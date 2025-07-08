import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:nhapp/pages/proforma_invoice/models/add_proforma_invoice.dart';
import 'package:nhapp/pages/proforma_invoice/models/proforma_details.dart';
import 'package:nhapp/pages/proforma_invoice/pages/add_item_page.dart';
import 'package:nhapp/pages/proforma_invoice/service/add_proforma_invoice.dart';
import 'package:nhapp/utils/format_utils.dart';
import '../../../utils/storage_utils.dart';

class EditProformaInvoiceForm extends StatefulWidget {
  final ProformaInvoiceDetails proformaDetails;
  final int proformaId;

  const EditProformaInvoiceForm({
    super.key,
    required this.proformaDetails,
    required this.proformaId,
  });

  @override
  State<EditProformaInvoiceForm> createState() =>
      _EditProformaInvoiceFormState();
}

class _EditProformaInvoiceFormState extends State<EditProformaInvoiceForm> {
  late ProformaInvoiceService _service;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController dateController = TextEditingController();
  final TextEditingController customerController = TextEditingController();

  String? selectPreference;
  DateTime? selectedDate;
  Customer? selectedCustomer;
  String? selectedQuotationNumber;
  String? selectedSalesOrderNumber;
  List<ProformaItem> items = [];
  List<RateStructure> rateStructures = [];
  late Map<String, dynamic>? companyDetails;
  late Map<String, dynamic>? locationDetails;
  late Map<String, dynamic>? userDetails;
  late Map<String, dynamic>? _financeDetails;
  List<Map<String, dynamic>> _rsGrid = [];
  List<Map<String, dynamic>> _discountDetails = [];
  late DateTime startDate;
  late DateTime endDate;

  final List<String> preferenceOptions = [
    "On Quotation",
    "On Sales Order",
    "On Other",
  ];

  bool _isLoading = true;
  bool _isEditable = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  Future<void> _initializeForm() async {
    _service = await ProformaInvoiceService.create();
    await _loadFinancePeriod();
    await _loadRateStructures();
    companyDetails = await StorageUtils.readJson('selected_company');
    locationDetails = await StorageUtils.readJson('selected_location');
    final tokenDetails = await StorageUtils.readJson('session_token');
    userDetails = tokenDetails?['user'];

    _prefillFormWithDetails();
    setState(() => _isLoading = false);
  }

  void _prefillFormWithDetails() {
    final header = widget.proformaDetails.headerDetail;
    final gridDetail = widget.proformaDetails.gridDetail;

    // Set preference based on invOn field
    final invOn = header['invOn'] ?? '';
    if (invOn == 'Q') {
      selectPreference = "On Quotation";
      selectedQuotationNumber = header['refNumber'] ?? '';
    } else if (invOn == 'O') {
      selectPreference = "On Sales Order";
      selectedSalesOrderNumber = header['refNumber'] ?? '';
    } else {
      selectPreference = "On Other";
      _isEditable = true;
    }

    // Set date
    final dateStr = header['invIssueDate'] ?? '';
    if (dateStr.isNotEmpty) {
      selectedDate = DateTime.parse(dateStr);
      dateController.text = FormatUtils.formatDateForUser(selectedDate!);
    }

    // Set customer
    selectedCustomer = Customer(
      totalRows: 1,
      custCode: header['invCustCode'] ?? '',
      custName: header['custName'] ?? '',
      cityCode: header['cityCode'] ?? '',
      cityName: header['cityName'] ?? '',
    );
    customerController.text = selectedCustomer!.custName;

    // Parse items from gridDetail
    _parseItemsFromGridDetail(gridDetail);

    // Parse rate structure and discount details
    _parseRateStructureFromDetails();
    _parseDiscountDetailsFromDetails();
  }

  void _parseItemsFromGridDetail(Map<String, dynamic> gridDetail) {
    final itemDetailList = gridDetail['itemDetail'] as List<dynamic>? ?? [];

    items =
        itemDetailList.map<ProformaItem>((item) {
          return ProformaItem(
            itemName: item['itemName'] ?? '',
            itemCode: item['salesItemCode'] ?? '',
            qty: (item['invQty'] ?? 0).toDouble(),
            basicRate: (item['discOrdRate'] ?? 0).toDouble(),
            uom: item['itemUOM'] ?? 'NOS',
            discountType: (item['discAmount'] ?? 0) > 0 ? 'Value' : 'None',
            discountAmount:
                double.tryParse(item['discAmount']?.toString() ?? '0') ?? 0.0,
            discountPercentage: null,
            rateStructure: item['taxStructure'] ?? '',
            taxAmount: (item['taxAmount'] ?? 0).toDouble(),
            totalAmount: (item['discountedAmount'] ?? 0).toDouble(),
            rateStructureRows: null,
            lineNo: item['lineNo'] ?? 0,
            hsnAccCode: item['hsnAccCode'] ?? '',
          );
        }).toList();
  }

  void _parseRateStructureFromDetails() {
    _rsGrid = List<Map<String, dynamic>>.from(
      widget.proformaDetails.gridDetail['rsGrid'] ?? [],
    );
  }

  void _parseDiscountDetailsFromDetails() {
    _discountDetails = List<Map<String, dynamic>>.from(
      widget.proformaDetails.gridDetail['discountDetail'] ?? [],
    );
  }

  Future<void> _loadFinancePeriod() async {
    try {
      _financeDetails = await StorageUtils.readJson('finance_period');
      if (_financeDetails != null) {
        startDate = DateTime.parse(_financeDetails!['periodSDt']);
        endDate = DateTime.parse(_financeDetails!['periodEDt']);
      }
    } catch (e) {
      _setDefaultDate();
    }
  }

  void _setDefaultDate() {
    startDate = DateTime.now().subtract(const Duration(days: 365));
    endDate = DateTime.now();
  }

  Future<void> _loadRateStructures() async {
    try {
      final companyDetails = await StorageUtils.readJson('selected_company');
      if (companyDetails != null) {
        final companyId = companyDetails['id'];
        rateStructures = await _service.fetchRateStructures(companyId);
      }
    } catch (e) {
      _showError("Failed to load rate structures: ${e.toString()}");
    }
  }

  Future<void> _showAddItemPage() async {
    if (!_isEditable) return;

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

  void _removeItem(int index) {
    if (!_isEditable) return;

    setState(() {
      items.removeAt(index);
      // Reassign line numbers
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

  Map<String, dynamic> _buildUpdatePayload() {
    if (userDetails?['id'] == null) throw Exception("User ID is null");
    if (locationDetails?['id'] == null) throw Exception("Location ID is null");
    if (locationDetails?['code'] == null)
      throw Exception("Location code is null");
    if (selectedCustomer == null) throw Exception("Customer is null");

    List<Map<String, dynamic>> itemDetails = [];
    List<Map<String, dynamic>> rsGrid = [];
    List<Map<String, dynamic>> discountDetails = [];

    final userId = userDetails?['id'] ?? 0;
    final locationId = locationDetails?['id'] ?? 0;
    final locationCode = locationDetails?['code'] ?? "";

    // Calculate totals
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
      itemDetails.add(itemJson);
    }

    // Handle rsGrid and discountDetails
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
      // For "On Other" - build from item data
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
      "action": "edit",
      "autoId": widget.proformaId,
      "ExchangeRate": 1.0,
      "autoNoRequired": "N",
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
    final header = widget.proformaDetails.headerDetail;
    final financeDetails = _financeDetails ?? {};
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
      "autoId": widget.proformaId,
      "invYear": financialYear,
      "invGroup": header['invGroup'] ?? "PI",
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
      "invType": header['invType'] ?? "M",
      "invCustCode": selectedCustomer!.custCode,
      "invStatus": header['invStatus'] ?? "O",
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
      "invNumber": header['invNumber'] ?? "",
      "invBacAmount": basicAmount.toStringAsFixed(2),
      "invSiteReq": "Y",
    };
  }

  Map<String, dynamic> _buildTransportDetail(int userId) {
    final transport =
        widget.proformaDetails.gridDetail['transportDetail'] ?? {};
    return {
      "refId": transport['refId'] ?? 0,
      "shipVIa": transport['shipVIa'] ?? "",
      "portLoad": transport['portLoad'] ?? "",
      "portDischarg": transport['portDischarg'] ?? "",
      "kindAttention": transport['kindAttention'] ?? "",
      "attencontactno": transport['attencontactno'] ?? "",
      "finDestination": transport['finDestination'] ?? "",
      "shippingMark": transport['shippingMark'] ?? "",
      "bookCode": transport['bookCode'] ?? "",
      "createdBy": userId,
    };
  }

  Future<void> _updateProformaInvoice() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_validateForm()) return;

    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;

    try {
      setState(() => _isLoading = true);

      final payload = _buildUpdatePayload();
      final success = await _service.updateProformaInvoice(payload);

      setState(() => _isLoading = false);

      if (success) {
        _showSuccess("Proforma Invoice updated successfully");
        Navigator.pop(context, true);
      } else {
        _showError("Failed to update Proforma Invoice");
      }
    } catch (e) {
      setState(() => _isLoading = false);
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
      appBar: AppBar(title: const Text("Edit Proforma Invoice"), elevation: 1),
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
                        _buildQuotationField(),
                        const SizedBox(height: 16),
                      ],
                      if (selectPreference == "On Sales Order") ...[
                        _buildSalesOrderField(),
                        const SizedBox(height: 16),
                      ],
                      if (items.isNotEmpty) ...[
                        _buildItemsList(),
                        const SizedBox(height: 16),
                      ],
                      if (_isEditable) ...[
                        _buildAddItemButton(),
                        const SizedBox(height: 16),
                      ],
                      if (items.isNotEmpty) ...[
                        _buildTotalCard(),
                        const SizedBox(height: 24),
                      ],
                      _buildUpdateButton(),
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
      onChanged: null, // Disabled in edit mode
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
      readOnly: !_isEditable,
      onTap:
          _isEditable
              ? () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: startDate,
                  lastDate: endDate,
                );
                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                    dateController.text = FormatUtils.formatDateForUser(picked);
                  });
                }
              }
              : null,
      validator:
          (val) => val == null || val.isEmpty ? "Date is required" : null,
    );
  }

  Widget _buildCustomerField() {
    return TextFormField(
      controller: customerController,
      decoration: const InputDecoration(
        labelText: "Customer Name",
        border: OutlineInputBorder(),
      ),
      readOnly: true, // Always read-only in edit mode
      validator:
          (val) =>
              val == null || val.isEmpty ? "Customer Name is required" : null,
    );
  }

  Widget _buildQuotationField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: "Quotation Number",
        border: OutlineInputBorder(),
      ),
      initialValue: selectedQuotationNumber,
      readOnly: true,
      validator:
          (val) =>
              val == null || val.isEmpty
                  ? "Quotation Number is required"
                  : null,
    );
  }

  Widget _buildSalesOrderField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: "Sales Order Number",
        border: OutlineInputBorder(),
      ),
      initialValue: selectedSalesOrderNumber,
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
                trailing:
                    _isEditable
                        ? IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeItem(index),
                        )
                        : null,
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

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _updateProformaInvoice,
        child: const Text("Update Proforma Invoice"),
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
