import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:nhapp/pages/sales_order/models/add_sales_order.dart';
import 'package:nhapp/pages/sales_order/pages/add_item.dart';
import 'package:nhapp/pages/sales_order/service/add_service.dart';
import 'package:nhapp/pages/sales_order/service/so_attachment.dart';
import 'package:nhapp/utils/format_utils.dart';
import 'package:nhapp/utils/location_utils.dart';
import 'package:nhapp/utils/storage_utils.dart';
import 'package:file_picker/file_picker.dart';

class EditSalesOrderPage extends StatefulWidget {
  final String ioYear;
  final String ioGroup;
  final String ioSiteCode;
  final String ioNumber;
  final int locationId;

  const EditSalesOrderPage({
    super.key,
    required this.ioYear,
    required this.ioGroup,
    required this.ioSiteCode,
    required this.ioNumber,
    required this.locationId,
  });

  @override
  State<EditSalesOrderPage> createState() => _EditSalesOrderPageState();
}

class _EditSalesOrderPageState extends State<EditSalesOrderPage> {
  late SalesOrderService _service;
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
  late final SalesOrderAttachmentService _attachmentService;
  final List<PlatformFile> _newAttachments = [];
  final List<Map<String, dynamic>> _editableAttachments = [];
  String? _documentNo;

  String salesOrderReference = "Without Quotation Reference";
  Customer? selectedOrderFrom;
  Customer? selectedBillTo;
  DateTime? selectedDate;
  DateTime? selectedCustomerPODate;
  List<RateStructure> rateStructures = [];
  List<SalesOrderItem> items = [];
  List<PlatformFile> attachments = [];
  DocumentDetail? documentDetail;
  bool _isLoading = true;
  bool _submitting = false;
  DateTime? startDate;
  DateTime? endDate;
  late Map<String, dynamic>? _financeDetails;
  bool _isDuplicateAllowed = false;

  // Quotation related fields - Updated to match add_so.dart
  List<QuotationNumber> quotationNumbers = [];
  List<QuotationItemDetail> quotationItemDetails = [];
  QuotationNumber? selectedQuotationNumber;
  bool _loadingQuotationDetails = false;

  // Sales Order details
  Map<String, dynamic>? salesOrderDetails;
  String originalOrderId = "";

  @override
  void initState() {
    super.initState();
    _attachmentService = SalesOrderAttachmentService(Dio());
    _initializeForm();
  }

  Future<void> _initializeForm() async {
    _service = await SalesOrderService.create();
    await _loadFinancePeriod();
    await _loadRateStructures();
    await _loadSalesOrderDetails();
    await _loadSalesPolicy();
    await _loadAttachments();
    setState(() => _isLoading = false);
  }

  Future<void> _loadSalesPolicy() async {
    try {
      final salesPolicy = await _service.getSalesPolicy();
      _isDuplicateAllowed =
          salesPolicy['allowduplictae'] ??
          salesPolicy['allowduplicate'] ??
          false;
    } catch (e) {
      debugPrint("Error loading sales policy: $e");
      _isDuplicateAllowed = false; // Default to not allowing duplicates
    }
  }

  Future<void> _loadAttachments() async {
    try {
      final baseUrl = 'http://${await StorageUtils.readValue('url')}';
      final docYear = _financeDetails?['financialYear'] ?? "";
      final groupCode = widget.ioGroup;
      final locationCode = widget.ioSiteCode;

      _documentNo =
          "$docYear/$groupCode/$locationCode/${widget.ioNumber}/SALESORDERENTRY";

      final attachments = await _attachmentService.fetchSalesOrderAttachments(
        baseUrl: baseUrl,
        ioYear: widget.ioYear,
        ioGroup: widget.ioGroup,
        ioSiteCode: widget.ioSiteCode,
        ioNumber: widget.ioNumber,
      );

      setState(() {
        _editableAttachments.clear();
        _editableAttachments.addAll(
          attachments.map(
            (attachment) => {
              ...attachment,
              'action': 'none',
              'replacementFile': null,
            },
          ),
        );
      });
    } catch (e) {
      debugPrint('Error loading attachments: $e');
    }
  }

  Future<void> _loadFinancePeriod() async {
    _financeDetails = await StorageUtils.readJson('finance_period');
    if (_financeDetails != null) {
      startDate = DateTime.parse(_financeDetails!['periodSDt']);
      endDate = DateTime.parse(_financeDetails!['periodEDt']);
    }
  }

  Future<void> _loadRateStructures() async {
    rateStructures = await _service.fetchRateStructures();
  }

  Future<void> _loadSalesOrderDetails() async {
    try {
      final companyId = _service.companyDetails['id'];
      final response = await _service.fetchSalesOrderDetails(
        widget.ioYear,
        widget.ioGroup,
        widget.ioSiteCode,
        widget.ioNumber,
        widget.locationId,
        companyId,
      );

      if (response['success'] == true && response['data'] != null) {
        salesOrderDetails = response['data'];
        _populateFormFromResponse(salesOrderDetails!);
      }
    } catch (e) {
      _showError("Error loading sales order details: ${e.toString()}");
    }
  }

  void _populateFormFromResponse(Map<String, dynamic> data) {
    final soDetails = data['salesOrderDetails'][0];
    final modelDetails = data['modelDetails'] as List;
    final rateStructureDetails = data['rateStructureDetails'] as List;
    final discountDetails = data['discountDetails'] as List;

    // Set basic sales order details
    originalOrderId = soDetails['orderId'].toString();

    // Set customer details
    selectedOrderFrom = Customer(
      customerCode: soDetails['customerCode'] ?? '',
      customerName: soDetails['customerName'] ?? '',
      gstNumber: soDetails['gstNo'] ?? '',
      telephoneNo: '',
      customerFullName: soDetails['customerFullName'] ?? '',
    );
    orderFromController.text = selectedOrderFrom!.customerName;

    selectedBillTo = Customer(
      customerCode: soDetails['billToCode'] ?? '',
      customerName: soDetails['billToName'] ?? '',
      gstNumber: soDetails['gstNo'] ?? '',
      telephoneNo: '',
      customerFullName:
          "${soDetails['billToCode']} - ${soDetails['billToName']}",
    );
    billToController.text = selectedBillTo!.customerName;

    // Set dates
    selectedDate = DateTime.parse(soDetails['ioDate']);
    dateController.text = FormatUtils.formatDateForUser(selectedDate!);

    selectedCustomerPODate = DateTime.parse(soDetails['customerPODate']);
    customerPODateController.text = FormatUtils.formatDateForUser(
      selectedCustomerPODate!,
    );

    // Set customer PO number
    customerPONumberController.text = soDetails['customerPONumber'] ?? '';

    // Set quotation reference
    if (soDetails['quotationNumber'] != null &&
        soDetails['quotationNumber'].toString().isNotEmpty &&
        soDetails['quotationNumber'] != '0') {
      salesOrderReference = "With Quotation Reference";

      // Create and set the selected quotation number
      selectedQuotationNumber = QuotationNumber(
        select: false,
        customerCode: soDetails['customerCode'] ?? '',
        quotationID: soDetails['quotationId'] ?? 0,
        qtnNumber: soDetails['quotationNumber'] ?? '',
        quotationDate:
            soDetails['quotationDate'] != null &&
                    soDetails['quotationDate'] != '0001-01-01T00:00:00'
                ? DateTime.parse(soDetails['quotationDate'])
                : DateTime.now(),
        revisionNo: 0,
        revisionDate: null,
        quotationCurrency: 'INR',
        agentCode: '',
        inquiryNo: '',
        inquiryDate: null,
        salesmanCode: soDetails['salesmanCode'] ?? '',
        salesmanName: soDetails['salesmanName'] ?? '',
        consultantCode: '',
        consultantName: '',
        gstno: soDetails['gstNo'] ?? '',
        quotationYear: soDetails['quotationYear'] ?? '',
        quotationGroup: soDetails['quotationGroup'] ?? '',
        quotationNumber: soDetails['quotationNumber'] ?? '',
        quotationSiteCode: soDetails['quotationSiteCode'] ?? '',
        quotationSiteId: soDetails['quotationSiteId'] ?? 0,
      );

      // Add the selected quotation to the list if it's not already there
      if (!quotationNumbers.any(
        (q) => q.quotationID == selectedQuotationNumber!.quotationID,
      )) {
        quotationNumbers.add(selectedQuotationNumber!);
      }
    } else {
      salesOrderReference = "Without Quotation Reference";
      selectedQuotationNumber = null;
    }

    // Populate items
    items.clear();
    for (int i = 0; i < modelDetails.length; i++) {
      final model = modelDetails[i];

      // Find discount details for this item
      String discountType = "None";
      double? discountPercentage;
      double? discountAmount;
      String? discountCode;

      final discount = discountDetails.firstWhere(
        (d) => d['itemCode'] == model['salesItemCode'],
        orElse: () => {},
      );

      if (discount.isNotEmpty) {
        final discType = discount['discountType'] ?? 'None';
        discountCode = discount['discountCode'];

        if (discType != 'None' && discType != 'N') {
          if (discType == 'Percentage' || discType == 'P') {
            discountType = 'P';
            discountPercentage = (discount['discountValue'] ?? 0).toDouble();
            discountAmount =
                (model['basicPriceSUOM'] * model['qtySUOM']) *
                (discountPercentage! / 100);
          } else {
            discountType = 'V';
            discountAmount = (discount['discountValue'] ?? 0).toDouble();
            final basicAmount =
                (model['basicPriceSUOM'] ?? 0).toDouble() *
                (model['qtySUOM'] ?? 0).toDouble();
            discountPercentage =
                basicAmount > 0 ? (discountAmount! / basicAmount) * 100 : 0;
          }
        }
      }

      // Calculate tax amount for this item
      double taxAmount = 0.0;
      final itemRateStructures = rateStructureDetails.where(
        (rs) => rs['customerItemCode'] == model['salesItemCode'],
      );
      for (final rs in itemRateStructures) {
        taxAmount += (rs['rateAmount'] ?? 0).toDouble();
      }

      // Get rate structure rows for this item
      List<Map<String, dynamic>> rateStructureRows =
          itemRateStructures.map((e) => e as Map<String, dynamic>).toList();

      final basicRate = (model['basicPriceSUOM'] ?? 0).toDouble();
      final qty = (model['qtySUOM'] ?? 0).toDouble();
      final basicAmount = basicRate * qty;
      final discountedAmount = basicAmount - (discountAmount ?? 0);
      final totalAmount = discountedAmount + taxAmount;

      items.add(
        SalesOrderItem(
          itemName: model['salesItemDesc'] ?? '',
          itemCode: model['salesItemCode'] ?? '',
          qty: qty,
          basicRate: basicRate,
          uom: model['uom'] ?? 'NOS',
          discountType: discountType,
          discountPercentage: discountPercentage,
          discountAmount: discountAmount,
          discountCode: discountCode,
          rateStructure: model['rateStructureCode'] ?? '',
          taxAmount: taxAmount,
          totalAmount: totalAmount,
          rateStructureRows: rateStructureRows,
          lineNo: model['itemLineNo'] ?? (i + 1),
          hsnCode: model['hsnCode'] ?? '',
        ),
      );
    }

    setState(() {});
  }

  Future<void> _onOrderFromSelected(Customer customer) async {
    setState(() {
      selectedOrderFrom = customer;
      orderFromController.text = customer.customerName;
      billToController.text = customer.customerName;
      selectedBillTo = customer;
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

  // Updated to match add_so.dart structure
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

  // Updated to match add_so.dart structure
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
        "DisplayMaxRecords": 1000,
        "QuotationDetails": [
          {"QuotationId": quotationNumber.quotationID},
        ],
        "ItemDetails":
            selectedQuotationItems
                .map(
                  (item) => {
                    "SalesItemCode": item.salesItemCode,
                    "QuotationId": item.quotationId,
                    "itmLineNo": item.itemLineNo,
                  },
                )
                .toList(),
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
            discountCode = discountDetail['discountCode']; // Get discount code

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

        // Calculate tax amount from rate structure details
        double taxAmount = 0.0;
        if (quotationDetails.rateStructureDetails != null) {
          final rateStructDetails = quotationDetails.rateStructureDetails!
              .where(
                (rs) =>
                    rs['customerItemCode'] == detail['salesItemCode'] &&
                    rs['lineNo'] == detail['itemLineNo'],
              );
          for (final rsDetail in rateStructDetails) {
            taxAmount += (rsDetail['rateAmount'] ?? 0).toDouble();
          }
        }

        // Calculate total amount
        final basicRate = (detail['basicPriceSUOM'] ?? 0).toDouble();
        final qty = (detail['qtySUOM'] ?? 0).toDouble();
        final basicAmount = basicRate * qty;
        final discountedAmount = basicAmount - (discountAmount ?? 0);
        final totalAmount = discountedAmount + taxAmount;

        // Get rate structure rows for this item
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
        }

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
            discountCode: discountCode, // Add this
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

  Future<void> _showAddItemPage() async {
    final result = await Navigator.push<SalesOrderItem>(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddSalesOrderItemPage(
              service: _service,
              rateStructures: rateStructures,
              existingItems: items, // Pass existing items
              isDuplicateAllowed: _isDuplicateAllowed, // Pass duplicate flag
            ),
      ),
    );
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
        _newAttachments.addAll(result.files);
      });
    }
  }

  void _removeNewAttachment(int index) {
    setState(() {
      _newAttachments.removeAt(index);
    });
  }

  void _markAttachmentForDeletion(int index) {
    setState(() {
      _editableAttachments[index]['action'] = 'delete';
    });
  }

  void _undoAttachmentDeletion(int index) {
    setState(() {
      _editableAttachments[index]['action'] = 'none';
      _editableAttachments[index]['replacementFile'] = null;
    });
  }

  Future<void> _replaceAttachment(int index) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _editableAttachments[index]['replacementFile'] = result.files.first;
      });
    }
  }

  // Add attachment API helpers
  Future<bool> _deleteAttachment(Map<String, dynamic> attachment) async {
    final baseUrl = 'http://${await StorageUtils.readValue('url')}';
    final docYear = _financeDetails?['financialYear'] ?? "";

    return await _attachmentService.deleteAttachment(
      baseUrl: baseUrl,
      docYear: docYear,
      documentNo: _documentNo ?? '',
      formId: "06105",
      deletedFileList: [
        {"sysFileName": attachment['sysFileName'], "id": attachment['id']},
      ],
    );
  }

  Future<bool> _uploadNewAttachments() async {
    if (_newAttachments.isEmpty) return true;

    try {
      final companyDetails = await StorageUtils.readJson('selected_company');
      final locationDetails = await StorageUtils.readJson('selected_location');
      final companyId = companyDetails['id'];
      final companyCode = companyDetails['code'];
      final locationCode = locationDetails['code'];
      final locationId = locationDetails['id'];
      final docYear = _financeDetails?['financialYear'] ?? "";
      final userId = _service.tokenDetails['user']['id'] ?? 0;

      final filePaths =
          _newAttachments
              .map((f) => f.path!)
              .where((path) => path.isNotEmpty)
              .toList();
      if (filePaths.isEmpty) return true;

      return await _attachmentService.uploadAttachments(
        filePaths: filePaths,
        documentNo: _documentNo ?? '',
        documentId: originalOrderId,
        docYear: docYear,
        formId: "06105",
        locationCode: locationCode,
        companyCode: companyCode,
        locationId: locationId,
        companyId: companyId,
        userId: userId,
      );
    } catch (e) {
      debugPrint('Error uploading new attachments: $e');
      return false;
    }
  }

  Future<bool> _uploadSingleFile(PlatformFile file) async {
    if (file.path == null) return false;

    try {
      final companyDetails = await StorageUtils.readJson('selected_company');
      final locationDetails = await StorageUtils.readJson('selected_location');
      final companyId = companyDetails['id'];
      final companyCode = companyDetails['code'];
      final locationCode = locationDetails['code'];
      final locationId = locationDetails['id'];
      final docYear = _financeDetails?['financialYear'] ?? "";
      final userId = _service.tokenDetails['user']['id'] ?? 0;

      return await _attachmentService.uploadAttachments(
        filePaths: [file.path!],
        documentNo: _documentNo ?? '',
        documentId: originalOrderId,
        docYear: docYear,
        formId: "06105",
        locationCode: locationCode,
        companyCode: companyCode,
        locationId: locationId,
        companyId: companyId,
        userId: userId,
      );
    } catch (e) {
      debugPrint('Error uploading single file: $e');
      return false;
    }
  }

  Map<String, dynamic> _buildUpdatePayload() {
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
      modelDetail['orderId'] = int.parse(originalOrderId);

      // Add quotation reference if applicable - Updated field names
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
        discountDetail['orderId'] = int.parse(originalOrderId);
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
      "authorizationRequired": "Y",
      "autoNumberRequired": "N", // N for update
      "siteRequired": "Y",
      "authorizationDate": FormatUtils.formatDateForApi(
        selectedDate ?? DateTime.now(),
      ),
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
      "domesticCurrencyCode": "INR",
      "salesOrderDetails": {
        "orderId": int.parse(originalOrderId),
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
        "discountType": "V", //need to ask
        "discountAmount": _calculateTotalDiscount(),
        "exchangeRate": "1.0000",
        "OrderStatus": "O",
        "ioYear": widget.ioYear,
        "ioGroup": widget.ioGroup,
        "ioSiteId": locationId.toString(),
        "ioSiteCode": widget.ioSiteCode,
        "ioNumber": widget.ioNumber,
        "ioDate": FormatUtils.formatDateForApi(selectedDate!),
        "billToCode": selectedBillTo?.customerCode ?? "",
        "currencyCode":
            salesOrderReference == "With Quotation Reference" &&
                    selectedQuotationNumber != null
                ? selectedQuotationNumber!.quotationCurrency
                : "INR",
        "salesOrderType": "REG",
        "custType": "CU",
        "lcDetail": "F",
        "bgDetail": "F",
        "isAgentAssociated":
            salesOrderReference == "With Quotation Reference" &&
            selectedQuotationNumber != null &&
            selectedQuotationNumber!.agentCode.isNotEmpty,
        "custContactPersonId": "",
        "salesOrderRefNo": "",
        "buyerCode": 0,
        "soDeliveryDate": null,
        "bookCode": "",
        "agentCode":
            salesOrderReference == "With Quotation Reference" &&
                    selectedQuotationNumber != null
                ? selectedQuotationNumber!.agentCode
                : "",
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

  Future<void> _updateSalesOrder() async {
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
              'Location access is required to update the sales order',
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
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final payload = _buildUpdatePayload();
      final response = await _service.updateSalesOrder(payload);

      if (response['success'] == true) {
        bool locationSuccess = true;
        // Handle attachment operations
        bool attachmentSuccess = true;

        // Extract function ID for location submission
        String? functionId = originalOrderId;

        // Process existing attachments
        for (int i = 0; i < _editableAttachments.length; i++) {
          final attachment = _editableAttachments[i];

          if (attachment['action'] == 'delete') {
            final deleteSuccess = await _deleteAttachment(attachment);
            if (!deleteSuccess) attachmentSuccess = false;
          } else if (attachment['replacementFile'] != null) {
            // Delete old and upload new
            final deleteSuccess = await _deleteAttachment(attachment);
            if (deleteSuccess) {
              final uploadSuccess = await _uploadSingleFile(
                attachment['replacementFile'],
              );
              if (!uploadSuccess) attachmentSuccess = false;
            } else {
              attachmentSuccess = false;
            }
          }
        }

        // Upload new attachments
        final newAttachmentSuccess = await _uploadNewAttachments();
        if (!newAttachmentSuccess) attachmentSuccess = false;

        if (!attachmentSuccess) {
          _showError(
            "Sales Order updated, but some attachment operations failed!",
          );
        }

        Navigator.pop(context, true);
      } else {
        _showError(response['errorMessage'] ?? "Failed to update sales order");
      }
    } catch (e) {
      _showError("Error during update: ${e.toString()}");
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
      appBar: AppBar(
        title: Text("Edit Sales Order - ${widget.ioNumber}"),
        elevation: 1,
      ),
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
                      if (salesOrderReference ==
                          "With Quotation Reference") ...[
                        _buildQuotationNumberField(),
                        const SizedBox(height: 16),
                      ],
                      _buildDateField(),
                      const SizedBox(height: 16),
                      _buildCustomerPONumberField(),
                      const SizedBox(height: 16),
                      _buildCustomerPODateField(),
                      const SizedBox(height: 16),
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
                      if (salesOrderReference == "Without Quotation Reference")
                        _buildAddItemButton(),
                      if (items.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildTotalCard(),
                      ],
                      const SizedBox(height: 24),
                      _buildAttachmentSection(),
                      const SizedBox(height: 24),
                      _buildUpdateButton(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSalesOrderReferenceDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: "Sales Order Reference",
        border: OutlineInputBorder(),
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
          _submitting
              ? null
              : (val) {
                if (val != null) {
                  setState(() {
                    salesOrderReference = val;
                    // Clear quotation data when switching
                    if (val == "Without Quotation Reference") {
                      quotationNumbers.clear();
                      quotationItemDetails.clear();
                      selectedQuotationNumber = null;
                      quotationNumberController.clear();
                    } else if (selectedOrderFrom != null) {
                      _loadQuotationNumbers(selectedOrderFrom!.customerCode);
                    }
                  });
                }
              },
      validator:
          (val) => val == null ? "Sales Order Reference is required" : null,
    );
  }

  Widget _buildOrderFromField() {
    return TypeAheadField<Customer>(
      debounceDuration: const Duration(milliseconds: 400),
      controller: orderFromController,
      builder: (context, controller, focusNode) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: !_submitting,
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
      onSelected: _submitting ? null : _onOrderFromSelected,
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

  Widget _buildQuotationNumberField() {
    return DropdownButtonFormField<QuotationNumber>(
      decoration: const InputDecoration(
        labelText: "Quotation Number",
        border: OutlineInputBorder(),
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
      onChanged: null, // Disabled field
      validator:
          salesOrderReference == "With Quotation Reference"
              ? (val) => val == null ? "Quotation Number is required" : null
              : null,
    );
  }

  // Widget _buildDateField() {
  //   return TextFormField(
  //     controller: dateController,
  //     readOnly: true,
  //     enabled: !_submitting,
  //     decoration: const InputDecoration(
  //       labelText: "Date",
  //       border: OutlineInputBorder(),
  //       suffixIcon: Icon(Icons.calendar_today),
  //     ),
  //     onTap:
  //         _submitting
  //             ? null
  //             : () async {
  //               final picked = await showDatePicker(
  //                 context: context,
  //                 initialDate: selectedDate ?? DateTime.now(),
  //                 firstDate: startDate ?? DateTime(2000),
  //                 lastDate: endDate ?? DateTime.now(),
  //               );
  //               if (picked != null) {
  //                 setState(() {
  //                   selectedDate = picked;
  //                   dateController.text = FormatUtils.formatDateForUser(picked);
  //                 });
  //               }
  //             },
  //     validator:
  //         (val) => val == null || val.isEmpty ? "Date is required" : null,
  //   );
  // }
  Widget _buildDateField() {
    return TextFormField(
      controller: dateController,
      readOnly: true,
      enabled: !_submitting,
      decoration: const InputDecoration(
        labelText: "Date",
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.calendar_today),
      ),
      onTap:
          _submitting
              ? null
              : () async {
                final today = DateTime.now();
                final initialDate = selectedDate ?? today;

                // Calculate end date dynamically
                final periodEndDate =
                    _financeDetails != null
                        ? DateTime.parse(_financeDetails!['periodEDt'])
                        : today;
                final effectiveEndDate =
                    today.isBefore(periodEndDate) ||
                            today.isAtSameMomentAs(periodEndDate)
                        ? today
                        : periodEndDate;

                final picked = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: startDate ?? DateTime(2000),
                  lastDate: effectiveEndDate,
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
      readOnly: true,
      enabled: !_submitting,
      decoration: const InputDecoration(
        labelText: "Customer PO Date",
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.calendar_today),
      ),
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

  Widget _buildItemsList() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Items",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.itemName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Code: ${item.itemCode}"),
                    Text(
                      "Qty: ${item.qty} ${item.uom} | Rate: ₹${item.basicRate.toStringAsFixed(2)}",
                    ),
                    if (item.discountAmount != null && item.discountAmount! > 0)
                      Text(
                        "Discount: ${item.discountType} - ₹${item.discountAmount!.toStringAsFixed(2)}",
                      ),
                    Text(
                      "Tax: ₹${item.taxAmount?.toStringAsFixed(2) ?? '0.00'}",
                    ),
                    Text(
                      "Total: ₹${item.totalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                trailing:
                    salesOrderReference == "Without Quotation Reference"
                        ? IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed:
                              _submitting ? null : () => _removeItem(index),
                        )
                        : null,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddItemButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _submitting ? null : _showAddItemPage,
        icon: const Icon(Icons.add),
        label: const Text("Add Item"),
      ),
    );
  }

  Widget _buildTotalCard() {
    final totalBasic = _calculateTotalBasic();
    final totalDiscount = _calculateTotalDiscount();
    final totalTax = _calculateTotalTax();
    final totalAmount = _calculateTotalAmount();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Order Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Basic Amount:"),
                Text("₹${totalBasic.toStringAsFixed(2)}"),
              ],
            ),
            if (totalDiscount > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Discount:"),
                  Text("- ₹${totalDiscount.toStringAsFixed(2)}"),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Tax:"),
                Text("₹${totalTax.toStringAsFixed(2)}"),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Final Amount:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "₹${totalAmount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
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
        const Text(
          "Attachments",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Existing attachments
        if (_editableAttachments.isNotEmpty) ...[
          const Text(
            "Existing Attachments:",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _editableAttachments.length,
            itemBuilder: (context, index) {
              final attachment = _editableAttachments[index];
              final isMarkedForDeletion = attachment['action'] == 'delete';
              final hasReplacement = attachment['replacementFile'] != null;

              // Get the original filename with fallback options
              final originalFileName =
                  attachment['originalFileName'] ??
                  attachment['originalName'] ??
                  attachment['name'] ??
                  'Unknown file';

              return Card(
                color: isMarkedForDeletion ? Colors.red.shade50 : null,
                child: ListTile(
                  leading: Icon(
                    Icons.attach_file,
                    color: isMarkedForDeletion ? Colors.red : null,
                  ),
                  title: Text(
                    hasReplacement
                        ? attachment['replacementFile'].name
                        : originalFileName,
                    style: TextStyle(
                      decoration:
                          isMarkedForDeletion
                              ? TextDecoration.lineThrough
                              : null,
                      color: isMarkedForDeletion ? Colors.red : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasReplacement) Text("Replacing: $originalFileName"),
                      if (attachment['size'] != null)
                        Text(
                          "Size: ${(attachment['size'] / 1024).toStringAsFixed(1)} KB",
                        ),
                      if (attachment['createdByName'] != null)
                        Text("Uploaded by: ${attachment['createdByName']}"),
                      if (attachment['createdDate'] != null)
                        Text(
                          "Date: ${FormatUtils.formatDateForUser(DateTime.parse(attachment['createdDate']))}",
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isMarkedForDeletion && !hasReplacement) ...[
                        IconButton(
                          icon: const Icon(Icons.swap_horiz),
                          onPressed: () => _replaceAttachment(index),
                          tooltip: 'Replace',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _markAttachmentForDeletion(index),
                          tooltip: 'Delete',
                        ),
                      ] else ...[
                        IconButton(
                          icon: const Icon(Icons.undo),
                          onPressed: () => _undoAttachmentDeletion(index),
                          tooltip: 'Undo',
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],

        // New attachments
        if (_newAttachments.isNotEmpty) ...[
          const Text(
            "New Attachments:",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _newAttachments.length,
            itemBuilder: (context, index) {
              final file = _newAttachments[index];
              return Card(
                color: Colors.green.shade50,
                child: ListTile(
                  leading: const Icon(Icons.attach_file, color: Colors.green),
                  title: Text(file.name),
                  subtitle: Text("${(file.size / 1024).toStringAsFixed(1)} KB"),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => _removeNewAttachment(index),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],

        // Add attachment button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _submitting ? null : _pickFiles,
            icon: const Icon(Icons.attach_file),
            label: const Text("Add Attachments"),
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitting ? null : _updateSalesOrder,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child:
            _submitting
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Text(
                  "Update Sales Order",
                  style: TextStyle(fontSize: 16),
                ),
      ),
    );
  }
}
