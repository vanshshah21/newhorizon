// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:nhapp/utils/storage_utils.dart';
// import 'package:intl/intl.dart' as intl;

// class DeliveryOverdue extends StatefulWidget {
//   const DeliveryOverdue({super.key});

//   @override
//   State<DeliveryOverdue> createState() => _DeliveryOverdueState();
// }

// class _DeliveryOverdueState extends State<DeliveryOverdue> {
//   late Future<List<DeliveryOverdueItem>> _futureItems;
//   List<DeliveryOverdueItem> _allItems = [];
//   List<DeliveryOverdueItem> _filteredItems = [];
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _futureItems = fetchDeliveryOverdueItems();
//     _searchController.addListener(_onSearchChanged);
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<List<DeliveryOverdueItem>> fetchDeliveryOverdueItems() async {
//     final url = await StorageUtils.readValue('url');

//     final companyDetails = await StorageUtils.readJson('selected_company');
//     if (companyDetails == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Company not set")));
//       }
//       return [];
//     }

//     final locationDetails = await StorageUtils.readJson('selected_location');
//     if (locationDetails == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Location not set")));
//       }
//     }

//     final tokenDetails = await StorageUtils.readJson('session_token');
//     if (tokenDetails == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Session token not found")));
//       }
//     }

//     final companyId = companyDetails['id'];
//     final locationId = locationDetails['id'];
//     final token = tokenDetails['token']['value'];
//     final dio = Dio();

//     dio.options.headers['Content-Type'] = 'application/json';
//     dio.options.headers['Authorization'] = 'Bearer $token';
//     final response = await dio.get(
//       'http://$url/api/Login/dash_DeliveryOverdueItemwise',
//       queryParameters: {'companyid': companyId, 'siteid': locationId},
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.data)['data'] as List<dynamic>;
//       final deliverylist =
//           data.map((e) => DeliveryOverdueItem.fromJson(e)).toList();
//       _allItems = deliverylist;
//       _filteredItems = deliverylist;
//       return deliverylist;
//     } else {
//       throw Exception('Failed to load items');
//     }
//   }

//   void _onSearchChanged() {
//     final query = _searchController.text.toLowerCase();
//     setState(() {
//       _filteredItems =
//           _allItems.where((item) {
//             return item.itemName.toLowerCase().contains(query) ||
//                 item.poNo.toLowerCase().contains(query) ||
//                 item.code.toLowerCase().contains(query) ||
//                 item.uom.toLowerCase().contains(query);
//           }).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFF1F1F1),
//       appBar: AppBar(title: const Text('Delivery overdue items')),
//       body: FutureBuilder<List<DeliveryOverdueItem>>(
//         future: _futureItems,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No items found.'));
//           }

//           // Only set _allItems and _filteredItems if they are empty (first build)
//           if (_allItems.isEmpty) {
//             _allItems = snapshot.data!;
//             _filteredItems = _allItems;
//           }

//           return Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       labelText: 'Search by Item, PO No, Code, UOM',
//                       prefixIcon: Icon(Icons.search),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child:
//                       _filteredItems.isEmpty
//                           ? const Center(
//                             child: Text('No items match your search.'),
//                           )
//                           : ListView.builder(
//                             itemCount: _filteredItems.length,
//                             itemBuilder: (context, index) {
//                               final item = _filteredItems[index];
//                               return Card(
//                                 margin: const EdgeInsets.symmetric(
//                                   horizontal: 8,
//                                   vertical: 4,
//                                 ),
//                                 child: ExpansionTile(
//                                   title: Text(
//                                     item.itemName,
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   subtitle: Text(
//                                     'PO No: ${item.poNo} | Delivery Qty: ${item.deliveryQty}',
//                                   ),
//                                   children: [
//                                     ListTile(
//                                       title: Text('Code: ${item.code}'),
//                                       subtitle: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             'PO Date: ${intl.DateFormat("dd/MM/yyyy").format(item.poDate)}',
//                                           ),
//                                           Text(
//                                             'Delivery Date: ${intl.DateFormat("dd/MM/yyyy").format(item.deliveryDate)}',
//                                           ),
//                                           Text(
//                                             'Qty: ${item.qty} ${item.uom.trim()}',
//                                           ),
//                                           Text(
//                                             'Rate: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: '').format(item.rate)}',
//                                           ),
//                                           Text(
//                                             'Amount: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: "").format(item.amount)}',
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             },
//                           ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class DeliveryOverdueItem {
//   final int deliveryQty;
//   final DateTime deliveryDate;
//   final String poNo;
//   final String itemName;
//   final String code;
//   final DateTime poDate;
//   final double qty;
//   final double rate;
//   final String uom;
//   final double amount;

//   DeliveryOverdueItem({
//     required this.deliveryQty,
//     required this.deliveryDate,
//     required this.poNo,
//     required this.itemName,
//     required this.code,
//     required this.poDate,
//     required this.qty,
//     required this.rate,
//     required this.uom,
//     required this.amount,
//   });

//   factory DeliveryOverdueItem.fromJson(Map<String, dynamic> json) {
//     print("JSON: ${json['amount']}, ${json['amount'].runtimeType}");
//     return DeliveryOverdueItem(
//       deliveryQty: json['deliveryQty'] ?? 0,
//       deliveryDate: DateTime.parse(json['deliveryDate']),
//       poNo: json['poNo'] ?? '',
//       itemName: json['itemName'] ?? '',
//       code: json['code'] ?? '',
//       poDate: DateTime.parse(json['poDate']),
//       qty: json['qty'] ?? 0.00,
//       rate: double.parse(json['rate']),
//       uom: json['uom'] ?? '',
//       amount: double.parse(json['amount']),
//     );
//   }
// }
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:nhapp/utils/storage_utils.dart';
// import 'package:intl/intl.dart' as intl;

// class DeliveryOverdue extends StatefulWidget {
//   const DeliveryOverdue({super.key});

//   @override
//   State<DeliveryOverdue> createState() => _DeliveryOverdueState();
// }

// class _DeliveryOverdueState extends State<DeliveryOverdue> {
//   late Future<List<DeliveryOverdueItem>> _futureItems;
//   final List<DeliveryOverdueItem> _allItems = [];
//   final ValueNotifier<List<DeliveryOverdueItem>> _filteredItems = ValueNotifier(
//     [],
//   );
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _futureItems = fetchDeliveryOverdueItems();
//     _searchController.addListener(_onSearchChanged);
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _filteredItems.dispose();
//     super.dispose();
//   }

//   Future<List<DeliveryOverdueItem>> fetchDeliveryOverdueItems() async {
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

//     final locationDetails = await StorageUtils.readJson('selected_location');
//     if (locationDetails == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("Location not set")));
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
//     final locationId = locationDetails['id'];
//     final token = tokenDetails['token']['value'];
//     final dio = Dio();

//     dio.options.headers['Content-Type'] = 'application/json';
//     dio.options.headers['Authorization'] = 'Bearer $token';
//     final response = await dio.get(
//       'http://$url/api/Login/dash_DeliveryOverdueItemwise',
//       queryParameters: {'companyid': companyId, 'siteid': locationId},
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.data)['data'] as List<dynamic>;
//       final deliveryList =
//           data.map((e) => DeliveryOverdueItem.fromJson(e)).toList();
//       _allItems.clear();
//       _allItems.addAll(deliveryList);
//       _filteredItems.value = List.from(_allItems);
//       return deliveryList;
//     } else {
//       throw Exception('Failed to load items');
//     }
//   }

//   void _onSearchChanged() {
//     final query = _searchController.text.trim().toLowerCase();
//     if (query.isEmpty) {
//       _filteredItems.value = List.from(_allItems);
//     } else {
//       _filteredItems.value =
//           _allItems.where((item) {
//             return item.itemName.toLowerCase().contains(query) ||
//                 item.poNo.toLowerCase().contains(query) ||
//                 item.code.toLowerCase().contains(query) ||
//                 item.uom.toLowerCase().contains(query);
//           }).toList();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF1F1F1),
//       appBar: AppBar(title: const Text('Delivery overdue items')),
//       body: FutureBuilder<List<DeliveryOverdueItem>>(
//         future: _futureItems,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No items found.'));
//           }

//           return Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       labelText: 'Search by Item, PO No, Code, UOM',
//                       prefixIcon: const Icon(Icons.search),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: ValueListenableBuilder<List<DeliveryOverdueItem>>(
//                     valueListenable: _filteredItems,
//                     builder: (context, filtered, _) {
//                       if (filtered.isEmpty) {
//                         return const Center(
//                           child: Text('No items match your search.'),
//                         );
//                       }
//                       return ListView.builder(
//                         itemCount: filtered.length,
//                         itemBuilder: (context, index) {
//                           final item = filtered[index];
//                           return Card(
//                             margin: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 4,
//                             ),
//                             child: ExpansionTile(
//                               title: Text(
//                                 item.itemName,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               subtitle: Text(
//                                 'PO No: ${item.poNo} | Delivery Qty: ${item.deliveryQty}',
//                               ),
//                               children: [
//                                 ListTile(
//                                   title: Text('Code: ${item.code}'),
//                                   subtitle: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         'PO Date: ${intl.DateFormat("dd/MM/yyyy").format(item.poDate)}',
//                                       ),
//                                       Text(
//                                         'Delivery Date: ${intl.DateFormat("dd/MM/yyyy").format(item.deliveryDate)}',
//                                       ),
//                                       Text(
//                                         'Qty: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 4).format(item.qty)} ${item.uom.trim()}',
//                                       ),
//                                       Text(
//                                         'Rate: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: '').format(item.rate)}',
//                                       ),
//                                       Text(
//                                         'Amount: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: "").format(item.amount)}',
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class DeliveryOverdueItem {
//   final int deliveryQty;
//   final DateTime deliveryDate;
//   final String poNo;
//   final String itemName;
//   final String code;
//   final DateTime poDate;
//   final double qty;
//   final double rate;
//   final String uom;
//   final double amount;

//   DeliveryOverdueItem({
//     required this.deliveryQty,
//     required this.deliveryDate,
//     required this.poNo,
//     required this.itemName,
//     required this.code,
//     required this.poDate,
//     required this.qty,
//     required this.rate,
//     required this.uom,
//     required this.amount,
//   });

//   factory DeliveryOverdueItem.fromJson(Map<String, dynamic> json) {
//     double parseDouble(dynamic value) {
//       if (value is num) return value.toDouble();
//       if (value is String) return double.tryParse(value) ?? 0.0;
//       return 0.0;
//     }

//     return DeliveryOverdueItem(
//       deliveryQty: json['deliveryQty'] ?? 0,
//       deliveryDate: DateTime.parse(json['deliveryDate']),
//       poNo: json['poNo'] ?? '',
//       itemName: json['itemName'] ?? '',
//       code: json['code'] ?? '',
//       poDate: DateTime.parse(json['poDate']),
//       qty: parseDouble(json['qty']),
//       rate: parseDouble(json['rate']),
//       uom: json['uom'] ?? '',
//       amount: parseDouble(json['amount']),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nhapp/utils/storage_utils.dart';
import 'package:nhapp/utils/token_utils.dart'; // <-- Add this import
import 'package:intl/intl.dart' as intl;

class DeliveryOverdue extends StatefulWidget {
  const DeliveryOverdue({super.key});

  @override
  State<DeliveryOverdue> createState() => _DeliveryOverdueState();
}

class _DeliveryOverdueState extends State<DeliveryOverdue> {
  late Future<List<DeliveryOverdueItem>> _futureItems;
  final List<DeliveryOverdueItem> _allItems = [];
  final ValueNotifier<List<DeliveryOverdueItem>> _filteredItems = ValueNotifier(
    [],
  );
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureItems = fetchDeliveryOverdueItems();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filteredItems.dispose();
    super.dispose();
  }

  Future<List<DeliveryOverdueItem>> fetchDeliveryOverdueItems() async {
    // 1. Validate token before API call
    final isValid = await TokenUtils.isTokenValid(context);
    if (!isValid) {
      _showSnackBar("Session expired. Please log in again.");
      return [];
    }

    try {
      final url = await StorageUtils.readValue('url');
      final companyDetails = await StorageUtils.readJson('selected_company');
      if (companyDetails == null) {
        _showSnackBar("Company not set");
        return [];
      }

      final locationDetails = await StorageUtils.readJson('selected_location');
      if (locationDetails == null) {
        _showSnackBar("Location not set");
        return [];
      }

      final tokenDetails = await StorageUtils.readJson('session_token');
      if (tokenDetails == null) {
        _showSnackBar("Session token not found");
        return [];
      }

      final companyId = companyDetails['id'];
      final locationId = locationDetails['id'];
      final token = tokenDetails['token']['value'];
      final dio = Dio();

      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await dio.get(
        'http://$url/api/Login/dash_DeliveryOverdueItemwise',
        queryParameters: {'companyid': companyId, 'siteid': locationId},
      );

      if (response.statusCode == 200) {
        // Parse JSON in a background isolate for large responses
        final data = await compute(_parseJson, response.data);
        final List<dynamic> items = data['data'] ?? [];
        final deliveryList =
            items.map((e) => DeliveryOverdueItem.fromJson(e)).toList();
        _allItems.clear();
        _allItems.addAll(deliveryList);
        _filteredItems.value = List.from(_allItems);
        return deliveryList;
      } else {
        throw Exception('Failed to load items');
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
      _showSnackBar("Exception: $e");
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

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      _filteredItems.value = List.from(_allItems);
    } else {
      _filteredItems.value =
          _allItems.where((item) {
            return item.itemName.toLowerCase().contains(query) ||
                item.poNo.toLowerCase().contains(query) ||
                item.code.toLowerCase().contains(query) ||
                item.uom.toLowerCase().contains(query);
          }).toList();
    }
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
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(title: const Text('Delivery overdue items')),
      body: FutureBuilder<List<DeliveryOverdueItem>>(
        future: _futureItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No items found.'));
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search by Item, PO No, Code, UOM',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ValueListenableBuilder<List<DeliveryOverdueItem>>(
                    valueListenable: _filteredItems,
                    builder: (context, filtered, _) {
                      if (filtered.isEmpty) {
                        return const Center(
                          child: Text('No items match your search.'),
                        );
                      }
                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ExpansionTile(
                              title: Text(
                                item.itemName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'PO No: ${item.poNo} | Delivery Qty: ${item.deliveryQty}',
                              ),
                              children: [
                                ListTile(
                                  title: Text('Code: ${item.code}'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'PO Date: ${intl.DateFormat("dd/MM/yyyy").format(item.poDate)}',
                                      ),
                                      Text(
                                        'Delivery Date: ${intl.DateFormat("dd/MM/yyyy").format(item.deliveryDate)}',
                                      ),
                                      Text(
                                        'Qty: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 4).format(item.qty)} ${item.uom.trim()}',
                                      ),
                                      Text(
                                        'Rate: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: '').format(item.rate)}',
                                      ),
                                      Text(
                                        'Amount: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: "").format(item.amount)}',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DeliveryOverdueItem {
  final int deliveryQty;
  final DateTime deliveryDate;
  final String poNo;
  final String itemName;
  final String code;
  final DateTime poDate;
  final double qty;
  final double rate;
  final String uom;
  final double amount;

  DeliveryOverdueItem({
    required this.deliveryQty,
    required this.deliveryDate,
    required this.poNo,
    required this.itemName,
    required this.code,
    required this.poDate,
    required this.qty,
    required this.rate,
    required this.uom,
    required this.amount,
  });

  factory DeliveryOverdueItem.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return DeliveryOverdueItem(
      deliveryQty: json['deliveryQty'] ?? 0,
      deliveryDate: DateTime.parse(json['deliveryDate']),
      poNo: json['poNo'] ?? '',
      itemName: json['itemName'] ?? '',
      code: json['code'] ?? '',
      poDate: DateTime.parse(json['poDate']),
      qty: parseDouble(json['qty']),
      rate: parseDouble(json['rate']),
      uom: json['uom'] ?? '',
      amount: parseDouble(json['amount']),
    );
  }
}
