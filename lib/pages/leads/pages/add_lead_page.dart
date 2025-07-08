import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:nhapp/utils/format_utils.dart';
import 'package:nhapp/utils/storage_utils.dart';
import '../models/lead_form.dart';
import '../services/lead_form_service.dart';

class AddLeadPage extends StatefulWidget {
  const AddLeadPage({super.key});
  @override
  State<AddLeadPage> createState() => _AddLeadPageState();
}

class _AddLeadPageState extends State<AddLeadPage> {
  final _formKey = GlobalKey<FormState>();
  final LeadFormService _service = LeadFormService();

  DateTime? _leadDate;
  DateTime? _minDate;
  DateTime? _maxDate;
  String? _year;
  int? _siteId;
  int? _userId;
  late bool _isDuplicateItem;

  CustomerModel? _selectedCustomer;
  SourceModel? _selectedSource;
  SalesmanModel? _selectedSalesman;
  RegionModel? _selectedRegion;

  Map<String, dynamic> _companyDetails = {};
  Map<String, dynamic> _locationDetails = {};
  Map<String, dynamic> _userDetails = {};

  late final List<SourceModel> _sources = [];
  late final List<SalesmanModel> _salesmen = [];
  late final List<RegionModel> _regions = [];
  final List<LeadItemEntry> _items = [];
  final List<PlatformFile> _attachments = [];

  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _leadNumberController = TextEditingController();
  final TextEditingController _salesItemController = TextEditingController();

  bool _loading = true;
  bool _submitting = false;

  String? _customerError;
  String? _sourceError;
  String? _salesmanError;
  String? _regionError;
  String? _itemError;
  String? _leadDateError;
  String? _leadNumberError;

  bool? _isAutoNumberGenerated;
  String? _leadNumber;
  bool _leadNumberChecking = false;
  String? _groupCode;
  String? _locationCode;

  String? _documentNo;
  String? _documentId;

  @override
  void initState() {
    super.initState();
    _customerController.addListener(() {
      if (_customerController.text != _selectedCustomer?.customerFullName) {
        setState(() {
          _selectedCustomer = null;
          _customerError = null;
        });
      }
    });
    _leadNumberController.addListener(() {
      if (_leadNumberController.text != _leadNumber) {
        setState(() {
          _leadNumber = _leadNumberController.text.toUpperCase();
          _leadNumberError = null;
        });
      }
    });
    _loadDropdowns();
  }

  Future<void> _loadDropdowns() async {
    setState(() => _loading = true);
    _companyDetails = await StorageUtils.readJson('selected_company');
    _locationDetails = await StorageUtils.readJson('selected_location');
    final tokenDetails = await StorageUtils.readJson('session_token');
    _userDetails = tokenDetails['user'] ?? {};
    int siteId = _locationDetails['id'];
    final dateRange = await _service.fetchDateRange(siteId);
    final minDate =
        dateRange['periodSDt'] != null
            ? DateTime.parse(dateRange['periodSDt'])
            : DateTime.now();
    final maxDate =
        dateRange['periodEDt'] != null
            ? DateTime.parse(dateRange['periodEDt'])
            : DateTime.now();
    final year = dateRange['financialYear'] ?? '';
    final docDetail = await _service.fetchDefaultDocDetail(
      year: year,
      locationId: siteId,
    );
    final isAutoNumberGenerated = docDetail['isAutoNumberGenerated'] == true;
    final groupCode = docDetail['groupCode'] ?? '';
    final locationCode = docDetail['locationCode'] ?? '';
    final sources = await _service.fetchSources();
    final salesmen = await _service.fetchSalesmen();
    final regions = await _service.fetchRegions();
    final salesPolicy = await _service.getSalesPolicy();
    _isDuplicateItem =
        salesPolicy['allowduplictae'] ?? salesPolicy['allowduplicate'] ?? false;

    setState(() {
      _leadDate = DateTime.now();
      _minDate = minDate;
      _maxDate = maxDate;
      _year = year;
      _siteId = siteId;
      _userId =
          _userDetails['id']; // Replace with your actual user id from storage/session
      _isAutoNumberGenerated = isAutoNumberGenerated;
      _groupCode = groupCode;
      _locationCode = locationCode;
      _sources.clear();
      _sources.addAll(sources);
      _salesmen.clear();
      _salesmen.addAll(salesmen);
      _regions.clear();
      _regions.addAll(regions);
      _loading = false;
    });
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

  void _addItem(SalesItemModel item) {
    setState(() {
      _items.add(LeadItemEntry(item: item, qty: 1, rate: 0));
      _itemError = null;
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  bool _validateItems() {
    if (_items.isEmpty) {
      setState(() => _itemError = 'Add at least one item');
      return false;
    }
    for (final item in _items) {
      if (item.qty <= 0) {
        setState(() => _itemError = 'Quantity must be greater than 0');
        return false;
      }
      if (item.rate <= 0) {
        setState(() => _itemError = 'Rate must be greater than 0');
        return false;
      }
    }
    setState(() => _itemError = null);
    return true;
  }

  bool _validateAll() {
    bool valid = true;
    setState(() {
      _customerError = _selectedCustomer == null ? 'Select a customer' : null;
      _sourceError = _selectedSource == null ? 'Select a source' : null;
      _salesmanError = _selectedSalesman == null ? 'Select a salesman' : null;
      _regionError = _selectedRegion == null ? 'Select a region' : null;
      _leadDateError = null;
      if (_leadDate == null ||
          _leadDate!.isBefore(_minDate!) ||
          _leadDate!.isAfter(_maxDate!.add(Duration(days: 1)))) {
        _leadDateError =
            'Lead date must be between ${FormatUtils.formatDateForUser(_minDate!)} and ${FormatUtils.formatDateForUser(_maxDate!)}';
        valid = false;
      }
      if (_isAutoNumberGenerated == false) {
        if (_leadNumber == null || _leadNumber!.length != 6) {
          _leadNumberError = 'Enter a 6-character Lead Number';
          valid = false;
        } else if (_leadNumberError != null) {
          valid = false;
        }
      }
    });
    if (_customerError != null ||
        _sourceError != null ||
        _salesmanError != null ||
        _regionError != null ||
        _leadDateError != null ||
        _leadNumberError != null) {
      valid = false;
    }
    if (!_validateItems()) valid = false;
    return valid;
  }

  Future<bool> _checkLeadNumberExists(String number) async {
    if (_year == null || _groupCode == null || _siteId == null) return false;
    setState(() => _leadNumberChecking = true);
    final exists = await _service.verifyLeadNumber(
      year: _year!,
      group: _groupCode!,
      site: _siteId!,
      number: number,
    );
    setState(() => _leadNumberChecking = false);
    return exists;
  }

  Future<void> _onLeadNumberUnfocus() async {
    if (_leadNumber != null && _leadNumber!.length == 6) {
      final exists = await _checkLeadNumberExists(_leadNumber!);
      setState(() {
        _leadNumberError = exists ? 'Lead Number already exists' : null;
      });
    }
  }

  Future<void> _submit() async {
    if (!_validateAll()) return;
    setState(() => _submitting = true);

    // Check lead number existence if not auto-generated
    if (_isAutoNumberGenerated == false) {
      if (_leadNumber == null || _leadNumber!.length != 6) {
        setState(() => _leadNumberError = 'Enter a 6-character Lead Number');
        setState(() => _submitting = false);
        return;
      }
      final exists = await _checkLeadNumberExists(_leadNumber!);
      if (exists) {
        setState(() => _leadNumberError = 'Lead Number already exists');
        setState(() => _submitting = false);
        return;
      }
    }

    // 1. Fetch docDetail for required fields
    final docDetail = await _service.fetchDefaultDocDetail(
      year: _year!,
      locationId: _siteId!,
    );
    final isLocationRequired = docDetail['isLocationRequired'] ?? false;
    final isAutorisationRequired = docDetail['isAutorisationRequired'];
    final isAutoNumberGenerated = docDetail['isAutoNumberGenerated'];
    final locationCode = docDetail['locationCode'];
    final groupCode = docDetail['groupCode'];
    final groupFullName = docDetail['groupFullName'];
    final locationFullName = docDetail['locationFullName'];
    final companyCode = docDetail['companyCode'] ?? '';
    final formId = docDetail['formId'] ?? '06100';

    // 2. First stage: Create lead entry and get document number/id
    final docResult = await _service.createLeadEntryAndGetDoc(
      customer: _selectedCustomer!,
      source: _selectedSource!,
      salesman: _selectedSalesman!,
      region: _selectedRegion!,
      leadDate: _leadDate!,
      items: _items,
      siteId: _siteId!,
      year: _year!,
      userId: _userId!,
      locationCode: locationCode,
      isAutorisationRequired: isAutorisationRequired,
      isAutoNumberGenerated: isAutoNumberGenerated,
      isLocationRequired: isLocationRequired,
      groupCode: groupCode,
      groupFullName: groupFullName,
      locationFullName: locationFullName,
      leadNumber: _isAutoNumberGenerated == false ? _leadNumber : null,
    );

    if (!mounted) return;
    if (docResult.isEmpty ||
        docResult['documentNo'] == null ||
        docResult['documentId'] == null) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create lead entry')),
      );
      return;
    }

    _documentNo = docResult['documentNo'];
    _documentId = docResult['documentId'];

    // 3. Second stage: Upload attachments (if any)
    bool attachSuccess = true;
    if (_attachments.isNotEmpty) {
      attachSuccess = await _service.uploadAttachments(
        filePaths: _attachments.map((f) => f.path!).toList(),
        documentNo: _documentNo!,
        documentId: _documentId!,
        docYear: _year!,
        formId: formId,
        locationCode: locationCode,
        companyCode: companyCode,
        locationId: _siteId!,
        companyId: _companyDetails['id'],
        userId: _userId!,
      );
    }
    if (!mounted) return;
    setState(() => _submitting = false);

    if (attachSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lead created successfully!')),
      );
      // Navigator.of(context).pop(true); // refresh list
      // return;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lead created, but attachment upload failed'),
        ),
      );
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    DateTime initialDate = _leadDate!;
    if (initialDate.isAfter(_maxDate!)) initialDate = _maxDate!;
    if (initialDate.isBefore(_minDate!)) initialDate = _minDate!;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Lead')),
      body: AbsorbPointer(
        absorbing: _submitting,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Lead Date
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: _minDate!,
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _leadDate = picked;
                      _leadDateError = null;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Lead Date',
                    errorText: _leadDateError,
                    suffixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(FormatUtils.formatDateForUser(_leadDate!)),
                ),
              ),
              const SizedBox(height: 16),

              // Lead Number (conditional)
              if (_isAutoNumberGenerated == false)
                Focus(
                  onFocusChange: (hasFocus) async {
                    if (!hasFocus &&
                        _leadNumber != null &&
                        _leadNumber!.length == 6) {
                      await _onLeadNumberUnfocus();
                    }
                  },
                  child: TextFormField(
                    controller: _leadNumberController,
                    enabled: true,
                    maxLength: 6,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: 'Lead Number',
                      errorText: _leadNumberError,
                      counterText: '',
                      suffixIcon:
                          _leadNumberChecking
                              ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                              : Icon(Icons.search_rounded),
                    ),
                    onChanged: (val) {
                      final upper = val.toUpperCase();
                      if (val != upper) {
                        _leadNumberController.value = _leadNumberController
                            .value
                            .copyWith(
                              text: upper,
                              selection: TextSelection.collapsed(
                                offset: upper.length,
                              ),
                            );
                      }
                      setState(() {
                        _leadNumber = upper;
                        _leadNumberError = null;
                      });
                    },
                  ),
                ),
              const SizedBox(height: 16),
              // Customer Name (Typeahead)
              TypeAheadField<CustomerModel>(
                controller: _customerController,
                builder:
                    (context, controller, focusNode) => TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Customer Name',
                        errorText: _customerError,
                        suffixIcon: const Icon(Icons.search_rounded),
                      ),
                      enabled: !_submitting,
                      onTapOutside: (event) {
                        FocusScope.of(context).unfocus();
                      },
                      onChanged: (val) {
                        if (_customerError != null && val.isNotEmpty) {
                          setState(() => _customerError = null);
                        }
                      },
                    ),
                suggestionsCallback: (pattern) async {
                  if (pattern.length < 4) {
                    return [];
                  }
                  return await _service.searchCustomers(pattern);
                },
                itemBuilder:
                    (context, suggestion) =>
                        ListTile(title: Text(suggestion.customerFullName)),
                onSelected: (suggestion) {
                  setState(() {
                    _selectedCustomer = suggestion;
                    _customerError = null;
                  });
                  _customerController.text = suggestion.customerFullName;
                },
                emptyBuilder: (context) => const SizedBox(),
              ),
              const SizedBox(height: 16),

              // Source of Lead
              DropdownButtonFormField<SourceModel>(
                decoration: InputDecoration(
                  labelText: 'Source of Lead',
                  errorText: _sourceError,
                ),
                value: _selectedSource,
                items:
                    _sources
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.codeFullName),
                          ),
                        )
                        .toList(),
                onChanged:
                    _submitting
                        ? null
                        : (v) => setState(() {
                          _selectedSource = v;
                          if (_sourceError != null && v != null) {
                            _sourceError = null;
                          }
                        }),
                validator: (_) => null,
                autovalidateMode: AutovalidateMode.disabled,
              ),
              const SizedBox(height: 16),

              // Salesman
              DropdownButtonFormField<SalesmanModel>(
                decoration: InputDecoration(
                  labelText: 'Salesman',
                  errorText: _salesmanError,
                ),
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
                onChanged:
                    _submitting
                        ? null
                        : (v) => setState(() {
                          _selectedSalesman = v;
                          if (_salesmanError != null && v != null) {
                            _salesmanError = null;
                          }
                        }),
                validator: (_) => null,
                autovalidateMode: AutovalidateMode.disabled,
              ),
              const SizedBox(height: 16),

              // Sales Region
              DropdownButtonFormField<RegionModel>(
                decoration: InputDecoration(
                  labelText: 'Sales Region',
                  errorText: _regionError,
                ),
                value: _selectedRegion,
                items:
                    _regions
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.codeFullName),
                          ),
                        )
                        .toList(),
                onChanged:
                    _submitting
                        ? null
                        : (v) => setState(() {
                          _selectedRegion = v;
                          if (_regionError != null && v != null) {
                            _regionError = null;
                          }
                        }),
                validator: (_) => null,
                autovalidateMode: AutovalidateMode.disabled,
              ),
              const SizedBox(height: 16),

              // Sales Item (Typeahead)
              TypeAheadField<SalesItemModel>(
                controller: _salesItemController,
                direction: VerticalDirection.up,
                builder:
                    (context, controller, focusNode) => TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Sales Item',
                        suffixIcon: Icon(Icons.search_rounded),
                      ),
                      // onTapOutside: (event) {
                      //   FocusScope.of(context).unfocus();
                      // },
                      enabled: !_submitting,
                    ),
                suggestionsCallback: (pattern) async {
                  if (pattern.length < 4) return [];

                  final allItems = await _service.searchSalesItems(pattern);

                  if (!_isDuplicateItem) {
                    // Filter out items that are already added
                    final addedItemCodes =
                        _items.map((entry) => entry.item.itemCode).toSet();
                    return allItems
                        .where(
                          (item) => !addedItemCodes.contains(item.itemCode),
                        )
                        .toList();
                  }

                  return allItems;
                },
                itemBuilder:
                    (context, suggestion) =>
                        ListTile(title: Text(suggestion.salesItemFullName)),
                onSelected: (suggestion) {
                  _addItem(suggestion);
                  _salesItemController.clear();
                  FocusScope.of(context).unfocus();
                },
                emptyBuilder: (context) => const SizedBox(),
              ),
              const SizedBox(height: 8),

              // Items List
              if (_itemError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _itemError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ..._items.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.item.itemName,
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: item.qty.toString(),
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Qty',
                                    ),
                                    onChanged:
                                        (v) => setState(
                                          () =>
                                              item.qty =
                                                  double.tryParse(v) ?? 0,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: item.item.salesUOM,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: 'UOM',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: item.rate.toString(),
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Rate',
                                    ),
                                    onChanged:
                                        (v) => setState(
                                          () =>
                                              item.rate =
                                                  double.tryParse(v) ?? 0,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => _removeItem(idx),
                        ),
                      ),
                    ],
                  ),
                );
              }),

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
              ..._attachments.asMap().entries.map((entry) {
                final idx = entry.key;
                final file = entry.value;
                return ListTile(
                  title: Text(file.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed:
                        _submitting ? null : () => _removeAttachment(idx),
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child:
                    _submitting
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
