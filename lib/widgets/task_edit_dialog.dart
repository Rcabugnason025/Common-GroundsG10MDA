import 'package:flutter/material.dart';
import 'package:commongrounds/model/detailed_task.dart';
import 'package:commongrounds/services/task_validation_service.dart';
import 'package:commongrounds/widgets/task_success_dialog.dart';

/// Shared dialog widget for adding/editing tasks
class TaskEditDialog extends StatefulWidget {
  final DetailedTask? task;
  final int? index;
  final Function(DetailedTask) onSave;
  final VoidCallback? onDelete;

  const TaskEditDialog({
    super.key,
    this.task,
    this.index,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<TaskEditDialog> createState() => _TaskEditDialogState();
}

class _TaskEditDialogState extends State<TaskEditDialog> {
  late String title;
  late String subject;
  late String priority;
  late String status;
  late DateTime deadline;
  late String category;
  late List<String> categoryOptions;
  late bool addingCategory;
  late TextEditingController categoryController;

  String? titleError;
  String? subjectError;
  String? dateError;
  String? categoryError;

  @override
  void initState() {
    super.initState();
    final isEditing = widget.task != null;
    title = widget.task?.title ?? '';
    subject = widget.task?.subject ?? '';
    const priorityOptions = ['High Priority', 'Medium Priority', 'Low Priority'];
    const statusOptions = ['Not Started', 'In Progress', 'Completed', 'Overdue'];
    priority = widget.task?.priority ?? 'Medium Priority';
    if (!priorityOptions.contains(priority)) {
      priority = 'Medium Priority';
    }
    status = widget.task?.status ?? 'Not Started';
    if (!statusOptions.contains(status)) {
      status = 'Not Started';
    }
    deadline = widget.task?.deadline ?? DateTime.now().add(const Duration(days: 7));
    category = widget.task?.category ?? 'Personal';
    categoryOptions = ['Personal', 'Homework', 'Work', 'Project', 'Other'];
// Always include the current category and remove duplicates
if (!categoryOptions.contains(category)) {
  categoryOptions.add(category);
}
categoryOptions = categoryOptions.toSet().toList();
    addingCategory = false;
    categoryController = TextEditingController();
  }

  @override
  void dispose() {
    categoryController.dispose();
    super.dispose();
  }

  void _saveTask() {
    titleError = TaskValidationService.validateTitle(title);
    subjectError = TaskValidationService.validateSubject(subject);
    dateError = TaskValidationService.validateDate(deadline);

    final isValid = titleError == null && subjectError == null && dateError == null;

    if (!isValid) {
      setState(() {});
      return;
    }

    final isEditing = widget.task != null;
    final updatedTask = isEditing
        ? widget.task!.copyWith(
            title: title.trim(),
            subject: subject.trim(),
            priority: priority,
            status: status,
            deadline: deadline,
            category: category,
          )
        : DetailedTask(
            title: title.trim(),
            subject: subject.trim(),
            deadline: deadline,
            priority: priority,
            status: status,
            progress: 0.0,
            icon: Icons.assignment,
            category: category,
            simpleDescription: 'New task added by user',
          );

    widget.onSave(updatedTask);
    Navigator.pop(context);
    TaskSuccessDialog.show(context, isEditing: isEditing);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        deadline = picked;
        dateError = TaskValidationService.validateDate(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEditing = widget.task != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withOpacity(0.10),
                    colorScheme.secondary.withOpacity(0.10),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isEditing ? Icons.edit : Icons.add_task,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit Task' : 'Add New Task',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Field
                    TextField(
                      controller: TextEditingController(text: title)
                        ..selection = TextSelection.fromPosition(
                          TextPosition(offset: title.length),
                        ),
                      decoration: InputDecoration(
                        labelText: 'Task Title *',
                        hintText: 'Enter task title (3-100 characters)',
                        errorText: titleError,
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                      ),
                      maxLength: 100,
                      onChanged: (value) {
                        title = value;
                        if (titleError != null) {
                          titleError = TaskValidationService.validateTitle(value);
                          setState(() {});
                        }
                      },
                    ),

                    const SizedBox(height: 14),

                    // Subject Field
                    TextField(
                      controller: TextEditingController(text: subject)
                        ..selection = TextSelection.fromPosition(
                          TextPosition(offset: subject.length),
                        ),
                      maxLength: 200,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Subject *',
                        hintText: 'Enter subject (3-200 characters)',
                        errorText: subjectError,
                        prefixIcon: const Icon(Icons.subject),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                      ),
                      onChanged: (value) {
                        subject = value;
                        if (subjectError != null) {
                          subjectError = TaskValidationService.validateSubject(value);
                          setState(() {});
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Date Picker
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: colorScheme.primary, size: 18),
                          const SizedBox(width: 10),
                          const Text(
                            "Due Date:",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _pickDate,
                            icon: Icon(Icons.edit, size: 16, color: colorScheme.primary),
                            label: Text(
                              "${deadline.year}-${deadline.month.toString().padLeft(2, '0')}-${deadline.day.toString().padLeft(2, '0')}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (dateError != null) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, size: 16, color: colorScheme.error),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                dateError!,
                                style: TextStyle(color: colorScheme.error, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Priority Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: ['High Priority', 'Medium Priority', 'Low Priority'].contains(priority) ? priority : 'Medium Priority',
                      decoration: InputDecoration(
                        labelText: 'Priority',
                        prefixIcon: const Icon(Icons.flag),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                      ),
                      items: const [
                        'High Priority',
                        'Medium Priority',
                        'Low Priority',
                      ].map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text(p),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => priority = value);
                      },
                    ),

                    const SizedBox(height: 14),

                    // Status Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: ['Not Started', 'In Progress', 'Completed', 'Overdue'].contains(status) ? status : 'Not Started',
                      decoration: InputDecoration(
                        labelText: 'Status',
                        prefixIcon: const Icon(Icons.info_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                      ),
                      items: const [
                        'Not Started',
                        'In Progress',
                        'Completed',
                        'Overdue',
                      ].map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text(s),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => status = value);
                      },
                    ),

                    const SizedBox(height: 14),

                    // Category Dropdown (only show in edit mode)
                    if (isEditing) ...[
                      addingCategory
                          ? Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: categoryController,
                                    autofocus: true,
                                    decoration: InputDecoration(
                                      labelText: 'New Category',
                                      errorText: categoryError,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: colorScheme.surfaceContainerHighest,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.check),
                                  color: colorScheme.primary,
                                  onPressed: () {
                                    final newCat = categoryController.text.trim();
                                    if (newCat.isEmpty) {
                                      setState(() {
                                        categoryError = 'Category name required';
                                      });
                                      return;
                                    }
                                    if (!categoryOptions.contains(newCat)) {
                                      setState(() {
                                        categoryOptions.add(newCat);
                                        category = newCat;
                                        addingCategory = false;
                                        categoryController.clear();
                                        categoryError = null;
                                      });
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  color: colorScheme.error,
                                  onPressed: () {
                                    setState(() {
                                      addingCategory = false;
                                      categoryController.clear();
                                      categoryError = null;
                                    });
                                  },
                                ),
                              ],
                            )
                          : DropdownButtonFormField<String>(
                              initialValue: category,
                              decoration: InputDecoration(
                                labelText: 'Category',
                                prefixIcon: const Icon(Icons.category),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: colorScheme.surfaceContainerHighest,
                              ),
                              items: [
                                ...categoryOptions.map(
                                  (c) => DropdownMenuItem(value: c, child: Text(c)),
                                ),
                                const DropdownMenuItem<String>(
                                  value: '__add_new__',
                                  child: Row(
                                    children: [
                                      Icon(Icons.add, size: 18),
                                      SizedBox(width: 8),
                                      Text('Add Category'),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == '__add_new__') {
                                  setState(() {
                                    addingCategory = true;
                                  });
                                } else if (value != null) {
                                  setState(() {
                                    category = value;
                                  });
                                }
                              },
                            ),
                      const SizedBox(height: 14),
                    ],

                    // Required Fields Note
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            '* Required fields',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer Buttons
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isEditing && widget.onDelete != null)
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onDelete!();
                      },
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  if (isEditing && widget.onDelete != null) const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _saveTask,
                    icon: Icon(isEditing ? Icons.save : Icons.add, size: 18),
                    label: Text(isEditing ? 'Save' : 'Add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
