// import 'package:flutter/material.dart';
// import 'package:nhapp/pages/authorize_quotation/models/quotation_data.dart';
// import 'package:nhapp/pages/authorize_quotation/pages/quotation_view_pdf.dart';
// import 'package:nhapp/pages/authorize_quotation/services/quotation_service.dart';
// import 'package:nhapp/pages/authorize_quotation/widgets/quotation_infinite_list.dart';

// class AuthorizeQuotationListPage extends StatefulWidget {
//   const AuthorizeQuotationListPage({super.key});

//   @override
//   State<AuthorizeQuotationListPage> createState() => _QuotationListPageState();
// }

// class _QuotationListPageState extends State<AuthorizeQuotationListPage> {
//   final service = QuotationService();

//   Future<void> handlePdfTap(BuildContext context, QuotationData qtn) async {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => QuotationPdfLoaderPage(qtn: qtn, service: service),
//       ),
//     );
//   }

//   Future<bool> handleAuthorizeTap(
//     BuildContext context,
//     QuotationData qtn,
//   ) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Authorize Quotation'),
//             content: Text(
//               'Are you sure you want to authorize QTN# ${qtn.qtnNumber}?',
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
//         final success = await service.authorizeQuotation(qtn);
//         if (success) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Quotation authorized successfully!')),
//           );
//           return true;
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Failed to authorize Quotation')),
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
//       appBar: AppBar(title: const Text('Quotation Authorization')),
//       body: QuotationInfiniteList(
//         service: service,
//         onPdfTap: (qtn) => handlePdfTap(context, qtn),
//         onAuthorizeTap: (qtn) => handleAuthorizeTap(context, qtn),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:nhapp/pages/authorize_quotation/models/quotation_data.dart';
import 'package:nhapp/pages/authorize_quotation/pages/quotation_view_pdf.dart';
import 'package:nhapp/pages/authorize_quotation/services/quotation_service.dart';
import 'package:nhapp/pages/authorize_quotation/widgets/quotation_infinite_list.dart';

class AuthorizeQuotationListPage extends StatefulWidget {
  const AuthorizeQuotationListPage({super.key});

  @override
  State<AuthorizeQuotationListPage> createState() => _QuotationListPageState();
}

class _QuotationListPageState extends State<AuthorizeQuotationListPage> {
  final service = QuotationService();

  Future<void> handlePdfTap(BuildContext context, QuotationData qtn) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuotationPdfLoaderPage(qtn: qtn, service: service),
      ),
    );
  }

  Future<bool> handleAuthorizeTap(
    BuildContext context,
    QuotationData qtn,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Authorize Quotation'),
            content: Text(
              'Are you sure you want to authorize QTN# ${qtn.qtnNumber}?',
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
        final success = await service.authorizeQuotation(qtn);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quotation authorized successfully!')),
          );
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to authorize Quotation')),
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
      appBar: AppBar(title: const Text('Quotation Authorization')),
      body: QuotationInfiniteList(
        service: service,
        onPdfTap: (qtn) => handlePdfTap(context, qtn),
        onAuthorizeTap: (qtn) => handleAuthorizeTap(context, qtn),
      ),
    );
  }
}
