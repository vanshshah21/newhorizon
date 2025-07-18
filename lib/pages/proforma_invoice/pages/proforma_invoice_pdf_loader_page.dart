import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:url_launcher/url_launcher.dart';
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

  Future<void> _downloadPdf() async {
    if (pdfUrl == null) return;

    try {
      final uri = Uri.parse(pdfUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('PDF download started')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Cannot open PDF URL')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error downloading PDF: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Proforma Invoice PDF')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error!),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _fetchPdf, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    if (pdfUrl == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Proforma Invoice PDF')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Proforma Invoice ${widget.invoice.number}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadPdf,
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: PDF().fromUrl(
        // pdfUrl!,
        '${pdfUrl!}?t=${DateTime.now().millisecondsSinceEpoch}',
        placeholder: (progress) => Center(child: Text('$progress %')),
        errorWidget:
            (error) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error loading PDF: ${error.toString()}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _downloadPdf,
                    child: const Text('Download PDF'),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
