// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class AuthorizePurchaseOrderScreen extends StatefulWidget {
//   const AuthorizePurchaseOrderScreen({super.key});

//   @override
//   _AuthorizePurchaseOrderScreenState createState() =>
//       _AuthorizePurchaseOrderScreenState();
// }

// class _AuthorizePurchaseOrderScreenState
//     extends State<AuthorizePurchaseOrderScreen>
//     with TickerProviderStateMixin {
//   late TabController _tabController;
//   final TextEditingController _searchControllerTab1 = TextEditingController();
//   final TextEditingController _searchControllerTab2 = TextEditingController();
//   String _searchTextTab1 = '';
//   String _searchTextTab2 = '';
//   final List<int> _selectedItemsTab1 = [];
//   final List<int> _selectedItemsTab2 = [];
//   late Future<List<dynamic>> futureItemsTab1;
//   late Future<List<dynamic>> futureItemsTab2; // Changed type to match tab1
//   Map<String, dynamic>? receivedData;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);

//     // Initialize with empty list, will be populated in didChangeDependencies
//     futureItemsTab1 = Future.value([]);
//     futureItemsTab2 = _fetchItems2();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // Get the arguments passed from the previous screen
//     receivedData =
//         ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

//     if (receivedData != null && receivedData!['data'] != null) {
//       // Use the passed data directly
//       futureItemsTab1 = Future.value(receivedData!['data']);
//     } else {
//       // Fall back to API call if no data was passed
//       futureItemsTab1 = _fetchItems1();
//     }
//   }

//   Future<List<dynamic>> _fetchItems1() async {
//     try {
//       final storage = FlutterSecureStorage();
//       final url = await storage.read(key: 'url');

//       final companyDetails = await storage.read(key: 'selected_company');
//       if (companyDetails == null || companyDetails.isEmpty) {
//         if (mounted) {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(SnackBar(content: Text("Company not selected")));
//         }
//         throw Exception("Company not selected");
//       }

//       final companyId = jsonDecode(companyDetails)['id'];
//       final locationDetails = await storage.read(key: 'selected_location');
//       if (locationDetails == null || locationDetails.isEmpty) {
//         if (mounted) {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(SnackBar(content: Text("Location not selected")));
//         }
//         throw Exception("Location not selected");
//       }

//       final locationId = jsonDecode(locationDetails)['id'];
//       final tokenDetails = await storage.read(key: 'session_token');
//       if (tokenDetails == null || tokenDetails.isEmpty) {
//         if (mounted) {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(SnackBar(content: Text("Session token not found")));
//         }
//         throw Exception("Session token not found");
//       }

//       final token =
//           jsonDecode(
//             tokenDetails,
//           )['token']['value']; // Added token back as it's needed
//       final userId = jsonDecode(tokenDetails)['user']['id'];

//       final poRegularBody = {
//         "pageNumber": 1,
//         "pageSize": 100,
//         "sortField": "",
//         "sortDirection": "",
//         "searchValue": null,
//         "potype": "'R'",
//         "usrLvl": 0,
//         "usrSubLvl": 0,
//         "mulLvlAuthRed": true,
//         "valLimit": 0,
//         "docType": "PR",
//         "docSubType": "RP",
//         "companyId": companyId,
//         "userId": userId,
//       };

//       final dio = Dio();
//       dio.options.headers = {
//         // Added missing headers
//         "CompanyId": "$companyId",
//         "Content-Type": "application/json; charset=utf-8",
//         "Authorization": "Bearer $token",
//       };
//       Response response = await dio.post(
//         'http://$url/api/Podata/FetchPendingAuthPOList',
//         data: poRegularBody,
//         queryParameters: {
//           'locIds': locationId.toString(),
//           'companyId': companyId,
//           'locationId': locationId,
//         },
//       );
//       return response.data['data'] ?? [];
//     } catch (e) {
//       throw Exception('Failed to load items: $e');
//     }
//   }

//   Future<List<dynamic>> _fetchItems2() async {
//     try {
//       final storage = FlutterSecureStorage();
//       final url = await storage.read(key: 'url');

//       final companyDetails = await storage.read(key: 'selected_company');
//       if (companyDetails == null || companyDetails.isEmpty) {
//         if (mounted) {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(SnackBar(content: Text("Company not selected")));
//         }
//         throw Exception("Company not selected");
//       }

//       final companyId = jsonDecode(companyDetails)['id'];
//       final locationDetails = await storage.read(key: 'selected_location');
//       if (locationDetails == null || locationDetails.isEmpty) {
//         if (mounted) {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(SnackBar(content: Text("Location not selected")));
//         }
//         throw Exception("Location not selected");
//       }

//       final locationId = jsonDecode(locationDetails)['id'];
//       final tokenDetails = await storage.read(key: 'session_token');
//       if (tokenDetails == null || tokenDetails.isEmpty) {
//         if (mounted) {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(SnackBar(content: Text("Session token not found")));
//         }
//         throw Exception("Session token not found");
//       }

//       final token =
//           jsonDecode(
//             tokenDetails,
//           )['token']['value']; // Added token back as it's needed
//       final userId = jsonDecode(tokenDetails)['user']['id'];

//       final poCapitalBody = {
//         "pageNumber": 1,
//         "pageSize": 100,
//         "sortField": "",
//         "sortDirection": "",
//         "searchValue": null,
//         "potype": "'C'",
//         "usrLvl": 0,
//         "usrSubLvl": 0,
//         "mulLvlAuthRed": true,
//         "valLimit": 0,
//         "docType": "PR",
//         "docSubType": "CP",
//         "companyId": companyId,
//         "userId": userId,
//       };

//       final dio = Dio();
//       dio.options.headers = {
//         // Added missing headers
//         "CompanyId": "$companyId",
//         "Content-Type": "application/json; charset=utf-8",
//         "Authorization": "Bearer $token",
//       };
//       Response response = await dio.post(
//         'http://$url/api/Podata/FetchPendingAuthPOList',
//         data: poCapitalBody,
//         queryParameters: {
//           'locIds': locationId.toString(),
//           'companyId': companyId,
//           'locationId': locationId,
//         },
//       );
//       return response.data['data'] ?? [];
//     } catch (e) {
//       throw Exception('Failed to load items: $e');
//     }
//   }

//   Future<void> _refreshItems(int tabIndex) async {
//     setState(() {
//       if (tabIndex == 0) {
//         futureItemsTab1 = _fetchItems1();
//       } else {
//         futureItemsTab2 = _fetchItems2();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _searchControllerTab1.dispose();
//     _searchControllerTab2.dispose();
//     super.dispose();
//   }

//   void _toggleSelection(int index, int tabIndex) {
//     setState(() {
//       final selectedItems =
//           tabIndex == 0 ? _selectedItemsTab1 : _selectedItemsTab2;
//       if (selectedItems.contains(index)) {
//         selectedItems.remove(index);
//       } else {
//         selectedItems.add(index);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Authorize Purchase Order'),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: [Tab(text: 'Regular'), Tab(text: 'Capital')],
//           onTap: (index) {
//             if (index == 0) {
//               _searchControllerTab2.clear();
//               setState(() {
//                 _searchTextTab2 = '';
//               });
//             } else {
//               _searchControllerTab1.clear();
//               setState(() {
//                 _searchTextTab1 = '';
//               });
//             }
//           },
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: TabBarView(
//               physics: NeverScrollableScrollPhysics(),
//               controller: _tabController,
//               children: [
//                 _buildTabContent(
//                   0,
//                   _searchControllerTab1,
//                   _searchTextTab1,
//                   _selectedItemsTab1,
//                 ),
//                 _buildTabContent(
//                   1,
//                   _searchControllerTab2,
//                   _searchTextTab2,
//                   _selectedItemsTab2,
//                 ),
//               ],
//             ),
//           ),
//           if (_selectedItemsTab1.isNotEmpty || _selectedItemsTab2.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: ElevatedButton(
//                 onPressed: () {
//                   // authorization logic here
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       behavior: SnackBarBehavior.floating,
//                       showCloseIcon: true,
//                       content: Text(
//                         '${_selectedItemsTab1.isNotEmpty ? _selectedItemsTab1 : ''} ${_selectedItemsTab2.isNotEmpty ? _selectedItemsTab2 : ''} Authorized successfully! ',
//                       ),
//                     ),
//                   );
//                 },
//                 child: Text('Authorize'),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTabContent(
//     int tabIndex,
//     TextEditingController searchController,
//     String searchText,
//     List<int> selectedItems,
//   ) {
//     final futureItems = tabIndex == 0 ? futureItemsTab1 : futureItemsTab2;

//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: TextField(
//             controller: searchController,
//             decoration: InputDecoration(
//               hintText: 'Search',
//               prefixIcon: Icon(Icons.search),
//               suffixIcon: IconButton(
//                 icon: Icon(Icons.clear),
//                 onPressed: () {
//                   searchController.clear();
//                   setState(() {
//                     if (tabIndex == 0) {
//                       _searchTextTab1 = '';
//                     } else {
//                       _searchTextTab2 = '';
//                     }
//                   });
//                 },
//               ),
//             ),
//             onChanged: (text) {
//               setState(() {
//                 if (tabIndex == 0) {
//                   _searchTextTab1 = text;
//                 } else {
//                   _searchTextTab2 = text;
//                 }
//               });
//             },
//           ),
//         ),
//         Expanded(
//           child: RefreshIndicator(
//             onRefresh: () => _refreshItems(tabIndex),
//             child: FutureBuilder<List<dynamic>>(
//               // Updated type parameter
//               future: futureItems,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text('Error: ${snapshot.error}'),
//                         SizedBox(height: 10),
//                         ElevatedButton(
//                           onPressed: () => _refreshItems(tabIndex),
//                           child: Text('Retry'),
//                         ),
//                       ],
//                     ),
//                   );
//                 } else if (snapshot.hasData) {
//                   final items =
//                       tabIndex == 0
//                           ? _filterPurchaseOrders(snapshot.data!, searchText)
//                           : _filterStrings(snapshot.data!, searchText);

//                   if (items.isEmpty) {
//                     return Center(child: Text('No items found.'));
//                   }

//                   return ListView.builder(
//                     itemCount: items.length,
//                     itemBuilder: (context, index) {
//                       if (tabIndex == 0) {
//                         // Display purchase order data
//                         final item = items[index];
//                         return CheckboxListTile(
//                           title: Text("${item['nmbr']} - ${item['vendor']}"),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "Date: ${item['date']?.toString().substring(0, 10) ?? ''}",
//                               ),
//                               Text(
//                                 "Amount: ₹${item['pototalamt']?.toStringAsFixed(2) ?? ''}",
//                               ),
//                             ],
//                           ),
//                           value: selectedItems.contains(index),
//                           onChanged: (_) => _toggleSelection(index, tabIndex),
//                         );
//                       } else {
//                         // Display strings (for tab 2)
//                         final item = items[index];
//                         return CheckboxListTile(
//                           title: Text(
//                             item.toString(),
//                           ), // Ensure String conversion
//                           value: selectedItems.contains(index),
//                           onChanged: (_) => _toggleSelection(index, tabIndex),
//                         );
//                       }
//                     },
//                   );
//                 } else {
//                   return Center(child: Text('No data available.'));
//                 }
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // Helper method to filter purchase orders
//   List<dynamic> _filterPurchaseOrders(List<dynamic> data, String searchText) {
//     if (searchText.isEmpty) return data;

//     return data.where((item) {
//       if (item is Map) {
//         final vendor = item['vendor']?.toString().toLowerCase() ?? '';
//         final number = item['nmbr']?.toString().toLowerCase() ?? '';
//         final searchLower = searchText.toLowerCase();

//         return vendor.contains(searchLower) || number.contains(searchLower);
//       }
//       return false;
//     }).toList();
//   }

//   // Helper method to filter strings
//   List<dynamic> _filterStrings(List<dynamic> data, String searchText) {
//     if (searchText.isEmpty) return data;

//     return data.where((item) {
//       return item.toString().toLowerCase().contains(searchText.toLowerCase());
//     }).toList();
//   }
// }

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart' as intl;

class AuthorizePurchaseOrderScreen extends StatefulWidget {
  const AuthorizePurchaseOrderScreen({super.key});

  @override
  AuthorizePurchaseOrderScreenState createState() =>
      AuthorizePurchaseOrderScreenState();
}

class AuthorizePurchaseOrderScreenState
    extends State<AuthorizePurchaseOrderScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchControllerTab1 = TextEditingController();
  final TextEditingController _searchControllerTab2 = TextEditingController();

  final ValueNotifier<String> _searchTextTab1 = ValueNotifier('');
  final ValueNotifier<String> _searchTextTab2 = ValueNotifier('');
  final ValueNotifier<Set<int>> _selectedItemsTab1 = ValueNotifier({});
  final ValueNotifier<Set<int>> _selectedItemsTab2 = ValueNotifier({});

  late Future<List<dynamic>> futureItemsTab1;
  late Future<List<dynamic>> futureItemsTab2;
  Map<String, dynamic>? receivedData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    futureItemsTab1 = Future.value([]);
    futureItemsTab2 = _fetchItems2();

    _searchControllerTab1.addListener(() {
      _searchTextTab1.value = _searchControllerTab1.text;
    });
    _searchControllerTab2.addListener(() {
      _searchTextTab2.value = _searchControllerTab2.text;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    receivedData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (receivedData != null && receivedData!['data'] != null) {
      futureItemsTab1 = Future.value(receivedData!['data']);
    } else {
      futureItemsTab1 = _fetchItems1();
    }
  }

  Future<List<dynamic>> _fetchItems1() async {
    try {
      final storage = FlutterSecureStorage();
      final url = await storage.read(key: 'url');
      final companyDetails = await storage.read(key: 'selected_company');
      if (companyDetails == null || companyDetails.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Company not selected")));
        }
        throw Exception("Company not selected");
      }
      final companyId = jsonDecode(companyDetails)['id'];
      final locationDetails = await storage.read(key: 'selected_location');
      if (locationDetails == null || locationDetails.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location not selected")),
          );
        }
        throw Exception("Location not selected");
      }
      final locationId = jsonDecode(locationDetails)['id'];
      final tokenDetails = await storage.read(key: 'session_token');
      if (tokenDetails == null || tokenDetails.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Session token not found")),
          );
        }
        throw Exception("Session token not found");
      }
      final token = jsonDecode(tokenDetails)['token']['value'];
      final userId = jsonDecode(tokenDetails)['user']['id'];

      final poRegularBody = {
        "pageNumber": 1,
        "pageSize": 100,
        "sortField": "",
        "sortDirection": "",
        "searchValue": null,
        "potype": "'R'",
        "usrLvl": 0,
        "usrSubLvl": 0,
        "mulLvlAuthRed": true,
        "valLimit": 0,
        "docType": "PR",
        "docSubType": "RP",
        "companyId": companyId,
        "userId": userId,
      };

      final dio = Dio();
      dio.options.headers = {
        "CompanyId": "$companyId",
        "Content-Type": "application/json; charset=utf-8",
        "Authorization": "Bearer $token",
      };
      final response = await dio.post(
        'http://$url/api/Podata/FetchPendingAuthPOList',
        data: poRegularBody,
        queryParameters: {
          'locIds': locationId.toString(),
          'companyId': companyId,
          'locationId': locationId,
        },
      );
      return response.data['data'] ?? [];
    } catch (e) {
      throw Exception('Failed to load items: $e');
    }
  }

  Future<List<dynamic>> _fetchItems2() async {
    try {
      final storage = FlutterSecureStorage();
      final url = await storage.read(key: 'url');
      final companyDetails = await storage.read(key: 'selected_company');
      if (companyDetails == null || companyDetails.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Company not selected")));
        }
        throw Exception("Company not selected");
      }
      final companyId = jsonDecode(companyDetails)['id'];
      final locationDetails = await storage.read(key: 'selected_location');
      if (locationDetails == null || locationDetails.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location not selected")),
          );
        }
        throw Exception("Location not selected");
      }
      final locationId = jsonDecode(locationDetails)['id'];
      final tokenDetails = await storage.read(key: 'session_token');
      if (tokenDetails == null || tokenDetails.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Session token not found")),
          );
        }
        throw Exception("Session token not found");
      }
      final token = jsonDecode(tokenDetails)['token']['value'];
      final userId = jsonDecode(tokenDetails)['user']['id'];

      final poCapitalBody = {
        "pageNumber": 1,
        "pageSize": 100,
        "sortField": "",
        "sortDirection": "",
        "searchValue": null,
        "potype": "'C'",
        "usrLvl": 0,
        "usrSubLvl": 0,
        "mulLvlAuthRed": true,
        "valLimit": 0,
        "docType": "PR",
        "docSubType": "CP",
        "companyId": companyId,
        "userId": userId,
      };

      final dio = Dio();
      dio.options.headers = {
        "CompanyId": "$companyId",
        "Content-Type": "application/json; charset=utf-8",
        "Authorization": "Bearer $token",
      };
      final response = await dio.post(
        'http://$url/api/Podata/FetchPendingAuthPOList',
        data: poCapitalBody,
        queryParameters: {
          'locIds': locationId.toString(),
          'companyId': companyId,
          'locationId': locationId,
        },
      );
      return response.data['data'] ?? [];
    } catch (e) {
      throw Exception('Failed to load items: $e');
    }
  }

  Future<void> _refreshItems(int tabIndex) async {
    setState(() {
      if (tabIndex == 0) {
        futureItemsTab1 = _fetchItems1();
        _selectedItemsTab1.value = {};
      } else {
        futureItemsTab2 = _fetchItems2();
        _selectedItemsTab2.value = {};
      }
    });
  }

  void _toggleSelection(int index, int tabIndex) {
    final selectedItems =
        tabIndex == 0 ? _selectedItemsTab1 : _selectedItemsTab2;
    final current = Set<int>.from(selectedItems.value);
    if (current.contains(index)) {
      current.remove(index);
    } else {
      current.add(index);
    }
    selectedItems.value = current;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchControllerTab1.dispose();
    _searchControllerTab2.dispose();
    _searchTextTab1.dispose();
    _searchTextTab2.dispose();
    _selectedItemsTab1.dispose();
    _selectedItemsTab2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authorize Purchase Order'),
        bottom: TabBar(
          controller: _tabController,
          dividerHeight: 0,
          tabs: const [Tab(text: 'Regular'), Tab(text: 'Capital')],
          onTap: (index) {
            if (index == 0) {
              _searchControllerTab2.clear();
              _searchTextTab2.value = '';
              _selectedItemsTab2.value = {};
            } else {
              _searchControllerTab1.clear();
              _searchTextTab1.value = '';
              _selectedItemsTab1.value = {};
            }
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: [
                _buildTabContent(
                  0,
                  _searchControllerTab1,
                  _searchTextTab1,
                  _selectedItemsTab1,
                  futureItemsTab1,
                ),
                _buildTabContent(
                  1,
                  _searchControllerTab2,
                  _searchTextTab2,
                  _selectedItemsTab2,
                  futureItemsTab2,
                ),
              ],
            ),
          ),
          ValueListenableBuilder<Set<int>>(
            valueListenable: _selectedItemsTab1,
            builder: (context, selected1, _) {
              return ValueListenableBuilder<Set<int>>(
                valueListenable: _selectedItemsTab2,
                builder: (context, selected2, _) {
                  if (selected1.isEmpty && selected2.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // authorization logic here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            showCloseIcon: true,
                            content: Text(
                              '${selected1.isNotEmpty ? selected1 : ''} ${selected2.isNotEmpty ? selected2 : ''} Authorized successfully! ',
                            ),
                          ),
                        );
                      },
                      child: const Text('Authorize'),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(
    int tabIndex,
    TextEditingController searchController,
    ValueNotifier<String> searchTextNotifier,
    ValueNotifier<Set<int>> selectedItemsNotifier,
    Future<List<dynamic>> futureItems,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  searchController.clear();
                  searchTextNotifier.value = '';
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _refreshItems(tabIndex),
            child: FutureBuilder<List<dynamic>>(
              future: futureItems,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => _refreshItems(tabIndex),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.hasData) {
                  return ValueListenableBuilder<String>(
                    valueListenable: searchTextNotifier,
                    builder: (context, searchText, _) {
                      final items =
                          tabIndex == 0
                              ? _filterPurchaseOrders(
                                snapshot.data!,
                                searchText,
                              )
                              : _filterStrings(snapshot.data!, searchText);

                      if (items.isEmpty) {
                        return const Center(child: Text('No items found.'));
                      }

                      return ValueListenableBuilder<Set<int>>(
                        valueListenable: selectedItemsNotifier,
                        builder: (context, selectedItems, _) {
                          return ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              if (tabIndex == 0) {
                                final item = items[index];
                                return CheckboxListTile(
                                  title: Text(
                                    "${item['nmbr']} - ${item['vendor']}",
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Date: ${intl.DateFormat("dd/MM/yyyy").format(DateTime.parse(item['date']))}",
                                      ),
                                      Text(
                                        "Amount: ${intl.NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 2).format(item['pototalamt'])}",
                                      ),
                                    ],
                                  ),
                                  value: selectedItems.contains(index),
                                  onChanged:
                                      (_) => _toggleSelection(index, tabIndex),
                                );
                              } else {
                                final item = items[index];
                                return CheckboxListTile(
                                  title: Text(item.toString()),
                                  value: selectedItems.contains(index),
                                  onChanged:
                                      (_) => _toggleSelection(index, tabIndex),
                                );
                              }
                            },
                          );
                        },
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No data available.'));
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  List<dynamic> _filterPurchaseOrders(List<dynamic> data, String searchText) {
    if (searchText.isEmpty) return data;
    final searchLower = searchText.toLowerCase();
    return data.where((item) {
      if (item is Map) {
        final vendor = item['vendor']?.toString().toLowerCase() ?? '';
        final number = item['nmbr']?.toString().toLowerCase() ?? '';
        return vendor.contains(searchLower) || number.contains(searchLower);
      }
      return false;
    }).toList();
  }

  List<dynamic> _filterStrings(List<dynamic> data, String searchText) {
    if (searchText.isEmpty) return data;
    final searchLower = searchText.toLowerCase();
    return data.where((item) {
      return item.toString().toLowerCase().contains(searchLower);
    }).toList();
  }
}
