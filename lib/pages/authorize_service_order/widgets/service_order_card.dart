// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:nhapp/utils/call_utils.dart';
// import 'package:nhapp/utils/format_utils.dart';
// import '../models/service_order_data.dart';

// class ServiceOrderCard extends StatelessWidget {
//   final ServiceOrderData so;
//   final VoidCallback onPdfTap;
//   final VoidCallback onAuthorizeTap;
//   final bool selected;

//   const ServiceOrderCard({
//     required this.so,
//     required this.onPdfTap,
//     required this.onAuthorizeTap,
//     this.selected = false,
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final hasPhone = so.mobile.isNotEmpty;

//     return Slidable(
//       key: ValueKey(so.id),
//       endActionPane: ActionPane(
//         motion: const DrawerMotion(),
//         children: [
//           SlidableAction(
//             onPressed: (_) => onPdfTap(),
//             backgroundColor: Colors.blue.shade600,
//             foregroundColor: Colors.white,
//             icon: Icons.picture_as_pdf_outlined,
//             label: 'PDF',
//             borderRadius: const BorderRadius.horizontal(
//               left: Radius.circular(12),
//             ),
//           ),
//           SlidableAction(
//             onPressed: (_) => onAuthorizeTap(),
//             backgroundColor: Colors.green.shade600,
//             foregroundColor: Colors.white,
//             icon: Icons.check_circle_outline,
//             label: 'Authorize',
//             borderRadius: const BorderRadius.horizontal(
//               right: Radius.circular(12),
//             ),
//           ),
//         ],
//       ),
//       child: Card(
//         margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         // elevation: 2,
//         // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         shape:
//             selected
//                 ? RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   side: BorderSide(color: theme.colorScheme.primary, width: 2),
//                 )
//                 : null,
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           decoration:
//               selected
//                   ? BoxDecoration(
//                     color: theme.colorScheme.primary.withOpacity(0.08),
//                     borderRadius: BorderRadius.circular(12),
//                   )
//                   : null,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header row with SO number and phone button
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'SO #${so.number}',
//                           style: theme.textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.bold,
//                             color: theme.primaryColor,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           so.vendorname.trim(),
//                           style: theme.textTheme.titleSmall?.copyWith(
//                             fontWeight: FontWeight.w600,
//                             color: theme.colorScheme.onSurface,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   if (so.mobile.trim().isNotEmpty)
//                     Container(
//                       decoration: BoxDecoration(
//                         color: theme.primaryColor.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(24),
//                       ),
//                       child: IconButton(
//                         icon: Icon(
//                           hasPhone ? Icons.phone : Icons.phone_disabled,
//                           size: 20,
//                         ),
//                         color: theme.primaryColor,
//                         onPressed: () => CallUtils.makePhoneCall(so.mobile),
//                         tooltip: 'Call ${so.mobile.trim()}',
//                       ),
//                     ),
//                 ],
//               ),

//               const SizedBox(height: 12),

//               // Details section
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.surface,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(
//                     color: theme.colorScheme.outline.withOpacity(0.2),
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     _buildDetailRow(
//                       context,
//                       'Buyer',
//                       so.buyer.trim(),
//                       Icons.person_outline,
//                     ),
//                     const SizedBox(height: 8),
//                     _buildDetailRow(
//                       context,
//                       'Amount',
//                       FormatUtils.formatAmount(so.totalpovalue),
//                       Icons.currency_rupee,
//                       valueColor: theme.colorScheme.primary,
//                       isAmount: true,
//                     ),
//                     const SizedBox(height: 8),
//                     _buildDetailRow(
//                       context,
//                       'Date',
//                       FormatUtils.formatDateForUser(DateTime.parse(so.date)),
//                       Icons.calendar_today_outlined,
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 8),

//               // Action hint
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Icon(
//                     Icons.swipe_left,
//                     size: 16,
//                     color: theme.colorScheme.onSurface.withOpacity(0.5),
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     'Swipe for actions',
//                     style: theme.textTheme.bodySmall?.copyWith(
//                       color: theme.colorScheme.onSurface.withOpacity(0.5),
//                       fontStyle: FontStyle.italic,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(
//     BuildContext context,
//     String label,
//     String value,
//     IconData icon, {
//     Color? valueColor,
//     bool isAmount = false,
//   }) {
//     final theme = Theme.of(context);

//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(6),
//           decoration: BoxDecoration(
//             color: theme.colorScheme.primary.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(6),
//           ),
//           child: Icon(icon, size: 16, color: theme.colorScheme.primary),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: theme.textTheme.bodySmall?.copyWith(
//                   color: theme.colorScheme.onSurface.withOpacity(0.7),
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               Text(
//                 value,
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   fontWeight: isAmount ? FontWeight.bold : FontWeight.w500,
//                   color: valueColor ?? theme.colorScheme.onSurface,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nhapp/utils/call_utils.dart';
import 'package:nhapp/utils/format_utils.dart';
import '../models/service_order_data.dart';

class ServiceOrderCard extends StatelessWidget {
  final ServiceOrderData so;
  final VoidCallback onPdfTap;
  final VoidCallback onAuthorizeTap;
  final bool selected;
  final bool showCheckbox;
  final VoidCallback? onCheckboxChanged;

  const ServiceOrderCard({
    required this.so,
    required this.onPdfTap,
    required this.onAuthorizeTap,
    this.selected = false,
    this.showCheckbox = false,
    this.onCheckboxChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPhone = so.mobile.isNotEmpty;

    Widget cardContent = Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: selected ? 6 : 2,
      shape:
          selected
              ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.primary, width: 2),
              )
              : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration:
            selected
                ? BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                )
                : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with checkbox, SO number and phone button
            Row(
              children: [
                if (showCheckbox) ...[
                  Checkbox(
                    value: selected,
                    onChanged: (_) => onCheckboxChanged?.call(),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SO #${so.number}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        so.vendorname.trim(),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                if (so.mobile.trim().isNotEmpty)
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
                              ? () => CallUtils.makePhoneCall(so.mobile)
                              : null,
                      tooltip:
                          hasPhone
                              ? 'Call ${so.mobile.trim()}'
                              : 'No phone number',
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
                    so.buyer.trim(),
                    Icons.person_outline,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    context,
                    'Amount',
                    FormatUtils.formatAmount(so.totalpovalue),
                    Icons.currency_rupee,
                    valueColor: theme.colorScheme.primary,
                    isAmount: true,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    context,
                    'Date',
                    FormatUtils.formatDateForUser(DateTime.parse(so.date)),
                    Icons.calendar_today_outlined,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Action hint - only show when not in checkbox mode
            if (!showCheckbox)
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
    );

    // If showing checkboxes, disable sliding actions
    if (showCheckbox) {
      return cardContent;
    }

    return Slidable(
      key: ValueKey(so.id),
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
      child: cardContent,
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
