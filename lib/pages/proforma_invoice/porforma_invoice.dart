// pages/proforma_invoice_list_page.dart
import 'package:flutter/material.dart';
import 'package:nhapp/pages/proforma_invoice/models/proforma_invoice_item.dart';
import 'package:nhapp/pages/proforma_invoice/pages/edit_proforma_invoice.dart';
import 'package:nhapp/pages/proforma_invoice/pages/proforma_invoice_pdf_loader_page.dart';
import 'package:nhapp/pages/proforma_invoice/service/proforma_invoice_service.dart';
import 'package:nhapp/pages/proforma_invoice/widgets/proforma_invoice_infinite_list.dart';
import 'package:nhapp/utils/rightsChecker.dart';

// class ProformaInvoiceListPage extends StatefulWidget {
//   const ProformaInvoiceListPage({super.key});

//   @override
//   State<ProformaInvoiceListPage> createState() =>
//       _ProformaInvoiceListPageState();
// }

// class _ProformaInvoiceListPageState extends State<ProformaInvoiceListPage> {
//   final service = ProformaInvoiceService();
//   final GlobalKey<ProformaInvoiceInfiniteListState> _listKey = GlobalKey();

//   void handlePdfTap(BuildContext context, ProformaInvoice invoice) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder:
//             (_) => ProformaInvoicePdfLoaderPage(
//               invoice: invoice,
//               service: service,
//             ),
//       ),
//     );
//   }

//   void handleDeleteTap(BuildContext context, ProformaInvoice invoice) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Delete Proforma Invoice'),
//             content: Text(
//               'Are you sure you want to delete Proforma Invoice #${invoice.number}?',
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(false),
//                 child: const Text('Cancel'),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(true),
//                 style: TextButton.styleFrom(foregroundColor: Colors.red),
//                 child: const Text('Delete'),
//               ),
//             ],
//           ),
//     );

//     if (confirmed == true) {
//       try {
//         // Show loading indicator
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder:
//               (context) => const AlertDialog(
//                 content: Row(
//                   children: [
//                     CircularProgressIndicator(),
//                     SizedBox(width: 16),
//                     Text('Deleting...'),
//                   ],
//                 ),
//               ),
//         );

//         // Save the result of the delete operation
//         final deleteSuccess = await service.proformaDelete(invoice.id);

//         if (context.mounted) {
//           Navigator.of(context).pop(); // Close loading dialog

//           if (deleteSuccess) {
//             // Show success message and refresh list
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('Proforma Invoice deleted successfully'),
//                 backgroundColor: Colors.green,
//               ),
//             );
//             _listKey.currentState?.refresh();
//           } else {
//             // Show failure message
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('Failed to delete proforma invoice'),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           }
//         }
//       } catch (e) {
//         if (context.mounted) {
//           Navigator.of(context).pop(); // Close loading dialog
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Failed to delete: ${e.toString()}'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Proforma Invoices')),
//       body: ProformaInvoiceInfiniteList(
//         key: _listKey,
//         service: service,
//         onPdfTap: (invoice) => handlePdfTap(context, invoice),
//         onDeleteTap: (invoice) => handleDeleteTap(context, invoice),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           final result = await Navigator.pushNamed(
//             context,
//             '/add_proforma_invoice',
//           );
//           if (result == true) {
//             _listKey.currentState?.refresh();
//           }
//         },
//         tooltip: 'Add Proforma Invoice',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

class ProformaInvoiceListPage extends StatefulWidget {
  const ProformaInvoiceListPage({super.key});

  @override
  State<ProformaInvoiceListPage> createState() =>
      _ProformaInvoiceListPageState();
}

class _ProformaInvoiceListPageState extends State<ProformaInvoiceListPage> {
  final service = ProformaInvoiceService();
  final GlobalKey<ProformaInvoiceInfiniteListState> _listKey = GlobalKey();

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

  void handleEditTap(BuildContext context, ProformaInvoice invoice) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Loading...'),
              ],
            ),
          ),
    );

    try {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        // Navigate to edit page
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditProformaInvoiceForm(invoice: invoice),
          ),
        );

        if (result == true) {
          _listKey.currentState?.refresh();
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open edit page: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void handleDeleteTap(BuildContext context, ProformaInvoice invoice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Proforma Invoice'),
            content: Text(
              'Are you sure you want to delete Proforma Invoice #${invoice.number}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const AlertDialog(
                content: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text('Deleting...'),
                  ],
                ),
              ),
        );

        // Save the result of the delete operation
        final deleteSuccess = await service.proformaDelete(invoice.id);

        if (context.mounted) {
          Navigator.of(context).pop(); // Close loading dialog

          if (deleteSuccess) {
            // Show success message and refresh list
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Proforma Invoice deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
            _listKey.currentState?.refresh();
          } else {
            // Show failure message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to delete proforma invoice'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canCreateProformaInvoice = RightsChecker.canAdd(
      'Proforma Invoice',
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Proforma Invoices')),
      body: ProformaInvoiceInfiniteList(
        key: _listKey,
        service: service,
        onPdfTap: (invoice) => handlePdfTap(context, invoice),
        onEditTap: (invoice) => handleEditTap(context, invoice),
        onDeleteTap: (invoice) => handleDeleteTap(context, invoice),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            canCreateProformaInvoice
                ? () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/add_proforma_invoice',
                  );
                  if (result == true) {
                    _listKey.currentState?.refresh();
                  }
                }
                : null,
        tooltip: 'Add Proforma Invoice',
        child: const Icon(Icons.add),
      ),
    );
  }
}
