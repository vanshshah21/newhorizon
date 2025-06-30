import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/lead_data.dart';
import '../services/lead_service.dart';

class LeadPdfLoaderPage extends StatefulWidget {
  final LeadData lead;

  const LeadPdfLoaderPage({required this.lead, super.key});

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
        appBar: AppBar(title: const Text('Lead PDF')),
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
        appBar: AppBar(title: const Text('Lead PDF')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Lead ${widget.lead.inquiryNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadPdf,
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: PDF().fromUrl(
        pdfUrl!,
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
