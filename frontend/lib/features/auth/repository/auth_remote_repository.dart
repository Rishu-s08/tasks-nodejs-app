import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:todonodejs/core/constants/paths.dart';
import 'package:todonodejs/core/services/sp_service.dart';
import 'package:todonodejs/features/auth/repository/auth_local_repository.dart';
import 'package:todonodejs/models/user_model.dart';

class AuthRemoteRepository {
  final SpService _spService = SpService();
  final AuthLocalRepository _authLocalRepository = AuthLocalRepository();

  Future<UserModel> signIn(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse(Paths.signInEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw jsonDecode(res.body)['message'];
      }
      return UserModel.fromJson(res.body);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(Paths.signUpEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'name': name}),
      );

      if (res.statusCode != 201 && res.statusCode != 200) {
        throw jsonDecode(res.body)['message'];
      }
      return UserModel.fromJson(res.body);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserModel?> getUserData() async {
    try {
      final token = await _spService.getToken();

      if (token == null) {
        return null;
      }
      final res = await http.get(
        Uri.parse(Paths.tokenIsValidEndpoint),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );
      if (res.statusCode != 200 && res.statusCode != 201) {
        return null;
      }

      final isValid = jsonDecode(res.body);
      if (isValid == false || isValid == 'false') {
        return null;
      }

      final userData = await http.get(
        Uri.parse('${Paths.backendBaseUrl}/auth'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );
      if (userData.statusCode != 200 && userData.statusCode != 201) {
        throw jsonDecode(userData.body)['message'];
      }

      return UserModel.fromJson(userData.body);
    } catch (e) {
      final user = await _authLocalRepository.getUser();
      return user;
    }
  }
}
