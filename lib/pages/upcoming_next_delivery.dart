// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:nhapp/utils/storage_utils.dart';
// import 'package:intl/intl.dart' as intl;

// class UpcomingNextDelivery extends StatefulWidget {
//   const UpcomingNextDelivery({super.key});

//   @override
//   State<UpcomingNextDelivery> createState() => _UpcomingNextDeliveryState();
// }

// class _UpcomingNextDeliveryState extends State<UpcomingNextDelivery> {
//   late Future<List<UpcomingDeliveryItem>> _futureItems;
//   List<UpcomingDeliveryItem> _allItems = [];
//   List<UpcomingDeliveryItem> _filteredItems = [];
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _futureItems = fetchUpcomingDeliveryItems();
//     _searchController.addListener(_onSearchChanged);
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<List<UpcomingDeliveryItem>> fetchUpcomingDeliveryItems() async {
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
//       'http://$url/api/Login/dash_UpcomingNextDelivery',
//       queryParameters: {'companyid': companyId, 'siteid': locationId},
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.data)['data'] as List<dynamic>;
//       final deliverylist =
//           data.map((e) => UpcomingDeliveryItem.fromJson(e)).toList();
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
//       appBar: AppBar(title: const Text('Upcoming Delivery')),
//       body: FutureBuilder<List<UpcomingDeliveryItem>>(
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
//                                             'Rate: ${intl.NumberFormat.compact(locale: 'en_IN').format(double.parse(item.rate))}',
//                                           ),
//                                           Text(
//                                             'Amount: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: "").format(double.parse(item.amount))}',
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

// class UpcomingDeliveryItem {
//   final int deliveryQty;
//   final DateTime deliveryDate;
//   final String poNo;
//   final String itemName;
//   final String code;
//   final DateTime poDate;
//   final double qty;
//   final String rate;
//   final String uom;
//   final String amount;

//   UpcomingDeliveryItem({
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

//   factory UpcomingDeliveryItem.fromJson(Map<String, dynamic> json) {
//     return UpcomingDeliveryItem(
//       deliveryQty: json['deliveryQty'] ?? 0,
//       deliveryDate: DateTime.parse(json['deliveryDate']),
//       poNo: json['poNo'] ?? '',
//       itemName: json['itemName'] ?? '',
//       code: json['code'] ?? '',
//       poDate: DateTime.parse(json['poDate']),
//       qty: (json['qty'] as num).toDouble(),
//       rate: json['rate'] ?? '',
//       uom: json['uom'] ?? '',
//       amount: json['amount'] ?? '',
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart' as intl;
import 'package:nhapp/utils/storage_utils.dart';

class UpcomingNextDelivery extends StatefulWidget {
  const UpcomingNextDelivery({super.key});

  @override
  State<UpcomingNextDelivery> createState() => _UpcomingNextDeliveryState();
}

class _UpcomingNextDeliveryState extends State<UpcomingNextDelivery> {
  late Future<List<UpcomingDeliveryItem>> _futureItems;
  final List<UpcomingDeliveryItem> _allItems = [];
  final ValueNotifier<List<UpcomingDeliveryItem>> _filteredItems =
      ValueNotifier([]);
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureItems = fetchUpcomingDeliveryItems();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filteredItems.dispose();
    super.dispose();
  }

  Future<List<UpcomingDeliveryItem>> fetchUpcomingDeliveryItems() async {
    final url = await StorageUtils.readValue('url');

    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Company not set")));
      }
      return [];
    }

    final locationDetails = await StorageUtils.readJson('selected_location');
    if (locationDetails == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Location not set")));
      }
      return [];
    }

    final tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session token not found")),
        );
      }
      return [];
    }

    final companyId = companyDetails['id'];
    final locationId = locationDetails['id'];
    final token = tokenDetails['token']['value'];
    final dio = Dio();

    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Authorization'] = 'Bearer $token';
    final response = await dio.get(
      'http://$url/api/Login/dash_UpcomingNextDelivery',
      queryParameters: {'companyid': companyId, 'siteid': locationId},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.data)['data'] as List<dynamic>;
      final deliveryList =
          data.map((e) => UpcomingDeliveryItem.fromJson(e)).toList();
      _allItems.clear();
      _allItems.addAll(deliveryList);
      _filteredItems.value = List.from(_allItems);
      return deliveryList;
    } else {
      throw Exception('Failed to load items');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(title: const Text('Upcoming Delivery')),
      body: FutureBuilder<List<UpcomingDeliveryItem>>(
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
                  child: ValueListenableBuilder<List<UpcomingDeliveryItem>>(
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
                                        'Rate: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 2).format(item.rate)}',
                                      ),
                                      Text(
                                        'Amount: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: "", decimalDigits: 2).format(item.amount)}',
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

class UpcomingDeliveryItem {
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

  UpcomingDeliveryItem({
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

  factory UpcomingDeliveryItem.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return UpcomingDeliveryItem(
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
