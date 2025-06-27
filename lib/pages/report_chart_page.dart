// import 'dart:convert';

// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:nhapp/utils/storage_utils.dart';
// import 'package:nhapp/widgets/Dashboard/Director/report_chart.dart';

// class ReportChartPage extends StatefulWidget {
//   const ReportChartPage({super.key});

//   @override
//   State<ReportChartPage> createState() => _ReportChartPageState();
// }

// class _ReportChartPageState extends State<ReportChartPage> {
//   final List<Map<String, String>> _dateOptions = [
//     {'label': 'Today', 'value': 'today'},
//     {'label': 'Month', 'value': 'month'},
//     {'label': 'Qtr', 'value': 'qtr'},
//     {'label': 'Ytd', 'value': 'ytd'},
//     {'label': 'Custom Dates', 'value': 'custom'},
//   ];

//   String _selectedOption = 'today';
//   DateTime? _fromDate; // default is null
//   DateTime? _toDate; // default is null
//   bool _loading = false;
//   List<ReportData>? _chartData;

//   // API call
//   Future<List<ReportData>?> fetchData(
//     String option, {
//     DateTime? from,
//     DateTime? to,
//     String curtype = "A",
//   }) async {
//     setState(() => _loading = true);

//     final url = await StorageUtils.readValue('url');
//     final companyDetails = await StorageUtils.readJson('selected_company');
//     if (companyDetails == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("Company not set")));
//       }
//       setState(() => _loading = false);
//       return null;
//     }

//     final locationDetails = await StorageUtils.readJson('selected_location');
//     if (locationDetails == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("Location not set")));
//       }
//       setState(() => _loading = false);
//       return null;
//     }

//     final tokenDetails = await StorageUtils.readJson('session_token');
//     if (tokenDetails == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Session token not found")),
//         );
//       }
//       setState(() => _loading = false);
//       return null;
//     }

//     final companyId = companyDetails['id'];
//     final locationId = locationDetails['id'];
//     final token = tokenDetails['token']['value'];

//     try {
//       final dio = Dio();
//       dio.options.headers['Content-Type'] = 'application/json';
//       dio.options.headers['Authorization'] = 'Bearer $token';
//       dio.options.headers['companyid'] = companyId;
//       Response response = await dio.get(
//         'http://$url/api/Login/dash_FetchDashboardReport',
//         queryParameters: {
//           'companyid': companyId,
//           'fromdate': from.toString(),
//           'todate': to.toString(),
//           'datetype': option,
//           'curtype': curtype,
//         },
//       );

//       if (response.statusCode == 200) {
//         var responseData;
//         if (response.data is String) {
//           responseData = jsonDecode(response.data);
//         } else {
//           responseData = response.data;
//         }

//         if (responseData['success'] == true ||
//             responseData['status'] == 'success') {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Data fetched successfully")),
//           );
//           // Ensure _chartData is a List<Map<String, dynamic>>
//           final data = responseData['data'];
//           print("Report chart data: $data");
//           setState(() {
//             _chartData = (data is List) ? List<ReportData>.from(data) : [];
//             _loading = false;
//           });
//           return _chartData;
//         } else {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(
//                   "API returned error: ${responseData['message'] ?? 'Unknown error'}",
//                 ),
//               ),
//             );
//           }
//         }
//       } else {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Error: ${response.statusCode}")),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Exception: ${e.toString()}")));
//       }
//     }

//     setState(() => _loading = false);
//     return null;
//   }

//   Future<void> _pickDate(BuildContext context, bool isFrom) async {
//     final initialDate =
//         isFrom ? (_fromDate ?? DateTime.now()) : (_toDate ?? DateTime.now());
//     final firstDate = DateTime(2000);
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

//   void _submit() async {
//     if (_selectedOption == 'custom') {
//       if (_fromDate == null || _toDate == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please select both dates')),
//         );
//         return;
//       }
//     }
//     final data = await fetchData(_selectedOption, from: _fromDate, to: _toDate);
//     setState(() {
//       _chartData = data;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dateFormat = DateFormat('yyyy-MM-dd');

//     return Scaffold(
//       appBar: AppBar(title: const Text('Director Report Chart')),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               // Dropdown
//               DropdownButtonFormField<String>(
//                 value: _selectedOption,
//                 items:
//                     _dateOptions
//                         .map(
//                           (e) => DropdownMenuItem(
//                             value: e['value'],
//                             child: Text(e['label']!),
//                           ),
//                         )
//                         .toList(),
//                 onChanged: (val) {
//                   setState(() {
//                     _selectedOption = val!;
//                     if (_selectedOption != 'custom') {
//                       _fromDate = null;
//                       _toDate = null;
//                     }
//                   });
//                 },
//                 decoration: const InputDecoration(
//                   labelText: 'Select Date Range',
//                   border: OutlineInputBorder(),
//                 ),
//               ),

//               const SizedBox(height: 16),
//               // Custom date pickers
//               if (_selectedOption == 'custom')
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextFormField(
//                         readOnly: true,
//                         controller: TextEditingController(
//                           text:
//                               _fromDate != null
//                                   ? dateFormat.format(_fromDate!)
//                                   : '',
//                         ),
//                         decoration: InputDecoration(
//                           labelText: 'From Date',
//                           suffixIcon: IconButton(
//                             icon: const Icon(Icons.calendar_today),
//                             onPressed: () => _pickDate(context, true),
//                           ),
//                           border: const OutlineInputBorder(),
//                         ),
//                         onTap: () => _pickDate(context, true),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: TextFormField(
//                         readOnly: true,
//                         controller: TextEditingController(
//                           text:
//                               _toDate != null
//                                   ? dateFormat.format(_toDate!)
//                                   : '',
//                         ),
//                         decoration: InputDecoration(
//                           labelText: 'To Date',
//                           suffixIcon: IconButton(
//                             icon: const Icon(Icons.calendar_today),
//                             onPressed: () => _pickDate(context, false),
//                           ),
//                           border: const OutlineInputBorder(),
//                         ),
//                         onTap: () => _pickDate(context, false),
//                       ),
//                     ),
//                   ],
//                 ),
//               if (_selectedOption == 'custom') const SizedBox(height: 16),
//               // Submit button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _loading ? null : _submit,
//                   child:
//                       _loading
//                           ? const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                           : const Text('Submit'),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               // Chart
//               if (_chartData != null && _chartData!.isNotEmpty)
//                 SizedBox(
//                   height: 400, // Set a fixed height for the chart if needed
//                   child: ReportPieChartCard(statuses: _chartData!),
//                 ),
//               if (_chartData != null && _chartData!.isEmpty)
//                 const Text('No data available.'),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:nhapp/utils/storage_utils.dart';
// import 'package:nhapp/widgets/Dashboard/Director/report_chart.dart';

// class ReportChartPage extends StatefulWidget {
//   const ReportChartPage({super.key});

//   @override
//   State<ReportChartPage> createState() => _ReportChartPageState();
// }

// class _ReportChartPageState extends State<ReportChartPage> {
//   final List<Map<String, String>> _dateOptions = [
//     {'label': 'Today', 'value': 'today'},
//     {'label': 'Month', 'value': 'month'},
//     {'label': 'Qtr', 'value': 'qtr'},
//     {'label': 'Ytd', 'value': 'ytd'},
//     {'label': 'Custom Dates', 'value': 'custom'},
//   ];

//   String _selectedOption = 'today';
//   DateTime? _fromDate;
//   DateTime? _toDate;
//   bool _loading = false;
//   List<ReportData>? _chartData;

//   Future<List<ReportData>?> fetchData(
//     String option, {
//     DateTime? from,
//     DateTime? to,
//     String curtype = "A",
//   }) async {
//     setState(() => _loading = true);

//     try {
//       // Load shared data
//       final url = await StorageUtils.readValue('url');
//       final companyDetails = await StorageUtils.readJson('selected_company');
//       final locationDetails = await StorageUtils.readJson('selected_location');
//       final tokenDetails = await StorageUtils.readJson('session_token');

//       if (companyDetails == null) {
//         if (mounted) {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(const SnackBar(content: Text("Company not set")));
//         }
//         setState(() => _loading = false);
//         return null;
//       }

//       if (locationDetails == null) {
//         if (mounted) {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(const SnackBar(content: Text("Location not set")));
//         }
//         setState(() => _loading = false);
//         return null;
//       }

//       if (tokenDetails == null) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Session token not found")),
//           );
//         }
//         setState(() => _loading = false);
//         return null;
//       }

//       final companyId = companyDetails['id'];
//       final token = tokenDetails['token']['value'];

//       final dio = Dio();
//       dio.options.headers['Content-Type'] = 'application/json';
//       dio.options.headers['Authorization'] = 'Bearer $token';
//       dio.options.headers['companyid'] = companyId;

//       final formattedFromDate =
//           from != null ? DateFormat('yyyy-MM-dd').format(from) : "undefined";
//       final formattedToDate =
//           to != null ? DateFormat('yyyy-MM-dd').format(to) : "undefined";

//       final response = await dio.get(
//         'http://$url/api/Login/dash_FetchDashboardReport',
//         queryParameters: {
//           'companyid': companyId,
//           'fromdate': formattedFromDate,
//           'todate': formattedToDate,
//           'datetype': option,
//           'curtype': curtype,
//         },
//       );

//       if (response.statusCode == 200) {
//         final responseData =
//             response.data is String ? jsonDecode(response.data) : response.data;

//         if ((responseData['success'] == true ||
//             responseData['status'] == 'success')) {
//           final data = responseData['data'];

//           setState(() {
//             _chartData =
//                 (data is List)
//                     ? data.map((item) => ReportData.fromMap(item)).toList()
//                     : [];
//             _loading = false;
//           });

//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text("Data fetched successfully")),
//             );
//           }

//           return _chartData;
//         } else {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(
//                   "API returned error: ${responseData['message'] ?? 'Unknown error'}",
//                 ),
//               ),
//             );
//           }
//         }
//       } else {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Error: ${response.statusCode}")),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Exception: ${e.toString()}")));
//       }
//     }

//     setState(() => _loading = false);
//     return null;
//   }

//   Future<void> _pickDate(BuildContext context, bool isFrom) async {
//     final initialDate =
//         isFrom ? (_fromDate ?? DateTime.now()) : (_toDate ?? DateTime.now());
//     final firstDate = DateTime(2000);
//     final lastDate = DateTime(2100);

//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initialDate,
//       firstDate: firstDate,
//       lastDate: lastDate,
//     );

//     if (picked != null && mounted) {
//       setState(() {
//         if (isFrom) {
//           _fromDate = picked;
//         } else {
//           _toDate = picked;
//         }
//       });
//     }
//   }

//   void _submit() async {
//     if (_selectedOption == 'custom') {
//       if (_fromDate == null || _toDate == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please select both dates')),
//         );
//         return;
//       }
//     }

//     await fetchData(_selectedOption, from: _fromDate, to: _toDate);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dateFormat = DateFormat('dd-MM-yyyy');

//     return Scaffold(
//       appBar: AppBar(title: const Text('Director Report Chart')),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               // Dropdown for Date Range
//               DropdownButtonFormField<String>(
//                 value: _selectedOption,
//                 items:
//                     _dateOptions
//                         .map(
//                           (e) => DropdownMenuItem(
//                             value: e['value'],
//                             child: Text(e['label']!),
//                           ),
//                         )
//                         .toList(),
//                 onChanged: (val) {
//                   setState(() {
//                     _selectedOption = val!;
//                     if (_selectedOption != 'custom') {
//                       _fromDate = null;
//                       _toDate = null;
//                     }
//                   });
//                 },
//                 decoration: const InputDecoration(
//                   labelText: 'Select Date Range',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Custom Date Pickers
//               if (_selectedOption == 'custom')
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextFormField(
//                         readOnly: true,
//                         controller: TextEditingController(
//                           text:
//                               _fromDate != null
//                                   ? dateFormat.format(_fromDate!)
//                                   : '',
//                         ),
//                         decoration: InputDecoration(
//                           labelText: 'From Date',
//                           suffixIcon: IconButton(
//                             icon: const Icon(Icons.calendar_today),
//                             onPressed: () => _pickDate(context, true),
//                           ),
//                           border: const OutlineInputBorder(),
//                         ),
//                         onTap: () => _pickDate(context, true),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: TextFormField(
//                         readOnly: true,
//                         controller: TextEditingController(
//                           text:
//                               _toDate != null
//                                   ? dateFormat.format(_toDate!)
//                                   : '',
//                         ),
//                         decoration: InputDecoration(
//                           labelText: 'To Date',
//                           suffixIcon: IconButton(
//                             icon: const Icon(Icons.calendar_today),
//                             onPressed: () => _pickDate(context, false),
//                           ),
//                           border: const OutlineInputBorder(),
//                         ),
//                         onTap: () => _pickDate(context, false),
//                       ),
//                     ),
//                   ],
//                 ),
//               if (_selectedOption == 'custom') const SizedBox(height: 16),

//               // Submit Button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _loading ? null : _submit,
//                   child:
//                       _loading
//                           ? const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                           : const Text('Submit'),
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Pie Chart or Empty Message
//               if (_chartData != null && _chartData!.isNotEmpty)
//                 ReportPieChartCard(statuses: _chartData!),
//               if (_chartData != null && _chartData!.isEmpty)
//                 const Text('No data available.'),
//             ],
//           ),
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
import 'package:nhapp/widgets/Dashboard/Director/report_chart.dart';

class ReportChartPage extends StatefulWidget {
  const ReportChartPage({super.key});

  @override
  State<ReportChartPage> createState() => _ReportChartPageState();
}

class _ReportChartPageState extends State<ReportChartPage> {
  final List<Map<String, String>> _dateOptions = [
    {'label': 'Today', 'value': 'today'},
    {'label': 'Month', 'value': 'month'},
    {'label': 'Qtr', 'value': 'qtr'},
    {'label': 'Ytd', 'value': 'ytd'},
    {'label': 'Custom Dates', 'value': 'custom'},
  ];

  String _selectedOption = 'today';
  DateTime? _fromDate = DateTime.now();
  DateTime? _toDate = DateTime.now();
  bool _loading = false;
  List<ReportData>? _chartData;
  DateTime _today = DateTime.now();

  Future<List<ReportData>?> fetchData(
    String option, {
    DateTime? from,
    DateTime? to,
    String curtype = "A",
  }) async {
    setState(() => _loading = true);

    try {
      // Load shared data
      final url = await StorageUtils.readValue('url');
      final companyDetails = await StorageUtils.readJson('selected_company');
      final locationDetails = await StorageUtils.readJson('selected_location');
      final tokenDetails = await StorageUtils.readJson('session_token');

      if (companyDetails == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Company not set")));
        }
        setState(() => _loading = false);
        return null;
      }

      if (locationDetails == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Location not set")));
        }
        setState(() => _loading = false);
        return null;
      }

      if (tokenDetails == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Session token not found")),
          );
        }
        setState(() => _loading = false);
        return null;
      }

      final companyId = companyDetails['id'];
      final token = tokenDetails['token']['value'];

      final dio = Dio();
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Authorization'] = 'Bearer $token';
      dio.options.headers['companyid'] = companyId;

      final formattedFromDate =
          from != null ? DateFormat('yyyy-MM-dd').format(from) : "undefined";
      final formattedToDate =
          to != null ? DateFormat('yyyy-MM-dd').format(to) : "undefined";

      final response = await dio.get(
        'http://$url/api/Login/dash_FetchDashboardReport',
        queryParameters: {
          'companyid': companyId,
          'fromdate': formattedFromDate,
          'todate': formattedToDate,
          'datetype': option,
          'curtype': curtype,
        },
      );

      if (response.statusCode == 200) {
        final responseData =
            response.data is String ? jsonDecode(response.data) : response.data;

        if ((responseData['success'] == true ||
            responseData['status'] == 'success')) {
          final data = responseData['data'];

          setState(() {
            _chartData =
                (data is List)
                    ? data.map((item) => ReportData.fromMap(item)).toList()
                    : [];
            _loading = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Data fetched successfully")),
            );
          }

          return _chartData;
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "API returned error: ${responseData['message'] ?? 'Unknown error'}",
                ),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${response.statusCode}")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Exception: ${e.toString()}")));
      }
    }

    setState(() => _loading = false);
    return null;
  }

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

  Future<void> _pickDate(BuildContext context, bool isFrom) async {
    if (!isFrom && _fromDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select From Date first')),
      );
      return;
    }

    final initialDate =
        isFrom ? (_fromDate ?? _today) : (_toDate ?? _fromDate ?? _today);

    final firstDate = isFrom ? DateTime(2000) : (_fromDate ?? DateTime(2000));
    final lastDate = _today;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(lastDate) ? lastDate : initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && mounted) {
      if (isFrom) {
        final validationError = _validateFromDate(picked);
        if (validationError != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(validationError)));
          return;
        }
        setState(() {
          _fromDate = picked;
          // Reset To Date if it's before the new From Date
          if (_toDate != null && _toDate!.isBefore(picked)) {
            _toDate = null;
          }
        });
      } else {
        final validationError = _validateToDate(picked);
        if (validationError != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(validationError)));
          return;
        }
        setState(() {
          _toDate = picked;
        });
      }
    }
  }

  void _submit() async {
    if (_selectedOption == 'custom') {
      if (_fromDate == null || _toDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select both dates')),
        );
        return;
      }
    }

    await fetchData(_selectedOption, from: _fromDate, to: _toDate);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd-MM-yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Director Report Chart')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Dropdown for Date Range
              DropdownButtonFormField<String>(
                value: _selectedOption,
                items:
                    _dateOptions
                        .map(
                          (e) => DropdownMenuItem(
                            value: e['value'],
                            child: Text(e['label']!),
                          ),
                        )
                        .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedOption = val!;
                    if (_selectedOption != 'custom') {
                      _fromDate = null;
                      _toDate = null;
                    }
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Select Date Range',
                  // border: OutlineInputBorder(),
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Custom Date Pickers
              if (_selectedOption == 'custom')
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        controller: TextEditingController(
                          text:
                              _fromDate != null
                                  ? FormatUtils.formatDateForUser(_fromDate!)
                                  : '',
                        ),
                        decoration: InputDecoration(
                          labelText: 'From Date',
                          suffixIcon: const Icon(Icons.calendar_today_outlined),
                          border: const OutlineInputBorder(),
                          fillColor: Colors.white,
                        ),
                        onTap: () => _pickDate(context, true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        controller: TextEditingController(
                          text:
                              _toDate != null
                                  ? FormatUtils.formatDateForUser(_toDate!)
                                  : '',
                        ),
                        decoration: InputDecoration(
                          labelText: 'To Date',
                          suffixIcon: const Icon(Icons.calendar_today_outlined),
                          border: const OutlineInputBorder(),
                          fillColor: Colors.white,
                        ),
                        onTap:
                            _fromDate != null
                                ? () => _pickDate(context, false)
                                : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please select From Date first',
                                      ),
                                    ),
                                  );
                                },
                      ),
                    ),
                  ],
                ),
              if (_selectedOption == 'custom') const SizedBox(height: 16),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child:
                      _loading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Submit'),
                ),
              ),
              const SizedBox(height: 24),

              // Pie Chart or Empty Message
              if (_chartData != null && _chartData!.isNotEmpty)
                ReportPieChartCard(statuses: _chartData!),
              if (_chartData != null && _chartData!.isEmpty)
                const Text('No data available.'),
            ],
          ),
        ),
      ),
    );
  }
}
