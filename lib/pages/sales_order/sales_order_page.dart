// import 'package:flutter/material.dart';
// import 'package:nhapp/pages/purchase_order/pages/pdf_viewer_page.dart';
// import 'package:nhapp/pages/sales_order/models/sales_order.dart';
// import 'package:nhapp/pages/sales_order/service/sales_order_service.dart';
// import 'package:nhapp/pages/sales_order/widgets/sales_order_infinite_list_tab.dart';

// class SalesOrderListPage extends StatelessWidget {
//   const SalesOrderListPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final service = SalesOrderService();

//     Future<void> handlePdfTap(BuildContext context, SalesOrder so) async {
//       try {
//         final pdfUrl = await service.fetchSalesOrderPdfUrl(so);
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

//     return Scaffold(
//       appBar: AppBar(title: const Text('Sales Orders')),
//       body: SalesOrderInfiniteListTab(
//         service: service,
//         onPdfTap: (so) => handlePdfTap(context, so),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:nhapp/pages/purchase_order/pages/pdf_viewer_page.dart';
// import 'package:nhapp/pages/sales_order/models/sales_order.dart';
// import 'package:nhapp/pages/sales_order/pages/so_pdf_page.dart';
// import 'package:nhapp/pages/sales_order/service/sales_order_service.dart';
// import 'package:nhapp/pages/sales_order/widgets/sales_order_infinite_list_tab.dart';

// class SalesOrderListPage extends StatefulWidget {
//   const SalesOrderListPage({super.key});

//   @override
//   State<SalesOrderListPage> createState() => SalesOrderListPageState();
// }

// class SalesOrderListPageState extends State<SalesOrderListPage> {
//   final service = SalesOrderService();

//   Future<void> handlePdfTap(SalesOrder so) async {
//     if (!mounted) return;
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => SalesOrderPdfLoaderPage(salesOrder: so),
//       ),
//     );
//   }

//   Future<void> _navigateToAddSalesOrder() async {
//     final result = await Navigator.pushNamed(context, '/add_sales_order');

//     // If sales order was successfully created, refresh the list
//     if (result == true && _listKey.currentState != null) {
//       _listKey.currentState!.refreshList();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Sales Orders')),
//       body: SalesOrderInfiniteListTab(service: service, onPdfTap: handlePdfTap),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _navigateToAddSalesOrder(),
//         child: const Icon(Icons.add),
//         tooltip: 'Add Sales Order',
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:nhapp/pages/purchase_order/pages/pdf_viewer_page.dart';
import 'package:nhapp/pages/sales_order/models/sales_order.dart';
import 'package:nhapp/pages/sales_order/pages/so_pdf_page.dart';
import 'package:nhapp/pages/sales_order/service/sales_order_service.dart';
import 'package:nhapp/pages/sales_order/widgets/sales_order_infinite_list_tab.dart';
import 'package:nhapp/utils/rightsChecker.dart';

class SalesOrderListPage extends StatefulWidget {
  const SalesOrderListPage({super.key});

  @override
  State<SalesOrderListPage> createState() => SalesOrderListPageState();
}

class SalesOrderListPageState extends State<SalesOrderListPage> {
  final service = SalesOrderService();
  final GlobalKey<SalesOrderInfiniteListTabState> _listKey =
      GlobalKey<SalesOrderInfiniteListTabState>();

  Future<void> handlePdfTap(SalesOrder so) async {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SalesOrderPdfLoaderPage(salesOrder: so),
      ),
    );
  }

  Future<void> _navigateToAddSalesOrder() async {
    final result = await Navigator.pushNamed(context, '/add_sales_order');

    // If sales order was successfully created, refresh the list
    if (result == true && _listKey.currentState != null) {
      _listKey.currentState!.refreshList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canAdd = RightsChecker.canAdd('Sales Order');
    return Scaffold(
      appBar: AppBar(title: const Text('Sales Orders')),
      body: SalesOrderInfiniteListTab(
        key: _listKey,
        service: service,
        onPdfTap: handlePdfTap,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: canAdd ? () => _navigateToAddSalesOrder() : null,
        child: const Icon(Icons.add),
        tooltip: 'Add Sales Order',
      ),
    );
  }
}
