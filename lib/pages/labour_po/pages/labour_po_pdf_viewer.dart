import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:nhapp/pages/labour_po/models/labour_po_data.dart';
import 'package:nhapp/pages/labour_po/services/labour_po_service.dart';

class LabourPOPdfLoaderPage extends StatefulWidget {
  final LabourPOData po;
  final LabourPOService service;

  const LabourPOPdfLoaderPage({
    required this.po,
    required this.service,
    super.key,
  });

  @override
  State<LabourPOPdfLoaderPage> createState() => _LabourPOPdfLoaderPageState();
}

class _LabourPOPdfLoaderPageState extends State<LabourPOPdfLoaderPage> {
  String? pdfUrl;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchPdf();
  }

  Future<void> _fetchPdf() async {
    try {
      final url = await widget.service.fetchLabourPOPdfUrl(widget.po);
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
        appBar: AppBar(title: const Text('Labour PO PDF')),
        body: Center(child: Text(error!)),
      );
    }
    if (pdfUrl == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Labour PO PDF')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Labour PO PDF')),
      body: PDF().fromUrl(
        pdfUrl!,
        placeholder: (progress) => Center(child: Text('$progress %')),
        errorWidget: (error) => Center(child: Text(error.toString())),
      ),
    );
  }
}
