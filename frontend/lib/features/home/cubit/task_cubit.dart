import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todonodejs/core/utils.dart';
import 'package:todonodejs/features/home/repository/task_local_repository.dart';
import 'package:todonodejs/features/home/repository/task_remote_repository.dart';
import 'package:todonodejs/models/task_model.dart';

part 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  TaskCubit() : super(TaskInitial());
  final TaskRemoteRepository _taskRemoteRepository = TaskRemoteRepository();
  final TaskLocalRepository _taskLocalRepository = TaskLocalRepository();

  Future<void> createNewTask({
    required String title,
    required String description,
    required Color color,
    required String uid,
    required String token,
    required DateTime dueAt,
  }) async {
    try {
      emit(TaskLoading());
      final hexColor = rgbToHex(color);
      print(
        'title: $title, description: $description, hexColor: $hexColor, dueAt: $dueAt, token: $token',
      );
      final task = await _taskRemoteRepository.createTask(
        title: title,
        description: description,
        hexColor: hexColor,
        uid: uid,
        token: token,
        dueAt: dueAt,
      );
      await _taskLocalRepository.insertTask(task);
      print('Created Task: $task');
      emit(TaskSuccess(task));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> getAllTasks({required String token}) async {
    emit(TaskLoading());
    try {
      final tasks = await _taskRemoteRepository.getAllTasks(token: token);
      emit(GetTasksSuccess(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> syncTasks({required String token}) async {
    //get all unsynced tasks from local db

    final unsyncedTasks = await _taskLocalRepository.getUnsyncedTasks();
    if (unsyncedTasks.isEmpty) {
      print('No unsynced tasks to sync.');
      return;
    }
    //sync them with backend
    final isSynced = await _taskRemoteRepository.syncTasks(
      token: token,
      tasks: unsyncedTasks,
    );

    //update their isSynced status in local db
    if (isSynced) {
      for (final task in unsyncedTasks) {
        final syncedTask = task.copyWith(isSynced: 1);
        await _taskLocalRepository.updateTask(syncedTask);
      }
    }
  }
}
