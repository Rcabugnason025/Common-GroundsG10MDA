import 'package:flutter/material.dart';
import 'package:commongrounds/data/mock_detailed_tasks.dart';
import 'package:commongrounds/model/detailed_task.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  void _addOrEditTask({DetailedTask? task, int? index}) {
    final isEditing = task != null;
    String title = task?.title ?? '';
    String subject = task?.subject ?? '';
    String priority = task?.priority ?? 'Medium Priority';
    String status = task?.status ?? 'Not Started';
    DateTime deadline =
        task?.deadline ?? DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Task' : 'Add New Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: title,
                      decoration: const InputDecoration(
                        labelText: 'Task Title',
                      ),
                      onChanged: (value) => title = value,
                    ),
                    TextFormField(
                      initialValue: subject,
                      decoration: const InputDecoration(labelText: 'Subject'),
                      onChanged: (value) => subject = value,
                    ),
                    const SizedBox(height: 16),
                    // Date Picker Row
                    Row(
                      children: [
                        const Text("Due Date: "),
                        TextButton(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: deadline,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setStateDialog(() {
                                deadline = picked;
                              });
                            }
                          },
                          child: Text(
                            "${deadline.year}-${deadline.month}-${deadline.day}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: priority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items:
                          ['High Priority', 'Medium Priority', 'Low Priority']
                              .map(
                                (p) =>
                                    DropdownMenuItem(value: p, child: Text(p)),
                              )
                              .toList(),
                      onChanged: (value) =>
                          setStateDialog(() => priority = value!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items:
                          ['Not Started', 'In Progress', 'Completed', 'Overdue']
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                      onChanged: (value) =>
                          setStateDialog(() => status = value!),
                    ),
                  ],
                ),
              ),
              actions: [
                if (isEditing)
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteTask(index!);
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Delete'),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (title.isNotEmpty && subject.isNotEmpty) {
                      setState(() {
                        if (isEditing) {
                          mockDetailedTasks[index!] = task.copyWith(
                            title: title,
                            subject: subject,
                            priority: priority,
                            status: status,
                          );
                        } else {
                          mockDetailedTasks.insert(
                            0,
                            DetailedTask(
                              title: title,
                              subject: subject,
                              deadline: DateTime.now().add(
                                const Duration(days: 7),
                              ),
                              priority: priority,
                              status: status,
                              progress: 0.0,
                              icon: Icons.assignment,
                              category: 'Personal',
                              simpleDescription: 'New task added by user',
                            ),
                          );
                        }
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Text(isEditing ? 'Save' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showStatusPicker(DetailedTask task, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
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
              ...['Not Started', 'In Progress', 'Completed', 'Overdue'].map(
                (status) => ListTile(
                  leading: status == task.status
                      ? const Icon(Icons.check, color: Colors.blue)
                      : const SizedBox(width: 24),
                  title: Text(status),
                  onTap: () {
                    setState(() {
                      mockDetailedTasks[index] = task.copyWith(status: status);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Status updated to $status')),
                    );
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteTask(int index) {
    setState(() {
      mockDetailedTasks.removeAt(index);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Task deleted')));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks'), centerTitle: true),
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
            key: UniqueKey(), // Use UniqueKey since we don't have stable IDs
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              _deleteTask(index);
            },
            child: Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  // _showTaskDetails(context, task);
                  _addOrEditTask(task: task, index: index);
                },
                onLongPress: () {
                  _addOrEditTask(task: task, index: index);
                },
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
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withOpacity(
                                      0.08,
                                    ),
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
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          task.status,
                                          style: textTheme.labelSmall?.copyWith(
                                            color: colorScheme.onSurface
                                                .withOpacity(0.8),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_drop_down,
                                          size: 16,
                                          color: colorScheme.onSurface
                                              .withOpacity(0.6),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: task.progress,
                              backgroundColor:
                                  colorScheme.surfaceContainerHighest,
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

  void _showTaskDetails(BuildContext context, dynamic detailedTask) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, controller) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                controller: controller,
                children: [
                  Text(
                    detailedTask.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    detailedTask.subject,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('Priority: ${detailedTask.priority}'),
                  const SizedBox(height: 4),
                  Text('Status: ${detailedTask.status}'),
                  const SizedBox(height: 16),
                  if (detailedTask.simpleDescription != null)
                    Text(detailedTask.simpleDescription!)
                  else if (detailedTask.detailedSteps != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: detailedTask.detailedSteps!.map<Widget>((step) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(step.details),
                        );
                      }).toList(),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
