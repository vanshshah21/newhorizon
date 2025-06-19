import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:nhapp/pages/authorize_sales_order/models/sales_order_pend_auth_data.dart';
import 'package:nhapp/pages/authorize_sales_order/service/auth_sales_order_service.dart';

class SalesOrderPdfLoaderPage extends StatefulWidget {
  final SalesOrderData so;
  final SalesOrderService service;

  const SalesOrderPdfLoaderPage({
    required this.so,
    required this.service,
    super.key,
  });

  @override
  State<SalesOrderPdfLoaderPage> createState() =>
      _SalesOrderPdfLoaderPageState();
}

class _SalesOrderPdfLoaderPageState extends State<SalesOrderPdfLoaderPage> {
  String? pdfUrl;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchPdf();
  }

  Future<void> _fetchPdf() async {
    try {
      final url = await widget.service.fetchSalesOrderPdfUrl(widget.so);
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
        appBar: AppBar(title: const Text('Sales Order PDF')),
        body: Center(child: Text(error!)),
      );
    }
    if (pdfUrl == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sales Order PDF')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Sales Order PDF')),
      body: PDF().fromUrl(
        pdfUrl!,
        placeholder: (progress) => Center(child: Text('$progress %')),
        errorWidget: (error) => Center(child: Text(error.toString())),
      ),
    );
  }
}
