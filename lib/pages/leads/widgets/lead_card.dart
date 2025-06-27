import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nhapp/pages/leads/models/lead_data.dart';
import 'package:nhapp/pages/leads/pages/edit_lead_page.dart';
import 'package:nhapp/pages/leads/pages/lead_details_page.dart';
import 'package:nhapp/utils/format_utils.dart';

class LeadCard extends StatefulWidget {
  final LeadData lead;
  final VoidCallback onPdfTap;
  final VoidCallback onDeleteTap;

  const LeadCard({
    required this.lead,
    required this.onPdfTap,
    required this.onDeleteTap,
    super.key,
  });

  @override
  State<LeadCard> createState() => _LeadCardState();
}

class _LeadCardState extends State<LeadCard>
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
  void didUpdateWidget(covariant LeadCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lead.inqEntryItemModel != widget.lead.inqEntryItemModel) {
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

  Future<void> _calculateAmounts() async {
    final items = widget.lead.inqEntryItemModel;
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
      final calculated = items.map((e) => e.itemQty * e.basicPrice).toList();
      setState(() {
        _amounts = calculated;
        _isCalculating = false;
      });
    }
  }

  static List<double> _amountsForItems(List<LeadEntryItemModel> items) {
    return items.map((e) => e.itemQty * e.basicPrice).toList();
  }

  @override
  Widget build(BuildContext context) {
    final lead = widget.lead;
    final theme = Theme.of(context);

    final actions = <Widget>[
      SlidableAction(
        onPressed: (_) => widget.onPdfTap(),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        icon: Icons.picture_as_pdf_outlined,
        label: 'PDF',
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
      ),
      if (lead.isEdit)
        SlidableAction(
          onPressed: (_) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EditLeadPage(lead: lead)),
            );
          },
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          icon: Icons.edit_outlined,
          label: 'Edit',
        ),
      if (lead.isDelete)
        SlidableAction(
          onPressed: (_) => widget.onDeleteTap(),
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
      key: ValueKey(lead.inquiryID),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: actions,
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          children: [
            // Main content with onTap
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InquiryDetailsPage(lead: lead),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row with Inquiry number and status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Inquiry #${lead.inquiryNumber}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                lead.customerName,
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
                    _LeadDetailSection(lead: lead),
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
                                  '${lead.inqEntryItemModel.length} item${lead.inqEntryItemModel.length == 1 ? '' : 's'}',
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
                            _isCalculating
                                ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                                : _LeadItemDetailsList(
                                  items: lead.inqEntryItemModel,
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
    );
  }
}

class _LeadDetailSection extends StatelessWidget {
  final LeadData lead;
  const _LeadDetailSection({required this.lead});

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
          const SizedBox(height: 8),
          _buildDetailRow(
            context,
            'Date',
            FormatUtils.formatDateForUser(DateTime.parse(lead.inquiryDate)),
            Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            context,
            'Salesman',
            lead.salesmanName,
            Icons.person_outline,
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

class _LeadItemDetailsList extends StatelessWidget {
  final List<LeadEntryItemModel> items;
  final List<double> amounts;
  const _LeadItemDetailsList({required this.items, required this.amounts});

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            // Defensive: fallback to inline calculation if amounts is not set
            final amount =
                (idx < amounts.length && amounts.isNotEmpty)
                    ? amounts[idx]
                    : (item.itemQty * item.basicPrice);
            return _buildItemCard(context, item, idx, amount);
          }).toList(),
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    LeadEntryItemModel item,
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
                  item.salesItemCode,
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
                  '${FormatUtils.formatQuantity(item.itemQty)} ${item.uom}',
                ),
              ),
              Expanded(
                child: _buildItemDetail(
                  context,
                  'Rate',
                  FormatUtils.formatAmount(item.basicPrice),
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
