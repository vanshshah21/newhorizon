import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:nhapp/pages/sales_order/models/add_sales_order.dart';
import 'package:nhapp/pages/sales_order/models/sales_order.dart';
import 'package:nhapp/pages/sales_order/pages/add_item.dart';
import 'package:nhapp/pages/sales_order/pages/sales_order_details.dart';
import 'package:nhapp/pages/sales_order/service/add_service.dart';
import 'package:nhapp/pages/sales_order/service/so_attachment.dart';
import 'package:nhapp/utils/format_utils.dart';
import 'package:nhapp/utils/location_utils.dart';
import 'package:nhapp/utils/storage_utils.dart';
import 'package:file_picker/file_picker.dart';

class AddSalesOrderPage extends StatefulWidget {
  final Map<String, dynamic>? quotationData;
  final Map<String, dynamic>? quotationListItem;
  const AddSalesOrderPage({
    super.key,
    this.quotationData,
    this.quotationListItem,
  });

  @override
  State<AddSalesOrderPage> createState() => _AddSalesOrderPageState();
}

class _AddSalesOrderPageState extends State<AddSalesOrderPage> {
  late SalesOrderService _service;
  late final SalesOrderAttachmentService _attachmentService;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController orderFromController = TextEditingController();
  final TextEditingController billToController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController customerPONumberController =
      TextEditingController();
  final TextEditingController customerPODateController =
      TextEditingController();
  final TextEditingController quotationNumberController =
      TextEditingController();

  String salesOrderReference = "Without Quotation Reference";
  Customer? selectedOrderFrom;
  Customer? selectedBillTo;
  DateTime? selectedDate;
  DateTime? selectedCustomerPODate;
  List<RateStructure> rateStructures = [];
  List<SalesOrderItem> items = [];
  List<PlatformFile> attachments = [];
  late Map<String, dynamic> documentDetail;
  bool _isLoading = true;
  bool _submitting = false;
  DateTime? startDate;
  DateTime? endDate;
  late Map<String, dynamic>? _financeDetails;
  late bool _autogenerateoafonsalesorder;

  List<QuotationNumber> quotationNumbers = [];
  List<QuotationItemDetail> quotationItemDetails = [];
  QuotationNumber? selectedQuotationNumber;
  List<Map<String, dynamic>> oafGroupCodes = [];
  Map<String, dynamic>? selectedOAFGroup;
  bool _loadingQuotationDetails = false;
  bool _isDuplicateAllowed = false;
  List<DiscountCode> discountCodes = [];
  late String currency;
  double _exchangeRate = 1.0;

  @override
  void initState() {
    super.initState();
    _attachmentService = SalesOrderAttachmentService(Dio());
    _initializeForm();
  }

  Future<void> _initializeForm() async {
    await initializeCurrencyCode();
    _service = await SalesOrderService.create();
    await _loadFinancePeriod();
    await _loadRateStructures();
    await _loadDiscountCodes();
    await _loadDocumentDetail();
    await _loadSalesPolicy();
    await _getExchangeRate();
    if (_autogenerateoafonsalesorder) {
      final oafGroupCodes = await _service.fetchOAFGroupCodes();
      if (oafGroupCodes.isNotEmpty) {
        _financeDetails?['oafGroupCodes'] = oafGroupCodes;
        this.oafGroupCodes = oafGroupCodes;
        if (oafGroupCodes.length == 1) {
          selectedOAFGroup = oafGroupCodes.first;
        }
      }
    }

    // Prefill data if coming from quotation
    if (widget.quotationData != null && widget.quotationListItem != null) {
      await _prefillFromQuotation();
    }

    setState(() => _isLoading = false);
  }

  Future<void> _prefillFromQuotation() async {
    final quotationData = widget.quotationData!;
    final quotationItem = widget.quotationListItem!;

    try {
      // Set sales order reference to "With Quotation Reference"
      setState(() {
        salesOrderReference = "With Quotation Reference";
      });

      // Extract quotation details
      final quotationDetails =
          quotationData['quotationDetails'] as Map<String, dynamic>;

      // Create customer data from quotation
      final customerCode = quotationDetails['customerCode']?.toString() ?? '';
      final customerName = quotationDetails['customerName']?.toString() ?? '';
      final billToCode =
          quotationDetails['billToCode']?.toString() ?? customerCode;
      final billToName =
          quotationDetails['billToName']?.toString() ?? customerName;

      if (customerCode.isNotEmpty && customerName.isNotEmpty) {
        // Set Order From customer
        selectedOrderFrom = Customer(
          customerCode: customerCode,
          customerName: customerName,
          customerFullName: customerCode + ' - ' + customerName,
          gstNumber: quotationDetails['gstNumber']?.toString() ?? '',
          telephoneNo: quotationDetails['telephoneNo']?.toString() ?? '',
        );
        orderFromController.text = customerName;

        // Set Bill To customer
        selectedBillTo = Customer(
          customerCode: billToCode,
          customerName: billToName,
          customerFullName: customerCode + ' - ' + customerName,
          gstNumber: quotationDetails['gstNumber']?.toString() ?? '',
          telephoneNo: quotationDetails['telephoneNo']?.toString() ?? '',
        );
        billToController.text = billToName;

        // Load quotation numbers for this customer
        await _loadQuotationNumbers(customerCode);

        // Find and select the current quotation from the loaded list
        final quotationId = quotationItem['quotationId'] as int? ?? 0;
        if (quotationId > 0) {
          final matchingQuotation =
              quotationNumbers
                  .where((q) => q.quotationID == quotationId)
                  .firstOrNull;
          if (matchingQuotation != null) {
            // This will trigger the API call to fetch quotation details
            await _onQuotationNumberSelected(matchingQuotation);
          }
        }
      }

      // Prefill customer PO details if available
      final custPONumber = quotationDetails['custPONumber']?.toString() ?? '';
      if (custPONumber.isNotEmpty) {
        customerPONumberController.text = custPONumber;
      }

      final custPODate = quotationDetails['custPODate']?.toString();
      if (custPODate != null && custPODate.isNotEmpty) {
        try {
          selectedCustomerPODate = DateTime.parse(custPODate);
          customerPODateController.text = FormatUtils.formatDateForUser(
            selectedCustomerPODate!,
          );
        } catch (e) {
          // Use default date if parsing fails
          debugPrint('Error parsing customer PO date: $e');
        }
      }
    } catch (e) {
      debugPrint('Error prefilling quotation data: $e');
    }
  }

  Future<void> _getExchangeRate() async {
    try {
      final domCurrency = await StorageUtils.readJson('domestic_currency');
      if (domCurrency == null) throw Exception("Domestic currency not set");

      currency = domCurrency['domCurCode'] ?? 'INR';
      _exchangeRate = await _service.getExchangeRate();
    } catch (e) {
      debugPrint("Error loading exchange rate: $e");
      _exchangeRate = 1.0; // Default to 1.0 if there's an error
    }
  }

  Future<void> _loadDiscountCodes() async {
    try {
      discountCodes = await _service.fetchDiscountCodes();
    } catch (e) {
      debugPrint("Error loading discount codes: $e");
      discountCodes = []; // Default to empty list if there's an error
    }
  }

  Future<void> _uploadAttachments(
    String salesOrderNumber,
    String documentId,
  ) async {
    if (attachments.isEmpty) return;

    try {
      final companyDetails = await StorageUtils.readJson('selected_company');
      final locationDetails = await StorageUtils.readJson('selected_location');
      final companyId = companyDetails['id'];
      final companyCode = companyDetails['code'];
      final locationCode = locationDetails['code'];
      final locationId = locationDetails['id'];
      final docYear = _financeDetails?['financialYear'] ?? "";
      final userId = _service.tokenDetails['user']['id'] ?? 0;

      // Get file paths from PlatformFile objects
      final filePaths =
          attachments
              .map((f) => f.path!)
              .where((path) => path.isNotEmpty)
              .toList();
      if (filePaths.isEmpty) return;

      final documentNo =
          "$docYear/${documentDetail['groupCode'] ?? "SO"}/$locationCode/$salesOrderNumber/SALESORDERENTRY";

      final uploadSuccess = await _attachmentService.uploadAttachments(
        filePaths: filePaths,
        documentNo: documentNo,
        documentId: documentId,
        docYear: docYear,
        formId: "06105",
        locationCode: locationCode,
        companyCode: companyCode,
        locationId: locationId,
        companyId: companyId,
        userId: userId,
      );

      // if (!uploadSuccess) {
      //   _showError("Sales Order saved, but attachment upload failed!");
      // }
    } catch (e) {
      debugPrint('Error uploading attachments: $e');
      // _showError("Sales Order saved, but attachment upload failed!");
    }
  }

  Future<void> _loadSalesPolicy() async {
    try {
      final salesPolicy = await _service.getSalesPolicy();
      _isDuplicateAllowed =
          salesPolicy['allowduplictae'] ??
          salesPolicy['allowduplicate'] ??
          false;
      final autogenerateoafonsalesorder = await StorageUtils.readJson(
        'salesPolicy',
      );
      _autogenerateoafonsalesorder =
          autogenerateoafonsalesorder['autogenerateoafonsalesorder'] ??
          autogenerateoafonsalesorder['autogenerateoafonso'] ??
          false;
    } catch (e) {
      debugPrint("Error loading sales policy: $e");
      _isDuplicateAllowed = false; // Default to not allowing duplicates
    }
  }

  Future<void> _loadFinancePeriod() async {
    _financeDetails = await StorageUtils.readJson('finance_period');
    if (_financeDetails != null) {
      startDate = DateTime.parse(_financeDetails!['periodSDt']);
      endDate = DateTime.parse(_financeDetails!['periodEDt']);
      final now = DateTime.now();
      selectedDate = now.isAfter(endDate!) ? endDate : now;
      selectedCustomerPODate = selectedDate;
      dateController.text = FormatUtils.formatDateForUser(selectedDate!);
      customerPODateController.text = FormatUtils.formatDateForUser(
        selectedCustomerPODate!,
      );
    }
  }

  Future<void> _loadRateStructures() async {
    rateStructures = await _service.fetchRateStructures();
  }

  Future<void> _loadDocumentDetail() async {
    documentDetail = await _service.fetchDefaultDocumentDetail("OB");

    final domCurrency = await StorageUtils.readJson('domestic_currency');
    currency = domCurrency?['domCurCode'] ?? 'INR';
  }

  Future<void> _onOrderFromSelected(Customer customer) async {
    setState(() {
      selectedOrderFrom = customer;
      orderFromController.text = customer.customerName;
      billToController.text = customer.customerName;
      selectedBillTo = customer;
      quotationNumbers.clear();
      selectedQuotationNumber = null;
      quotationNumberController.clear();
      items.clear();
    });

    // Load quotation numbers if quotation reference is selected
    if (salesOrderReference == "With Quotation Reference") {
      await _loadQuotationNumbers(customer.customerCode);
    }
  }

  Future<void> _onBillToSelected(Customer customer) async {
    setState(() {
      selectedBillTo = customer;
      billToController.text = customer.customerName;
    });
  }

  Future<void> _loadQuotationNumbers(String customerCode) async {
    try {
      final quotationListResponse = await _service.fetchQuotationNumberList(
        customerCode,
      );

      quotationNumbers = quotationListResponse.quotationDetails;
      quotationItemDetails = quotationListResponse.quotationItemDetails;
      setState(() {});
    } catch (e) {
      _showError("Error loading quotation numbers: ${e.toString()}");
    }
  }

  Future<void> _onQuotationNumberSelected(
    QuotationNumber quotationNumber,
  ) async {
    setState(() {
      selectedQuotationNumber = quotationNumber;
      quotationNumberController.text = quotationNumber.qtnNumber;
      _loadingQuotationDetails = true;
      items.clear();
    });

    try {
      // Filter items for the selected quotation
      final selectedQuotationItems =
          quotationItemDetails
              .where((item) => item.quotationId == quotationNumber.quotationID)
              .toList();

      // Build request body for fetching quotation details
      final requestBody = {
        "QtnYear": quotationNumber.quotationYear,
        "QtnGrp": quotationNumber.quotationGroup,
        "QtnNumber": quotationNumber.quotationNumber,
        "QtnSiteId": quotationNumber.quotationSiteId,
      };

      final quotationDetails = await _service.fetchQuotationDetails(
        requestBody,
      );

      // Convert quotation items to sales order items
      int lineNo = 1;
      for (final detail in quotationDetails.modelDetails) {
        // Calculate discount details properly
        String discountType = "None";
        double? discountPercentage;
        double? discountAmount;
        String? discountCode;

        // Look for discount in discountDetails array first
        if (quotationDetails.discountDetail != null &&
            quotationDetails.discountDetail!.isNotEmpty) {
          final discountDetail = quotationDetails.discountDetail!.firstWhere(
            (d) =>
                d['salesItemCode'] == detail['salesItemCode'] &&
                d['itmLineNo'] == detail['itemLineNo'],
            orElse: () => {},
          );

          if (discountDetail.isNotEmpty) {
            final discType = discountDetail['discountType'] ?? 'N';
            final discValue = (discountDetail['discountValue'] ?? 0).toDouble();
            discountCode = discountDetail['discountCode'];

            if (discType == 'P' && discValue > 0) {
              discountType = 'Percentage';
              discountPercentage = discValue;
              final basicAmount =
                  (detail['basicPriceSUOM'] ?? 0).toDouble() *
                  (detail['qtySUOM'] ?? 0).toDouble();
              discountAmount = basicAmount * (discValue / 100);
            } else if (discType == 'V' && discValue > 0) {
              discountType = 'Value';
              discountAmount = discValue;
              final basicAmount =
                  (detail['basicPriceSUOM'] ?? 0).toDouble() *
                  (detail['qtySUOM'] ?? 0).toDouble();
              discountPercentage =
                  basicAmount > 0 ? (discValue / basicAmount) * 100 : 0;
            }
          }
        }

        // Fallback: check if discount is in the model detail itself
        if (discountType == "None" && detail['discountAmt'] != null) {
          final discAmt = (detail['discountAmt'] ?? 0).toDouble();
          if (discAmt > 0) {
            discountType = 'Value';
            discountAmount = discAmt;
            final basicAmount =
                (detail['basicPriceSUOM'] ?? 0).toDouble() *
                (detail['qtySUOM'] ?? 0).toDouble();
            discountPercentage =
                basicAmount > 0 ? (discAmt / basicAmount) * 100 : 0;
          }
        }

        // Calculate amounts
        final basicRate = (detail['basicPriceSUOM'] ?? 0).toDouble();
        final qty = (detail['qtySUOM'] ?? 0).toDouble();
        final basicAmount = basicRate * qty;
        final discountedAmount = basicAmount - (discountAmount ?? 0);

        // Calculate tax amount from rate structure details - FIXED
        double taxAmount = 0.0;
        List<Map<String, dynamic>> rateStructureRows = [];

        if (quotationDetails.rateStructureDetails != null) {
          rateStructureRows =
              quotationDetails.rateStructureDetails!
                  .where(
                    (rs) =>
                        rs['customerItemCode'] == detail['salesItemCode'] &&
                        rs['lineNo'] == detail['itemLineNo'],
                  )
                  .toList();

          // Calculate tax amount using the discounted amount as base
          for (final rsDetail in rateStructureRows) {
            final rateAmount = (rsDetail['rateAmount'] ?? 0).toDouble();
            taxAmount += rateAmount;
          }
        }

        final totalAmount = discountedAmount + taxAmount;

        items.add(
          SalesOrderItem(
            itemName: detail['salesItemDesc'] ?? '',
            itemCode: detail['salesItemCode'] ?? '',
            qty: qty,
            basicRate: basicRate,
            uom: detail['uom'] ?? 'NOS',
            discountType: discountType,
            discountPercentage: discountPercentage,
            discountAmount: discountAmount,
            discountCode: discountCode,
            rateStructure: detail['rateStructureCode'] ?? '',
            taxAmount: taxAmount,
            totalAmount: totalAmount,
            rateStructureRows: rateStructureRows,
            lineNo: lineNo,
            hsnCode: detail['hsnCode'] ?? '',
          ),
        );
        lineNo++;
      }

      setState(() {});
    } catch (e) {
      _showError("Error loading quotation details: ${e.toString()}");
    } finally {
      setState(() => _loadingQuotationDetails = false);
    }
  }

  Map<String, dynamic> _buildSubmissionPayload() {
    final userId = _service.tokenDetails['user']['id'] ?? 0;
    final locationId = _service.locationDetails['id'] ?? 0;
    final locationCode = _service.locationDetails['code'] ?? "";
    final companyCode = _service.companyDetails['code'] ?? "";
    final companyId = _service.companyId;
    final docYear = _financeDetails?['financialYear'] ?? "";

    // Build model details
    List<Map<String, dynamic>> modelDetails = [];
    List<Map<String, dynamic>> discountDetails = [];
    List<Map<String, dynamic>> rateStructureDetails = [];
    List<Map<String, dynamic>> deliveryDetails = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      item.lineNo = i + 1;

      final modelDetail = item.toModelDetail();
      modelDetail['custPONumber'] = customerPONumberController.text;

      // Add quotation reference if applicable
      if (salesOrderReference == "With Quotation Reference" &&
          selectedQuotationNumber != null) {
        // Find the corresponding quotation item detail
        final quotationItemDetail = quotationItemDetails.firstWhere(
          (qItem) =>
              qItem.salesItemCode == item.itemCode &&
              qItem.quotationId == selectedQuotationNumber!.quotationID,
          orElse:
              () =>
                  quotationItemDetails.isNotEmpty
                      ? quotationItemDetails.first
                      : QuotationItemDetail(
                        select: false,
                        salesItemCode: '',
                        salesItemDesc: '',
                        uom: '',
                        itemQtySUOM: 0,
                        itemRate: 0,
                        itemValue: 0,
                        quotationId: 0,
                        itemLineNo: 0,
                        currencyCode: '',
                        quotationStatus: '',
                        conversionFactor: 1,
                        amendSrNo: 0,
                        agentCode: '',
                      ),
        );

        modelDetail['quotationId'] = selectedQuotationNumber!.quotationID;
        modelDetail['quotationLineNo'] = quotationItemDetail.itemLineNo;
        modelDetail['quotationAmendNo'] = quotationItemDetail.amendSrNo;
      }
      modelDetails.add(modelDetail);

      final discountDetail = item.toDiscountDetail();
      if (discountDetail.isNotEmpty) {
        discountDetails.add(discountDetail);
      }

      rateStructureDetails.addAll(item.toRateStructureDetails());

      // Create delivery detail for each item
      final deliveryDetail = {
        "modelNo": "", // XORDMDLNO
        "itemCode": item.itemCode, // XORDSITMCD
        "itemOrderQty": item.qty, // XORDITMQTY
        "orderType": "REG", // XORDTYP
        "qtySUOM": item.qty, // XORDDLVQTY
        "deliveryDate": FormatUtils.formatDateForApi(
          selectedDate!,
        ), // XORDDLVDT
        "expectedInstallationDate": FormatUtils.formatDateForApi(
          selectedDate!.add(const Duration(days: 1)),
        ), // ExpInstalDt, XORDEXPINSTALDT
        "amendSrNo": 0, // XORDAMDSRNO
        "commitedDelDate": null, // XORDCDDT
        "shipmentCode": "CADD", // XODShipCd in future using api
        "amendYear": "", // XORDAMDYEAR
        "amendGroup": "", // XORDAMDGRP
        "amendSiteId": 0, // XORDAMDSITEID
        "amendNumber": "", // XORDAMDNO
        "amendDate": null, // XORDAMDDT
        "amendAuthDate": null, // XORDAMDAUDT
        "oafQty": 0.0, // XORDOAFQTY
        "sjoQty": 0.0, // XORDSJOQTY
        "lineId": 0, // XORDLINEID
        "itemLineNo": item.lineNo, // XORDITMLINENO
      };
      deliveryDetails.add(deliveryDetail);
    }

    final totalBasic = _calculateTotalBasic();
    final totalDiscount = _calculateTotalDiscount();
    final totalTax = _calculateTotalTax();
    final totalAfterDiscount = totalBasic - totalDiscount;
    final finalAmount = totalAfterDiscount + totalTax;

    return {
      "authorizationRequired": documentDetail['isAutorisationRequired'] ?? "Y",
      "autoNumberRequired": documentDetail['isAutoNumberGenerated'] ?? "Y",
      "siteRequired": documentDetail['isLocationRequired'] ?? "Y",
      "authorizationDate": null,
      "fromLocationId": locationId,
      "userId": userId,
      "companyId": companyId,
      "companyCode": companyCode,
      "fromLocationCode": locationCode,
      "fromLocationName": _service.locationDetails['name'] ?? "",
      "ip": "",
      "mac": "",
      "docType": "OB",
      "docSubType": "OB",
      "domesticCurrencyCode": currency,
      "salesOrderDetails": {
        "orderId": 0,
        "customerPONumber": customerPONumberController.text,
        "customerPODate": FormatUtils.formatDateForApi(selectedCustomerPODate!),
        "quotationId":
            salesOrderReference == "With Quotation Reference" &&
                    selectedQuotationNumber != null
                ? selectedQuotationNumber!.quotationID
                : 0,
        "quotationYear":
            salesOrderReference == "With Quotation Reference" &&
                    selectedQuotationNumber != null
                ? selectedQuotationNumber!.quotationYear
                : "",
        "quotationGroup":
            salesOrderReference == "With Quotation Reference" &&
                    selectedQuotationNumber != null
                ? selectedQuotationNumber!.quotationGroup
                : "",
        "quotationNumber":
            salesOrderReference == "With Quotation Reference" &&
                    selectedQuotationNumber != null
                ? selectedQuotationNumber!.quotationNumber
                : "",
        "OAFGroup":
            _autogenerateoafonsalesorder
                ? selectedOAFGroup != null
                    ? selectedOAFGroup!['groupCode']
                    : ""
                : "",
        "quotationDate":
            salesOrderReference == "With Quotation Reference" &&
                    selectedQuotationNumber != null
                ? FormatUtils.formatDateForApi(
                  selectedQuotationNumber!.quotationDate,
                )
                : null,
        "customerCode": selectedOrderFrom?.customerCode ?? "",
        "customerName": selectedOrderFrom?.customerName ?? "",
        "salesManCode":
            salesOrderReference == "With Quotation Reference" &&
                    selectedQuotationNumber != null
                ? selectedQuotationNumber!.salesmanCode
                : "",
        "attachFlag": "",
        "totalAmountAfterDiscountCustomerCurrency": totalAfterDiscount
            .toStringAsFixed(2),
        "totalAmountAfterDiscountDomesticCurrency": totalAfterDiscount
            .toStringAsFixed(2),
        "totalAmounttAfterTaxDomesticCurrency": finalAmount.toStringAsFixed(2),
        "totalAmountAfterTaxCustomerCurrency": finalAmount.toStringAsFixed(2),
        "discountType": "N",
        "discountAmount": 0,
        "exchangeRate": _exchangeRate.toString(),
        "OrderStatus": "O",
        "xobCredit": "",
        "xobcrauth": "",
        "amendSrNo": 0,
        "ioYear": docYear,
        "ioGroup": documentDetail['groupCode'] ?? "SO",
        "ioSiteId": locationId.toString(),
        "ioSiteCode": locationCode,
        "ioDate": FormatUtils.formatDateForApi(selectedDate!),
        "amendYear": "",
        "amendGroup": "",
        "amendSiteId": 0,
        "amendSiteCode": "",
        "amendNumber": "",
        "amendDate": null,
        "amendAuthBy": 0,
        "amendAuthByDate": null,
        "custType": "CU",
        "lcDetail": "F",
        "bgDetail": "F",
        "salesOrderType": "REG",
        "isAgentAssociated":
            salesOrderReference == "With Quotation Reference" &&
            selectedQuotationNumber != null &&
            selectedQuotationNumber!.agentCode.isNotEmpty,
        "custContactPersonId": "",
        "salesOrderRefNo": "",
        "buyerCode": 0,
        "soDeliveryDate": null,
        "currencyCode":
            salesOrderReference == "With Quotation Reference" &&
                    selectedQuotationNumber != null
                ? selectedQuotationNumber!.quotationCurrency
                : currency,
        "bookCode": "",
        "agentCode":
            salesOrderReference == "With Quotation Reference" &&
                    selectedQuotationNumber != null
                ? selectedQuotationNumber!.agentCode
                : "",
        "ioNumber": "",
        "modOfDispatchCode": "",
        "isFreeSupply": false,
        "isReturnable": false,
        "isRoadPermitReceived": false,
        "customerLOINumber": "",
        "customerLOIDate": "",
        "isInterBranchTransfer": false,
        "customerPOId": 0,
        "consultantCode":
            salesOrderReference == "With Quotation Reference" &&
                    selectedQuotationNumber != null
                ? selectedQuotationNumber!.consultantCode
                : "",
        "billToCode": selectedBillTo?.customerCode ?? "",
        "billToCreditLimit": 0,
        "billToAccBalance": 0,
        "config": "N",
        "projectName": "",
      },
      "modelDetails": modelDetails,
      "discountDetails": discountDetails,
      "rateStructureDetails": rateStructureDetails,
      "DeliveryDetails": deliveryDetails, // Updated to use the populated list
      "paymentDetails": [],
      "termDetails": [],
      "specificationDetails": [],
      "optionalItemDetails": [],
      "textDetails": [],
      "standardTerms": [],
      "historyDetails": [],
      "addOnDetails": [],
      "subItemDetails": [],
      "noteDetails": [],
      "projectLotDetails": [],
      "equipmentAttributeDetails": [],
      "technicalspec": [],
      "msctechspecifications": true,
    };
  }

  Future<void> _showAddItemPage() async {
    final result = await Navigator.push<SalesOrderItem>(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddSalesOrderItemPage(
              rateStructures: rateStructures,
              service: _service,
              existingItems: items, // Pass existing items
              isDuplicateAllowed: _isDuplicateAllowed, // Pass duplicate flag
            ),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
    if (result != null) {
      setState(() {
        result.lineNo = items.length + 1;
        items.add(result);
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      items.removeAt(index);
      // Re-assign line numbers
      for (int i = 0; i < items.length; i++) {
        items[i].lineNo = i + 1;
      }
    });
  }

  double _calculateTotalBasic() {
    return items.fold(0.0, (sum, item) => sum + (item.basicRate * item.qty));
  }

  double _calculateTotalDiscount() {
    return items.fold(0.0, (sum, item) => sum + (item.discountAmount ?? 0.0));
  }

  double _calculateTotalTax() {
    return items.fold(0.0, (sum, item) => sum + (item.taxAmount ?? 0.0));
  }

  double _calculateTotalAmount() {
    return items.fold(0.0, (sum, item) => sum + item.totalAmount);
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        attachments.addAll(result.files);
      });
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      attachments.removeAt(index);
    });
  }

  Future<SalesOrder?> fetchSalesOrderList({String? searchValue}) async {
    final Dio _dio = Dio();
    final url = await StorageUtils.readValue("url");
    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) throw Exception("Company not set");

    final tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails == null) throw Exception("Session token not found");

    final locationDetails = await StorageUtils.readJson('selected_location');
    if (locationDetails == null) throw Exception("Location details not found");

    final financeDetails = await StorageUtils.readJson('finance_period');
    if (financeDetails == null) throw Exception("Finance details not found");

    final companyId = companyDetails['id'];
    final locationId = locationDetails['id'];
    final token = tokenDetails['token']['value'];
    final year = financeDetails['financialYear'];
    final companycd = companyDetails['code'];
    final userId = tokenDetails['user']['userName'];

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyId;
    _dio.options.headers['Authorization'] = 'Bearer $token';

    final body = {
      "year": year,
      "type": "OB",
      "subType": "OB",
      "locId": locationId,
      "userId": userId,
      "comCode": companycd,
      "flag": "SITEID",
      "pageSize": 1,
      "pageNumber": 1,
      "sortField": "",
      "sortDirection": "",
      "searchValue": searchValue ?? "",
      "restcoresalestrans": "false",
      "companyId": companyId,
      "usrLvl": 0,
      "usrSubLvl": 0,
      "valLimit": 0,
    };

    final endpoint = "/api/SalesOrder/SalesOrderGetList";
    debugPrint('Fetching Sales Orders with body: $body');
    final response = await _dio.post('http://$url$endpoint', data: body);
    debugPrint('Sales Order Response: ${response}');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data']?['solist'] ?? [];
      if (data.isNotEmpty) {
        return SalesOrder.fromJson(data.first);
      } else {
        return null;
      }
    } else {
      debugPrint('Failed to fetch Sales Orders: ${response.data}');
      throw Exception('Failed to load Sales Orders');
    }
  }

  Future<void> _submitSalesOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedOrderFrom == null) {
      _showError("Please select Order From customer");
      return;
    }
    if (selectedBillTo == null) {
      _showError("Please select Bill To customer");
      return;
    }
    if (salesOrderReference == "With Quotation Reference" &&
        selectedQuotationNumber == null) {
      _showError("Please select Quotation Number");
      return;
    }
    if (customerPONumberController.text.isEmpty) {
      _showError("Please enter Customer PO Number");
      return;
    }
    if (selectedCustomerPODate == null) {
      _showError("Please select Customer PO Date");
      return;
    }
    if (items.isEmpty) {
      _showError("Please add at least one item");
      return;
    }

    // Step 1: Check location status before starting submission
    final locationStatus = await LocationUtils.instance.checkLocationStatus();

    if (locationStatus != LocationStatus.granted) {
      final shouldContinue = await LocationUtils.instance.showLocationDialog(
        context,
        locationStatus,
      );

      if (!shouldContinue) {
        return;
      }

      // Re-check location status after user interaction
      final newStatus = await LocationUtils.instance.checkLocationStatus();
      if (newStatus != LocationStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location access is required to submit the sales order',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Step 2: Get current location
    setState(() => _submitting = true);

    final position = await LocationUtils.instance.getCurrentLocation();
    if (position == null) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to get current location. Please try again.'),
          // backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final payload = _buildSubmissionPayload();
      final response = await _service.submitSalesOrder(payload);

      if (response['success'] == true) {
        // Step 3: Submit location and handle attachments with proper error handling
        bool locationSuccess = true;
        bool attachmentSuccess = true;

        List<String> errorMessages = [];

        // Extract function ID and sales order number for location submission
        final String responseData = response['data'];
        final String salesOrderNumber = "${responseData.split('#')[0]}";
        final String documentId = responseData.split('#')[1];
        String? functionId = documentId;

        // Submit location if we have the function ID
        if (functionId.isNotEmpty) {
          try {
            locationSuccess = await _service.submitLocation(
              functionId: functionId,
              longitude: position.longitude,
              latitude: position.latitude,
            );

            // if (!locationSuccess) {
            //   errorMessages.add('Location submission failed');
            // }
          } catch (e) {
            debugPrint('Location submission error: $e');
            locationSuccess = false;
            // errorMessages.add('Location submission failed: $e');
          }
        } else {
          locationSuccess = false;
          // errorMessages.add(
          //   'Unable to get function ID for location submission',
          // );
        }
        // Upload attachments if any
        if (attachments.isNotEmpty) {
          final String responseData = response['data'];
          final String salesOrderNumber = "${responseData.split('#')[0]}";
          final String documentId = responseData.split('#')[1];

          if (salesOrderNumber.isNotEmpty) {
            await _uploadAttachments(salesOrderNumber, documentId);
          }
        }

        _showSuccess(
          response['message'] ?? "Sales Order submitted successfully",
        );
        try {
          final salesOrderDetails = await fetchSalesOrderList(
            searchValue: response['data'].split('#')[0],
          );

          if (salesOrderDetails != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sales Order created successfully!'),
              ),
            );

            // Navigate to SalesOrderDetailPage
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder:
                    (context) =>
                        SalesOrderDetailPage(salesOrder: salesOrderDetails),
              ),
            );
          } else {
            _showError("Failed to fetch the created sales order details.");
          }
        } catch (e) {
          Navigator.pop(context, true);
        }
      } else {
        _showError("Failed to submit sales order");
      }
    } catch (e) {
      _showError("Error during submission.");
    } finally {
      setState(() => _submitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  void dispose() {
    orderFromController.dispose();
    billToController.dispose();
    dateController.dispose();
    customerPONumberController.dispose();
    customerPODateController.dispose();
    quotationNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Sales Order"), elevation: 1),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSalesOrderReferenceDropdown(),
                      const SizedBox(height: 16),
                      _buildOrderFromField(),
                      const SizedBox(height: 16),
                      _buildBillToField(),
                      const SizedBox(height: 16),
                      // ADD THIS CONDITIONAL BLOCK FOR QUOTATION NUMBER
                      if (salesOrderReference ==
                          "With Quotation Reference") ...[
                        _buildQuotationNumberField(),
                        const SizedBox(height: 16),
                      ],
                      _buildDateField(),
                      const SizedBox(height: 16),
                      _autogenerateoafonsalesorder
                          ? _buildOAFGroupField()
                          : Container(),
                      const SizedBox(height: 16),
                      _buildCustomerPONumberField(),
                      const SizedBox(height: 16),
                      _buildCustomerPODateField(),
                      const SizedBox(height: 16),
                      // ADD LOADING INDICATOR FOR QUOTATION DETAILS
                      if (_loadingQuotationDetails)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      if (items.isNotEmpty) ...[
                        _buildItemsList(),
                        const SizedBox(height: 16),
                      ],
                      // CONDITIONALLY SHOW ADD ITEM BUTTON
                      if (salesOrderReference == "Without Quotation Reference")
                        _buildAddItemButton(),
                      if (items.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildTotalCard(),
                      ],
                      const SizedBox(height: 24),
                      _buildAttachmentSection(),
                      const SizedBox(height: 24),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSalesOrderReferenceDropdown() {
    bool prefilled = widget.quotationData != null;
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: "Sales Order Reference",
        border: const OutlineInputBorder(),
        enabled:
            !prefilled && !_submitting, // Disable if prefilled OR submitting
      ),
      value: salesOrderReference,
      items:
          ["Without Quotation Reference", "With Quotation Reference"]
              .map(
                (option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                ),
              )
              .toList(),
      onChanged:
          (prefilled ||
                  _submitting) // Disable onChanged if prefilled OR submitting
              ? null
              : (val) {
                if (val != null) {
                  setState(() {
                    salesOrderReference = val;
                    // Clear all related fields
                    items.clear();
                    quotationNumbers.clear();
                    selectedQuotationNumber = null;
                    quotationNumberController.clear();
                  });

                  // Load quotation numbers if customer is already selected and "With Quotation Reference" is chosen
                  if (val == "With Quotation Reference" &&
                      selectedOrderFrom != null) {
                    _loadQuotationNumbers(selectedOrderFrom!.customerCode);
                  }
                }
              },
      validator:
          (val) => val == null ? "Sales Order Reference is required" : null,
    );
  }

  Widget _buildQuotationNumberField() {
    bool prefilled = widget.quotationData != null;
    return DropdownButtonFormField<QuotationNumber>(
      decoration: InputDecoration(
        labelText: "Quotation Number",
        border: const OutlineInputBorder(),
        enabled:
            !prefilled &&
            !_submitting &&
            !_loadingQuotationDetails, // Disable if prefilled, submitting, or loading
      ),
      value: selectedQuotationNumber,
      isExpanded: true,
      items:
          quotationNumbers.map((quotation) {
            return DropdownMenuItem<QuotationNumber>(
              value: quotation,
              child: Text(quotation.qtnNumber, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
      onChanged:
          (prefilled || _submitting || _loadingQuotationDetails)
              ? null
              : (val) {
                if (val != null) {
                  _onQuotationNumberSelected(val);
                }
              },
      validator:
          salesOrderReference == "With Quotation Reference"
              ? (val) => val == null ? "Quotation Number is required" : null
              : null,
    );
  }

  Widget _buildOrderFromField() {
    bool prefilled = widget.quotationData != null;

    return TypeAheadField<Customer>(
      debounceDuration: const Duration(milliseconds: 400),
      controller: orderFromController,
      builder: (context, controller, focusNode) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: !prefilled && !_submitting,
          decoration: const InputDecoration(
            labelText: "Order From",
            border: OutlineInputBorder(),
          ),
          validator:
              (val) =>
                  val == null || val.isEmpty ? "Order From is required" : null,
        );
      },
      suggestionsCallback:
          (prefilled || _submitting)
              ? (pattern) async => []
              : (pattern) async {
                if (pattern.length < 4) return [];
                try {
                  return await _service.fetchCustomerSuggestions(pattern);
                } catch (e) {
                  return [];
                }
              },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion.customerName),
          subtitle: Text(suggestion.customerCode),
        );
      },
      onSelected: (prefilled || _submitting) ? null : _onOrderFromSelected,
    );
  }

  Widget _buildBillToField() {
    return TypeAheadField<Customer>(
      debounceDuration: const Duration(milliseconds: 400),
      controller: billToController,
      builder: (context, controller, focusNode) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: !_submitting,
          decoration: const InputDecoration(
            labelText: "Bill To",
            border: OutlineInputBorder(),
          ),
          validator:
              (val) =>
                  val == null || val.isEmpty ? "Bill To is required" : null,
        );
      },
      suggestionsCallback:
          _submitting
              ? (pattern) async => []
              : (pattern) async {
                if (pattern.length < 4) return [];
                try {
                  return await _service.fetchCustomerSuggestions(pattern);
                } catch (e) {
                  return [];
                }
              },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion.customerName),
          subtitle: Text(suggestion.customerCode),
        );
      },
      onSelected: _submitting ? null : _onBillToSelected,
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: dateController,
      decoration: const InputDecoration(
        labelText: "Date",
        suffixIcon: Icon(Icons.calendar_today),
        border: OutlineInputBorder(),
      ),
      readOnly: true,
      enabled: !_submitting,
      onTap:
          _submitting
              ? null
              : () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: startDate ?? DateTime(2000),
                  lastDate: endDate ?? DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                    dateController.text = FormatUtils.formatDateForUser(picked);
                  });
                }
              },
      validator:
          (val) => val == null || val.isEmpty ? "Date is required" : null,
    );
  }

  Widget _buildOAFGroupField() {
    return DropdownButtonFormField<Map<String, dynamic>>(
      decoration: const InputDecoration(
        labelText: "OAF Group",
        border: OutlineInputBorder(),
      ),
      value: selectedOAFGroup,
      isExpanded: true,
      items:
          oafGroupCodes.map((oafGroup) {
            return DropdownMenuItem<Map<String, dynamic>>(
              value: oafGroup,
              child: Text(
                oafGroup['fullName'] ??
                    "${oafGroup['groupCode']} - ${oafGroup['groupDescription']}", // Display fullName
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
      onChanged:
          _submitting
              ? null
              : (val) {
                setState(() {
                  selectedOAFGroup = val;
                });
              },
      validator: (val) => val == null ? "OAF Group is required" : null,
    );
  }

  Widget _buildCustomerPONumberField() {
    return TextFormField(
      controller: customerPONumberController,
      enabled: !_submitting,
      decoration: const InputDecoration(
        labelText: "Customer PO Number",
        border: OutlineInputBorder(),
      ),
      validator:
          (val) =>
              val == null || val.isEmpty
                  ? "Customer PO Number is required"
                  : null,
    );
  }

  Widget _buildCustomerPODateField() {
    return TextFormField(
      controller: customerPODateController,
      decoration: const InputDecoration(
        labelText: "Customer PO Date",
        suffixIcon: Icon(Icons.calendar_today),
        border: OutlineInputBorder(),
      ),
      readOnly: true,
      enabled: !_submitting,
      onTap:
          _submitting
              ? null
              : () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedCustomerPODate ?? DateTime.now(),
                  firstDate: startDate ?? DateTime(2000),
                  lastDate: selectedDate ?? DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    selectedCustomerPODate = picked;
                    customerPODateController
                        .text = FormatUtils.formatDateForUser(picked);
                  });
                }
              },
      validator:
          (val) =>
              val == null || val.isEmpty
                  ? "Customer PO Date is required"
                  : null,
    );
  }

  Widget _buildAddItemButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _submitting ? null : _showAddItemPage,
        icon: const Icon(Icons.add),
        label: const Text("Add New Item"),
      ),
    );
  }

  Widget _buildItemsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Items:",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: ListTile(
                title: Text(item.itemName),
                subtitle: Text(
                  "Qty: ${item.qty} ${item.uom}\nRate: ₹${item.basicRate.toStringAsFixed(2)}\nTax: ₹${(item.taxAmount ?? 0).toStringAsFixed(2)}\nTotal: ₹${item.totalAmount.toStringAsFixed(2)}",
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _submitting ? null : () => _removeItem(index),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTotalCard() {
    final totalBasic = _calculateTotalBasic();
    final totalDiscount = _calculateTotalDiscount();
    final totalTax = _calculateTotalTax();
    final netAmount = totalBasic - totalDiscount;
    final finalAmount = netAmount + totalTax;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Total Summary",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Basic Amount:"),
                Text("₹${totalBasic.toStringAsFixed(2)}"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Discount Value:"),
                Text("₹${totalDiscount.toStringAsFixed(2)}"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tax Amount:"),
                Text("₹${totalTax.toStringAsFixed(2)}"),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Amount:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "₹${finalAmount.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _submitting ? null : _pickFiles,
              icon: const Icon(Icons.attach_file),
              label: const Text('Add Attachment'),
            ),
            const SizedBox(width: 8),
            Text('${attachments.length} file(s) selected'),
          ],
        ),
        ...attachments.asMap().entries.map((entry) {
          final idx = entry.key;
          final file = entry.value;
          return ListTile(
            title: Text(file.name),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _submitting ? null : () => _removeAttachment(idx),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitting ? null : _submitSalesOrder,
        child:
            _submitting
                ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Text("Submit Sales Order"),
      ),
    );
  }
}
