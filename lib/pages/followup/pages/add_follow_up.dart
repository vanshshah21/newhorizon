import 'dart:async';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:nhapp/utils/format_utils.dart';
import 'package:nhapp/utils/storage_utils.dart';

class AddFollowUpForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const AddFollowUpForm({super.key, this.initialData});

  @override
  State<AddFollowUpForm> createState() => _AddFollowUpFormState();
}

class _AddFollowUpFormState extends State<AddFollowUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _dio = Dio();

  // Controllers
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _nextFollowUpAgendaController =
      TextEditingController();

  final FocusNode _customerFocusNode = FocusNode();

  // Dropdown data
  List<Map<String, dynamic>> followUpBaseList = [];
  List<Map<String, dynamic>> salesmanList = [];
  List<Map<String, dynamic>> methodList = [];
  List<Map<String, dynamic>> leadNumberList = [];
  List<Map<String, dynamic>> quotationNumberList = [];

  // Selected values
  String? selectedFollowUpBase;
  Map<String, dynamic>? selectedCustomer;
  Map<String, dynamic>? selectedLeadNumber;
  Map<String, dynamic>? selectedQuotationNumber;
  DateTime? followUpDate;
  DateTime? expectedDate;
  TimeOfDay? followUpTime;
  Map<String, dynamic>? selectedSalesman;
  Map<String, dynamic>? selectedMethod;
  Map<String, dynamic>? selectedNextSalesman;
  DateTime? nextFollowUpDate;
  List<PlatformFile> attachments = [];

  // Finance period
  DateTime? periodSDt;
  DateTime? periodEDt;

  // Loading states
  bool isSubmitting = false;
  bool isLoadingLeadQuotation = false;
  bool isLoading = true;

  String? baseUrl;
  Map<String, dynamic>? financePeriod;
  Map<String, dynamic>? companyData;
  Map<String, dynamic>? tokenData;
  Map<String, dynamic>? locationData;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _customerController.dispose();
    _remarksController.dispose();
    _nextFollowUpAgendaController.dispose();
    _customerFocusNode.dispose();
    super.dispose();
  }

  // --- Date Initializer Fix ---
  DateTime getInitialFollowUpDate() {
    final now = DateTime.now();
    if (periodSDt != null && periodEDt != null) {
      if (now.isBefore(periodSDt!)) {
        return periodSDt!;
      } else if (now.isAfter(periodEDt!)) {
        return periodEDt!;
      } else {
        return now;
      }
    }
    return now;
  }

  String _formatTimeOfDay24(TimeOfDay? time) {
    if (time == null) return "";
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute:00"; // or "$hour:$minute" if seconds are not needed
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() => isLoading = true);

      baseUrl = await StorageUtils.readValue('url');
      financePeriod = await StorageUtils.readJson('finance_period');
      companyData = await StorageUtils.readJson("selected_company");
      tokenData = await StorageUtils.readJson("session_token");
      locationData = await StorageUtils.readJson("selected_location");

      await Future.wait([
        _fetchFollowUpBaseList(),
        _fetchSalesmanList(),
        _fetchMethodList(),
        _loadFinancePeriod(),
      ]);

      if (widget.initialData != null) {
        _prefillData();
      }

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  void _prefillData() {
    final data = widget.initialData!;

    // Set follow-up base to Inquiry
    selectedFollowUpBase = 'I';

    // Set customer data
    if (data['customerCode'] != null && data['customerName'] != null) {
      selectedCustomer = {
        'customerCode': data['customerCode'],
        'customerFullName': data['customerName'],
        'telephoneNo': data['telephoneNo'] ?? '',
      };
      _customerController.text = data['customerName'];
    }

    // Set salesman if available
    if (data['salesmanCode'] != null && data['salesmanName'] != null) {
      // Find matching salesman in the list
      final matchingSalesman = salesmanList.firstWhere(
        (s) => s['salesmanCode'] == data['salesmanCode'],
        orElse: () => {},
      );
      if (matchingSalesman.isNotEmpty) {
        selectedSalesman = matchingSalesman;
      }
    }

    if (selectedCustomer != null) {
      _fetchLeadOrQuotationNumbers().then((_) {
        // After fetching, set the lead number if available
        if (data['inquiryNumber'] != null) {
          final matchingLead = leadNumberList.firstWhere(
            (item) => item['number'] == data['inquiryNumber'],
            orElse: () => {},
          );
          if (matchingLead.isNotEmpty) {
            setState(() {
              selectedLeadNumber = matchingLead;
            });
          }
        }
      });
    }

    // if (data['inquiryNumber'] != null) {
    //   // Set lead number if available
    //   selectedLeadNumber = leadNumberList.firstWhere(
    //     (l) => l['number'] == data['inquiryNumber'],
    //     orElse: () => {},
    //   );
    // }
  }

  Future<void> _fetchFollowUpBaseList() async {
    try {
      final companyId = companyData?['id'];
      final token = tokenData?['token']['value'];

      _dio.options.headers['accept'] = 'application/json';
      _dio.options.headers['Content-Type'] = 'application/json';
      _dio.options.headers['CompanyId'] = companyId;
      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.get(
        'http://$baseUrl/api/Followup/FollowUpBaseList',
      );
      final data = List<Map<String, dynamic>>.from(response.data['data']);
      // Only Inquiry, Quotation, Other
      followUpBaseList =
          data
              .where(
                (e) =>
                    e['Name'] == 'Inquiry Base' ||
                    e['Name'] == 'Quotation Base' ||
                    e['Name'] == 'Other',
              )
              .toList();
    } catch (e) {
      debugPrint('Error fetching follow up base list: $e');
      rethrow;
    }
  }

  Future<void> _fetchSalesmanList() async {
    try {
      final companyId = companyData?['id'];
      final token = tokenData?['token']['value'];

      _dio.options.headers['accept'] = 'application/json';
      _dio.options.headers['Content-Type'] = 'application/json';
      _dio.options.headers['CompanyId'] = companyId;
      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.get(
        'http://$baseUrl/api/Followup/FollowUpSalesManList',
      );
      salesmanList = List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      debugPrint('Error fetching salesman list: $e');
      rethrow;
    }
  }

  Future<void> _fetchMethodList() async {
    try {
      final companyId = companyData?['id'];
      final token = tokenData?['token']['value'];

      _dio.options.headers['accept'] = 'application/json';
      _dio.options.headers['Content-Type'] = 'application/json';
      _dio.options.headers['CompanyId'] = companyId;
      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.get(
        'http://$baseUrl/api/Followup/FollowUpMethodofContact',
        queryParameters: {'codeType': 'MF', 'codeValue': 'GEN'},
      );
      methodList = List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      debugPrint('Error fetching method list: $e');
      rethrow;
    }
  }

  Future<void> _loadFinancePeriod() async {
    try {
      final periodData = await StorageUtils.readJson('finance_period');
      if (periodData != null) {
        periodSDt = DateTime.parse(periodData['periodSDt']);
        periodEDt = DateTime.parse(periodData['periodEDt']);
        followUpDate = getInitialFollowUpDate();
      }
    } catch (e) {
      debugPrint('Error loading finance period: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchCustomerSuggestions(
    String pattern,
  ) async {
    if (pattern.length < 4) return [];
    try {
      final companyId = companyData?['id'];
      final token = tokenData?['token']['value'];

      _dio.options.headers['accept'] = 'application/json';
      _dio.options.headers['Content-Type'] = 'application/json';
      _dio.options.headers['CompanyId'] = companyId;
      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.post(
        'http://$baseUrl/api/Followup/FollowUpGetCustomer',
        data: {
          "pageNumber": 1,
          "pageSize": 10,
          "sortField": "",
          "sortDirection": "",
          "searchValue": pattern,
          "restcoresalestrans": "false",
        },
      );
      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      debugPrint('Error fetching customer suggestions: $e');
      return [];
    }
  }

  Future<void> _fetchLeadOrQuotationNumbers() async {
    if (selectedFollowUpBase == null || selectedCustomer == null) return;

    try {
      setState(() {
        isLoadingLeadQuotation = true;
        leadNumberList = [];
        quotationNumberList = [];
        selectedLeadNumber = null;
        selectedQuotationNumber = null;
      });

      final custCode = selectedCustomer!['customerCode'];

      final companyId = companyData?['id'];
      final token = tokenData?['token']['value'];

      _dio.options.headers['accept'] = 'application/json';
      _dio.options.headers['Content-Type'] = 'application/json';
      _dio.options.headers['CompanyId'] = companyId;
      _dio.options.headers['Authorization'] = 'Bearer $token';

      if (selectedFollowUpBase == 'I') {
        // Inquiry Base
        final response = await _dio.get(
          'http://$baseUrl/api/Followup/FollowUpEntryGetInquiryNumber',
          queryParameters: {
            'followUpd': 'Inquiry Base',
            'functionName': 'Number',
            'custCode': custCode,
          },
        );
        final data = response.data['data']['inquiryBaseList']['numberList'];
        leadNumberList = List<Map<String, dynamic>>.from(data ?? []);
      } else if (selectedFollowUpBase == 'Q') {
        // Quotation Base
        final response = await _dio.get(
          'http://$baseUrl/api/Followup/FollowUpEntryGetQuotationNumber',
          queryParameters: {
            'followUpd': 'Quotation Base',
            'functionName': 'Number',
            'custCode': custCode,
          },
        );
        final data = response.data['data']['quatationBaseList']['numberList'];
        quotationNumberList = List<Map<String, dynamic>>.from(data ?? []);
      }
    } catch (e) {
      debugPrint('Error fetching lead/quotation numbers: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading numbers: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => isLoadingLeadQuotation = false);
      }
    }
  }

  // --- UI BUILDERS ---

  Widget _buildFollowUpBaseDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Follow Up Base *',
        border: OutlineInputBorder(),
      ),
      value: selectedFollowUpBase,
      items:
          followUpBaseList
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e['Code'] as String,
                  child: Text(e['Name'] as String),
                ),
              )
              .toList(),
      onChanged:
          widget.initialData != null
              ? null // This disables the dropdown
              : (val) {
                setState(() {
                  selectedFollowUpBase = val;
                  selectedLeadNumber = null;
                  selectedQuotationNumber = null;
                  leadNumberList = [];
                  quotationNumberList = [];
                });
                _fetchLeadOrQuotationNumbers();
              },
      validator: (val) => val == null ? 'Required' : null,
    );
  }

  // Widget _buildCustomerTypeAhead() {
  //   return TypeAheadField<Map<String, dynamic>>(
  //     controller: _customerController,
  //     builder:
  //         (context, controller, focusNode) => TextField(
  //           controller: controller,
  //           focusNode: focusNode,
  //           decoration: const InputDecoration(
  //             labelText: 'Customer Name *',
  //             border: OutlineInputBorder(),
  //           ),
  //         ),
  //     suggestionsCallback: (pattern) async {
  //       return await fetchCustomerSuggestions(pattern);
  //     },
  //     itemBuilder:
  //         (context, suggestion) => ListTile(
  //           title: Text(suggestion['customerFullName']),
  //           subtitle: Text(suggestion['telephoneNo'] ?? ''),
  //         ),
  //     onSelected: (suggestion) {
  //       setState(() {
  //         selectedCustomer = suggestion;
  //         _customerController.text = suggestion['customerFullName'];
  //       });
  //       _fetchLeadOrQuotationNumbers();
  //     },
  //     decorationBuilder:
  //         (context, child) => Material(
  //           elevation: 4,
  //           borderRadius: BorderRadius.circular(8),
  //           child: child,
  //         ),
  //     emptyBuilder:
  //         (context) => const ListTile(title: Text('No customer found')),
  //   );
  // }
  Widget _buildCustomerTypeAhead() {
    return TypeAheadField<Map<String, dynamic>>(
      controller: _customerController,
      showOnFocus: widget.initialData != null ? false : true,
      focusNode: _customerFocusNode, // Add the focus node here
      builder:
          (context, controller, focusNode) => TextField(
            readOnly: widget.initialData != null ? true : false,
            controller: controller,
            focusNode: focusNode,
            decoration: const InputDecoration(
              labelText: 'Customer Name *',
              border: OutlineInputBorder(),
            ),
          ),
      suggestionsCallback: (pattern) async {
        return await fetchCustomerSuggestions(pattern);
      },
      itemBuilder:
          (context, suggestion) => ListTile(
            title: Text(suggestion['customerFullName']),
            subtitle: Text(suggestion['telephoneNo'] ?? ''),
          ),
      onSelected: (suggestion) {
        setState(() {
          selectedCustomer = suggestion;
          _customerController.text = suggestion['customerFullName'];
        });
        _fetchLeadOrQuotationNumbers();
      },
      decorationBuilder:
          (context, child) => Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: child,
          ),
      emptyBuilder:
          (context) => const ListTile(title: Text('No customer found')),
    );
  }

  Widget _buildLeadOrQuotationDropdown() {
    if (selectedFollowUpBase == 'I') {
      // Inquiry Base
      return isLoadingLeadQuotation
          ? const Center(child: CircularProgressIndicator())
          : DropdownButtonFormField<Map<String, dynamic>>(
            decoration: const InputDecoration(
              labelText: 'Lead Number *',
              border: OutlineInputBorder(),
            ),
            value: selectedLeadNumber,
            items:
                leadNumberList
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e['number'],
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    )
                    .toList(),
            onChanged:
                widget.initialData != null
                    ? null
                    : (val) {
                      setState(() {
                        selectedLeadNumber = val;
                      });
                    },
            validator:
                (val) =>
                    selectedFollowUpBase == 'I' && val == null
                        ? 'Lead Number is required'
                        : null,
          );
    } else if (selectedFollowUpBase == 'Q') {
      // Quotation Base
      return isLoadingLeadQuotation
          ? const Center(child: CircularProgressIndicator())
          : DropdownButtonFormField<Map<String, dynamic>>(
            decoration: const InputDecoration(
              labelText: 'Quotation Number *',
              border: OutlineInputBorder(),
            ),
            value: selectedQuotationNumber,
            items:
                quotationNumberList
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e, child: Text(e['number'])),
                    )
                    .toList(),
            onChanged: (val) {
              setState(() {
                selectedQuotationNumber = val;
              });
            },
            validator:
                (val) =>
                    selectedFollowUpBase == 'Q' && val == null
                        ? 'Quotation Number is required'
                        : null,
          );
    }
    return const SizedBox.shrink();
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
    DateTime? firstDate,
    DateTime? lastDate,
    bool required = false,
  }) {
    return InkWell(
      onTap: () async {
        // Unfocus any text fields (e.g., TypeAheadField) so that they do not
        // capture focus after the calendar closes
        _customerFocusNode.unfocus();
        FocusScope.of(context).unfocus();
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? getInitialFollowUpDate(),
          firstDate: firstDate ?? DateTime(2000),
          lastDate: lastDate ?? DateTime(2100),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value != null ? FormatUtils.formatDateForUser(value) : 'Select',
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay? value,
    required ValueChanged<TimeOfDay?> onChanged,
  }) {
    return InkWell(
      onTap: () async {
        // Unfocus any text fields so that focus doesn't return to an unwanted
        // widget after the time picker closes
        FocusScope.of(context).unfocus();
        final picked = await showTimePicker(
          context: context,
          initialTime: value ?? TimeOfDay.now(),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value != null ? value.format(context) : 'Select'),
            const Icon(Icons.access_time),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesmanDropdown() {
    return DropdownButtonFormField<Map<String, dynamic>>(
      decoration: const InputDecoration(
        labelText: 'Salesman *',
        border: OutlineInputBorder(),
      ),
      value: selectedSalesman,
      items:
          salesmanList
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e['salesManFullName']),
                ),
              )
              .toList(),
      onChanged: (val) {
        setState(() {
          selectedSalesman = val;
          // Remove from next salesman if same
          // if (selectedNextSalesman != null &&
          //     selectedNextSalesman!['salesmanCode'] ==
          //         selectedSalesman!['salesmanCode']) {
          //   selectedNextSalesman = null;
          // }
        });
      },
      validator: (val) => val == null ? 'Required' : null,
    );
  }

  Widget _buildMethodDropdown() {
    return DropdownButtonFormField<Map<String, dynamic>>(
      decoration: const InputDecoration(
        labelText: 'Method *',
        border: OutlineInputBorder(),
      ),
      value: selectedMethod,
      items:
          methodList
              .map(
                (e) =>
                    DropdownMenuItem(value: e, child: Text(e['codeFullName'])),
              )
              .toList(),
      onChanged: (val) {
        setState(() {
          selectedMethod = val;
        });
      },
      validator: (val) => val == null ? 'Required' : null,
    );
  }

  Widget _buildNextSalesmanDropdown() {
    final filteredList =
        salesmanList
            .where(
              (e) =>
                  selectedSalesman == null ||
                  e['salesmanCode'] != selectedSalesman!['salesmanCode'],
            )
            .toList();

    return DropdownButtonFormField<Map<String, dynamic>>(
      decoration: const InputDecoration(
        labelText: 'Next Follow Up Salesman',
        border: OutlineInputBorder(),
      ),
      value: selectedNextSalesman,
      items:
          salesmanList
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e['salesManFullName']),
                ),
              )
              .toList(),
      onChanged: (val) {
        setState(() {
          selectedNextSalesman = val;
        });
      },
    );
  }

  Widget _buildNextFollowUpAgendaField() {
    return TextFormField(
      controller: _nextFollowUpAgendaController,
      decoration: const InputDecoration(
        labelText: 'Next Follow Up Agenda',
        border: OutlineInputBorder(),
        hintText: 'Enter agenda for next follow up',
      ),
      maxLines: 2,
      textInputAction: TextInputAction.newline,
    );
  }

  Widget _buildAttachmentPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attachments (max 10MB each)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...attachments.map(
              (file) => Chip(
                label: Text(file.name),
                onDeleted: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (ctx) => AlertDialog(
                          title: const Text('Remove Attachment?'),
                          content: Text('Remove ${file.name}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                  );
                  if (confirm == true) {
                    setState(() {
                      attachments.remove(file);
                    });
                  }
                },
              ),
            ),
            ActionChip(
              label: const Text('Add Files'),
              onPressed: () async {
                // Unfocus to avoid any unwanted focus changes
                FocusScope.of(context).unfocus();
                final result = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                  withData: true,
                  type: FileType.any,
                );
                if (result != null) {
                  for (final file in result.files) {
                    if (file.size > 10 * 1024 * 1024) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${file.name} exceeds 10MB and was not added.',
                            ),
                          ),
                        );
                      }
                      continue;
                    }
                    setState(() {
                      attachments.add(file);
                    });
                  }
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  // --- SUBMISSION ---

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    try {
      final companyId = companyData?['id'];
      final token = tokenData?['token']['value'];

      _dio.options.headers['accept'] = 'application/json';
      _dio.options.headers['Content-Type'] = 'application/json';
      _dio.options.headers['CompanyId'] = companyId;
      _dio.options.headers['Authorization'] = 'Bearer $token';
      // Prepare data
      final body = {
        "NewSalesManFullName": selectedNextSalesman?['salesManFullName'] ?? "",
        "SalesManFullName": selectedSalesman?['salesManFullName'] ?? "",
        "autoId":
            selectedLeadNumber?['autoId'] ??
            selectedQuotationNumber?['autoId'] ??
            1,
        "baseOn": selectedFollowUpBase == "T" ? "O" : selectedFollowUpBase,
        "custCode": selectedCustomer?['customerCode'],
        "docId":
            selectedLeadNumber?['autoId'] ??
            selectedQuotationNumber?['autoId'] ??
            1,
        "expeResDate":
            expectedDate != null
                ? FormatUtils.formatDateForApi(expectedDate!)
                : "",
        "followUpAgenda": _nextFollowUpAgendaController.text,
        "followUpCost": 0,
        "followUpCount": 0,
        "followUpDate":
            followUpDate != null
                ? FormatUtils.formatDateForApi(followUpDate!)
                : "",
        "followUpTime": FormatUtils.timeOfDayToHHmmss(followUpTime),
        "method": selectedMethod?['code'],
        "nxtFollowUpDate":
            nextFollowUpDate != null
                ? FormatUtils.formatDateForApi(nextFollowUpDate!)
                : "",
        "nxtSalesPersonCode": selectedNextSalesman?['salesmanCode'] ?? "",
        "remark": _remarksController.text,
        "salesPerCode": selectedSalesman?['salesmanCode'],
      };

      final response = await _dio.post(
        'http://$baseUrl/api/Followup/FollowUpEntryCreate',
        data: body,
      );

      if (response.data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Follow up added successfully!')),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${response.data['message']}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  // --- MAIN BUILD ---

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add Follow Up')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add Follow Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildFollowUpBaseDropdown(),
              const SizedBox(height: 16),
              _buildCustomerTypeAhead(),
              const SizedBox(height: 16),
              _buildLeadOrQuotationDropdown(),
              const SizedBox(height: 16),
              _buildDatePicker(
                label: 'Follow Up Date',
                value: followUpDate,
                onChanged: (val) => setState(() => followUpDate = val),
                firstDate: periodSDt,
                lastDate: DateTime.now(),
                required: true,
              ),
              const SizedBox(height: 16),
              _buildDatePicker(
                label: 'Expected Response Date',
                value: expectedDate,
                onChanged: (val) => setState(() => expectedDate = val),
                firstDate: followUpDate,
                lastDate: DateTime(2100, 12, 31),
              ),
              const SizedBox(height: 16),
              _buildTimePicker(
                label: 'Follow Up Time',
                value: followUpTime,
                onChanged: (val) => setState(() => followUpTime = val),
              ),
              const SizedBox(height: 16),
              _buildSalesmanDropdown(),
              const SizedBox(height: 16),
              _buildMethodDropdown(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _remarksController,
                decoration: const InputDecoration(
                  labelText: 'Remarks',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildNextSalesmanDropdown(),
              const SizedBox(height: 16),
              _buildNextFollowUpAgendaField(),
              const SizedBox(height: 16),
              _buildDatePicker(
                label: 'Next Follow Up Date',
                value: nextFollowUpDate,
                onChanged: (val) => setState(() => nextFollowUpDate = val),
                firstDate: followUpDate,
              ),
              // Uncomment the next line if attachments are needed
              // const SizedBox(height: 16),
              // _buildAttachmentPicker(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submitForm,
                  child:
                      isSubmitting
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
