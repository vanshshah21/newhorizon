import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import '../models/sales_order.dart';
import '../service/sales_order_service.dart';

class SalesOrderPdfLoaderPage extends StatefulWidget {
  final SalesOrder salesOrder;

  const SalesOrderPdfLoaderPage({required this.salesOrder, super.key});

  @override
  State<SalesOrderPdfLoaderPage> createState() =>
      _SalesOrderPdfLoaderPageState();
}

class _SalesOrderPdfLoaderPageState extends State<SalesOrderPdfLoaderPage> {
  String? pdfUrl;
  String? error;
  final service = SalesOrderService();

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
      final url = await service.fetchSalesOrderPdfUrl(widget.salesOrder);
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
        title: const Text('Sales Order PDF'),
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
