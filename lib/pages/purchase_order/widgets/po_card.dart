import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nhapp/pages/purchase_order/model/po_data.dart';
import 'package:nhapp/utils/format_utils.dart';

class POCard extends StatefulWidget {
  final POData po;
  final bool isRegular;
  final VoidCallback onCallTap;
  final VoidCallback onPdfTap;

  const POCard({
    required this.po,
    required this.isRegular,
    required this.onCallTap,
    required this.onPdfTap,
    super.key,
  });

  @override
  State<POCard> createState() => _POCardState();
}

class _POCardState extends State<POCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(widget.po.id),
      endActionPane: ActionPane(
        extentRatio: 0.25,
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => widget.onPdfTap(),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.picture_as_pdf_rounded,
            label: 'PDF',
          ),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: _expanded,
        onExpansionChanged: (val) => setState(() => _expanded = val),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'PO#: ${widget.po.nmbr}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (widget.po.mobile.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.phone),
                onPressed: widget.onCallTap,
                tooltip: 'Call',
              ),
          ],
        ),
        subtitle: Text(
          '${widget.po.vendor}\nBuyer: ${widget.po.buyer}\nAmount: ${FormatUtils.formatAmount(widget.po.pototalamt)}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Item Details:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...ListTile.divideTiles(
                  context: context,
                  tiles: widget.po.itemDetail.map(
                    (item) => ListTile(
                      dense: true,
                      title: Text(item.itemCode),
                      subtitle: Text(
                        'Description: ${item.itemDesc} \nQty: ${FormatUtils.formatQuantity(item.qty)} ${item.uom} \nRate: ${FormatUtils.formatAmount(item.rate)} \nAmount: ${FormatUtils.formatAmount(item.amount)}',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
