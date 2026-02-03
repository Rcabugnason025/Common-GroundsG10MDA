import 'package:flutter/material.dart';

/// Shared delete confirmation dialog widget
class TaskDeleteDialog {
  static Future<bool> show(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    bool? result = false;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text('Delete Task?'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this task? This action cannot be undone.',
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.75)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              result = false;
              Navigator.pop(context);
            },
            child: Text('Cancel', style: TextStyle(color: colorScheme.primary)),
          ),
          ElevatedButton(
            onPressed: () {
              result = true;
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
