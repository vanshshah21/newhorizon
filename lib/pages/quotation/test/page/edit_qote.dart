import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:nhapp/pages/quotation/test/model/model_ad_qote.dart';
import 'package:nhapp/pages/quotation/test/page/ad_itm.dart';
import 'package:nhapp/pages/quotation/test/page/edit_item.dart';
import 'package:nhapp/pages/quotation/test/service/qote_service.dart';
import 'package:nhapp/utils/format_utils.dart';
import 'package:nhapp/utils/storage_utils.dart';
import 'package:file_picker/file_picker.dart';

class EditQuotationPage extends StatefulWidget {
  final String quotationNumber;
  final String quotationYear;
  final String? quotationGrp;
  final int? quotationSiteId;

  const EditQuotationPage({
    super.key,
    required this.quotationNumber,
    required this.quotationYear,
    required this.quotationGrp,
    required this.quotationSiteId,
  });

  @override
  State<EditQuotationPage> createState() => _EditQuotationPageState();
}

class _EditQuotationPageState extends State<EditQuotationPage> {
  late QuotationService _service;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController dateController = TextEditingController();
  final TextEditingController customerController = TextEditingController();
  final TextEditingController billToController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();

  QuotationBase? selectedQuotationBase;
  List<QuotationBase> quotationBases = [];
  DateTime? selectedDate;
  Customer? selectedCustomer;
  Customer? selectedBillToCustomer;
  Salesman? selectedSalesman;
  List<Salesman> salesmanList = [];
  List<RateStructure> rateStructures = [];
  List<QuotationItem> items = [];
  List<PlatformFile> attachments = [];
  DocumentDetail? documentDetail;
  List<Inquiry> inquiryList = [];
  Inquiry? selectedInquiry;
  QuotationEditData? originalData;
  bool _isLoading = true;
  bool _submitting = false;
  DateTime? startDate;
  DateTime? endDate;
  late Map<String, dynamic>? _financeDetails;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  Future<void> _initializeForm() async {
    _service = await QuotationService.create();
    await _loadFinancePeriod();
    await _loadQuotationBases();
    await _loadRateStructures();
    await _loadSalesmanList();
    await _loadDocumentDetail();
    await _loadQuotationData();
    setState(() => _isLoading = false);
  }

  Future<void> _loadFinancePeriod() async {
    _financeDetails = await StorageUtils.readJson('finance_period');
    if (_financeDetails != null) {
      startDate = DateTime.parse(_financeDetails!['periodSDt']);
      endDate = DateTime.parse(_financeDetails!['periodEDt']);
    }
  }

  Future<void> _loadQuotationBases() async {
    quotationBases = await _service.fetchQuotationBaseList();
  }

  Future<void> _loadRateStructures() async {
    rateStructures = await _service.fetchRateStructures();
  }

  Future<void> _loadSalesmanList() async {
    salesmanList = await _service.fetchSalesmanList();
  }

  Future<void> _loadDocumentDetail() async {
    documentDetail = await _service.fetchDefaultDocumentDetail("SQ");
  }

  Future<void> _loadQuotationData() async {
    try {
      originalData = await _service.fetchQuotationForEdit(
        widget.quotationNumber,
        widget.quotationYear,
        widget.quotationGrp,
        widget.quotationSiteId,
      );

      // Populate form with existing data
      selectedDate = originalData!.quotationDate;
      dateController.text = FormatUtils.formatDateForUser(selectedDate!);
      subjectController.text = originalData!.subject;

      // Set quotation base
      selectedQuotationBase = quotationBases.firstWhere(
        (base) => base.code == originalData!.quotationBase,
        orElse: () => quotationBases.first,
      );

      // Create customer objects
      selectedCustomer = Customer(
        customerCode: originalData!.customerCode,
        customerName: originalData!.customerName,
        gstNumber: '',
        telephoneNo: '',
        customerFullName: originalData!.customerName,
      );
      customerController.text = selectedCustomer!.customerName;

      selectedBillToCustomer = Customer(
        customerCode: originalData!.billToCustomerCode,
        customerName: originalData!.billToCustomerName,
        gstNumber: '',
        telephoneNo: '',
        customerFullName: originalData!.billToCustomerName,
      );
      billToController.text = selectedBillToCustomer!.customerName;

      // Set salesman
      selectedSalesman = salesmanList.firstWhere(
        (s) => s.salesmanCode == originalData!.salesmanCode,
        orElse: () => salesmanList.first,
      );

      // Set inquiry if applicable
      if (originalData!.inquiryId != null && originalData!.inquiryId! > 0) {
        selectedInquiry = Inquiry(
          inquiryNumber: originalData!.inquiryNumber,
          inquiryId: originalData!.inquiryId!,
          customerName: originalData!.customerName,
        );
      }

      // Set items
      items = List.from(originalData!.items);

      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error loading quotation: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _onCustomerSelected(Customer customer) async {
    setState(() {
      selectedCustomer = customer;
      customerController.text = customer.customerName;
      selectedSalesman = _findSalesmanForCustomer(customer);
    });
  }

  Future<void> _onBillToSelected(Customer customer) async {
    setState(() {
      selectedBillToCustomer = customer;
      billToController.text = customer.customerName;
    });
  }

  Salesman _findSalesmanForCustomer(Customer customer) {
    return salesmanList.firstWhere(
      (s) => s.salesmanCode == customer.customerCode,
      orElse:
          () =>
              salesmanList.isNotEmpty ? salesmanList.first : selectedSalesman!,
    );
  }

  Future<void> _showAddItemPage() async {
    final result = await Navigator.push<QuotationItem>(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                AddItemPage(rateStructures: rateStructures, service: _service),
      ),
    );
    if (result != null) {
      setState(() {
        result.lineNo = items.length + 1;
        items.add(result);
      });
    }
  }

  Future<void> _showEditItemPage(QuotationItem item, int index) async {
    final result = await Navigator.push<QuotationItem>(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditItemPage(
              rateStructures: rateStructures,
              item: item,
              service: _service,
            ),
      ),
    );
    if (result != null) {
      setState(() {
        items[index] = result;
        // Re-assign line numbers
        for (int i = 0; i < items.length; i++) {
          items[i].lineNo = i + 1;
        }
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

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      item.lineNo = i + 1;

      final modelDetail = item.toModelDetail();
      modelDetail['customerCode'] = selectedCustomer?.customerCode ?? "";
      modelDetail['quotationOrderNumber'] = widget.quotationNumber;
      modelDetails.add(modelDetail);

      final discountDetail = item.toDiscountDetail();
      if (discountDetail.isNotEmpty) {
        discountDetails.add(discountDetail);
      }

      rateStructureDetails.addAll(item.toRateStructureDetails());
    }

    final totalBasic = _calculateTotalBasic();
    final totalDiscount = _calculateTotalDiscount();
    final totalTax = _calculateTotalTax();
    final totalAfterDiscount = totalBasic - totalDiscount;
    final finalAmount = totalAfterDiscount + totalTax;

    return {
      "authorizationRequired": "Y",
      "autoNumberRequired": "N", // No auto number for update
      "siteRequired": "Y",
      "authorizationDate": FormatUtils.formatDateForApi(
        selectedDate ?? DateTime.now(),
      ),
      "fromLocationId": locationId,
      "userId": userId,
      "companyId": companyId,
      "fromLocationCode": locationCode,
      "fromLocationName": _service.locationDetails['name'] ?? "",
      "ip": "",
      "mac": "",
      "domesticCurrencyCode": "INR",
      "quotationDetails": {
        "customerCode": selectedCustomer?.customerCode ?? "",
        "quotationYear": originalData!.quotationYear,
        "quotationGroup": originalData!.quotationGroup,
        "quotationNumber": int.tryParse(widget.quotationNumber) ?? 0,
        "quotationDate": FormatUtils.formatDateForApi(
          selectedDate ?? DateTime.now(),
        ),
        "salesPersonCode": selectedSalesman?.salesmanCode ?? "",
        "validity": "30",
        "attachFlag": "",
        "totalAmounttAfterTaxDomesticCurrency": finalAmount.toStringAsFixed(2),
        "totalAmountAfterTaxCustomerCurrency": finalAmount.toStringAsFixed(2),
        "totalAmountAfterDiscountCustomerCurrency": totalAfterDiscount
            .toStringAsFixed(2),
        "exchangeRate": "1",
        "discountType": "None",
        "discountAmount": "0",
        "modValue": 0,
        "subject": subjectController.text,
        "kindAttentionName": "",
        "kindAttentionDesignation": "",
        "destination": "",
        "authorizedSignatoryName": "",
        "authorizedSignatoryDesignation": "",
        "customerInqRefNo": "",
        "customerInqRefDate": "",
        "customerName": selectedCustomer?.customerName ?? "",
        "inquiryDate": null,
        "quotationSiteId": originalData!.quotationSiteId.toString(),
        "quotationSiteCode": locationCode,
        "quotationId": originalData!.quotationId,
        "inquiryId": selectedInquiry?.inquiryId ?? 0,
        "quotationTypeSalesOrder": "REG",
        "ProjectItemId": 0,
        "ProjectItemCode": "",
        "isAgentAssociated": false,
        "projectName": "",
        "contactEmail": "",
        "contactNo": "",
        "submittedDate": null,
        "isBudgetaryQuotation": false,
        "quotationStatus": "NS",
        "quotationAmendDate": null,
        "currencyCode": "INR",
        "agentCode": "",
        "quotationTypeConfig": "N",
        "reasonCode": "",
        "consultantCode": "",
        "billToCustomerCode": selectedBillToCustomer?.customerCode ?? "",
        "amendmentSrNo": "0",
        "xqdbookcd": "",
      },
      "modelDetails": modelDetails,
      "discountDetails": discountDetails,
      "rateStructureDetails": rateStructureDetails,
      "historyDetails": [],
      "noteDetails": [],
      "equipmentAttributeDetails": [],
      "addOnDetails": [],
      "subItemDetails": [],
      "standardTerms": [],
      "quotationRemarks": [],
      "msctechspecifications": true,
      "mscSameItemAllowMultitimeFlag": true,
    };
  }

  Future<void> _updateQuotation() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedCustomer == null) {
      _showError("Please select a customer");
      return;
    }
    if (selectedBillToCustomer == null) {
      _showError("Please select Bill To customer");
      return;
    }
    if (selectedSalesman == null) {
      _showError("Please select a salesman");
      return;
    }
    if (subjectController.text.isEmpty) {
      _showError("Please enter subject");
      return;
    }
    if (items.isEmpty) {
      _showError("Please add at least one item");
      return;
    }

    setState(() => _submitting = true);

    try {
      final payload = _buildUpdatePayload();
      final response = await _service.updateQuotation(payload);

      if (response['success'] == true) {
        // Upload attachments if any
        if (attachments.isNotEmpty) {
          final docYear = _financeDetails?['financialYear'] ?? "";

          final uploadSuccess = await _service.uploadAttachments(
            filePaths: attachments.map((f) => f.path!).toList(),
            documentNo: widget.quotationNumber,
            documentId: "SQ",
            docYear: docYear,
            formId: "QUOTATION",
            locationCode: _service.locationDetails['code'] ?? "",
            companyCode: _service.companyDetails['code'] ?? "",
            locationId: _service.locationDetails['id'] ?? 0,
            companyId: _service.companyId,
            userId: _service.tokenDetails['user']['id'] ?? 0,
          );

          if (!uploadSuccess) {
            _showError("Quotation updated, but attachment upload failed!");
          }
        }

        _showSuccess(response['message'] ?? "Quotation updated successfully");
        Navigator.pop(context, true);
      } else {
        _showError(response['errorMessage'] ?? "Failed to update quotation");
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
    dateController.dispose();
    customerController.dispose();
    billToController.dispose();
    subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Quotation #${widget.quotationNumber}"),
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
                      _buildQuotationInfoCard(),
                      const SizedBox(height: 16),
                      _buildDateField(),
                      const SizedBox(height: 16),
                      _buildCustomerField(),
                      const SizedBox(height: 16),
                      _buildBillToField(),
                      const SizedBox(height: 16),
                      _buildSalesmanDropdown(),
                      const SizedBox(height: 16),
                      _buildSubjectField(),
                      const SizedBox(height: 16),
                      if (items.isNotEmpty) ...[
                        _buildItemsList(),
                        const SizedBox(height: 16),
                      ],
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

  Widget _buildQuotationInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Quotation Information",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text("Number: ${widget.quotationNumber}"),
            Text("Year: ${widget.quotationYear}"),
            Text("Base: ${originalData?.quotationBase ?? 'N/A'}"),
            if (originalData?.inquiryNumber.isNotEmpty == true)
              Text("Inquiry: ${originalData!.inquiryNumber}"),
          ],
        ),
      ),
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

  Widget _buildCustomerField() {
    return TypeAheadField<Customer>(
      debounceDuration: const Duration(milliseconds: 400),
      controller: customerController,
      builder: (context, controller, focusNode) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: !_submitting,
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
      onSelected: _submitting ? null : _onCustomerSelected,
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

  Widget _buildSalesmanDropdown() {
    return DropdownButtonFormField<Salesman>(
      decoration: const InputDecoration(
        labelText: "Salesman",
        border: OutlineInputBorder(),
      ),
      value: selectedSalesman,
      items:
          salesmanList
              .map(
                (s) => DropdownMenuItem<Salesman>(
                  value: s,
                  child: Text(s.salesManFullName),
                ),
              )
              .toList(),
      onChanged:
          _submitting
              ? null
              : (val) {
                setState(() {
                  selectedSalesman = val;
                });
              },
      validator: (val) => val == null ? "Salesman is required" : null,
    );
  }

  Widget _buildSubjectField() {
    return TextFormField(
      controller: subjectController,
      enabled: !_submitting,
      decoration: const InputDecoration(
        labelText: "Subject",
        border: OutlineInputBorder(),
      ),
      validator:
          (val) => val == null || val.isEmpty ? "Subject is required" : null,
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
                  "Qty: ${item.qty} ${item.uom}\nRate: ₹${item.basicRate.toStringAsFixed(2)}\nTotal: ₹${item.totalAmount.toStringAsFixed(2)}",
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed:
                          _submitting
                              ? null
                              : () => _showEditItemPage(item, index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: _submitting ? null : () => _removeItem(index),
                    ),
                  ],
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

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitting ? null : _updateQuotation,
        child:
            _submitting
                ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Text("Update Quotation"),
      ),
    );
  }
}
