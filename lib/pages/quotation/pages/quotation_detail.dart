// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:nhapp/pages/quotation/service/quotation_service.dart';
// import 'package:nhapp/utils/format_utils.dart';
// import '../models/quotation_list_item.dart';
// import '../models/quotation_detail.dart';

// class QuotationDetailPage extends StatefulWidget {
//   final QuotationListItem quotation;
//   const QuotationDetailPage({required this.quotation, super.key});

//   @override
//   State<QuotationDetailPage> createState() => _QuotationDetailPageState();
// }

// class _QuotationDetailPageState extends State<QuotationDetailPage> {
//   QuotationDetail? detail;
//   String? error;
//   bool loading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchDetail();
//   }

//   Future<void> _fetchDetail() async {
//     setState(() {
//       loading = true;
//       error = null;
//     });
//     try {
//       final service = QuotationService();
//       final result = await service.fetchQuotationDetail(widget.quotation);
//       if (!mounted) return;
//       setState(() {
//         detail = result;
//         loading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         error = 'Error: $e';
//         loading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     if (loading) {
//       return Scaffold(
//         appBar: AppBar(title: Text('Quotation Details')),
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//     if (error != null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Quotation Details')),
//         body: Center(child: Text(error!)),
//       );
//     }
//     if (detail == null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Quotation Details')),
//         body: const Center(child: Text('No data found.')),
//       );
//     }

//     final q = detail!.quotationDetails;
//     final items = detail!.modelDetails;

//     String formatDate(String? dateStr) {
//       if (dateStr == null || dateStr.isEmpty) return '-';
//       try {
//         final dt = DateTime.parse(dateStr);
//         return DateFormat('dd/MM/yyyy').format(dt);
//       } catch (_) {
//         return dateStr;
//       }
//     }

//     return Scaffold(
//       appBar: AppBar(title: const Text('Quotation Details')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Card(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//             side: BorderSide(color: theme.dividerColor, width: 1.5),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Header
//                 Text(
//                   'Quotation No. ${q['quotationNumber'] ?? widget.quotation.qtnNumber}',
//                   style: theme.textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Customer: ${q['customerCode'] ?? widget.quotation.customerCode} - ${q['customerName'] ?? widget.quotation.customerFullName}',
//                   style: theme.textTheme.bodyMedium,
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         'Date: ${FormatUtils.formatDateForUser(DateTime.parse(widget.quotation.date))}',
//                         style: theme.textTheme.bodySmall,
//                       ),
//                     ),
//                     Expanded(
//                       child: Text(
//                         'Status: ${q['quotationStatus'] ?? widget.quotation.quotationStatus ?? "-"}',
//                         style: theme.textTheme.bodySmall,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const Divider(height: 32),

//                 // Info Grid
//                 Wrap(
//                   spacing: 24,
//                   runSpacing: 12,
//                   children: [
//                     _infoTile(
//                       'Year',
//                       q['quotationYear'] ?? widget.quotation.qtnYear,
//                     ),
//                     _infoTile(
//                       'Group',
//                       q['quotationGroup'] ?? widget.quotation.qtnGroup,
//                     ),
//                     _infoTile(
//                       'Site',
//                       q['siteCode'] ?? widget.quotation.siteCode,
//                     ),
//                     _infoTile(
//                       'Revision',
//                       (q['revisionNo'] ?? widget.quotation.revisionNo)
//                           .toString(),
//                     ),
//                     _infoTile('Validity', (q['validity'] ?? '-').toString()),
//                     _infoTile('Currency', q['currencyCode'] ?? '-'),
//                     _infoTile('GST No.', q['gstNo'] ?? '-'),
//                   ],
//                 ),
//                 const SizedBox(height: 24),

//                 // Items Section
//                 Text(
//                   'Items',
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 ...items.map((item) => _itemCard(context, item)).toList(),

//                 const SizedBox(height: 24),

//                 // Amounts
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         'Total (INR): ${q['totalAmounttAfterTaxDomesticCurrency'] ?? '-'}',
//                         style: theme.textTheme.bodyLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: Text(
//                         'Total (Customer): ${q['totalAmountAfterTaxCustomerCurrency'] ?? '-'}',
//                         style: theme.textTheme.bodyLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 // You can add more sections here: Terms, Taxes, Remarks, etc.
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _infoTile(String label, String value) {
//     return SizedBox(
//       width: 160,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
//           const SizedBox(height: 2),
//           Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
//         ],
//       ),
//     );
//   }

//   Widget _itemCard(BuildContext context, Map<String, dynamic> item) {
//     final theme = Theme.of(context);
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       elevation: 0,
//       color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               '${item['salesItemCode'] ?? item['itemCode'] ?? '-'} - ${item['itemName'] ?? item['salesItemDesc'] ?? '-'}',
//               style: theme.textTheme.bodyLarge?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Row(
//               children: [
//                 Expanded(
//                   child: Text('Qty: ${item['qtyIUOM'] ?? item['qty'] ?? '-'}'),
//                 ),
//                 Expanded(child: Text('UOM: ${item['uom'] ?? '-'}')),
//                 Expanded(
//                   child: Text(
//                     'Rate: ${item['basicPriceIUOM'] ?? item['rate'] ?? '-'}',
//                   ),
//                 ),
//               ],
//             ),
//             if (item['remark'] != null && (item['remark'] as String).isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.only(top: 4),
//                 child: Text(
//                   'Remark: ${item['remark']}',
//                   style: theme.textTheme.bodySmall,
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//==================================================================================
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhapp/pages/quotation/service/quotation_service.dart';
import '../models/quotation_list_item.dart';
import '../models/quotation_detail.dart';

class QuotationDetailPage extends StatefulWidget {
  final QuotationListItem quotation;
  const QuotationDetailPage({required this.quotation, super.key});

  @override
  State<QuotationDetailPage> createState() => _QuotationDetailPageState();
}

class _QuotationDetailPageState extends State<QuotationDetailPage> {
  QuotationDetail? detail;
  String? error;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final service = QuotationService();
      final result = await service.fetchQuotationDetail(widget.quotation);
      if (!mounted) return;
      setState(() {
        detail = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'Error: $e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Quotation Details')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: Text('Quotation Details')),
        body: Center(child: Text(error!)),
      );
    }
    if (detail == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Quotation Details')),
        body: const Center(child: Text('No data found.')),
      );
    }

    final q = detail!.quotationDetails;
    final items = detail!.modelDetails;

    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return '-';
      try {
        final dt = DateTime.parse(dateStr);
        return DateFormat('dd/MM/yyyy').format(dt);
      } catch (_) {
        return dateStr;
      }
    }

    // Section 1: Title
    final titleSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quotation No. ${q['quotationNumber'] ?? widget.quotation.qtnNumber}',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          q['customerName'] ?? widget.quotation.customerFullName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    // Section 2: Separator & Info Grid
    final infoSection = Column(
      spacing: 1.0,
      children: [
        const SizedBox(height: 8),
        const Divider(thickness: 1.2),
        const SizedBox(height: 8),
        Row(
          spacing: 1.0,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _infoTile('Quotation Base', q['quotationTypeSalesOrder'] ?? '-'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          spacing: 1.0,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _infoTile('Quotation To', q['customerName'] ?? '-'),
            _infoTile('Bill To', q['billToCustomerName'] ?? '-'),
          ],
        ),
        Row(
          spacing: 1.0,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _infoTile(
              'Number',
              q['quotationNumber'] ?? widget.quotation.qtnNumber,
            ),
            _infoTile(
              'Date',
              formatDate(q['quotationDate'] ?? widget.quotation.date),
            ),
          ],
        ),
      ],
    );

    // Section 3: Items
    final itemsSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Items',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => _itemCard(context, item)),
      ],
    );

    // Section 4: Amounts
    final amountsSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Amounts',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _amountRow(
          'Basic Amount',
          q['totalAmounttAfterTaxDomesticCurrency'] ?? '-',
        ),
        _amountRow('Discount Amount', q['discountAmount'] ?? '-'),
        _amountRow(
          'Tax Amount',
          q['totalTaxAmount'] ?? '-',
        ), // You may need to sum tax from rateStructureDetails if not present
        const Divider(thickness: 1),
        _amountRow(
          'Total Amount',
          q['totalAmountAfterTaxCustomerCurrency'] ?? '-',
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Quotation Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.dividerColor, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                titleSection,
                infoSection,
                itemsSection,
                amountsSection,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _itemCard(BuildContext context, Map<String, dynamic> item) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item['salesItemCode'] ?? item['itemCode'] ?? '-'} - ${item['itemName'] ?? item['salesItemDesc'] ?? '-'}',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Description: ${item['description'] ?? '-'}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text('Qty: ${item['qtyIUOM'] ?? item['qty'] ?? '-'}'),
                ),
                Expanded(child: Text('UOM: ${item['uom'] ?? '-'}')),
                Expanded(
                  child: Text(
                    'Rate: ${item['basicPriceIUOM'] ?? item['rate'] ?? '-'}',
                  ),
                ),
              ],
            ),
            if (item['remark'] != null && (item['remark'] as String).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Remark: ${item['remark']}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _amountRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value is num ? value.toStringAsFixed(2) : value.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
