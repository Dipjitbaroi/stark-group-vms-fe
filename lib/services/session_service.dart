import 'package:shared_preferences/shared_preferences.dart';

/// Storage service to persist user authentication tokens and credentials
/// across browser refreshes and page reloads.
class SessionService {
  static const String _keyToken = 'vms_auth_token';
  static const String _keyUser = 'vms_auth_user';

  /// Save session credentials into persistent browser local storage
  Future<void> saveSession({required String token, required String emailOrUsername}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyToken, token);
      await prefs.setString(_keyUser, emailOrUsername);
    } catch (_) {
      // Storage unavailable fallback
    }
  }

  /// Retrieve saved session on page load / refresh
  Future<Map<String, String>?> getSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_keyToken);
      final user = prefs.getString(_keyUser);
      if (token != null && token.isNotEmpty) {
        return {
          'token': token,
          'user': user ?? '',
        };
      }
    } catch (_) {
      // Storage unavailable fallback
    }
    return null;
  }

  /// Remove session on user logout
  Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyToken);
      await prefs.remove(_keyUser);
    } catch (_) {
      // Storage unavailable fallback
    }
  }
}
