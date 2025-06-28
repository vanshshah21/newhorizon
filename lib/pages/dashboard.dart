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
import 'package:nhapp/utils/format_utils.dart';
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
            // case 3:
            //   return _FunctionalCard(
            //     title: 'Unauthorized PO Count',
            //     value: getValue('unauthorisedPoCount'),
            //     subtitle: null,
            //     count: null,
            //     onTap:
            //         () => Navigator.pushNamed(
            //           context,
            //           '/authorize_purchase_orders',
            //         ),
            //   );
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748b),
                          ),
                        ),
                      ),
                      if (onTap != null)
                        Icon(
                          // Icons.touch_app_outlined,
                          Icons.arrow_forward_ios,
                          size: 20,
                          color: Colors.grey,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
  "RECOVRD": "Receivable Amount",
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
                          FormatUtils.formatAmount(
                            _parseDouble(amt["totalamount"]),
                          ),
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
          // _DirectorOrderCard(
          //   title: 'Orders',
          //   amount: orderAmount,
          //   count: ordertile.length,
          //   onTap:
          //       () => Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder:
          //               (_) => DetailsPage(
          //                 title: "Order Overdue Dispatch",
          //                 list: ordertile,
          //               ),
          //         ),
          //       ),
          // ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748b),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    FormatUtils.formatAmount(amount),
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
//       } catch (_) {
//         return value; // Return as is if not a valid date
//       }
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
//                                       "Amount: ${FormatUtils.formatAmount(amount)}",
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

// ...existing imports and code...

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
    // Try to format as date using FormatUtils
    if (value is DateTime) {
      return FormatUtils.formatDateForUser(value);
    }
    if (value is String) {
      // Try to parse as date - be more careful with date detection
      if (key.toLowerCase().contains('date') ||
          key.toLowerCase().contains('time') ||
          key.toLowerCase().endsWith('dt') ||
          key.toLowerCase().endsWith('on')) {
        try {
          final dt = DateTime.parse(value);
          if (dt.year > 1900 && dt.year < 2100) {
            return FormatUtils.formatDateForUser(dt);
          }
        } catch (_) {
          // If date parsing fails, return as string
        }
      }
    }

    // Format as amount using FormatUtils if key suggests so
    if (key.toLowerCase().contains('amount') ||
        key.toLowerCase().contains('total') ||
        key.toLowerCase().contains('price') ||
        key.toLowerCase().contains('cost') ||
        key.toLowerCase().contains('value')) {
      try {
        return FormatUtils.formatAmount(value);
      } catch (_) {
        // If amount formatting fails, return as string
      }
    }

    // Format as quantity using FormatUtils if key suggests so
    if (key.toLowerCase().contains('quantity') ||
        key.toLowerCase().contains('qty') ||
        key.toLowerCase().contains('count')) {
      try {
        return FormatUtils.formatQuantity(value);
      } catch (_) {
        // If quantity formatting fails, return as string
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
                            item["companyname"] ??
                            "Item #${idx + 1}";
                        final amount = item["amount"];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Colors.white, Colors.grey.shade50],
                              ),
                            ),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              collapsedShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              iconColor: Theme.of(context).primaryColor,
                              collapsedIconColor: Colors.grey.shade600,
                              title: Text(
                                title.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              subtitle:
                                  amount != null
                                      ? Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          "Amount: ${FormatUtils.formatAmount(amount)}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      )
                                      : null,
                              children: [
                                Container(
                                  margin: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    16,
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Table(
                                    columnWidths: const {
                                      0: IntrinsicColumnWidth(),
                                      1: FlexColumnWidth(),
                                    },
                                    defaultVerticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    children:
                                        // item.entries.map((e) {
                                        //   if (e.value == null ||
                                        //       e.value.toString().isEmpty) {
                                        //     return TableRow(
                                        //       children: [
                                        //         Padding(
                                        //           padding:
                                        //               const EdgeInsets.symmetric(
                                        //                 vertical: 6,
                                        //                 horizontal: 8,
                                        //               ),
                                        //           child: Text(
                                        //             "${formatKey(e.key)}:",
                                        //             style: const TextStyle(
                                        //               fontWeight:
                                        //                   FontWeight.w600,
                                        //               color: Colors.black54,
                                        //               fontSize: 13,
                                        //             ),
                                        //           ),
                                        //         ),
                                        //         Padding(
                                        //           padding:
                                        //               const EdgeInsets.symmetric(
                                        //                 vertical: 6,
                                        //                 horizontal: 8,
                                        //               ),
                                        //           child: const Text(
                                        //             "N/A",
                                        //             style: TextStyle(
                                        //               fontSize: 14,
                                        //               color: Colors.black87,
                                        //               fontWeight:
                                        //                   FontWeight.w500,
                                        //             ),
                                        //           ),
                                        //         ),
                                        //       ],
                                        //     );
                                        //   }
                                        //   return TableRow(
                                        //     children: [
                                        //       Padding(
                                        //         padding:
                                        //             const EdgeInsets.symmetric(
                                        //               vertical: 6,
                                        //               horizontal: 8,
                                        //             ),
                                        //         child: Text(
                                        //           "${formatKey(e.key)}:",
                                        //           style: const TextStyle(
                                        //             fontWeight: FontWeight.w600,
                                        //             color: Colors.black54,
                                        //             fontSize: 13,
                                        //           ),
                                        //         ),
                                        //       ),
                                        //       Padding(
                                        //         padding:
                                        //             const EdgeInsets.symmetric(
                                        //               vertical: 6,
                                        //               horizontal: 8,
                                        //             ),
                                        //         child: SelectableText(
                                        //           formatValue(e.key, e.value),
                                        //           style: const TextStyle(
                                        //             fontSize: 14,
                                        //             color: Colors.black87,
                                        //             fontWeight: FontWeight.w500,
                                        //           ),
                                        //         ),
                                        //       ),
                                        //     ],
                                        //   );
                                        // }).toList(),
                                        item.entries
                                            .where((e) {
                                              // Filter out null, empty, or whitespace-only values
                                              if (e.value == null) return false;
                                              if (e.value
                                                  .toString()
                                                  .trim()
                                                  .isEmpty)
                                                return false;
                                              return true;
                                            })
                                            .map((e) {
                                              return TableRow(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 6,
                                                          horizontal: 8,
                                                        ),
                                                    child: Text(
                                                      "${formatKey(e.key)}:",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black54,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 6,
                                                          horizontal: 8,
                                                        ),
                                                    child: SelectableText(
                                                      formatValue(
                                                        e.key,
                                                        e.value,
                                                      ),
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black87,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            })
                                            .toList(),
                                  ),
                                ),
                              ],
                            ),
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

// import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart' as intl;
// import 'package:nhapp/pages/total_sales_region_wise.dart';
// import 'package:nhapp/utils/token_utils.dart';
// import 'package:nhapp/utils/storage_utils.dart';
// import 'package:nhapp/widgets/Dashboard/Functional/purchase_amount_month_wise.dart';
// import 'package:nhapp/widgets/Dashboard/Functional/top_supplier_by_amount.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen>
//     with TickerProviderStateMixin {
//   Map<String, dynamic> dashboardData = {};
//   Map<String, dynamic> directorData = {};
//   bool isLoadingFunctional = true;
//   bool isLoadingDirector = true;
//   bool isLoadingSales = true;

//   late TabController _tabController;
//   final Dio _dio = Dio();

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _validateTokenAndFetchData();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _validateTokenAndFetchData() async {
//     setState(() {
//       isLoadingFunctional = true;
//       isLoadingDirector = true;
//       isLoadingSales = true;
//     });

//     try {
//       final isValid = await TokenUtils.isTokenValid(context);
//       if (!isValid) {
//         _showSnackBar('Session expired. Please log in again.', isError: true);
//         setState(() {
//           isLoadingFunctional = false;
//           isLoadingDirector = false;
//           isLoadingSales = false;
//         });
//         return;
//       }

//       await Future.wait([
//         _fetchFNYear(),
//         _fetchFunctionalDashboardData(),
//         _fetchDirectorDashboardData(),
//       ]);
//     } catch (e) {
//       _showSnackBar('Unexpected error: $e', isError: true);
//       setState(() {
//         isLoadingFunctional = false;
//         isLoadingDirector = false;
//         isLoadingSales = false;
//       });
//     }
//   }

//   Future<void> _fetchFNYear() async {
//     try {
//       final url = await StorageUtils.readValue('url');
//       final companyDetails = await StorageUtils.readJson('selected_company');
//       final tokenDetails = await StorageUtils.readJson('session_token');

//       if (companyDetails == null || tokenDetails == null) {
//         _showSnackBar("Company or session token not set", isError: true);
//         return;
//       }

//       final companyId = companyDetails['id'];
//       final token = tokenDetails['token']['value'];

//       _dio.options.headers['Content-Type'] = 'application/json';
//       _dio.options.headers['Authorization'] = 'Bearer $token';

//       final response = await _dio.get(
//         'http://$url/api/Login/dash_getFNYears',
//         queryParameters: {'companyid': companyId},
//       );

//       if (response.statusCode == 200) {
//         final responseData = await compute(_parseJson, response.data);
//         final List fnYear = responseData['data'];
//         await StorageUtils.writeValue(
//           'fn_year',
//           fnYear.isNotEmpty ? fnYear.last : null,
//         );
//       } else {
//         _showSnackBar(
//           "Error: fetching year ${response.statusCode}",
//           isError: true,
//         );
//       }
//     } catch (e) {
//       _showSnackBar("Exception: $e", isError: true);
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoadingSales = false;
//         });
//       }
//     }
//   }

//   Future<void> _fetchFunctionalDashboardData() async {
//     try {
//       final url = await StorageUtils.readValue('url');
//       final companyDetails = await StorageUtils.readJson('selected_company');
//       final locationDetails = await StorageUtils.readJson('selected_location');
//       final tokenDetails = await StorageUtils.readJson('session_token');

//       if (companyDetails == null ||
//           locationDetails == null ||
//           tokenDetails == null) {
//         _showSnackBar(
//           "Company, location, or session token not set",
//           isError: true,
//         );
//         return;
//       }

//       final companyId = companyDetails['id'];
//       final locationId = locationDetails['id'];
//       final token = tokenDetails['token']['value'];

//       _dio.options.headers['Content-Type'] = 'application/json';
//       _dio.options.headers['Authorization'] = 'Bearer $token';

//       final response = await _dio.get(
//         'http://$url/api/Login/dashboardPurchaseData',
//         queryParameters: {'companyid': companyId, 'siteid': locationId},
//       );

//       if (response.statusCode == 200) {
//         final responseData = await compute(_parseJson, response.data);

//         if (responseData['success'] == true ||
//             responseData['status'] == 'success') {
//           if (mounted) {
//             setState(() {
//               dashboardData = responseData['data'] ?? {};
//             });
//           }
//         } else {
//           _showSnackBar(
//             "API returned error: ${responseData['message'] ?? 'Unknown error'}",
//             isError: true,
//           );
//         }
//       } else {
//         _showSnackBar("Error: ${response.statusCode}", isError: true);
//       }
//     } catch (e) {
//       _showSnackBar("Exception: $e", isError: true);
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoadingFunctional = false;
//         });
//       }
//     }
//   }

//   Future<void> _fetchDirectorDashboardData() async {
//     try {
//       final url = await StorageUtils.readValue('url');
//       final companyDetails = await StorageUtils.readJson('selected_company');
//       final tokenDetails = await StorageUtils.readJson('session_token');

//       if (companyDetails == null || tokenDetails == null) {
//         _showSnackBar("Company or session token not set", isError: true);
//         return;
//       }

//       final companyId = companyDetails['id'];
//       final token = tokenDetails['token']['value'];

//       _dio.options.headers['Content-Type'] = 'application/json';
//       _dio.options.headers['Authorization'] = 'Bearer $token';

//       final response = await _dio.get(
//         'http://$url/api/Login/dash_FetchDashboardAmount',
//         queryParameters: {'companyid': companyId},
//       );

//       if (response.statusCode == 200) {
//         final responseData = await compute(_parseJson, response.data);

//         if (responseData['success'] == true ||
//             responseData['status'] == 'success') {
//           if (mounted) {
//             setState(() {
//               directorData = responseData;
//             });
//           }
//         } else {
//           _showSnackBar(
//             "API returned error: ${responseData['message'] ?? 'Unknown error'}",
//             isError: true,
//           );
//         }
//       } else {
//         _showSnackBar("Error: ${response.statusCode}", isError: true);
//       }
//     } catch (e) {
//       _showSnackBar("Exception: $e", isError: true);
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoadingDirector = false;
//         });
//       }
//     }
//   }

//   void _showSnackBar(String message, {bool isError = false}) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: isError ? Colors.red : Colors.green,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text(
//           'Dashboard',
//           style: TextStyle(fontWeight: FontWeight.w600),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.white,
//         surfaceTintColor: Colors.transparent,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _validateTokenAndFetchData,
//             tooltip: 'Refresh',
//           ),
//         ],
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(60),
//           child: Container(
//             color: Colors.white,
//             child: TabBar(
//               controller: _tabController,
//               isScrollable: false,
//               labelColor: Theme.of(context).primaryColor,
//               unselectedLabelColor: Colors.grey[600],
//               indicatorColor: Theme.of(context).primaryColor,
//               indicatorWeight: 3,
//               labelStyle: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14,
//               ),
//               unselectedLabelStyle: const TextStyle(
//                 fontWeight: FontWeight.w400,
//                 fontSize: 14,
//               ),
//               tabs: const [
//                 Tab(icon: Icon(Icons.business, size: 20), text: 'Functional'),
//                 Tab(icon: Icon(Icons.analytics, size: 20), text: 'Director'),
//                 Tab(
//                   icon: Icon(Icons.pie_chart, size: 20),
//                   text: 'Sales Analysis',
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         physics: const NeverScrollableScrollPhysics(),
//         children: [
//           isLoadingFunctional
//               ? const _LoadingWidget()
//               : FunctionalTabView(data: dashboardData),
//           isLoadingDirector
//               ? const _LoadingWidget()
//               : DirectoralTabView(data: directorData),
//           isLoadingSales
//               ? const _LoadingWidget()
//               : const TotalSalesRegionWisePage(),
//         ],
//       ),
//     );
//   }
// }

// class _LoadingWidget extends StatelessWidget {
//   const _LoadingWidget();

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(
//             strokeWidth: 3,
//             color: Theme.of(context).primaryColor,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Loading dashboard data...',
//             style: TextStyle(color: Colors.grey[600], fontSize: 16),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Top-level function for compute (must be top-level or static)
// Map<String, dynamic> _parseJson(dynamic data) {
//   if (data is String) {
//     return jsonDecode(data) as Map<String, dynamic>;
//   }
//   if (data is Map<String, dynamic>) {
//     return data;
//   }
//   if (data is Map) {
//     return Map<String, dynamic>.from(data);
//   }
//   throw Exception('Invalid data for JSON parsing');
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
//       return const _EmptyStateWidget(
//         icon: Icons.business,
//         title: "No Functional Data",
//         subtitle: "Dashboard data is not available at the moment",
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: () async {
//         // Trigger refresh
//       },
//       child: SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Quick Overview',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Grid of functional cards
//             GridView.count(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               crossAxisCount: 2,
//               crossAxisSpacing: 12,
//               mainAxisSpacing: 12,
//               childAspectRatio: 1.1,
//               children: [
//                 _ModernFunctionalCard(
//                   title: 'Pending Delivery',
//                   value: getValue('pendingReceiveGoodsValue'),
//                   count: getValue('pendingReceiveGoodsCount'),
//                   icon: Icons.pending_actions,
//                   color: Colors.orange,
//                   onTap:
//                       () => Navigator.pushNamed(
//                         context,
//                         '/items_pending_for_delivery',
//                       ),
//                 ),
//                 _ModernFunctionalCard(
//                   title: 'Upcoming Delivery',
//                   value: getValue('upcomingReceiveGoodsValue'),
//                   count: getValue('upcomingReceiveGoodsCount'),
//                   icon: Icons.schedule,
//                   color: Colors.blue,
//                   onTap:
//                       () => Navigator.pushNamed(
//                         context,
//                         '/upcoming_next_delivery',
//                       ),
//                 ),
//                 _ModernFunctionalCard(
//                   title: 'Overdue Delivery',
//                   value: getValue('overdueReceiveGoodsValue'),
//                   count: getValue('overdueReceiveGoodsCount'),
//                   icon: Icons.warning,
//                   color: Colors.red,
//                   onTap:
//                       () => Navigator.pushNamed(context, '/delivery_overdue'),
//                 ),
//                 _ModernFunctionalCard(
//                   title: 'Unauthorized PO',
//                   value: getValue('unauthorisedPoCount'),
//                   count: null,
//                   icon: Icons.assignment_late,
//                   color: Colors.purple,
//                   onTap:
//                       () => Navigator.pushNamed(
//                         context,
//                         '/authorize_purchase_orders',
//                       ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 32),
//             const Text(
//               'Analytics',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 16),
//             PurchaseAmountBarChartCard(purchaseAmountData: purchaseAmountData),
//             const SizedBox(height: 16),
//             SupplierAmountBarChartCard(supplierData: supplierAmountData),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _ModernFunctionalCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final String? count;
//   final IconData icon;
//   final Color color;
//   final VoidCallback? onTap;

//   const _ModernFunctionalCard({
//     required this.title,
//     required this.value,
//     this.count,
//     required this.icon,
//     required this.color,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: color.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Icon(icon, color: color, size: 20),
//                   ),
//                   if (onTap != null)
//                     Icon(
//                       Icons.arrow_forward_ios,
//                       size: 16,
//                       color: Colors.grey[400],
//                     ),
//                 ],
//               ),
//               const Spacer(),
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 value,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               if (count != null) ...[
//                 const SizedBox(height: 2),
//                 Text(
//                   'Count: $count',
//                   style: TextStyle(
//                     fontSize: 10,
//                     color: Colors.grey[500],
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _EmptyStateWidget extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;

//   const _EmptyStateWidget({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(icon, size: 48, color: Colors.grey[400]),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               subtitle,
//               style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//               textAlign: TextAlign.center,
//             ),
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
//       return const _EmptyStateWidget(
//         icon: Icons.analytics,
//         title: "No Director Data",
//         subtitle: "Dashboard data is not available at the moment",
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: () async {
//         // Trigger refresh
//       },
//       child: SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (amounts.isNotEmpty) ...[
//               const Text(
//                 'Financial Overview',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               ...amounts.map<Widget>((amt) {
//                 return _ModernAmountCard(
//                   title: amountTitles[amt["code"]] ?? amt["code"],
//                   amount: _parseDouble(amt["totalamount"]),
//                   code: amt["code"],
//                 );
//               }),
//               const SizedBox(height: 32),
//             ],
//             const Text(
//               'Order Management',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 16),
//             _ModernDirectorCard(
//               title: 'Orders',
//               amount: orderAmount,
//               count: ordertile.length,
//               icon: Icons.shopping_cart,
//               color: Colors.blue,
//               onTap:
//                   () => Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder:
//                           (_) => DetailsPage(title: "Orders", list: ordertile),
//                     ),
//                   ),
//             ),
//             const SizedBox(height: 12),
//             _ModernDirectorCard(
//               title: 'Order Dispatched',
//               amount: dispatchAmount,
//               count: dispatchtile.length,
//               icon: Icons.local_shipping,
//               color: Colors.green,
//               onTap:
//                   () => Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder:
//                           (_) => DetailsPage(
//                             title: "Order Dispatched",
//                             list: dispatchtile,
//                           ),
//                     ),
//                   ),
//             ),
//             const SizedBox(height: 12),
//             _ModernDirectorCard(
//               title: 'Overdue Dispatch',
//               amount: overduedispatchAmount,
//               count: overduedispatchtile.length,
//               icon: Icons.warning,
//               color: Colors.red,
//               onTap:
//                   () => Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder:
//                           (_) => DetailsPage(
//                             title: "Order Overdue Dispatch",
//                             list: overduedispatchtile,
//                           ),
//                     ),
//                   ),
//             ),
//             const SizedBox(height: 32),
//             const Text(
//               'Quick Actions',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 16),
//             ..._modernDirectorListTiles(context),
//           ],
//         ),
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

//   List<Widget> _modernDirectorListTiles(BuildContext context) {
//     final items = [
//       {
//         'title': "Report Chart",
//         'route': '/director_report_chart',
//         'icon': Icons.bar_chart,
//       },
//       {
//         'title': "Top 10 Customers by Sales Amount",
//         'route': '/customer_by_sales_amount',
//         'icon': Icons.people,
//       },
//       {
//         'title': "Best Selling Items By Sales Amount",
//         'route': '/best_selling_items_by_sales_amount',
//         'icon': Icons.trending_up,
//       },
//       {
//         'title': "Customers By Receivable Overdue Chart",
//         'route': '/customers_by_receivable_overdue_chart',
//         'icon': Icons.account_balance,
//       },
//       {
//         'title': "Sales Analysis",
//         'route': '/sales_analysis',
//         'icon': Icons.analytics,
//       },
//       {
//         'title': "Ageing Of Receivable Overdue",
//         'route': '/ageing_of_receivable_overdue',
//         'icon': Icons.schedule,
//       },
//       {
//         'title': "Dispatch Amount By Months",
//         'route': '/dispatch_amount_by_months',
//         'icon': Icons.timeline,
//       },
//       {
//         'title': "Key Deals - Recent Inquiries",
//         'route': '/recent_inquiries',
//         'icon': Icons.business_center,
//       },
//     ];

//     return items
//         .map(
//           (item) => _ModernListTile(
//             title: item['title'] as String,
//             route: item['route'] as String,
//             icon: item['icon'] as IconData,
//           ),
//         )
//         .toList();
//   }
// }

// class _ModernAmountCard extends StatelessWidget {
//   final String title;
//   final double amount;
//   final String code;

//   const _ModernAmountCard({
//     required this.title,
//     required this.amount,
//     required this.code,
//   });

//   Color _getColorForCode(String code) {
//     switch (code) {
//       case 'SALES':
//         return Colors.green;
//       case 'RECEIVABLE':
//         return Colors.blue;
//       case 'PAYABLE':
//         return Colors.orange;
//       case 'PAYOVRD':
//         return Colors.red;
//       case 'RECOVRD':
//         return Colors.purple;
//       default:
//         return Colors.grey;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final color = _getColorForCode(code);

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: color.withOpacity(0.2)),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   Icons.account_balance_wallet,
//                   color: color,
//                   size: 24,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey[600],
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       intl.NumberFormat.currency(
//                         locale: 'en_IN',
//                         symbol: '₹',
//                         decimalDigits: 0,
//                       ).format(amount),
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _ModernDirectorCard extends StatelessWidget {
//   final String title;
//   final double amount;
//   final int count;
//   final IconData icon;
//   final Color color;
//   final VoidCallback onTap;

//   const _ModernDirectorCard({
//     required this.title,
//     required this.amount,
//     required this.count,
//     required this.icon,
//     required this.color,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(icon, color: color, size: 24),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey[600],
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       intl.NumberFormat.currency(
//                         locale: 'en_IN',
//                         symbol: '₹',
//                         decimalDigits: 0,
//                       ).format(amount),
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       'Count: $count',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey[500],
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _ModernListTile extends StatelessWidget {
//   final String title;
//   final String route;
//   final IconData icon;

//   const _ModernListTile({
//     required this.title,
//     required this.route,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       child: Card(
//         elevation: 1,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         child: ListTile(
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 4,
//           ),
//           leading: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Theme.of(context).primaryColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Icon(icon, size: 20, color: Theme.of(context).primaryColor),
//           ),
//           title: Text(
//             title,
//             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//           ),
//           trailing: Icon(
//             Icons.arrow_forward_ios,
//             size: 14,
//             color: Colors.grey[400],
//           ),
//           onTap: () => Navigator.pushNamed(context, route),
//         ),
//       ),
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
//     if (value is DateTime) {
//       return intl.DateFormat("dd/MM/yyyy").format(value);
//     }
//     if (value is String) {
//       try {
//         final dt = DateTime.parse(value);
//         if (dt.year > 1900 && dt.year < 2100) {
//           return intl.DateFormat("dd/MM/yyyy").format(dt);
//         }
//       } catch (_) {}
//     }
//     if (key.toLowerCase().contains('amount') ||
//         key.toLowerCase().contains('total')) {
//       if (value is num) {
//         return intl.NumberFormat.currency(
//           locale: 'en_IN',
//           symbol: "₹",
//           decimalDigits: 0,
//         ).format(value);
//       }
//       if (value is String) {
//         final numValue = num.tryParse(value.replaceAll(',', ''));
//         if (numValue != null) {
//           return intl.NumberFormat.currency(
//             locale: 'en_IN',
//             symbol: "₹",
//             decimalDigits: 0,
//           ).format(numValue);
//         }
//       }
//     }
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
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: Text(
//           widget.title,
//           style: const TextStyle(fontWeight: FontWeight.w600),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.white,
//         surfaceTintColor: Colors.transparent,
//       ),
//       body: Column(
//         children: [
//           Container(
//             color: Colors.white,
//             padding: const EdgeInsets.all(16),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: "Search records...",
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[100],
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//               ),
//               onChanged: (val) => setState(() => search = val),
//             ),
//           ),
//           Expanded(
//             child:
//                 filteredList.isEmpty
//                     ? const _EmptyStateWidget(
//                       icon: Icons.search_off,
//                       title: "No Records Found",
//                       subtitle: "Try adjusting your search criteria",
//                     )
//                     : ListView.builder(
//                       padding: const EdgeInsets.all(16),
//                       itemCount: filteredList.length,
//                       itemBuilder: (context, idx) {
//                         final Map<String, dynamic> item =
//                             filteredList[idx] as Map<String, dynamic>;
//                         final title =
//                             item["customername"] ??
//                             item["itemname"] ??
//                             "Record #${idx + 1}";
//                         final amount = item["amount"];

//                         return Card(
//                           margin: const EdgeInsets.only(bottom: 12),
//                           elevation: 2,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: ExpansionTile(
//                             tilePadding: const EdgeInsets.all(16),
//                             childrenPadding: const EdgeInsets.all(16),
//                             title: Text(
//                               title.toString(),
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 16,
//                               ),
//                             ),
//                             subtitle:
//                                 amount != null
//                                     ? Padding(
//                                       padding: const EdgeInsets.only(top: 4),
//                                       child: Text(
//                                         "Amount: ${formatValue('amount', amount)}",
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.w500,
//                                           color: Colors.grey[600],
//                                         ),
//                                       ),
//                                     )
//                                     : null,
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.all(12),
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey[50],
//                                   borderRadius: BorderRadius.circular(8),
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
//                                                     vertical: 6,
//                                                   ),
//                                               child: Text(
//                                                 "${formatKey(e.key)}:",
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.w500,
//                                                   color: Colors.grey[700],
//                                                   fontSize: 13,
//                                                 ),
//                                               ),
//                                             ),
//                                             Padding(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                     vertical: 6,
//                                                     horizontal: 12,
//                                                   ),
//                                               child: SelectableText(
//                                                 formatValue(e.key, e.value),
//                                                 style: const TextStyle(
//                                                   fontSize: 13,
//                                                   fontWeight: FontWeight.w400,
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
