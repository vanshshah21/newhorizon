import 'package:flutter/material.dart';
import 'package:nhapp/pages/leads/models/lead_data.dart';
import 'package:nhapp/pages/leads/pages/add_lead_page.dart';
import 'package:nhapp/pages/leads/pages/lead_pdf_loader_page.dart';
import 'package:nhapp/pages/leads/services/lead_service.dart';
import 'package:nhapp/pages/leads/widgets/lead_infinite_list.dart';
import 'package:nhapp/utils/error_handler.dart';

class LeadListPage extends StatefulWidget {
  const LeadListPage({super.key});

  @override
  State<LeadListPage> createState() => _LeadListPageState();
}

class _LeadListPageState extends State<LeadListPage> {
  final service = LeadService();
  final GlobalKey<LeadInfiniteListState> _listKey = GlobalKey();

  Future<void> handlePdfTap(BuildContext context, LeadData lead) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LeadPdfLoaderPage(lead: lead)),
    );
  }

  Future<bool> handleDeleteTap(BuildContext context, LeadData lead) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Lead'),
            content: Text(
              'Are you sure you want to delete Inquiry# ${lead.inquiryNumber}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (confirm == true) {
      final result = await ErrorHandler.handleAsyncOperation<bool>(
        () => service.deleteLead(lead),
        context: context,
        errorMessage: 'Failed to delete lead',
        fallbackValue: false,
      );

      if (result == true) {
        // Refresh the list
        _listKey.currentState?.refresh();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lead deleted successfully!')),
          );
        }
        return true;
      }
    }
    return false;
  }

  void _openAddLead() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddLeadPage()),
    );
    if (result == true) {
      // Call refresh on the list
      _listKey.currentState?.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leads List')),
      body: LeadInfiniteList(
        key: _listKey,
        service: service,
        onPdfTap: (lead) => handlePdfTap(context, lead),
        onDeleteTap: (lead) => handleDeleteTap(context, lead),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddLead,
        tooltip: 'Add Lead',
        child: const Icon(Icons.add),
      ),
    );
  }
}
