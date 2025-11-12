import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todonodejs/app_theme.dart';
import 'package:todonodejs/features/auth/cubit/auth_cubit.dart';
import 'package:todonodejs/features/auth/pages/login_page.dart';
import 'package:todonodejs/features/home/cubit/task_cubit.dart';
import 'package:todonodejs/features/home/pages/home_page.dart';
import 'package:todonodejs/features/home/repository/task_remote_repository.dart';
import 'package:todonodejs/features/home/repository/task_local_repository.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final taskRemoteRepository = TaskRemoteRepository();
      final taskLocalRepository = TaskLocalRepository();
      final token = inputData?['token'] as String? ?? '';

      if (token.isNotEmpty) {
        final localTasks = await taskLocalRepository.getUnsyncedTasks();

        if (localTasks.isNotEmpty) {
          final success = await taskRemoteRepository.syncTasks(
            token: token,
            tasks: localTasks,
          );
          return Future.value(success);
        } else {
          return Future.value(true);
        }
      } else {
        return Future.value(false);
      }
    } catch (e) {
      return Future.value(false);
    }
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher);
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()),
        BlocProvider(create: (context) => TaskCubit()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Defer the call to after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().getUserData();
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (state is AuthLoggedIn) {
            return const HomePage();
          }
          return const LoginPage();
        },
      ),
    );
  }
}
