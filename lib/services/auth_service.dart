import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _isLoggedKey = 'is_logged_in';
  
  // Credenciales por defecto para tu exposición
  final String _adminUser = 'admin';
  final String _adminPass = '123456';

  Future<bool> login(String user, String pass) async {
    if (user == _adminUser && pass == _adminPass) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedKey, true);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedKey, false);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedKey) ?? false;
  }
}