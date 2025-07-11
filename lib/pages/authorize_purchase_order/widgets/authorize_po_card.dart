// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:nhapp/pages/authorize_purchase_order/models/authorize_po_data.dart';
// import 'package:nhapp/utils/call_utils.dart';
// import 'package:nhapp/utils/format_utils.dart';

// class AuthorizePOCard extends StatefulWidget {
//   final POData po;
//   final VoidCallback onPdfTap;
//   final VoidCallback onAuthorizeTap;

//   const AuthorizePOCard({
//     required this.po,
//     required this.onPdfTap,
//     required this.onAuthorizeTap,
//     super.key,
//   });

//   @override
//   State<AuthorizePOCard> createState() => _AuthorizePOCardState();
// }

// class _AuthorizePOCardState extends State<AuthorizePOCard> {
//   bool _expanded = false;

//   @override
//   Widget build(BuildContext context) {
//     return Slidable(
//       key: ValueKey(widget.po.id),
//       endActionPane: ActionPane(
//         // extentRatio: 0.4,
//         motion: const DrawerMotion(),
//         children: [
//           SlidableAction(
//             onPressed: (_) => widget.onPdfTap(),
//             backgroundColor: Colors.blue,
//             foregroundColor: Colors.white,
//             icon: Icons.picture_as_pdf,
//             label: 'PDF',
//           ),
//           SlidableAction(
//             onPressed: (_) => widget.onAuthorizeTap(),
//             backgroundColor: Colors.green,
//             foregroundColor: Colors.white,
//             icon: Icons.check,
//             label: 'Authorize',
//           ),
//         ],
//       ),
//       child: Card(
//         margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         // margin: const EdgeInsets.all(8.0),
//         child: ExpansionTile(
//           initiallyExpanded: _expanded,
//           onExpansionChanged: (val) => setState(() => _expanded = val),
//           title: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'PO#: ${widget.po.nmbr} ',
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//               IconButton(
//                 color:
//                     (widget.po.mobile.isNotEmpty)
//                         ? Theme.of(context).primaryColor
//                         : Theme.of(context).disabledColor,
//                 icon: const Icon(Icons.phone),
//                 onPressed:
//                     (widget.po.mobile.isNotEmpty)
//                         ? () => CallUtils.makePhoneCall(widget.po.mobile)
//                         : null,
//                 tooltip: 'Call',
//               ),
//             ],
//           ),
//           subtitle: Text(
//             'Vendor: ${widget.po.vendor}\nBuyer: ${widget.po.buyer}\nAmount: ${FormatUtils.formatAmount(widget.po.pototalamt)}\nDate: ${FormatUtils.formatDateForUser(DateTime.parse(widget.po.date))}',
//           ),

//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Item Details:',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   ...ListTile.divideTiles(
//                     context: context,
//                     tiles: widget.po.itemDetail.map(
//                       (item) => ListTile(
//                         dense: true,
//                         title: Text(item.itemCode),
//                         subtitle: Text(
//                           'Description: ${item.itemDesc} \nQty: ${FormatUtils.formatQuantity(item.qty)} ${item.uom} \nRate: ${FormatUtils.formatAmount(item.rate)} \nAmount: ${FormatUtils.formatAmount(item.amount)}',
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nhapp/pages/authorize_purchase_order/models/authorize_po_data.dart';
import 'package:nhapp/utils/call_utils.dart';
import 'package:nhapp/utils/format_utils.dart';

class AuthorizePOCard extends StatefulWidget {
  final POData po;
  final VoidCallback onPdfTap;
  final VoidCallback onAuthorizeTap;
  final bool selected;

  const AuthorizePOCard({
    required this.po,
    required this.onPdfTap,
    required this.onAuthorizeTap,
    this.selected = false,
    super.key,
  });

  @override
  State<AuthorizePOCard> createState() => _AuthorizePOCardState();
}

class _AuthorizePOCardState extends State<AuthorizePOCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPhone = widget.po.mobile.isNotEmpty;

    return Slidable(
      key: ValueKey(widget.po.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => widget.onPdfTap(),
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            icon: Icons.picture_as_pdf_outlined,
            label: 'PDF',
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(12),
            ),
          ),
          SlidableAction(
            onPressed: (_) => widget.onAuthorizeTap(),
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
        elevation: widget.selected ? 6 : 2,
        shape:
            widget.selected
                ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.primary, width: 2),
                )
                : null,
        child: Column(
          children: [
            // Main content
            Container(
              padding: const EdgeInsets.all(16),
              decoration:
                  widget.selected
                      ? BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      )
                      : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ...existing code...
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PO #${widget.po.nmbr}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.po.vendor.trim(),
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
                              hasPhone
                                  ? theme.primaryColor
                                  : theme.disabledColor,
                          onPressed:
                              hasPhone
                                  ? () =>
                                      CallUtils.makePhoneCall(widget.po.mobile)
                                  : null,
                          tooltip:
                              hasPhone
                                  ? 'Call ${widget.po.mobile}'
                                  : 'No phone number',
                        ),
                      ),
                    ],
                  ),
                  // ...existing code...
                  const SizedBox(height: 12),
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
                          widget.po.buyer.trim(),
                          Icons.person_outline,
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          context,
                          'Amount',
                          FormatUtils.formatAmount(widget.po.pototalamt),
                          Icons.currency_rupee,
                          valueColor: theme.colorScheme.primary,
                          isAmount: true,
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          context,
                          'Date',
                          FormatUtils.formatDateForUser(
                            DateTime.parse(widget.po.date),
                          ),
                          Icons.calendar_today_outlined,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _expanded = !_expanded;
                            if (_expanded) {
                              _animationController.forward();
                            } else {
                              _animationController.reverse();
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${widget.po.itemDetail.length} item${widget.po.itemDetail.length == 1 ? '' : 's'}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              AnimatedBuilder(
                                animation: _expandAnimation,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _expandAnimation.value * 3.14159,
                                    child: Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 20,
                                      color: theme.colorScheme.primary,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
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
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.5,
                              ),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child:
                  _expanded
                      ? Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withOpacity(0.3),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.list_alt,
                                    size: 18,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Item Details',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...widget.po.itemDetail.asMap().entries.map(
                              (entry) => _buildItemCard(
                                context,
                                entry.value,
                                entry.key,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
          ],
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

  Widget _buildItemCard(BuildContext context, dynamic item, int index) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '#${index + 1}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.itemCode,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Item description
          Text(
            item.itemDesc,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),

          const SizedBox(height: 8),

          // Item details in grid
          Row(
            children: [
              Expanded(
                child: _buildItemDetail(
                  context,
                  'Quantity',
                  '${FormatUtils.formatQuantity(item.qty)} ${item.uom}',
                ),
              ),
              Expanded(
                child: _buildItemDetail(
                  context,
                  'Rate',
                  FormatUtils.formatAmount(item.rate),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Amount (highlighted)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amount',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  FormatUtils.formatAmount(item.amount),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemDetail(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Column(
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
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
