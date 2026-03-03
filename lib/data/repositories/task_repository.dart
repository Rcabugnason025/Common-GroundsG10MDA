import 'package:commongrounds/model/detailed_task.dart';

abstract class TaskRepository {
  Future<List<DetailedTask>> fetchTasks();
  Future<DetailedTask> createTask(DetailedTask task);
  Future<void> updateTask(DetailedTask task);
  Future<void> deleteTask(String id);
}
