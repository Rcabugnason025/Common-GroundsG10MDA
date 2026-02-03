import 'package:flutter/material.dart';
import 'package:commongrounds/data/mock_detailed_tasks.dart';
import 'package:commongrounds/model/detailed_task.dart';
import 'package:commongrounds/widgets/task_edit_dialog.dart';
import 'package:commongrounds/widgets/task_delete_dialog.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  // -------------------------
  // Helpers / Actions
  // -------------------------

  void _deleteTask(int index, {bool showFeedback = true}) {
    setState(() {
      mockDetailedTasks.removeAt(index);
    });

    if (showFeedback) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task deleted'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showStatusPicker(DetailedTask task, int index) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        final statuses = ['Not Started', 'In Progress', 'Completed', 'Overdue'];

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Update Status',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              ...statuses.map(
                (status) => ListTile(
                  leading: status == task.status
                      ? Icon(Icons.check, color: colorScheme.primary)
                      : const SizedBox(width: 24),
                  title: Text(status),
                  onTap: () {
                    setState(() {
                      mockDetailedTasks[index] = task.copyWith(status: status);
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Status updated to $status'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );

                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(int index) async {
    final shouldDelete = await TaskDeleteDialog.show(context);
    if (shouldDelete) {
      _deleteTask(index, showFeedback: true);
    }
  }

  void _confirmEditTask(DetailedTask task, int index) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(Icons.edit_note, color: colorScheme.primary),
            const SizedBox(width: 10),
            const Text('Edit Task?'),
          ],
        ),
        content: Text(
          'Do you want to edit this task now?',
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.75)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: colorScheme.primary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addOrEditTask(task: task, index: index);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  // -------------------------
  // Add / Edit Dialog
  // -------------------------

  void _addOrEditTask({DetailedTask? task, int? index}) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => TaskEditDialog(
        task: task,
        index: index,
        onSave: (updatedTask) {
          setState(() {
            if (task != null && index != null) {
              // Editing existing task
              mockDetailedTasks[index] = updatedTask;
            } else {
              // Adding new task
              mockDetailedTasks.insert(0, updatedTask);
            }
          });
        },
        onDelete: task != null && index != null
            ? () => _confirmDelete(index)
            : null,
      ),
    );
  }

  // -------------------------
  // UI
  // -------------------------

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditTask(),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockDetailedTasks.length,
        itemBuilder: (context, index) {
          final task = mockDetailedTasks[index];

          return Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => _deleteTask(index),
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _confirmEditTask(task, index),
                onLongPress: () => _confirmEditTask(task, index),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: colorScheme.secondary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(task.icon, color: colorScheme.secondary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              task.subject,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    task.priority,
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _showStatusPicker(task, index),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          task.status,
                                          style: textTheme.labelSmall?.copyWith(
                                            color: colorScheme.onSurface.withOpacity(0.85),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_drop_down,
                                          size: 18,
                                          color: colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            LinearProgressIndicator(
                              value: task.progress,
                              backgroundColor: colorScheme.surfaceContainerHighest,
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

