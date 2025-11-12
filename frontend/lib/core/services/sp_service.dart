import 'package:shared_preferences/shared_preferences.dart';

class SpService {
  void setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('x-auth-token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('x-auth-token');
  }
}
