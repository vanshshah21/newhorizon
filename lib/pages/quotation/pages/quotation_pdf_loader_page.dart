import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:nhapp/pages/quotation/service/quotation_service.dart';
import '../models/quotation_list_item.dart';

class QuotationPdfLoaderPage extends StatefulWidget {
  final QuotationListItem quotation;

  const QuotationPdfLoaderPage({required this.quotation, super.key});

  @override
  State<QuotationPdfLoaderPage> createState() => _QuotationPdfLoaderPageState();
}

class _QuotationPdfLoaderPageState extends State<QuotationPdfLoaderPage> {
  String? pdfUrl;
  String? error;
  final service = QuotationService();

  @override
  void initState() {
    super.initState();
    _fetchPdf();
  }

  Future<void> _fetchPdf() async {
    try {
      final url = await service.fetchQuotationPdfUrl(widget.quotation);
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
        appBar: AppBar(title: const Text('Quotation PDF')),
        body: Center(child: Text(error!)),
      );
    }
    if (pdfUrl == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quotation PDF')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Quotation PDF Viewer')),
      body: PDF().fromUrl(
        // pdfUrl!,
        '${pdfUrl!}?t=${DateTime.now().millisecondsSinceEpoch}',
        placeholder: (progress) => Center(child: Text('$progress %')),
        errorWidget: (error) => Center(child: Text(error.toString())),
      ),
    );
  }
}
