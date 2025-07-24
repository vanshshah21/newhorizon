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
import 'package:nhapp/utils/rightsChecker.dart';

class QuotationListPage extends StatelessWidget {
  final QuotationService service = QuotationService();
  final GlobalKey<QuotationInfiniteListState> _listKey = GlobalKey();

  QuotationListPage({super.key});

  Future<void> handlePdfTap(
    BuildContext context,
    QuotationListItem quotation,
  ) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuotationPdfLoaderPage(quotation: quotation),
      ),
    );
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
        // Force refresh on the list by calling refresh method
        _listKey.currentState?.refresh();

        // Add a small delay to ensure the refresh is processed
        await Future.delayed(const Duration(milliseconds: 100));

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
    final bool canCreateQuotation = RightsChecker.canAdd('Quotation');
    return Scaffold(
      appBar: AppBar(title: const Text('Quotations List')),
      body: QuotationInfiniteList(
        key: _listKey,
        service: service,
        onPdfTap: (quotation) => handlePdfTap(context, quotation),
        onEditTap: (quotation) => handleEditQuotation(context, quotation),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: canCreateQuotation ? () => _openAddQuotation(context) : null,
        tooltip: 'Create Quotation',
        child: const Icon(Icons.add),
      ),
    );
  }
}
