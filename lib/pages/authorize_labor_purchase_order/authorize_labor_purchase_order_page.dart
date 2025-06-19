import 'package:flutter/material.dart';
import 'package:nhapp/pages/authorize_labor_purchase_order/model/labor_po_data.dart';
import 'package:nhapp/pages/authorize_labor_purchase_order/services/labor_po_service.dart';
import 'package:nhapp/pages/authorize_labor_purchase_order/widgets/labor_po_infinite_list.dart';
import 'package:nhapp/pages/authorize_labor_purchase_order/widgets/labor_po_pdf_loader_page.dart';

class LaborPOListPage extends StatefulWidget {
  const LaborPOListPage({super.key});

  @override
  State<LaborPOListPage> createState() => _LaborPOListPageState();
}

class _LaborPOListPageState extends State<LaborPOListPage> {
  final service = LaborPOService();

  Future<void> handlePdfTap(BuildContext context, LaborPOData po) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LaborPOPdfLoaderPage(po: po, service: service),
      ),
    );
  }

  Future<bool> handleAuthorizeTap(BuildContext context, LaborPOData po) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Authorize Labor PO'),
            content: Text('Are you sure you want to authorize PO# ${po.nmbr}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Authorize'),
              ),
            ],
          ),
    );
    if (confirm == true) {
      try {
        final success = await service.authorizeLaborPO(po);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Labor PO authorized successfully!')),
          );
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to authorize Labor PO')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Labor PO Authorization')),
      body: LaborPOInfiniteList(
        service: service,
        onPdfTap: (po) => handlePdfTap(context, po),
        onAuthorizeTap: (po) => handleAuthorizeTap(context, po),
      ),
    );
  }
}
