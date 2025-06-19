// import 'dart:convert';

// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:nhapp/utils/storage_utils.dart';
// import 'package:nhapp/widgets/Dashboard/Director/customers_by_receivable_overdue.dart';

// class CustomerByReceivableOverduePage extends StatefulWidget {
//   const CustomerByReceivableOverduePage({super.key});

//   @override
//   State<CustomerByReceivableOverduePage> createState() =>
//       _CustomerByReceivableOverduePageState();
// }

// class _CustomerByReceivableOverduePageState
//     extends State<CustomerByReceivableOverduePage> {
//   Future<List<Map<String, dynamic>>>? _chartFuture;

//   Future<List<Map<String, dynamic>>> _fetchChartData() async {
//     String curtype = "A";
//     final url = await StorageUtils.readValue('url');
//     final companyDetails = await StorageUtils.readJson('selected_company');
//     if (companyDetails == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("Company not set")));
//       }
//       return [];
//     }

//     final tokenDetails = await StorageUtils.readJson('session_token');
//     if (tokenDetails == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Session token not found")),
//         );
//       }
//       return [];
//     }

//     final companyId = companyDetails['id'];
//     final token = tokenDetails['token']['value'];

//     final dio = Dio();
//     dio.options.headers['Content-Type'] = 'application/json';
//     dio.options.headers['Accept'] = 'application/json';
//     dio.options.headers['companyid'] = companyId.toString();
//     dio.options.headers['Authorization'] = 'Bearer $token';
//     try {
//       final response = await dio.get(
//         'http://$url/api/Login/dash_FetchCustomerReceivableOverdue',
//         queryParameters: {'curtype': curtype, 'companyid': companyId},
//       );

//       if (response.statusCode == 200) {
//         final data =
//             response.data is String ? jsonDecode(response.data) : response.data;

//         // Safely extract the customerReceivableOverdue list
//         final list = data['data']?['customerReceivableOverdue'];
//         if (list is List && list.isNotEmpty) {
//           return List<Map<String, dynamic>>.from(list);
//         } else {
//           return [];
//         }
//       } else {
//         throw Exception('Failed with status: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('API error: $e');
//     }
//   }

//   Widget _buildChart(List<Map<String, dynamic>> data) {
//     // Example: expects data like [{'category': 'A', 'value': 10}, ...]
//     return CustomerReceivableOverdueChart(chartData: data);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Customers By Receivable Overdue Chart'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Center(
//               child: ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     _chartFuture = _fetchChartData();
//                   });
//                 },
//                 child: const Text('Load Chart'),
//               ),
//             ),
//             const SizedBox(height: 24),
//             if (_chartFuture != null)
//               FutureBuilder<List<Map<String, dynamic>>>(
//                 future: _chartFuture,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Padding(
//                       padding: EdgeInsets.all(32.0),
//                       child: Center(child: CircularProgressIndicator()),
//                     );
//                   }
//                   if (snapshot.hasError) {
//                     return Padding(
//                       padding: const EdgeInsets.all(32.0),
//                       child: Text('Error: ${snapshot.error}'),
//                     );
//                   }
//                   final data = snapshot.data;
//                   if (data == null || data.isEmpty) {
//                     return const Padding(
//                       padding: EdgeInsets.all(32.0),
//                       child: Text('No data to display'),
//                     );
//                   }
//                   return _buildChart(data);
//                 },
//               ),
//           ],
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
import 'package:nhapp/widgets/Dashboard/Director/customers_by_receivable_overdue.dart';

class CustomerByReceivableOverduePage extends StatefulWidget {
  const CustomerByReceivableOverduePage({super.key});

  @override
  State<CustomerByReceivableOverduePage> createState() =>
      _CustomerByReceivableOverduePageState();
}

class _CustomerByReceivableOverduePageState
    extends State<CustomerByReceivableOverduePage> {
  Future<List<Map<String, dynamic>>>? _chartFuture;

  Future<List<Map<String, dynamic>>> _fetchChartData() async {
    // 1. Validate token before API call
    final isValid = await TokenUtils.isTokenValid(context);
    if (!isValid) {
      _showSnackBar("Session expired. Please log in again.");
      return [];
    }

    String curtype = "A";
    final url = await StorageUtils.readValue('url');
    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) {
      _showSnackBar("Company not set");
      return [];
    }

    final tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails == null) {
      _showSnackBar("Session token not found");
      return [];
    }

    final companyId = companyDetails['id'];
    final token = tokenDetails['token']['value'];

    final dio = Dio();
    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Accept'] = 'application/json';
    dio.options.headers['companyid'] = companyId.toString();
    dio.options.headers['Authorization'] = 'Bearer $token';
    try {
      final response = await dio.get(
        'http://$url/api/Login/dash_FetchCustomerReceivableOverdue',
        queryParameters: {'curtype': curtype, 'companyid': companyId},
      );

      if (response.statusCode == 200) {
        // Parse JSON in a background isolate for large responses
        final data = await compute(_parseJson, response.data);

        // Safely extract the customerReceivableOverdue list
        final list = data['data']?['customerReceivableOverdue'];
        if (list is List && list.isNotEmpty) {
          return List<Map<String, dynamic>>.from(list);
        } else {
          return [];
        }
      } else {
        _showSnackBar('Failed with status: ${response.statusCode}');
        return [];
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
      return [];
    } catch (e) {
      _showSnackBar('API error: $e');
      return [];
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

  Widget _buildChart(List<Map<String, dynamic>> data) {
    return CustomerReceivableOverdueChart(chartData: data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers By Receivable Overdue Chart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _chartFuture = _fetchChartData();
                  });
                },
                child: const Text('Load Chart'),
              ),
            ),
            const SizedBox(height: 24),
            if (_chartFuture != null)
              FutureBuilder<List<Map<String, dynamic>>>(
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
                  if (data == null || data.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No data to display'),
                    );
                  }
                  return _buildChart(data);
                },
              ),
          ],
        ),
      ),
    );
  }
}
