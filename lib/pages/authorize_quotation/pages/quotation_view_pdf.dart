import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:nhapp/pages/authorize_quotation/models/quotation_data.dart';
import 'package:nhapp/pages/authorize_quotation/services/quotation_service.dart';

class QuotationPdfLoaderPage extends StatefulWidget {
  final QuotationData qtn;
  final QuotationService service;

  const QuotationPdfLoaderPage({
    required this.qtn,
    required this.service,
    super.key,
  });

  @override
  State<QuotationPdfLoaderPage> createState() => _QuotationPdfLoaderPageState();
}

class _QuotationPdfLoaderPageState extends State<QuotationPdfLoaderPage> {
  String? pdfUrl;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchPdf();
  }

  Future<void> _fetchPdf() async {
    try {
      final url = await widget.service.fetchQuotationPdfUrl(widget.qtn);
      if (!mounted) return;
      if (url.isEmpty) {
        setState(() => error = 'PDF not found');
      } else {
        setState(() => pdfUrl = url);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => error = 'Error fetching PDF.');
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
      appBar: AppBar(title: const Text('Quotation PDF')),
      body: PDF().fromUrl(
        pdfUrl!,
        placeholder: (progress) => Center(child: Text('$progress %')),
        errorWidget: (error) => Center(child: Text(error.toString())),
      ),
    );
  }
}
