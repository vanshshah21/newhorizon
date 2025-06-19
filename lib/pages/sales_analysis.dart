// import 'dart:convert';

// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:nhapp/utils/storage_utils.dart';
// import 'package:nhapp/widgets/Dashboard/Director/sales_analysis.dart';

// class SalesAnalysisPage extends StatefulWidget {
//   const SalesAnalysisPage({super.key});

//   @override
//   State<SalesAnalysisPage> createState() => _SalesAnalysisPageState();
// }

// class _SalesAnalysisPageState extends State<SalesAnalysisPage> {
//   // API data
//   List<String> financialYears = [];
//   List<Map<String, dynamic>> salesmanList = [];
//   List<Map<String, dynamic>> regionList = [];

//   // Selections
//   String? selectedYear;
//   List<String> selectedSalesmen = [];
//   List<String> selectedRegions = [];

//   // Chart data
//   Future<List<Map<String, dynamic>>>? chartFuture;

//   // Loading state
//   bool loading = true;
//   String? error;

//   // Company details
//   late int companyId;
//   late String token;

//   // API URL
//   late String? url;

//   @override
//   void initState() {
//     super.initState();
//     _fetchInitialData();
//   }

//   Future<void> _fetchInitialData() async {
//     setState(() {
//       loading = true;
//       error = null;
//     });
//     try {
//       url = await StorageUtils.readValue('url');
//       final companyDetails = await StorageUtils.readJson('selected_company');
//       if (companyDetails == null) {
//         if (mounted) {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(const SnackBar(content: Text("Company not set")));
//         }
//         setState(() => loading = false);
//         return;
//       }

//       final tokenDetails = await StorageUtils.readJson('session_token');
//       if (tokenDetails == null) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Session token not found")),
//           );
//         }
//         setState(() => loading = false);
//         return;
//       }

//       companyId = companyDetails['id'];
//       token = tokenDetails['token']['value'];
//       final dio = Dio();

//       dio.options.headers['Content-Type'] = 'application/json';
//       dio.options.headers['Accept'] = 'application/json';
//       dio.options.headers['Authorization'] = 'Bearer $token';
//       dio.options.headers['companyid'] = companyId;

//       // Replace with your actual endpoints
//       final responses = await Future.wait([
//         dio.get(
//           'http://$url/api/Login/dash_getFNYears',
//           queryParameters: {'companyId': companyId},
//         ),
//         dio.get(
//           'http://$url/api/Login/dash_GetSalesmanCodeList',
//           queryParameters: {'companyid': companyId},
//         ),
//         dio.get(
//           'http://$url/api/Login/dash_GetRegionList',
//           queryParameters: {'companyid': companyId},
//         ),
//       ]);

//       print('Responses: ${responses.map((r) => r.data).toList()}');

//       // Parse financial years
//       final fyData =
//           responses[0].data is String
//               ? jsonDecode(responses[0].data)
//               : responses[0].data;
//       financialYears = List<String>.from(fyData['data'] ?? []);

//       // Parse salesman list
//       final smData =
//           responses[1].data is String
//               ? jsonDecode(responses[1].data)
//               : responses[1].data;
//       salesmanList = List<Map<String, dynamic>>.from(smData['data'] ?? []);

//       // Parse region list
//       final rgData =
//           responses[2].data is String
//               ? jsonDecode(responses[2].data)
//               : responses[2].data;
//       regionList = List<Map<String, dynamic>>.from(rgData['data'] ?? []);

//       setState(() {
//         loading = false;
//         // Optionally set defaults
//         selectedYear = financialYears.isNotEmpty ? financialYears.first : null;
//       });
//     } catch (e) {
//       setState(() {
//         loading = false;
//         error = 'Failed to load initial data: $e';
//       });
//     }
//   }

//   void _showMultiSelectSheet({
//     required List<Map<String, dynamic>> options,
//     required List<String> selected,
//     required String labelKey,
//     required String valueKey,
//     required String title,
//     required void Function(List<String>) onSave,
//   }) {
//     final tempSelected = List<String>.from(selected);
//     showModalBottomSheet(
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
//               maxChildSize: 0.9,
//               expand: false,
//               builder: (context, scrollController) {
//                 return Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
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
//                           Padding(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Text(
//                               title,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 18,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Expanded(
//                       child: ListView(
//                         controller: scrollController,
//                         children:
//                             options.map((option) {
//                               final value = option[valueKey]?.toString() ?? '';
//                               final label = option[labelKey]?.toString() ?? '';
//                               return CheckboxListTile(
//                                 title: Text(label),
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
//                     SafeArea(
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             child: const Text('Save'),
//                             onPressed: () {
//                               onSave(List<String>.from(tempSelected));
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

//   Future<List<Map<String, dynamic>>> _fetchChartData() async {
//     // For demo, use the first selected salesman and region
//     final spcode =
//         selectedSalesmen.isNotEmpty ? selectedSalesmen.join(",") : '';
//     final srcode = selectedRegions.isNotEmpty ? selectedRegions.join(",") : '';
//     final fnyear = selectedYear ?? '';
//     const curtype = 'A';
//     print(spcode);
//     print(srcode);

//     final dio = Dio();
//     dio.options.headers['Content-Type'] = 'application/json';
//     dio.options.headers['Accept'] = 'application/json';
//     dio.options.headers['Authorization'] = 'Bearer $token';
//     dio.options.headers['companyid'] = companyId;
//     final response = await dio.get(
//       'http://$url/api/Login/dash_FetchSalesAnalysisData',
//       queryParameters: {
//         'companyId': companyId,
//         'spcode': spcode,
//         'srcode': srcode,
//         'fnyear': fnyear,
//         'curtype': curtype,
//       },
//     );

//     if (response.statusCode == 200) {
//       final data =
//           response.data is String ? jsonDecode(response.data) : response.data;
//       final list = data['data'];
//       if (list is List && list.isNotEmpty) {
//         return List<Map<String, dynamic>>.from(list);
//       } else {
//         return [];
//       }
//     } else {
//       throw Exception('Failed with status: ${response.statusCode}');
//     }
//   }

//   Widget _buildChart(List<Map<String, dynamic>> data) {
//     print('Chart data: $data');
//     return SalesAnalysisChart(chartData: data);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Sales Analysis')),
//       body:
//           loading
//               ? const Center(child: CircularProgressIndicator())
//               : error != null
//               ? Center(child: Text(error!))
//               : SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Financial Year Dropdown
//                     Text(
//                       'Financial Year',
//                       style: Theme.of(context).textTheme.titleMedium,
//                     ),
//                     const SizedBox(height: 8),
//                     DropdownButtonFormField<String>(
//                       value: selectedYear,
//                       items:
//                           financialYears
//                               .map(
//                                 (fy) => DropdownMenuItem<String>(
//                                   value: fy,
//                                   child: Text(fy),
//                                 ),
//                               )
//                               .toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           selectedYear = value;
//                         });
//                       },
//                       decoration: const InputDecoration(
//                         border: OutlineInputBorder(),
//                         contentPadding: EdgeInsets.symmetric(horizontal: 12),
//                       ),
//                     ),
//                     const SizedBox(height: 24),

//                     // Salesman Multi-select
//                     Text(
//                       'Select Salesman',
//                       style: Theme.of(context).textTheme.titleMedium,
//                     ),
//                     const SizedBox(height: 8),
//                     GestureDetector(
//                       onTap: () {
//                         _showMultiSelectSheet(
//                           options: salesmanList,
//                           selected: selectedSalesmen,
//                           labelKey: 'salesmanFullName',
//                           valueKey: 'salesmanCode',
//                           title: 'Select Salesman',
//                           onSave: (values) {
//                             setState(() {
//                               selectedSalesmen = values;
//                             });
//                           },
//                         );
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 16,
//                         ),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey.shade400),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 selectedSalesmen.isEmpty
//                                     ? 'Select salesman'
//                                     : salesmanList
//                                         .where(
//                                           (o) => selectedSalesmen.contains(
//                                             o['salesmanCode'],
//                                           ),
//                                         )
//                                         .map((o) => o['salesmanFullName'])
//                                         .join(', '),
//                                 style: TextStyle(
//                                   color:
//                                       selectedSalesmen.isEmpty
//                                           ? Colors.grey
//                                           : Colors.black,
//                                 ),
//                               ),
//                             ),
//                             const Icon(Icons.arrow_drop_down),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 24),

//                     // Region Multi-select
//                     Text(
//                       'Select Region',
//                       style: Theme.of(context).textTheme.titleMedium,
//                     ),
//                     const SizedBox(height: 8),
//                     GestureDetector(
//                       onTap: () {
//                         _showMultiSelectSheet(
//                           options: regionList,
//                           selected: selectedRegions,
//                           labelKey: 'codeFullName',
//                           valueKey: 'code',
//                           title: 'Select Region',
//                           onSave: (values) {
//                             setState(() {
//                               selectedRegions = values;
//                             });
//                           },
//                         );
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 16,
//                         ),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey.shade400),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 selectedRegions.isEmpty
//                                     ? 'Select region'
//                                     : regionList
//                                         .where(
//                                           (o) => selectedRegions.contains(
//                                             o['code'],
//                                           ),
//                                         )
//                                         .map((o) => o['codeFullName'])
//                                         .join(', '),
//                                 style: TextStyle(
//                                   color:
//                                       selectedRegions.isEmpty
//                                           ? Colors.grey
//                                           : Colors.black,
//                                 ),
//                               ),
//                             ),
//                             const Icon(Icons.arrow_drop_down),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 24),

//                     // Submit button
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           if (selectedYear == null ||
//                               selectedSalesmen.isEmpty ||
//                               selectedRegions.isEmpty) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text(
//                                   'Please select all required fields',
//                                 ),
//                               ),
//                             );
//                             return;
//                           }
//                           setState(() {
//                             chartFuture = _fetchChartData();
//                           });
//                         },
//                         child: const Text('Submit'),
//                       ),
//                     ),

//                     // Chart
//                     if (chartFuture != null)
//                       FutureBuilder<List<Map<String, dynamic>>>(
//                         future: chartFuture,
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState ==
//                               ConnectionState.waiting) {
//                             return const Padding(
//                               padding: EdgeInsets.all(32.0),
//                               child: Center(child: CircularProgressIndicator()),
//                             );
//                           }
//                           if (snapshot.hasError) {
//                             return Padding(
//                               padding: const EdgeInsets.all(32.0),
//                               child: Text('Error: ${snapshot.error}'),
//                             );
//                           }
//                           final data = snapshot.data;
//                           if (data == null || data.isEmpty) {
//                             return const Padding(
//                               padding: EdgeInsets.all(32.0),
//                               child: Text('No data to display'),
//                             );
//                           }
//                           return _buildChart(data);
//                         },
//                       ),
//                   ],
//                 ),
//               ),
//     );
//   }
// }

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:nhapp/utils/storage_utils.dart';
import 'package:nhapp/utils/token_utils.dart'; // <-- Add this import
import 'package:nhapp/widgets/Dashboard/Director/sales_analysis.dart';

class SalesAnalysisPage extends StatefulWidget {
  const SalesAnalysisPage({super.key});

  @override
  State<SalesAnalysisPage> createState() => _SalesAnalysisPageState();
}

class _SalesAnalysisPageState extends State<SalesAnalysisPage> {
  // API data
  List<String> financialYears = [];
  List<Map<String, dynamic>> salesmanList = [];
  List<Map<String, dynamic>> regionList = [];

  // Selections
  String? selectedYear;
  List<String> selectedSalesmen = [];
  List<String> selectedRegions = [];

  // Chart data
  Future<List<Map<String, dynamic>>>? chartFuture;

  // Loading state
  bool loading = true;
  String? error;

  // Company details
  late int companyId;
  late String token;

  // API URL
  late String? url;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      loading = true;
      error = null;
    });

    // 1. Validate token before any API call
    final isValid = await TokenUtils.isTokenValid(context);
    if (!isValid) {
      _showSnackBar("Session expired. Please log in again.");
      setState(() => loading = false);
      return;
    }

    try {
      url = await StorageUtils.readValue('url');
      final companyDetails = await StorageUtils.readJson('selected_company');
      final tokenDetails = await StorageUtils.readJson('session_token');

      if (companyDetails == null) {
        _showSnackBar("Company not set");
        setState(() => loading = false);
        return;
      }
      if (tokenDetails == null) {
        _showSnackBar("Session token not found");
        setState(() => loading = false);
        return;
      }

      companyId = companyDetails['id'];
      token = tokenDetails['token']['value'];
      final dio = Dio();

      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Accept'] = 'application/json';
      dio.options.headers['Authorization'] = 'Bearer $token';
      dio.options.headers['companyid'] = companyId;

      // Fetch all initial data in parallel
      final responses = await Future.wait([
        dio.get(
          'http://$url/api/Login/dash_getFNYears',
          queryParameters: {'companyId': companyId},
        ),
        dio.get(
          'http://$url/api/Login/dash_GetSalesmanCodeList',
          queryParameters: {'companyid': companyId},
        ),
        dio.get(
          'http://$url/api/Login/dash_GetRegionList',
          queryParameters: {'companyid': companyId},
        ),
      ]);

      // Parse all responses in isolates
      final fyData = await compute(_parseJson, responses[0].data);
      final smData = await compute(_parseJson, responses[1].data);
      final rgData = await compute(_parseJson, responses[2].data);

      financialYears = List<String>.from(fyData['data'] ?? []);
      salesmanList = List<Map<String, dynamic>>.from(smData['data'] ?? []);
      regionList = List<Map<String, dynamic>>.from(rgData['data'] ?? []);

      setState(() {
        loading = false;
        selectedYear = financialYears.isNotEmpty ? financialYears.first : null;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = 'Failed to load initial data: $e';
      });
    }
  }

  void _showMultiSelectSheet({
    required List<Map<String, dynamic>> options,
    required List<String> selected,
    required String labelKey,
    required String valueKey,
    required String title,
    required void Function(List<String>) onSave,
  }) {
    final tempSelected = List<String>.from(selected);
    showModalBottomSheet(
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
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        children:
                            options.map((option) {
                              final value = option[valueKey]?.toString() ?? '';
                              final label = option[labelKey]?.toString() ?? '';
                              return CheckboxListTile(
                                title: Text(label),
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
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            child: const Text('Save'),
                            onPressed: () {
                              onSave(List<String>.from(tempSelected));
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

  Future<List<Map<String, dynamic>>> _fetchChartData() async {
    // Validate token before API call
    final isValid = await TokenUtils.isTokenValid(context);
    if (!isValid) {
      _showSnackBar("Session expired. Please log in again.");
      return [];
    }

    final spcode =
        selectedSalesmen.isNotEmpty ? selectedSalesmen.join(",") : '';
    final srcode = selectedRegions.isNotEmpty ? selectedRegions.join(",") : '';
    final fnyear = selectedYear ?? '';
    const curtype = 'A';

    final dio = Dio();
    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Accept'] = 'application/json';
    dio.options.headers['Authorization'] = 'Bearer $token';
    dio.options.headers['companyid'] = companyId;

    try {
      final response = await dio.get(
        'http://$url/api/Login/dash_FetchSalesAnalysisData',
        queryParameters: {
          'companyId': companyId,
          'spcode': spcode,
          'srcode': srcode,
          'fnyear': fnyear,
          'curtype': curtype,
        },
      );

      if (response.statusCode == 200) {
        final data = await compute(_parseJson, response.data);
        final list = data['data'];
        if (list is List && list.isNotEmpty) {
          return List<Map<String, dynamic>>.from(list);
        } else {
          return [];
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
      return [];
    } catch (e) {
      _showSnackBar('Error loading chart data: $e');
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
    return SalesAnalysisChart(chartData: data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales Analysis')),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(child: Text(error!))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Financial Year Dropdown
                    Text(
                      'Financial Year',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedYear,
                      items:
                          financialYears
                              .map(
                                (fy) => DropdownMenuItem<String>(
                                  value: fy,
                                  child: Text(fy),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedYear = value;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Salesman Multi-select
                    Text(
                      'Select Salesman',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        _showMultiSelectSheet(
                          options: salesmanList,
                          selected: selectedSalesmen,
                          labelKey: 'salesmanFullName',
                          valueKey: 'salesmanCode',
                          title: 'Select Salesman',
                          onSave: (values) {
                            setState(() {
                              selectedSalesmen = values;
                            });
                          },
                        );
                      },
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
                                selectedSalesmen.isEmpty
                                    ? 'Select salesman'
                                    : salesmanList
                                        .where(
                                          (o) => selectedSalesmen.contains(
                                            o['salesmanCode'],
                                          ),
                                        )
                                        .map((o) => o['salesmanFullName'])
                                        .join(', '),
                                style: TextStyle(
                                  color:
                                      selectedSalesmen.isEmpty
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

                    // Region Multi-select
                    Text(
                      'Select Region',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        _showMultiSelectSheet(
                          options: regionList,
                          selected: selectedRegions,
                          labelKey: 'codeFullName',
                          valueKey: 'code',
                          title: 'Select Region',
                          onSave: (values) {
                            setState(() {
                              selectedRegions = values;
                            });
                          },
                        );
                      },
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
                                selectedRegions.isEmpty
                                    ? 'Select region'
                                    : regionList
                                        .where(
                                          (o) => selectedRegions.contains(
                                            o['code'],
                                          ),
                                        )
                                        .map((o) => o['codeFullName'])
                                        .join(', '),
                                style: TextStyle(
                                  color:
                                      selectedRegions.isEmpty
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

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (selectedYear == null ||
                              selectedSalesmen.isEmpty ||
                              selectedRegions.isEmpty) {
                            _showSnackBar('Please select all required fields');
                            return;
                          }
                          setState(() {
                            chartFuture = _fetchChartData();
                          });
                        },
                        child: const Text('Submit'),
                      ),
                    ),

                    // Chart
                    if (chartFuture != null)
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: chartFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
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
