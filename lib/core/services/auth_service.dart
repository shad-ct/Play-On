import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:playon/core/models/user_model.dart';

class AuthService {
  AuthService._();

  static const _kUsernameKey = 'logged_in_username';
  static const _kPasswordKey = 'logged_in_password';

  static UserModel? _currentUser;
  static List<UserModel>? _users;

  /// The currently logged-in user (null if not logged in).
  static UserModel? get currentUser => _currentUser;

  /// Whether a user is currently logged in.
  static bool get isLoggedIn => _currentUser != null;

  /// Load users from the bundled JSON asset (cached after first load).
  static Future<void> _ensureLoaded() async {
    if (_users != null) return;
    final jsonStr = await rootBundle.loadString('lib/data/user.json');
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    final list = data['players'] as List<dynamic>;
    _users = list.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Try to restore a previously saved session.
  /// Returns the [UserModel] if a valid session exists, otherwise `null`.
  static Future<UserModel?> tryRestoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_kUsernameKey);
    final password = prefs.getString(_kPasswordKey);
    if (username == null || password == null) return null;

    await _ensureLoaded();
    try {
      final user = _users!.firstWhere(
        (u) => u.username == username && u.password == password,
      );
      _currentUser = user;
      return user;
    } catch (_) {
      // Saved credentials no longer valid — clear them
      await prefs.remove(_kUsernameKey);
      await prefs.remove(_kPasswordKey);
      return null;
    }
  }

  /// Attempt to log in with [username] and [password].
  /// Returns the matched [UserModel] on success, or `null` on failure.
  static Future<UserModel?> login(String username, String password) async {
    await _ensureLoaded();
    try {
      final user = _users!.firstWhere(
        (u) => u.username == username && u.password == password,
      );
      _currentUser = user;

      // Persist session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kUsernameKey, username);
      await prefs.setString(_kPasswordKey, password);

      return user;
    } catch (_) {
      return null;
    }
  }

  /// Log out the current user and clear persisted session.
  static Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUsernameKey);
    await prefs.remove(_kPasswordKey);
  }
}
