// lib/widgets/confirmation_dialog.dart

import 'package:flutter/material.dart';

Future<bool> showConfirmationDialog(
  BuildContext context,
  String message,
) async {
  return await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Confirm Submission'),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Submit'),
                ),
              ],
            ),
      ) ??
      false;
}
