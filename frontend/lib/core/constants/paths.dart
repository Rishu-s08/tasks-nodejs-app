class Paths {
  static const String backendBaseUrl = 'https://tasks-nodejs-app.onrender.com';

  static String get signUpEndpoint => '$backendBaseUrl/auth/signup';
  static String get signInEndpoint => '$backendBaseUrl/auth/login';
  static String get tokenIsValidEndpoint => '$backendBaseUrl/auth/tokenIsValid';
  static String get createTaskEndpoint => '$backendBaseUrl/task/add';
  static String get syncTasksEndpoint => '$backendBaseUrl/task/sync';
  static String get fetchTasksEndpoint => '$backendBaseUrl/task';
  static String get deleteTaskEndpoint => '$backendBaseUrl/task/delete';
}
