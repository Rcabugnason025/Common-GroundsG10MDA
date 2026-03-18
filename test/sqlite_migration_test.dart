import 'dart:convert';
import 'dart:io';

import 'package:commongrounds/data/local/task_db.dart';
import 'package:commongrounds/data/repositories/sqlite_task_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  test('Migrates v1 tasks table to v2 normalized schema', () async {
    final tempDir = Directory.systemTemp.createTempSync('commongrounds_mig_');
    final dbPath = p.join(tempDir.path, 'commongrounds_mig.db');

    final v1 = await databaseFactoryFfi.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
CREATE TABLE tasks(
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  subject TEXT NOT NULL,
  description TEXT,
  deadline TEXT NOT NULL,
  priority TEXT NOT NULL,
  status TEXT NOT NULL,
  progress REAL NOT NULL,
  category TEXT NOT NULL
)
''');
        },
      ),
    );

    await v1.insert('tasks', {
      'id': 't_steps',
      'title': 'Milestone',
      'subject': 'Mobile Dev',
      'description': jsonEncode([
        {'step': 1, 'name': 'Plan', 'details': 'Break it down'},
        {'step': 2, 'name': 'Build', 'details': 'Implement it'},
      ]),
      'deadline': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
      'priority': 'High Priority',
      'status': 'In Progress',
      'progress': 0.4,
      'category': 'Project',
    });

    await v1.insert('tasks', {
      'id': 't_simple',
      'title': 'Read',
      'subject': 'OOP',
      'description': 'Read the chapter',
      'deadline': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      'priority': 'Low Priority',
      'status': 'Not Started',
      'progress': 0.0,
      'category': 'Homework',
    });

    await v1.close();

    TaskDb.useForTesting(
      TaskDb.forTesting(databaseFactory: databaseFactoryFfi, path: dbPath),
    );
    await TaskDb.instance.db;

    final repo = SqliteTaskRepository();
    final tasks = await repo.fetchTasks();
    expect(tasks.length, 2);

    final withSteps = tasks.singleWhere((t) => t.id == 't_steps');
    expect(withSteps.detailedSteps, isNotNull);
    expect(withSteps.detailedSteps!.length, 2);
    expect(withSteps.simpleDescription, isNull);
    expect(withSteps.category, 'Project');

    final simple = tasks.singleWhere((t) => t.id == 't_simple');
    expect(simple.detailedSteps, isNull);
    expect(simple.simpleDescription, isNotNull);
    expect(simple.category, 'Homework');

    await TaskDb.instance.close();
    await tempDir.delete(recursive: true);
  });
}

