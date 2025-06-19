import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nhapp/utils/format_utils.dart';
import '../models/labour_po_data.dart';

class LabourPOCard extends StatefulWidget {
  final LabourPOData po;
  final VoidCallback onCallTap;
  final VoidCallback onPdfTap;

  const LabourPOCard({
    required this.po,
    required this.onCallTap,
    required this.onPdfTap,
    super.key,
  });

  @override
  State<LabourPOCard> createState() => _LabourPOCardState();
}

class _LabourPOCardState extends State<LabourPOCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(widget.po.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => widget.onPdfTap(),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.picture_as_pdf,
            label: 'PDF',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        title: Text(item.itemDesc),
                        subtitle: Text(
                          'Code: ${item.itemCode} \nQty: ${FormatUtils.formatQuantity(item.qty)} ${item.uom} \nRate: ${FormatUtils.formatAmount(item.rate)} \nAmount: ${FormatUtils.formatAmount(item.amount)}',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
