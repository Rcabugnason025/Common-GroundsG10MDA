import 'package:commongrounds/data/local/task_db.dart';
import 'package:commongrounds/data/repositories/task_repository.dart';
import 'package:commongrounds/model/detailed_task.dart';
import 'package:commongrounds/model/task_step.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';

class SqliteTaskRepository implements TaskRepository {
  static const _tasksTable = 'tasks';
  static const _categoriesTable = 'categories';
  static const _stepsTable = 'task_steps';

  @override
  Future<List<DetailedTask>> fetchTasks() async {
    final db = await TaskDb.instance.db;
    final rows = await db.rawQuery('''
SELECT t.*, c.name AS category_name
FROM $_tasksTable t
JOIN $_categoriesTable c ON c.id = t.category_id
ORDER BY t.deadline_ms ASC
''');

    final tasks = <DetailedTask>[];
    for (final rowAny in rows) {
      final row = Map<String, Object?>.from(rowAny);
      final id = row['id']?.toString();
      if (id == null || id.isEmpty) continue;

      final stepRows = await db.query(
        _stepsTable,
        where: 'task_id = ?',
        whereArgs: [id],
        orderBy: 'order_index ASC',
      );
      final steps = stepRows
          .map(
            (r) => TaskStep(
              step: r['step_no'] as int?,
              name: r['name']?.toString(),
              phase: r['phase']?.toString(),
              details: r['details']?.toString() ?? '',
            ),
          )
          .toList();

      final deadlineMs = row['deadline_ms'];
      final deadline = DateTime.fromMillisecondsSinceEpoch(
        (deadlineMs is int)
            ? deadlineMs
            : (deadlineMs as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      );

      final progressRaw = row['progress'];
      final progress = (progressRaw is int)
          ? progressRaw.toDouble()
          : (progressRaw as num?)?.toDouble() ?? 0.0;

      final simpleDescription = row['simple_description']?.toString();

      tasks.add(
        DetailedTask(
          id: id,
          title: row['title']?.toString() ?? '',
          subject: row['subject']?.toString() ?? '',
          detailedSteps: steps.isEmpty ? null : steps,
          simpleDescription: steps.isEmpty
              ? (simpleDescription?.isNotEmpty == true
                  ? simpleDescription
                  : 'New task added by user')
              : null,
          deadline: deadline,
          priority: _priorityFromInt(row['priority']),
          status: _statusFromInt(row['status']),
          progress: progress,
          icon: Icons.assignment,
          category: row['category_name']?.toString() ?? 'Personal',
        ),
      );
    }

    return tasks;
  }

  @override
  Future<DetailedTask> createTask(DetailedTask task) async {
    final id = task.id ?? DateTime.now().microsecondsSinceEpoch.toString();
    final db = await TaskDb.instance.db;

    await db.transaction((txn) async {
      final categoryId = await _ensureCategoryId(txn, task.category);
      await txn.insert(
        _tasksTable,
        _taskToRow(task.copyWith(id: id), categoryId: categoryId),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await _replaceSteps(txn, task.copyWith(id: id));
    });

    return task.copyWith(id: id);
  }

  @override
  Future<void> updateTask(DetailedTask task) async {
    if (task.id == null) return;
    final db = await TaskDb.instance.db;
    await db.transaction((txn) async {
      final categoryId = await _ensureCategoryId(txn, task.category);
      await txn.update(
        _tasksTable,
        _taskToRow(task, categoryId: categoryId),
        where: 'id = ?',
        whereArgs: [task.id],
      );
      await _replaceSteps(txn, task);
    });
  }

  @override
  Future<void> deleteTask(String id) async {
    final db = await TaskDb.instance.db;
    await db.delete(_tasksTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> _replaceSteps(DatabaseExecutor db, DetailedTask task) async {
    final id = task.id;
    if (id == null) return;
    await db.delete(_stepsTable, where: 'task_id = ?', whereArgs: [id]);
    final steps = task.detailedSteps;
    if (steps == null || steps.isEmpty) return;
    var orderIndex = 0;
    for (final s in steps) {
      await db.insert(_stepsTable, {
        'task_id': id,
        'step_no': s.step,
        'name': s.name,
        'phase': s.phase,
        'details': s.details,
        'order_index': orderIndex,
      });
      orderIndex++;
    }
  }

  Map<String, Object?> _taskToRow(
    DetailedTask task, {
    required int categoryId,
  }) {
    return {
      'id': task.id,
      'title': task.title,
      'subject': task.subject,
      'simple_description': task.simpleDescription,
      'deadline_ms': task.deadline.millisecondsSinceEpoch,
      'priority': _priorityToInt(task.priority),
      'status': _statusToInt(task.status),
      'progress': task.progress,
      'category_id': categoryId,
      'icon_codepoint': task.icon.codePoint,
    };
  }

  Future<int> _ensureCategoryId(DatabaseExecutor db, String name) async {
    final existing =
        await db.query(_categoriesTable, where: 'name = ?', whereArgs: [name], limit: 1);
    if (existing.isNotEmpty) {
      return (existing.first['id'] as int?) ?? 1;
    }
    return await db.insert(_categoriesTable, {'name': name});
  }

  int _priorityToInt(String p) {
    switch (p) {
      case 'High Priority':
        return 2;
      case 'Low Priority':
        return 0;
      case 'Medium Priority':
      default:
        return 1;
    }
  }

  String _priorityFromInt(Object? p) {
    final v = (p is int) ? p : (p as num?)?.toInt();
    switch (v) {
      case 2:
        return 'High Priority';
      case 0:
        return 'Low Priority';
      case 1:
      default:
        return 'Medium Priority';
    }
  }

  int _statusToInt(String s) {
    switch (s) {
      case 'In Progress':
        return 1;
      case 'Completed':
        return 2;
      case 'Overdue':
        return 3;
      case 'Not Started':
      default:
        return 0;
    }
  }

  String _statusFromInt(Object? s) {
    final v = (s is int) ? s : (s as num?)?.toInt();
    switch (v) {
      case 1:
        return 'In Progress';
      case 2:
        return 'Completed';
      case 3:
        return 'Overdue';
      case 0:
      default:
        return 'Not Started';
    }
  }
}
