import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:nhapp/pages/proforma_invoice/models/proforma_invoice_item.dart';
import '../service/proforma_invoice_service.dart';

class ProformaInvoicePdfLoaderPage extends StatefulWidget {
  final ProformaInvoice invoice;
  final ProformaInvoiceService service;

  const ProformaInvoicePdfLoaderPage({
    required this.invoice,
    required this.service,
    super.key,
  });

  @override
  State<ProformaInvoicePdfLoaderPage> createState() =>
      _ProformaInvoicePdfLoaderPageState();
}

class _ProformaInvoicePdfLoaderPageState
    extends State<ProformaInvoicePdfLoaderPage> {
  String? pdfUrl;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchPdf();
  }

  Future<void> _fetchPdf() async {
    try {
      final url = await widget.service.fetchProformaInvoicePdfUrl(
        widget.invoice,
      );
      if (!mounted) return;
      if (url.isEmpty) {
        setState(() => error = 'PDF not found');
      } else {
        setState(() => pdfUrl = url);
      }
    } catch (e) {
      debugPrint('Error fetching PDF: $e');
      if (!mounted) return;
      setState(() => error = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Proforma Invoice PDF')),
        body: Center(child: Text(error!)),
      );
    }
    if (pdfUrl == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Proforma Invoice PDF')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Proforma Invoice PDF')),
      body: PDF().fromUrl(
        pdfUrl!,
        placeholder: (progress) => Center(child: Text('$progress %')),
        errorWidget: (error) => Center(child: Text(error.toString())),
      ),
    );
  }
}
