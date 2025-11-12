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
    try {
      emit(AuthLoading());
      await _authRemoteRepository.signUp(
        email: email,
        password: password,
        name: name,
      );
      emit(AuthSignUp());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  void logIn({required String email, required String password}) async {
    try {
      emit(AuthLoading());
      final user = await _authRemoteRepository.signIn(email, password);

      if (user.token.isNotEmpty) {
        _spService.setToken(user.token);
      }

      await _authLocalRepository.insertUser(user);

      emit(AuthLoggedIn(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  void getUserData() async {
    try {
      emit(AuthLoading());
      final user = await _authRemoteRepository.getUserData();

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
