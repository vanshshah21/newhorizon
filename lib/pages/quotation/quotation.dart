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
import 'package:nhapp/pages/Quotation2/pages/add_quotation_page.dart';
import 'package:nhapp/pages/quotation/models/quotation_list_item.dart';
import 'package:nhapp/pages/quotation/pages/quotation_pdf_loader_page.dart';
import 'package:nhapp/pages/quotation/service/quotation_service.dart';
import 'package:nhapp/pages/quotation/widgets/quotation_infinite_list.dart';

class QuotationListPage extends StatelessWidget {
  final QuotationService service = QuotationService();
  final GlobalKey<QuotationInfiniteListState> _listKey = GlobalKey();

  QuotationListPage({super.key});

  void handlePdfTap(BuildContext context, QuotationListItem quotation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuotationPdfLoaderPage(quotation: quotation),
      ),
    );
  }

  Future<void> _openAddQuotation(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddQuotationPage()),
    );
    if (result == true) {
      // Call refresh on the list
      _listKey.currentState?.refresh();
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddQuotation(context),
        tooltip: 'Create Quotation',
        child: const Icon(Icons.add),
      ),
    );
  }
}
