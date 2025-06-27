// import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:nhapp/utils/format_utils.dart';
// import 'package:nhapp/utils/storage_utils.dart';

// class RecentInquiryPage extends StatefulWidget {
//   const RecentInquiryPage({super.key});

//   @override
//   State<RecentInquiryPage> createState() => _RecentInquiryPageState();
// }

// class _RecentInquiryPageState extends State<RecentInquiryPage> {
//   final List<Map<String, String>> _dateFilters = [
//     {'label': 'Today', 'value': 'today'},
//     {'label': 'Month', 'value': 'month'},
//     {'label': 'Qtr', 'value': 'qtr'},
//     {'label': 'Ytd', 'value': 'ytd'},
//     {'label': 'Custom Dates', 'value': 'custom'},
//   ];

//   String _selectedFilter = 'today';
//   DateTime? _fromDate = DateTime.now();
//   DateTime? _toDate = DateTime.now();
//   bool _loading = false;
//   String curtype = "A";
//   List<Map<String, dynamic>> _data = [];

//   final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

//   Future<void> _pickDate(BuildContext context, bool isFrom) async {
//     final initialDate =
//         isFrom ? (_fromDate ?? DateTime.now()) : (_toDate ?? DateTime.now());
//     final firstDate = DateTime(2020);
//     final lastDate = DateTime(2100);

//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initialDate,
//       firstDate: firstDate,
//       lastDate: lastDate,
//     );
//     if (picked != null) {
//       setState(() {
//         if (isFrom) {
//           _fromDate = picked;
//         } else {
//           _toDate = picked;
//         }
//       });
//     }
//   }

//   Future<void> _fetchData() async {
//     setState(() {
//       _loading = true;
//       _data = [];
//     });

//     final url = await StorageUtils.readValue('url');
//     final companyDetails = await StorageUtils.readJson('selected_company');
//     if (companyDetails == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("Company not set")));
//       }
//       setState(() => _loading = false);
//       return;
//     }

//     final tokenDetails = await StorageUtils.readJson('session_token');
//     if (tokenDetails == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Session token not found")),
//         );
//       }
//       setState(() => _loading = false);
//       return;
//     }

//     final companyId = companyDetails['id'];
//     final token = tokenDetails['token']['value'];

//     try {
//       Dio dio = Dio();
//       dio.options.headers['Authorization'] = 'Bearer $token';
//       dio.options.headers['Content-Type'] = 'application/json';
//       dio.options.headers['Accept'] = 'application/json';
//       dio.options.headers['companyid'] = companyId.toString();

//       final response = await dio.get(
//         'http://$url/api/Login/dash_FetchCustomerInquries2',
//         queryParameters: {
//           'companyid': companyId,
//           'curtype': curtype,
//           'fromdate':
//               _fromDate != null ? _dateFormat.format(_fromDate!) : "undefined",
//           'todate':
//               _toDate != null ? _dateFormat.format(_toDate!) : "undefined",
//           'datetype': _selectedFilter,
//         },
//       );

//       if (response.statusCode == 200) {
//         final decoded = jsonDecode(response.data);
//         final List<Map<String, dynamic>> data =
//             (decoded['data'] as List).cast<Map<String, dynamic>>();
//         setState(() {
//           _data = data;
//           _loading = false;
//         });
//       } else {
//         throw Exception('Failed to load data');
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Error fetching data: $e")));
//       }
//       return;
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   Widget _buildDateField({
//     required String label,
//     required DateTime? value,
//     required VoidCallback onTap,
//   }) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: AbsorbPointer(
//           child: TextFormField(
//             decoration: InputDecoration(
//               labelText: label,
//               border: const OutlineInputBorder(),
//               suffixIcon: const Icon(Icons.calendar_today),
//             ),
//             controller: TextEditingController(
//               text: value != null ? _dateFormat.format(value) : '',
//             ),
//             readOnly: true,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Customer Inquiry List')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             DropdownButtonFormField<String>(
//               value: _selectedFilter,
//               decoration: const InputDecoration(
//                 labelText: 'Date Filter',
//                 border: OutlineInputBorder(),
//               ),
//               items:
//                   _dateFilters
//                       .map(
//                         (opt) => DropdownMenuItem<String>(
//                           value: opt['value'],
//                           child: Text(opt['label']!),
//                         ),
//                       )
//                       .toList(),
//               onChanged: (val) {
//                 setState(() {
//                   _selectedFilter = val!;
//                   if (_selectedFilter != 'custom') {
//                     _fromDate = null;
//                     _toDate = null;
//                   }
//                 });
//               },
//             ),
//             if (_selectedFilter == 'custom') ...[
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   _buildDateField(
//                     label: 'From Date',
//                     value: _fromDate,
//                     onTap: () => _pickDate(context, true),
//                   ),
//                   const SizedBox(width: 12),
//                   _buildDateField(
//                     label: 'To Date',
//                     value: _toDate,
//                     onTap: () => _pickDate(context, false),
//                   ),
//                 ],
//               ),
//             ],
//             const SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _loading ? null : _fetchData,
//                 child:
//                     _loading
//                         ? const SizedBox(
//                           width: 18,
//                           height: 18,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                         : const Text('Submit'),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Expanded(
//               child:
//                   _loading
//                       ? const Center(child: CircularProgressIndicator())
//                       : _data.isEmpty
//                       ? const Center(child: Text('No data'))
//                       : ListView.builder(
//                         itemCount: _data.length,
//                         itemBuilder: (context, idx) {
//                           final item = _data[idx];
//                           final date =
//                               DateTime.tryParse(item['inquirydate'] ?? '') ??
//                               DateTime.now();
//                           return Card(
//                             margin: const EdgeInsets.symmetric(vertical: 6),
//                             child: ListTile(
//                               title: Text(
//                                 (item['customername'] ?? '').trim(),
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               subtitle: Text(
//                                 'Date: ${FormatUtils.formatDateForUser(date)}',
//                               ),
//                               trailing: Text(
//                                 FormatUtils.formatAmount(item['amount']),
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.green,
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhapp/utils/format_utils.dart';
import 'package:nhapp/utils/storage_utils.dart';

class RecentInquiryPage extends StatefulWidget {
  const RecentInquiryPage({super.key});

  @override
  State<RecentInquiryPage> createState() => _RecentInquiryPageState();
}

class _RecentInquiryPageState extends State<RecentInquiryPage> {
  final List<Map<String, String>> _dateFilters = [
    {'label': 'Today', 'value': 'today'},
    {'label': 'Month', 'value': 'month'},
    {'label': 'Qtr', 'value': 'qtr'},
    {'label': 'Ytd', 'value': 'ytd'},
    {'label': 'Custom Dates', 'value': 'custom'},
  ];

  String _selectedFilter = 'today';
  DateTime? _fromDate = DateTime.now();
  DateTime? _toDate = DateTime.now();
  bool _loading = false;
  String curtype = "A";
  List<Map<String, dynamic>> _data = [];
  final DateTime _today = DateTime.now();

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  // Validation for From Date
  String? _validateFromDate(DateTime? selectedDate) {
    if (selectedDate == null) {
      return null;
    }

    if (selectedDate.isAfter(_today)) {
      return 'From Date cannot be greater than today';
    }

    return null;
  }

  // Validation for To Date
  String? _validateToDate(DateTime? selectedDate) {
    if (selectedDate == null) {
      return null;
    }

    if (selectedDate.isAfter(_today)) {
      return 'To Date cannot be greater than today';
    }

    if (_fromDate != null && selectedDate.isBefore(_fromDate!)) {
      return 'To Date cannot be before From Date';
    }

    return null;
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _pickDate(BuildContext context, bool isFrom) async {
    if (!isFrom && _fromDate == null) {
      _showSnackBar('Please select From Date first');
      return;
    }

    final initialDate = DateTime.now();

    final firstDate = isFrom ? DateTime(2000) : (_fromDate ?? DateTime(2000));
    final lastDate = _today;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(lastDate) ? lastDate : initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      if (isFrom) {
        final validationError = _validateFromDate(picked);
        if (validationError != null) {
          _showSnackBar(validationError);
          return;
        }
        // setState(() {
        //   _fromDate = picked;
        //   // Reset To Date if it's before the new From Date
        //   if (_toDate != null && _toDate!.isBefore(picked)) {
        //     _toDate = null;
        //   }
        // });
      } else {
        final validationError = _validateToDate(picked);
        if (validationError != null) {
          _showSnackBar(validationError);
          return;
        }
        setState(() {
          _toDate = picked;
        });
      }
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
      _data = [];
    });

    final url = await StorageUtils.readValue('url');
    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Company not set")));
      }
      setState(() => _loading = false);
      return;
    }

    final tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session token not found")),
        );
      }
      setState(() => _loading = false);
      return;
    }

    final companyId = companyDetails['id'];
    final token = tokenDetails['token']['value'];

    try {
      Dio dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Accept'] = 'application/json';
      dio.options.headers['companyid'] = companyId.toString();

      final response = await dio.get(
        'http://$url/api/Login/dash_FetchCustomerInquries2',
        queryParameters: {
          'companyid': companyId,
          'curtype': curtype,
          'fromdate':
              _fromDate != null ? _dateFormat.format(_fromDate!) : "undefined",
          'todate':
              _toDate != null ? _dateFormat.format(_toDate!) : "undefined",
          'datetype': _selectedFilter,
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.data);
        final List<Map<String, dynamic>> data =
            (decoded['data'] as List).cast<Map<String, dynamic>>();
        setState(() {
          _data = data;
          _loading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error fetching data: $e")));
      }
      return;
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap:
            enabled
                ? onTap
                : () {
                  if (label == 'To Date' && _fromDate == null) {
                    _showSnackBar('Please select From Date first');
                  }
                },
        child: AbsorbPointer(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.calendar_today_outlined),
              fillColor: enabled ? Colors.white : Colors.grey[200],
              filled: true,
            ),
            controller: TextEditingController(
              text: value != null ? FormatUtils.formatDateForUser(value) : '',
            ),
            readOnly: true,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Inquiry List')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedFilter,
              decoration: const InputDecoration(
                labelText: 'Date Filter',
                border: OutlineInputBorder(),
              ),
              items:
                  _dateFilters
                      .map(
                        (opt) => DropdownMenuItem<String>(
                          value: opt['value'],
                          child: Text(opt['label']!),
                        ),
                      )
                      .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedFilter = val!;
                  if (_selectedFilter != 'custom') {
                    _fromDate = null;
                    _toDate = null;
                  }
                });
              },
            ),
            if (_selectedFilter == 'custom') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildDateField(
                    label: 'From Date',
                    value: _fromDate,
                    onTap: () => _pickDate(context, true),
                    enabled: true,
                  ),
                  const SizedBox(width: 12),
                  _buildDateField(
                    label: 'To Date',
                    value: _toDate,
                    onTap: () => _pickDate(context, false),
                    enabled: _fromDate != null,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _fetchData,
                child:
                    _loading
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Submit'),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _data.isEmpty
                      ? const Center(child: Text('No data'))
                      : ListView.builder(
                        itemCount: _data.length,
                        itemBuilder: (context, idx) {
                          final item = _data[idx];
                          final date =
                              DateTime.tryParse(item['inquirydate'] ?? '') ??
                              DateTime.now();
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              title: Text(
                                (item['customername'] ?? '').trim(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Date: ${FormatUtils.formatDateForUser(date)}',
                              ),
                              trailing: Text(
                                FormatUtils.formatAmount(item['amount']),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
