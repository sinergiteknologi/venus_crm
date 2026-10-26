import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/login.dart';

class PrefManager {
  static const String _keyLoginData = 'login_data';
  static const String _keyIsLoggedIn = 'is_logged_in';

  static Future<void> saveLoginData(Login login) async {
    if (!_isValidLogin(login)) {
      throw const FormatException('Invalid login response');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLoginData, jsonEncode(login.toJson()));
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  static Future<Login?> getLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_keyLoginData);
    if (data == null || data.isEmpty) return null;

    try {
      final decoded = jsonDecode(data);
      if (decoded is! Map<String, dynamic>) return null;
      final login = Login.fromXml(decoded);
      return _isValidLogin(login) ? login : null;
    } on FormatException {
      return null;
    }
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final login = await getLoginData();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    if (!isLoggedIn || login == null) {
      await prefs.remove(_keyIsLoggedIn);
      if (login == null) await prefs.remove(_keyLoginData);
      return false;
    }
    return true;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static bool _isValidLogin(Login login) {
    return (login.pref1 ?? '').trim().isNotEmpty &&
        (login.pref3 ?? '').trim().isNotEmpty &&
        (login.pref8 ?? '').trim().isNotEmpty;
  }
}
