// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:nhapp/pages/authorize_sales_order/models/sales_order_pend_auth_data.dart';
// import 'package:nhapp/utils/format_utils.dart';

// class SalesOrderCard extends StatefulWidget {
//   final SalesOrderData so;
//   final VoidCallback onPdfTap;
//   final VoidCallback onAuthorizeTap;

//   const SalesOrderCard({
//     required this.so,
//     required this.onPdfTap,
//     required this.onAuthorizeTap,
//     super.key,
//   });

//   @override
//   State<SalesOrderCard> createState() => _SalesOrderCardState();
// }

// class _SalesOrderCardState extends State<SalesOrderCard>
//     with SingleTickerProviderStateMixin {
//   bool _expanded = false;
//   late final AnimationController _animationController;
//   late final Animation<double> _expandAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _expandAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     );
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _toggleExpand() {
//     setState(() {
//       _expanded = !_expanded;
//       if (_expanded) {
//         _animationController.forward();
//       } else {
//         _animationController.reverse();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Slidable(
//       key: ValueKey(widget.so.orderId),
//       endActionPane: ActionPane(
//         motion: const DrawerMotion(),
//         children: [
//           SlidableAction(
//             onPressed: (_) => widget.onPdfTap(),
//             backgroundColor: Colors.blue.shade600,
//             foregroundColor: Colors.white,
//             icon: Icons.picture_as_pdf_outlined,
//             label: 'PDF',
//             borderRadius: const BorderRadius.horizontal(
//               left: Radius.circular(12),
//             ),
//           ),
//           SlidableAction(
//             onPressed:
//                 widget.so.isAuthorized ? null : (_) => widget.onAuthorizeTap(),
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
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header row
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'SO #${widget.so.ioNumber}',
//                               style: theme.textTheme.titleMedium?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                                 color: theme.primaryColor,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               widget.so.customerFullName,
//                               style: theme.textTheme.titleSmall?.copyWith(
//                                 fontWeight: FontWeight.w600,
//                                 color: theme.colorScheme.onSurface,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   // Details section
//                   _DetailSection(so: widget.so),
//                   const SizedBox(height: 12),
//                   // Expand/Collapse button and action hint
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       InkWell(
//                         onTap: _toggleExpand,
//                         borderRadius: BorderRadius.circular(8),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 8,
//                           ),
//                           child: Row(
//                             children: [
//                               const Icon(
//                                 Icons.inventory_2_outlined,
//                                 size: 16,
//                                 color: Colors.blue,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 '${widget.so.itemDetail.length} item${widget.so.itemDetail.length == 1 ? '' : 's'}',
//                                 style: theme.textTheme.bodyMedium?.copyWith(
//                                   color: theme.colorScheme.primary,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               AnimatedBuilder(
//                                 animation: _expandAnimation,
//                                 builder: (context, child) {
//                                   return Transform.rotate(
//                                     angle: _expandAnimation.value * 3.14159,
//                                     child: const Icon(
//                                       Icons.keyboard_arrow_down,
//                                       size: 20,
//                                       color: Colors.blue,
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.swipe_left,
//                             size: 16,
//                             color: theme.colorScheme.onSurface.withOpacity(0.5),
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             'Swipe for actions',
//                             style: theme.textTheme.bodySmall?.copyWith(
//                               color: theme.colorScheme.onSurface.withOpacity(
//                                 0.5,
//                               ),
//                               fontStyle: FontStyle.italic,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             // Expandable item details
//             AnimatedSize(
//               duration: const Duration(milliseconds: 300),
//               curve: Curves.easeInOut,
//               child:
//                   _expanded
//                       ? _ItemDetailsList(items: widget.so.itemDetail)
//                       : const SizedBox.shrink(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _DetailSection extends StatelessWidget {
//   final SalesOrderData so;
//   const _DetailSection({required this.so});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
//       ),
//       child: Column(
//         children: [
//           // _buildDetailRow(
//           //   context,
//           //   'Site',
//           //   so.siteFullName,
//           //   Icons.location_on_outlined,
//           // ),
//           // const SizedBox(height: 8),
//           _buildDetailRow(
//             context,
//             'Date',
//             FormatUtils.formatDateForUser(so.date),
//             Icons.calendar_today_outlined,
//           ),
//           // const SizedBox(height: 8),
//           // _buildDetailRow(
//           //   context,
//           //   'Revision',
//           //   so.revisionNo.toString(),
//           //   Icons.repeat,
//           // ),
//           const SizedBox(height: 8),
//           _buildDetailRow(
//             context,
//             'Total Amount',
//             so.totalAmount.toStringAsFixed(2),
//             Icons.attach_money,
//           ),
//         ],
//       ),
//     );
//   }

//   static Widget _buildDetailRow(
//     BuildContext context,
//     String label,
//     String value,
//     IconData icon,
//   ) {
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
//                   fontWeight: FontWeight.w500,
//                   color: theme.colorScheme.onSurface,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _ItemDetailsList extends StatelessWidget {
//   final List<SalesOrderItem> items;
//   const _ItemDetailsList({required this.items});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: items.length,
//       itemBuilder: (context, index) {
//         final item = items[index];
//         return Container(
//           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: theme.colorScheme.surface,
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(
//               color: theme.colorScheme.outline.withOpacity(0.2),
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Item header
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: theme.colorScheme.primary.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       '#${index + 1}',
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: theme.colorScheme.primary,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       item.itemCode,
//                       style: theme.textTheme.titleSmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               // Item description
//               Text(
//                 item.itemDesc,
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   color: theme.colorScheme.onSurface.withOpacity(0.8),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               // Item details in grid
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildItemDetail(
//                       context,
//                       'Quantity',
//                       '${item.qty} ${item.uom}',
//                     ),
//                   ),
//                   Expanded(
//                     child: _buildItemDetail(
//                       context,
//                       'Rate',
//                       item.rate.toStringAsFixed(2),
//                     ),
//                   ),
//                   Expanded(
//                     child: _buildItemDetail(
//                       context,
//                       'Amount',
//                       item.amount.toStringAsFixed(2),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   static Widget _buildItemDetail(
//     BuildContext context,
//     String label,
//     String value,
//   ) {
//     final theme = Theme.of(context);
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: theme.textTheme.bodySmall?.copyWith(
//             color: theme.colorScheme.onSurface.withOpacity(0.7),
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         Text(
//           value,
//           style: theme.textTheme.bodyMedium?.copyWith(
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nhapp/pages/authorize_sales_order/models/sales_order_pend_auth_data.dart';
import 'package:nhapp/utils/format_utils.dart';

class SalesOrderCard extends StatefulWidget {
  final SalesOrderData so;
  final VoidCallback onPdfTap;
  final VoidCallback onAuthorizeTap;

  const SalesOrderCard({
    required this.so,
    required this.onPdfTap,
    required this.onAuthorizeTap,
    super.key,
  });

  @override
  State<SalesOrderCard> createState() => _SalesOrderCardState();
}

class _SalesOrderCardState extends State<SalesOrderCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _animationController;
  late final Animation<double> _expandAnimation;

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

  void _toggleExpand() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Slidable(
      key: ValueKey(widget.so.orderId),
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
            onPressed:
                widget.so.isAuthorized ? null : (_) => widget.onAuthorizeTap(),
            backgroundColor:
                widget.so.isAuthorized
                    ? Colors.grey.shade400
                    : Colors.green.shade600,
            foregroundColor: Colors.white,
            icon:
                widget.so.isAuthorized
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
            label: widget.so.isAuthorized ? 'Authorized' : 'Authorize',
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(12),
            ),
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Main content
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with SO number and customer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SO #${widget.so.ioNumber}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.so.customerFullName,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Details section
                  _DetailSection(so: widget.so),
                  const SizedBox(height: 12),
                  // Expand/Collapse button and action hint
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: _toggleExpand,
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
                                '${widget.so.itemDetail.length} item${widget.so.itemDetail.length == 1 ? '' : 's'}',
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
                                    angle: _expandAnimation.value * math.pi,
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
            // Expandable item details
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
                            _ItemDetailsList(items: widget.so.itemDetail),
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
}

class _DetailSection extends StatelessWidget {
  final SalesOrderData so;
  const _DetailSection({required this.so});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            context,
            'Date',
            FormatUtils.formatDateForUser(so.date),
            Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            context,
            'Total Amount',
            FormatUtils.formatAmount(so.totalAmount),
            Icons.currency_rupee,
          ),
        ],
      ),
    );
  }

  static Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
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
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ItemDetailsList extends StatelessWidget {
  final List<SalesOrderItem> items;
  const _ItemDetailsList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          items.asMap().entries.map((entry) {
            return _buildItemCard(context, entry.value, entry.key);
          }).toList(),
    );
  }

  Widget _buildItemCard(BuildContext context, SalesOrderItem item, int index) {
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

  static Widget _buildItemDetail(
    BuildContext context,
    String label,
    String value,
  ) {
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
