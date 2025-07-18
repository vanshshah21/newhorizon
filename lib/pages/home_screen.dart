// import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:nhapp/main.dart';
// import 'package:nhapp/utils/storage_utils.dart';
// import 'package:provider/provider.dart';
// import 'package:nhapp/utils/token_utils.dart'; // <-- Make sure this is imported

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
//   List<Map<String, dynamic>> pendingAuthList = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadPendingAuthenticationCount();
//     });
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   Future<void> _loadPendingAuthenticationCount() async {
//     setState(() {
//       isLoading = true;
//     });

//     // 1. Validate token before proceeding
//     final isValid = await TokenUtils.isTokenValid(context);
//     if (!isValid) {
//       // _showSnackBar("Session expired. Please log in again.");
//       setState(() {
//         isLoading = false;
//       });
//       return;
//     }

//     try {
//       final url = await StorageUtils.readValue('url');
//       final companyDetails = await StorageUtils.readJson('selected_company');
//       final locationDetails = await StorageUtils.readJson('selected_location');
//       final tokenDetails = await StorageUtils.readJson('session_token');

//       if (companyDetails == null ||
//           companyDetails.isEmpty ||
//           locationDetails == null ||
//           locationDetails.isEmpty ||
//           tokenDetails == null ||
//           tokenDetails.isEmpty) {
//         _showSnackBar("Company, location, or session token not set");
//         setState(() {
//           isLoading = false;
//         });
//         return;
//       }

//       final companyId = companyDetails['id'];
//       final locationId = locationDetails['id'];
//       final token = tokenDetails['token']['value'];

//       Dio dio = Dio();
//       dio.options.headers = {
//         "Content-Type": "application/json; charset=utf-8",
//         "Authorization": "Bearer $token",
//       };
//       dio.options.connectTimeout = const Duration(seconds: 10);
//       dio.options.receiveTimeout = const Duration(seconds: 10);

//       final response = await dio.get(
//         'http://$url/api/Login/pendDashBoardCount',
//         queryParameters: {'companyid': companyId, 'siteid': locationId},
//       );

//       if (response.statusCode == 200) {
//         // Parse JSON in a background isolate for large responses
//         final data = await compute(_parseJson, response.data);

//         if (data['success'] == true && data['data'] is List) {
//           if (!mounted) return; // Check if the widget is still mounted
//           setState(() {
//             pendingAuthList = List<Map<String, dynamic>>.from(data['data']);
//           });
//         } else {
//           _showSnackBar(data['message'] ?? 'Unknown error');
//         }
//       } else {
//         _showSnackBar('Error: ${response.statusCode}');
//       }
//     } on DioException catch (e) {
//       String message = 'Network error';
//       if (e.response != null) {
//         message = 'Failed: ${e.response?.statusCode}';
//         if (e.response?.data is Map) {
//           message += ' - ${e.response?.data['message']}';
//         }
//       } else {
//         switch (e.type) {
//           case DioExceptionType.connectionError:
//             message = 'No internet connection';
//             break;
//           case DioExceptionType.receiveTimeout:
//           case DioExceptionType.sendTimeout:
//             message = 'Server timeout';
//             break;
//           case DioExceptionType.connectionTimeout:
//             message = 'Connection timeout';
//             break;
//           default:
//             message = 'Network error: ${e.message}';
//         }
//       }
//       _showSnackBar(message);
//     } catch (e) {
//       _showSnackBar('Error loading data: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _onRefresh() async {
//     await _loadPendingAuthenticationCount();
//   }

//   static Map<String, dynamic> _parseJson(dynamic data) {
//     if (data is String) {
//       return jsonDecode(data) as Map<String, dynamic>;
//     }
//     if (data is Map<String, dynamic>) {
//       return data;
//     }
//     if (data is Map) {
//       return Map<String, dynamic>.from(data);
//     }
//     throw Exception('Invalid data for JSON parsing');
//   }

//   void _showSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(message)));
//     }
//   }

//   final Map<String, String> routeToPageName = {
//     '/purchase_orders': 'Purchase Orders',
//     '/service_orders': 'Service Orders',
//     '/labour_po': 'Labour PO',
//     '/leads': 'Leads',
//     '/follow_up': 'Follow Up',
//     '/quotation': 'Quotation',
//     '/sales_order': 'Sales Order',
//     '/proforma_invoice': 'Proforma Invoice',
//   };

//   final Map<String, String> titleToRoute = {
//     'Purchase Orders': '/authorize_purchase_orders',
//     'Service Orders': '/authorize_service_orders',
//     'Labour PO': '/authorize_labour_purchase_orders',
//     'Quotation': '/authorize_quotations',
//     'Sales Order': '/authorize_sales_orders',
//   };

//   @override
//   Widget build(BuildContext context) {
//     final favoritePages = Provider.of<FavoritePages>(context);
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home Screen'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications),
//             onPressed: () {
//               Navigator.pushNamed(context, '/my_notification');
//             },
//           ),
//         ],
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: <Widget>[
//             // const DrawerHeader(
//             //   decoration: BoxDecoration(color: Colors.blue),
//             //   child: Text(
//             //     'Drawer Header',
//             //     style: TextStyle(color: Colors.white, fontSize: 24),
//             //   ),
//             // ),
//             DrawerHeader(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   SvgPicture.asset(
//                     'assets/img_new_horizon_logo.svg',
//                     height: 64,
//                   ),
//                   const SizedBox(height: 12),
//                   const Text(
//                     'New Horizon ERP',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             ListTile(
//               title: const Text('Dashboard'),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.pushNamed(context, '/dashboard');
//               },
//             ),
//             ExpansionTile(
//               title: const Text('Purchase'),
//               children: [
//                 ListTile(
//                   title: const Text('Purchase Orders'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.pushNamed(context, '/purchase_orders');
//                   },
//                 ),
//                 ListTile(
//                   title: const Text('Service Orders'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.pushNamed(context, '/service_orders');
//                   },
//                 ),
//                 ListTile(
//                   title: const Text('Labour PO'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.pushNamed(context, '/labour_po');
//                   },
//                 ),
//               ],
//             ),
//             ExpansionTile(
//               title: const Text('Sales'),
//               children: [
//                 ListTile(
//                   title: const Text('Leads'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.pushNamed(context, '/leads');
//                   },
//                 ),
//                 ListTile(
//                   title: const Text('Follow Up'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.pushNamed(context, '/follow_up');
//                   },
//                 ),
//                 ListTile(
//                   title: const Text('Quotation'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.pushNamed(context, '/quotation');
//                   },
//                 ),
//                 ListTile(
//                   title: const Text('Sales Order'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.pushNamed(context, '/sales_order');
//                   },
//                 ),
//                 ListTile(
//                   title: const Text('Proforma Invoice'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.pushNamed(context, '/proforma_invoice');
//                   },
//                 ),
//               ],
//             ),
//             ExpansionTile(
//               title: const Text('Settings'),
//               children: [
//                 ListTile(
//                   title: const Text('My Notification'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.pushNamed(context, '/my_notification');
//                   },
//                 ),
//                 ListTile(
//                   title: const Text('My Favourites'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.pushNamed(context, '/my_favourites');
//                   },
//                 ),
//               ],
//             ),
//             ListTile(
//               title: const Text('Logout'),
//               onTap: () async {
//                 if (await StorageUtils.readBool('remember_me')) {
//                   await StorageUtils.deleteValue('session_token');
//                   await StorageUtils.deleteValue('selected_company');
//                   await StorageUtils.deleteValue('selected_location');
//                   await StorageUtils.deleteValue('finance_period');
//                 } else {
//                   await StorageUtils.clearAll();
//                 }
//                 if (!mounted) return;
//                 Navigator.pop(context);
//                 Navigator.of(
//                   context,
//                 ).pushNamedAndRemoveUntil('/login', (Route route) => false);
//               },
//             ),
//           ],
//         ),
//       ),
//       body:
//           isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : RefreshIndicator(
//                 onRefresh: _onRefresh,
//                 child: CustomScrollView(
//                   slivers: [
//                     SliverToBoxAdapter(
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [Text('Pending Authorizations:')],
//                       ),
//                     ),
//                     SliverPadding(
//                       padding: const EdgeInsets.all(8),
//                       sliver: SliverGrid(
//                         gridDelegate:
//                             const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 3,
//                               mainAxisSpacing: 12,
//                               crossAxisSpacing: 12,
//                               childAspectRatio: 1,
//                             ),
//                         delegate: SliverChildBuilderDelegate(
//                           (context, index) => _AuthTile(
//                             title: pendingAuthList[index]['title'] ?? '',
//                             count: pendingAuthList[index]['count'] ?? 0,
//                             onTap: () {
//                               final route =
//                                   titleToRoute[pendingAuthList[index]['title']];
//                               if (route != null) {
//                                 Navigator.pushNamed(context, route);
//                               }
//                             },
//                           ),
//                           childCount: pendingAuthList.length,
//                         ),
//                       ),
//                     ),
//                     SliverToBoxAdapter(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Column(
//                           children: [
//                             const Text(
//                               'Favorite Pages:',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             const SizedBox(height: 12),
//                             favoritePages.favoriteRoutes.isEmpty
//                                 ? Card(
//                                   elevation: 0,
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(24.0),
//                                     child: Text(
//                                       'No favorites yet.',
//                                       style: TextStyle(
//                                         color:
//                                             Theme.of(
//                                               context,
//                                             ).colorScheme.outline,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ),
//                                 )
//                                 : Wrap(
//                                   spacing: 8.0,
//                                   runSpacing: 8.0,
//                                   alignment: WrapAlignment.center,
//                                   children:
//                                       favoritePages.favoriteRoutes.map((route) {
//                                         final pageName =
//                                             routeToPageName[route] ?? route;
//                                         return Card(
//                                           elevation: 0,
//                                           child: InkWell(
//                                             onTap: () {
//                                               Navigator.pushNamed(
//                                                 context,
//                                                 route,
//                                               );
//                                             },
//                                             borderRadius: BorderRadius.circular(
//                                               12,
//                                             ),
//                                             child: Padding(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                     horizontal: 16.0,
//                                                     vertical: 12.0,
//                                                   ),
//                                               child: Row(
//                                                 mainAxisSize: MainAxisSize.min,
//                                                 children: [
//                                                   Icon(
//                                                     Icons.star_border_outlined,
//                                                     size: 16,
//                                                     color:
//                                                         Theme.of(
//                                                           context,
//                                                         ).colorScheme.primary,
//                                                   ),
//                                                   const SizedBox(width: 8),
//                                                   Text(
//                                                     pageName,
//                                                     style: TextStyle(
//                                                       fontSize: 14,
//                                                       fontWeight:
//                                                           FontWeight.w500,
//                                                       color:
//                                                           Theme.of(context)
//                                                               .colorScheme
//                                                               .onSurface,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         );
//                                       }).toList(),
//                                 ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SliverToBoxAdapter(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Column(
//                           children: [
//                             const Text(
//                               'Quick Links:',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             const SizedBox(height: 12),
//                             GridView.count(
//                               shrinkWrap: true,
//                               physics: const NeverScrollableScrollPhysics(),
//                               crossAxisCount: 4,
//                               mainAxisSpacing: 8,
//                               crossAxisSpacing: 8,
//                               childAspectRatio: 1.2,
//                               children: [
//                                 _QuickLinkTile(
//                                   title: 'Purchase Orders',
//                                   icon: Icons.shopping_cart,
//                                   onTap:
//                                       () => Navigator.pushNamed(
//                                         context,
//                                         '/purchase_orders',
//                                       ),
//                                 ),
//                                 _QuickLinkTile(
//                                   title: 'Service Orders',
//                                   icon: Icons.build,
//                                   onTap:
//                                       () => Navigator.pushNamed(
//                                         context,
//                                         '/service_orders',
//                                       ),
//                                 ),
//                                 _QuickLinkTile(
//                                   title: 'Labour PO',
//                                   icon: Icons.person_outline,
//                                   onTap:
//                                       () => Navigator.pushNamed(
//                                         context,
//                                         '/labour_po',
//                                       ),
//                                 ),
//                                 _QuickLinkTile(
//                                   title: 'Leads',
//                                   icon: Icons.track_changes,
//                                   onTap:
//                                       () => Navigator.pushNamed(
//                                         context,
//                                         '/leads',
//                                       ),
//                                 ),
//                                 _QuickLinkTile(
//                                   title: 'Follow Up',
//                                   icon: Icons.follow_the_signs,
//                                   onTap:
//                                       () => Navigator.pushNamed(
//                                         context,
//                                         '/follow_up',
//                                       ),
//                                 ),
//                                 _QuickLinkTile(
//                                   title: 'Quotation',
//                                   icon: Icons.description,
//                                   onTap:
//                                       () => Navigator.pushNamed(
//                                         context,
//                                         '/quotation',
//                                       ),
//                                 ),
//                                 _QuickLinkTile(
//                                   title: 'Sales Order',
//                                   icon: Icons.receipt_long,
//                                   onTap:
//                                       () => Navigator.pushNamed(
//                                         context,
//                                         '/sales_order',
//                                       ),
//                                 ),
//                                 _QuickLinkTile(
//                                   title: 'Proforma Invoice',
//                                   icon: Icons.article,
//                                   onTap:
//                                       () => Navigator.pushNamed(
//                                         context,
//                                         '/proforma_invoice',
//                                       ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//     );
//   }
// }

// class _QuickLinkTile extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final VoidCallback onTap;

//   const _QuickLinkTile({
//     required this.title,
//     required this.icon,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 0,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 icon,
//                 size: 24,
//                 color: Theme.of(context).colorScheme.primary,
//               ),
//               const SizedBox(height: 6),
//               // Fixed text overflow by allowing proper wrapping
//               Flexible(
//                 child: Text(
//                   title,
//                   textAlign: TextAlign.center,
//                   maxLines: 2,
//                   overflow: TextOverflow.visible,
//                   style: const TextStyle(
//                     fontSize: 10,
//                     fontWeight: FontWeight.w500,
//                     height: 1.2,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _AuthTile extends StatelessWidget {
//   final String title;
//   final int count;
//   final VoidCallback onTap;

//   const _AuthTile({
//     required this.title,
//     required this.count,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext ctx) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Card(
//         elevation: 0,
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(title, style: const TextStyle(fontSize: 12)),
//               Text('$count', style: const TextStyle(fontSize: 20)),
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
// import 'package:flutter/foundation.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:nhapp/main.dart';
// import 'package:nhapp/utils/storage_utils.dart';
// import 'package:provider/provider.dart';
// import 'package:nhapp/utils/token_utils.dart'; // <-- Make sure this is imported

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen>
//     with WidgetsBindingObserver, RouteAware {
//   List<Map<String, dynamic>> pendingAuthList = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadPendingAuthenticationCount();
//     });
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // Register this widget as a route observer to detect when user returns
//     final route = ModalRoute.of(context);
//     if (route is PageRoute) {
//       // You might need to implement RouteObserver in your main.dart if not already done
//       // routeObserver.subscribe(this, route);
//     }
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     // routeObserver.unsubscribe(this);
//     super.dispose();
//   }

//   @override
//   void didPopNext() {
//     // This will be called when user returns to this page from another page
//     _loadPendingAuthenticationCount();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
//     if (state == AppLifecycleState.resumed) {
//       // Refresh when app comes back to foreground
//       _loadPendingAuthenticationCount();
//     }
//   }

//   Future<void> _loadPendingAuthenticationCount() async {
//     setState(() {
//       isLoading = true;
//     });

//     // 1. Validate token before proceeding
//     final isValid = await TokenUtils.isTokenValid(context);
//     if (!isValid) {
//       // _showSnackBar("Session expired. Please log in again.");
//       setState(() {
//         isLoading = false;
//       });
//       return;
//     }

//     try {
//       final url = await StorageUtils.readValue('url');
//       final companyDetails = await StorageUtils.readJson('selected_company');
//       final locationDetails = await StorageUtils.readJson('selected_location');
//       final tokenDetails = await StorageUtils.readJson('session_token');

//       if (companyDetails == null ||
//           companyDetails.isEmpty ||
//           locationDetails == null ||
//           locationDetails.isEmpty ||
//           tokenDetails == null ||
//           tokenDetails.isEmpty) {
//         _showSnackBar("Company, location, or session token not set");
//         setState(() {
//           isLoading = false;
//         });
//         return;
//       }

//       final companyId = companyDetails['id'];
//       final locationId = locationDetails['id'];
//       final token = tokenDetails['token']['value'];

//       Dio dio = Dio();
//       dio.options.headers = {
//         "Content-Type": "application/json; charset=utf-8",
//         "Authorization": "Bearer $token",
//       };
//       dio.options.connectTimeout = const Duration(seconds: 10);
//       dio.options.receiveTimeout = const Duration(seconds: 10);

//       final response = await dio.get(
//         'http://$url/api/Login/pendDashBoardCount',
//         queryParameters: {'companyid': companyId, 'siteid': locationId},
//       );

//       if (response.statusCode == 200) {
//         // Parse JSON in a background isolate for large responses
//         final data = await compute(_parseJson, response.data);

//         if (data['success'] == true && data['data'] is List) {
//           if (!mounted) return; // Check if the widget is still mounted
//           setState(() {
//             pendingAuthList = List<Map<String, dynamic>>.from(data['data']);
//           });
//         } else {
//           _showSnackBar(data['message'] ?? 'Unknown error');
//         }
//       } else {
//         _showSnackBar('Error: ${response.statusCode}');
//       }
//     } on DioException catch (e) {
//       String message = 'Network error';
//       if (e.response != null) {
//         message = 'Failed: ${e.response?.statusCode}';
//         if (e.response?.data is Map) {
//           message += ' - ${e.response?.data['message']}';
//         }
//       } else {
//         switch (e.type) {
//           case DioExceptionType.connectionError:
//             message = 'No internet connection';
//             break;
//           case DioExceptionType.receiveTimeout:
//           case DioExceptionType.sendTimeout:
//             message = 'Server timeout';
//             break;
//           case DioExceptionType.connectionTimeout:
//             message = 'Connection timeout';
//             break;
//           default:
//             message = 'Network error: ${e.message}';
//         }
//       }
//       _showSnackBar(message);
//     } catch (e) {
//       _showSnackBar('Error loading data: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _onRefresh() async {
//     await _loadPendingAuthenticationCount();
//   }

//   static Map<String, dynamic> _parseJson(dynamic data) {
//     if (data is String) {
//       return jsonDecode(data) as Map<String, dynamic>;
//     }
//     if (data is Map<String, dynamic>) {
//       return data;
//     }
//     if (data is Map) {
//       return Map<String, dynamic>.from(data);
//     }
//     throw Exception('Invalid data for JSON parsing');
//   }

//   void _showSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(message)));
//     }
//   }

//   final Map<String, String> routeToPageName = {
//     '/purchase_orders': 'Purchase Orders',
//     '/service_orders': 'Service Orders',
//     '/labour_po': 'Labour PO',
//     '/leads': 'Leads',
//     '/follow_up': 'Follow Up',
//     '/quotation': 'Quotation',
//     '/sales_order': 'Sales Order',
//     '/proforma_invoice': 'Proforma Invoice',
//   };

//   final Map<String, String> titleToRoute = {
//     'Purchase Orders': '/authorize_purchase_orders',
//     'Service Orders': '/authorize_service_orders',
//     'Labour PO': '/authorize_labour_purchase_orders',
//     'Quotation': '/authorize_quotations',
//     'Sales Order': '/authorize_sales_orders',
//   };

//   @override
//   Widget build(BuildContext context) {
//     final favoritePages = Provider.of<FavoritePages>(context);
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home Screen'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications),
//             onPressed: () {
//               Navigator.pushNamed(context, '/my_notification');
//             },
//           ),
//         ],
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: <Widget>[
//             // const DrawerHeader(
//             //   decoration: BoxDecoration(color: Colors.blue),
//             //   child: Text(
//             //     'Drawer Header',
//             //     style: TextStyle(color: Colors.white, fontSize: 24),
//             //   ),
//             // ),
//             DrawerHeader(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   SvgPicture.asset(
//                     'assets/img_new_horizon_logo.svg',
//                     height: 64,
//                   ),
//                   const SizedBox(height: 12),
//                   const Text(
//                     'New Horizon ERP',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             ListTile(
//               title: const Text('Dashboard'),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.pushNamed(context, '/dashboard');
//               },
//             ),
//             ExpansionTile(
//               title: const Text('Purchase'),
//               children: [
//                 ListTile(
//                   title: const Text('Purchase Orders'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.pushNamed(context, '/purchase_orders');
//                   },
//                 ),
//                 ListTile(
//                   title: const Text('Service Orders'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.pushNamed(context, '/service_orders');
//                   },
//                 ),
//                 ListTile(
//                   title: const Text('Labour PO'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.pushNamed(context, '/labour_po');
//                   },
//                 ),
//               ],
//             ),
//             ExpansionTile(
//               title: const Text('Sales'),
//               children: [
//                 ListTile(
//                   title: const Text('Leads'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.pushNamed(context, '/leads');
//                   },
//                 ),
//                 ListTile(
//                   title: const Text('Follow Up'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.pushNamed(context, '/follow_up');
//                   },
//                 ),
//                 ListTile(
//                   title: const Text('Quotation'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.pushNamed(context, '/quotation');
//                   },
//                 ),
//                 ListTile(
//                   title: const Text('Sales Order'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.pushNamed(context, '/sales_order');
//                   },
//                 ),
//                 ListTile(
//                   title: const Text('Proforma Invoice'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.pushNamed(context, '/proforma_invoice');
//                   },
//                 ),
//               ],
//             ),
//             ExpansionTile(
//               title: const Text('Settings'),
//               children: [
//                 ListTile(
//                   title: const Text('My Notification'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.pushNamed(context, '/my_notification');
//                   },
//                 ),
//                 ListTile(
//                   title: const Text('My Favourites'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.pushNamed(context, '/my_favourites');
//                   },
//                 ),
//               ],
//             ),
//             ListTile(
//               title: const Text('Logout'),
//               onTap: () async {
//                 if (await StorageUtils.readBool('remember_me')) {
//                   await StorageUtils.deleteValue('session_token');
//                   await StorageUtils.deleteValue('selected_company');
//                   await StorageUtils.deleteValue('selected_location');
//                   await StorageUtils.deleteValue('finance_period');
//                 } else {
//                   await StorageUtils.clearAll();
//                 }
//                 if (!mounted) return;
//                 Navigator.pop(context);
//                 Navigator.of(
//                   context,
//                 ).pushNamedAndRemoveUntil('/login', (Route route) => false);
//               },
//             ),
//           ],
//         ),
//       ),
//       body:
//           isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : RefreshIndicator(
//                 onRefresh: _onRefresh,
//                 child: CustomScrollView(
//                   slivers: [
//                     SliverToBoxAdapter(
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [Text('Pending Authorizations:')],
//                       ),
//                     ),
//                     SliverPadding(
//                       padding: const EdgeInsets.all(8),
//                       sliver: SliverGrid(
//                         gridDelegate:
//                             const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 3,
//                               mainAxisSpacing: 12,
//                               crossAxisSpacing: 12,
//                               childAspectRatio: 1,
//                             ),
//                         delegate: SliverChildBuilderDelegate(
//                           (context, index) => _AuthTile(
//                             title: pendingAuthList[index]['title'] ?? '',
//                             count: pendingAuthList[index]['count'] ?? 0,
//                             onTap: () async {
//                               final route =
//                                   titleToRoute[pendingAuthList[index]['title']];
//                               if (route != null) {
//                                 await Navigator.pushNamed(context, route);
//                                 // Refresh data when returning from authorize page
//                                 _loadPendingAuthenticationCount();
//                               }
//                             },
//                           ),
//                           childCount: pendingAuthList.length,
//                         ),
//                       ),
//                     ),
//                     SliverToBoxAdapter(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Column(
//                           children: [
//                             const Text(
//                               'Favorite Pages:',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             const SizedBox(height: 12),
//                             favoritePages.favoriteRoutes.isEmpty
//                                 ? Card(
//                                   elevation: 0,
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(24.0),
//                                     child: Text(
//                                       'No favorites yet.',
//                                       style: TextStyle(
//                                         color:
//                                             Theme.of(
//                                               context,
//                                             ).colorScheme.outline,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ),
//                                 )
//                                 : Wrap(
//                                   spacing: 8.0,
//                                   runSpacing: 8.0,
//                                   alignment: WrapAlignment.center,
//                                   children:
//                                       favoritePages.favoriteRoutes.map((route) {
//                                         final pageName =
//                                             routeToPageName[route] ?? route;
//                                         return Card(
//                                           elevation: 0,
//                                           child: InkWell(
//                                             onTap: () {
//                                               Navigator.pushNamed(
//                                                 context,
//                                                 route,
//                                               );
//                                             },
//                                             borderRadius: BorderRadius.circular(
//                                               12,
//                                             ),
//                                             child: Padding(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                     horizontal: 16.0,
//                                                     vertical: 12.0,
//                                                   ),
//                                               child: Row(
//                                                 mainAxisSize: MainAxisSize.min,
//                                                 children: [
//                                                   Icon(
//                                                     Icons.star_border_outlined,
//                                                     size: 16,
//                                                     color:
//                                                         Theme.of(
//                                                           context,
//                                                         ).colorScheme.primary,
//                                                   ),
//                                                   const SizedBox(width: 8),
//                                                   Text(
//                                                     pageName,
//                                                     style: TextStyle(
//                                                       fontSize: 14,
//                                                       fontWeight:
//                                                           FontWeight.w500,
//                                                       color:
//                                                           Theme.of(context)
//                                                               .colorScheme
//                                                               .onSurface,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         );
//                                       }).toList(),
//                                 ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SliverToBoxAdapter(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Column(
//                           children: [
//                             const Text(
//                               'Quick Links:',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             const SizedBox(height: 12),
//                             GridView.count(
//                               shrinkWrap: true,
//                               physics: const NeverScrollableScrollPhysics(),
//                               crossAxisCount: 4,
//                               mainAxisSpacing: 8,
//                               crossAxisSpacing: 8,
//                               childAspectRatio: 0.9,
//                               children: [
//                                 _QuickLinkTile(
//                                   title: 'Purchase Orders',
//                                   icon: Icons.shopping_cart,
//                                   onTap:
//                                       () => Navigator.pushNamed(
//                                         context,
//                                         '/purchase_orders',
//                                       ),
//                                 ),
//                                 _QuickLinkTile(
//                                   title: 'Service Orders',
//                                   icon: Icons.build,
//                                   onTap:
//                                       () => Navigator.pushNamed(
//                                         context,
//                                         '/service_orders',
//                                       ),
//                                 ),
//                                 _QuickLinkTile(
//                                   title: 'Labour PO',
//                                   icon: Icons.person_outline,
//                                   onTap:
//                                       () => Navigator.pushNamed(
//                                         context,
//                                         '/labour_po',
//                                       ),
//                                 ),
//                                 _QuickLinkTile(
//                                   title: 'Leads',
//                                   icon: Icons.track_changes,
//                                   onTap:
//                                       () => Navigator.pushNamed(
//                                         context,
//                                         '/leads',
//                                       ),
//                                 ),
//                                 _QuickLinkTile(
//                                   title: 'Follow Up',
//                                   icon: Icons.follow_the_signs,
//                                   onTap:
//                                       () => Navigator.pushNamed(
//                                         context,
//                                         '/follow_up',
//                                       ),
//                                 ),
//                                 _QuickLinkTile(
//                                   title: 'Quotation',
//                                   icon: Icons.description,
//                                   onTap:
//                                       () => Navigator.pushNamed(
//                                         context,
//                                         '/quotation',
//                                       ),
//                                 ),
//                                 _QuickLinkTile(
//                                   title: 'Sales Order',
//                                   icon: Icons.receipt_long,
//                                   onTap:
//                                       () => Navigator.pushNamed(
//                                         context,
//                                         '/sales_order',
//                                       ),
//                                 ),
//                                 _QuickLinkTile(
//                                   title: 'Proforma Invoice',
//                                   icon: Icons.article,
//                                   onTap:
//                                       () => Navigator.pushNamed(
//                                         context,
//                                         '/proforma_invoice',
//                                       ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//     );
//   }
// }

// class _QuickLinkTile extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final VoidCallback onTap;

//   const _QuickLinkTile({
//     required this.title,
//     required this.icon,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 0,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 icon,
//                 size: 24,
//                 color: Theme.of(context).colorScheme.primary,
//               ),
//               const SizedBox(height: 6),
//               // Fixed text overflow by allowing proper wrapping
//               Flexible(
//                 child: Text(
//                   title,
//                   textAlign: TextAlign.center,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     fontSize: 10,
//                     fontWeight: FontWeight.w500,
//                     height: 1.2,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _AuthTile extends StatelessWidget {
//   final String title;
//   final int count;
//   final VoidCallback onTap;

//   const _AuthTile({
//     required this.title,
//     required this.count,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext ctx) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Card(
//         elevation: 0,
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(title, style: const TextStyle(fontSize: 12)),
//               Text('$count', style: const TextStyle(fontSize: 20)),
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
// import 'package:flutter/foundation.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:nhapp/main.dart';
// import 'package:nhapp/utils/storage_utils.dart';
// import 'package:provider/provider.dart';
// import 'package:nhapp/utils/token_utils.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen>
//     with WidgetsBindingObserver, RouteAware {
//   List<Map<String, dynamic>> pendingAuthList = [];
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);

//     // Initialize with default data showing 0 counts
//     _initializeDefaultData();

//     // Load actual data in background
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadPendingAuthenticationCount();
//     });
//   }

//   void _initializeDefaultData() {
//     // Set default pending auth items with 0 counts
//     pendingAuthList = [
//       {'title': 'Purchase Orders', 'count': 0},
//       {'title': 'Service Orders', 'count': 0},
//       {'title': 'Labour PO', 'count': 0},
//       {'title': 'Quotation', 'count': 0},
//       {'title': 'Sales Order', 'count': 0},
//     ];
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // Refresh data every time this page becomes visible
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadPendingAuthenticationCount();
//     });
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
//     if (state == AppLifecycleState.resumed) {
//       // Refresh when app comes back to foreground
//       _loadPendingAuthenticationCount();
//     }
//   }

//   // This method will be called when navigating back to this page
//   void _onPageResumed() {
//     if (mounted) {
//       _loadPendingAuthenticationCount();
//     }
//   }

//   Future<void> _loadPendingAuthenticationCount() async {
//     // Don't show loading indicator, update in background
//     if (!mounted) return;

//     // 1. Validate token before proceeding
//     final isValid = await TokenUtils.isTokenValid(context);
//     if (!isValid) {
//       // Keep default 0 counts if token is invalid
//       return;
//     }

//     try {
//       final url = await StorageUtils.readValue('url');
//       final companyDetails = await StorageUtils.readJson('selected_company');
//       final locationDetails = await StorageUtils.readJson('selected_location');
//       final tokenDetails = await StorageUtils.readJson('session_token');

//       if (companyDetails == null ||
//           companyDetails.isEmpty ||
//           locationDetails == null ||
//           locationDetails.isEmpty ||
//           tokenDetails == null ||
//           tokenDetails.isEmpty) {
//         // Keep default 0 counts if required data is missing
//         return;
//       }

//       final companyId = companyDetails['id'];
//       final locationId = locationDetails['id'];
//       final token = tokenDetails['token']['value'];

//       Dio dio = Dio();
//       dio.options.headers = {
//         "Content-Type": "application/json; charset=utf-8",
//         "Authorization": "Bearer $token",
//       };
//       dio.options.connectTimeout = const Duration(seconds: 10);
//       dio.options.receiveTimeout = const Duration(seconds: 10);

//       final response = await dio.get(
//         'http://$url/api/Login/pendDashBoardCount',
//         queryParameters: {'companyid': companyId, 'siteid': locationId},
//       );

//       if (response.statusCode == 200) {
//         // Parse JSON in a background isolate for large responses
//         final data = await compute(_parseJson, response.data);

//         if (data['success'] == true && data['data'] is List) {
//           if (!mounted) return; // Check if the widget is still mounted
//           setState(() {
//             pendingAuthList = List<Map<String, dynamic>>.from(data['data']);
//           });
//         } else {
//           // Keep existing data and show error if needed
//           if (mounted) {
//             _showSnackBar(data['message'] ?? 'Unknown error');
//           }
//         }
//       } else {
//         // Keep existing data and show error if needed
//         if (mounted) {
//           _showSnackBar('Error: ${response.statusCode}');
//         }
//       }
//     } on DioException catch (e) {
//       String message = 'Network error';
//       if (e.response != null) {
//         message = 'Failed: ${e.response?.statusCode}';
//         if (e.response?.data is Map) {
//           message += ' - ${e.response?.data['message']}';
//         }
//       } else {
//         switch (e.type) {
//           case DioExceptionType.connectionError:
//             message = 'No internet connection';
//             break;
//           case DioExceptionType.receiveTimeout:
//           case DioExceptionType.sendTimeout:
//             message = 'Server timeout';
//             break;
//           case DioExceptionType.connectionTimeout:
//             message = 'Connection timeout';
//             break;
//           default:
//             message = 'Network error: ${e.message}';
//         }
//       }
//       // Show error but keep existing data
//       if (mounted) {
//         _showSnackBar(message);
//       }
//     } catch (e) {
//       // Show error but keep existing data
//       if (mounted) {
//         _showSnackBar('Error loading data: $e');
//       }
//     }
//   }

//   Future<void> _onRefresh() async {
//     // Show loading indicator only during manual refresh
//     setState(() {
//       isLoading = true;
//     });

//     await _loadPendingAuthenticationCount();

//     if (mounted) {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   static Map<String, dynamic> _parseJson(dynamic data) {
//     if (data is String) {
//       return jsonDecode(data) as Map<String, dynamic>;
//     }
//     if (data is Map<String, dynamic>) {
//       return data;
//     }
//     if (data is Map) {
//       return Map<String, dynamic>.from(data);
//     }
//     throw Exception('Invalid data for JSON parsing');
//   }

//   void _showSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(message)));
//     }
//   }

//   final Map<String, String> routeToPageName = {
//     '/purchase_orders': 'Purchase Orders',
//     '/service_orders': 'Service Orders',
//     '/labour_po': 'Labour PO',
//     '/leads': 'Leads',
//     '/follow_up': 'Follow Up',
//     '/quotation': 'Quotation',
//     '/sales_order': 'Sales Order',
//     '/proforma_invoice': 'Proforma Invoice',
//   };

//   final Map<String, String> titleToRoute = {
//     'Purchase Orders': '/authorize_purchase_orders',
//     'Service Orders': '/authorize_service_orders',
//     'Labour PO': '/authorize_labour_purchase_orders',
//     'Quotation': '/authorize_quotations',
//     'Sales Order': '/authorize_sales_orders',
//   };

//   // Method to handle navigation with refresh callback
//   Future<void> _navigateAndRefresh(String route) async {
//     final result = await Navigator.pushNamed(context, route);
//     // Refresh data when returning from any page
//     _onPageResumed();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final favoritePages = Provider.of<FavoritePages>(context);
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home Screen'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications),
//             onPressed: () async {
//               await _navigateAndRefresh('/my_notification');
//             },
//           ),
//         ],
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: <Widget>[
//             DrawerHeader(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   SvgPicture.asset(
//                     'assets/img_new_horizon_logo.svg',
//                     height: 64,
//                   ),
//                   const SizedBox(height: 12),
//                   const Text(
//                     'New Horizon ERP',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             ListTile(
//               title: const Text('Dashboard'),
//               onTap: () async {
//                 Navigator.pop(context);
//                 await _navigateAndRefresh('/dashboard');
//               },
//             ),
//             ExpansionTile(
//               title: const Text('Purchase'),
//               children: [
//                 ListTile(
//                   title: const Text('Purchase Orders'),
//                   onTap: () async {
//                     Navigator.pop(context);
//                     await _navigateAndRefresh('/purchase_orders');
//                   },
//                 ),
//                 ListTile(
//                   title: const Text('Service Orders'),
//                   onTap: () async {
//                     Navigator.pop(context);
//                     await _navigateAndRefresh('/service_orders');
//                   },
//                 ),
//                 ListTile(
//                   title: const Text('Labour PO'),
//                   onTap: () async {
//                     Navigator.pop(context);
//                     await _navigateAndRefresh('/labour_po');
//                   },
//                 ),
//               ],
//             ),
//             ExpansionTile(
//               title: const Text('Sales'),
//               children: [
//                 ListTile(
//                   title: const Text('Leads'),
//                   onTap: () async {
//                     Navigator.pop(context);
//                     await _navigateAndRefresh('/leads');
//                   },
//                 ),
//                 ListTile(
//                   title: const Text('Follow Up'),
//                   onTap: () async {
//                     Navigator.pop(context);
//                     await _navigateAndRefresh('/follow_up');
//                   },
//                 ),
//                 ListTile(
//                   title: const Text('Quotation'),
//                   onTap: () async {
//                     Navigator.pop(context);
//                     await _navigateAndRefresh('/quotation');
//                   },
//                 ),
//                 ListTile(
//                   title: const Text('Sales Order'),
//                   onTap: () async {
//                     Navigator.pop(context);
//                     await _navigateAndRefresh('/sales_order');
//                   },
//                 ),
//                 ListTile(
//                   title: const Text('Proforma Invoice'),
//                   onTap: () async {
//                     Navigator.pop(context);
//                     await _navigateAndRefresh('/proforma_invoice');
//                   },
//                 ),
//               ],
//             ),
//             ExpansionTile(
//               title: const Text('Settings'),
//               children: [
//                 ListTile(
//                   title: const Text('My Notification'),
//                   onTap: () async {
//                     Navigator.pop(context);
//                     await _navigateAndRefresh('/my_notification');
//                   },
//                 ),
//                 ListTile(
//                   title: const Text('My Favourites'),
//                   onTap: () async {
//                     Navigator.pop(context);
//                     await _navigateAndRefresh('/my_favourites');
//                   },
//                 ),
//               ],
//             ),
//             ListTile(
//               title: const Text('Logout'),
//               onTap: () async {
//                 if (await StorageUtils.readBool('remember_me')) {
//                   await StorageUtils.deleteValue('session_token');
//                   await StorageUtils.deleteValue('selected_company');
//                   await StorageUtils.deleteValue('selected_location');
//                   await StorageUtils.deleteValue('finance_period');
//                 } else {
//                   await StorageUtils.clearAll();
//                 }
//                 if (!mounted) return;
//                 Navigator.pop(context);
//                 Navigator.of(
//                   context,
//                 ).pushNamedAndRemoveUntil('/login', (Route route) => false);
//               },
//             ),
//           ],
//         ),
//       ),
//       body: RefreshIndicator(
//         onRefresh: _onRefresh,
//         child: CustomScrollView(
//           slivers: [
//             SliverToBoxAdapter(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text('Pending Authorizations:'),
//                   if (isLoading) ...[
//                     const SizedBox(width: 8),
//                     const SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//             SliverPadding(
//               padding: const EdgeInsets.all(8),
//               sliver: SliverGrid(
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3,
//                   mainAxisSpacing: 12,
//                   crossAxisSpacing: 12,
//                   childAspectRatio: 1,
//                 ),
//                 delegate: SliverChildBuilderDelegate(
//                   (context, index) => _AuthTile(
//                     title: pendingAuthList[index]['title'] ?? '',
//                     count: pendingAuthList[index]['count'] ?? 0,
//                     onTap: () async {
//                       final route =
//                           titleToRoute[pendingAuthList[index]['title']];
//                       if (route != null) {
//                         await _navigateAndRefresh(route);
//                       }
//                     },
//                   ),
//                   childCount: pendingAuthList.length,
//                 ),
//               ),
//             ),
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   children: [
//                     const Text(
//                       'Favorite Pages:',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     favoritePages.favoriteRoutes.isEmpty
//                         ? Card(
//                           elevation: 0,
//                           child: Padding(
//                             padding: const EdgeInsets.all(24.0),
//                             child: Text(
//                               'No favorites yet.',
//                               style: TextStyle(
//                                 color: Theme.of(context).colorScheme.outline,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ),
//                         )
//                         : Wrap(
//                           spacing: 8.0,
//                           runSpacing: 8.0,
//                           alignment: WrapAlignment.center,
//                           children:
//                               favoritePages.favoriteRoutes.map((route) {
//                                 final pageName =
//                                     routeToPageName[route] ?? route;
//                                 return Card(
//                                   elevation: 0,
//                                   child: InkWell(
//                                     onTap: () async {
//                                       await _navigateAndRefresh(route);
//                                     },
//                                     borderRadius: BorderRadius.circular(12),
//                                     child: Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 16.0,
//                                         vertical: 12.0,
//                                       ),
//                                       child: Row(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           Icon(
//                                             Icons.star_border_outlined,
//                                             size: 16,
//                                             color:
//                                                 Theme.of(
//                                                   context,
//                                                 ).colorScheme.primary,
//                                           ),
//                                           const SizedBox(width: 8),
//                                           Text(
//                                             pageName,
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.w500,
//                                               color:
//                                                   Theme.of(
//                                                     context,
//                                                   ).colorScheme.onSurface,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               }).toList(),
//                         ),
//                   ],
//                 ),
//               ),
//             ),
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   children: [
//                     const Text(
//                       'Quick Links:',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     GridView.count(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       crossAxisCount: 4,
//                       mainAxisSpacing: 8,
//                       crossAxisSpacing: 8,
//                       childAspectRatio: 0.9,
//                       children: [
//                         _QuickLinkTile(
//                           title: 'Purchase Orders',
//                           icon: Icons.shopping_cart,
//                           onTap: () => _navigateAndRefresh('/purchase_orders'),
//                         ),
//                         _QuickLinkTile(
//                           title: 'Service Orders',
//                           icon: Icons.build,
//                           onTap: () => _navigateAndRefresh('/service_orders'),
//                         ),
//                         _QuickLinkTile(
//                           title: 'Labour PO',
//                           icon: Icons.person_outline,
//                           onTap: () => _navigateAndRefresh('/labour_po'),
//                         ),
//                         _QuickLinkTile(
//                           title: 'Leads',
//                           icon: Icons.track_changes,
//                           onTap: () => _navigateAndRefresh('/leads'),
//                         ),
//                         _QuickLinkTile(
//                           title: 'Follow Up',
//                           icon: Icons.follow_the_signs,
//                           onTap: () => _navigateAndRefresh('/follow_up'),
//                         ),
//                         _QuickLinkTile(
//                           title: 'Quotation',
//                           icon: Icons.description,
//                           onTap: () => _navigateAndRefresh('/quotation'),
//                         ),
//                         _QuickLinkTile(
//                           title: 'Sales Order',
//                           icon: Icons.receipt_long,
//                           onTap: () => _navigateAndRefresh('/sales_order'),
//                         ),
//                         _QuickLinkTile(
//                           title: 'Proforma Invoice',
//                           icon: Icons.article,
//                           onTap: () => _navigateAndRefresh('/proforma_invoice'),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _QuickLinkTile extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final VoidCallback onTap;

//   const _QuickLinkTile({
//     required this.title,
//     required this.icon,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 0,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 icon,
//                 size: 24,
//                 color: Theme.of(context).colorScheme.primary,
//               ),
//               const SizedBox(height: 6),
//               Flexible(
//                 child: Text(
//                   title,
//                   textAlign: TextAlign.center,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     fontSize: 10,
//                     fontWeight: FontWeight.w500,
//                     height: 1.2,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _AuthTile extends StatelessWidget {
//   final String title;
//   final int count;
//   final VoidCallback onTap;

//   const _AuthTile({
//     required this.title,
//     required this.count,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext ctx) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Card(
//         elevation: 0,
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(title, style: const TextStyle(fontSize: 12)),
//               Text('$count', style: const TextStyle(fontSize: 20)),
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
import 'package:flutter_svg/svg.dart';
import 'package:nhapp/main.dart';
import 'package:nhapp/utils/storage_utils.dart';
import 'package:provider/provider.dart';
import 'package:nhapp/utils/token_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, RouteAware {
  List<Map<String, dynamic>> pendingAuthList = [];
  bool isLoading = false;
  bool _isPageVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeDefaultData();

    // Load data immediately when page is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPendingAuthenticationCount();
    });
  }

  void _initializeDefaultData() {
    pendingAuthList = [
      {'title': 'Purchase Orders', 'count': 0},
      {'title': 'Service Orders', 'count': 0},
      {'title': 'Labour PO', 'count': 0},
      {'title': 'Quotation', 'count': 0},
      {'title': 'Sales Order', 'count': 0},
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Always refresh when dependencies change (page becomes visible)
    if (_isPageVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadPendingAuthenticationCount();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _isPageVisible) {
      _loadPendingAuthenticationCount();
    }
  }

  // Called when page becomes visible after navigation
  void _onPageResumed() {
    _isPageVisible = true;
    if (mounted) {
      _loadPendingAuthenticationCount();
    }
  }

  // Called when page becomes hidden (navigating away)
  void _onPagePaused() {
    _isPageVisible = false;
  }

  Future<void> _loadPendingAuthenticationCount() async {
    if (!mounted || !_isPageVisible) return;

    // Validate token before proceeding
    final isValid = await TokenUtils.isTokenValid(context);
    if (!isValid) {
      if (mounted) {
        setState(() {
          _initializeDefaultData();
        });
      }
      return;
    }

    try {
      final url = await StorageUtils.readValue('url');
      final companyDetails = await StorageUtils.readJson('selected_company');
      final locationDetails = await StorageUtils.readJson('selected_location');
      final tokenDetails = await StorageUtils.readJson('session_token');

      if (companyDetails == null ||
          companyDetails.isEmpty ||
          locationDetails == null ||
          locationDetails.isEmpty ||
          tokenDetails == null ||
          tokenDetails.isEmpty) {
        if (mounted) {
          setState(() {
            _initializeDefaultData();
          });
        }
        return;
      }

      final companyId = companyDetails['id'];
      final locationId = locationDetails['id'];
      final token = tokenDetails['token']['value'];

      Dio dio = Dio();
      dio.options.headers = {
        "Content-Type": "application/json; charset=utf-8",
        "Authorization": "Bearer $token",
      };
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);

      final response = await dio.get(
        'http://$url/api/Login/pendDashBoardCount',
        queryParameters: {'companyid': companyId, 'siteid': locationId},
      );

      if (response.statusCode == 200) {
        final data = await compute(_parseJson, response.data);

        if (data['success'] == true && data['data'] is List) {
          if (mounted && _isPageVisible) {
            setState(() {
              pendingAuthList = List<Map<String, dynamic>>.from(data['data']);
            });
          }
        } else {
          if (mounted) {
            _showSnackBar(data['message'] ?? 'Unknown error');
          }
        }
      } else {
        if (mounted) {
          _showSnackBar('Error: ${response.statusCode}');
        }
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
      if (mounted) {
        _showSnackBar(message);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error loading data: $e');
      }
    }
  }

  Future<void> _onRefresh() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    await _loadPendingAuthenticationCount();

    if (mounted) {
      setState(() {
        isLoading = false;
      });
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

  final Map<String, String> routeToPageName = {
    '/purchase_orders': 'Purchase Orders',
    '/service_orders': 'Service Orders',
    '/labour_po': 'Labour PO',
    '/leads': 'Leads',
    '/follow_up': 'Follow Up',
    '/quotation': 'Quotation',
    '/sales_order': 'Sales Order',
    '/proforma_invoice': 'Proforma Invoice',
  };

  final Map<String, String> titleToRoute = {
    'Purchase Orders': '/authorize_purchase_orders',
    'Service Orders': '/authorize_service_orders',
    'Labour PO': '/authorize_labour_purchase_orders',
    'Quotation': '/authorize_quotations',
    'Sales Order': '/authorize_sales_orders',
  };

  Future<void> _navigateAndRefresh(String route) async {
    _onPagePaused(); // Mark page as not visible
    final result = await Navigator.pushNamed(context, route);
    _onPageResumed(); // Mark page as visible and refresh data
  }

  @override
  Widget build(BuildContext context) {
    final favoritePages = Provider.of<FavoritePages>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () async {
              await _navigateAndRefresh('/my_notification');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/img_new_horizon_logo.svg',
                    height: 64,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'New Horizon ERP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Dashboard'),
              onTap: () async {
                Navigator.pop(context);
                await _navigateAndRefresh('/dashboard');
              },
            ),
            ExpansionTile(
              title: const Text('Purchase'),
              children: [
                ListTile(
                  title: const Text('Purchase Orders'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _navigateAndRefresh('/purchase_orders');
                  },
                ),
                ListTile(
                  title: const Text('Service Orders'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _navigateAndRefresh('/service_orders');
                  },
                ),
                ListTile(
                  title: const Text('Labour PO'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _navigateAndRefresh('/labour_po');
                  },
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('Sales'),
              children: [
                ListTile(
                  title: const Text('Leads'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _navigateAndRefresh('/leads');
                  },
                ),
                ListTile(
                  title: const Text('Follow Up'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _navigateAndRefresh('/follow_up');
                  },
                ),
                ListTile(
                  title: const Text('Quotation'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _navigateAndRefresh('/quotation');
                  },
                ),
                ListTile(
                  title: const Text('Sales Order'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _navigateAndRefresh('/sales_order');
                  },
                ),
                ListTile(
                  title: const Text('Proforma Invoice'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _navigateAndRefresh('/proforma_invoice');
                  },
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('Settings'),
              children: [
                ListTile(
                  title: const Text('My Notification'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _navigateAndRefresh('/my_notification');
                  },
                ),
                ListTile(
                  title: const Text('My Favourites'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _navigateAndRefresh('/my_favourites');
                  },
                ),
              ],
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () async {
                if (await StorageUtils.readBool('remember_me')) {
                  await StorageUtils.deleteValue('session_token');
                  await StorageUtils.deleteValue('selected_company');
                  await StorageUtils.deleteValue('selected_location');
                  await StorageUtils.deleteValue('finance_period');
                } else {
                  await StorageUtils.clearAll();
                }
                if (!mounted) return;
                Navigator.pop(context);
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (Route route) => false);
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Pending Authorizations:'),
                  if (isLoading) ...[
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(8),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _AuthTile(
                    title: pendingAuthList[index]['title'] ?? '',
                    count: pendingAuthList[index]['count'] ?? 0,
                    onTap: () async {
                      final route =
                          titleToRoute[pendingAuthList[index]['title']];
                      if (route != null) {
                        await _navigateAndRefresh(route);
                      }
                    },
                  ),
                  childCount: pendingAuthList.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Text(
                      'Favorite Pages:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    favoritePages.favoriteRoutes.isEmpty
                        ? Card(
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              'No favorites yet.',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                        : Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          alignment: WrapAlignment.center,
                          children:
                              favoritePages.favoriteRoutes.map((route) {
                                final pageName =
                                    routeToPageName[route] ?? route;
                                return Card(
                                  elevation: 0,
                                  child: InkWell(
                                    onTap: () async {
                                      await _navigateAndRefresh(route);
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 12.0,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.star_border_outlined,
                                            size: 16,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            pageName,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Text(
                      'Quick Links:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.9,
                      children: [
                        _QuickLinkTile(
                          title: 'Purchase Orders',
                          icon: Icons.shopping_cart,
                          onTap: () => _navigateAndRefresh('/purchase_orders'),
                        ),
                        _QuickLinkTile(
                          title: 'Service Orders',
                          icon: Icons.build,
                          onTap: () => _navigateAndRefresh('/service_orders'),
                        ),
                        _QuickLinkTile(
                          title: 'Labour PO',
                          icon: Icons.person_outline,
                          onTap: () => _navigateAndRefresh('/labour_po'),
                        ),
                        _QuickLinkTile(
                          title: 'Leads',
                          icon: Icons.track_changes,
                          onTap: () => _navigateAndRefresh('/leads'),
                        ),
                        _QuickLinkTile(
                          title: 'Follow Up',
                          icon: Icons.follow_the_signs,
                          onTap: () => _navigateAndRefresh('/follow_up'),
                        ),
                        _QuickLinkTile(
                          title: 'Quotation',
                          icon: Icons.description,
                          onTap: () => _navigateAndRefresh('/quotation'),
                        ),
                        _QuickLinkTile(
                          title: 'Sales Order',
                          icon: Icons.receipt_long,
                          onTap: () => _navigateAndRefresh('/sales_order'),
                        ),
                        _QuickLinkTile(
                          title: 'Proforma Invoice',
                          icon: Icons.article,
                          onTap: () => _navigateAndRefresh('/proforma_invoice'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickLinkTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickLinkTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthTile extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback onTap;

  const _AuthTile({
    required this.title,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext ctx) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(fontSize: 12)),
              Text('$count', style: const TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
