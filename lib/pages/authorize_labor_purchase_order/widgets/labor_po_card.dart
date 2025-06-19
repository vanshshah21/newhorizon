// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:nhapp/pages/authorize_labor_purchase_order/model/labor_po_data.dart';
// import 'package:nhapp/utils/call_utils.dart';
// import 'package:nhapp/utils/format_utils.dart';

// class LaborPOCard extends StatelessWidget {
//   final LaborPOData po;
//   final VoidCallback onPdfTap;
//   final VoidCallback onAuthorizeTap;

//   const LaborPOCard({
//     required this.po,
//     required this.onPdfTap,
//     required this.onAuthorizeTap,
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Slidable(
//       key: ValueKey(po.id),
//       endActionPane: ActionPane(
//         motion: const DrawerMotion(),
//         children: [
//           SlidableAction(
//             onPressed: (_) => onPdfTap(),
//             backgroundColor: Colors.blue,
//             foregroundColor: Colors.white,
//             icon: Icons.picture_as_pdf,
//             label: 'PDF',
//           ),
//           SlidableAction(
//             onPressed: (_) => onAuthorizeTap(),
//             backgroundColor: Colors.green,
//             foregroundColor: Colors.white,
//             icon: Icons.check,
//             label: 'Authorize',
//           ),
//         ],
//       ),
//       child: Card(
//         margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         child: ListTile(
//           title: Text(
//             'PO#: ${po.nmbr} | Vendor: ${po.vendor.trim()}',
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           subtitle: Text(
//             'Buyer: ${po.buyer.trim()}\n'
//             'Amount: ${FormatUtils.formatAmount(po.pototalamt)}\n'
//             'Date: ${FormatUtils.formatDateForUser(DateTime.parse(po.date))}',
//           ),
//           trailing: IconButton(
//             color:
//                 (po.mobile?.isNotEmpty ?? false)
//                     ? Theme.of(context).primaryColor
//                     : Theme.of(context).disabledColor,
//             icon: const Icon(Icons.phone),
//             onPressed:
//                 (po.mobile?.isNotEmpty ?? false)
//                     ? () => CallUtils.makePhoneCall(po.mobile!)
//                     : null,
//             tooltip: 'Call',
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nhapp/pages/authorize_labor_purchase_order/model/labor_po_data.dart';
import 'package:nhapp/utils/call_utils.dart';
import 'package:nhapp/utils/format_utils.dart';

class LaborPOCard extends StatelessWidget {
  final LaborPOData po;
  final VoidCallback onPdfTap;
  final VoidCallback onAuthorizeTap;

  const LaborPOCard({
    required this.po,
    required this.onPdfTap,
    required this.onAuthorizeTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPhone = po.mobile?.isNotEmpty ?? false;

    return Slidable(
      key: ValueKey(po.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onPdfTap(),
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            icon: Icons.picture_as_pdf_outlined,
            label: 'PDF',
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(12),
            ),
          ),
          SlidableAction(
            onPressed: (_) => onAuthorizeTap(),
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            icon: Icons.check_circle_outline,
            label: 'Authorize',
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(12),
            ),
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        // elevation: 2,
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with PO number and phone button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PO #${po.nmbr}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          po.vendor.trim(),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color:
                          hasPhone
                              ? theme.primaryColor.withOpacity(0.1)
                              : theme.disabledColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: IconButton(
                      icon: Icon(
                        hasPhone ? Icons.phone : Icons.phone_disabled,
                        size: 20,
                      ),
                      color:
                          hasPhone ? theme.primaryColor : theme.disabledColor,
                      onPressed:
                          hasPhone
                              ? () => CallUtils.makePhoneCall(po.mobile!)
                              : null,
                      tooltip:
                          hasPhone ? 'Call ${po.mobile}' : 'No phone number',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Details section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      context,
                      'Buyer',
                      po.buyer.trim(),
                      Icons.person_outline,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      context,
                      'Amount',
                      FormatUtils.formatAmount(po.pototalamt),
                      Icons.attach_money,
                      valueColor: theme.colorScheme.primary,
                      isAmount: true,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      context,
                      'Date',
                      FormatUtils.formatDateForUser(DateTime.parse(po.date)),
                      Icons.calendar_today_outlined,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Action hint
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.swipe_left,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Swipe for actions',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
    bool isAmount = false,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isAmount ? FontWeight.bold : FontWeight.w500,
                  color: valueColor ?? theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
