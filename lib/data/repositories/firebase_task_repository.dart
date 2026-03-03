import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:commongrounds/model/detailed_task.dart';
import 'package:commongrounds/data/repositories/task_repository.dart';

class FirebaseTaskRepository implements TaskRepository {
  final _col = FirebaseFirestore.instance.collection('tasks');

  @override
  Future<List<DetailedTask>> fetchTasks() async {
    final snap = await _col.orderBy('deadline', descending: false).get();
    return snap.docs.map((d) {
      final map = d.data();
      map['id'] = d.id;
      return DetailedTask.fromJson(map);
    }).toList();
  }

  @override
  Future<DetailedTask> createTask(DetailedTask task) async {
    final map = task.toJson();
    map.remove('id');
    final ref = await _col.add(map);
    return task.copyWith(id: ref.id);
    }

  @override
  Future<void> updateTask(DetailedTask task) async {
    if (task.id == null) return;
    final map = task.toJson();
    map.remove('id');
    await _col.doc(task.id).set(map);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _col.doc(id).delete();
  }
}
