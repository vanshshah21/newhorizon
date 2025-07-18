import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nhapp/pages/followup/models/followup_list_item.dart';
import 'package:nhapp/utils/format_utils.dart';
import 'package:nhapp/utils/storage_utils.dart';

class EditFollowUpForm extends StatefulWidget {
  final FollowupListItem followup;

  const EditFollowUpForm({super.key, required this.followup});

  @override
  State<EditFollowUpForm> createState() => _EditFollowUpFormState();
}

class _EditFollowUpFormState extends State<EditFollowUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _dio = Dio();

  // Base URL for API
  late String url;
  late Map<String, dynamic> companyDetails;
  late Map<String, dynamic> locationDetails;
  late Map<String, dynamic> tokenDetails;

  // Dropdown data
  List<Map<String, dynamic>> followUpBaseList = [];
  List<Map<String, dynamic>> salesmanList = [];
  List<Map<String, dynamic>> methodList = [];
  List<Map<String, dynamic>> leadNumberList = [];
  List<Map<String, dynamic>> quotationNumberList = [];

  // Prefilled/selected values
  String? selectedFollowUpBase;
  String? customerName;
  Map<String, dynamic>? selectedLeadNumber;
  Map<String, dynamic>? selectedQuotationNumber;
  DateTime? followUpDate;
  DateTime? expectedDate;
  TimeOfDay? followUpTime;
  Map<String, dynamic>? selectedSalesman;
  Map<String, dynamic>? selectedMethod;
  Map<String, dynamic>? selectedNextSalesman;
  DateTime? nextFollowUpDate;
  String? remarks;

  // Loading states
  bool isLoading = true;
  bool isSubmitting = false;

  // For API
  Map<String, dynamic>? entryDetail;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    debugPrint(
      "Followup: Based on=${widget.followup.baseOn} - DocId=${widget.followup.docId} - CustCode=${widget.followup.custCode}",
    );
    setState(() => isLoading = true);
    try {
      url = (await StorageUtils.readValue('url'))!;
      companyDetails = await StorageUtils.readJson('selected_company');
      if (companyDetails.isEmpty) throw Exception("Company not set");
      locationDetails = await StorageUtils.readJson('selected_location');
      if (locationDetails.isEmpty) throw Exception("Location not set");
      tokenDetails = await StorageUtils.readJson('session_token');
      if (tokenDetails.isEmpty) throw Exception("Session token not found");
      await Future.wait([
        _fetchFollowUpBaseList(),
        _fetchSalesmanList(),
        _fetchMethodList(),
        _fetchEntryDetail(),
      ]);
      _prefillFields();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
    setState(() => isLoading = false);
  }

  Future<void> _fetchFollowUpBaseList() async {
    try {
      final companyId = companyDetails['id'];
      final token = tokenDetails['token']['value'];

      _dio.options.headers['accept'] = 'application/json';
      _dio.options.headers['Content-Type'] = 'application/json';
      _dio.options.headers['CompanyId'] = companyId;
      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.get(
        'http://$url/api/Followup/FollowUpBaseList',
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
    final companyId = companyDetails['id'];
    final token = tokenDetails['token']['value'];

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyId.toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';

    final response = await _dio.get(
      'http://$url/api/Followup/FollowUpSalesManList',
    );
    salesmanList = List<Map<String, dynamic>>.from(response.data['data']);
  }

  Future<void> _fetchMethodList() async {
    final companyId = companyDetails['id'];
    final token = tokenDetails['token']['value'];

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyId.toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';

    final response = await _dio.get(
      'http://$url/api/Followup/FollowUpMethodofContact',
      queryParameters: {'codeType': 'MF', 'codeValue': 'GEN'},
    );
    methodList = List<Map<String, dynamic>>.from(response.data['data']);
  }

  Future<void> _fetchEntryDetail() async {
    final companyId = companyDetails['id'];
    final token = tokenDetails['token']['value'];

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyId.toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';

    final response = await _dio.get(
      'http://$url/api/Followup/FollowupGetEntryDetail2',
      queryParameters: {
        'custCode': widget.followup.custCode,
        'baseOn': widget.followup.baseOn,
        'docId': widget.followup.docId,
      },
    );
    final data = response.data['data'] as List;
    if (data.isNotEmpty) {
      // Use the latest (most recent) follow up
      entryDetail = data.last;
    }
  }

  void _prefillFields() {
    if (entryDetail == null) return;

    // 1. Follow up base
    final baseOn =
        entryDetail!['baseOn'] == 'I' || entryDetail!['baseOn'] == 'Inquiry'
            ? 'I'
            : entryDetail!['baseOn'] == 'Q' ||
                entryDetail!['baseOn'] == 'Quotation'
            ? 'Q'
            : 'T';

    selectedFollowUpBase = baseOn;

    // 2. Customer Name
    customerName =
        widget.followup.customerFullName ?? entryDetail!['custCode'] ?? '';

    // 3. Lead/Quotation Number (simulate API if needed)
    if (selectedFollowUpBase == 'I') {
      selectedLeadNumber = {
        'number': entryDetail!['docId']?.toString() ?? '',
        'autoId': entryDetail!['docId'],
      };
    } else if (selectedFollowUpBase == 'Q') {
      selectedQuotationNumber = {
        'number': entryDetail!['docId']?.toString() ?? '',
        'autoId': entryDetail!['docId'],
      };
    }

    // 4. Follow Up date
    followUpDate = _parseDate(entryDetail!['followUpDate']);

    // 5. Expected Response Date
    expectedDate = _parseDate(entryDetail!['expeResDate']);

    // 6. Follow up time
    followUpTime = _parseTime(entryDetail!['followUpTime']);

    // 7. Salesman
    selectedSalesman = salesmanList.firstWhere(
      (e) => e['salesmanCode'] == entryDetail!['salesPerCode'],
      orElse: () => {},
    );
    if (selectedSalesman!.isEmpty) selectedSalesman = null;

    // 8. Method
    selectedMethod = methodList.firstWhere(
      (e) => e['code'] == entryDetail!['method'],
      orElse: () => {},
    );
    if (selectedMethod!.isEmpty) selectedMethod = null;

    // 9. Next Follow up salesman
    selectedNextSalesman = salesmanList.firstWhere(
      (e) => e['salesmanCode'] == entryDetail!['nxtSalesPersonCode'],
      orElse: () => {},
    );
    if (selectedNextSalesman!.isEmpty) selectedNextSalesman = null;

    // 10. Next follow up date
    nextFollowUpDate = _parseDate(entryDetail!['nxtFollowUpDate']);

    // 11. Remarks
    remarks = entryDetail!['remark'] ?? '';
  }

  // String? _getBaseCode(String? baseOn) {
  //   if (baseOn == null) return null;
  //   if (baseOn.toLowerCase().contains('inquiry')) return 'I';
  //   if (baseOn.toLowerCase().contains('quotation')) return 'Q';
  //   if (baseOn.toLowerCase().contains('other')) return 'O';
  //   return null;
  // }

  DateTime? _parseDate(dynamic dateStr) {
    if (dateStr == null || dateStr.toString().isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  TimeOfDay? _parseTime(dynamic timeStr) {
    if (timeStr == null || timeStr.toString().isEmpty) return null;
    final t = timeStr.toString();
    if (t == '__:__:__') return null;
    try {
      final parts = t.split(':');
      if (parts.length >= 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (_) {}
    return null;
  }

  // --- UI BUILDERS ---

  Widget _buildFollowUpBaseDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Follow Up Base',
        border: OutlineInputBorder(),
      ),
      value:
          followUpBaseList.any((e) => e['Code'] == selectedFollowUpBase)
              ? selectedFollowUpBase
              : null,
      items:
          followUpBaseList
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e['Code'],
                  child: Text(
                    e['Name'],
                    style: TextStyle(
                      color:
                          Theme.of(
                            context,
                          ).hintColor, // or ShadcnColors.foreground.toColor
                    ),
                  ),
                ),
              )
              .toList(),
      onChanged: null, // Disabled
    );
  }

  Widget _buildCustomerNameField() {
    return TextFormField(
      initialValue: customerName ?? '',
      decoration: const InputDecoration(
        labelText: 'Customer Name',
        border: OutlineInputBorder(),
      ),
      enabled: false,
    );
  }

  Widget _buildLeadOrQuotationDropdown() {
    if (selectedFollowUpBase == 'I') {
      return DropdownButtonFormField<Map<String, dynamic>>(
        decoration: const InputDecoration(
          labelText: 'Lead Number',
          border: OutlineInputBorder(),
        ),
        value: selectedLeadNumber,
        items:
            selectedLeadNumber != null
                ? [
                  DropdownMenuItem(
                    value: selectedLeadNumber,
                    child: Text(
                      selectedLeadNumber!['number'] ?? '',
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
                  ),
                ]
                : [],
        onChanged: null,
      );
    } else if (selectedFollowUpBase == 'Q') {
      return DropdownButtonFormField<Map<String, dynamic>>(
        decoration: const InputDecoration(
          labelText: 'Quotation Number',
          border: OutlineInputBorder(),
        ),
        value: selectedQuotationNumber,
        items:
            selectedQuotationNumber != null
                ? [
                  DropdownMenuItem(
                    value: selectedQuotationNumber,
                    child: Text(
                      selectedQuotationNumber!['number'] ?? '',
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
                  ),
                ]
                : [],
        onChanged: null,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? value,
    required bool enabled,
    required ValueChanged<DateTime?>? onChanged,
    DateTime? firstDate,
    DateTime? lastDate,
    bool required = false,
  }) {
    return InkWell(
      onTap:
          enabled
              ? () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: value ?? DateTime.now(),
                  firstDate: firstDate ?? DateTime(2000),
                  lastDate: lastDate ?? DateTime(2100),
                );
                if (picked != null && onChanged != null) onChanged(picked);
              }
              : null,
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
              style: TextStyle(
                color: value != null ? Theme.of(context).hintColor : null,
              ),
            ),
            if (enabled) const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay? value,
    required bool enabled,
    required ValueChanged<TimeOfDay?>? onChanged,
  }) {
    return InkWell(
      onTap:
          enabled
              ? () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: value ?? TimeOfDay.now(),
                );
                if (picked != null && onChanged != null) onChanged(picked);
              }
              : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value != null ? value.format(context) : 'Select'),
            if (enabled) const Icon(Icons.access_time),
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
      isExpanded: true,
      value:
          salesmanList.any(
                (e) => e['salesmanCode'] == selectedSalesman?['salesmanCode'],
              )
              ? selectedSalesman
              : null,
      items:
          salesmanList
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e['salesManFullName'],
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
      onChanged: (val) {
        setState(() {
          selectedSalesman = val;
          // Remove from next salesman if same
          if (selectedNextSalesman != null &&
              selectedNextSalesman!['salesmanCode'] ==
                  selectedSalesman!['salesmanCode']) {
            selectedNextSalesman = null;
          }
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
      isExpanded: true,
      value:
          methodList.any((e) => e['code'] == selectedMethod?['code'])
              ? selectedMethod
              : null,
      items:
          methodList
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e['codeFullName'],
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
      isExpanded: true,
      value:
          salesmanList.any(
                (e) =>
                    e['salesmanCode'] == selectedNextSalesman?['salesmanCode'],
              )
              ? selectedNextSalesman
              : null,
      items:
          salesmanList
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e['salesManFullName'],
                    overflow: TextOverflow.ellipsis,
                  ),
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

  Widget _buildRemarksField() {
    return TextFormField(
      initialValue: remarks ?? '',
      decoration: const InputDecoration(
        labelText: 'Remarks',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      onChanged: (val) => remarks = val,
    );
  }

  // --- SUBMISSION ---

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isSubmitting = true);

    try {
      final companyId = companyDetails['id'];
      final token = tokenDetails['token']['value'];

      _dio.options.headers['accept'] = 'application/json';
      _dio.options.headers['Content-Type'] = 'application/json';
      _dio.options.headers['CompanyId'] = companyId;
      _dio.options.headers['Authorization'] = 'Bearer $token';

      final body = {
        "NewSalesManFullName": selectedNextSalesman?['salesManFullName'] ?? "",
        "SalesManFullName": selectedSalesman?['salesManFullName'] ?? "",
        "autoId": entryDetail?['autoId'],
        "baseOn": selectedFollowUpBase == "T" ? "O" : selectedFollowUpBase,
        "custCode": entryDetail?['custCode'],
        "docId": entryDetail?['docId'],
        "expeResDate":
            expectedDate != null
                ? FormatUtils.formatDateForApi(expectedDate!)
                : "",
        "followUpAgenda": "",
        "followUpCost": 0,
        "followUpCount": 0,
        "followUpDate":
            followUpDate != null
                ? FormatUtils.formatDateForApi(followUpDate!)
                : "",
        "followUpTime":
            followUpTime != null ? followUpTime!.format(context) : "",
        "method": selectedMethod?['code'],
        "nxtFollowUpDate":
            nextFollowUpDate != null
                ? FormatUtils.formatDateForApi(nextFollowUpDate!)
                : "",
        "nxtSalesPersonCode": selectedNextSalesman?['salesmanCode'] ?? "",
        "remark": remarks ?? "",
        "salesPerCode": selectedSalesman?['salesmanCode'],
      };

      final response = await _dio.post(
        'http://$url/api/Followup/FollowUpEntryUpdate',
        data: body,
      );

      if (response.data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Follow up updated successfully!')),
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
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  // --- MAIN BUILD ---

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Follow Up')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Follow Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              _buildFollowUpBaseDropdown(),
              const SizedBox(height: 16),
              _buildCustomerNameField(),
              const SizedBox(height: 16),
              _buildLeadOrQuotationDropdown(),
              const SizedBox(height: 16),
              _buildDatePicker(
                label: 'Follow Up Date',
                value: followUpDate,
                enabled: false,
                onChanged: null,
                required: true,
              ),
              const SizedBox(height: 16),
              _buildDatePicker(
                label: 'Expected Response Date',
                value: expectedDate,
                enabled: true,
                onChanged: (val) => setState(() => expectedDate = val),
                firstDate: followUpDate,
              ),
              const SizedBox(height: 16),
              _buildTimePicker(
                label: 'Follow Up Time',
                value: followUpTime,
                enabled: true,
                onChanged: (val) => setState(() => followUpTime = val),
              ),
              const SizedBox(height: 16),
              _buildSalesmanDropdown(),
              const SizedBox(height: 16),
              _buildMethodDropdown(),
              const SizedBox(height: 16),
              _buildRemarksField(),
              const SizedBox(height: 16),
              _buildNextSalesmanDropdown(),
              const SizedBox(height: 16),
              _buildDatePicker(
                label: 'Next Follow Up Date',
                value: nextFollowUpDate,
                enabled: true,
                onChanged: (val) => setState(() => nextFollowUpDate = val),
                firstDate: followUpDate,
              ),
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
                          : const Text('Update'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
