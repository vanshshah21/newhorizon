// import 'package:flutter/material.dart';
// import 'package:nhapp/pages/authorize_service_order/models/service_order_data.dart';
// import 'package:nhapp/pages/authorize_service_order/services/service_order_service.dart';
// import 'package:nhapp/pages/authorize_service_order/widgets/pdf_viewer_page.dart';
// import 'package:nhapp/pages/authorize_service_order/widgets/service_order_infinite_list.dart';

// class ServiceOrderListPage extends StatefulWidget {
//   const ServiceOrderListPage({super.key});

//   @override
//   State<ServiceOrderListPage> createState() => _ServiceOrderListPageState();
// }

// class _ServiceOrderListPageState extends State<ServiceOrderListPage> {
//   final service = ServiceOrderService();

//   Future<void> handlePdfTap(BuildContext context, ServiceOrderData so) async {
//     // try {
//     //   final pdfUrl = await service.fetchServiceOrderPdfUrl(so);
//     //   if (pdfUrl.isNotEmpty) {
//     //     Navigator.push(
//     //       context,
//     //       MaterialPageRoute(builder: (_) => PDFViewerPage(pdfUrl: pdfUrl)),
//     //     );
//     //   } else {
//     //     ScaffoldMessenger.of(
//     //       context,
//     //     ).showSnackBar(const SnackBar(content: Text('PDF not found')));
//     //   }
//     // } catch (e) {
//     //   ScaffoldMessenger.of(
//     //     context,
//     //   ).showSnackBar(SnackBar(content: Text('Error: $e')));
//     // }
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ServiceOrderPdfLoaderPage(so: so, service: service),
//       ),
//     );
//   }

//   // Future<bool> handleAuthorizeTap(
//   //   BuildContext context,
//   //   ServiceOrderData so,
//   // ) async {
//   //   final confirm = await showDialog<bool>(
//   //     context: context,
//   //     builder:
//   //         (context) => AlertDialog(
//   //           title: const Text('Authorize Service Order'),
//   //           content: Text(
//   //             'Are you sure you want to authorize SO# ${so.number}?',
//   //           ),
//   //           actions: [
//   //             TextButton(
//   //               onPressed: () => Navigator.pop(context, false),
//   //               child: const Text('Cancel'),
//   //             ),
//   //             ElevatedButton(
//   //               onPressed: () => Navigator.pop(context, true),
//   //               child: const Text('Authorize'),
//   //             ),
//   //           ],
//   //         ),
//   //   );
//   //   if (confirm == true) {
//   //     try {
//   //       final success = await service.authorizeServiceOrder(so);
//   //       if (!mounted) return false;
//   //       if (success) {
//   //         ScaffoldMessenger.of(context).showSnackBar(
//   //           const SnackBar(
//   //             content: Text('Service Order authorized successfully!'),
//   //           ),
//   //         );
//   //         return true;
//   //       } else {
//   //         ScaffoldMessenger.of(context).showSnackBar(
//   //           const SnackBar(content: Text('Failed to authorize Service Order')),
//   //         );
//   //       }
//   //     } catch (e) {
//   //       if (!mounted) return false;
//   //       ScaffoldMessenger.of(
//   //         context,
//   //       ).showSnackBar(SnackBar(content: Text('Error: $e')));
//   //     }
//   //   }
//   //   return false;
//   // }

//   Future<bool> handleAuthorizeTap(
//     BuildContext context,
//     ServiceOrderData so,
//   ) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Authorize Service Order'),
//             content: Text(
//               'Are you sure you want to authorize SO# ${so.number}?',
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

//     // Check if widget is still mounted after the dialog
//     if (!mounted) return false;

//     if (confirm == true) {
//       try {
//         final success = await service.authorizeServiceOrder(so);

//         // Check if widget is still mounted after the async service call
//         if (!mounted) return false;

//         if (success) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Service Order authorized successfully!'),
//             ),
//           );
//           return true;
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Failed to authorize Service Order')),
//           );
//         }
//       } catch (e) {
//         // Also check mounted in the catch block
//         if (!mounted) return false;

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
//       appBar: AppBar(title: const Text('Service Order Authorization')),
//       body: ServiceOrderInfiniteList(
//         service: service,
//         onPdfTap: (so) => handlePdfTap(context, so),
//         onAuthorizeTap: (so) => handleAuthorizeTap(context, so),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:nhapp/pages/authorize_service_order/models/service_order_data.dart';
import 'package:nhapp/pages/authorize_service_order/services/service_order_service.dart';
import 'package:nhapp/pages/authorize_service_order/widgets/pdf_viewer_page.dart';
import 'package:nhapp/pages/authorize_service_order/widgets/service_order_infinite_list.dart';

class ServiceOrderListPage extends StatefulWidget {
  const ServiceOrderListPage({super.key});

  @override
  State<ServiceOrderListPage> createState() => _ServiceOrderListPageState();
}

class _ServiceOrderListPageState extends State<ServiceOrderListPage> {
  final service = ServiceOrderService();

  Future<void> handlePdfTap(ServiceOrderData so) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceOrderPdfLoaderPage(so: so, service: service),
      ),
    );
  }

  Future<bool> handleAuthorizeTap(ServiceOrderData so) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Authorize Service Order'),
            content: Text(
              'Are you sure you want to authorize SO# ${so.number}?',
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

    if (!mounted) return false;

    if (confirm == true) {
      try {
        final success = await service.authorizeServiceOrder(so);

        if (!mounted) return false;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Service Order authorized successfully!'),
            ),
          );
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to authorize Service Order')),
          );
        }
      } catch (e) {
        if (!mounted) return false;

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
      appBar: AppBar(title: const Text('Service Order Authorization')),
      body: ServiceOrderInfiniteList(
        service: service,
        onPdfTap: handlePdfTap,
        onAuthorizeTap:
            handleAuthorizeTap, // Now matches Future<bool> signature
      ),
    );
  }
}
