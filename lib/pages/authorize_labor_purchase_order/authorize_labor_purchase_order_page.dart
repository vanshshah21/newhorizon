// import 'package:flutter/material.dart';
// import 'package:nhapp/pages/authorize_labor_purchase_order/model/labor_po_data.dart';
// import 'package:nhapp/pages/authorize_labor_purchase_order/services/labor_po_service.dart';
// import 'package:nhapp/pages/authorize_labor_purchase_order/widgets/labor_po_infinite_list.dart';
// import 'package:nhapp/pages/authorize_labor_purchase_order/widgets/labor_po_pdf_loader_page.dart';

// class LaborPOListPage extends StatefulWidget {
//   const LaborPOListPage({super.key});

//   @override
//   State<LaborPOListPage> createState() => _LaborPOListPageState();
// }

// class _LaborPOListPageState extends State<LaborPOListPage> {
//   final service = LaborPOService();
//   final Set<LaborPOData> selectedPOs = <LaborPOData>{};
//   bool isSelectionMode = false;

//   Future<void> handlePdfTap(BuildContext context, LaborPOData po) async {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => LaborPOPdfLoaderPage(po: po, service: service),
//       ),
//     );
//   }

//   Future<bool> handleAuthorizeTap(BuildContext context, LaborPOData po) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Authorize Labor PO'),
//             content: Text('Are you sure you want to authorize PO# ${po.nmbr}?'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: () => Navigator.pop(context, true),
//                 child: const Text('Authorize'),
//               ),
//             ],
//           ),
//     );
//     if (confirm == true) {
//       try {
//         final success = await service.authorizeLaborPO(po);
//         if (success) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Labor PO authorized successfully!')),
//           );
//           return true;
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Failed to authorize Labor PO')),
//           );
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error: $e')));
//       }
//     }
//     return false;
//   }

//   Future<void> handleBulkAuthorize() async {
//     if (selectedPOs.isEmpty) return;

//     final confirm = await showDialog<bool>(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Authorize Multiple Labor POs'),
//             content: Text(
//               'Are you sure you want to authorize ${selectedPOs.length} Labor PO(s)?',
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: () => Navigator.pop(context, true),
//                 child: const Text('Authorize All'),
//               ),
//             ],
//           ),
//     );

//     if (confirm == true) {
//       try {
//         final success = await service.authorizeBulkLaborPO(
//           selectedPOs.toList(),
//         );
//         if (success) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 '${selectedPOs.length} Labor PO(s) authorized successfully!',
//               ),
//             ),
//           );
//           setState(() {
//             selectedPOs.clear();
//             isSelectionMode = false;
//           });
//           // Trigger refresh of the list
//           return;
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Failed to authorize some Labor POs')),
//           );
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error: $e')));
//       }
//     }
//   }

//   void toggleSelection(LaborPOData po) {
//     setState(() {
//       if (selectedPOs.contains(po)) {
//         selectedPOs.remove(po);
//       } else {
//         selectedPOs.add(po);
//       }

//       if (selectedPOs.isEmpty) {
//         isSelectionMode = false;
//       }
//     });
//   }

//   void enterSelectionMode(LaborPOData po) {
//     setState(() {
//       isSelectionMode = true;
//       selectedPOs.add(po);
//     });
//   }

//   void exitSelectionMode() {
//     setState(() {
//       isSelectionMode = false;
//       selectedPOs.clear();
//     });
//   }

//   void selectAll(List<LaborPOData> allPOs) {
//     setState(() {
//       selectedPOs.addAll(allPOs);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           isSelectionMode
//               ? '${selectedPOs.length} selected'
//               : 'Labor PO Authorization',
//         ),
//         actions: [
//           if (isSelectionMode) ...[
//             IconButton(
//               onPressed: exitSelectionMode,
//               icon: const Icon(Icons.close),
//               tooltip: 'Exit selection mode',
//             ),
//           ],
//         ],
//       ),
//       body: LaborPOInfiniteList(
//         service: service,
//         isSelectionMode: isSelectionMode,
//         selectedPOs: selectedPOs,
//         onPdfTap: (po) => handlePdfTap(context, po),
//         onAuthorizeTap: (po) => handleAuthorizeTap(context, po),
//         onToggleSelection: toggleSelection,
//         onEnterSelectionMode: enterSelectionMode,
//         onBulkAuthorizeRequested: () => handleBulkAuthorize(),
//       ),
//       floatingActionButton:
//           isSelectionMode && selectedPOs.isNotEmpty
//               ? FloatingActionButton.extended(
//                 onPressed: handleBulkAuthorize,
//                 icon: const Icon(Icons.check_circle),
//                 label: Text('Authorize ${selectedPOs.length}'),
//               )
//               : null,
//     );
//   }
// }

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
