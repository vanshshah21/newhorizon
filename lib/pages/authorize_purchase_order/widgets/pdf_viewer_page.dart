// // import 'package:flutter/material.dart';
// // import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

// // class PDFViewerPage extends StatelessWidget {
// //   final String pdfUrl;

// //   const PDFViewerPage({required this.pdfUrl, super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('PO PDF')),
// //       body: PDF().fromUrl(
// //         pdfUrl,
// //         placeholder: (progress) => Center(child: Text('$progress %')),
// //         errorWidget: (error) => Center(child: Text(error.toString())),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
// import 'package:nhapp/pages/authorize_purchase_order/models/authorize_po_data.dart';
// import 'package:nhapp/pages/authorize_purchase_order/services/authorize_po_service.dart';

// class PurchasePdfLoaderPage extends StatefulWidget {
//   final POData po;
//   final bool isRegular;
//   final AuthorizePOService service;

//   const PurchasePdfLoaderPage({
//     required this.po,
//     required this.service,
//     required this.isRegular,
//     super.key,
//   });

//   @override
//   State<PurchasePdfLoaderPage> createState() => _PurchasePdfLoaderPageState();
// }

// class _PurchasePdfLoaderPageState extends State<PurchasePdfLoaderPage> {
//   String? pdfUrl;
//   String? error;

//   @override
//   void initState() {
//     super.initState();
//     _fetchPdf();
//   }

//   Future<void> _fetchPdf() async {
//     try {
//       final url = await widget.service.fetchPOPdfUrl(
//         widget.po,
//         widget.isRegular,
//       );
//       if (!mounted) return;
//       if (url.isEmpty) {
//         setState(() => error = 'PDF not found');
//       } else {
//         setState(() => pdfUrl = url);
//       }
//     } catch (e) {
//       if (!mounted) return;
//       setState(() => error = 'Error fetching PDF.');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (error != null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Purchase Order PDF')),
//         body: Center(child: Text(error!)),
//       );
//     }
//     if (pdfUrl == null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Purchase Order PDF')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }
//     return Scaffold(
//       appBar: AppBar(title: const Text('Purchase Order PDF')),
//       body: PDF().fromUrl(
//         pdfUrl!,
//         placeholder: (progress) => Center(child: Text('$progress %')),
//         errorWidget: (error) => Center(child: Text(error.toString())),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class PDFViewerPage extends StatefulWidget {
  final String? pdfUrl;
  final Future<String> Function()? fetchPdfUrl;

  const PDFViewerPage({this.pdfUrl, this.fetchPdfUrl, super.key})
    : assert(
        pdfUrl != null || fetchPdfUrl != null,
        'Either pdfUrl or fetchPdfUrl must be provided',
      );

  @override
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  String? pdfUrl;
  String? error;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.pdfUrl != null) {
      // Direct URL provided
      pdfUrl = widget.pdfUrl;
    } else {
      // Need to fetch URL
      _fetchPdf();
    }
  }

  Future<void> _fetchPdf() async {
    if (widget.fetchPdfUrl == null) return;

    setState(() => isLoading = true);

    try {
      final url = await widget.fetchPdfUrl!();
      if (!mounted) return;
      if (url.isEmpty) {
        setState(() {
          error = 'PDF not found';
          isLoading = false;
        });
      } else {
        setState(() {
          pdfUrl = url;
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'Error fetching PDF.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('PO PDF')),
        body: Center(child: Text(error!)),
      );
    }
    if (pdfUrl == null || isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('PO PDF')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('PO PDF')),
      body: PDF().fromUrl(
        // pdfUrl!,
        '${pdfUrl!}?t=${DateTime.now().millisecondsSinceEpoch}',
        placeholder: (progress) => Center(child: Text('$progress %')),
        errorWidget: (error) => Center(child: Text(error.toString())),
      ),
    );
  }
}
