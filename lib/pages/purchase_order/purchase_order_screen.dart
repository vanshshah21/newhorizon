// import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
// import 'package:nhapp/utils/storage_utils.dart';
// import 'package:url_launcher/url_launcher.dart';

// // --- Models ---

// class ItemDetail {
//   final String itemCode;
//   final String itemDesc;
//   final double qty;
//   final String uom;
//   final double rate;
//   final double amount;

//   const ItemDetail({
//     required this.itemCode,
//     required this.itemDesc,
//     required this.qty,
//     required this.uom,
//     required this.rate,
//     required this.amount,
//   });

//   factory ItemDetail.fromJson(Map<String, dynamic> json) {
//     return ItemDetail(
//       itemCode: json['itemCode'] ?? '',
//       itemDesc: json['itemDesc'] ?? '',
//       qty: (json['qty'] ?? 0.0).toDouble(),
//       uom: json['uom'] ?? '',
//       rate: (json['rate'] ?? 0.0).toDouble(),
//       amount: (json['amount'] ?? 0.0).toDouble(),
//     );
//   }
// }

// class PurchaseOrder {
//   final String nmbr;
//   final String vendor;
//   final String mobile;
//   final List<ItemDetail> itemDetail;

//   const PurchaseOrder({
//     required this.nmbr,
//     required this.vendor,
//     required this.mobile,
//     required this.itemDetail,
//   });

//   factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
//     return PurchaseOrder(
//       nmbr: json['nmbr'] ?? '',
//       vendor: json['vendor'] ?? '',
//       mobile: json['mobile'] ?? '',
//       itemDetail:
//           (json['itemDetail'] as List<dynamic>? ?? [])
//               .map((e) => ItemDetail.fromJson(e))
//               .toList(),
//     );
//   }
// }

// class PurchaseOrderPage {
//   final List<PurchaseOrder> orders;
//   final int totalRows;

//   PurchaseOrderPage({required this.orders, required this.totalRows});
// }

// // --- Utility ---

// Future<void> _launchCall(String phoneNumber) async {
//   if (phoneNumber.isEmpty) return;
//   final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
//   if (await canLaunchUrl(launchUri)) {
//     await launchUrl(launchUri);
//   }
// }

// // --- Main App ---

// class PurchaseOrdersScreen extends StatefulWidget {
//   const PurchaseOrdersScreen({super.key});

//   @override
//   State<PurchaseOrdersScreen> createState() => _PurchaseOrdersScreenState();
// }

// class _PurchaseOrdersScreenState extends State<PurchaseOrdersScreen>
//     with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
//   late final TabController _tabController;
//   late final TextEditingController _searchTextControllerTab1;
//   late final TextEditingController _searchTextControllerTab2;
//   final ValueNotifier<String> _searchTextTab1 = ValueNotifier('');
//   final ValueNotifier<String> _searchTextTab2 = ValueNotifier('');
//   static const int _pageSize = 100;

//   @override
//   bool get wantKeepAlive => true;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _searchTextControllerTab1 = TextEditingController();
//     _searchTextControllerTab2 = TextEditingController();
//     _searchTextControllerTab1.addListener(() {
//       _searchTextTab1.value = _searchTextControllerTab1.text;
//     });
//     _searchTextControllerTab2.addListener(() {
//       _searchTextTab2.value = _searchTextControllerTab2.text;
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _searchTextControllerTab1.dispose();
//     _searchTextControllerTab2.dispose();
//     _searchTextTab1.dispose();
//     _searchTextTab2.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context); // for AutomaticKeepAliveClientMixin
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Purchase Order'),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [Tab(text: 'Regular'), Tab(text: 'Capital')],
//           onTap: (index) {
//             if (index == 0) {
//               _searchTextControllerTab2.clear();
//             } else {
//               _searchTextControllerTab1.clear();
//             }
//           },
//         ),
//       ),
//       body: TabBarView(
//         physics: const NeverScrollableScrollPhysics(),
//         controller: _tabController,
//         children: [
//           _TabContent(
//             isRegular: true,
//             searchTextNotifier: _searchTextTab1,
//             searchTextController: _searchTextControllerTab1,
//             pageSize: _pageSize,
//           ),
//           _TabContent(
//             isRegular: false,
//             searchTextNotifier: _searchTextTab2,
//             searchTextController: _searchTextControllerTab2,
//             pageSize: _pageSize,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _TabContent extends StatefulWidget {
//   final bool isRegular;
//   final ValueNotifier<String> searchTextNotifier;
//   final TextEditingController searchTextController;
//   final int pageSize;

//   const _TabContent({
//     required this.isRegular,
//     required this.searchTextNotifier,
//     required this.searchTextController,
//     required this.pageSize,
//   });

//   @override
//   State<_TabContent> createState() => _TabContentState();
// }

// class _TabContentState extends State<_TabContent>
//     with AutomaticKeepAliveClientMixin {
//   late final PagingController<int, PurchaseOrder> _pagingController =
//       PagingController<int, PurchaseOrder>(
//         getNextPageKey: (state) => (state.keys?.last ?? 0) + 1,
//         fetchPage: (pageKey) async {
//           final searchValue = widget.searchTextNotifier.value;
//           final page = await fetchPOs(
//             isRegular: widget.isRegular,
//             pageNumber: pageKey,
//             pageSize: widget.pageSize,
//             searchValue: searchValue.isEmpty ? null : searchValue,
//           );
//           final isLastPage = (pageKey * widget.pageSize) >= page.totalRows;
//           return isLastPage ? page.orders : page.orders;
//         },
//       );

//   @override
//   bool get wantKeepAlive => true;

//   @override
//   void initState() {
//     super.initState();
//     widget.searchTextNotifier.addListener(_onSearchChanged);
//   }

//   @override
//   void dispose() {
//     _pagingController.dispose();
//     widget.searchTextNotifier.removeListener(_onSearchChanged);
//     super.dispose();
//   }

//   void _onSearchChanged() {
//     _pagingController.refresh();
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return Column(
//       children: [
//         const SizedBox(height: 8),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8),
//           child: TextField(
//             controller: widget.searchTextController,
//             decoration: InputDecoration(
//               hintText: 'Search',
//               prefixIcon: const Icon(Icons.search),
//               suffixIcon: ValueListenableBuilder<String>(
//                 valueListenable: widget.searchTextNotifier,
//                 builder: (context, value, child) {
//                   if (value.isEmpty) return const SizedBox.shrink();
//                   return IconButton(
//                     icon: const Icon(Icons.clear),
//                     onPressed: () => widget.searchTextController.clear(),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Expanded(
//           child: PagingListener<int, PurchaseOrder>(
//             controller: _pagingController,
//             builder:
//                 (
//                   context,
//                   state,
//                   fetchNextPage,
//                 ) => PagedListView<int, PurchaseOrder>(
//                   state: state,
//                   fetchNextPage: fetchNextPage,
//                   builderDelegate: PagedChildBuilderDelegate<PurchaseOrder>(
//                     invisibleItemsThreshold: (widget.pageSize * 0.3).round(),
//                     itemBuilder:
//                         (context, po, index) => _PurchaseOrderTile(po: po),
//                     noItemsFoundIndicatorBuilder:
//                         (context) =>
//                             const Center(child: Text('No record found.')),
//                     firstPageProgressIndicatorBuilder:
//                         (context) =>
//                             const Center(child: CircularProgressIndicator()),
//                     newPageProgressIndicatorBuilder:
//                         (context) => Center(
//                           child: Container(
//                             margin: EdgeInsets.all(18),
//                             child: CircularProgressIndicator(),
//                           ),
//                         ),
//                     firstPageErrorIndicatorBuilder:
//                         (context) => Center(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               const Text('Failed to load data'),
//                               ElevatedButton(
//                                 onPressed: () => _pagingController.refresh(),
//                                 child: const Text("Retry"),
//                               ),
//                             ],
//                           ),
//                         ),
//                     newPageErrorIndicatorBuilder:
//                         (context) => Center(
//                           child: ElevatedButton(
//                             onPressed: () => _pagingController.refresh(),
//                             child: const Text("Retry"),
//                           ),
//                         ),
//                   ),
//                 ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _PurchaseOrderTile extends StatelessWidget {
//   final PurchaseOrder po;
//   const _PurchaseOrderTile({required this.po});

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: Text(po.nmbr),
//       subtitle: Text(po.vendor),
//       trailing:
//           po.mobile.isNotEmpty
//               ? IconButton(
//                 icon: const Icon(Icons.call),
//                 onPressed: () => _launchCall(po.mobile),
//               )
//               : null,
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => PurchaseOrderDetailsScreen(po: po)),
//         );
//       },
//     );
//   }
// }

// class PurchaseOrderDetailsScreen extends StatelessWidget {
//   final PurchaseOrder po;

//   const PurchaseOrderDetailsScreen({super.key, required this.po});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('PO ${po.nmbr} Details')),
//       body: ListView.separated(
//         padding: const EdgeInsets.all(16),
//         itemCount: po.itemDetail.length,
//         separatorBuilder: (_, __) => const Divider(),
//         itemBuilder: (context, index) {
//           final item = po.itemDetail[index];
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Item Code: ${item.itemCode}',
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//               Text('Description: ${item.itemDesc}'),
//               Text('Qty: ${item.qty} ${item.uom}'),
//               Text('Rate: ${item.rate}'),
//               Text('Amount: ${item.amount}'),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// // --- API with Pagination ---

// Future<PurchaseOrderPage> fetchPOs({
//   required bool isRegular,
//   required int pageNumber,
//   required int pageSize,
//   String? searchValue,
// }) async {
//   final url = await StorageUtils.readValue('url');
//   final companyDetails = await StorageUtils.readJson('selected_company');
//   if (companyDetails == null) throw Exception("Company not set");

//   final locationDetails = await StorageUtils.readJson('selected_location');
//   if (locationDetails == null) throw Exception("Location not set");

//   final tokenDetails = await StorageUtils.readJson('session_token');
//   if (tokenDetails == null) throw Exception("Session token not found");

//   final companyId = companyDetails['id'];
//   final locationId = locationDetails['id'];
//   final token = tokenDetails['token']['value'];
//   final userId = tokenDetails['user']['id'];

//   final body = {
//     "pageNumber": pageNumber,
//     "pageSize": pageSize,
//     "sortField": "",
//     "sortDirection": "",
//     "searchValue": searchValue,
//     "potype": isRegular ? "'R'" : "'C'",
//     "usrLvl": 0,
//     "usrSubLvl": 0,
//     "mulLvlAuthRed": false,
//     "valLimit": 0,
//     "docType": "PR",
//     "docSubType": isRegular ? "RP" : "CP",
//     "companyId": companyId,
//     "userId": userId,
//   };

//   final dio = Dio();
//   dio.options.headers['Content-Type'] = 'application/json';
//   dio.options.headers['Accept'] = 'application/json';
//   dio.options.headers['companyid'] = companyId.toString();
//   dio.options.headers['Authorization'] = 'Bearer $token';

//   final response = await dio.post(
//     'http://$url/api/Podata/${isRegular ? "PurchasePOList_Regular" : "PurchasePOList_Capital"}',
//     data: jsonEncode(body),
//     queryParameters: {
//       "locIds": locationId.toString(),
//       "companyId": companyId,
//       "locationId": locationId,
//     },
//   );

//   if (response.statusCode == 200) {
//     final dynamic data =
//         response.data is String ? jsonDecode(response.data) : response.data;
//     final List<dynamic> jsonList = data['data'] ?? [];
//     final int totalRows = data['totalRows'] ?? 0;
//     print(data);
//     return PurchaseOrderPage(
//       orders:
//           jsonList
//               .map<PurchaseOrder>(
//                 (json) => PurchaseOrder.fromJson(json as Map<String, dynamic>),
//               )
//               .toList(),
//       totalRows: totalRows,
//     );
//   } else {
//     throw Exception('Failed to load purchase orders');
//   }
// }

// import 'dart:convert';
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
// import 'package:nhapp/utils/storage_utils.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:path_provider/path_provider.dart';

// // --- Models ---

// class ItemDetail {
//   final String itemCode;
//   final String itemDesc;
//   final double qty;
//   final String uom;
//   final double rate;
//   final double amount;

//   const ItemDetail({
//     required this.itemCode,
//     required this.itemDesc,
//     required this.qty,
//     required this.uom,
//     required this.rate,
//     required this.amount,
//   });

//   factory ItemDetail.fromJson(Map<String, dynamic> json) {
//     return ItemDetail(
//       itemCode: json['itemCode'] ?? '',
//       itemDesc: json['itemDesc'] ?? '',
//       qty: (json['qty'] ?? 0.0).toDouble(),
//       uom: json['uom'] ?? '',
//       rate: (json['rate'] ?? 0.0).toDouble(),
//       amount: (json['amount'] ?? 0.0).toDouble(),
//     );
//   }
// }

// class PurchaseOrder {
//   final String nmbr;
//   final String vendor;
//   final String mobile;
//   final List<ItemDetail> itemDetail;

//   const PurchaseOrder({
//     required this.nmbr,
//     required this.vendor,
//     required this.mobile,
//     required this.itemDetail,
//   });

//   factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
//     return PurchaseOrder(
//       nmbr: json['nmbr'] ?? '',
//       vendor: json['vendor'] ?? '',
//       mobile: json['mobile'] ?? '',
//       itemDetail:
//           (json['itemDetail'] as List<dynamic>? ?? [])
//               .map((e) => ItemDetail.fromJson(e))
//               .toList(),
//     );
//   }
// }

// class PurchaseOrderWithJson {
//   final PurchaseOrder po;
//   final Map<String, dynamic> json;
//   PurchaseOrderWithJson(this.po, this.json);
// }

// class PurchaseOrderPage {
//   final List<PurchaseOrderWithJson> orders;
//   final int totalRows;

//   PurchaseOrderPage({required this.orders, required this.totalRows});
// }

// // --- Utility ---

// Future<void> _launchCall(String phoneNumber) async {
//   if (phoneNumber.isEmpty) return;
//   final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
//   if (await canLaunchUrl(launchUri)) {
//     await launchUrl(launchUri);
//   }
// }

// // --- Main App ---

// class PurchaseOrdersScreen extends StatefulWidget {
//   const PurchaseOrdersScreen({super.key});

//   @override
//   State<PurchaseOrdersScreen> createState() => _PurchaseOrdersScreenState();
// }

// class _PurchaseOrdersScreenState extends State<PurchaseOrdersScreen>
//     with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
//   late final TabController _tabController;
//   late final TextEditingController _searchTextControllerTab1;
//   late final TextEditingController _searchTextControllerTab2;
//   final ValueNotifier<String> _searchTextTab1 = ValueNotifier('');
//   final ValueNotifier<String> _searchTextTab2 = ValueNotifier('');
//   static const int _pageSize = 100;

//   @override
//   bool get wantKeepAlive => true;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _searchTextControllerTab1 = TextEditingController();
//     _searchTextControllerTab2 = TextEditingController();
//     _searchTextControllerTab1.addListener(() {
//       _searchTextTab1.value = _searchTextControllerTab1.text;
//     });
//     _searchTextControllerTab2.addListener(() {
//       _searchTextTab2.value = _searchTextControllerTab2.text;
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _searchTextControllerTab1.dispose();
//     _searchTextControllerTab2.dispose();
//     _searchTextTab1.dispose();
//     _searchTextTab2.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context); // for AutomaticKeepAliveClientMixin
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Purchase Order'),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [Tab(text: 'Regular'), Tab(text: 'Capital')],
//           onTap: (index) {
//             if (index == 0) {
//               _searchTextControllerTab2.clear();
//             } else {
//               _searchTextControllerTab1.clear();
//             }
//           },
//         ),
//       ),
//       body: TabBarView(
//         physics: const NeverScrollableScrollPhysics(),
//         controller: _tabController,
//         children: [
//           _TabContent(
//             isRegular: true,
//             searchTextNotifier: _searchTextTab1,
//             searchTextController: _searchTextControllerTab1,
//             pageSize: _pageSize,
//           ),
//           _TabContent(
//             isRegular: false,
//             searchTextNotifier: _searchTextTab2,
//             searchTextController: _searchTextControllerTab2,
//             pageSize: _pageSize,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _TabContent extends StatefulWidget {
//   final bool isRegular;
//   final ValueNotifier<String> searchTextNotifier;
//   final TextEditingController searchTextController;
//   final int pageSize;

//   const _TabContent({
//     required this.isRegular,
//     required this.searchTextNotifier,
//     required this.searchTextController,
//     required this.pageSize,
//   });

//   @override
//   State<_TabContent> createState() => _TabContentState();
// }

// class _TabContentState extends State<_TabContent>
//     with AutomaticKeepAliveClientMixin {
//   late final PagingController<int, PurchaseOrderWithJson> _pagingController =
//       PagingController<int, PurchaseOrderWithJson>(
//         getNextPageKey: (state) => (state.keys?.last ?? 0) + 1,
//         fetchPage: (pageKey) async {
//           final searchValue = widget.searchTextNotifier.value;
//           final page = await fetchPOs(
//             isRegular: widget.isRegular,
//             pageNumber: pageKey,
//             pageSize: widget.pageSize,
//             searchValue: searchValue.isEmpty ? null : searchValue,
//           );
//           final isLastPage = (pageKey * widget.pageSize) >= page.totalRows;
//           return isLastPage ? page.orders : page.orders;
//         },
//       );

//   @override
//   bool get wantKeepAlive => true;

//   @override
//   void initState() {
//     super.initState();
//     widget.searchTextNotifier.addListener(_onSearchChanged);
//   }

//   @override
//   void dispose() {
//     _pagingController.dispose();
//     widget.searchTextNotifier.removeListener(_onSearchChanged);
//     super.dispose();
//   }

//   void _onSearchChanged() {
//     _pagingController.refresh();
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return Column(
//       children: [
//         const SizedBox(height: 8),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8),
//           child: TextField(
//             controller: widget.searchTextController,
//             decoration: InputDecoration(
//               hintText: 'Search',
//               prefixIcon: const Icon(Icons.search),
//               suffixIcon: ValueListenableBuilder<String>(
//                 valueListenable: widget.searchTextNotifier,
//                 builder: (context, value, child) {
//                   if (value.isEmpty) return const SizedBox.shrink();
//                   return IconButton(
//                     icon: const Icon(Icons.clear),
//                     onPressed: () => widget.searchTextController.clear(),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Expanded(
//           child: PagingListener<int, PurchaseOrderWithJson>(
//             controller: _pagingController,
//             builder:
//                 (
//                   context,
//                   state,
//                   fetchNextPage,
//                 ) => PagedListView<int, PurchaseOrderWithJson>(
//                   state: state,
//                   fetchNextPage: fetchNextPage,
//                   builderDelegate: PagedChildBuilderDelegate<
//                     PurchaseOrderWithJson
//                   >(
//                     invisibleItemsThreshold: (widget.pageSize * 0.3).round(),
//                     itemBuilder:
//                         (context, poWithJson, index) => _PurchaseOrderTile(
//                           po: poWithJson.po,
//                           poJson: poWithJson.json,
//                         ),
//                     noItemsFoundIndicatorBuilder:
//                         (context) =>
//                             const Center(child: Text('No record found.')),
//                     firstPageProgressIndicatorBuilder:
//                         (context) =>
//                             const Center(child: CircularProgressIndicator()),
//                     newPageProgressIndicatorBuilder:
//                         (context) =>
//                             const Center(child: CircularProgressIndicator()),
//                     firstPageErrorIndicatorBuilder:
//                         (context) => Center(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               const Text('Failed to load data'),
//                               ElevatedButton(
//                                 onPressed: () => _pagingController.refresh(),
//                                 child: const Text("Retry"),
//                               ),
//                             ],
//                           ),
//                         ),
//                     newPageErrorIndicatorBuilder:
//                         (context) => Center(
//                           child: ElevatedButton(
//                             onPressed: () => _pagingController.refresh(),
//                             child: const Text("Retry"),
//                           ),
//                         ),
//                   ),
//                 ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _PurchaseOrderTile extends StatelessWidget {
//   final PurchaseOrder po;
//   final Map<String, dynamic> poJson; // The full JSON for this PO

//   const _PurchaseOrderTile({required this.po, required this.poJson});

//   @override
//   Widget build(BuildContext context) {
//     return Slidable(
//       key: ValueKey(po.nmbr),
//       endActionPane: ActionPane(
//         motion: const DrawerMotion(),
//         children: [
//           SlidableAction(
//             onPressed: (_) async {
//               final pdfUrl = await _fetchPdfUrl(context, poJson);
//               if (pdfUrl != null) {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => PdfViewScreen(pdfUrl: pdfUrl),
//                   ),
//                 );
//               }
//             },
//             backgroundColor: Colors.blue,
//             foregroundColor: Colors.white,
//             icon: Icons.picture_as_pdf,
//             label: 'View PDF',
//           ),
//         ],
//       ),
//       child: ListTile(
//         title: Text(po.nmbr),
//         subtitle: Text(po.vendor),
//         trailing:
//             po.mobile.isNotEmpty
//                 ? IconButton(
//                   icon: const Icon(Icons.call),
//                   onPressed: () => _launchCall(po.mobile),
//                 )
//                 : null,
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => PurchaseOrderDetailsScreen(po: po),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// Future<String?> _fetchPdfUrl(
//   BuildContext context,
//   Map<String, dynamic> poJson,
// ) async {
//   try {
//     final url = await StorageUtils.readValue('url');
//     print("URL: $url");
//     final tokenDetails = await StorageUtils.readJson('session_token');
//     final token = tokenDetails['token']['value'];
//     final companyData = await StorageUtils.readJson('selected_company');
//     final locationData = await StorageUtils.readJson('selected_location');

//     final body = {
//       "POData": [poJson],
//       "companyData": companyData,
//       "locationData": locationData,
//       "typeCopyControl": "1",
//       "strDomCurrency": "INR",
//       "FormID": "01109",
//       "typeSelection": "P",
//       "GSTDateTimeTemp": "01/07/2017",
//       "blnpocomparision_fabcon": true,
//       "blnpoitemwisestock_fabcon": true,
//       "strtctype": "GEN",
//       "printtype": "pdf",
//     };
//     print("PDF URL Body: $body");
//     final dio = Dio();
//     dio.options.headers['Content-Type'] = 'application/json';
//     dio.options.headers['Accept'] = 'application/json';
//     dio.options.headers['companyid'] = companyData['id'].toString();
//     dio.options.headers['Authorization'] = 'Bearer $token';

//     final response = await dio.post(
//       'http://$url/api/Podata/poGetPrint_Regular',
//       data: jsonEncode(body),
//     );
//     if (response.statusCode == 200) {
//       final data =
//           response.data is String ? jsonDecode(response.data) : response.data;
//       final pdfUrl = data['data'];
//       if (pdfUrl != null && pdfUrl.toString().isNotEmpty) {
//         print("PDF URL: $pdfUrl");
//         return pdfUrl.toString();
//       }
//     }
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text('Failed to fetch PDF URL')));
//     return null;
//   } catch (e) {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text('Error: $e')));
//     return null;
//   }
// }

// class PdfViewScreen extends StatefulWidget {
//   final String pdfUrl;
//   const PdfViewScreen({super.key, required this.pdfUrl});

//   @override
//   State<PdfViewScreen> createState() => _PdfViewScreenState();
// }

// class _PdfViewScreenState extends State<PdfViewScreen> {
//   String? localPath;

//   @override
//   void initState() {
//     super.initState();
//     // _downloadPdf();
//   }

//   // Future<void> _downloadPdf() async {
//   //   try {
//   //     final dir = await getTemporaryDirectory();
//   //     final filePath = '${dir.path}/temp.pdf';
//   //     final response = await Dio().get<List<int>>(
//   //       widget.pdfUrl,
//   //       options: Options(responseType: ResponseType.bytes),
//   //     );
//   //     final file = File(filePath);
//   //     await file.writeAsBytes(response.data!);
//   //     setState(() {
//   //       localPath = filePath;
//   //     });
//   //   } catch (e) {
//   //     print(e);
//   //     ScaffoldMessenger.of(
//   //       context,
//   //     ).showSnackBar(SnackBar(content: Text('Failed to load PDF: $e')));
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     if (localPath == null) {
//       return Scaffold(
//         appBar: AppBar(title: Text('PDF')),
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//     return Scaffold(
//       appBar: AppBar(title: const Text('PDF')),
//       body: PDFView(filePath: "http://10.0.2.2:5000/MOB_NH_PRINT/poprint.pdf"),
//     );
//   }
// }

// class PurchaseOrderDetailsScreen extends StatelessWidget {
//   final PurchaseOrder po;

//   const PurchaseOrderDetailsScreen({super.key, required this.po});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('PO ${po.nmbr} Details')),
//       body: ListView.separated(
//         padding: const EdgeInsets.all(16),
//         itemCount: po.itemDetail.length,
//         separatorBuilder: (_, __) => const Divider(),
//         itemBuilder: (context, index) {
//           final item = po.itemDetail[index];
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Item Code: ${item.itemCode}',
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//               Text('Description: ${item.itemDesc}'),
//               Text('Qty: ${item.qty} ${item.uom}'),
//               Text('Rate: ${item.rate}'),
//               Text('Amount: ${item.amount}'),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// // --- API with Pagination ---

// Future<PurchaseOrderPage> fetchPOs({
//   required bool isRegular,
//   required int pageNumber,
//   required int pageSize,
//   String? searchValue,
// }) async {
//   final url = await StorageUtils.readValue('url');
//   final companyDetails = await StorageUtils.readJson('selected_company');
//   if (companyDetails == null) throw Exception("Company not set");

//   final locationDetails = await StorageUtils.readJson('selected_location');
//   if (locationDetails == null) throw Exception("Location not set");

//   final tokenDetails = await StorageUtils.readJson('session_token');
//   if (tokenDetails == null) throw Exception("Session token not found");

//   final companyId = companyDetails['id'];
//   final locationId = locationDetails['id'];
//   final token = tokenDetails['token']['value'];
//   final userId = tokenDetails['user']['id'];

//   final body = {
//     "pageNumber": pageNumber,
//     "pageSize": pageSize,
//     "sortField": "",
//     "sortDirection": "",
//     "searchValue": searchValue,
//     "potype": isRegular ? "'R'" : "'C'",
//     "usrLvl": 0,
//     "usrSubLvl": 0,
//     "mulLvlAuthRed": false,
//     "valLimit": 0,
//     "docType": "PR",
//     "docSubType": isRegular ? "RP" : "CP",
//     "companyId": companyId,
//     "userId": userId,
//   };

//   final dio = Dio();
//   dio.options.headers['Content-Type'] = 'application/json';
//   dio.options.headers['Accept'] = 'application/json';
//   dio.options.headers['companyid'] = companyId.toString();
//   dio.options.headers['Authorization'] = 'Bearer $token';

//   final response = await dio.post(
//     'http://$url/api/Podata/${isRegular ? "PurchasePOList_Regular" : "PurchasePOList_Capital"}',
//     data: jsonEncode(body),
//     queryParameters: {
//       "locIds": locationId.toString(),
//       "companyId": companyId,
//       "locationId": locationId,
//     },
//   );

//   if (response.statusCode == 200) {
//     final dynamic data =
//         response.data is String ? jsonDecode(response.data) : response.data;
//     final List<dynamic> jsonList = data['data'] ?? [];
//     final int totalRows = data['totalRows'] ?? 0;
//     final orders =
//         jsonList
//             .map<PurchaseOrderWithJson>(
//               (json) => PurchaseOrderWithJson(
//                 PurchaseOrder.fromJson(json as Map<String, dynamic>),
//                 json as Map<String, dynamic>,
//               ),
//             )
//             .toList();
//     return PurchaseOrderPage(orders: orders, totalRows: totalRows);
//   } else {
//     throw Exception('Failed to load purchase orders');
//   }
// }

// pages/po_list_page.dart
// import 'package:flutter/material.dart';
// import 'package:nhapp/pages/purchase_order/model/po_data.dart';
// import 'package:nhapp/pages/purchase_order/pages/pdf_viewer_page.dart';
// import 'package:nhapp/pages/purchase_order/services/po_service.dart';
// import 'package:nhapp/pages/purchase_order/widgets/po_infinite_list_tab.dart';
// import 'package:url_launcher/url_launcher.dart';

// class POListPage extends StatelessWidget {
//   const POListPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final service = POService();

//     Future<void> handlePdfTap(
//       BuildContext context,
//       POData po,
//       bool isRegular,
//     ) async {
//       try {
//         final pdfUrl = await service.fetchPOPdfUrl(po, isRegular);
//         if (pdfUrl.isNotEmpty) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => PDFViewerPage(pdfUrl: pdfUrl)),
//           );
//         } else {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(const SnackBar(content: Text('PDF not found')));
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error: $e')));
//       }
//     }

//     Future<void> handleCallTap(BuildContext context, POData po) async {
//       if (po.mobile.isNotEmpty) {
//         final uri = Uri.parse('tel:${po.mobile}');
//         if (await canLaunchUrl(uri)) {
//           await launchUrl(uri);
//         } else {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(const SnackBar(content: Text('Cannot launch dialer')));
//         }
//       }
//     }

//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Purchase Orders'),
//           bottom: const TabBar(
//             tabs: [Tab(text: 'Regular'), Tab(text: 'Capital')],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             POInfiniteListTab(
//               isRegular: true,
//               service: service,
//               onPdfTap: (po) => handlePdfTap(context, po, true),
//               onCallTap: (po) => handleCallTap(context, po),
//             ),
//             POInfiniteListTab(
//               isRegular: false,
//               service: service,
//               onPdfTap: (po) => handlePdfTap(context, po, false),
//               onCallTap: (po) => handleCallTap(context, po),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:nhapp/pages/purchase_order/model/po_data.dart';
import 'package:nhapp/pages/purchase_order/pages/pdf_viewer_page.dart';
import 'package:nhapp/pages/purchase_order/services/po_service.dart';
import 'package:nhapp/pages/purchase_order/widgets/po_infinite_list_tab.dart';
import 'package:url_launcher/url_launcher.dart';

class POListPage extends StatefulWidget {
  const POListPage({super.key});

  @override
  State<POListPage> createState() => POListPageState();
}

class POListPageState extends State<POListPage> {
  final POService service = POService();

  Future<void> handlePdfTap(POData po, bool isRegular) async {
    try {
      final pdfUrl = await service.fetchPOPdfUrl(po, isRegular);
      if (!mounted) return;
      if (pdfUrl.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PDFViewerPage(pdfUrl: pdfUrl)),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('PDF not found')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> handleCallTap(POData po) async {
    if (po.mobile.isNotEmpty) {
      final uri = Uri.parse('tel:${po.mobile}');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cannot launch dialer')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Purchase Orders'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Regular'), Tab(text: 'Capital')],
          ),
        ),
        body: TabBarView(
          children: [
            POInfiniteListTab(
              isRegular: true,
              service: service,
              onPdfTap: (po) => handlePdfTap(po, true),
              onCallTap: handleCallTap,
            ),
            POInfiniteListTab(
              isRegular: false,
              service: service,
              onPdfTap: (po) => handlePdfTap(po, false),
              onCallTap: handleCallTap,
            ),
          ],
        ),
      ),
    );
  }
}
