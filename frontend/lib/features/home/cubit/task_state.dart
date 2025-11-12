part of 'task_cubit.dart';

sealed class TaskState {
  const TaskState();
}

final class TaskInitial extends TaskState {}

final class TaskLoading extends TaskState {}

final class TaskSuccess extends TaskState {
  final TaskModel task;
  const TaskSuccess(this.task);
}

final class TaskError extends TaskState {
  final String? message;
  const TaskError([this.message]);
}

final class GetTasksSuccess extends TaskState {
  final List<TaskModel> tasks;
  const GetTasksSuccess(this.tasks);
}
