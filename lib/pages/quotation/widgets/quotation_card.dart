// import 'package:flutter/material.dart';
// import '../models/quotation_list_item.dart';

// class QuotationCard extends StatelessWidget {
//   final QuotationListItem quotation;
//   final VoidCallback onPdfTap;

//   const QuotationCard({
//     required this.quotation,
//     required this.onPdfTap,
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       child: ListTile(
//         onTap: onPdfTap,
//         title: Text(
//           'Quotation#: ${quotation.qtnNumber} | Customer: ${quotation.customerFullName}',
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Text(
//           'Date: ${quotation.date.split('T').first}\n'
//           'Status: ${quotation.quotationStatus ?? "-"}',
//         ),
//         trailing: Text(quotation.qtnYear),
//       ),
//     );
//   }
// }

//-----------------------------------------------------------------------------------

// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:nhapp/pages/quotation/pages/quotation_detail.dart';
// import 'package:nhapp/utils/format_utils.dart';
// import '../models/quotation_list_item.dart';

// class QuotationCard extends StatelessWidget {
//   final QuotationListItem quotation;
//   final VoidCallback onPdfTap;
//   final VoidCallback? onEditTap;
//   final VoidCallback? onDeleteTap;

//   const QuotationCard({
//     required this.quotation,
//     required this.onPdfTap,
//     this.onEditTap,
//     this.onDeleteTap,
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final actions = <Widget>[
//       CustomSlidableAction(
//         onPressed: (_) => onPdfTap(),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//         child: Icon(Icons.picture_as_pdf),
//       ),
//       if (quotation.isEdit)
//         CustomSlidableAction(
//           onPressed: (_) => onEditTap!(),
//           backgroundColor: Colors.green,
//           foregroundColor: Colors.white,
//           child: const Icon(Icons.edit),
//         ),
//     ];

//     return Slidable(
//       key: ValueKey(quotation.qtnID),
//       endActionPane: ActionPane(
//         extentRatio: 0.3,
//         motion: const DrawerMotion(),
//         children: actions,
//       ),
//       child: Card(
//         margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         child: ListTile(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => QuotationDetailPage(quotation: quotation),
//               ),
//             );
//           },
//           title: Text(
//             'Quotation No.: ${quotation.qtnNumber}',
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           subtitle: Text(
//             'Customer: ${quotation.customerFullName}\n'
//             'Date: ${FormatUtils.formatDateForUser(DateTime.parse(quotation.date))}',
//           ),
//           trailing: Text(quotation.qtnYear),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nhapp/pages/quotation/pages/quotation_detail.dart';
import 'package:nhapp/utils/format_utils.dart';
import '../models/quotation_list_item.dart';

class QuotationCard extends StatefulWidget {
  final QuotationListItem quotation;
  final VoidCallback onPdfTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onDeleteTap;

  const QuotationCard({
    required this.quotation,
    required this.onPdfTap,
    this.onEditTap,
    this.onDeleteTap,
    super.key,
  });

  @override
  State<QuotationCard> createState() => _QuotationCardState();
}

class _QuotationCardState extends State<QuotationCard>
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

  Color _getStatusColor() {
    switch (widget.quotation.quotationStatus?.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Slidable(
      key: ValueKey(widget.quotation.qtnID),
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
          if (widget.quotation.isEdit)
            SlidableAction(
              onPressed: (_) => widget.onEditTap!(),
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              icon: Icons.edit_outlined,
              label: 'Edit',
            ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => QuotationDetailPage(quotation: widget.quotation),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              // Main content
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row with QTN number and year badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'QTN #${widget.quotation.qtnNumber}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.quotation.customerFullName,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.quotation.qtnYear,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Details section
                    _DetailSection(quotation: widget.quotation),

                    const SizedBox(height: 12),

                    // Bottom row with expand/status and action hint
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Status badge or expand indicator
                        widget.quotation.quotationStatus != null
                            ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor().withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getStatusColor().withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                widget.quotation.quotationStatus!,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(),
                                ),
                              ),
                            )
                            : const SizedBox.shrink(),

                        // Action hint
                        Row(
                          children: [
                            Icon(
                              Icons.swipe_left,
                              size: 16,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.5,
                              ),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final QuotationListItem quotation;
  const _DetailSection({required this.quotation});

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
            FormatUtils.formatDateForUser(DateTime.parse(quotation.date)),
            Icons.calendar_today_outlined,
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
