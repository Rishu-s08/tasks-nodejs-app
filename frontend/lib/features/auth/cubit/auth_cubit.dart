import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todonodejs/core/services/sp_service.dart';
import 'package:todonodejs/features/auth/repository/auth_local_repository.dart';
import 'package:todonodejs/features/auth/repository/auth_remote_repository.dart';
import 'package:todonodejs/models/user_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  final SpService _spService = SpService();
  final AuthRemoteRepository _authRemoteRepository = AuthRemoteRepository();
  final AuthLocalRepository _authLocalRepository = AuthLocalRepository();

  void signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    // Implementation for signing up a user
    try {
      emit(AuthLoading());
      final UserModel user = await _authRemoteRepository.signUp(
        email: email,
        password: password,
        name: name,
      );
      print(user);
      emit(AuthSignUp());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  void logIn({required String email, required String password}) async {
    try {
      emit(AuthLoading());
      print('Starting login...');
      final user = await _authRemoteRepository.signIn(email, password);
      print('User received: $user');
      print('Token: ${user.token}');

      if (user.token.isNotEmpty) {
        _spService.setToken(user.token);
        print('Token saved to SharedPreferences');
      }

      await _authLocalRepository.insertUser(user);
      print('User saved to local DB');

      print('Emitting AuthLoggedIn state');
      emit(AuthLoggedIn(user: user));
      print('AuthLoggedIn state emitted');
    } catch (e) {
      print('Login error: $e');
      emit(AuthError(message: e.toString()));
    }
  }

  void getUserData() async {
    try {
      emit(AuthLoading());
      print('Getting user data');
      final user = await _authRemoteRepository.getUserData();
      print('User data retrieved: $user');

      if (user != null) {
        emit(AuthLoggedIn(user: user));
        return;
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
