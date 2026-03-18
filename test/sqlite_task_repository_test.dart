import 'dart:io';

import 'package:commongrounds/data/local/task_db.dart';
import 'package:commongrounds/data/repositories/sqlite_task_repository.dart';
import 'package:commongrounds/model/detailed_task.dart';
import 'package:commongrounds/model/task_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  group('SqliteTaskRepository', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('commongrounds_test_');
      final dbPath = p.join(tempDir.path, 'commongrounds_test.db');
      TaskDb.useForTesting(
        TaskDb.forTesting(databaseFactory: databaseFactoryFfi, path: dbPath),
      );
      await TaskDb.instance.db;
    });

    tearDown(() async {
      await TaskDb.instance.close();
      await tempDir.delete(recursive: true);
    });

    test('SQLite CRUD - create, read, update, delete', () async {
      final repo = SqliteTaskRepository();

      final created = await repo.createTask(
        DetailedTask(
          title: 'Study Flutter',
          subject: 'Mobile Development',
          deadline: DateTime.now().add(const Duration(days: 2)),
          priority: 'High Priority',
          status: 'Not Started',
          progress: 0.0,
          icon: Icons.assignment,
          category: 'Homework',
          simpleDescription: 'New task added by user',
        ),
      );

      final list1 = await repo.fetchTasks();
      expect(list1.length, 1);
      expect(list1.first.id, created.id);
      expect(list1.first.category, 'Homework');

      await repo.updateTask(created.copyWith(status: 'Completed', progress: 1.0));
      final list2 = await repo.fetchTasks();
      expect(list2.single.status, 'Completed');
      expect(list2.single.progress, 1.0);

      await repo.deleteTask(created.id!);
      final list3 = await repo.fetchTasks();
      expect(list3, isEmpty);
    });

    test('Stores detailed steps in a separate table and reads them back', () async {
      final repo = SqliteTaskRepository();
      final task = DetailedTask(
        title: 'Milestone 2',
        subject: 'Mobile Dev',
        deadline: DateTime.now().add(const Duration(days: 10)),
        priority: 'Medium Priority',
        status: 'In Progress',
        progress: 0.3,
        icon: Icons.assignment,
        category: 'Project',
        detailedSteps: const [
          TaskStep(step: 1, name: 'Plan', details: 'Break down tasks'),
          TaskStep(step: 2, name: 'Build', details: 'Implement features'),
        ],
      );

      final created = await repo.createTask(task);
      final fetched = (await repo.fetchTasks()).singleWhere((t) => t.id == created.id);
      expect(fetched.detailedSteps, isNotNull);
      expect(fetched.detailedSteps!.length, 2);
      expect(fetched.simpleDescription, isNull);
    });
  });
}

