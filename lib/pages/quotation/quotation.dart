// import 'package:flutter/material.dart';
// import 'package:nhapp/pages/quotation/models/quotation_list_item.dart';
// import 'package:nhapp/pages/quotation/pages/add_quotation.dart';
// import 'package:nhapp/pages/quotation/pages/quotation_pdf_loader_page.dart';
// import 'package:nhapp/pages/quotation/service/quotation_service.dart';
// import 'package:nhapp/pages/quotation/widgets/quotation_infinite_list.dart';

// class QuotationListPage extends StatelessWidget {
//   final QuotationService service = QuotationService();
//   final GlobalKey<QuotationInfiniteListState> _listKey = GlobalKey();

//   QuotationListPage({super.key});

//   void handlePdfTap(BuildContext context, QuotationListItem quotation) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => QuotationPdfLoaderPage(quotation: quotation),
//       ),
//     );
//   }

//   void _openAddQuotation() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const AddQuotationPage()),
//     );
//     if (result == true) {
//       // Call refresh on the list
//       _listKey.currentState?.refresh();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Quotations List')),
//       body: QuotationInfiniteList(
//         service: service,
//         onPdfTap: (quotation) => handlePdfTap(context, quotation),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           _openAddQuotation();
//         },
//         tooltip: 'Create Quotation',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:nhapp/pages/quotation/models/quotation_list_item.dart';
import 'package:nhapp/pages/quotation/pages/quotation_pdf_loader_page.dart';
import 'package:nhapp/pages/quotation/service/quotation_service.dart';
import 'package:nhapp/pages/quotation/test/page/ad_qote.dart';
import 'package:nhapp/pages/quotation/test/page/edit_qote.dart';
import 'package:nhapp/pages/quotation/widgets/quotation_infinite_list.dart';
import 'package:nhapp/utils/error_handler.dart';

class QuotationListPage extends StatelessWidget {
  final QuotationService service = QuotationService();
  final GlobalKey<QuotationInfiniteListState> _listKey = GlobalKey();

  QuotationListPage({super.key});

  Future<void> handlePdfTap(
    BuildContext context,
    QuotationListItem quotation,
  ) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Pre-fetch PDF URL to check if it's available
      await service.fetchQuotationPdfUrl(quotation);

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);

        // Navigate to PDF viewer
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuotationPdfLoaderPage(quotation: quotation),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => handlePdfTap(context, quotation),
            ),
          ),
        );
      }
    }
  }

  Future<void> handleEditQuotation(
    BuildContext context,
    QuotationListItem quotation,
  ) async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => EditQuotationPage(
                quotationGrp: quotation.qtnGroup,
                quotationSiteId: quotation.siteId,
                quotationNumber: quotation.qtnNumber,
                quotationYear: quotation.qtnYear,
              ),
        ),
      );

      if (result == true) {
        // Refresh the list
        _listKey.currentState?.refresh();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quotation updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openAddQuotation(BuildContext context) async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddQuotationPage()),
      );
      if (result == true) {
        // Call refresh on the list
        _listKey.currentState?.refresh();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quotation created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quotations List')),
      body: QuotationInfiniteList(
        key: _listKey,
        service: service,
        onPdfTap: (quotation) => handlePdfTap(context, quotation),
        onEditTap: (quotation) => handleEditQuotation(context, quotation),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddQuotation(context),
        tooltip: 'Create Quotation',
        child: const Icon(Icons.add),
      ),
    );
  }
}
