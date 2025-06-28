import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:nhapp/pages/service_po/models/service_po_data.dart';
import 'package:nhapp/pages/service_po/service/service_po_service.dart';

class ServicePOPdfLoaderPage extends StatefulWidget {
  final ServicePOData po;

  const ServicePOPdfLoaderPage({required this.po, super.key});

  @override
  State<ServicePOPdfLoaderPage> createState() => _ServicePOPdfLoaderPageState();
}

class _ServicePOPdfLoaderPageState extends State<ServicePOPdfLoaderPage> {
  String? pdfUrl;
  String? error;
  final service = ServicePOService();

  @override
  void initState() {
    super.initState();
    _fetchPdf();
  }

  Future<void> _fetchPdf() async {
    setState(() {
      error = null;
      pdfUrl = null;
    });
    try {
      final url = await service.fetchServicePOPdfUrl(widget.po);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service PO PDF'),
        actions: [
          if (pdfUrl != null)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                // TODO: Implement download logic
              },
            ),
        ],
      ),
      body:
          error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(error!, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchPdf,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : pdfUrl == null
              ? const Center(child: CircularProgressIndicator())
              : PDF().fromUrl(
                pdfUrl!,
                placeholder: (progress) => Center(child: Text('$progress %')),
                errorWidget: (error) => Center(child: Text(error.toString())),
              ),
    );
  }
}
