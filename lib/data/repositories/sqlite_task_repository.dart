import 'dart:convert';
import 'package:commongrounds/data/local/task_db.dart';
import 'package:commongrounds/data/repositories/task_repository.dart';
import 'package:commongrounds/model/detailed_task.dart';
import 'package:sqflite/sqflite.dart';

class SqliteTaskRepository implements TaskRepository {
  static const _table = 'tasks';

  @override
  Future<List<DetailedTask>> fetchTasks() async {
    final db = await TaskDb.instance.db;
    final rows = await db.query(_table, orderBy: 'deadline ASC');
    return rows.map(_rowToTask).toList();
  }

  @override
  Future<DetailedTask> createTask(DetailedTask task) async {
    final id = task.id ?? DateTime.now().microsecondsSinceEpoch.toString();
    final db = await TaskDb.instance.db;
    await db.insert(
      _table,
      _taskToRow(task.copyWith(id: id)),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return task.copyWith(id: id);
  }

  @override
  Future<void> updateTask(DetailedTask task) async {
    if (task.id == null) return;
    final db = await TaskDb.instance.db;
    await db.update(
      _table,
      _taskToRow(task),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  @override
  Future<void> deleteTask(String id) async {
    final db = await TaskDb.instance.db;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Map<String, Object?> _taskToRow(DetailedTask task) {
    final jsonMap = task.toJson();
    final descriptionValue = jsonMap['description'];
    final descriptionJson = descriptionValue == null
        ? ''
        : jsonEncode(descriptionValue);
    return {
      'id': task.id,
      'title': task.title,
      'subject': task.subject,
      'description': descriptionJson,
      'deadline': task.deadline.toIso8601String(),
      'priority': task.priority,
      'status': task.status,
      'progress': task.progress,
      'category': task.category,
    };
  }

  DetailedTask _rowToTask(Map<String, Object?> row) {
    final descriptionRaw = row['description']?.toString();
    dynamic descriptionDecoded;
    if (descriptionRaw != null && descriptionRaw.isNotEmpty) {
      try {
        descriptionDecoded = jsonDecode(descriptionRaw);
      } catch (_) {
        descriptionDecoded = descriptionRaw;
      }
    }

    final map = <String, dynamic>{
      'id': row['id']?.toString(),
      'title': row['title']?.toString() ?? '',
      'subject': row['subject']?.toString() ?? '',
      'description': descriptionDecoded,
      'deadline':
          row['deadline']?.toString() ?? DateTime.now().toIso8601String(),
      'priority': row['priority']?.toString() ?? 'Medium Priority',
      'status': row['status']?.toString() ?? 'Not Started',
      'progress': row['progress'] is int
          ? (row['progress'] as int).toDouble()
          : (row['progress'] as num?)?.toDouble() ?? 0.0,
      'category': row['category']?.toString() ?? 'Personal',
    };
    return DetailedTask.fromJson(map);
  }
}
