// import 'package:flutter/material.dart';
// import 'package:nhapp/pages/service_po/models/service_po_data.dart';
// import 'package:nhapp/pages/service_po/service/service_po_service.dart';
// import 'package:nhapp/pages/service_po/widgets/service_po_infinite_list_tab.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

// class ServicePOListPage extends StatelessWidget {
//   const ServicePOListPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final service = ServicePOService();

//     Future<void> handlePdfTap(BuildContext context, ServicePOData po) async {
//       try {
//         final pdfUrl = await service.fetchServicePOPdfUrl(po);
//         if (pdfUrl.isNotEmpty) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder:
//                   (_) => Scaffold(
//                     appBar: AppBar(title: const Text('Service PO PDF')),
//                     body: PDF().fromUrl(
//                       pdfUrl,
//                       placeholder:
//                           (progress) => Center(child: Text('$progress %')),
//                       errorWidget:
//                           (error) => Center(child: Text(error.toString())),
//                     ),
//                   ),
//             ),
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

//     Future<void> handleCallTap(BuildContext context, ServicePOData po) async {
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

//     return ServicePOInfiniteListTab(
//       service: service,
//       onPdfTap: (po) => handlePdfTap(context, po),
//       onCallTap: (po) => handleCallTap(context, po),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:nhapp/pages/service_po/models/service_po_data.dart';
// import 'package:nhapp/pages/service_po/service/service_po_service.dart';
// import 'package:nhapp/pages/service_po/widgets/service_po_infinite_list_tab.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

// class ServicePOListPage extends StatelessWidget {
//   const ServicePOListPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final service = ServicePOService();

//     Future<void> handlePdfTap(BuildContext context, ServicePOData po) async {
//       try {
//         final pdfUrl = await service.fetchServicePOPdfUrl(po);
//         if (pdfUrl.isNotEmpty) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder:
//                   (_) => Scaffold(
//                     appBar: AppBar(title: const Text('Service PO PDF')),
//                     body: PDF().fromUrl(
//                       pdfUrl,
//                       placeholder:
//                           (progress) => Center(child: Text('$progress %')),
//                       errorWidget:
//                           (error) => Center(child: Text(error.toString())),
//                     ),
//                   ),
//             ),
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

//     Future<void> handleCallTap(BuildContext context, ServicePOData po) async {
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

//     return ServicePOInfiniteListTab(
//       service: service,
//       onPdfTap: (po) => handlePdfTap(context, po),
//       onCallTap: (po) => handleCallTap(context, po),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:nhapp/pages/service_po/models/service_po_data.dart';
import 'package:nhapp/pages/service_po/pages/service_po_pdf.dart';
import 'package:nhapp/pages/service_po/service/service_po_service.dart';
import 'package:nhapp/pages/service_po/widgets/service_po_infinite_list_tab.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class ServicePOListPage extends StatefulWidget {
  const ServicePOListPage({super.key});

  @override
  State<ServicePOListPage> createState() => ServicePOListPageState();
}

class ServicePOListPageState extends State<ServicePOListPage> {
  final service = ServicePOService();

  Future<void> handlePdfTap(ServicePOData po) async {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ServicePOPdfLoaderPage(po: po)),
    );
  }

  Future<void> handleCallTap(ServicePOData po) async {
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
    return ServicePOInfiniteListTab(
      service: service,
      onPdfTap: handlePdfTap,
      onCallTap: handleCallTap,
    );
  }
}
