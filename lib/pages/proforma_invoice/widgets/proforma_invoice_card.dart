import 'package:flutter/material.dart';
import 'package:nhapp/pages/proforma_invoice/models/proforma_invoice_item.dart';

class ProformaInvoiceCard extends StatelessWidget {
  final ProformaInvoice invoice;
  final VoidCallback onPdfTap;

  const ProformaInvoiceCard({
    required this.invoice,
    required this.onPdfTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(
          'PI No.: ${invoice.number} | Customer: ${invoice.customerFullName}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Date: ${invoice.date.split('T').first}\n'
          'Site: ${invoice.siteFullName}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.picture_as_pdf),
          onPressed: onPdfTap,
          tooltip: 'View PDF',
        ),
      ),
    );
  }
}
