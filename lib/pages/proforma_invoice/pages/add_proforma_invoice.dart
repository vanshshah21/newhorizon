import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:nhapp/pages/proforma_invoice/models/add_proforma_invoice.dart';
import 'package:nhapp/pages/proforma_invoice/pages/add_item_page.dart';
import 'package:nhapp/pages/proforma_invoice/service/add_proforma_invoice.dart';
import 'package:nhapp/utils/format_utils.dart';
import 'package:nhapp/utils/location_utils.dart';
import '../../../utils/storage_utils.dart';

class AddProformaInvoiceForm extends StatefulWidget {
  final Map<String, dynamic>? quotationData;
  final Map<String, dynamic>? quotationListItem;
  final Map<String, dynamic>? salesOrderData;
  final Map<String, dynamic>? salesOrderItem;
  const AddProformaInvoiceForm({
    super.key,
    this.quotationData,
    this.quotationListItem,
    this.salesOrderData,
    this.salesOrderItem,
  });

  @override
  State<AddProformaInvoiceForm> createState() => _AddProformaInvoiceFormState();
}

class _AddProformaInvoiceFormState extends State<AddProformaInvoiceForm> {
  late ProformaInvoiceService _service;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController dateController = TextEditingController();
  final TextEditingController customerController = TextEditingController();

  String? selectPreference;
  DateTime? selectedDate;
  Customer? selectedCustomer;
  String? selectedQuotationNumber;
  String? selectedQuotationSrNo;
  String? selectedSalesOrderNumber;
  String? selectedSalesOrderSrNo;
  late Map<String, dynamic> DefaultQuotation;
  late Map<String, dynamic> DefaultSalesOrder;
  late Map<String, dynamic> DefaultProformaInvoice;
  List<QuotationNumber> quotationNumbers = [];
  List<SalesOrderNumber> salesOrderNumbers = [];
  List<ProformaItem> items = [];
  List<RateStructure> rateStructures = [];
  late Map<String, dynamic>? companyDetails;
  late Map<String, dynamic>? locationDetails;
  late Map<String, dynamic>? userDetails;
  late Map<String, dynamic>? _financeDetails;
  QuotationDetails? _quotationResponse;
  SalesOrderDetails? _salesOrderResponse;
  List<Map<String, dynamic>> _rsGrid = [];
  List<Map<String, dynamic>> _discountDetails = [];
  late DateTime startDate;
  late DateTime endDate;
  late final String currency;

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
    _service = await ProformaInvoiceService.create();
    await _loadFinancePeriod();
    await _loadRateStructures();
    loadProformaInvoiceDefaults();
    final curObj = await StorageUtils.readJson('domestic_currency');
    currency = curObj?['domCurCode'] ?? 'INR';
    companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) {
      _showError("Company details not found.");
      return;
    }
    locationDetails = await StorageUtils.readJson('selected_location');
    debugPrint("Location Details: $locationDetails");
    if (locationDetails == null) {
      _showError("Location details not found.");
      return;
    }
    final tokenDetails = await StorageUtils.readJson('session_token');
    userDetails = tokenDetails?['user'];
    if (userDetails == null) {
      _showError("User details not found.");
      return;
    }

    // Prefill data if coming from quotation
    if (widget.quotationData != null && widget.quotationListItem != null) {
      await _prefillFromQuotation();
    }

    if (widget.salesOrderData != null && widget.salesOrderItem != null) {
      await _prefillFromSalesOrder();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadFinancePeriod() async {
    try {
      _financeDetails = await StorageUtils.readJson('finance_period');
      if (_financeDetails != null) {
        startDate = DateTime.parse(_financeDetails!['periodSDt']);
        endDate = DateTime.parse(_financeDetails!['periodEDt']);
        final now = DateTime.now();

        selectedDate = now.isAfter(endDate) ? endDate : now;
        dateController.text = FormatUtils.formatDateForUser(selectedDate!);
      }
    } catch (e) {
      _setDefaultDate();
    }
  }

  void _setDefaultDate() {
    selectedDate = DateTime.now();
    dateController.text = FormatUtils.formatDateForUser(selectedDate!);
  }

  void loadProformaInvoiceDefaults() async {
    DefaultProformaInvoice = await _service.fetchDefaultDocumentDetail("PI");
  }

  Future<void> _prefillFromQuotation() async {
    final quotationData = widget.quotationData!;
    final quotationItem = widget.quotationListItem!;

    try {
      // Set preference to "On Quotation"
      setState(() {
        selectPreference = "On Quotation";
      });

      // Load quotation defaults
      DefaultQuotation = await _service.fetchDefaultDocumentDetail("SQ");

      // Extract quotation details
      final quotationDetails =
          quotationData['quotationDetails'] as Map<String, dynamic>;

      // Create customer data from quotation
      final customerCode = quotationDetails['customerCode']?.toString() ?? '';
      final customerName = quotationDetails['customerName']?.toString() ?? '';

      if (customerCode.isNotEmpty && customerName.isNotEmpty) {
        // Create customer object
        final customer = Customer(
          custCode: customerCode,
          custName: customerName,
          cityCode: "",
          cityName: "",
          totalRows: 0,
        );

        // Set customer and trigger related loading
        await _onCustomerSelected(customer);

        // Find and select the quotation from the loaded list
        final qtnNumber = quotationItem['qtnNumber']?.toString() ?? '';
        if (qtnNumber.isNotEmpty) {
          final matchingQuotation =
              quotationNumbers.where((q) => q.number == qtnNumber).firstOrNull;
          if (matchingQuotation != null) {
            // This will trigger the API call to fetch quotation details
            await _onQuotationSelected(matchingQuotation.number);
          }
        }
      }
    } catch (e) {
      debugPrint('Error prefilling quotation data: $e');
    }
  }

  Future<void> _prefillFromSalesOrder() async {
    final salesOrderData = widget.salesOrderData!;
    final salesOrderItem = widget.salesOrderItem!;

    try {
      // Set preference to "On Sales Order"
      setState(() {
        selectPreference = "On Sales Order";
      });

      // Load sales order defaults
      DefaultSalesOrder = await _service.fetchDefaultDocumentDetail("OB");

      // Extract sales order details
      final salesOrderDetails =
          salesOrderData['salesOrderDetails'] as Map<String, dynamic>;

      // Create customer data from sales order
      final customerCode = salesOrderDetails['customerCode']?.toString() ?? '';
      final customerName = salesOrderDetails['customerName']?.toString() ?? '';

      if (customerCode.isNotEmpty && customerName.isNotEmpty) {
        // Create customer object
        final customer = Customer(
          custCode: customerCode,
          custName: customerName,
          cityCode: "",
          cityName: "",
          totalRows: 0,
        );

        // Set customer and trigger related loading
        await _onCustomerSelected(customer);

        // Find and select the sales order from the loaded list
        final ioNumber = salesOrderItem['ioNumber']?.toString() ?? '';
        if (ioNumber.isNotEmpty) {
          final matchingSalesOrder =
              salesOrderNumbers
                  .where((so) => so.number == ioNumber)
                  .firstOrNull;
          if (matchingSalesOrder != null) {
            // This will trigger the API call to fetch sales order details
            await _onSalesOrderSelected(matchingSalesOrder.number);
          }
        }
      }
    } catch (e) {
      debugPrint('Error prefilling sales order data: $e');
    }
  }

  Future<void> _loadRateStructures() async {
    try {
      final companyDetails = await StorageUtils.readJson('selected_company');
      if (companyDetails == null) {
        _showError("Company details not found.");
        return;
      }
      final companyId = companyDetails['id'];
      rateStructures = await _service.fetchRateStructures(companyId);
    } catch (e) {
      _showError("Failed to load rate structures: ${e.toString()}");
    }
  }

  // Future<void> _onPreferenceChanged(String? value) async {
  //   if (value == null) return;

  //   setState(() {
  //     selectPreference = value;
  //     selectedQuotationNumber = null;
  //     selectedSalesOrderNumber = null;
  //     quotationNumbers.clear();
  //     salesOrderNumbers.clear();
  //     items.clear();
  //     _rsGrid.clear();
  //     _discountDetails.clear();
  //   });

  //   try {
  //     if (value == "On Quotation") {
  //       await _service.fetchDefaultDocumentDetail("SQ");
  //     } else if (value == "On Sales Order") {
  //       await _service.fetchDefaultDocumentDetail("OB");
  //     }
  //   } catch (e) {
  //     _showError("Failed to load document details: ${e.toString()}");
  //   }
  // }
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
        DefaultQuotation = await _service.fetchDefaultDocumentDetail("SQ");
      } else if (value == "On Sales Order") {
        DefaultSalesOrder = await _service.fetchDefaultDocumentDetail("OB");
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

  // Future<void> _onQuotationSelected(String? quotationNumber) async {
  //   if (quotationNumber == null) return;

  //   setState(() {
  //     selectedQuotationNumber = quotationNumber;
  //     items.clear();
  //     _rsGrid.clear();
  //     _discountDetails.clear();
  //     _isLoading = true;
  //   });

  //   try {
  //     final details = await _service.fetchQuotationDetails(quotationNumber);
  //     items = [];
  //     _rsGrid = [];
  //     _discountDetails = [];

  //     int lineNo = 1;
  //     for (final item in details.itemDetail) {
  //       // Use maxInvoiceQty if qty is 0
  //       final quantity =
  //           (item['qty'] ?? 0).toDouble() == 0.0
  //               ? (item['maxInvoiceQty'] ?? 0).toDouble()
  //               : (item['qty'] ?? 0).toDouble();

  //       items.add(
  //         ProformaItem(
  //           itemName: item['itemName'] ?? '',
  //           itemCode: item['itemCode'] ?? '',
  //           qty: quantity,
  //           basicRate: (item['itemRate'] ?? 0).toDouble(),
  //           uom: item['suom'] ?? 'NOS',
  //           discountType: (item['discountAmount'] ?? 0) > 0 ? 'Value' : 'None',
  //           discountAmount: (item['discountAmount'] ?? 0).toDouble(),
  //           discountPercentage: null,
  //           rateStructure: item['rateStructureCode'] ?? '',
  //           taxAmount: (item['totalTax'] ?? 0).toDouble(),
  //           totalAmount: (item['totalValue'] ?? 0).toDouble(),
  //           rateStructureRows: null,
  //           lineNo: lineNo,
  //           hsnAccCode: item['hsnAccCode'] ?? '',
  //         ),
  //       );
  //       lineNo++;
  //     }

  //     // Populate rsGrid from response
  //     if (details.rateStructDetail != null) {
  //       for (final rs in details.rateStructDetail!) {
  //         _rsGrid.add({
  //           "docType": "PI",
  //           "docSubType": "PI",
  //           "xdtdtmcd": rs['xdtdtmcd'] ?? '',
  //           "rateCode": rs['rateCode'] ?? '',
  //           "rateStructCode": rs['rateStructCode'] ?? '',
  //           "rateAmount": rs['rateAmount'] ?? 0,
  //           "amdSrNo": rs['amdSrNo'] ?? 0,
  //           "perCValue": rs['perCValue']?.toString() ?? "0.00",
  //           "incExc": rs['incExc'] ?? '',
  //           "perVal": rs['perVal'] ?? 0,
  //           "appliedOn": rs['appliedOn'] ?? "",
  //           "pnyn": rs['pnyn'] ?? false,
  //           "seqNo": rs['seqNo']?.toString() ?? "1",
  //           "curCode": rs['curCode'] ?? "INR",
  //           "fromLocationId": locationDetails?['id'] ?? 8,
  //           "TaxTyp": rs['TaxTyp'] ?? '',
  //           "refLine": rs['refLine'] ?? 0,
  //         });
  //       }
  //     }

  //     // Populate discountDetail from response
  //     if (details.discountDetail != null) {
  //       for (final disc in details.discountDetail!) {
  //         _discountDetails.add({
  //           "itemCode": disc['itemCode'] ?? '',
  //           "currCode": disc['currCode'] ?? "INR",
  //           "discCode": disc['discCode'] ?? "01",
  //           "discType": disc['discType'] ?? '',
  //           "discVal": disc['discVal'] ?? 0,
  //           "fromLocationId": locationDetails?['id'] ?? 8,
  //           "oditmlineno": disc['oditmlineno'] ?? 0,
  //         });
  //       }
  //     }

  //     // Store the full response for later use
  //     _quotationResponse = details;
  //     setState(() => _isLoading = false);
  //   } catch (e) {
  //     setState(() => _isLoading = false);
  //     _showError("Failed to load quotation details: ${e.toString()}");
  //   }
  // }
  Future<void> _onQuotationSelected(String? quotationNumber) async {
    if (quotationNumber == null) return;

    // Find the selected quotation to get its srNo
    final selectedQuotation = quotationNumbers.firstWhere(
      (q) => q.number == quotationNumber,
      orElse: () => throw Exception("Selected quotation not found"),
    );

    setState(() {
      selectedQuotationNumber = quotationNumber;
      selectedQuotationSrNo = selectedQuotation.srNo.toString();
      items.clear();
      _rsGrid.clear();
      _discountDetails.clear();
      _isLoading = true;
    });

    try {
      final details = await _service.fetchQuotationDetails(
        quotationNumber,
        selectedQuotation.srNo,
      );
      items = [];
      _rsGrid = [];
      _discountDetails = [];

      int lineNo = 1;
      for (final item in details.itemDetail) {
        // Use maxInvoiceQty if qty is 0
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

      // Populate rsGrid from response - use rateAmount from API
      if (details.rateStructDetail != null) {
        for (final rs in details.rateStructDetail!) {
          _rsGrid.add({
            "docType": "PI",
            "docSubType": "PI",
            "xdtdtmcd": rs['dtmCode'] ?? '', // Use dtmCode for item mapping
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
            "fromLocationId": locationDetails?['id'] ?? 8,
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
            "currCode": disc['disccurr'] ?? currency ?? "INR",
            "discCode": disc['disccode'] ?? "01",
            "discType": disc['disctype'] ?? '',
            "discVal": disc['discvalue'] ?? 0,
            "fromLocationId": locationDetails?['id'] ?? 8,
            "oditmlineno": disc['itmModelRefNo'] ?? 0,
          });
        }
      }

      // Store the full response for later use
      _quotationResponse = details;
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("Failed to load quotation details: ${e.toString()}");
    }
  }

  // Update the onSalesOrderSelected method
  Future<void> _onSalesOrderSelected(String? salesOrderNumber) async {
    if (salesOrderNumber == null) return;

    // Find the selected sales order to get its srNo
    final selectedSalesOrder = salesOrderNumbers.firstWhere(
      (so) => so.number == salesOrderNumber,
      orElse: () => throw Exception("Selected sales order not found"),
    );

    setState(() {
      selectedSalesOrderNumber = salesOrderNumber;
      selectedSalesOrderSrNo = selectedSalesOrder.srNo.toString();
      items.clear();
      _rsGrid.clear();
      _discountDetails.clear();
      _isLoading = true;
    });

    try {
      final details = await _service.fetchSalesOrderDetails(
        salesOrderNumber,
        selectedSalesOrder.srNo,
      );
      items = [];
      _rsGrid = [];
      _discountDetails = [];

      int lineNo = 1;
      for (final item in details.itemDetail) {
        // Use maxInvoiceQty if qty is 0
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

      // Populate rsGrid from response - use exact same structure as quotation
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
            "curCode": rs['curCode'] ?? currency,
            "fromLocationId": locationDetails?['id'] ?? 8,
            "TaxTyp": rs['TaxTyp'] ?? '',
            "refLine": rs['refLine'] ?? 0,
          });
        }
      }

      // Populate discountDetail from response - use exact same structure as quotation
      if (details.discountDetail != null) {
        for (final disc in details.discountDetail!) {
          _discountDetails.add({
            "itemCode": disc['itemCode'] ?? '',
            "currCode": disc['currCode'] ?? currency,
            "discCode": disc['discCode'] ?? "01",
            "discType": disc['discType'] ?? '',
            "discVal": disc['discVal'] ?? 0,
            "fromLocationId": locationDetails?['id'] ?? 8,
            "oditmlineno": disc['oditmlineno'] ?? 0,
          });
        }
      }

      // Store the full response for later use
      _salesOrderResponse = details;
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error loading sales order details: $e");
      _showError("Failed to load sales order details: ${e.toString()}");
    }
  }

  // Future<void> _onSalesOrderSelected(String? salesOrderNumber) async {
  //   if (salesOrderNumber == null) return;

  //   setState(() {
  //     selectedSalesOrderNumber = salesOrderNumber;
  //     items.clear();
  //     _rsGrid.clear();
  //     _discountDetails.clear();
  //     _isLoading = true;
  //   });

  //   try {
  //     final details = await _service.fetchSalesOrderDetails(salesOrderNumber);
  //     items = [];
  //     _rsGrid = [];
  //     _discountDetails = [];

  //     int lineNo = 1;
  //     for (final item in details.itemDetail) {
  //       // Use maxInvoiceQty if qty is 0
  //       final quantity =
  //           (item['qty'] ?? 0).toDouble() == 0.0
  //               ? (item['maxInvoiceQty'] ?? 0).toDouble()
  //               : (item['qty'] ?? 0).toDouble();

  //       items.add(
  //         ProformaItem(
  //           itemName: item['itemName'] ?? '',
  //           itemCode: item['itemCode'] ?? '',
  //           qty: quantity,
  //           basicRate: (item['itemRate'] ?? 0).toDouble(),
  //           uom: item['suom'] ?? 'NOS',
  //           discountType: (item['discountAmount'] ?? 0) > 0 ? 'Value' : 'None',
  //           discountAmount: (item['discountAmount'] ?? 0).toDouble(),
  //           discountPercentage: null,
  //           rateStructure: item['rateStructureCode'] ?? '',
  //           taxAmount: (item['totalTax'] ?? 0).toDouble(),
  //           totalAmount: (item['totalValue'] ?? 0).toDouble(),
  //           rateStructureRows: null,
  //           lineNo: lineNo,
  //           hsnAccCode: item['hsnAccCode'] ?? '',
  //         ),
  //       );
  //       lineNo++;
  //     }

  //     // Populate rsGrid from response
  //     if (details.rateStructDetail != null) {
  //       for (final rs in details.rateStructDetail!) {
  //         _rsGrid.add({
  //           "docType": "PI",
  //           "docSubType": "PI",
  //           "xdtdtmcd": rs['xdtdtmcd'] ?? '',
  //           "rateCode": rs['rateCode'] ?? '',
  //           "rateStructCode": rs['rateStructCode'] ?? '',
  //           "rateAmount": rs['rateAmount'] ?? 0,
  //           "amdSrNo": rs['amdSrNo'] ?? 0,
  //           "perCValue": rs['perCValue']?.toString() ?? "0.00",
  //           "incExc": rs['incExc'] ?? '',
  //           "perVal": rs['perVal'] ?? 0,
  //           "appliedOn": rs['appliedOn'] ?? "",
  //           "pnyn": rs['pnyn'] ?? false,
  //           "seqNo": rs['seqNo']?.toString() ?? "1",
  //           "curCode": rs['curCode'] ?? currency ?? "INR",
  //           "fromLocationId": locationDetails?['id'] ?? 8,
  //           "TaxTyp": rs['TaxTyp'] ?? '',
  //           "refLine": rs['refLine'] ?? 0,
  //         });
  //       }
  //     }

  //     // Populate discountDetail from response
  //     if (details.discountDetail != null) {
  //       for (final disc in details.discountDetail!) {
  //         _discountDetails.add({
  //           "itemCode": disc['itemCode'] ?? '',
  //           "currCode": disc['currCode'] ?? currency ?? "INR",
  //           "discCode": disc['discCode'] ?? "01",
  //           "discType": disc['discType'] ?? '',
  //           "discVal": disc['discVal'] ?? 0,
  //           "fromLocationId": locationDetails?['id'],
  //           "oditmlineno": disc['oditmlineno'] ?? 0,
  //         });
  //       }
  //     }

  //     // Store the full response for later use
  //     _salesOrderResponse = details;
  //     setState(() => _isLoading = false);
  //   } catch (e) {
  //     setState(() => _isLoading = false);
  //     _showError("Failed to load sales order details: ${e.toString()}");
  //   }
  // }

  Future<void> _showAddItemPage() async {
    final result = await Navigator.push<ProformaItem>(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                AddItemPage(service: _service, rateStructures: rateStructures),
      ),
    );

    if (result != null) {
      setState(() {
        result.lineNo = items.length + 1;
        items.add(result);
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

  // Map<String, dynamic> _buildSubmissionPayload() {
  //   if (userDetails?['id'] == null) throw Exception("User ID is null");
  //   if (locationDetails?['id'] == null) throw Exception("Location ID is null");
  //   if (locationDetails?['code'] == null) {
  //     throw Exception("Location code is null");
  //   }
  //   if (selectedCustomer == null) throw Exception("Customer is null");

  //   List<Map<String, dynamic>> itemDetails = [];
  //   List<Map<String, dynamic>> rsGrid = [];
  //   List<Map<String, dynamic>> discountDetails = [];

  //   final userId = userDetails?['id'] ?? 0;
  //   final locationId = locationDetails?['id'] ?? 0;
  //   final locationCode = locationDetails?['code'] ?? "";

  //   // Calculate totals using the existing methods
  //   final totalBasic = _calculateTotalBasic();
  //   final totalDiscount = _calculateTotalDiscount();

  //   // Calculate tax from rate structure details instead of item tax amounts
  //   final totalTax = _calculateTaxFromRateStructure();
  //   final totalAmount = _calculateTotalAmount();

  //   // Debug print to verify calculations
  //   debugPrint("Total Basic: $totalBasic");
  //   debugPrint("Total Discount: $totalDiscount");
  //   debugPrint("Total Tax (from rate structure): $totalTax");
  //   debugPrint("Total Amount: $totalAmount");

  //   // Build item details
  //   for (int i = 0; i < items.length; i++) {
  //     final item = items[i];
  //     final lineNo = i + 1;

  //     final itemJson = item.toSubmissionJson(userId, locationId);
  //     itemJson['lineNo'] = lineNo;
  //     itemJson['seqNo'] = lineNo;
  //     itemJson['fromLocationId'] = locationId;
  //     if (selectPreference == "On Quotation") {
  //       itemJson['ordYear'] = _financeDetails?['financialYear'];
  //       itemJson['ordGroup'] = DefaultQuotation!.groupCode;
  //       itemJson['ordNumber'] = selectedQuotationNumber;
  //     } else if (selectPreference == "On Sales Order") {
  //       itemJson['ordYear'] = _financeDetails?['financialYear'];
  //       itemJson['ordGroup'] = DefaultSalesOrder!.groupCode;
  //       itemJson['ordNumber'] = selectedSalesOrderNumber;
  //     }
  //     itemDetails.add(itemJson);
  //   }

  //   // Handle rsGrid and discountDetails based on preference
  //   if (selectPreference == "On Quotation" ||
  //       selectPreference == "On Sales Order") {
  //     // Use pre-populated rsGrid and discountDetails, but update refLine numbers if needed
  //     rsGrid =
  //         _rsGrid.map((rs) {
  //           // Find the corresponding item to get the correct line number
  //           final itemIndex = items.indexWhere(
  //             (item) => item.itemCode == rs['xdtdtmcd'],
  //           );
  //           if (itemIndex != -1) {
  //             rs['refLine'] = itemIndex + 1;
  //           }
  //           return Map<String, dynamic>.from(rs);
  //         }).toList();

  //     discountDetails =
  //         _discountDetails.map((disc) {
  //           // Find the corresponding item to get the correct line number
  //           final itemIndex = items.indexWhere(
  //             (item) => item.itemCode == disc['itemCode'],
  //           );
  //           if (itemIndex != -1) {
  //             disc['oditmlineno'] = itemIndex + 1;
  //           }
  //           return Map<String, dynamic>.from(disc);
  //         }).toList();
  //   } else {
  //     // For "On Other" - build rsGrid and discountDetails from item data
  //     // Need to preserve rate codes from original rate structure
  //     for (int i = 0; i < items.length; i++) {
  //       final item = items[i];
  //       final lineNo = i + 1;

  //       // Add rate structure details for manually added items
  //       if (item.rateStructureRows != null) {
  //         // Find the original rate structure for this item's rate structure code
  //         // final originalRateStructure = rateStructures.firstWhere(
  //         //   (rs) => rs.rateStructCode == item.rateStructure,
  //         //   orElse: null,
  //         // );

  //         for (final row in item.rateStructureRows!) {
  //           // Find the matching rate code from original rate structure by sequence number
  //           String rateCode = row['msprtcd'] ?? row['rateCode'] ?? '';

  //           // If we have the original rate structure details, match by sequence number
  //           if (row['mspseqno'] != null) {
  //             // Try to find rate code from original structure based on sequence
  //             // This assumes the rate structure rows maintain their sequence order
  //             try {
  //               final seqNo =
  //                   int.tryParse(row['mspseqno']?.toString() ?? '0') ?? 0;
  //               if (seqNo > 0) {
  //                 // The rate code should be preserved from the calculated response
  //                 rateCode = row['msprtcd'] ?? '';
  //               }
  //             } catch (e) {
  //               debugPrint("Error parsing sequence number: $e");
  //             }
  //           }

  //           rsGrid.add({
  //             "docType": "PI",
  //             "docSubType": "PI",
  //             "customerItemCode": item.itemCode,
  //             "rateCode": rateCode, // Use the preserved rate code
  //             "rateStructCode": item.rateStructure,
  //             "rateAmount": row['rateAmount'] ?? 0,
  //             "amdSrNo": 0,
  //             "perCValue": row['msprtval']?.toString() ?? "0.00",
  //             "incExc": row['mspincexc'] ?? row['ie'] ?? '',
  //             "perVal": row['mspperval'] ?? row['pv'] ?? 0,
  //             "appliedOn": row['mtrslvlno'] ?? "",
  //             "pnyn": row['msppnyn'] == "True" || row['msppnyn'] == true,
  //             "seqNo": row['mspseqno']?.toString() ?? "1",
  //             "curCode": row['mprcurcode'] ?? "INR",
  //             "fromLocationId": locationId,
  //             "TaxTyp": row['mprtaxtyp'] ?? '',
  //             "refLine": lineNo,
  //           });
  //         }
  //       }

  //       // Add discount details for manually added items
  //       if (item.discountAmount != null && item.discountAmount! > 0) {
  //         discountDetails.add({
  //           "itemCode": item.itemCode,
  //           "currCode": "INR",
  //           "discCode": "DISC",
  //           "discType": item.discountType,
  //           "discVal":
  //               item.discountType == "Percentage"
  //                   ? item.discountPercentage ?? 0
  //                   : item.discountAmount ?? 0,
  //           "fromLocationId": locationId,
  //           "oditmlineno": lineNo,
  //         });
  //       }
  //     }
  //   }

  //   // Always generate itemHeaderDetial regardless of preference type
  //   final itemHeaderDetial = _buildItemHeaderDetail(
  //     totalAmount,
  //     totalTax,
  //     totalDiscount,
  //     userId,
  //     locationId,
  //     locationCode,
  //   );

  //   // Debug print the rsGrid to verify rate codes are preserved
  //   debugPrint("Final rsGrid: $rsGrid");

  //   // Generate transport detail
  //   final transportDetail = _buildTransportDetail(userId);

  //   return {
  //     "action": "add",
  //     "ExchangeRate": 1.0,
  //     "autoNoRequired": "Y",
  //     "customerPoNumber": null,
  //     "customerPoDate": null,
  //     "itemHeaderDetial": itemHeaderDetial,
  //     "itemDetail": itemDetails,
  //     "rsGrid": rsGrid,
  //     "discountDetail": discountDetails,
  //     "standardTerms": [],
  //     "transportDetail": transportDetail,
  //     "chargesDetail": [],
  //     "remark": [],
  //   };
  // }

  Map<String, dynamic> _buildSubmissionPayload() {
    if (userDetails?['id'] == null) throw Exception("User ID is null");
    if (locationDetails?['id'] == null) throw Exception("Location ID is null");
    if (locationDetails?['code'] == null)
      throw Exception("Location code is null");
    if (selectedCustomer == null) throw Exception("Customer is null");

    final userId = userDetails?['id'] ?? 0;
    final locationId = locationDetails?['id'] ?? 0;
    final locationCode = locationDetails?['code'] ?? "";

    // Calculate totals
    final totalBasic = _calculateTotalBasic();
    final totalDiscount = _calculateTotalDiscount();
    final totalTax = _calculateTaxFromRateStructure();
    final totalAmount = _calculateTotalAmount();

    // Build itemDetail list
    List<Map<String, dynamic>> itemDetail = [];
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final lineNo = i + 1;

      // Calculate values for this item
      final basicAmount = item.basicRate * item.qty;
      final discountAmount = item.discountAmount ?? 0.0;
      final discountedAmount = basicAmount - discountAmount;
      final discountedRate = item.qty > 0 ? (discountedAmount / item.qty) : 0.0;

      final itemMap = {
        "ordYear":
            selectPreference == "On Quotation"
                ? (_financeDetails?['financialYear'] ?? "")
                : selectPreference == "On Sales Order"
                ? (_financeDetails?['financialYear'] ?? "")
                : "",
        "rcvAdv": 0,
        "piAdv": 0,
        "rtnAmt": 0,
        "currCd": currency,
        "createdBy": userId,
        "netDiscountRate": discountedRate,
        "discOrdRate": item.basicRate,
        "lineNo": lineNo,
        "salesItemCode": item.itemCode,
        "invItemCode": item.itemCode,
        "ordGroup":
            selectPreference == "On Quotation"
                ? (DefaultQuotation['groupCode'] ?? "")
                : selectPreference == "On Sales Order"
                ? (DefaultSalesOrder['groupCode'] ?? "")
                : "",
        "ordNumber":
            selectPreference == "On Quotation"
                ? (selectedQuotationNumber ?? "")
                : selectPreference == "On Sales Order"
                ? (selectedSalesOrderNumber ?? "")
                : "",
        "quantitySUOM": item.qty,
        "invQty": item.qty,
        "maxAllowedQty": item.qty,
        "hsnAccCode": item.hsnAccCode ?? "",
        "productSize": "",
        "itemUOM": item.uom,
        "discountedRate": discountedRate,
        "discAmount": discountAmount.toStringAsFixed(2),
        "discountedAmount": discountedAmount,
        "taxStructure": item.rateStructure,
        "seqNo": lineNo,
        "fromLocationId": locationId,
        "curCode": currency,
        "headerRemark": "",
        "invId": 0,
        "mainitemcode": "",
        "printseq": "",
        "detaildescription": "",
        "loadRate": 0,
        "remarks": "",
      };

      itemDetail.add(itemMap);
    }

    // Build rsGrid list (ProformaRateStructureDetail)
    List<Map<String, dynamic>> rsGrid = [];
    if (selectPreference == "On Quotation" ||
        selectPreference == "On Sales Order") {
      for (final rs in _rsGrid) {
        final itemIndex = items.indexWhere(
          (item) => item.itemCode == rs['xdtdtmcd'],
        );

        rsGrid.add({
          "docType": "PI",
          "docSubType": "PI",
          "docId": 0,
          "xdtdtmcd": rs['xdtdtmcd'] ?? "",
          "rateCode": rs['rateCode'] ?? "",
          "rateAmount": rs['rateAmount'] ?? 0,
          "amdSrNo": rs['amdSrNo'] ?? 0,
          "perCValue": rs['perCValue'] ?? 0,
          "incExc": rs['incExc'] ?? "",
          "perVal": rs['perVal']?.toString() ?? "0",
          "appliedOn": rs['appliedOn'] ?? "",
          "pnyn": rs['pnyn'] ?? false,
          "rateStructCode": rs['rateStructCode'] ?? "",
          "seqNo": rs['seqNo'] ?? 1,
          "fromLocationId": locationId,
          "py": 0,
          "curCode": rs['curCode'] ?? currency,
          "taxTyp": rs['TaxTyp'] ?? "",
          "refId": 0,
          "percentage": 0,
          "refLine": itemIndex != -1 ? itemIndex + 1 : (rs['refLine'] ?? 1),
        });
      }
    } else {
      // For "On Other" - build from item rate structure data
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        final lineNo = i + 1;

        if (item.rateStructureRows != null) {
          for (final row in item.rateStructureRows!) {
            rsGrid.add({
              "docType": "PI",
              "docSubType": "PI",
              "docId": 0,
              "xdtdtmcd": item.itemCode,
              "rateCode": row['msprtcd'] ?? row['rateCode'] ?? "",
              "rateAmount": row['rateAmount'] ?? 0,
              "amdSrNo": 0,
              "perCValue": row['msprtval'] ?? row['perCValue'] ?? 0,
              "incExc": row['mspincexc'] ?? row['ie'] ?? "",
              "perVal":
                  row['mspperval']?.toString() ??
                  row['perVal']?.toString() ??
                  "0",
              "appliedOn": row['mtrslvlno'] ?? row['appliedOn'] ?? "",
              "pnyn": row['msppnyn'] == "True" || row['msppnyn'] == true,
              "rateStructCode": item.rateStructure,
              "seqNo": int.tryParse(row['mspseqno']?.toString() ?? '1') ?? 1,
              "fromLocationId": locationId,
              "py": 0,
              "curCode": currency,
              "taxTyp": row['mprtaxtyp'] ?? row['TaxTyp'] ?? "",
              "refId": 0,
              "percentage": 0,
              "refLine": lineNo,
            });
          }
        }
      }
    }

    // Build discountDetail list (ProformaDiscountDetail)
    List<Map<String, dynamic>> discountDetail = [];
    if (selectPreference == "On Quotation" ||
        selectPreference == "On Sales Order") {
      for (final disc in _discountDetails) {
        final itemIndex = items.indexWhere(
          (item) => item.itemCode == disc['itemCode'],
        );

        discountDetail.add({
          "invId": 0,
          "itemCode": disc['itemCode'] ?? "",
          "currCode": disc['currCode'] ?? currency,
          "discCode": disc['discCode'] ?? "DISC",
          "discType": disc['discType'] ?? "",
          "discVal": disc['discVal'] ?? 0,
          "fromLocationId": locationId,
          "oditmlineno":
              itemIndex != -1 ? itemIndex + 1 : (disc['oditmlineno'] ?? 1),
        });
      }
    } else {
      // For "On Other" - build from item discount data
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        final lineNo = i + 1;

        if (item.discountAmount != null && item.discountAmount! > 0) {
          discountDetail.add({
            "invId": 0,
            "itemCode": item.itemCode,
            "currCode": currency,
            "discCode": "DISC",
            "discType": item.discountType,
            "discVal":
                item.discountType == "Percentage"
                    ? (item.discountPercentage ?? 0)
                    : (item.discountAmount ?? 0),
            "fromLocationId": locationId,
            "oditmlineno": lineNo,
          });
        }
      }
    }

    // Build itemHeaderDetial (InvoiceHeaderModel)
    final itemHeaderDetial = _buildItemHeaderDetail(
      totalAmount,
      totalTax,
      totalDiscount,
      userId,
      locationId,
      locationCode,
    );

    // Build transportDetail (TransPortDetail)
    final transportDetail = _buildTransportDetail(userId);

    // Build the main payload matching PrformaInvoiceInsertModel
    return {
      "action": "add",
      "autoNoRequired": "Y",
      "exchangeRate": 1.0,
      "customerPoNumber": null,
      "customerPoDate": null,
      "itemHeaderDetial": itemHeaderDetial,
      "itemDetail": itemDetail,
      "rsGrid": rsGrid,
      "discountDetail": discountDetail,
      "termsDetail": [],
      "transportDetail": transportDetail,
      "chargesDetail": [],
      "remark": [],
      "standardTerms": [],
    };
  }

  // Update the itemHeaderDetail method to fix discount value calculation
  // Map<String, dynamic> _buildItemHeaderDetail(
  //   double totalAmount,
  //   double totalTax,
  //   double totalDiscount,
  //   int userId,
  //   int locationId,
  //   String locationCode,
  // ) {
  //   final financeDetails = _financeDetails ?? {};
  //   final financialYear = financeDetails['financialYear'] ?? "25-26";

  //   String discountType = "None";
  //   if (items.isNotEmpty && totalDiscount > 0) {
  //     final firstItemDiscountType = items.first.discountType;
  //     final allSameDiscountType = items.every(
  //       (item) => item.discountType == firstItemDiscountType,
  //     );
  //     discountType = allSameDiscountType ? firstItemDiscountType : "Mixed";
  //   }

  //   final basicAmount = _calculateTotalBasic();
  //   final netAmount = basicAmount - totalDiscount;
  //   final finalAmount = netAmount + totalTax;

  //   return {
  //     "autoId": 0,
  //     "invYear": financialYear,
  //     "invGroup": DefaultProformaInvoice['groupCode'] ?? "PI",
  //     "invSite": locationId,
  //     "invSiteCode": locationCode,
  //     "invIssueDate":
  //         selectedDate != null
  //             ? "${selectedDate!.year.toString().padLeft(4, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}"
  //             : "",
  //     "invValue": netAmount.toStringAsFixed(2),
  //     "invAmount": finalAmount.toStringAsFixed(2),
  //     "invRoValue": finalAmount.round(),
  //     "invTax": totalTax.toStringAsFixed(2),
  //     "invType": "M",
  //     "invCustCode": selectedCustomer!.custCode,
  //     "invStatus": "O",
  //     "invOn":
  //         selectPreference == "On Quotation"
  //             ? "Q"
  //             : selectPreference == "On Sales Order"
  //             ? "O"
  //             : "T",
  //     "invDiscountType": discountType,
  //     "invDiscountValue":
  //         totalDiscount, // Remove toStringAsFixed, keep as number
  //     "invFromLocationId": locationId,
  //     "invCreatedUserId": userId,
  //     "invCurrCode": currency,
  //     "invRate": 0,
  //     "invNumber": "",
  //     "invBacAmount": basicAmount.toStringAsFixed(2),
  //     "invSiteReq": "Y",
  //   };
  // }
  Map<String, dynamic> _buildItemHeaderDetail(
    double totalAmount,
    double totalTax,
    double totalDiscount,
    int userId,
    int locationId,
    String locationCode,
  ) {
    final financeDetails = _financeDetails ?? {};
    final financialYear = financeDetails['financialYear'] ?? "25-26";

    final basicAmount = _calculateTotalBasic();
    final netAmount = basicAmount - totalDiscount;
    final finalAmount = netAmount + totalTax;

    String discountType = "None";
    if (items.isNotEmpty && totalDiscount > 0) {
      final firstItemDiscountType = items.first.discountType;
      final allSameDiscountType = items.every(
        (item) => item.discountType == firstItemDiscountType,
      );
      discountType = allSameDiscountType ? firstItemDiscountType : "Mixed";
    }

    return {
      "autoId": 0,
      "invYear": financialYear,
      "invGroup": DefaultProformaInvoice['groupCode'] ?? "PI",
      "invSite": locationId,
      "invSiteCode": locationCode,
      "invIssueDate":
          selectedDate != null
              ? "${selectedDate!.year.toString().padLeft(4, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}"
              : "",
      "invValue": netAmount, // Keep as decimal
      "invAmount": finalAmount, // Keep as decimal
      "invTax": totalTax, // Keep as decimal
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
      "invDiscountValue": totalDiscount, // Keep as decimal
      "invFromLocationId": locationId,
      "invCreatedUserId": userId,
      "invCurrCode": currency,
      "exchangeRate": 1.0,
      "customerPoNumber": null,
      "customerPoDate": null,
      "invNumber": "",
      "invBacAmount": basicAmount, // Keep as decimal
      "invSiteReq": "Y",
    };
  }

  double _calculateTaxFromRateStructure() {
    if (selectPreference == "On Quotation" ||
        selectPreference == "On Sales Order") {
      // Use rate structure details from quotation/sales order response
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

      debugPrint("Tax calculated from rate structure: $totalTax");
      return totalTax;
    } else {
      // For "On Other" - use the existing calculation
      return _calculateTotalTax();
    }
  }

  Map<String, dynamic> _buildTransportDetail(int userId) {
    return {
      "refId": 0,
      "shipVIa": "",
      "portLoad": "",
      "portDischarg": "",
      "kindAttention": "",
      "attencontactno": "",
      "finDestination": "",
      "shippingMark": "",
      "bookCode": "",
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
  //     final success = await _service.submitProformaInvoice(payload);

  //     setState(() => _isLoading = false);

  //     if (success) {
  //       _showSuccess("Proforma Invoice submitted successfully");
  //       Navigator.pop(context, true);
  //     } else {
  //       _showError("Failed to submit Proforma Invoice");
  //     }
  //   } catch (e, st) {
  //     setState(() => _isLoading = false);
  //     debugPrint("Error stacktrace during submission: $st");
  //     _showError("Error during submission: ${e.toString()}");
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
              'Location access is required to submit the proforma invoice',
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
      final proformaInvoiceNumber = await _service.submitProformaInvoice(
        payload,
      );

      if (proformaInvoiceNumber != "0") {
        // Step 3: Submit location with proper error handling
        bool locationSuccess = true;
        List<String> errorMessages = [];

        // Submit location using the proforma invoice number
        try {
          locationSuccess = await _service.submitLocation(
            functionId: proformaInvoiceNumber,
            longitude: position.longitude,
            latitude: position.latitude,
          );

          if (!locationSuccess) {
            errorMessages.add('Location submission failed');
          }
        } catch (e) {
          debugPrint('Location submission error: $e');
          locationSuccess = false;
          errorMessages.add('Location submission failed: $e');
        }

        if (!mounted) return;
        setState(() => _isLoading = false);

        // Show appropriate success/error messages
        if (locationSuccess) {
          _showSuccess(
            "Proforma Invoice submitted successfully with location!",
          );
        } else {
          String errorMessage = 'Proforma Invoice submitted, but ';
          if (errorMessages.isNotEmpty) {
            errorMessage += errorMessages.join(', ');
          } else {
            errorMessage += 'location submission failed';
          }
          _showError(errorMessage);
        }

        Navigator.pop(context, true);
      } else {
        setState(() => _isLoading = false);
        _showError("Failed to submit Proforma Invoice");
      }
    } catch (e, st) {
      setState(() => _isLoading = false);
      debugPrint("Error stacktrace during submission: $st");
      _showError("Error during submission: ${e.toString()}");
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
                title: const Text("Confirm Submission"),
                content: const Text(
                  "Are you sure you want to submit this Proforma Invoice?",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Submit"),
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
      appBar: AppBar(title: const Text("Add Proforma Invoice"), elevation: 1),
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
                (pref) =>
                    DropdownMenuItem<String>(value: pref, child: Text(pref)),
              )
              .toList(),
      onChanged: _onPreferenceChanged,
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
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: startDate,
          lastDate: DateTime.now(),
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

  Widget _buildCustomerField() {
    return TypeAheadField<Customer>(
      debounceDuration: const Duration(milliseconds: 400),
      controller: customerController,
      builder: (context, controller, focusNode) {
        return TextFormField(
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
      suggestionsCallback: (pattern) async {
        if (pattern.length < 4) return [];
        try {
          return await _service.fetchCustomerSuggestions(pattern);
        } catch (e) {
          return [];
        }
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

  Widget _buildQuotationDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: "Quotation Number",
        border: OutlineInputBorder(),
      ),
      value: selectedQuotationNumber,
      items:
          quotationNumbers
              .map(
                (qn) => DropdownMenuItem<String>(
                  value: qn.number,
                  child: Text(qn.number),
                ),
              )
              .toList(),
      onChanged: _onQuotationSelected,
      validator: (val) => val == null ? "Quotation Number is required" : null,
    );
  }

  Widget _buildSalesOrderDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: "Sales Order Number",
        border: OutlineInputBorder(),
      ),
      value: selectedSalesOrderNumber,
      items:
          salesOrderNumbers
              .map(
                (so) => DropdownMenuItem<String>(
                  value: so.number,
                  child: Text(so.number),
                ),
              )
              .toList(),
      onChanged: _onSalesOrderSelected,
      validator: (val) => val == null ? "Sales Order Number is required" : null,
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
                // trailing: IconButton(
                //   icon: const Icon(Icons.delete, color: Colors.red),
                //   onPressed: () => _removeItem(index),
                // ),
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
    final totalTax =
        _calculateTaxFromRateStructure(); // Use rate structure tax calculation
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
        child: const Text("Submit Proforma Invoice"),
      ),
    );
  }

  @override
  void dispose() {
    dateController.dispose();
    customerController.dispose();
    super.dispose();
  }
}
