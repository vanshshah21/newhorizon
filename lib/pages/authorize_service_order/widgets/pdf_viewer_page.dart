// import 'package:flutter/material.dart';
// import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

// class PDFViewerPage extends StatelessWidget {
//   final String pdfUrl;

//   const PDFViewerPage({required this.pdfUrl, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Service Order PDF')),
//       body: PDF().fromUrl(
//         pdfUrl,
//         placeholder: (progress) => Center(child: Text('$progress %')),
//         errorWidget: (error) => Center(child: Text(error.toString())),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import '../models/service_order_data.dart';
import '../services/service_order_service.dart';

class ServiceOrderPdfLoaderPage extends StatefulWidget {
  final ServiceOrderData so;
  final ServiceOrderService service;

  const ServiceOrderPdfLoaderPage({
    required this.so,
    required this.service,
    super.key,
  });

  @override
  State<ServiceOrderPdfLoaderPage> createState() =>
      _ServiceOrderPdfLoaderPageState();
}

class _ServiceOrderPdfLoaderPageState extends State<ServiceOrderPdfLoaderPage> {
  String? pdfUrl;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchPdf();
  }

  Future<void> _fetchPdf() async {
    try {
      final url = await widget.service.fetchServiceOrderPdfUrl(widget.so);
      if (!mounted) return;
      if (url.isEmpty) {
        setState(() => error = 'PDF not found');
      } else {
        setState(() => pdfUrl = url);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => error = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Service Order PDF')),
        body: Center(child: Text(error!)),
      );
    }
    if (pdfUrl == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Service Order PDF')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Service Order PDF')),
      body: PDF().fromUrl(
        // pdfUrl!,
        '${pdfUrl!}?t=${DateTime.now().millisecondsSinceEpoch}',
        placeholder: (progress) => Center(child: Text('$progress %')),
        errorWidget: (error) => Center(child: Text(error.toString())),
      ),
    );
  }
}
