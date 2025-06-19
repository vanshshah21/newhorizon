// import 'dart:convert';

// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:nhapp/utils/storage_utils.dart';
// import 'package:nhapp/widgets/Dashboard/Director/customer_by_sales_amount.dart';

// class CustomerBySalesAmountPage extends StatefulWidget {
//   const CustomerBySalesAmountPage({super.key});

//   @override
//   State<CustomerBySalesAmountPage> createState() =>
//       _CustomerBySalesAmountPageState();
// }

// class _CustomerBySalesAmountPageState extends State<CustomerBySalesAmountPage> {
//   // Multi-select options
//   final List<Map<String, String>> multiSelectOptions = [
//     {'label': 'Machines/ Spare', 'value': 'P'},
//     {'label': 'DC General', 'value': 'D'},
//     {'label': 'SIT', 'value': 'S'},
//     {'label': 'HSS', 'value': 'H'},
//     {'label': 'Services', 'value': 'V'},
//   ];

//   // Dropdown options
//   final List<Map<String, String>> dropdownOptions = [
//     {'label': 'Today', 'value': 'today'},
//     {'label': 'Month', 'value': 'month'},
//     {'label': 'Qtr', 'value': 'qtr'},
//     {'label': 'Ytd', 'value': 'ytd'},
//     {'label': 'Custom Dates', 'value': 'custom'},
//   ];

//   // State
//   List<String> selectedMulti = [];
//   String? selectedDropdown;
//   DateTime? fromDate;
//   DateTime? toDate;
//   Future<Map<String, dynamic>>? apiFuture;

//   // Date format
//   final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

//   // Multi-select bottom sheet
//   void _showMultiSelectSheet() async {
//     final List<String> tempSelected = List.from(selectedMulti);
//     await showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setSheetState) {
//             return DraggableScrollableSheet(
//               initialChildSize: 0.7,
//               minChildSize: 0.3,
//               maxChildSize: 0.7,
//               expand: false,
//               builder: (context, scrollController) {
//                 return Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // Header and drag handle
//                     Container(
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       child: Column(
//                         children: [
//                           Container(
//                             width: 40,
//                             height: 4,
//                             decoration: BoxDecoration(
//                               color: Colors.grey[300],
//                               borderRadius: BorderRadius.circular(2),
//                             ),
//                           ),
//                           const Padding(
//                             padding: EdgeInsets.all(16.0),
//                             child: Text(
//                               'Select Options',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 18,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     // List of options - scrollable
//                     Expanded(
//                       child: ListView(
//                         controller: scrollController,
//                         children:
//                             multiSelectOptions.map((option) {
//                               final value = option['value']!;
//                               return CheckboxListTile(
//                                 title: Text(option['label']!),
//                                 value: tempSelected.contains(value),
//                                 onChanged: (checked) {
//                                   setSheetState(() {
//                                     if (checked == true) {
//                                       tempSelected.add(value);
//                                     } else {
//                                       tempSelected.remove(value);
//                                     }
//                                   });
//                                 },
//                               );
//                             }).toList(),
//                       ),
//                     ),
//                     // Button at bottom
//                     SafeArea(
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                             ),
//                             child: const Text('Done'),
//                             onPressed: () {
//                               setState(() {
//                                 selectedMulti = List.from(tempSelected);
//                               });
//                               Navigator.pop(context);
//                             },
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }

//   // Date pickers
//   Future<void> _pickFromDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null) {
//       setState(() {
//         fromDate = picked;
//         if (toDate != null && toDate!.isBefore(fromDate!)) {
//           toDate = fromDate;
//         }
//       });
//     }
//   }

//   Future<void> _pickToDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: fromDate ?? DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null) {
//       setState(() {
//         toDate = picked;
//       });
//     }
//   }

//   // API call
//   Future<Map<String, dynamic>> _fetchChartData() async {
//     String curtype = "A";
//     final url = await StorageUtils.readValue('url');
//     print("url $url");
//     final companyDetails = await StorageUtils.readJson('selected_company');
//     if (companyDetails == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("Company not set")));
//       }
//       return {};
//     }

//     final tokenDetails = await StorageUtils.readJson('session_token');
//     if (tokenDetails == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Session token not found")),
//         );
//       }
//       return {};
//     }

//     final companyId = companyDetails['id'];
//     final token = tokenDetails['token']['value'];

//     try {
//       final dio = Dio();
//       dio.options.headers['Content-Type'] = 'application/json';
//       dio.options.headers['Authorization'] = 'Bearer $token';
//       dio.options.headers['companyId'] = companyId.toString();

//       final String fromdate =
//           fromDate != null ? dateFormat.format(fromDate!) : "undefined";
//       final String todate =
//           toDate != null ? dateFormat.format(toDate!) : "undefined";
//       final String? invof =
//           selectedMulti.isNotEmpty ? selectedMulti.join(",") : null;

//       Response response = await dio.get(
//         'http://$url/api/Login/dash_FetchCustomerSaleData',
//         queryParameters: {
//           'companyid': companyId,
//           'curtype': curtype,
//           'datetype': selectedDropdown.toString(),
//           'fromdate': fromdate,
//           'todate': todate,
//           'invOf': invof,
//         },
//       );

//       if (response.statusCode == 200) {
//         final responseData =
//             response.data is String ? jsonDecode(response.data) : response.data;
//         return responseData;
//       } else {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text("Error: fetching year ${response.statusCode}"),
//             ),
//           );
//         }
//         return {};
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Exception: $e")));
//       }
//       return {};
//     }
//   }

//   void _submit() {
//     if (selectedMulti.isEmpty ||
//         selectedDropdown == null ||
//         (selectedDropdown == 'custom' &&
//             (fromDate == null || toDate == null))) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select all required fields')),
//       );
//       return;
//     } else {
//       setState(() {
//         apiFuture = _fetchChartData();
//       });
//     }
//   }

//   Widget _buildChart(List<Map<String, dynamic>> data) {
//     return CustomerPurchaseBarChartCard(customerData: data);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Top 10 Customers by Sales Amount")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Multi-select input
//             Text(
//               'Select Types',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 8),
//             GestureDetector(
//               onTap: _showMultiSelectSheet,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 16,
//                 ),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey.shade400),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         selectedMulti.isEmpty
//                             ? 'Select options'
//                             : multiSelectOptions
//                                 .where(
//                                   (o) => selectedMulti.contains(o['value']),
//                                 )
//                                 .map((o) => o['label'])
//                                 .join(', '),
//                         style: TextStyle(
//                           color:
//                               selectedMulti.isEmpty
//                                   ? Colors.grey
//                                   : Colors.black,
//                         ),
//                       ),
//                     ),
//                     const Icon(Icons.arrow_drop_down),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),

//             // Dropdown menu
//             Text(
//               'Select Period',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 8),
//             DropdownButtonFormField<String>(
//               value: selectedDropdown,
//               items:
//                   dropdownOptions
//                       .map(
//                         (option) => DropdownMenuItem<String>(
//                           value: option['value'],
//                           child: Text(option['label']!),
//                         ),
//                       )
//                       .toList(),
//               onChanged: (value) {
//                 setState(() {
//                   selectedDropdown = value;
//                   if (value != 'custom') {
//                     fromDate = null;
//                     toDate = null;
//                   }
//                 });
//               },
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 contentPadding: EdgeInsets.symmetric(horizontal: 12),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Date pickers (only if custom)
//             if (selectedDropdown == 'custom') ...[
//               Row(
//                 children: [
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: _pickFromDate,
//                       child: AbsorbPointer(
//                         child: TextFormField(
//                           decoration: const InputDecoration(
//                             labelText: 'From Date',
//                             border: OutlineInputBorder(),
//                           ),
//                           controller: TextEditingController(
//                             text:
//                                 fromDate == null
//                                     ? ''
//                                     : dateFormat.format(fromDate!),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: _pickToDate,
//                       child: AbsorbPointer(
//                         child: TextFormField(
//                           decoration: const InputDecoration(
//                             labelText: 'To Date',
//                             border: OutlineInputBorder(),
//                           ),
//                           controller: TextEditingController(
//                             text:
//                                 toDate == null
//                                     ? ''
//                                     : dateFormat.format(toDate!),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//             ],

//             // Submit button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _submit,
//                 child: const Text('Submit'),
//               ),
//             ),

//             // Chart (after API response)
//             if (apiFuture != null)
//               FutureBuilder<Map<String, dynamic>>(
//                 future: apiFuture,
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
//                   final response = snapshot.data;
//                   if (response == null ||
//                       response['success'] != true ||
//                       response['data'] == null) {
//                     return const Padding(
//                       padding: EdgeInsets.all(32.0),
//                       child: Text('Failed to load chart data'),
//                     );
//                   }
//                   final List<Map<String, dynamic>> chartData =
//                       List<Map<String, dynamic>>.from(response['data']);
//                   if (chartData.isEmpty) {
//                     return const Padding(
//                       padding: EdgeInsets.all(32.0),
//                       child: Text('No data available.'),
//                     );
//                   }
//                   return _buildChart(chartData);
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
import 'package:intl/intl.dart';
import 'package:nhapp/utils/storage_utils.dart';
import 'package:nhapp/utils/token_utils.dart'; // <-- Add this import
import 'package:nhapp/widgets/Dashboard/Director/customer_by_sales_amount.dart';

class CustomerBySalesAmountPage extends StatefulWidget {
  const CustomerBySalesAmountPage({super.key});

  @override
  State<CustomerBySalesAmountPage> createState() =>
      _CustomerBySalesAmountPageState();
}

class _CustomerBySalesAmountPageState extends State<CustomerBySalesAmountPage> {
  // Multi-select options
  final List<Map<String, String>> multiSelectOptions = [
    {'label': 'Machines/ Spare', 'value': 'P'},
    {'label': 'DC General', 'value': 'D'},
    {'label': 'SIT', 'value': 'S'},
    {'label': 'HSS', 'value': 'H'},
    {'label': 'Services', 'value': 'V'},
  ];

  // Dropdown options
  final List<Map<String, String>> dropdownOptions = [
    {'label': 'Today', 'value': 'today'},
    {'label': 'Month', 'value': 'month'},
    {'label': 'Qtr', 'value': 'qtr'},
    {'label': 'Ytd', 'value': 'ytd'},
    {'label': 'Custom Dates', 'value': 'custom'},
  ];

  // State
  List<String> selectedMulti = [];
  String? selectedDropdown;
  DateTime? fromDate;
  DateTime? toDate;
  Future<Map<String, dynamic>>? apiFuture;

  // Date format
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  // Multi-select bottom sheet
  void _showMultiSelectSheet() async {
    final List<String> tempSelected = List.from(selectedMulti);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.3,
              maxChildSize: 0.7,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header and drag handle
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Select Options',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // List of options - scrollable
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        children:
                            multiSelectOptions.map((option) {
                              final value = option['value']!;
                              return CheckboxListTile(
                                title: Text(option['label']!),
                                value: tempSelected.contains(value),
                                onChanged: (checked) {
                                  setSheetState(() {
                                    if (checked == true) {
                                      tempSelected.add(value);
                                    } else {
                                      tempSelected.remove(value);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                      ),
                    ),
                    // Button at bottom
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Done'),
                            onPressed: () {
                              setState(() {
                                selectedMulti = List.from(tempSelected);
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  // Date pickers
  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fromDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        fromDate = picked;
        if (toDate != null && toDate!.isBefore(fromDate!)) {
          toDate = fromDate;
        }
      });
    }
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: toDate ?? fromDate ?? DateTime.now(),
      firstDate: fromDate ?? DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        toDate = picked;
      });
    }
  }

  // API call
  Future<Map<String, dynamic>> _fetchChartData() async {
    // 1. Validate token before API call
    final isValid = await TokenUtils.isTokenValid(context);
    if (!isValid) {
      _showSnackBar("Session expired. Please log in again.");
      return {};
    }

    String curtype = "A";
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

    try {
      final dio = Dio();
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Authorization'] = 'Bearer $token';
      dio.options.headers['companyId'] = companyId.toString();

      final String fromdate =
          fromDate != null ? dateFormat.format(fromDate!) : "undefined";
      final String todate =
          toDate != null ? dateFormat.format(toDate!) : "undefined";
      final String? invof =
          selectedMulti.isNotEmpty ? selectedMulti.join(",") : null;

      Response response = await dio.get(
        'http://$url/api/Login/dash_FetchCustomerSaleData',
        queryParameters: {
          'companyid': companyId,
          'curtype': curtype,
          'datetype': selectedDropdown.toString(),
          'fromdate': fromdate,
          'todate': todate,
          'invOf': invof,
        },
      );

      if (response.statusCode == 200) {
        // Parse JSON in a background isolate for large responses
        final responseData = await compute(_parseJson, response.data);
        return responseData;
      } else {
        _showSnackBar("Error: fetching data ${response.statusCode}");
        return {};
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
      _showSnackBar("Exception: $e");
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

  void _submit() {
    if (selectedMulti.isEmpty ||
        selectedDropdown == null ||
        (selectedDropdown == 'custom' &&
            (fromDate == null || toDate == null))) {
      _showSnackBar('Please select all required fields');
      return;
    } else {
      setState(() {
        apiFuture = _fetchChartData();
      });
    }
  }

  Widget _buildChart(List<Map<String, dynamic>> data) {
    return CustomerPurchaseBarChartCard(customerData: data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Top 10 Customers by Sales Amount")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Multi-select input
            Text(
              'Select Types',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showMultiSelectSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedMulti.isEmpty
                            ? 'Select options'
                            : multiSelectOptions
                                .where(
                                  (o) => selectedMulti.contains(o['value']),
                                )
                                .map((o) => o['label'])
                                .join(', '),
                        style: TextStyle(
                          color:
                              selectedMulti.isEmpty
                                  ? Colors.grey
                                  : Colors.black,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Dropdown menu
            Text(
              'Select Period',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedDropdown,
              items:
                  dropdownOptions
                      .map(
                        (option) => DropdownMenuItem<String>(
                          value: option['value'],
                          child: Text(option['label']!),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedDropdown = value;
                  if (value != 'custom') {
                    fromDate = null;
                    toDate = null;
                  }
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(height: 16),

            // Date pickers (only if custom)
            if (selectedDropdown == 'custom') ...[
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickFromDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'From Date',
                            border: OutlineInputBorder(),
                          ),
                          controller: TextEditingController(
                            text:
                                fromDate == null
                                    ? ''
                                    : dateFormat.format(fromDate!),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickToDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'To Date',
                            border: OutlineInputBorder(),
                          ),
                          controller: TextEditingController(
                            text:
                                toDate == null
                                    ? ''
                                    : dateFormat.format(toDate!),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Submit'),
              ),
            ),

            // Chart (after API response)
            if (apiFuture != null)
              FutureBuilder<Map<String, dynamic>>(
                future: apiFuture,
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
                  final response = snapshot.data;
                  if (response == null ||
                      response['success'] != true ||
                      response['data'] == null) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('Failed to load chart data'),
                    );
                  }
                  final List<Map<String, dynamic>> chartData =
                      List<Map<String, dynamic>>.from(response['data']);
                  if (chartData.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No data available.'),
                    );
                  }
                  return _buildChart(chartData);
                },
              ),
          ],
        ),
      ),
    );
  }
}
