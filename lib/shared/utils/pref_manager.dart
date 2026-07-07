import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/login.dart';

class PrefManager {
  static const String _keyLoginData = 'login_data';
  static const String _keyIsLoggedIn = 'is_logged_in';

  // Simpan data login
  static Future<void> saveLoginData(Login login) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLoginData, jsonEncode(login.toJson()));
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  // Ambil data login
  static Future<Login?> getLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_keyLoginData);
    if (data != null) {
      return Login.fromXml(jsonDecode(data));
    }
    return null;
  }

  // Cek status login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Hapus data (Logout)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
