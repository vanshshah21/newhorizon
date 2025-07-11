import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nhapp/pages/sales_order/models/sales_order_item.dart';
import 'package:nhapp/pages/sales_order/pages/sales_order_details.dart';
import '../models/sales_order.dart';
import 'package:nhapp/utils/format_utils.dart';

class SalesOrderCard extends StatefulWidget {
  final SalesOrder so;
  final VoidCallback onPdfTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onDeleteTap;

  const SalesOrderCard({
    required this.so,
    required this.onPdfTap,
    this.onEditTap,
    this.onDeleteTap,
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

  List<double> _amounts = [];
  bool _isCalculating = false;

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
    _calculateAmounts();
  }

  @override
  void didUpdateWidget(covariant SalesOrderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.so.itemDetail != widget.so.itemDetail) {
      _calculateAmounts();
    }
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

  void _navigateToDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SalesOrderDetailPage(salesOrder: widget.so),
      ),
    );
  }

  Future<void> _calculateAmounts() async {
    final items = widget.so.itemDetail;
    if (items.isEmpty) {
      setState(() {
        _amounts = [];
        _isCalculating = false;
      });
      return;
    }
    setState(() => _isCalculating = true);

    if (items.length > 10) {
      // For large lists, use compute to avoid blocking UI
      final calculated = await compute(_amountsForItems, items);
      if (!mounted) return;
      setState(() {
        _amounts = calculated;
        _isCalculating = false;
      });
    } else {
      // For small lists, calculate directly
      final calculated = items.map((e) => e.amount).toList();
      setState(() {
        _amounts = calculated;
        _isCalculating = false;
      });
    }
  }

  static List<double> _amountsForItems(List<SalesOrderItem> items) {
    return items.map((e) => e.amount).toList();
  }

  @override
  Widget build(BuildContext context) {
    final so = widget.so;
    final theme = Theme.of(context);

    // Build actions based on permissions
    final actions = <Widget>[
      SlidableAction(
        onPressed: (_) => widget.onPdfTap(),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        icon: Icons.picture_as_pdf_outlined,
        label: 'PDF',
        borderRadius: BorderRadius.horizontal(
          left: const Radius.circular(12),
          right:
              (!so.isEdit && !so.isDelete)
                  ? const Radius.circular(12)
                  : Radius.zero,
        ),
      ),
      if (so.isEdit && widget.onEditTap != null)
        SlidableAction(
          onPressed: (_) => widget.onEditTap!(),
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          icon: Icons.edit_outlined,
          label: 'Edit',
          borderRadius: BorderRadius.horizontal(
            left: Radius.zero,
            right: !so.isDelete ? const Radius.circular(12) : Radius.zero,
          ),
        ),
      if (so.isDelete && widget.onDeleteTap != null)
        SlidableAction(
          onPressed: (_) => widget.onDeleteTap!(),
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          icon: Icons.delete_outline,
          label: 'Delete',
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(12),
          ),
        ),
    ];

    return Slidable(
      key: ValueKey(so.orderId),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: actions,
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: InkWell(
          onTap: _navigateToDetails,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              // Main content - now with onTap to open details page
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row with SO number and status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'SO #${so.ioNumber}',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.primaryColor,
                                        ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.visibility_outlined,
                                    size: 16,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                so.customerFullName,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(so.orderStatus, theme),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                so.orderStatus,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Show permission indicators
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (so.isEdit)
                                  Container(
                                    margin: const EdgeInsets.only(left: 4),
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      size: 12,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                if (so.isDelete)
                                  Container(
                                    margin: const EdgeInsets.only(left: 4),
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Icon(
                                      Icons.delete,
                                      size: 12,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Details section
                    _SalesOrderDetailSection(so: so),
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
                                  '${so.itemDetail.length} item${so.itemDetail.length == 1 ? '' : 's'}',
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.touch_app_outlined,
                                  size: 16,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Tap for details',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.5),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.swipe_left,
                                  size: 16,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getActionHintText(),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.5),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
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
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  8,
                                ),
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
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              _isCalculating
                                  ? const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                  : _SalesOrderItemDetailsList(
                                    items: so.itemDetail,
                                    amounts: _amounts,
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
      ),
    );
  }

  String _getActionHintText() {
    final availableActions = <String>[];
    availableActions.add('PDF');
    if (widget.so.isEdit) availableActions.add('Edit');
    if (widget.so.isDelete) availableActions.add('Delete');

    if (availableActions.length == 1) {
      return 'Swipe for ${availableActions.first}';
    } else {
      return 'Swipe for actions';
    }
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return Colors.green;
      case 'CLOSED':
        return Colors.blue;
      case 'CANCELLED':
        return Colors.red;
      case 'PENDING':
        return Colors.orange;
      default:
        return theme.colorScheme.primary;
    }
  }
}

// ...existing code for _SalesOrderDetailSection and _SalesOrderItemDetailsList...
class _SalesOrderDetailSection extends StatelessWidget {
  final SalesOrder so;
  const _SalesOrderDetailSection({required this.so});

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
            FormatUtils.formatDateForUser(DateTime.parse(so.date)),
            Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            context,
            'Total Amount',
            FormatUtils.formatAmount(so.totalAmount),
            Icons.currency_rupee,
          ),
          if (so.custPONo.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              'Customer PO',
              '${so.custPONo} (${FormatUtils.formatDateForUser(DateTime.parse(so.custPODate))})',
              Icons.receipt_long_outlined,
            ),
          ],
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

class _SalesOrderItemDetailsList extends StatelessWidget {
  final List<SalesOrderItem> items;
  final List<double> amounts;
  const _SalesOrderItemDetailsList({
    required this.items,
    required this.amounts,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            // Defensive: fallback to item amount if amounts is not set
            final amount =
                (idx < amounts.length && amounts.isNotEmpty)
                    ? amounts[idx]
                    : item.amount;
            return _buildItemCard(context, item, idx, amount);
          }).toList(),
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    SalesOrderItem item,
    int index,
    double amount,
  ) {
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
                  FormatUtils.formatAmount(amount),
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
