import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class TaskDb {
  static TaskDb instance = TaskDb._internal();
  TaskDb._internal() : _databaseFactory = databaseFactory, _customPath = null;

  TaskDb._testing({
    required DatabaseFactory databaseFactory,
    required String path,
  }) : _databaseFactory = databaseFactory,
       _customPath = path;

  Database? _db;
  final DatabaseFactory _databaseFactory;
  final String? _customPath;

  static void useForTesting(TaskDb db) {
    instance = db;
  }

  static TaskDb forTesting({
    required DatabaseFactory databaseFactory,
    required String path,
  }) {
    return TaskDb._testing(databaseFactory: databaseFactory, path: path);
  }

  Future<Database> get db async {
    final existing = _db;
    if (existing != null) return existing;
    final created = await _open();
    _db = created;
    return created;
  }

  Future<void> close() async {
    final existing = _db;
    _db = null;
    if (existing != null) {
      await existing.close();
    }
  }

  Future<Database> _open() async {
    final path =
        _customPath ?? p.join(await getDatabasesPath(), 'commongrounds.db');
    return _databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (db, version) async {
          await db.execute('''
CREATE TABLE categories(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE
)
''');
          await db.execute('''
CREATE TABLE tasks(
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  subject TEXT NOT NULL,
  simple_description TEXT,
  deadline_ms INTEGER NOT NULL,
  priority INTEGER NOT NULL,
  status INTEGER NOT NULL,
  progress REAL NOT NULL,
  category_id INTEGER NOT NULL,
  icon_codepoint INTEGER NOT NULL,
  FOREIGN KEY(category_id) REFERENCES categories(id) ON DELETE RESTRICT
)
''');
          await db.execute('''
CREATE TABLE task_steps(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task_id TEXT NOT NULL,
  step_no INTEGER,
  name TEXT,
  phase TEXT,
  details TEXT NOT NULL,
  order_index INTEGER NOT NULL,
  FOREIGN KEY(task_id) REFERENCES tasks(id) ON DELETE CASCADE
)
''');
          await db.execute(
            'CREATE INDEX idx_tasks_deadline_ms ON tasks(deadline_ms)',
          );
          await db.execute(
            'CREATE INDEX idx_task_steps_task_id_order ON task_steps(task_id, order_index)',
          );

          await db.insert('categories', {'name': 'Personal'});
          await db.insert('categories', {'name': 'Homework'});
          await db.insert('categories', {'name': 'Work'});
          await db.insert('categories', {'name': 'Project'});
          await db.insert('categories', {'name': 'Other'});
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion >= 2) return;
          await db.execute('PRAGMA foreign_keys = OFF');

          await db.execute('ALTER TABLE tasks RENAME TO tasks_v1');

          await db.execute('''
CREATE TABLE categories(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE
)
''');
          await db.execute('''
CREATE TABLE tasks(
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  subject TEXT NOT NULL,
  simple_description TEXT,
  deadline_ms INTEGER NOT NULL,
  priority INTEGER NOT NULL,
  status INTEGER NOT NULL,
  progress REAL NOT NULL,
  category_id INTEGER NOT NULL,
  icon_codepoint INTEGER NOT NULL,
  FOREIGN KEY(category_id) REFERENCES categories(id) ON DELETE RESTRICT
)
''');
          await db.execute('''
CREATE TABLE task_steps(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task_id TEXT NOT NULL,
  step_no INTEGER,
  name TEXT,
  phase TEXT,
  details TEXT NOT NULL,
  order_index INTEGER NOT NULL,
  FOREIGN KEY(task_id) REFERENCES tasks(id) ON DELETE CASCADE
)
''');
          await db.execute(
            'CREATE INDEX idx_tasks_deadline_ms ON tasks(deadline_ms)',
          );
          await db.execute(
            'CREATE INDEX idx_task_steps_task_id_order ON task_steps(task_id, order_index)',
          );

          Future<int> ensureCategoryId(String name) async {
            final existing = await db.query(
              'categories',
              where: 'name = ?',
              whereArgs: [name],
              limit: 1,
            );
            if (existing.isNotEmpty) {
              return (existing.first['id'] as int?) ?? 1;
            }
            return await db.insert('categories', {'name': name});
          }

          int priorityToInt(String p) {
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

          int statusToInt(String s) {
            switch (s) {
              case 'Completed':
                return 2;
              case 'Overdue':
                return 3;
              case 'In Progress':
                return 1;
              case 'Not Started':
              default:
                return 0;
            }
          }

          final oldRows = await db.query('tasks_v1');
          for (final row in oldRows) {
            final id = row['id']?.toString();
            final categoryName = row['category']?.toString() ?? 'Personal';
            final categoryId = await ensureCategoryId(categoryName);

            final deadlineStr = row['deadline']?.toString();
            final deadlineMs = deadlineStr == null
                ? DateTime.now().millisecondsSinceEpoch
                : DateTime.tryParse(deadlineStr)?.millisecondsSinceEpoch ??
                      DateTime.now().millisecondsSinceEpoch;

            final progressRaw = row['progress'];
            final progress = progressRaw is int
                ? progressRaw.toDouble()
                : (progressRaw as num?)?.toDouble() ?? 0.0;

            final descriptionRaw = row['description']?.toString();
            dynamic descriptionDecoded;
            if (descriptionRaw != null && descriptionRaw.isNotEmpty) {
              try {
                descriptionDecoded = jsonDecode(descriptionRaw);
              } catch (_) {
                descriptionDecoded = descriptionRaw;
              }
            }

            String? simpleDescription;
            if (descriptionDecoded is String && descriptionDecoded.isNotEmpty) {
              simpleDescription = descriptionDecoded;
            }

            await db.insert('tasks', {
              'id': id,
              'title': row['title']?.toString() ?? '',
              'subject': row['subject']?.toString() ?? '',
              'simple_description': simpleDescription,
              'deadline_ms': deadlineMs,
              'priority': priorityToInt(
                row['priority']?.toString() ?? 'Medium Priority',
              ),
              'status': statusToInt(row['status']?.toString() ?? 'Not Started'),
              'progress': progress,
              'category_id': categoryId,
              'icon_codepoint': 0xe0b3,
            });

            if (id != null && descriptionDecoded is List) {
              var orderIndex = 0;
              for (final stepAny in descriptionDecoded) {
                if (stepAny is! Map) continue;
                final m = Map<String, dynamic>.from(stepAny);
                await db.insert('task_steps', {
                  'task_id': id,
                  'step_no': m['step'] is int ? m['step'] : null,
                  'name': m['name']?.toString(),
                  'phase': m['phase']?.toString(),
                  'details': m['details']?.toString() ?? '',
                  'order_index': orderIndex,
                });
                orderIndex++;
              }
            }
          }

          await db.execute('DROP TABLE tasks_v1');
          await db.execute('PRAGMA foreign_keys = ON');
        },
      ),
    );
  }
}
