import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:commongrounds/data/mock_detailed_tasks.dart';
import 'package:commongrounds/model/detailed_task.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Focus. Plan. Achieve',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: sortedDates.isEmpty
          ? const Center(child: Text("No upcoming deadlines"))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: sortedDates.length,
              itemBuilder: (context, index) {
                final dateKey = sortedDates[index];
                final tasks = tasksByDate[dateKey]!;
                final date = DateTime.parse(dateKey);
                final dateLabel = DateFormat('EEEE, MMMM d, y').format(date);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        dateLabel,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    ...tasks.map((task) => TaskCard(task: task)),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final DetailedTask task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (task.status) {
      case 'Completed':
        statusColor = Colors.green;
        break;
      case 'In Progress':
        statusColor = Colors.orange;
        break;
      case 'Overdue':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(task.subject, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('h:mm a').format(task.deadline),
                  style: const TextStyle(color: Colors.black54),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
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
    );
  }
}
