import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:commongrounds/model/detailed_task.dart';
import 'package:commongrounds/config/app_config.dart';
import 'package:commongrounds/data/repositories/task_repository.dart';

class RestTaskRepository implements TaskRepository {
  final String baseUrl;
  RestTaskRepository({String? baseUrl}) : baseUrl = baseUrl ?? AppConfig.restBaseUrl;

  Uri _uri(String path, [String? id]) {
    final p = id == null ? path : '$path/$id';
    return Uri.parse('$baseUrl$p');
  }

  @override
  Future<List<DetailedTask>> fetchTasks() async {
    final res = await http.get(_uri('/tasks'));
    if (res.statusCode != 200) {
      return [];
    }
    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => DetailedTask.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  @override
  Future<DetailedTask> createTask(DetailedTask task) async {
    final res = await http.post(
      _uri('/tasks'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      final map = jsonDecode(res.body) as Map<String, dynamic>;
      return DetailedTask.fromJson(map);
    }
    return task;
  }

  @override
  Future<void> updateTask(DetailedTask task) async {
    if (task.id == null) return;
    await http.put(
      _uri('/tasks', task.id),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()),
    );
  }

  @override
  Future<void> deleteTask(String id) async {
    await http.delete(_uri('/tasks', id));
  }
}
