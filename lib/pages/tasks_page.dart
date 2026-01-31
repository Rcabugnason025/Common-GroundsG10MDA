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

    // Form key for validation
    final formKey = GlobalKey<FormState>();
    String? titleError;
    String? subjectError;
    String? dateError;

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final colorScheme = Theme.of(context).colorScheme;
            
            // Validation functions
            String? validateTitle(String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Task title is required';
              }
              if (value.trim().length < 3) {
                return 'Title must be at least 3 characters';
              }
              if (value.length > 100) {
                return 'Title must be less than 100 characters';
              }
              return null;
            }

            String? validateSubject(String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Subject is required';
              }
              if (value.trim().length < 3) {
                return 'Subject must be at least 3 characters';
              }
              if (value.length > 200) {
                return 'Subject must be less than 200 characters';
              }
              return null;
            }

            String? validateDate(DateTime date) {
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final selectedDate = DateTime(date.year, date.month, date.day);
              
              if (selectedDate.isBefore(today)) {
                return 'Due date cannot be in the past';
              }
              return null;
            }

            void saveTask() {
              // Clear previous errors
              titleError = null;
              subjectError = null;
              dateError = null;

              // Validate all fields
              bool isValid = true;

              titleError = validateTitle(title);
              if (titleError != null) isValid = false;

              subjectError = validateSubject(subject);
              if (subjectError != null) isValid = false;

              dateError = validateDate(deadline);
              if (dateError != null) isValid = false;

              if (isValid) {
                setState(() {
                  if (isEditing) {
                    mockDetailedTasks[index!] = task.copyWith(
                      title: title.trim(),
                      subject: subject.trim(),
                      priority: priority,
                      status: status,
                      deadline: deadline,
                    );
                  } else {
                    mockDetailedTasks.insert(
                      0,
                      DetailedTask(
                        title: title.trim(),
                        subject: subject.trim(),
                        deadline: deadline,
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
                // Show success dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
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
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isEditing ? 'Task Updated!' : 'Task Added!',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isEditing 
                            ? 'Your task has been updated successfully.'
                            : 'Your new task has been added successfully.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
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
              } else {
                setStateDialog(() {});
              }
            }

            void confirmDelete() {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, 
                        color: Colors.red, 
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text('Delete Task?'),
                    ],
                  ),
                  content: Text(
                    'Are you sure you want to delete this task? This action cannot be undone.',
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteTask(index!, showFeedback: false);
                        // Show delete confirmation
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Task Deleted',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'The task has been deleted successfully.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
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
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with gradient
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary.withOpacity(0.1),
                            colorScheme.secondary.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
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
                              color: colorScheme.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isEditing ? Icons.edit : Icons.add_task,
                              color: colorScheme.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              isEditing ? 'Edit Task' : 'Add New Task',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Form content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Task Title Field
                              TextFormField(
                                initialValue: title,
                                decoration: InputDecoration(
                                  labelText: 'Task Title *',
                                  hintText: 'Enter task title (3-100 characters)',
                                  errorText: titleError,
                                  errorMaxLines: 2,
                                  prefixIcon: const Icon(Icons.title),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: colorScheme.surfaceContainerHighest,
                                ),
                                maxLength: 100,
                                textInputAction: TextInputAction.next,
                                onChanged: (value) {
                                  title = value;
                                  if (titleError != null) {
                                    titleError = validateTitle(value);
                                    setStateDialog(() {});
                                  }
                                },
                                validator: validateTitle,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                              ),
                              const SizedBox(height: 16),
                              // Subject Field
                              TextFormField(
                                initialValue: subject,
                                decoration: InputDecoration(
                                  labelText: 'Subject *',
                                  hintText: 'Enter subject (3-200 characters)',
                                  errorText: subjectError,
                                  errorMaxLines: 2,
                                  prefixIcon: const Icon(Icons.subject),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: colorScheme.surfaceContainerHighest,
                                ),
                                maxLength: 200,
                                textInputAction: TextInputAction.done,
                                maxLines: 2,
                                onChanged: (value) {
                                  subject = value;
                                  if (subjectError != null) {
                                    subjectError = validateSubject(value);
                                    setStateDialog(() {});
                                  }
                                },
                                validator: validateSubject,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                              ),
                              const SizedBox(height: 20),
                              // Date Picker
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: colorScheme.outline.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: colorScheme.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      "Due Date:",
                                      style: TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    const Spacer(),
                                    TextButton.icon(
                                      onPressed: () async {
                                        final DateTime? picked = await showDatePicker(
                                          context: context,
                                          initialDate: deadline,
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime(2030),
                                        );
                                        if (picked != null) {
                                          setStateDialog(() {
                                            deadline = picked;
                                            dateError = validateDate(picked);
                                          });
                                        }
                                      },
                                      icon: Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: colorScheme.primary,
                                      ),
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
                              if (dateError != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 12, top: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        size: 16,
                                        color: colorScheme.error,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          dateError!,
                                          style: TextStyle(
                                            color: colorScheme.error,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 20),
                              // Priority Dropdown
                              DropdownButtonFormField<String>(
                                value: priority,
                                decoration: InputDecoration(
                                  labelText: 'Priority',
                                  prefixIcon: const Icon(Icons.flag),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: colorScheme.surfaceContainerHighest,
                                ),
                                items: ['High Priority', 'Medium Priority', 'Low Priority']
                                    .map(
                                      (p) => DropdownMenuItem(
                                        value: p,
                                        child: Text(p),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) =>
                                    setStateDialog(() => priority = value!),
                              ),
                              const SizedBox(height: 16),
                              // Status Dropdown
                              DropdownButtonFormField<String>(
                                value: status,
                                decoration: InputDecoration(
                                  labelText: 'Status',
                                  prefixIcon: const Icon(Icons.info_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: colorScheme.surfaceContainerHighest,
                                ),
                                items: ['Not Started', 'In Progress', 'Completed', 'Overdue']
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) =>
                                    setStateDialog(() => status = value!),
                              ),
                              const SizedBox(height: 16),
                              // Required fields note
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '* Required fields',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Action buttons
                    Container(
                      padding: const EdgeInsets.all(20),
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
                          if (isEditing)
                            TextButton.icon(
                              onPressed: confirmDelete,
                              icon: const Icon(Icons.delete_outline, size: 18),
                              label: const Text('Delete'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          if (isEditing) const SizedBox(width: 8),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: saveTask,
                            icon: Icon(
                              isEditing ? Icons.save : Icons.add,
                              size: 18,
                            ),
                            label: Text(isEditing ? 'Save' : 'Add'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
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
          },
        );
      },
    );
  }

  void _confirmEditTask(DetailedTask task, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.edit_note,
              color: colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Edit Task?'),
          ],
        ),
        content: Text(
          'Are you sure you want to edit this task?',
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: colorScheme.primary),
            ),
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
                  _confirmEditTask(task, index);
                },
                onLongPress: () {
                  _confirmEditTask(task, index);
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
