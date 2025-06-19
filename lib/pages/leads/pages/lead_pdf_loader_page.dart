import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import '../models/lead_data.dart';
import '../services/lead_service.dart';

class LeadPdfLoaderPage extends StatefulWidget {
  final LeadData lead;
  // final LeadService service;

  const LeadPdfLoaderPage({
    required this.lead,
    // required this.service,
    super.key,
  });

  @override
  State<LeadPdfLoaderPage> createState() => _LeadPdfLoaderPageState();
}

class _LeadPdfLoaderPageState extends State<LeadPdfLoaderPage> {
  String? pdfUrl;
  String? error;
  final service = LeadService();

  @override
  void initState() {
    super.initState();
    _fetchPdf();
  }

  Future<void> _fetchPdf() async {
    try {
      final url = await service.fetchLeadPdfUrl(widget.lead);
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
        appBar: AppBar(title: const Text('Lead PDF')),
        body: Center(child: Text(error!)),
      );
    }
    if (pdfUrl == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lead PDF')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Lead PDF')),
      body: PDF().fromUrl(
        pdfUrl!,
        placeholder: (progress) => Center(child: Text('$progress %')),
        errorWidget: (error) => Center(child: Text(error.toString())),
      ),
    );
  }
}
