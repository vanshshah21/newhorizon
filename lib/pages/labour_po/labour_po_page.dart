// import 'package:flutter/material.dart';
// import 'package:nhapp/pages/labour_po/models/labour_po_data.dart';
// import 'package:nhapp/pages/labour_po/services/labour_po_service.dart';
// import 'package:nhapp/pages/labour_po/widgets/labour_po_infinite_list_tab.dart';
// import 'package:nhapp/pages/purchase_order/pages/pdf_viewer_page.dart';
// import 'package:url_launcher/url_launcher.dart';

// class LabourPOListPage extends StatelessWidget {
//   const LabourPOListPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final service = LabourPOService();

//     Future<void> handlePdfTap(BuildContext context, LabourPOData po) async {
//       try {
//         final pdfUrl = await service.fetchLabourPOPdfUrl(po);
//         if (!mounted) return;
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

//     Future<void> handleCallTap(BuildContext context, LabourPOData po) async {
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

//     return LabourPOInfiniteListTab(
//       service: service,
//       onPdfTap: (po) => handlePdfTap(context, po),
//       onCallTap: (po) => handleCallTap(context, po),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:nhapp/pages/labour_po/models/labour_po_data.dart';
import 'package:nhapp/pages/labour_po/pages/labour_po_pdf_viewer.dart';
import 'package:nhapp/pages/labour_po/services/labour_po_service.dart';
import 'package:nhapp/pages/labour_po/widgets/labour_po_infinite_list_tab.dart';
import 'package:url_launcher/url_launcher.dart';

class LabourPOListPage extends StatefulWidget {
  const LabourPOListPage({super.key});

  @override
  State<LabourPOListPage> createState() => LabourPOListPageState();
}

class LabourPOListPageState extends State<LabourPOListPage> {
  final LabourPOService service = LabourPOService();

  Future<void> handlePdfTap(LabourPOData po) async {
    try {
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LabourPOPdfLoaderPage(po: po, service: service),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> handleCallTap(LabourPOData po) async {
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
    return LabourPOInfiniteListTab(
      service: service,
      onPdfTap: handlePdfTap,
      onCallTap: handleCallTap,
    );
  }
}
