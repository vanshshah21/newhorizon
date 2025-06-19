// import 'dart:convert';

// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:nhapp/utils/storage_utils.dart';
// import 'package:nhapp/widgets/Dashboard/Director/dispatch_amount_by_month.dart';

// class DispatchAmountByMonthsPage extends StatefulWidget {
//   const DispatchAmountByMonthsPage({super.key});

//   @override
//   State<DispatchAmountByMonthsPage> createState() =>
//       _DispatchAmountByMonthsPageState();
// }

// class _DispatchAmountByMonthsPageState
//     extends State<DispatchAmountByMonthsPage> {
//   final List<Map<String, String>> _dropdownOptions = [
//     {'name': 'Current Year', 'value': 'C'},
//     {'name': 'Last 2 Years', 'value': 'OC'},
//     {'name': 'Last 3 Years', 'value': 'TC'},
//   ];

//   String _selectedCompare = 'C';
//   Future<Map<String, dynamic>>? _chartFuture;

//   Future<Map<String, dynamic>> _fetchChartData() async {
//     final companyid = 1;
//     final curtype = 'A';
//     final compare = _selectedCompare;

//     try {
//       final url = await StorageUtils.readValue('url');
//       final companyDetails = await StorageUtils.readJson('selected_company');
//       if (companyDetails == null) {
//         if (mounted) {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(const SnackBar(content: Text("Company not set")));
//         }
//         return {};
//       }
//       final tokenDetails = await StorageUtils.readJson('session_token');
//       if (tokenDetails == null) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Session token not found")),
//           );
//         }
//         return {};
//       }
//       final companyId = companyDetails['id'];
//       final token = tokenDetails['token']['value'];
//       final dio = Dio();
//       dio.options.headers['Content-Type'] = 'application/json';
//       dio.options.headers['Accept'] = 'application/json';
//       dio.options.headers['companyid'] = companyId.toString();
//       dio.options.headers['Authorization'] = 'Bearer $token';
//       final response = await dio.get(
//         'http://$url/api/Login/dash_FetchDispatchAmountMonth',
//         queryParameters: {
//           'companyid': companyid,
//           'curtype': curtype,
//           'compare': compare,
//         },
//       );

//       if (response.statusCode == 200) {
//         final data =
//             response.data is String ? jsonDecode(response.data) : response.data;
//         if (data['success'] == true) {
//           final List chartdata = data['data']?['chartdata'] ?? [];
//           final List seriesdata = data['data']?['seriesdata'] ?? [];
//           return {
//             'chartdata': List<Map<String, dynamic>>.from(chartdata),
//             'seriesdata': List<Map<String, dynamic>>.from(seriesdata),
//           };
//         } else {
//           throw Exception(data['errorMessage'] ?? 'API error');
//         }
//       } else {
//         throw Exception('Failed with status: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('API error: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Dispatch Amount by Month')),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               DropdownButtonFormField<String>(
//                 value: _selectedCompare,
//                 decoration: const InputDecoration(
//                   labelText: 'Select Year Range',
//                   border: OutlineInputBorder(),
//                 ),
//                 items:
//                     _dropdownOptions
//                         .map(
//                           (opt) => DropdownMenuItem<String>(
//                             value: opt['value'],
//                             child: Text(opt['name']!),
//                           ),
//                         )
//                         .toList(),
//                 onChanged: (val) {
//                   setState(() {
//                     _selectedCompare = val!;
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     _chartFuture = _fetchChartData();
//                   });
//                 },
//                 child: const Text('Submit'),
//               ),
//               const SizedBox(height: 24),
//               if (_chartFuture != null)
//                 FutureBuilder<Map<String, dynamic>>(
//                   future: _chartFuture,
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Padding(
//                         padding: EdgeInsets.all(32.0),
//                         child: Center(child: CircularProgressIndicator()),
//                       );
//                     }
//                     if (snapshot.hasError) {
//                       return Padding(
//                         padding: const EdgeInsets.all(32.0),
//                         child: Text('Error: ${snapshot.error}'),
//                       );
//                     }
//                     final data = snapshot.data;
//                     if (data == null ||
//                         data['chartdata'] == null ||
//                         data['seriesdata'] == null ||
//                         (data['chartdata'] as List).isEmpty) {
//                       return const Padding(
//                         padding: EdgeInsets.all(32.0),
//                         child: Text('No data to display'),
//                       );
//                     }
//                     return DispatchAmountByMonthsChart(
//                       chartdata: List<Map<String, dynamic>>.from(
//                         data['chartdata'],
//                       ),
//                       seriesdata: List<Map<String, dynamic>>.from(
//                         data['seriesdata'],
//                       ),
//                     );
//                   },
//                 ),
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
import 'package:flutter/foundation.dart';
import 'package:nhapp/utils/storage_utils.dart';
import 'package:nhapp/utils/token_utils.dart'; // <-- Add this import
import 'package:nhapp/widgets/Dashboard/Director/dispatch_amount_by_month.dart';

class DispatchAmountByMonthsPage extends StatefulWidget {
  const DispatchAmountByMonthsPage({super.key});

  @override
  State<DispatchAmountByMonthsPage> createState() =>
      _DispatchAmountByMonthsPageState();
}

class _DispatchAmountByMonthsPageState
    extends State<DispatchAmountByMonthsPage> {
  final List<Map<String, String>> _dropdownOptions = [
    {'name': 'Current Year', 'value': 'C'},
    {'name': 'Last 2 Years', 'value': 'OC'},
    {'name': 'Last 3 Years', 'value': 'TC'},
  ];

  String _selectedCompare = 'C';
  Future<Map<String, dynamic>>? _chartFuture;

  Future<Map<String, dynamic>> _fetchChartData() async {
    // 1. Validate token before API call
    final isValid = await TokenUtils.isTokenValid(context);
    if (!isValid) {
      _showSnackBar("Session expired. Please log in again.");
      return {};
    }

    try {
      final url = await StorageUtils.readValue('url');
      final companyDetails = await StorageUtils.readJson('selected_company');
      if (companyDetails == null) {
        _showSnackBar("Company not set");
        return {};
      }
      final tokenDetails = await StorageUtils.readJson('session_token');
      if (tokenDetails == null) {
        _showSnackBar("Session token not found");
        return {};
      }
      final companyId = companyDetails['id'];
      final token = tokenDetails['token']['value'];
      final curtype = 'A';
      final compare = _selectedCompare;

      final dio = Dio();
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Accept'] = 'application/json';
      dio.options.headers['companyid'] = companyId.toString();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await dio.get(
        'http://$url/api/Login/dash_FetchDispatchAmountMonth',
        queryParameters: {
          'companyid': companyId,
          'curtype': curtype,
          'compare': compare,
        },
      );

      if (response.statusCode == 200) {
        // Parse JSON in a background isolate for large responses
        final data = await compute(_parseJson, response.data);
        if (data['success'] == true) {
          final List chartdata = data['data']?['chartdata'] ?? [];
          final List seriesdata = data['data']?['seriesdata'] ?? [];
          return {
            'chartdata': List<Map<String, dynamic>>.from(chartdata),
            'seriesdata': List<Map<String, dynamic>>.from(seriesdata),
          };
        } else {
          throw Exception(data['errorMessage'] ?? 'API error');
        }
      } else {
        throw Exception('Failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      String message = 'Network error';
      if (e.response != null) {
        message = 'Failed: ${e.response?.statusCode}';
        if (e.response?.data is Map) {
          message += ' - ${e.response?.data['message']}';
        }
      } else {
        switch (e.type) {
          case DioExceptionType.connectionError:
            message = 'No internet connection';
            break;
          case DioExceptionType.receiveTimeout:
          case DioExceptionType.sendTimeout:
            message = 'Server timeout';
            break;
          case DioExceptionType.connectionTimeout:
            message = 'Connection timeout';
            break;
          default:
            message = 'Network error: ${e.message}';
        }
      }
      _showSnackBar(message);
      return {};
    } catch (e) {
      _showSnackBar('API error: $e');
      return {};
    }
  }

  static Map<String, dynamic> _parseJson(dynamic data) {
    if (data is String) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw Exception('Invalid data for JSON parsing');
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dispatch Amount by Month')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCompare,
                decoration: const InputDecoration(
                  labelText: 'Select Year Range',
                  border: OutlineInputBorder(),
                ),
                items:
                    _dropdownOptions
                        .map(
                          (opt) => DropdownMenuItem<String>(
                            value: opt['value'],
                            child: Text(opt['name']!),
                          ),
                        )
                        .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCompare = val!;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _chartFuture = _fetchChartData();
                  });
                },
                child: const Text('Submit'),
              ),
              const SizedBox(height: 24),
              if (_chartFuture != null)
                FutureBuilder<Map<String, dynamic>>(
                  future: _chartFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }
                    final data = snapshot.data;
                    if (data == null ||
                        data['chartdata'] == null ||
                        data['seriesdata'] == null ||
                        (data['chartdata'] as List).isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('No data to display'),
                      );
                    }
                    return DispatchAmountByMonthsChart(
                      chartdata: List<Map<String, dynamic>>.from(
                        data['chartdata'],
                      ),
                      seriesdata: List<Map<String, dynamic>>.from(
                        data['seriesdata'],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
