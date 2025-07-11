import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:nhapp/pages/Quotation2/models/add_quotation.dart';
import 'package:nhapp/pages/Quotation2/services/quotation_service.dart';
import 'package:nhapp/pages/quotation/pages/add_quotation_item_page.dart';
import 'package:nhapp/pages/leads/models/lead_data.dart';
import 'package:nhapp/pages/leads/models/lead_detail_data.dart';
import 'package:nhapp/utils/storage_utils.dart';
import 'package:nhapp/toast.dart';

class AddQuotationPage extends StatefulWidget {
  final LeadData? leadData;
  final LeadDetailData? leadDetailData;

  const AddQuotationPage({super.key, this.leadData, this.leadDetailData});

  @override
  State<AddQuotationPage> createState() => _AddQuotationPageState();
}

class _AddQuotationPageState extends State<AddQuotationPage> {
  final _formKey = GlobalKey<FormState>();
  late final QuotationFormService _service;

  // Form fields
  List<QuotationBase> _quotationBases = [];
  QuotationBase? _selectedQuotationBase;

  QuotationCustomer? _selectedQuoteTo;
  QuotationCustomer? _selectedBillTo;
  final TextEditingController _quoteToController = TextEditingController();
  final TextEditingController _billToController = TextEditingController();

  List<Salesman> _salesmen = [];
  Salesman? _selectedSalesman;

  final TextEditingController _subjectToController = TextEditingController();

  // Lead Number: Shown only if the selected quotation base requires inquiry.
  String? _selectedLeadNumber;
  List<String> _leadNumbers = [];

  DateTime _date = DateTime.now();
  DateTime? _minDate;
  DateTime? _maxDate;
  String? _year;
  int? _siteId;
  int? _userId;

  final List<Map<String, dynamic>> _items = [];
  final List<PlatformFile> _attachments = [];

  bool _loading = true;
  bool _submitting = false;

  // Determine if the selected quotation base requires a Lead Number.
  bool get _isInquiryReference =>
      _selectedQuotationBase != null &&
      _selectedQuotationBase!.name.toLowerCase().contains('inquiry');

  @override
  void initState() {
    super.initState();
    _service = QuotationFormService();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _loading = true);
    try {
      // 1. Fetch current year date range.
      final dateRange = await _service.fetchDateRange();
      _minDate =
          dateRange["periodSDt"] != null
              ? DateTime.parse(dateRange["periodSDt"])
              : DateTime.now();
      _maxDate =
          dateRange["periodEDt"] != null
              ? DateTime.parse(dateRange["periodEDt"])
              : DateTime.now();
      _year = dateRange["financialYear"] ?? "";
      _siteId = dateRange["siteId"] ?? 0;

      // Get user ID from storage
      final userDetails = await StorageUtils.readJson('user_details');
      _userId = userDetails?['id'] ?? 0;

      // 2. Fetch default document details.
      final docDetail = await _service.fetchDefaultDocDetail(year: _year!);
      await StorageUtils.writeJson("docDetail", docDetail);

      // 3. Load dropdown data.
      final bases = await _service.fetchQuotationBases();
      final salesmen = await _service.fetchSalesmen();

      setState(() {
        _quotationBases = bases;
        _salesmen = salesmen;
        _date = DateTime.now();
        if (_date.isBefore(_minDate!)) _date = _minDate!;
        if (_date.isAfter(_maxDate!)) _date = _maxDate!;
        _loading = false;
      });

      // 4. Prefill data if coming from lead
      if (widget.leadData != null && widget.leadDetailData != null) {
        _prefillFromLead();
      }
    } catch (e) {
      setState(() => _loading = false);
      showToast('Error loading data: $e');
    }
  }

  void _prefillFromLead() {
    if (widget.leadData == null || widget.leadDetailData == null) return;

    final lead = widget.leadData!;
    final detail = widget.leadDetailData!;

    // Set quotation base to "With Inquiry Reference" if available
    final inquiryBase = _quotationBases.firstWhere(
      (base) => base.name.toLowerCase().contains('inquiry'),
      orElse:
          () =>
              _quotationBases.isNotEmpty
                  ? _quotationBases.first
                  : QuotationBase(code: '', name: ''),
    );
    if (inquiryBase.code.isNotEmpty) {
      setState(() {
        _selectedQuotationBase = inquiryBase;
      });
    }

    // Prefill customer data
    final customer = QuotationCustomer(
      customerCode: lead.customerCode,
      customerName: lead.customerName,
      customerFullName: '${lead.customerCode} - ${lead.customerName}',
    );

    setState(() {
      _selectedQuoteTo = customer;
      _selectedBillTo = customer;
      _quoteToController.text = customer.customerFullName;
      _billToController.text = customer.customerFullName;
    });

    // Prefill salesman
    final salesman = _salesmen.firstWhere(
      (s) => s.salesmanCode == lead.salesmanCode,
      orElse:
          () => Salesman(
            salesmanCode: '',
            salesmanName: '',
            salesManFullName: '',
          ),
    );
    if (salesman.salesmanCode.isNotEmpty) {
      setState(() {
        _selectedSalesman = salesman;
      });
    }

    // Set lead number
    setState(() {
      _selectedLeadNumber = lead.inquiryNumber;
      _leadNumbers = [lead.inquiryNumber];
    });

    // Prefill subject
    _subjectToController.text = 'Quotation for Inquiry ${lead.inquiryNumber}';

    // Prefill items from lead detail
    final leadItems =
        detail.inqEntryItemModel
            .map(
              (item) => {
                'itemCode': item.salesItemCode,
                'itemName': item.itemName,
                'qty': item.itemQty,
                'uom': item.uom,
                'rate': item.basicPrice,
                'discountType': 'None',
                'discountValue': 0.0,
                'rateStructure': '',
                'basicAmount': item.itemQty * item.basicPrice,
                'discountAmount': 0.0,
                'taxAmount': 0.0,
                'totalAmount': item.itemQty * item.basicPrice,
              },
            )
            .toList();

    setState(() {
      _items.addAll(leadItems);
    });
  }

  /// Load Lead Numbers based on selected Bill To.
  Future<void> _loadLeadNumbers() async {
    if (!_isInquiryReference || _selectedBillTo == null) return;

    try {
      final leads = await _service.fetchLeadNumbers(
        customerCode: _selectedBillTo!.customerCode,
      );
      setState(() {
        _leadNumbers = leads;
        _selectedLeadNumber = null; // Reset selection
      });
    } catch (e) {
      showToast('Error fetching lead numbers: $e');
    }
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _attachments.addAll(result.files);
      });
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  void _addItem(Map<String, dynamic> item) {
    setState(() {
      _items.add(item);
    });
  }

  void _editItem(int index, Map<String, dynamic> item) {
    setState(() {
      _items[index] = item;
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _openAddItem() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddQuotationItemPage()),
    );
    if (result != null) _addItem(result);
  }

  void _openEditItem(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddQuotationItemPage(initialItem: _items[index]),
      ),
    );
    if (result != null) {
      _editItem(index, result);
    }
  }

  Map<String, double> getTotals() {
    double basic = 0, discount = 0, tax = 0, total = 0;
    for (final item in _items) {
      basic += (item['basicAmount'] ?? 0) as double;
      tax += (item['taxAmount'] ?? 0) as double;
      total += (item['totalAmount'] ?? 0) as double;
      discount += (item['discountValue'] ?? 0) as double;
    }
    return {'basic': basic, 'discount': discount, 'tax': tax, 'total': total};
  }

  bool _validateDate() {
    if (_minDate != null && _date.isBefore(_minDate!)) {
      showToast('Date should be within the financial period');
      return false;
    }
    if (_maxDate != null && _date.isAfter(_maxDate!)) {
      showToast('Date should be within the financial period');
      return false;
    }
    if (_date.isAfter(DateTime.now())) {
      showToast('Date should not be in the future');
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      showToast('Please fill all required fields');
      return;
    }

    if (_items.isEmpty) {
      showToast('Please add at least one item');
      return;
    }

    if (!_validateDate()) {
      return;
    }

    if (_isInquiryReference && _selectedLeadNumber == null) {
      showToast('Please select a lead number');
      return;
    }

    setState(() => _submitting = true);

    try {
      final docDetail =
          await StorageUtils.readJson("docDetail") as Map<String, dynamic>?;

      if (docDetail == null || docDetail.isEmpty) {
        setState(() => _submitting = false);
        showToast('Failed to fetch document details');
        return;
      }

      final submissionData = QuotationSubmissionData(
        docDetail: docDetail,
        quoteTo: _selectedQuoteTo!,
        billTo: _selectedBillTo!,
        salesman: _selectedSalesman!,
        subject: _subjectToController.text,
        quotationDate: _date,
        quotationYear: _year!,
        siteId: _siteId!,
        userId: _userId ?? 0,
        items: _items,
      );

      final submissionResponse = await _service.submitQuotation(submissionData);

      if (submissionResponse['success'] == true) {
        final quotationData = submissionResponse['data'];
        final quotationNumber =
            quotationData?['quotationDetails']?['quotationNumber'] ??
            quotationData?['QuotationNumber'] ??
            quotationData?['quotationNumber'];

        bool attachSuccess = true;
        if (_attachments.isNotEmpty && quotationNumber != null) {
          attachSuccess = await _service.uploadAttachments(
            filePaths: _attachments.map((f) => f.path!).toList(),
            documentNo: quotationNumber.toString(),
            documentId:
                quotationData?['quotationDetails']?['quotationId']
                    ?.toString() ??
                '0',
            docYear: _year!,
            formId: '06103',
            locationCode: docDetail['locationCode'] ?? '',
            companyCode: docDetail['companyCode'] ?? '',
            locationId: docDetail['locationId'] ?? 0,
            companyId: docDetail['companyId'] ?? 1,
            userId: _userId ?? 0,
          );
        }

        setState(() => _submitting = false);

        if (attachSuccess) {
          showToast('Quotation created successfully!');
          Navigator.pop(context, true);
        } else {
          showToast('Quotation created but attachment upload failed');
          Navigator.pop(context, true);
        }
      } else {
        setState(() => _submitting = false);
        final errorMessage =
            submissionResponse['message'] ??
            submissionResponse['errorMessage'] ??
            'Failed to create quotation';
        showToast(errorMessage);
      }
    } catch (e) {
      setState(() => _submitting = false);
      showToast('Error creating quotation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final totals = getTotals();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.leadData != null
              ? 'Create Quotation from Lead'
              : 'Add Quotation',
        ),
      ),
      body: AbsorbPointer(
        absorbing: _submitting,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Show lead info if coming from lead
              if (widget.leadData != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lead Information',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text('Lead No: ${widget.leadData!.inquiryNumber}'),
                        Text(
                          'Customer: ${widget.leadData!.customerCode} - ${widget.leadData!.customerName}',
                        ),
                        Text(
                          'Salesman: ${widget.leadData!.salesmanCode} - ${widget.leadData!.salesmanName}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Quotation Base
              DropdownButtonFormField<QuotationBase>(
                decoration: const InputDecoration(
                  labelText: 'Quotation Base *',
                ),
                value: _selectedQuotationBase,
                items:
                    _quotationBases
                        .map(
                          (e) =>
                              DropdownMenuItem(value: e, child: Text(e.name)),
                        )
                        .toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedQuotationBase = v;
                    _selectedLeadNumber = null;
                    _leadNumbers.clear();
                  });
                  if (_isInquiryReference && _selectedBillTo != null) {
                    _loadLeadNumbers();
                  }
                },
                validator: (v) => v == null ? 'Select Quotation Base' : null,
              ),
              const SizedBox(height: 16),

              // Quote To (TypeAheadField)
              TypeAheadField<QuotationCustomer>(
                controller: _quoteToController,
                suggestionsCallback: (pattern) async {
                  if (pattern.length < 4) return [];
                  return await _service.searchCustomers(pattern);
                },
                builder:
                    (context, controller, focusNode) => TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Quote To *',
                      ),
                      validator:
                          (val) =>
                              (val == null || val.isEmpty)
                                  ? 'Select Quote To'
                                  : null,
                    ),
                itemBuilder:
                    (context, suggestion) =>
                        ListTile(title: Text(suggestion.customerFullName)),
                onSelected: (suggestion) {
                  setState(() {
                    _selectedQuoteTo = suggestion;
                    _quoteToController.text = suggestion.customerFullName;
                    _selectedBillTo = suggestion;
                    _billToController.text = suggestion.customerFullName;
                  });
                  if (_isInquiryReference) {
                    _loadLeadNumbers();
                  }
                },
                emptyBuilder:
                    (context) => const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Type at least 4 characters to search'),
                    ),
              ),
              const SizedBox(height: 16),

              // Bill To (TypeAheadField)
              TypeAheadField<QuotationCustomer>(
                controller: _billToController,
                suggestionsCallback: (pattern) async {
                  if (pattern.length < 4) return [];
                  return await _service.searchCustomers(pattern);
                },
                builder:
                    (context, controller, focusNode) => TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(labelText: 'Bill To *'),
                      validator:
                          (val) =>
                              (val == null || val.isEmpty)
                                  ? 'Select Bill To'
                                  : null,
                    ),
                itemBuilder:
                    (context, suggestion) =>
                        ListTile(title: Text(suggestion.customerFullName)),
                onSelected: (suggestion) {
                  setState(() {
                    _selectedBillTo = suggestion;
                    _billToController.text = suggestion.customerFullName;
                  });
                  if (_isInquiryReference) {
                    _loadLeadNumbers();
                  }
                },
                emptyBuilder:
                    (context) => const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Type at least 4 characters to search'),
                    ),
              ),
              const SizedBox(height: 16),

              // Salesman
              DropdownButtonFormField<Salesman>(
                decoration: const InputDecoration(labelText: 'Salesman *'),
                value: _selectedSalesman,
                items:
                    _salesmen
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.salesManFullName),
                          ),
                        )
                        .toList(),
                onChanged: (v) => setState(() => _selectedSalesman = v),
                validator: (v) => v == null ? 'Select Salesman' : null,
              ),
              const SizedBox(height: 16),

              // Lead Number (conditional)
              if (_isInquiryReference) ...[
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Lead Number *'),
                  value: _selectedLeadNumber,
                  items:
                      _leadNumbers
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => _selectedLeadNumber = v),
                  validator: (v) => v == null ? 'Select Lead Number' : null,
                ),
                const SizedBox(height: 16),
              ],

              // Subject To
              TextFormField(
                controller: _subjectToController,
                decoration: const InputDecoration(labelText: 'Subject To *'),
                validator:
                    (val) =>
                        (val == null || val.isEmpty) ? 'Enter Subject' : null,
              ),
              const SizedBox(height: 16),

              // Date
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date *',
                  errorText:
                      _minDate != null && _maxDate != null
                          ? 'Date should be between ${DateFormat('dd/MM/yyyy').format(_minDate!)} and ${DateFormat('dd/MM/yyyy').format(_maxDate!)}'
                          : null,
                ),
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: _minDate ?? DateTime(2000),
                      lastDate: _maxDate ?? DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _date = picked);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('dd/MM/yyyy').format(_date)),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Items Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Items', style: Theme.of(context).textTheme.titleMedium),
                  ElevatedButton.icon(
                    onPressed: _submitting ? null : _openAddItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Item'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Items List
              if (_items.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No items added yet'),
                  ),
                )
              else
                ..._items.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(item['itemName'] ?? 'Item'),
                      subtitle: Text(
                        'Code: ${item['itemCode']}\n'
                        'Qty: ${item['qty']} ${item['uom'] ?? ''}\n'
                        'Rate: ₹${(item['rate'] ?? 0).toStringAsFixed(2)}\n'
                        'Amount: ₹${(item['totalAmount'] ?? 0).toStringAsFixed(2)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed:
                                _submitting ? null : () => _openEditItem(idx),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed:
                                _submitting ? null : () => _removeItem(idx),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 16),

              // Total Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Summary',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Basic Amount:'),
                          Text(
                            '₹${totals['basic']?.toStringAsFixed(2) ?? '0.00'}',
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Discount:'),
                          Text(
                            '₹${totals['discount']?.toStringAsFixed(2) ?? '0.00'}',
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tax Amount:'),
                          Text(
                            '₹${totals['tax']?.toStringAsFixed(2) ?? '0.00'}',
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '₹${totals['total']?.toStringAsFixed(2) ?? '0.00'}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Attachments
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _submitting ? null : _pickFiles,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Add Attachment'),
                  ),
                  const SizedBox(width: 8),
                  Text('${_attachments.length} file(s) selected'),
                ],
              ),
              if (_attachments.isNotEmpty) ...[
                const SizedBox(height: 8),
                ..._attachments.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final file = entry.value;
                  return ListTile(
                    leading: const Icon(Icons.attach_file),
                    title: Text(file.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed:
                          _submitting ? null : () => _removeAttachment(idx),
                    ),
                  );
                }),
              ],

              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _submitting
                        ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Creating Quotation...'),
                          ],
                        )
                        : const Text('Create Quotation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
