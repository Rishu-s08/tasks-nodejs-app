import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todonodejs/core/utils.dart';
import 'package:todonodejs/features/auth/cubit/auth_cubit.dart';
import 'package:todonodejs/features/home/cubit/task_cubit.dart';
import 'package:todonodejs/features/home/pages/add_new_task_page.dart';
import 'package:todonodejs/features/home/widgets/card_widget.dart';
import 'package:todonodejs/features/home/widgets/date_selector.dart';
import 'package:todonodejs/models/task_model.dart';
import 'package:workmanager/workmanager.dart';

class HomePage extends StatefulWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const HomePage());
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().state as AuthLoggedIn;
    context.read<TaskCubit>().getAllTasks(token: user.user.token);
    Connectivity().onConnectivityChanged.listen((data) async {
      if (data.contains(ConnectivityResult.wifi) ||
          data.contains(ConnectivityResult.mobile)) {
        await context.read<TaskCubit>().syncTasks(token: user.user.token);
        print('Network connected - synced tasks');
      }
    });

    Workmanager().registerPeriodicTask(
      'syncTasksBackground',
      'syncTasks',
      frequency: const Duration(hours: 24),
      inputData: {'token': user.user.token},
    );
  }

  List<TaskModel> _filterTasksByDate(List<TaskModel> allTasks) {
    final filtered = allTasks.where((task) {
      final taskDate = DateFormat('d').format(task.dueAt);
      final selectedDay = DateFormat('d').format(selectedDate);
      final match =
          taskDate == selectedDay &&
          selectedDate.month == task.dueAt.month &&
          selectedDate.year == task.dueAt.year;
      return match;
    }).toList();
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(context, AddNewTaskPage().route());
              // Refresh tasks when coming back from add page
              if (mounted) {
                final user = context.read<AuthCubit>().state as AuthLoggedIn;
                context.read<TaskCubit>().getAllTasks(token: user.user.token);
              }
            },
            icon: Icon(CupertinoIcons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date picker - always visible
          BlocBuilder<TaskCubit, TaskState>(
            builder: (context, state) {
              return DateSelector(
                selectedDate: selectedDate,
                onTap: (date) {
                  print(
                    'Date selected: ${DateFormat('MMM d, y').format(date)}',
                  );
                  setState(() {
                    selectedDate = date;
                  });
                },
              );
            },
          ),

          // Task list - filtered by selected date
          Expanded(
            child: BlocBuilder<TaskCubit, TaskState>(
              key: ValueKey(selectedDate.toString()),
              builder: (context, state) {
                if (state is TaskLoading) {
                  return Center(child: CircularProgressIndicator());
                }
                if (state is TaskError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                if (state is GetTasksSuccess) {
                  final tasks = _filterTasksByDate(state.tasks);
                  print(
                    'Filtered tasks for ${DateFormat('MMM d, y').format(selectedDate)}: ${tasks.length}',
                  );

                  if (tasks.isEmpty) {
                    return Center(child: Text('No tasks for this date'));
                  }

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          Expanded(
                            child: CardWidget(
                              color: tasks[index].color,
                              title: tasks[index].title,
                              description: tasks[index].description,
                            ),
                          ),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: strengthColor(tasks[index].color, 0.69),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Text(
                              DateFormat.jm().format(tasks[index].dueAt),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
                return Center(
                  child: Text('No tasks found. Add a new task to get started!'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
