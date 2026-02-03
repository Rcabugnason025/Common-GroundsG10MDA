import 'package:flutter/material.dart';
import 'package:commongrounds/model/detailed_task.dart';

class TaskListPage extends StatelessWidget {
  final String title;
  final List<DetailedTask> tasks;

  const TaskListPage({
    super.key,
    required this.title,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: tasks.isEmpty
          ? Center(child: Text('No tasks found.'))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(task.title),
                    subtitle: Text(task.subject),
                    trailing: Text(task.status),
                  ),
                );
              },
            ),
    );
  }
}
