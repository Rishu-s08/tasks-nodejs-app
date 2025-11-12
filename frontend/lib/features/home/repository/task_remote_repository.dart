import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:todonodejs/core/constants/paths.dart';
import 'package:todonodejs/core/utils.dart';
import 'package:todonodejs/features/home/repository/task_local_repository.dart';
import 'package:todonodejs/models/task_model.dart';
import 'package:uuid/uuid.dart';

class TaskRemoteRepository {
  final TaskLocalRepository _taskLocalRepository = TaskLocalRepository();
  Future<TaskModel> createTask({
    required String title,
    required String description,
    required String hexColor,
    required String token,
    required String uid,
    required DateTime dueAt,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(Paths.createTaskEndpoint),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: jsonEncode({
          "title": title,
          "description": description,
          "hexColor": hexColor,
          "dueAt": dueAt.toIso8601String(),
        }),
      );
      if (res.statusCode != 201) {
        throw jsonDecode(res.body);
      }
      return TaskModel.fromJson(res.body);
    } catch (e) {
      try {
        final task = TaskModel(
          id: const Uuid().v4(),
          uid: uid,
          title: title,
          description: description,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          dueAt: dueAt,
          color: hexToRgb(hexColor),
          isSynced: 0,
        );
        await _taskLocalRepository.insertTask(task);
        return task;
      } catch (e) {
        rethrow;
      }
    }
  }

  Future<List<TaskModel>> getAllTasks({required String token}) async {
    try {
      final res = await http.get(
        Uri.parse(Paths.fetchTasksEndpoint),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );
      if (res.statusCode != 200) {
        throw jsonDecode(res.body);
      }
      final List<dynamic> tasksJson = jsonDecode(res.body);
      if (tasksJson.isEmpty) {
        throw Exception('No tasks found');
      }
      final List<TaskModel> tasksList = [];
      for (var taskJson in tasksJson) {
        tasksList.add(TaskModel.fromMap(taskJson));
      }

      await _taskLocalRepository.insertTasks(tasksList);

      return tasksList;
    } catch (e) {
      final tasks = await _taskLocalRepository.getTask();
      if (tasks.isNotEmpty) {
        return tasks;
      }
      rethrow;
    }
  }

  Future<bool> syncTasks({
    required String token,
    required List<TaskModel> tasks,
  }) async {
    try {
      final taskListInMap = [];
      {
        for (final task in tasks) {
          taskListInMap.add(task.toMap());
        }
      }
      final res = await http.post(
        Uri.parse(Paths.syncTasksEndpoint),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: jsonEncode(taskListInMap),
      );
      if (res.statusCode != 201) {
        throw jsonDecode(res.body);
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
