import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:commongrounds/theme/colors.dart';
import 'package:commongrounds/data/mock_detailed_tasks.dart';
import 'package:commongrounds/model/detailed_task.dart';
import 'package:commongrounds/widgets/task_edit_dialog.dart';
import 'package:commongrounds/widgets/task_delete_dialog.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  void _openEditDialog(DetailedTask task, int index) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => TaskEditDialog(
        task: task,
        index: index,
        onSave: (updatedTask) {
          setState(() {
            mockDetailedTasks[index] = updatedTask;
          });
        },
        onDelete: () => _confirmDelete(index),
      ),
    );
  }

  Future<void> _confirmDelete(int index) async {
    final shouldDelete = await TaskDeleteDialog.show(context);
    if (shouldDelete) {
      setState(() {
        mockDetailedTasks.removeAt(index);
      });
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

    // Group tasks by date
    final Map<String, List<DetailedTask>> tasksByDate = {};
    for (var task in mockDetailedTasks) {
      final dateKey = DateFormat('yyyy-MM-dd').format(task.deadline);
      if (tasksByDate[dateKey] == null) {
        tasksByDate[dateKey] = [];
      }
      tasksByDate[dateKey]!.add(task);
    }

    final sortedDates = tasksByDate.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading:
            (ModalRoute.of(context)?.settings.arguments is Map &&
                (ModalRoute.of(context)?.settings.arguments
                        as Map)['showBackButton'] ==
                    true)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          "Calendar",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Slogan Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFE8EAF6),
            child: const Text(
              'Focus. Plan. Achieve',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Tasks List
          Expanded(
            child: sortedDates.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 64,
                          color: colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No upcoming deadlines',
                          style: TextStyle(
                            fontSize: 18,
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: sortedDates.length,
                    itemBuilder: (context, index) {
                      final dateKey = sortedDates[index];
                      final tasks = tasksByDate[dateKey]!;
                      final date = DateTime.parse(dateKey);
                      final dateLabel = DateFormat(
                        'EEEE, MMMM d, y',
                      ).format(date);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              top: index == 0 ? 0 : 24,
                              bottom: 12,
                              left: 4,
                            ),
                            child: Text(
                              dateLabel,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6A1B9A),
                              ),
                            ),
                          ),
                          ...tasks.asMap().entries.map((entry) {
                            final task = entry.value;
                            // Find the actual index in mockDetailedTasks
                            final actualIndex = mockDetailedTasks.indexOf(task);
                            return TaskCard(
                              task: task,
                              index: actualIndex >= 0 ? actualIndex : 0,
                            );
                          }),
                          if (index == sortedDates.length - 1)
                            const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final DetailedTask task;
  final int index;

  const TaskCard({super.key, required this.task, required this.index});

  void _showTaskDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                          Theme.of(
                            context,
                          ).colorScheme.secondary.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            task.icon,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                task.subject,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: controller,
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildDetailRow(
                          context,
                          Icons.flag,
                          'Priority',
                          task.priority,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          context,
                          Icons.info_outline,
                          'Status',
                          task.status,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          context,
                          Icons.calendar_today,
                          'Deadline',
                          DateFormat(
                            'EEEE, MMMM d, y • h:mm a',
                          ).format(task.deadline),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          context,
                          Icons.category,
                          'Category',
                          task.category,
                        ),
                        const SizedBox(height: 24),
                        if (task.simpleDescription != null) ...[
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            task.simpleDescription!,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Directly open edit dialog
                        final calendarState = context
                            .findAncestorStateOfType<_CalendarPageState>();
                        if (calendarState != null) {
                          calendarState._openEditDialog(task, index);
                        }
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Task'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBgColor;
    switch (task.status) {
      case 'Completed':
        statusColor = const Color(0xFF4CAF50);
        statusBgColor = const Color(0xFFE8F5E9);
        break;
      case 'In Progress':
        statusColor = const Color(0xFFFF9800);
        statusBgColor = const Color(0xFFFFF3E0);
        break;
      case 'Overdue':
        statusColor = const Color(0xFFE53935);
        statusBgColor = const Color(0xFFFFEBEE);
        break;
      default:
        statusColor = const Color(0xFF9E9E9E);
        statusBgColor = const Color(0xFFF5F5F5);
    }

    return InkWell(
      onTap: () => _showTaskDetails(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE1BEE7).withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFCE93D8).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Title
              Text(
                task.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Subject
              Text(
                task.subject,
                style: TextStyle(
                  color: Colors.black87.withOpacity(0.7),
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Deadline and Status Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Deadline Time
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.black87.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('h:mm a').format(task.deadline),
                        style: TextStyle(
                          color: Colors.black87.withOpacity(0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // Status Badge
                  Container(
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 14,
                    ),
                    child: Text(
                      task.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
