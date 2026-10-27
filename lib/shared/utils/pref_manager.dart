import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/login.dart';

class PrefManager {
  static const String _keyLoginData = 'login_data';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyPasswordDigest = 'user_pwd_digest';

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
    await Future.wait([
      prefs.remove(_keyLoginData),
      prefs.remove(_keyIsLoggedIn),
      prefs.remove(_keyPasswordDigest),
      prefs.remove('user_pwd'),
    ]);
  }

  static Future<void> savePasswordDigest(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPasswordDigest, _digest(password));
    await prefs.remove('user_pwd');
  }

  static Future<bool> verifyPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    final digest = prefs.getString(_keyPasswordDigest);
    if (digest != null) return digest == _digest(password);

    final legacyPassword = prefs.getString('user_pwd');
    if (legacyPassword == null || legacyPassword != password) return false;
    await savePasswordDigest(password);
    return true;
  }

  static bool _isValidLogin(Login login) {
    return (login.pref1 ?? '').trim().isNotEmpty &&
        (login.pref3 ?? '').trim().isNotEmpty &&
        (login.pref8 ?? '').trim().isNotEmpty;
  }

  static String _digest(String value) {
    return sha256.convert(utf8.encode(value)).toString();
  }
}
