// import 'package:flutter/material.dart';
// import 'package:nhapp/pages/authorize_sales_order/models/sales_order_pend_auth_data.dart';
// import 'package:nhapp/pages/authorize_sales_order/pages/auth_sales_order_view_pdf.dart';
// import 'package:nhapp/pages/authorize_sales_order/service/auth_sales_order_service.dart';
// import 'package:nhapp/pages/authorize_sales_order/widgets/auth_sales_order_infinite_list.dart';

// class AuthorizeSalesOrderListPage extends StatefulWidget {
//   const AuthorizeSalesOrderListPage({super.key});

//   @override
//   State<AuthorizeSalesOrderListPage> createState() =>
//       _SalesOrderListPageState();
// }

// class _SalesOrderListPageState extends State<AuthorizeSalesOrderListPage> {
//   final service = SalesOrderService();

//   Future<void> handlePdfTap(BuildContext context, SalesOrderData so) async {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => SalesOrderPdfLoaderPage(so: so, service: service),
//       ),
//     );
//   }

//   Future<bool> handleAuthorizeTap(
//     BuildContext context,
//     SalesOrderData so,
//   ) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Authorize Sales Order'),
//             content: Text(
//               'Are you sure you want to authorize SO# ${so.ioNumber}?',
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: () => Navigator.pop(context, true),
//                 child: const Text('Authorize'),
//               ),
//             ],
//           ),
//     );
//     if (confirm == true) {
//       try {
//         final success = await service.authorizeSalesOrder(so);
//         if (success) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Sales Order authorized successfully!'),
//             ),
//           );
//           return true;
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Failed to authorize Sales Order')),
//           );
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error: $e')));
//       }
//     }
//     return false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Sales Order Authorization')),
//       body: SalesOrderInfiniteList(
//         service: service,
//         onPdfTap: (so) => handlePdfTap(context, so),
//         onAuthorizeTap: (so) => handleAuthorizeTap(context, so),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:nhapp/pages/authorize_sales_order/models/sales_order_pend_auth_data.dart';
import 'package:nhapp/pages/authorize_sales_order/pages/auth_sales_order_view_pdf.dart';
import 'package:nhapp/pages/authorize_sales_order/service/auth_sales_order_service.dart';
import 'package:nhapp/pages/authorize_sales_order/widgets/auth_sales_order_infinite_list.dart';

class AuthorizeSalesOrderListPage extends StatefulWidget {
  const AuthorizeSalesOrderListPage({super.key});

  @override
  State<AuthorizeSalesOrderListPage> createState() =>
      _SalesOrderListPageState();
}

class _SalesOrderListPageState extends State<AuthorizeSalesOrderListPage> {
  final service = SalesOrderService();

  Future<void> handlePdfTap(BuildContext context, SalesOrderData so) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SalesOrderPdfLoaderPage(so: so, service: service),
      ),
    );
  }

  Future<bool> handleAuthorizeTap(
    BuildContext context,
    SalesOrderData so,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Authorize Sales Order'),
            content: Text(
              'Are you sure you want to authorize SO# ${so.ioNumber}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Authorize'),
              ),
            ],
          ),
    );
    if (confirm == true) {
      try {
        final success = await service.authorizeSalesOrder(so);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sales Order authorized successfully!'),
            ),
          );
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to authorize Sales Order')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales Order Authorization')),
      body: SalesOrderInfiniteList(
        service: service,
        onPdfTap: (so) => handlePdfTap(context, so),
        onAuthorizeTap: (so) => handleAuthorizeTap(context, so),
      ),
    );
  }
}
