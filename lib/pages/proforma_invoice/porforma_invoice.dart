// pages/proforma_invoice_list_page.dart
import 'package:flutter/material.dart';
import 'package:nhapp/pages/proforma_invoice/models/proforma_invoice_item.dart';
import 'package:nhapp/pages/proforma_invoice/pages/proforma_invoice_pdf_loader_page.dart';
import 'package:nhapp/pages/proforma_invoice/service/proforma_invoice_service.dart';
import 'package:nhapp/pages/proforma_invoice/widgets/proforma_invoice_infinite_list.dart';

class ProformaInvoiceListPage extends StatefulWidget {
  const ProformaInvoiceListPage({super.key});

  @override
  State<ProformaInvoiceListPage> createState() =>
      _ProformaInvoiceListPageState();
}

class _ProformaInvoiceListPageState extends State<ProformaInvoiceListPage> {
  final service = ProformaInvoiceService();

  void handlePdfTap(BuildContext context, ProformaInvoice invoice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ProformaInvoicePdfLoaderPage(
              invoice: invoice,
              service: service,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proforma Invoices')),
      body: ProformaInvoiceInfiniteList(
        service: service,
        onPdfTap: (invoice) => handlePdfTap(context, invoice),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the add proforma invoice page
          Navigator.pushNamed(context, '/add_proforma_invoice');
        },
        tooltip: 'Add Proforma Invoice',
        child: const Icon(Icons.add),
      ),
    );
  }
}
