import 'package:flutter/material.dart';
import '../models/sales_order.dart';

class SalesOrderCard extends StatefulWidget {
  final SalesOrder so;
  final VoidCallback onPdfTap;

  const SalesOrderCard({required this.so, required this.onPdfTap, super.key});

  @override
  State<SalesOrderCard> createState() => _SalesOrderCardState();
}

class _SalesOrderCardState extends State<SalesOrderCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        initiallyExpanded: _expanded,
        onExpansionChanged: (val) => setState(() => _expanded = val),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'SO#: ${widget.so.ioNumber}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: widget.onPdfTap,
              tooltip: 'Print PDF',
            ),
          ],
        ),
        subtitle: Text(
          '${widget.so.customerFullName}\nAmount: ₹${widget.so.totalAmount.toStringAsFixed(2)}\nStatus: ${widget.so.orderStatus}',
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
                  tiles: widget.so.itemDetail.map(
                    (item) => ListTile(
                      dense: true,
                      title: Text(item.itemDesc),
                      subtitle: Text(
                        'Code: ${item.itemCode} \nQty: ${item.qty} ${item.uom} \nRate: ${item.rate} \nAmount: ${item.amount}',
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
