import 'package:flutter/material.dart';
import '../models/lead_attachment.dart';

class LeadAttachmentList extends StatelessWidget {
  final List<LeadAttachment> attachments;
  final void Function(int index) onDelete;
  final bool isDeleting;

  const LeadAttachmentList({
    required this.attachments,
    required this.onDelete,
    this.isDeleting = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) {
      return const SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Existing Attachments:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ...attachments.asMap().entries.map((entry) {
          final idx = entry.key;
          final file = entry.value;
          return ListTile(
            title: Text(file.originalName),
            subtitle: Text('Size: ${file.size} bytes'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed:
                  isDeleting
                      ? null
                      : () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (ctx) => AlertDialog(
                                title: const Text('Delete Attachment'),
                                content: Text(
                                  'Are you sure you want to delete "${file.originalName}"?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(ctx).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(ctx).pop(true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                        );
                        if (confirm == true) {
                          onDelete(idx);
                        }
                      },
            ),
          );
        }),
      ],
    );
  }
}
