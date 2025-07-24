import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nhapp/pages/authorize_quotation/models/quotation_data.dart';
import 'package:nhapp/utils/format_utils.dart';
import 'package:nhapp/utils/rightsChecker.dart';

class QuotationCard extends StatefulWidget {
  final QuotationData qtn;
  final VoidCallback onPdfTap;
  final VoidCallback onAuthorizeTap;
  final bool selected;
  final bool showCheckbox;
  final VoidCallback? onCheckboxChanged;

  const QuotationCard({
    required this.qtn,
    required this.onPdfTap,
    required this.onAuthorizeTap,
    this.selected = false,
    this.showCheckbox = false,
    this.onCheckboxChanged,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final hasPhone = widget.qtn.

    final canPrint = RightsChecker.hasRight(
      'Quotation Print',
      RightsChecker.PRINT,
    );
    final canAuthorize = RightsChecker.hasRight(
      'Quotation',
      RightsChecker.AUTHORIZE,
    );

    Widget cardContent = Card(
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
                // Header row with checkbox and QTN number
                Row(
                  children: [
                    if (widget.showCheckbox) ...[
                      Checkbox(
                        value: widget.selected,
                        onChanged:
                            widget.qtn.isAuthorized
                                ? null
                                : (_) => widget.onCheckboxChanged?.call(),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'QTN #${widget.qtn.qtnNumber}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                              if (widget.qtn.isAuthorized) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Authorized',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.qtn.customerFullName,
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
                              '${widget.qtn.itemDetailsList.length} item${widget.qtn.itemDetailsList.length == 1 ? '' : 's'}',
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

                    // Action hint - only show when not in checkbox mode
                    if (!widget.showCheckbox && (canPrint || canAuthorize))
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
                    if (!widget.showCheckbox && !canPrint && !canAuthorize)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer.withOpacity(
                            0.1,
                          ),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: theme.colorScheme.error.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 16,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'No action permissions',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
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
                          _ItemDetailsList(items: widget.qtn.itemDetailsList),
                          const SizedBox(height: 8),
                        ],
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );

    List<SlidableAction> actions = [];

    if (canPrint) {
      actions.add(
        SlidableAction(
          onPressed: (_) => widget.onPdfTap(),
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          icon: Icons.picture_as_pdf_outlined,
          label: 'PDF',
          borderRadius: BorderRadius.horizontal(
            left: actions.isEmpty ? const Radius.circular(12) : Radius.zero,
          ),
        ),
      );
    }

    if (canAuthorize) {
      actions.add(
        SlidableAction(
          onPressed: (_) => widget.onAuthorizeTap(),
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          icon: Icons.check_circle_outline,
          label: 'Authorize',
          borderRadius: BorderRadius.horizontal(
            left: actions.isEmpty ? const Radius.circular(12) : Radius.zero,
            right: const Radius.circular(12),
          ),
        ),
      );
    }

    // If showing checkboxes, disable sliding actions
    if (widget.showCheckbox || (!canPrint && !canAuthorize)) {
      return cardContent;
    }

    // return Slidable(
    //   key: ValueKey(widget.qtn.qtnID),
    //   endActionPane: ActionPane(
    //     motion: const DrawerMotion(),
    //     children: [
    //       SlidableAction(
    //         onPressed: (_) => widget.onPdfTap(),
    //         backgroundColor: Colors.blue.shade600,
    //         foregroundColor: Colors.white,
    //         icon: Icons.picture_as_pdf_outlined,
    //         label: 'PDF',
    //         borderRadius: const BorderRadius.horizontal(
    //           left: Radius.circular(12),
    //         ),
    //       ),
    //       SlidableAction(
    //         onPressed:
    //             widget.qtn.isAuthorized ? null : (_) => widget.onAuthorizeTap(),
    //         backgroundColor:
    //             widget.qtn.isAuthorized
    //                 ? Colors.grey.shade400
    //                 : Colors.green.shade600,
    //         foregroundColor: Colors.white,
    //         icon:
    //             widget.qtn.isAuthorized
    //                 ? Icons.check_circle
    //                 : Icons.check_circle_outline,
    //         label: widget.qtn.isAuthorized ? 'Authorized' : 'Authorize',
    //         borderRadius: const BorderRadius.horizontal(
    //           right: Radius.circular(12),
    //         ),
    //       ),
    //     ],
    //   ),
    //   child: cardContent,
    // );
    return Slidable(
      key: ValueKey(widget.qtn.qtnID),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: actions,
      ),
      child: cardContent,
    );
  }
}

class _ItemDetailsList extends StatelessWidget {
  final List<QuotationItem> items;
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

  Widget _buildItemCard(BuildContext context, QuotationItem item, int index) {
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
            item.itemName,
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
                  FormatUtils.formatAmount(item.qty * item.rate),
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
