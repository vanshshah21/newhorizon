import 'package:flutter/material.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class PDFViewerPage extends StatelessWidget {
  final String pdfUrl;

  const PDFViewerPage({required this.pdfUrl, super.key});

  @override
  Widget build(BuildContext context) {
    // You may need to download the PDF to a local file before viewing
    // For simplicity, assuming pdfUrl is a direct file path or URL
    return Scaffold(
      appBar: AppBar(title: const Text('PO PDF')),
      body: PDF().cachedFromUrl(
        pdfUrl,
        placeholder: (progress) => Center(child: Text('$progress %')),
        errorWidget: (error) => Center(child: Text(error.toString())),
      ),
    );
  }
}
