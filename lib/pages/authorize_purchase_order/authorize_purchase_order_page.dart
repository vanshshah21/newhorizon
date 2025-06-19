// import 'package:flutter/material.dart';
// import 'package:nhapp/pages/authorize_purchase_order/models/authorize_po_data.dart';
// import 'package:nhapp/pages/authorize_purchase_order/services/authorize_po_service.dart';
// import 'package:nhapp/pages/authorize_purchase_order/widgets/authorize_po_infinite_list_tab.dart';
// import 'package:nhapp/pages/authorize_purchase_order/widgets/pdf_viewer_page.dart';

// class AuthorizePOListPage extends StatelessWidget {
//   const AuthorizePOListPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final service = AuthorizePOService();

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

//     Future<void> handleAuthorizeTap(
//       BuildContext context,
//       POData po,
//       bool isRegular,
//     ) async {
//       final confirm = await showDialog<bool>(
//         context: context,
//         builder:
//             (context) => AlertDialog(
//               title: const Text('Authorize PO'),
//               content: Text(
//                 'Are you sure you want to authorize PO# ${po.nmbr}?',
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context, false),
//                   child: const Text('Cancel'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => Navigator.pop(context, true),
//                   child: const Text('Authorize'),
//                 ),
//               ],
//             ),
//       );
//       if (confirm == true) {
//         try {
//           final success = await service.authorizePO(po, isRegular);
//           if (success) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('PO authorized successfully!')),
//             );
//           } else {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Failed to authorize PO')),
//             );
//           }
//         } catch (e) {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(SnackBar(content: Text('Error: $e')));
//         }
//       }
//     }

//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Authorize Purchase Orders'),
//           bottom: const TabBar(
//             physics: NeverScrollableScrollPhysics(),
//             tabs: [Tab(text: 'Regular'), Tab(text: 'Capital')],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             AuthorizePOInfiniteList(
//               service: service,
//               isRegular: true,
//               onPdfTap: (po) => handlePdfTap(context, po, true),
//               onAuthorizeTap: (po) => handleAuthorizeTap(context, po, true),
//             ),
//             AuthorizePOInfiniteList(
//               service: service,
//               isRegular: false,
//               onPdfTap: (po) => handlePdfTap(context, po, false),
//               onAuthorizeTap: (po) => handleAuthorizeTap(context, po, false),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:nhapp/pages/authorize_purchase_order/models/authorize_po_data.dart';
import 'package:nhapp/pages/authorize_purchase_order/services/authorize_po_service.dart';
import 'package:nhapp/pages/authorize_purchase_order/widgets/authorize_po_infinite_list_tab.dart';
import 'package:nhapp/pages/authorize_purchase_order/widgets/pdf_viewer_page.dart';

class AuthorizePOListPage extends StatefulWidget {
  const AuthorizePOListPage({super.key});

  @override
  State<AuthorizePOListPage> createState() => _AuthorizePOListPageState();
}

class _AuthorizePOListPageState extends State<AuthorizePOListPage> {
  final service = AuthorizePOService();

  Future<void> handlePdfTap(
    BuildContext context,
    POData po,
    bool isRegular,
  ) async {
    try {
      final pdfUrl = await service.fetchPOPdfUrl(po, isRegular);
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<bool> handleAuthorizeTap(
    BuildContext context,
    POData po,
    bool isRegular,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Authorize PO'),
            content: Text('Are you sure you want to authorize PO# ${po.nmbr}?'),
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
        final success = await service.authorizePO(po, isRegular);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PO authorized successfully!')),
          );
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to authorize PO')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
    // If cancelled or failed, return false
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Authorize Purchase Orders'),
          bottom: const TabBar(
            physics: NeverScrollableScrollPhysics(),
            tabs: [Tab(text: 'Regular'), Tab(text: 'Capital')],
          ),
        ),
        body: TabBarView(
          children: [
            AuthorizePOInfiniteList(
              service: service,
              isRegular: true,
              onPdfTap: (po) => handlePdfTap(context, po, true),
              onAuthorizeTap: (po) => handleAuthorizeTap(context, po, true),
            ),
            AuthorizePOInfiniteList(
              service: service,
              isRegular: false,
              onPdfTap: (po) => handlePdfTap(context, po, false),
              onAuthorizeTap: (po) => handleAuthorizeTap(context, po, false),
            ),
          ],
        ),
      ),
    );
  }
}
