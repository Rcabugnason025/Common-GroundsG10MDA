import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class TaskDb {
  static final TaskDb instance = TaskDb._internal();
  TaskDb._internal();

  Database? _db;

  Future<Database> get db async {
    final existing = _db;
    if (existing != null) return existing;
    final created = await _open();
    _db = created;
    return created;
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, 'commongrounds.db');
    return openDatabase(
      path,
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
    );
  }
}
