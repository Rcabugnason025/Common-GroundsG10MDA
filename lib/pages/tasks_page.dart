import 'package:flutter/material.dart';
import 'package:commongrounds/data/mock_detailed_tasks.dart';
import 'package:commongrounds/model/detailed_task.dart';
import 'package:commongrounds/widgets/task_edit_dialog.dart';
import 'package:commongrounds/widgets/task_delete_dialog.dart';
import 'package:commongrounds/data/repositories/task_repository.dart';
import 'package:commongrounds/data/repositories/firebase_task_repository.dart';
import 'package:commongrounds/data/repositories/rest_task_repository.dart';
import 'package:commongrounds/data/repositories/sqlite_task_repository.dart';
import 'package:commongrounds/config/app_config.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  late TaskRepository _repo;
  List<DetailedTask> _tasks = [];
  bool _loading = true;
  String _backend = 'local';

  @override
  void initState() {
    super.initState();
    _selectBackend(_backend);
  }

  void _selectBackend(String backend) {
    if (backend == 'local') {
      _repo = SqliteTaskRepository();
      _backend = 'local';
    } else if (backend == 'rest' && AppConfig.restBaseUrl.isNotEmpty) {
      _repo = RestTaskRepository();
      _backend = 'rest';
    } else {
      _repo = FirebaseTaskRepository();
      _backend = 'firebase';
    }
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _loading = true;
    });
    try {
      var result = await _repo.fetchTasks();
      if (_backend == 'local' && result.isEmpty) {
        for (final task in mockDetailedTasks.take(5)) {
          await _repo.createTask(task);
        }
        result = await _repo.fetchTasks();
      }
      setState(() {
        _tasks = result;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _tasks = List<DetailedTask>.from(mockDetailedTasks);
        _loading = false;
      });
    }
  }

  void _deleteTask(int index, {bool showFeedback = true}) {
    final id = _tasks[index].id;
    setState(() {
      _tasks.removeAt(index);
    });
    if (id != null) {
      _repo.deleteTask(id);
    }

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
                    final updated = task.copyWith(status: status);
                    setState(() {
                      _tasks[index] = updated;
                    });
                    if (updated.id != null) {
                      _repo.updateTask(updated);
                    }

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
          style: TextStyle(
            color: colorScheme.onSurface.withAlpha((0.75 * 255).round()),
          ),
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

  void _addOrEditTask({DetailedTask? task, int? index}) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => TaskEditDialog(
        task: task,
        index: index,
        onSave: (updatedTask) {
          if (task != null && index != null) {
            final withId = updatedTask.copyWith(id: task.id);
            setState(() {
              _tasks[index] = withId;
            });
            if (withId.id != null) {
              _repo.updateTask(withId);
            }
          } else {
            setState(() {
              _tasks.insert(0, updatedTask);
            });
            _repo.createTask(updatedTask).then((created) {
              final idx = _tasks.indexOf(updatedTask);
              if (idx != -1) {
                setState(() {
                  _tasks[idx] = created;
                });
              }
            });
          }
        },
        onDelete: task != null && index != null
            ? () => _confirmDelete(index)
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: _selectBackend,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'local',
                child: Text('Use Local (SQLite)'),
              ),
              const PopupMenuItem(
                value: 'firebase',
                child: Text('Use Firebase'),
              ),
              PopupMenuItem(
                value: 'rest',
                enabled: AppConfig.restBaseUrl.isNotEmpty,
                child: const Text('Use REST API'),
              ),
            ],
            icon: const Icon(Icons.sync),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditTask(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];

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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
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
                                color: colorScheme.secondary.withAlpha(
                                  (0.08 * 255).round(),
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                task.icon,
                                color: colorScheme.secondary,
                              ),
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
                                      color: colorScheme.onSurface.withAlpha(
                                        (0.8 * 255).round(),
                                      ),
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
                                          color: colorScheme.primary.withAlpha(
                                            (0.08 * 255).round(),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
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
                                        onTap: () =>
                                            _showStatusPicker(task, index),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: colorScheme
                                                .surfaceContainerHighest,
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                task.status,
                                                style: textTheme.labelSmall
                                                    ?.copyWith(
                                                      color: colorScheme
                                                          .onSurface
                                                          .withAlpha(
                                                            (0.85 * 255)
                                                                .round(),
                                                          ),
                                                    ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(
                                                Icons.arrow_drop_down,
                                                size: 18,
                                                color: colorScheme.onSurface
                                                    .withAlpha(
                                                      (0.6 * 255).round(),
                                                    ),
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
                                    backgroundColor:
                                        colorScheme.surfaceContainerHighest,
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
