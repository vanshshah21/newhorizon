import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:nhapp/pages/proforma_invoice/models/add_proforma_invoice.dart';
import 'package:nhapp/pages/proforma_invoice/models/proforma_details.dart';
import 'package:nhapp/pages/proforma_invoice/models/proforma_invoice_item.dart';
import 'package:nhapp/pages/proforma_invoice/pages/add_item_page.dart';
import 'package:nhapp/pages/proforma_invoice/service/edit_proforma.dart';
import 'package:nhapp/pages/proforma_invoice/service/add_proforma_invoice.dart'
    as AddProformaService; // Add alias
import 'package:nhapp/utils/format_utils.dart';
import 'package:nhapp/utils/location_utils.dart';
import '../../../utils/storage_utils.dart';

class EditProformaInvoiceForm extends StatefulWidget {
  final ProformaInvoice invoice;

  const EditProformaInvoiceForm({super.key, required this.invoice});

  @override
  State<EditProformaInvoiceForm> createState() =>
      _EditProformaInvoiceFormState();
}

class _EditProformaInvoiceFormState extends State<EditProformaInvoiceForm> {
  late EditProformaInvoiceService _service;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController dateController = TextEditingController();
  final TextEditingController customerController = TextEditingController();
  final TextEditingController quotationController = TextEditingController();
  final TextEditingController salesOrderController = TextEditingController();

  String? selectPreference;
  DateTime? selectedDate;
  Customer? selectedCustomer;
  String? selectedQuotationNumber;
  String? selectedQuotationSrNo;
  String? selectedSalesOrderNumber;
  String? selectedSalesOrderSrNo;
  DefaultDocumentDetail? defaultQuotation;
  DefaultDocumentDetail? defaultSalesOrder;
  List<QuotationNumber> quotationNumbers = [];
  List<SalesOrderNumber> salesOrderNumbers = [];
  List<ProformaItem> items = [];
  List<RateStructure> rateStructures = [];
  QuotationDetails? _quotationResponse;
  SalesOrderDetails? _salesOrderResponse;
  List<Map<String, dynamic>> _rsGrid = [];
  List<Map<String, dynamic>> _discountDetails = [];
  late DateTime startDate;
  late DateTime endDate;

  // Store original invoice details
  ProformaInvoiceDetails? _originalInvoiceDetails;

  final List<String> preferenceOptions = [
    "On Quotation",
    "On Sales Order",
    "On Other",
  ];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  Future<void> _initializeForm() async {
    try {
      _service = await EditProformaInvoiceService.create();
      await _loadFinancePeriod();
      await _loadRateStructures();
      await _loadInvoiceDetails();
    } catch (e) {
      _showError("Failed to initialize form: ${e.toString()}");
    }
  }

  Future<void> _loadInvoiceDetails() async {
    try {
      setState(() => _isLoading = true);

      _originalInvoiceDetails = await _service.fetchProformaInvoiceDetails(
        invSiteId: widget.invoice.siteId,
        invYear: widget.invoice.year,
        invGroup: widget.invoice.groupCode,
        invNumber: widget.invoice.number,
        piOn: widget.invoice.piOn,
        fromLocationId: widget.invoice.fromLocationId,
        custCode: widget.invoice.custCode,
      );

      await _populateFormFromInvoiceDetails();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("Failed to load invoice details: ${e.toString()}");
    }
  }

  Future<void> _populateFormFromInvoiceDetails() async {
    if (_originalInvoiceDetails == null) return;

    final headerDetail = _originalInvoiceDetails!.headerDetail;
    final salesOrderDetail = _originalInvoiceDetails!.salesOrderDetail;
    final gridDetail = _originalInvoiceDetails!.gridDetail;

    // Set date
    selectedDate = DateTime.parse(headerDetail['invIssueDate']);
    dateController.text = FormatUtils.formatDateForUser(selectedDate!);

    // Set customer
    selectedCustomer = Customer(
      totalRows: headerDetail['totalRows'] ?? 0,
      custCode: headerDetail['invCustCode'],
      custName: headerDetail['customerName'],
      cityCode: headerDetail['cityCode'] ?? '',
      cityName: headerDetail['cityName'] ?? '',
    );
    customerController.text = headerDetail['customerName'];

    switch (headerDetail['invOn']) {
      case 'Q':
        selectPreference = "On Quotation";
        // Load quotation data first, then set selected value
        defaultQuotation = await _service.fetchDefaultDocumentDetail("SQ");
        // await _loadQuotationNumbers(headerDetail['invCustCode']);
        // Set selected quotation after list is loaded
        final quotationFromSalesOrder = salesOrderDetail?['soNumber'];
        if (quotationFromSalesOrder != null) {
          selectedQuotationNumber = quotationFromSalesOrder;
          quotationController.text = quotationFromSalesOrder;
        }
        break;
      case 'O':
        selectPreference = "On Sales Order";
        // Load sales order data first, then set selected value
        defaultSalesOrder = await _service.fetchDefaultDocumentDetail("OB");
        // await _loadSalesOrderNumbers(headerDetail['invCustCode']);
        // Set selected sales order after list is loaded
        final salesOrderFromDetail = salesOrderDetail?['soNumber'];
        if (salesOrderFromDetail != null) {
          selectedSalesOrderNumber = salesOrderFromDetail;
          salesOrderController.text = salesOrderFromDetail;
        }
        break;
      default:
        selectPreference = "On Other";
    }

    // Populate items from gridDetail
    items = [];
    if (gridDetail['itemDetail'].isNotEmpty) {
      int lineNo = 1;
      for (final item in gridDetail['itemDetail']) {
        items.add(
          ProformaItem(
            itemName: item['itemName'],
            itemCode: item['itemCode'],
            qty: item['invoiceQty'] ?? item['maxInvoiceQty'] ?? item['qty'],
            basicRate: item['itemRate'],
            uom: item['suom'],
            discountType:
                item['invDiscountType'] == "N"
                    ? "None"
                    : item['discountAmount'] > 0
                    ? "Value"
                    : "None",
            discountAmount:
                item['discountAmount'] > 0 ? item['discountAmount'] : null,
            discountPercentage: null, // Calculate if needed
            rateStructure: item['rateStructureCode'],
            taxAmount: item['totalTax'],
            totalAmount: item['totalValue'],
            rateStructureRows: null, // Will be populated from rateStructDetail
            lineNo: lineNo,
            hsnAccCode: item['hsnAccCode'],
          ),
        );
        lineNo++;
      }
    }

    // Populate rate structure details
    _rsGrid = [];
    if (gridDetail['rateStructDetail'].isNotEmpty) {
      for (final rs in gridDetail['rateStructDetail']) {
        _rsGrid.add({
          "docType": "PI",
          "docSubType": "PI",
          "xdtdtmcd": rs['dtmCode'],
          "rateCode": rs['rateCode'],
          "rateStructCode": rs['rateStructureCode'],
          "rateAmount": double.tryParse(rs['rateAmount']) ?? 0.0,
          "amdSrNo": rs['srNo'],
          "perCValue": rs['taxValue'].toString(),
          "incExc": rs['incExc'],
          "perVal": rs['taxValue'],
          "appliedOn": rs['applicableOnCode'],
          "pnyn": rs['pNYN'],
          "seqNo": rs['seqNo'].toString(),
          "curCode": rs['curCode'],
          "fromLocationId": _service.locationDetails['id'] ?? 8,
          "TaxTyp": rs['taxType'],
          "refLine": rs['itmModelRefNo'],
        });
      }
    }

    // Populate discount details
    _discountDetails = [];
    if (gridDetail['discountDetail'].isNotEmpty) {
      for (final disc in gridDetail['discountDetail']) {
        _discountDetails.add({
          "itemCode": disc['discitem'],
          "currCode": disc['disccurr'].isNotEmpty ? disc['disccurr'] : "INR",
          "discCode": disc['disccode'],
          "discType": disc['disctype'],
          "discVal": disc['discvalue'],
          "fromLocationId": _service.locationDetails['id'] ?? 8,
          "oditmlineno": disc['itmModelRefNo'],
        });
      }
    }
  }

  Future<void> _loadFinancePeriod() async {
    try {
      final financeDetails = await StorageUtils.readJson('finance_period');
      if (financeDetails != null) {
        startDate = DateTime.parse(financeDetails['periodSDt']);
        endDate = DateTime.parse(financeDetails['periodEDt']);
      }
    } catch (e) {
      _setDefaultDate();
    }
  }

  void _setDefaultDate() {
    selectedDate = DateTime.now();
    dateController.text = FormatUtils.formatDateForUser(selectedDate!);
  }

  Future<void> _loadRateStructures() async {
    try {
      final companyId = _service.companyDetails['id'];
      rateStructures = await _service.fetchRateStructures(companyId);
    } catch (e) {
      _showError("Failed to load rate structures: ${e.toString()}");
    }
  }

  Future<void> _onPreferenceChanged(String? value) async {
    if (value == null) return;

    setState(() {
      selectPreference = value;
      customerController.clear();
      selectedCustomer = null;
      selectedQuotationNumber = null;
      selectedSalesOrderNumber = null;
      quotationNumbers.clear();
      salesOrderNumbers.clear();
      items.clear();
      _rsGrid.clear();
      _discountDetails.clear();
    });

    try {
      if (value == "On Quotation") {
        defaultQuotation = await _service.fetchDefaultDocumentDetail("SQ");
      } else if (value == "On Sales Order") {
        defaultSalesOrder = await _service.fetchDefaultDocumentDetail("OB");
      }
    } catch (e) {
      _showError("Failed to load document details: ${e.toString()}");
    }
  }

  Future<void> _onCustomerSelected(Customer customer) async {
    setState(() {
      selectedCustomer = customer;
      customerController.text = customer.custName;
      quotationNumbers.clear();
      salesOrderNumbers.clear();
      selectedQuotationNumber = null;
      selectedSalesOrderNumber = null;
      items.clear();
    });

    if (selectPreference == "On Quotation") {
      await _loadQuotationNumbers(customer.custCode);
    } else if (selectPreference == "On Sales Order") {
      await _loadSalesOrderNumbers(customer.custCode);
    }
  }

  Future<void> _loadQuotationNumbers(String customerCode) async {
    try {
      setState(() => _isLoading = true);
      quotationNumbers = await _service.fetchQuotationNumberList(customerCode);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("Failed to load quotation numbers: ${e.toString()}");
    }
  }

  Future<void> _loadSalesOrderNumbers(String customerCode) async {
    try {
      setState(() => _isLoading = true);
      salesOrderNumbers = await _service.fetchSalesOrderNumberList(
        customerCode,
      );
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("Failed to load sales order numbers: ${e.toString()}");
    }
  }

  Future<void> _onQuotationSelected(String? quotationNumber) async {
    if (quotationNumber == null) return;

    setState(() {
      selectedQuotationNumber = quotationNumber;
      items.clear();
      _rsGrid.clear();
      _discountDetails.clear();
      _isLoading = true;
    });

    try {
      final details = await _service.fetchQuotationDetails(quotationNumber);
      items = [];
      _rsGrid = [];
      _discountDetails = [];

      int lineNo = 1;
      for (final item in details.itemDetail) {
        final quantity =
            (item['qty'] ?? 0).toDouble() == 0.0
                ? (item['maxInvoiceQty'] ?? 0).toDouble()
                : (item['qty'] ?? 0).toDouble();

        items.add(
          ProformaItem(
            itemName: item['itemName'] ?? '',
            itemCode: item['itemCode'] ?? '',
            qty: quantity,
            basicRate: (item['itemRate'] ?? 0).toDouble(),
            uom: item['suom'] ?? 'NOS',
            discountType: (item['discountAmount'] ?? 0) > 0 ? 'Value' : 'None',
            discountAmount: (item['discountAmount'] ?? 0).toDouble(),
            discountPercentage: null,
            rateStructure: item['rateStructureCode'] ?? '',
            taxAmount: (item['totalTax'] ?? 0).toDouble(),
            totalAmount: (item['totalValue'] ?? 0).toDouble(),
            rateStructureRows: null,
            lineNo: lineNo,
            hsnAccCode: item['hsnAccCode'] ?? '',
          ),
        );
        lineNo++;
      }

      // Populate rsGrid from response
      if (details.rateStructDetail != null) {
        for (final rs in details.rateStructDetail!) {
          _rsGrid.add({
            "docType": "PI",
            "docSubType": "PI",
            "xdtdtmcd": rs['dtmCode'] ?? '',
            "rateCode": rs['rateCode'] ?? '',
            "rateStructCode": rs['rateStructureCode'] ?? '',
            "rateAmount":
                double.tryParse(rs['rateAmount']?.toString() ?? '0') ?? 0.0,
            "amdSrNo": rs['srNo'] ?? 0,
            "perCValue": rs['taxValue']?.toString() ?? "0.00",
            "incExc": rs['incExc'] ?? '',
            "perVal": rs['taxValue'] ?? 0,
            "appliedOn": rs['applicableOnCode'] ?? "",
            "pnyn": rs['pNYN'] ?? false,
            "seqNo": rs['seqNo']?.toString() ?? "1",
            "curCode": rs['curCode'] ?? "INR",
            "fromLocationId": _service.locationDetails['id'] ?? 8,
            "TaxTyp": rs['taxType'] ?? '',
            "refLine": rs['itmModelRefNo'] ?? 0,
          });
        }
      }

      // Populate discountDetail from response
      if (details.discountDetail != null) {
        for (final disc in details.discountDetail!) {
          _discountDetails.add({
            "itemCode": disc['discitem'] ?? '',
            "currCode": disc['disccurr'] ?? "INR",
            "discCode": disc['disccode'] ?? "01",
            "discType": disc['disctype'] ?? '',
            "discVal": disc['discvalue'] ?? 0,
            "fromLocationId": _service.locationDetails['id'] ?? 8,
            "oditmlineno": disc['itmModelRefNo'] ?? 0,
          });
        }
      }

      _quotationResponse = details;
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("Failed to load quotation details: ${e.toString()}");
    }
  }

  Future<void> _onSalesOrderSelected(String? salesOrderNumber) async {
    if (salesOrderNumber == null) return;

    setState(() {
      selectedSalesOrderNumber = salesOrderNumber;
      items.clear();
      _rsGrid.clear();
      _discountDetails.clear();
      _isLoading = true;
    });

    try {
      final details = await _service.fetchSalesOrderDetails(salesOrderNumber);
      items = [];
      _rsGrid = [];
      _discountDetails = [];

      int lineNo = 1;
      for (final item in details.itemDetail) {
        final quantity =
            (item['qty'] ?? 0).toDouble() == 0.0
                ? (item['maxInvoiceQty'] ?? 0).toDouble()
                : (item['qty'] ?? 0).toDouble();

        items.add(
          ProformaItem(
            itemName: item['itemName'] ?? '',
            itemCode: item['itemCode'] ?? '',
            qty: quantity,
            basicRate: (item['itemRate'] ?? 0).toDouble(),
            uom: item['suom'] ?? 'NOS',
            discountType: (item['discountAmount'] ?? 0) > 0 ? 'Value' : 'None',
            discountAmount: (item['discountAmount'] ?? 0).toDouble(),
            discountPercentage: null,
            rateStructure: item['rateStructureCode'] ?? '',
            taxAmount: (item['totalTax'] ?? 0).toDouble(),
            totalAmount: (item['totalValue'] ?? 0).toDouble(),
            rateStructureRows: null,
            lineNo: lineNo,
            hsnAccCode: item['hsnAccCode'] ?? '',
          ),
        );
        lineNo++;
      }

      // Populate rsGrid from response
      if (details.rateStructDetail != null) {
        for (final rs in details.rateStructDetail!) {
          _rsGrid.add({
            "docType": "PI",
            "docSubType": "PI",
            "xdtdtmcd": rs['xdtdtmcd'] ?? '',
            "rateCode": rs['rateCode'] ?? '',
            "rateStructCode": rs['rateStructCode'] ?? '',
            "rateAmount": rs['rateAmount'] ?? 0,
            "amdSrNo": rs['amdSrNo'] ?? 0,
            "perCValue": rs['perCValue']?.toString() ?? "0.00",
            "incExc": rs['incExc'] ?? '',
            "perVal": rs['perVal'] ?? 0,
            "appliedOn": rs['appliedOn'] ?? "",
            "pnyn": rs['pnyn'] ?? false,
            "seqNo": rs['seqNo']?.toString() ?? "1",
            "curCode": rs['curCode'] ?? "INR",
            "fromLocationId": _service.locationDetails['id'] ?? 8,
            "TaxTyp": rs['TaxTyp'] ?? '',
            "refLine": rs['refLine'] ?? 0,
          });
        }
      }

      // Populate discountDetail from response
      if (details.discountDetail != null) {
        for (final disc in details.discountDetail!) {
          _discountDetails.add({
            "itemCode": disc['itemCode'] ?? '',
            "currCode": disc['currCode'] ?? "INR",
            "discCode": disc['discCode'] ?? "01",
            "discType": disc['discType'] ?? '',
            "discVal": disc['discVal'] ?? 0,
            "fromLocationId": _service.locationDetails['id'],
            "oditmlineno": disc['oditmlineno'] ?? 0,
          });
        }
      }

      _salesOrderResponse = details;
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("Failed to load sales order details: ${e.toString()}");
    }
  }

  Future<void> _showAddItemPage() async {
    // Create the correct ProformaInvoiceService instance for AddItemPage
    final addProformaService =
        await AddProformaService.ProformaInvoiceService.create();

    final result = await Navigator.push<ProformaItem>(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddItemPage(
              service: addProformaService, // Use the correct service type
              rateStructures: rateStructures,
            ),
      ),
    );

    // if (result != null) {
    //   setState(() {
    //     result.lineNo = items.length + 1;
    //     items.add(result);
    //   });
    // }
    if (result != null) {
      setState(() {
        // Set proper line number
        result.lineNo = items.length + 1;
        items.add(result);

        // Append rate structure details if they exist (don't replace)
        if (result.rateStructureRows != null &&
            result.rateStructureRows!.isNotEmpty) {
          final lineNo = result.lineNo;

          // Add rate structure rows for this item
          for (final row in result.rateStructureRows!) {
            _rsGrid.add({
              "docType": "PI",
              "docSubType": "PI",
              "xdtdtmcd": result.itemCode,
              "rateCode": row['msprtcd'],
              "rateStructCode": result.rateStructure,
              "rateAmount": row['rateAmount'] ?? 0,
              "amdSrNo": 0,
              "perCValue": row['msprtval']?.toString() ?? "0.00",
              "incExc": row['mspincexc'],
              "perVal": row['mspperval'],
              "appliedOn": row['mtrslvlno'] ?? "",
              "pnyn": row['msppnyn'] == "True" || row['msppnyn'] == true,
              "seqNo": row['mspseqno']?.toString() ?? "1",
              "curCode": row['mprcurcode'] ?? "INR",
              "fromLocationId": _service.locationDetails['id'] ?? 8,
              "TaxTyp": row['mprtaxtyp'],
              "refLine": lineNo,
            });
          }
        }

        // Append discount details if they exist
        if (result.discountAmount != null && result.discountAmount! > 0) {
          _discountDetails.add({
            "itemCode": result.itemCode,
            "currCode": "INR",
            // "discCode": result.discountCode,
            "discType": result.discountType,
            "discVal":
                result.discountType == "Percentage"
                    ? result.discountPercentage ?? 0
                    : result.discountAmount ?? 0,
            "fromLocationId": _service.locationDetails['id'] ?? 8,
            "oditmlineno": result.lineNo,
          });
        }
      });
    }
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

  double _calculateTaxFromRateStructure() {
    if (selectPreference == "On Quotation" ||
        selectPreference == "On Sales Order") {
      double totalTax = 0.0;
      for (final rs in _rsGrid) {
        final rateAmount = rs['rateAmount'];
        if (rateAmount != null) {
          if (rateAmount is String) {
            totalTax += double.tryParse(rateAmount) ?? 0.0;
          } else if (rateAmount is num) {
            totalTax += rateAmount.toDouble();
          }
        }
      }
      return totalTax;
    } else {
      return _calculateTotalTax();
    }
  }

  Map<String, dynamic> _buildSubmissionPayload() {
    final userDetails = _service.userDetails;
    final locationDetails = _service.locationDetails;
    final financeDetails = _service.financeDetails;

    if (userDetails?['id'] == null) throw Exception("User ID is null");
    if (locationDetails['id'] == null) throw Exception("Location ID is null");
    if (locationDetails['code'] == null)
      throw Exception("Location code is null");
    if (selectedCustomer == null) throw Exception("Customer is null");

    List<Map<String, dynamic>> itemDetails = [];
    List<Map<String, dynamic>> rsGrid = [];
    List<Map<String, dynamic>> discountDetails = [];

    final userId = userDetails!['id'] ?? 0;
    final locationId = locationDetails['id'] ?? 0;
    final locationCode = locationDetails['code'] ?? "";

    final totalBasic = _calculateTotalBasic();
    final totalDiscount = _calculateTotalDiscount();
    final totalTax = _calculateTaxFromRateStructure();
    final totalAmount = _calculateTotalAmount();

    // Build item details
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final lineNo = i + 1;

      final itemJson = item.toSubmissionJson(userId, locationId);
      itemJson['lineNo'] = lineNo;
      itemJson['seqNo'] = lineNo;
      itemJson['fromLocationId'] = locationId;
      if (selectPreference == "On Quotation") {
        itemJson['ordYear'] = financeDetails['financialYear'];
        itemJson['ordGroup'] = defaultQuotation!.groupCode;
        itemJson['ordNumber'] = selectedQuotationNumber;
      } else if (selectPreference == "On Sales Order") {
        itemJson['ordYear'] = financeDetails['financialYear'];
        itemJson['ordGroup'] = defaultSalesOrder!.groupCode;
        itemJson['ordNumber'] = selectedSalesOrderNumber;
      }
      itemDetails.add(itemJson);
    }

    // Handle rsGrid and discountDetails based on preference
    if (selectPreference == "On Quotation" ||
        selectPreference == "On Sales Order") {
      rsGrid =
          _rsGrid.map((rs) {
            final itemIndex = items.indexWhere(
              (item) => item.itemCode == rs['xdtdtmcd'],
            );
            if (itemIndex != -1) {
              rs['refLine'] = itemIndex + 1;
            }
            return Map<String, dynamic>.from(rs);
          }).toList();

      discountDetails =
          _discountDetails.map((disc) {
            final itemIndex = items.indexWhere(
              (item) => item.itemCode == disc['itemCode'],
            );
            if (itemIndex != -1) {
              disc['oditmlineno'] = itemIndex + 1;
            }
            return Map<String, dynamic>.from(disc);
          }).toList();
    } else {
      // For "On Other" - build rsGrid and discountDetails from item data
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        final lineNo = i + 1;

        if (item.rateStructureRows != null) {
          for (final row in item.rateStructureRows!) {
            rsGrid.add({
              "docType": "PI",
              "docSubType": "PI",
              "xdtdtmcd": item.itemCode,
              "rateCode": row['msprtcd'],
              "rateStructCode": item.rateStructure,
              "rateAmount": row['rateAmount'] ?? 0,
              "amdSrNo": 0,
              "perCValue": row['msprtval']?.toString() ?? "0.00",
              "incExc": row['mspincexc'],
              "perVal": row['mspperval'],
              "appliedOn": row['mtrslvlno'] ?? "",
              "pnyn": row['msppnyn'] == "True" || row['msppnyn'] == true,
              "seqNo": row['mspseqno']?.toString() ?? "1",
              "curCode": row['mprcurcode'] ?? "INR",
              "fromLocationId": locationId,
              "TaxTyp": row['mprtaxtyp'],
              "refLine": lineNo,
            });
          }
        }

        if (item.discountAmount != null && item.discountAmount! > 0) {
          discountDetails.add({
            "itemCode": item.itemCode,
            "currCode": "INR",
            "discCode": "DISC",
            "discType": item.discountType,
            "discVal":
                item.discountType == "Percentage"
                    ? item.discountPercentage ?? 0
                    : item.discountAmount ?? 0,
            "fromLocationId": locationId,
            "oditmlineno": lineNo,
          });
        }
      }
    }

    final itemHeaderDetial = _buildItemHeaderDetail(
      totalAmount,
      totalTax,
      totalDiscount,
      userId,
      locationId,
      locationCode,
    );

    final transportDetail = _buildTransportDetail(userId);

    return {
      "action": "update", // Changed from "add" to "update"
      "ExchangeRate": 1.0,
      "autoNoRequired": "N", // Changed from "Y" to "N" for edit
      "customerPoNumber": null,
      "customerPoDate": null,
      "itemHeaderDetial": itemHeaderDetial,
      "itemDetail": itemDetails,
      "rsGrid": rsGrid,
      "discountDetail": discountDetails,
      "standardTerms": [],
      "transportDetail": transportDetail,
      "chargesDetail": [],
      "remark": [],
    };
  }

  Map<String, dynamic> _buildItemHeaderDetail(
    double totalAmount,
    double totalTax,
    double totalDiscount,
    int userId,
    int locationId,
    String locationCode,
  ) {
    final financeDetails = _service.financeDetails;
    final financialYear = financeDetails['financialYear'] ?? "25-26";

    String discountType = "None";
    if (items.isNotEmpty) {
      final firstItemDiscountType = items.first.discountType;
      final allSameDiscountType = items.every(
        (item) => item.discountType == firstItemDiscountType,
      );
      discountType = allSameDiscountType ? firstItemDiscountType : "Mixed";
    }

    final basicAmount = _calculateTotalBasic();
    final netAmount = basicAmount - totalDiscount;
    final finalAmount = netAmount + totalTax;

    return {
      "autoId": widget.invoice.id, // Use original autoId for update
      "invYear": financialYear,
      "invGroup": "PI",
      "invSite": locationId,
      "invSiteCode": locationCode,
      "invIssueDate":
          selectedDate != null
              ? "${selectedDate!.year.toString().padLeft(4, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}"
              : "",
      "invValue": netAmount.toStringAsFixed(2),
      "invAmount": finalAmount.toStringAsFixed(2),
      "invRoValue": finalAmount.round(),
      "invTax": totalTax.toStringAsFixed(2),
      "invType": "M",
      "invCustCode": selectedCustomer!.custCode,
      "invStatus": "O",
      "invOn":
          selectPreference == "On Quotation"
              ? "Q"
              : selectPreference == "On Sales Order"
              ? "O"
              : "T",
      "invDiscountType": discountType,
      "invDiscountValue": totalDiscount.toStringAsFixed(2),
      "invFromLocationId": locationId,
      "invCreatedUserId": userId,
      "invCurrCode": "INR",
      "invRate": 0,
      "invNumber": widget.invoice.number, // Use original invoice number
      "invBacAmount": basicAmount.toStringAsFixed(2),
      "invSiteReq": "Y",
    };
  }

  Map<String, dynamic> _buildTransportDetail(int userId) {
    // Use original transport details if available
    final originalTransport = _originalInvoiceDetails?.transPortDetail;

    return {
      "refId": originalTransport?['refId'] ?? 0,
      "shipVIa": originalTransport?['shipVIa'] ?? "",
      "portLoad": originalTransport?['portLoad'] ?? "",
      "portDischarg": originalTransport?['portDischarg'] ?? "",
      "kindAttention": originalTransport?['kindAttention'] ?? "",
      "attencontactno": originalTransport?['attencontactno'] ?? "",
      "finDestination": originalTransport?['finDestination'] ?? "",
      "shippingMark": originalTransport?['shippingMark'] ?? "",
      "bookCode": originalTransport?['bookCode'] ?? "",
      "createdBy": userId,
    };
  }

  // Future<void> _submitProformaInvoice() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   if (!_validateForm()) return;

  //   final confirmed = await _showConfirmationDialog();
  //   if (!confirmed) return;

  //   try {
  //     setState(() => _isLoading = true);

  //     final payload = _buildSubmissionPayload();
  //     final success = await _service.updateProformaInvoice(payload);

  //     setState(() => _isLoading = false);

  //     if (success) {
  //       _showSuccess("Proforma Invoice updated successfully");
  //       Navigator.pop(context, true);
  //     } else {
  //       _showError("Failed to update Proforma Invoice");
  //     }
  //   } catch (e, st) {
  //     setState(() => _isLoading = false);
  //     debugPrint("Error stacktrace during update: $st");
  //     _showError("Error during update: ${e.toString()}");
  //   }
  // }
  Future<void> _submitProformaInvoice() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_validateForm()) return;

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
              'Location access is required to update the proforma invoice',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Step 2: Get current location
    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;

    setState(() => _isLoading = true);

    final position = await LocationUtils.instance.getCurrentLocation();
    if (position == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to get current location. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final payload = _buildSubmissionPayload();
      final updatedProformaNumber = await _service.updateProformaInvoice(
        payload,
      );

      if (updatedProformaNumber != "0") {
        // Step 3: Submit location with proper error handling
        bool locationSuccess = true;
        List<String> errorMessages = [];

        // Use the original proforma invoice number for location submission
        String proformaInvoiceNumber = widget.invoice.number;

        // Submit location using the proforma invoice number
        try {
          locationSuccess = await _service.submitLocation(
            functionId: proformaInvoiceNumber,
            longitude: position.longitude,
            latitude: position.latitude,
          );

          if (!locationSuccess) {
            errorMessages.add('Location update failed');
          }
        } catch (e) {
          debugPrint('Location submission error: $e');
          locationSuccess = false;
          errorMessages.add('Location update failed: $e');
        }

        if (!mounted) return;
        setState(() => _isLoading = false);

        // Show appropriate success/error messages
        if (locationSuccess) {
          _showSuccess("Proforma Invoice updated successfully with location!");
        } else {
          String errorMessage = 'Proforma Invoice updated, but ';
          if (errorMessages.isNotEmpty) {
            errorMessage += errorMessages.join(', ');
          } else {
            errorMessage += 'location update failed';
          }
          _showError(errorMessage);
        }

        // Show detailed error dialog if there are specific errors
        if (errorMessages.isNotEmpty) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Update Status'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Proforma Invoice updated successfully, but some operations failed:',
                      ),
                      const SizedBox(height: 8),
                      ...errorMessages.map(
                        (error) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            '• $error',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
          );
        }

        Navigator.pop(context, true);
      } else {
        setState(() => _isLoading = false);
        _showError("Failed to update Proforma Invoice");
      }
    } catch (e, st) {
      setState(() => _isLoading = false);
      debugPrint("Error stacktrace during update: $st");
      _showError("Error during update: ${e.toString()}");
    }
  }

  bool _validateForm() {
    if (selectPreference == null) {
      _showError("Please select a preference");
      return false;
    }

    if (selectedDate == null) {
      _showError("Please select a date");
      return false;
    }

    if (selectedCustomer == null) {
      _showError("Please select a customer");
      return false;
    }

    if (selectPreference == "On Quotation" && selectedQuotationNumber == null) {
      _showError("Please select a quotation number");
      return false;
    }

    if (selectPreference == "On Sales Order" &&
        selectedSalesOrderNumber == null) {
      _showError("Please select a sales order number");
      return false;
    }

    if (items.isEmpty) {
      _showError("Please add at least one item");
      return false;
    }

    return true;
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Confirm Update"),
                content: const Text(
                  "Are you sure you want to update this Proforma Invoice?",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Update"),
                  ),
                ],
              ),
        ) ??
        false;
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Proforma Invoice - ${widget.invoice.number}"),
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
                      _buildPreferenceDropdown(),
                      const SizedBox(height: 16),
                      _buildDateField(),
                      const SizedBox(height: 16),
                      _buildCustomerField(),
                      const SizedBox(height: 16),
                      if (selectPreference == "On Quotation") ...[
                        _buildQuotationDropdown(),
                        const SizedBox(height: 16),
                      ],
                      if (selectPreference == "On Sales Order") ...[
                        _buildSalesOrderDropdown(),
                        const SizedBox(height: 16),
                      ],
                      if (items.isNotEmpty) ...[
                        _buildItemsList(),
                        const SizedBox(height: 16),
                      ],
                      if (selectPreference == "On Other") ...[
                        _buildAddItemButton(),
                        const SizedBox(height: 16),
                      ],
                      if (items.isNotEmpty) ...[
                        _buildTotalCard(),
                        const SizedBox(height: 24),
                      ],
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildPreferenceDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: "Select Preference",
        border: OutlineInputBorder(),
      ),
      value: selectPreference,
      items:
          preferenceOptions
              .map(
                (pref) => DropdownMenuItem<String>(
                  value: pref,
                  child: Text(pref, style: TextStyle(color: Colors.black)),
                ),
              )
              .toList(),
      // onChanged: _onPreferenceChanged,
      onChanged: null,
      validator: (val) => val == null ? "Select Preference is required" : null,
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
      // onTap: () async {
      //   final picked = await showDatePicker(
      //     context: context,
      //     initialDate: selectedDate ?? DateTime.now(),
      //     firstDate: startDate,
      //     lastDate: DateTime.now(),
      //   );
      //   if (picked != null) {
      //     setState(() {
      //       selectedDate = picked;
      //       dateController.text = FormatUtils.formatDateForUser(picked);
      //     });
      //   }
      // },
      validator:
          (val) => val == null || val.isEmpty ? "Date is required" : null,
    );
  }

  Widget _buildCustomerField() {
    return TypeAheadField<Customer>(
      showOnFocus: false,
      debounceDuration: const Duration(milliseconds: 400),
      controller: customerController,
      builder: (context, controller, focusNode) {
        return TextFormField(
          readOnly: true,
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: "Customer Name",
            border: OutlineInputBorder(),
          ),
          validator:
              (val) =>
                  val == null || val.isEmpty
                      ? "Customer Name is required"
                      : null,
        );
      },
      // suggestionsCallback: (pattern) async {
      //   if (pattern.length < 4) return [];
      //   try {
      //     return await _service.fetchCustomerSuggestions(pattern);
      //   } catch (e) {
      //     return [];
      //   }
      // },
      suggestionsCallback: (pattern) async {
        return [];
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion.custName),
          subtitle: Text(suggestion.custCode),
        );
      },
      onSelected: _onCustomerSelected,
    );
  }

  // Widget _buildQuotationDropdown() {
  //   return DropdownButtonFormField<String>(
  //     decoration: const InputDecoration(
  //       labelText: "Quotation Number",
  //       border: OutlineInputBorder(),
  //     ),
  //     value: selectedQuotationNumber,
  //     items:
  //         quotationNumbers
  //             .map(
  //               (qn) => DropdownMenuItem<String>(
  //                 value: qn.number,
  //                 child: Text(qn.number),
  //               ),
  //             )
  //             .toList(),
  //     onChanged: _onQuotationSelected,
  //     validator: (val) => val == null ? "Quotation Number is required" : null,
  //   );
  // }
  Widget _buildQuotationDropdown() {
    return TextFormField(
      controller: quotationController,
      decoration: const InputDecoration(
        labelText: "Quotation Number",
        border: OutlineInputBorder(),
      ),
      readOnly: true,
      validator:
          (val) =>
              val == null || val.isEmpty
                  ? "Quotation Number is required"
                  : null,
    );
  }

  // Widget _buildSalesOrderDropdown() {
  //   return DropdownButtonFormField<String>(
  //     decoration: const InputDecoration(
  //       labelText: "Sales Order Number",
  //       border: OutlineInputBorder(),
  //     ),
  //     value: selectedSalesOrderNumber,
  //     items:
  //         salesOrderNumbers
  //             .map(
  //               (so) => DropdownMenuItem<String>(
  //                 value: so.number,
  //                 child: Text(so.number),
  //               ),
  //             )
  //             .toList(),
  //     onChanged: _onSalesOrderSelected,
  //     validator: (val) => val == null ? "Sales Order Number is required" : null,
  //   );
  // }
  Widget _buildSalesOrderDropdown() {
    return TextFormField(
      controller: salesOrderController,
      decoration: const InputDecoration(
        labelText: "Sales Order Number",
        border: OutlineInputBorder(),
      ),
      readOnly: true,
      validator:
          (val) =>
              val == null || val.isEmpty
                  ? "Sales Order Number is required"
                  : null,
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
                  "Code: ${item.itemCode}\n"
                  "Qty: ${item.qty.toStringAsFixed(2)} ${item.uom}\n"
                  "Rate: ₹${item.basicRate.toStringAsFixed(2)}\n"
                  "Basic Amount: ₹${(item.basicRate * item.qty).toStringAsFixed(2)}\n"
                  "Discount: ₹${(item.discountAmount ?? 0.0).toStringAsFixed(2)}\n"
                  "Tax: ₹${(item.taxAmount ?? 0.0).toStringAsFixed(2)}\n"
                  "Total: ₹${item.totalAmount.toStringAsFixed(2)}",
                ),
                isThreeLine: true,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAddItemButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showAddItemPage,
        icon: const Icon(Icons.add),
        label: const Text("Add New Item"),
      ),
    );
  }

  Widget _buildTotalCard() {
    final totalBasic = _calculateTotalBasic();
    final totalDiscount = _calculateTotalDiscount();
    final totalTax = _calculateTaxFromRateStructure();
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
                const Text("Net Amount:"),
                Text("₹${netAmount.toStringAsFixed(2)}"),
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitProformaInvoice,
        child: const Text("Update Proforma Invoice"),
      ),
    );
  }

  @override
  void dispose() {
    dateController.dispose();
    customerController.dispose();
    quotationController.dispose();
    salesOrderController.dispose();
    super.dispose();
  }
}
