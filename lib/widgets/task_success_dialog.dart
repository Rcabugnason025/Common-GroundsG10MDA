import 'package:flutter/material.dart';

/// Shared success dialog widget
class TaskSuccessDialog {
  static void show(BuildContext context, {required bool isEditing}) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 40),
            ),
            const SizedBox(height: 14),
            Text(
              isEditing ? 'Task Updated!' : 'Task Added!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isEditing
                  ? 'Your task has been updated successfully.'
                  : 'Your new task has been added successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
