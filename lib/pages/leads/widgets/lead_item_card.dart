import 'package:flutter/material.dart';
import 'package:nhapp/pages/leads/models/lead_form.dart';

class LeadItemCard extends StatelessWidget {
  final LeadItemEntry entry;
  final VoidCallback onDelete;
  final ValueChanged<double> onQtyChanged;
  final ValueChanged<double> onRateChanged;

  const LeadItemCard({
    required this.entry,
    required this.onDelete,
    required this.onQtyChanged,
    required this.onRateChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.item.itemName, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: entry.qty.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Qty'),
                        onChanged: (v) => onQtyChanged(double.tryParse(v) ?? 0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: entry.item.salesUOM,
                        readOnly: true,
                        decoration: const InputDecoration(labelText: 'UOM'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: entry.rate.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Rate'),
                        onChanged:
                            (v) => onRateChanged(double.tryParse(v) ?? 0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}
