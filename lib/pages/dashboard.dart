// import 'dart:convert';

// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart' as intl;
// import 'package:nhapp/pages/TotalSalesRegionWise.dart';
// import 'package:nhapp/utils/token_utils.dart';
// import 'package:nhapp/utils/storage_utils.dart';
// import 'package:nhapp/widgets/Dashboard/Functional/purchase_amount_month_wise.dart';
// import 'package:nhapp/widgets/Dashboard/Functional/top_supplier_by_amount.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   Map<String, dynamic> dashboardData = {};
//   Map<String, dynamic> directorData = {};
//   bool isLoadingFunctional = true;
//   bool isLoadingDirector = true;
//   bool isLoadingSales = true;

//   @override
//   void initState() {
//     super.initState();
//     _validateTokenAndFetchData();
//   }

//   Future<void> _validateTokenAndFetchData() async {
//     bool isValid = await TokenUtils.isTokenValid(context);
//     if (isValid) {
//       await Future.wait([
//         _fetchFNYear(),
//         _fetchFunctionalDashboardData(),
//         _fetchDirectorDashboardData(),
//       ]);
//     }
//   }

//   Future<void> _fetchFNYear() async {
//     final url = await StorageUtils.readValue('url');
//     final companyDetails = await StorageUtils.readJson('selected_company');
//     final tokenDetails = await StorageUtils.readJson('session_token');

//     if (companyDetails == null || tokenDetails == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Company or session token not set")),
//         );
//       }
//       setState(() {
//         isLoadingSales = false;
//       });
//       return;
//     }

//     final companyId = companyDetails['id'];
//     final token = tokenDetails['token']['value'];

//     final dio = Dio();
//     dio.options.headers['Content-Type'] = 'application/json';
//     dio.options.headers['Authorization'] = 'Bearer $token';

//     try {
//       Response response = await dio.get(
//         'http://$url/api/Login/dash_getFNYears',
//         queryParameters: {'companyid': companyId},
//       );

//       if (response.statusCode == 200) {
//         var responseData =
//             response.data is String ? jsonDecode(response.data) : response.data;
//         List fnYear = responseData['data'];
//         await StorageUtils.writeValue(
//           'fn_year',
//           fnYear.isNotEmpty ? fnYear.last : null,
//         );
//       } else {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text("Error: fetching year ${response.statusCode}"),
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Exception: $e")));
//       }
//     } finally {
//       setState(() {
//         isLoadingSales = false;
//       });
//     }
//   }

//   Future<void> _fetchFunctionalDashboardData() async {
//     setState(() {
//       isLoadingFunctional = true;
//     });

//     final url = await StorageUtils.readValue('url');
//     final companyDetails = await StorageUtils.readJson('selected_company');
//     final locationDetails = await StorageUtils.readJson('selected_location');
//     final tokenDetails = await StorageUtils.readJson('session_token');

//     if (companyDetails == null ||
//         locationDetails == null ||
//         tokenDetails == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Company, location, or session token not set"),
//           ),
//         );
//       }
//       setState(() {
//         isLoadingFunctional = false;
//       });
//       return;
//     }

//     final companyId = companyDetails['id'];
//     final locationId = locationDetails['id'];
//     final token = tokenDetails['token']['value'];

//     final dio = Dio();
//     dio.options.headers['Content-Type'] = 'application/json';
//     dio.options.headers['Authorization'] = 'Bearer $token';

//     try {
//       Response response = await dio.get(
//         'http://$url/api/Login/dashboardPurchaseData',
//         queryParameters: {'companyid': companyId, 'siteid': locationId},
//       );

//       if (response.statusCode == 200) {
//         var responseData =
//             response.data is String ? jsonDecode(response.data) : response.data;

//         if (responseData['success'] == true ||
//             responseData['status'] == 'success') {
//           setState(() {
//             dashboardData = responseData['data'] ?? {};
//           });
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
//         ).showSnackBar(SnackBar(content: Text("Exception: $e")));
//       }
//     } finally {
//       setState(() {
//         isLoadingFunctional = false;
//       });
//     }
//   }

//   Future<void> _fetchDirectorDashboardData() async {
//     setState(() {
//       isLoadingDirector = true;
//     });

//     final url = await StorageUtils.readValue('url');
//     final companyDetails = await StorageUtils.readJson('selected_company');
//     final tokenDetails = await StorageUtils.readJson('session_token');

//     if (companyDetails == null || tokenDetails == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Company or session token not set")),
//         );
//       }
//       setState(() {
//         isLoadingDirector = false;
//       });
//       return;
//     }

//     final companyId = companyDetails['id'];
//     final token = tokenDetails['token']['value'];

//     final dio = Dio();
//     dio.options.headers['Content-Type'] = 'application/json';
//     dio.options.headers['Authorization'] = 'Bearer $token';

//     try {
//       Response response = await dio.get(
//         'http://$url/api/Login/dash_FetchDashboardAmount',
//         queryParameters: {'companyid': companyId},
//       );

//       if (response.statusCode == 200) {
//         var responseData =
//             response.data is String ? jsonDecode(response.data) : response.data;

//         if (responseData['success'] == true ||
//             responseData['status'] == 'success') {
//           setState(() {
//             directorData = responseData ?? {};
//           });
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
//         ).showSnackBar(SnackBar(content: Text("Exception: $e")));
//       }
//     } finally {
//       setState(() {
//         isLoadingDirector = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//         backgroundColor: const Color(0xFFFFFFFF),
//         appBar: AppBar(
//           title: const Text('Dashboard'),
//           bottom: const TabBar(
//             isScrollable: false,
//             tabs: [
//               Tab(child: Text('Functional')),
//               Tab(child: Text('Director')),
//               Tab(child: Text('Total Sales Regionwise')),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           physics: const NeverScrollableScrollPhysics(),
//           children: [
//             isLoadingFunctional
//                 ? const Center(child: CircularProgressIndicator())
//                 : FunctionalTabView(data: dashboardData),
//             isLoadingDirector
//                 ? const Center(child: CircularProgressIndicator())
//                 : DirectoralTabView(data: directorData),
//             isLoadingSales
//                 ? const Center(child: CircularProgressIndicator())
//                 : const TotalSalesRegionWisePage(),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class FunctionalTabView extends StatelessWidget {
//   final Map<String, dynamic> data;

//   const FunctionalTabView({super.key, required this.data});

//   String getValue(String key, {String defaultValue = '0'}) {
//     if (data.containsKey(key) && data[key] != null) {
//       return data[key].toString();
//     }
//     return defaultValue;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final List<Map<String, dynamic>> purchaseAmountData =
//         (data['purchaseAmountData'] as List?)
//             ?.map((e) => Map<String, dynamic>.from(e))
//             .toList() ??
//         const [];

//     final List<Map<String, dynamic>> supplierAmountData =
//         (data['supplierAmountData'] as List?)
//             ?.map((e) => Map<String, dynamic>.from(e))
//             .toList() ??
//         const [];

//     if (data.isEmpty) {
//       return const Center(child: Text("No dashboard data available"));
//     }

//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: ListView.builder(
//         physics: const BouncingScrollPhysics(),
//         itemCount: 6,
//         itemBuilder: (context, index) {
//           switch (index) {
//             case 0:
//               return _FunctionalCard(
//                 title: 'Item Pending for delivery',
//                 value: getValue('pendingReceiveGoodsValue'),
//                 subtitle: 'Items Pending ',
//                 count: getValue('pendingReceiveGoodsCount'),
//                 onTap:
//                     () => Navigator.pushNamed(
//                       context,
//                       '/items_pending_for_delivery',
//                     ),
//               );
//             case 1:
//               return _FunctionalCard(
//                 title: 'Upcoming next delivery',
//                 value: getValue('upcomingReceiveGoodsValue'),
//                 subtitle: 'Items Pending ',
//                 count: getValue('upcomingReceiveGoodsCount'),
//                 onTap:
//                     () =>
//                         Navigator.pushNamed(context, '/upcoming_next_delivery'),
//               );
//             case 2:
//               return _FunctionalCard(
//                 title: 'Delivery Overdue',
//                 value: getValue('overdueReceiveGoodsValue'),
//                 subtitle: 'Items Pending ',
//                 count: getValue('overdueReceiveGoodsCount'),
//                 onTap: () => Navigator.pushNamed(context, '/delivery_overdue'),
//               );
//             case 3:
//               return _FunctionalCard(
//                 title: 'Unauthorized PO Count',
//                 value: getValue('unauthorisedPoCount'),
//                 subtitle: null,
//                 count: null,
//                 onTap:
//                     () => Navigator.pushNamed(
//                       context,
//                       '/authorize_purchase_orders',
//                     ),
//               );
//             case 4:
//               return const SizedBox(height: 16);
//             case 5:
//               return Column(
//                 children: [
//                   PurchaseAmountBarChartCard(
//                     purchaseAmountData: purchaseAmountData,
//                   ),
//                   SupplierAmountBarChartCard(supplierData: supplierAmountData),
//                 ],
//               );
//             default:
//               return const SizedBox.shrink();
//           }
//         },
//       ),
//     );
//   }
// }

// class _FunctionalCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final String? subtitle;
//   final String? count;
//   final VoidCallback? onTap;

//   const _FunctionalCard({
//     required this.title,
//     required this.value,
//     this.subtitle,
//     this.count,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Card(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       color: Color(0xFF64748b),
//                     ),
//                   ),
//                   Text(
//                     value,
//                     style: const TextStyle(
//                       fontSize: 30,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             if (subtitle != null && count != null)
//               Padding(
//                 padding: const EdgeInsets.only(left: 24.0, bottom: 24.0),
//                 child: Row(
//                   children: [
//                     Text(subtitle!),
//                     Text(
//                       count!,
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             const SizedBox(height: 8),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Title mapping for amount codes
// const amountTitles = {
//   "RECOVRD": "Retention Amount",
//   "PAYOVRD": "Payable Overdue",
//   "RECEIVABLE": "Total Receivable Amount",
//   "PAYABLE": "Total Payable Amount",
//   "SALES": "Total Sales Amount",
// };

// class DirectoralTabView extends StatelessWidget {
//   final Map<String, dynamic> data;

//   const DirectoralTabView({super.key, required this.data});

//   @override
//   Widget build(BuildContext context) {
//     final Map<String, dynamic> dashboard =
//         data.containsKey('data') && data['data'] is Map
//             ? Map<String, dynamic>.from(data['data'])
//             : data;

//     final List amounts = dashboard['amounts'] ?? [];
//     final List ordertile = dashboard['ordertile'] ?? [];
//     final List dispatchtile = dashboard['dispatchtile'] ?? [];
//     final List overduedispatchtile = dashboard['overduedispatchtile'] ?? [];

//     final double orderAmount = _parseDouble(dashboard['orderAmount']);
//     final double dispatchAmount = _parseDouble(dashboard['dispatchAmount']);
//     final double overduedispatchAmount = _parseDouble(
//       dashboard['overduedispatchAmount'],
//     );

//     if (dashboard.isEmpty) {
//       return const Center(child: Text("No dashboard data available"));
//     }

//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: ListView(
//         physics: const BouncingScrollPhysics(),
//         children: [
//           if (amounts.isEmpty)
//             const Center(child: Text("No amount data available"))
//           else
//             ...amounts.map<Widget>((amt) {
//               return Card(
//                 child: SizedBox(
//                   width: double.infinity,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           amountTitles[amt["code"]] ?? amt["code"],
//                           style: const TextStyle(
//                             fontSize: 14,
//                             color: Color(0xFF64748b),
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           intl.NumberFormat.currency(
//                             locale: 'en_IN',
//                             symbol: '',
//                             decimalDigits: 2,
//                           ).format(_parseDouble(amt["totalamount"])),
//                           style: const TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             }),
//           const SizedBox(height: 24),
//           const Divider(),
//           const SizedBox(height: 24),
//           _DirectorOrderCard(
//             title: 'Orders',
//             amount: orderAmount,
//             count: ordertile.length,
//             onTap:
//                 () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder:
//                         (_) => DetailsPage(
//                           title: "Order Overdue Dispatch",
//                           list: ordertile,
//                         ),
//                   ),
//                 ),
//           ),
//           _DirectorOrderCard(
//             title: 'Order Dispatch',
//             amount: dispatchAmount,
//             count: dispatchtile.length,
//             onTap:
//                 () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder:
//                         (_) => DetailsPage(
//                           title: "Order Overdue Dispatch",
//                           list: dispatchtile,
//                         ),
//                   ),
//                 ),
//           ),
//           _DirectorOrderCard(
//             title: 'Order Overdue Dispatch',
//             amount: overduedispatchAmount,
//             count: overduedispatchtile.length,
//             onTap:
//                 () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder:
//                         (_) => DetailsPage(
//                           title: "Order Overdue Dispatch",
//                           list: overduedispatchtile,
//                         ),
//                   ),
//                 ),
//           ),
//           const SizedBox(height: 24),
//           const Divider(),
//           const SizedBox(height: 8),
//           ..._directorListTiles(context),
//         ],
//       ),
//     );
//   }

//   double _parseDouble(dynamic value) {
//     if (value == null) return 0.0;
//     if (value is num) return value.toDouble();
//     if (value is String) {
//       try {
//         return double.parse(value);
//       } catch (_) {
//         return 0.0;
//       }
//     }
//     return 0.0;
//   }

//   List<Widget> _directorListTiles(BuildContext context) {
//     return [
//       _DirectorListTile(title: "Report Chart", route: '/director_report_chart'),
//       _DirectorListTile(
//         title: "Top 10 Customers by Sales Amount",
//         route: '/customer_by_sales_amount',
//       ),
//       _DirectorListTile(
//         title: "Best Selling Items By Sales Amount",
//         route: '/best_selling_items_by_sales_amount',
//       ),
//       _DirectorListTile(
//         title: "Customers By Receivable Overdue Chart",
//         route: '/customers_by_receivable_overdue_chart',
//       ),
//       _DirectorListTile(title: "Sales Analysis", route: '/sales_analysis'),
//       _DirectorListTile(
//         title: "Ageing Of Receivable Overdue",
//         route: '/ageing_of_receivable_overdue',
//       ),
//       _DirectorListTile(
//         title: "Dispatch Amount By Months",
//         route: '/dispatch_amount_by_months',
//       ),
//       _DirectorListTile(
//         title: "Key Deals - Recent Inquiries",
//         route: '/recent_inquiries',
//       ),
//     ];
//   }
// }

// class _DirectorOrderCard extends StatelessWidget {
//   final String title;
//   final double amount;
//   final int count;
//   final VoidCallback onTap;

//   const _DirectorOrderCard({
//     required this.title,
//     required this.amount,
//     required this.count,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Card(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       color: Color(0xFF64748b),
//                     ),
//                   ),
//                   Text(
//                     intl.NumberFormat.currency(
//                       locale: 'en_IN',
//                       symbol: '',
//                       decimalDigits: 2,
//                     ).format(amount),
//                     style: const TextStyle(
//                       fontSize: 30,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(left: 24.0, bottom: 24.0),
//               child: Row(
//                 children: [
//                   const Text("Count is "),
//                   Text(
//                     count.toString(),
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 8),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _DirectorListTile extends StatelessWidget {
//   final String title;
//   final String route;

//   const _DirectorListTile({required this.title, required this.route});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         ListTile(
//           title: Text(
//             title,
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//           ),
//           trailing: const Icon(Icons.arrow_forward_ios),
//           onTap: () => Navigator.pushNamed(context, route),
//         ),
//         const SizedBox(height: 4),
//         const Divider(),
//         const SizedBox(height: 4),
//       ],
//     );
//   }
// }

// class DetailsPage extends StatefulWidget {
//   final String title;
//   final List list;

//   const DetailsPage({super.key, required this.title, required this.list});

//   @override
//   State<DetailsPage> createState() => _DetailsPageState();
// }

// class _DetailsPageState extends State<DetailsPage> {
//   String search = "";

//   String formatKey(String key) {
//     // Convert snake_case or camelCase to Title Case
//     final spaced = key
//         .replaceAllMapped(
//           RegExp(r'([a-z])([A-Z])'),
//           (m) => '${m.group(1)} ${m.group(2)}',
//         )
//         .replaceAll('_', ' ');
//     return spaced
//         .split(' ')
//         .map((w) {
//           if (w.isEmpty) return w;
//           return w[0].toUpperCase() + w.substring(1).toLowerCase();
//         })
//         .join(' ');
//   }

//   String formatValue(String key, dynamic value) {
//     // Try to format as date
//     if (value is DateTime) {
//       return intl.DateFormat("dd/MM/yyyy").format(value);
//     }
//     if (value is String) {
//       // Try to parse as date
//       try {
//         final dt = DateTime.parse(value);
//         if (dt.year > 1900 && dt.year < 2100) {
//           return intl.DateFormat("dd/MM/yyyy").format(dt);
//         }
//       } catch (_) {}
//     }
//     // Format as amount if key suggests so or value is num
//     if (key.toLowerCase().contains('amount') ||
//         key.toLowerCase().contains('total')) {
//       if (value is num) {
//         return intl.NumberFormat.currency(
//           locale: 'en_IN',
//           symbol: "",
//           decimalDigits: 0,
//         ).format(value);
//       }
//       if (value is String) {
//         final numValue = num.tryParse(value.replaceAll(',', ''));
//         if (numValue != null) {
//           return intl.NumberFormat.currency(
//             locale: 'en_IN',
//             symbol: "",
//             decimalDigits: 0,
//           ).format(numValue);
//         }
//       }
//     }
//     // Default: just show as string
//     return value?.toString() ?? "";
//   }

//   @override
//   Widget build(BuildContext context) {
//     final filteredList =
//         widget.list.where((item) {
//           final str = item.toString().toLowerCase();
//           return str.contains(search.trim().toLowerCase());
//         }).toList();

//     return Scaffold(
//       appBar: AppBar(title: Text(widget.title)),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: TextField(
//               decoration: const InputDecoration(
//                 labelText: "Search",
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.search),
//               ),
//               onChanged: (val) => setState(() => search = val),
//             ),
//           ),
//           Expanded(
//             child:
//                 filteredList.isEmpty
//                     ? const Center(child: Text("No records found."))
//                     : ListView.builder(
//                       itemCount: filteredList.length,
//                       itemBuilder: (context, idx) {
//                         final Map<String, dynamic> item =
//                             filteredList[idx] as Map<String, dynamic>;
//                         final title =
//                             item["customername"] ??
//                             item["itemname"] ??
//                             "Item #${idx + 1}";
//                         final amount = item["amount"];

//                         return Card(
//                           margin: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 6,
//                           ),
//                           child: ExpansionTile(
//                             tilePadding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 8,
//                             ),
//                             title: Text(
//                               title.toString(),
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             subtitle:
//                                 amount != null
//                                     ? Text(
//                                       "Amount: ${formatValue('amount', amount)}",
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     )
//                                     : null,
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 16,
//                                   vertical: 8,
//                                 ),
//                                 child: Table(
//                                   columnWidths: const {
//                                     0: IntrinsicColumnWidth(),
//                                     1: FlexColumnWidth(),
//                                   },
//                                   defaultVerticalAlignment:
//                                       TableCellVerticalAlignment.middle,
//                                   children:
//                                       item.entries.map((e) {
//                                         return TableRow(
//                                           children: [
//                                             Padding(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                     vertical: 4,
//                                                   ),
//                                               child: Text(
//                                                 "${formatKey(e.key)}:",
//                                                 style: const TextStyle(
//                                                   fontWeight: FontWeight.w500,
//                                                   color: Colors.grey,
//                                                 ),
//                                               ),
//                                             ),
//                                             Padding(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                     vertical: 4,
//                                                   ),
//                                               child: SelectableText(
//                                                 formatValue(e.key, e.value),
//                                                 style: const TextStyle(
//                                                   fontSize: 14,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         );
//                                       }).toList(),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:nhapp/pages/total_sales_region_wise.dart';
import 'package:nhapp/utils/token_utils.dart';
import 'package:nhapp/utils/storage_utils.dart';
import 'package:nhapp/widgets/Dashboard/Functional/purchase_amount_month_wise.dart';
import 'package:nhapp/widgets/Dashboard/Functional/top_supplier_by_amount.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic> dashboardData = {};
  Map<String, dynamic> directorData = {};
  bool isLoadingFunctional = true;
  bool isLoadingDirector = true;
  bool isLoadingSales = true;

  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _validateTokenAndFetchData();
  }

  Future<void> _validateTokenAndFetchData() async {
    setState(() {
      isLoadingFunctional = true;
      isLoadingDirector = true;
      isLoadingSales = true;
    });

    try {
      final isValid = await TokenUtils.isTokenValid(context);
      if (!isValid) {
        _showSnackBar('Session expired. Please log in again.');
        setState(() {
          isLoadingFunctional = false;
          isLoadingDirector = false;
          isLoadingSales = false;
        });
        return;
      }

      await Future.wait([
        _fetchFNYear(),
        _fetchFunctionalDashboardData(),
        _fetchDirectorDashboardData(),
      ]);
    } catch (e) {
      _showSnackBar('Unexpected error: $e');
      setState(() {
        isLoadingFunctional = false;
        isLoadingDirector = false;
        isLoadingSales = false;
      });
    }
  }

  Future<void> _fetchFNYear() async {
    try {
      final url = await StorageUtils.readValue('url');
      final companyDetails = await StorageUtils.readJson('selected_company');
      final tokenDetails = await StorageUtils.readJson('session_token');

      if (companyDetails == null || tokenDetails == null) {
        _showSnackBar("Company or session token not set");
        return;
      }

      final companyId = companyDetails['id'];
      final token = tokenDetails['token']['value'];

      _dio.options.headers['Content-Type'] = 'application/json';
      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.get(
        'http://$url/api/Login/dash_getFNYears',
        queryParameters: {'companyid': companyId},
      );

      if (response.statusCode == 200) {
        // Parse JSON in isolate
        final responseData = await compute(_parseJson, response.data);
        final List fnYear = responseData['data'];
        await StorageUtils.writeValue(
          'fn_year',
          fnYear.isNotEmpty ? fnYear.last : null,
        );
      } else {
        _showSnackBar("Error: fetching year ${response.statusCode}");
      }
    } catch (e) {
      _showSnackBar("Exception: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoadingSales = false;
        });
      }
    }
  }

  Future<void> _fetchFunctionalDashboardData() async {
    try {
      final url = await StorageUtils.readValue('url');
      final companyDetails = await StorageUtils.readJson('selected_company');
      final locationDetails = await StorageUtils.readJson('selected_location');
      final tokenDetails = await StorageUtils.readJson('session_token');

      if (companyDetails == null ||
          locationDetails == null ||
          tokenDetails == null) {
        _showSnackBar("Company, location, or session token not set");
        return;
      }

      final companyId = companyDetails['id'];
      final locationId = locationDetails['id'];
      final token = tokenDetails['token']['value'];

      _dio.options.headers['Content-Type'] = 'application/json';
      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.get(
        'http://$url/api/Login/dashboardPurchaseData',
        queryParameters: {'companyid': companyId, 'siteid': locationId},
      );

      if (response.statusCode == 200) {
        // Parse JSON in isolate
        final responseData = await compute(_parseJson, response.data);

        if (responseData['success'] == true ||
            responseData['status'] == 'success') {
          if (mounted) {
            setState(() {
              dashboardData = responseData['data'] ?? {};
            });
          }
        } else {
          _showSnackBar(
            "API returned error: ${responseData['message'] ?? 'Unknown error'}",
          );
        }
      } else {
        _showSnackBar("Error: ${response.statusCode}");
      }
    } catch (e) {
      _showSnackBar("Exception: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoadingFunctional = false;
        });
      }
    }
  }

  Future<void> _fetchDirectorDashboardData() async {
    try {
      final url = await StorageUtils.readValue('url');
      final companyDetails = await StorageUtils.readJson('selected_company');
      final tokenDetails = await StorageUtils.readJson('session_token');

      if (companyDetails == null || tokenDetails == null) {
        _showSnackBar("Company or session token not set");
        return;
      }

      final companyId = companyDetails['id'];
      final token = tokenDetails['token']['value'];

      _dio.options.headers['Content-Type'] = 'application/json';
      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.get(
        'http://$url/api/Login/dash_FetchDashboardAmount',
        queryParameters: {'companyid': companyId},
      );

      if (response.statusCode == 200) {
        // Parse JSON in isolate
        final responseData = await compute(_parseJson, response.data);

        if (responseData['success'] == true ||
            responseData['status'] == 'success') {
          if (mounted) {
            setState(() {
              directorData = responseData;
            });
          }
        } else {
          _showSnackBar(
            "API returned error: ${responseData['message'] ?? 'Unknown error'}",
          );
        }
      } else {
        _showSnackBar("Error: ${response.statusCode}");
      }
    } catch (e) {
      _showSnackBar("Exception: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoadingDirector = false;
        });
      }
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: AppBar(
          title: const Text('Dashboard'),
          bottom: const TabBar(
            isScrollable: false,
            tabs: [
              Tab(child: Text('Functional')),
              Tab(child: Text('Director')),
              Tab(child: Text('Total Sales Regionwise')),
            ],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            isLoadingFunctional
                ? const Center(child: CircularProgressIndicator())
                : FunctionalTabView(data: dashboardData),
            isLoadingDirector
                ? const Center(child: CircularProgressIndicator())
                : DirectoralTabView(data: directorData),
            isLoadingSales
                ? const Center(child: CircularProgressIndicator())
                : const TotalSalesRegionWisePage(),
          ],
        ),
      ),
    );
  }
}

// Top-level function for compute (must be top-level or static)
Map<String, dynamic> _parseJson(dynamic data) {
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

class FunctionalTabView extends StatelessWidget {
  final Map<String, dynamic> data;

  const FunctionalTabView({super.key, required this.data});

  String getValue(String key, {String defaultValue = '0'}) {
    if (data.containsKey(key) && data[key] != null) {
      return data[key].toString();
    }
    return defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> purchaseAmountData =
        (data['purchaseAmountData'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e))
            .toList() ??
        const [];

    final List<Map<String, dynamic>> supplierAmountData =
        (data['supplierAmountData'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e))
            .toList() ??
        const [];

    if (data.isEmpty) {
      return const Center(child: Text("No dashboard data available"));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: 6,
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return _FunctionalCard(
                title: 'Item Pending for delivery',
                value: getValue('pendingReceiveGoodsValue'),
                subtitle: 'Items Pending ',
                count: getValue('pendingReceiveGoodsCount'),
                onTap:
                    () => Navigator.pushNamed(
                      context,
                      '/items_pending_for_delivery',
                    ),
              );
            case 1:
              return _FunctionalCard(
                title: 'Upcoming next delivery',
                value: getValue('upcomingReceiveGoodsValue'),
                subtitle: 'Items Pending ',
                count: getValue('upcomingReceiveGoodsCount'),
                onTap:
                    () =>
                        Navigator.pushNamed(context, '/upcoming_next_delivery'),
              );
            case 2:
              return _FunctionalCard(
                title: 'Delivery Overdue',
                value: getValue('overdueReceiveGoodsValue'),
                subtitle: 'Items Pending ',
                count: getValue('overdueReceiveGoodsCount'),
                onTap: () => Navigator.pushNamed(context, '/delivery_overdue'),
              );
            case 3:
              return _FunctionalCard(
                title: 'Unauthorized PO Count',
                value: getValue('unauthorisedPoCount'),
                subtitle: null,
                count: null,
                onTap:
                    () => Navigator.pushNamed(
                      context,
                      '/authorize_purchase_orders',
                    ),
              );
            case 4:
              return const SizedBox(height: 16);
            case 5:
              return Column(
                children: [
                  PurchaseAmountBarChartCard(
                    purchaseAmountData: purchaseAmountData,
                  ),
                  SupplierAmountBarChartCard(supplierData: supplierAmountData),
                ],
              );
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

class _FunctionalCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final String? count;
  final VoidCallback? onTap;

  const _FunctionalCard({
    required this.title,
    required this.value,
    this.subtitle,
    this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748b),
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (subtitle != null && count != null)
              Padding(
                padding: const EdgeInsets.only(left: 24.0, bottom: 24.0),
                child: Row(
                  children: [
                    Text(subtitle!),
                    Text(
                      count!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// Title mapping for amount codes
const amountTitles = {
  "RECOVRD": "Retention Amount",
  "PAYOVRD": "Payable Overdue",
  "RECEIVABLE": "Total Receivable Amount",
  "PAYABLE": "Total Payable Amount",
  "SALES": "Total Sales Amount",
};

class DirectoralTabView extends StatelessWidget {
  final Map<String, dynamic> data;

  const DirectoralTabView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> dashboard =
        data.containsKey('data') && data['data'] is Map
            ? Map<String, dynamic>.from(data['data'])
            : data;

    final List amounts = dashboard['amounts'] ?? [];
    final List ordertile = dashboard['ordertile'] ?? [];
    final List dispatchtile = dashboard['dispatchtile'] ?? [];
    final List overduedispatchtile = dashboard['overduedispatchtile'] ?? [];

    final double orderAmount = _parseDouble(dashboard['orderAmount']);
    final double dispatchAmount = _parseDouble(dashboard['dispatchAmount']);
    final double overduedispatchAmount = _parseDouble(
      dashboard['overduedispatchAmount'],
    );

    if (dashboard.isEmpty) {
      return const Center(child: Text("No dashboard data available"));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          if (amounts.isEmpty)
            const Center(child: Text("No amount data available"))
          else
            ...amounts.map<Widget>((amt) {
              return Card(
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          amountTitles[amt["code"]] ?? amt["code"],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748b),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          intl.NumberFormat.currency(
                            locale: 'en_IN',
                            symbol: '',
                            decimalDigits: 2,
                          ).format(_parseDouble(amt["totalamount"])),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          _DirectorOrderCard(
            title: 'Orders',
            amount: orderAmount,
            count: ordertile.length,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => DetailsPage(
                          title: "Order Overdue Dispatch",
                          list: ordertile,
                        ),
                  ),
                ),
          ),
          _DirectorOrderCard(
            title: 'Order Dispatch',
            amount: dispatchAmount,
            count: dispatchtile.length,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => DetailsPage(
                          title: "Order Overdue Dispatch",
                          list: dispatchtile,
                        ),
                  ),
                ),
          ),
          _DirectorOrderCard(
            title: 'Order Overdue Dispatch',
            amount: overduedispatchAmount,
            count: overduedispatchtile.length,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => DetailsPage(
                          title: "Order Overdue Dispatch",
                          list: overduedispatchtile,
                        ),
                  ),
                ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),
          ..._directorListTiles(context),
        ],
      ),
    );
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return 0.0;
      }
    }
    return 0.0;
  }

  List<Widget> _directorListTiles(BuildContext context) {
    return [
      _DirectorListTile(title: "Report Chart", route: '/director_report_chart'),
      _DirectorListTile(
        title: "Top 10 Customers by Sales Amount",
        route: '/customer_by_sales_amount',
      ),
      _DirectorListTile(
        title: "Best Selling Items By Sales Amount",
        route: '/best_selling_items_by_sales_amount',
      ),
      _DirectorListTile(
        title: "Customers By Receivable Overdue Chart",
        route: '/customers_by_receivable_overdue_chart',
      ),
      _DirectorListTile(title: "Sales Analysis", route: '/sales_analysis'),
      _DirectorListTile(
        title: "Ageing Of Receivable Overdue",
        route: '/ageing_of_receivable_overdue',
      ),
      _DirectorListTile(
        title: "Dispatch Amount By Months",
        route: '/dispatch_amount_by_months',
      ),
      _DirectorListTile(
        title: "Key Deals - Recent Inquiries",
        route: '/recent_inquiries',
      ),
    ];
  }
}

class _DirectorOrderCard extends StatelessWidget {
  final String title;
  final double amount;
  final int count;
  final VoidCallback onTap;

  const _DirectorOrderCard({
    required this.title,
    required this.amount,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748b),
                    ),
                  ),
                  Text(
                    intl.NumberFormat.currency(
                      locale: 'en_IN',
                      symbol: '',
                      decimalDigits: 2,
                    ).format(amount),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24.0, bottom: 24.0),
              child: Row(
                children: [
                  const Text("Count is "),
                  Text(
                    count.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DirectorListTile extends StatelessWidget {
  final String title;
  final String route;

  const _DirectorListTile({required this.title, required this.route});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => Navigator.pushNamed(context, route),
        ),
        const SizedBox(height: 4),
        const Divider(),
        const SizedBox(height: 4),
      ],
    );
  }
}

class DetailsPage extends StatefulWidget {
  final String title;
  final List list;

  const DetailsPage({super.key, required this.title, required this.list});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  String search = "";

  String formatKey(String key) {
    // Convert snake_case or camelCase to Title Case
    final spaced = key
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (m) => '${m.group(1)} ${m.group(2)}',
        )
        .replaceAll('_', ' ');
    return spaced
        .split(' ')
        .map((w) {
          if (w.isEmpty) return w;
          return w[0].toUpperCase() + w.substring(1).toLowerCase();
        })
        .join(' ');
  }

  String formatValue(String key, dynamic value) {
    // Try to format as date
    if (value is DateTime) {
      return intl.DateFormat("dd/MM/yyyy").format(value);
    }
    if (value is String) {
      // Try to parse as date
      try {
        final dt = DateTime.parse(value);
        if (dt.year > 1900 && dt.year < 2100) {
          return intl.DateFormat("dd/MM/yyyy").format(dt);
        }
      } catch (_) {}
    }
    // Format as amount if key suggests so or value is num
    if (key.toLowerCase().contains('amount') ||
        key.toLowerCase().contains('total')) {
      if (value is num) {
        return intl.NumberFormat.currency(
          locale: 'en_IN',
          symbol: "",
          decimalDigits: 0,
        ).format(value);
      }
      if (value is String) {
        final numValue = num.tryParse(value.replaceAll(',', ''));
        if (numValue != null) {
          return intl.NumberFormat.currency(
            locale: 'en_IN',
            symbol: "",
            decimalDigits: 0,
          ).format(numValue);
        }
      }
    }
    // Default: just show as string
    return value?.toString() ?? "";
  }

  @override
  Widget build(BuildContext context) {
    final filteredList =
        widget.list.where((item) {
          final str = item.toString().toLowerCase();
          return str.contains(search.trim().toLowerCase());
        }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "Search",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) => setState(() => search = val),
            ),
          ),
          Expanded(
            child:
                filteredList.isEmpty
                    ? const Center(child: Text("No records found."))
                    : ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, idx) {
                        final Map<String, dynamic> item =
                            filteredList[idx] as Map<String, dynamic>;
                        final title =
                            item["customername"] ??
                            item["itemname"] ??
                            "Item #${idx + 1}";
                        final amount = item["amount"];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text(
                              title.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle:
                                amount != null
                                    ? Text(
                                      "Amount: ${formatValue('amount', amount)}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                    : null,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Table(
                                  columnWidths: const {
                                    0: IntrinsicColumnWidth(),
                                    1: FlexColumnWidth(),
                                  },
                                  defaultVerticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  children:
                                      item.entries.map((e) {
                                        return TableRow(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4,
                                                  ),
                                              child: Text(
                                                "${formatKey(e.key)}:",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4,
                                                  ),
                                              child: SelectableText(
                                                formatValue(e.key, e.value),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
