import 'dart:io';

class Paths {
  // Use 10.0.2.2 for Android emulator, localhost for iOS simulator
  // For physical device, replace with your computer's IP address
  static String get backendBaseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000'; // Android emulator
    } else {
      return 'http://localhost:3000'; // iOS simulator or other platforms
    }
  }

  static String get signUpEndpoint => '$backendBaseUrl/auth/signup';
  static String get signInEndpoint => '$backendBaseUrl/auth/login';
  static String get tokenIsValidEndpoint => '$backendBaseUrl/auth/tokenIsValid';
  static String get createTaskEndpoint => '$backendBaseUrl/task/add';
  static String get syncTasksEndpoint => '$backendBaseUrl/task/sync';
  static String get fetchTasksEndpoint => '$backendBaseUrl/task';
  static String get deleteTaskEndpoint => '$backendBaseUrl/task/delete';
}
