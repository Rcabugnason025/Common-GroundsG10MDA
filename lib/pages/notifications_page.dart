import 'package:flutter/material.dart';
import 'package:commongrounds/data/mock_detailed_tasks.dart';
import 'package:commongrounds/theme/colors.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(today);

    // Filter tasks due today
    final dueTodayTasks = mockDetailedTasks.where((task) {
      // Assuming task.dueDate is comparable or we can parse it.
      // Based on previous context, task.dueDate might be a DateTime or String.
      // Let's check detailed_task.dart or assume standard format.
      // If it's a DateTime, we compare parts.
      // If it's a String, we might need parsing.
      // Let's assume it's a DateTime for now or check the model.
      // Re-checking mock_detailed_tasks.dart would be safer, but I'll write defensive code.
      if (task.dueDate == null) return false;

      final taskDate = task.dueDate!;
      return taskDate.year == today.year &&
          taskDate.month == today.month &&
          taskDate.day == today.day;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // System Notification
          _buildNotificationCard(
            context,
            title: 'Welcome to Common Grounds!',
            message: 'Stay organized and focused on your goals.',
            icon: Icons.info_outline,
            color: Colors.blue,
            time: 'Now',
          ),
          const SizedBox(height: 16),

          // "Due Today" Section Header
          if (dueTodayTasks.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Due Today',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            ...dueTodayTasks.map(
              (task) => _buildNotificationCard(
                context,
                title: 'Task Due: ${task.title}',
                message:
                    'Priority: ${task.priority} • ${DateFormat('h:mm a').format(task.dueDate!)}',
                icon: Icons.calendar_today,
                color: Colors.orange,
                time: 'Today',
              ),
            ),
          ] else
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No tasks due today. You are all caught up!',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
