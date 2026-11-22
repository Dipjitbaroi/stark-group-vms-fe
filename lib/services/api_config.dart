import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized API and Environment Configuration for Stark Group VMS Flutter Web application.
/// Resolves the API Base URL from the local `.env` file (`API_BASE_URL`).
/// If `.env` is not present or the key is not defined, it defaults to localhost.
/// NO credentials, usernames, or passwords are ever stored or configured in the frontend.
class ApiConfig {
  static const String _defaultLocalhostUrl = 'http://localhost:8080/api';

  /// Resolves an environment key from flutter_dotenv.
  static String get(String key, {String defaultValue = ''}) {
    try {
      if (dotenv.isInitialized) {
        final val = dotenv.maybeGet(key);
        if (val != null && val.trim().isNotEmpty) {
          return val.trim();
        }
      }
    } catch (_) {}
    return defaultValue;
  }

  /// Backend REST API Base URL
  /// Strictly loaded from .env (API_BASE_URL or VMS_API_BASE_URL).
  /// If not present, falls back to http://localhost:8080/api.
  static String get baseUrl {
    // 1. Resolve from loaded .env file
    final envUrl = get('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;

    final altUrl = get('VMS_API_BASE_URL');
    if (altUrl.isNotEmpty) return altUrl;

    // 2. Resolve from compile-time --dart-define if supplied
    const dartDefineUrl = String.fromEnvironment('API_BASE_URL');
    if (dartDefineUrl.trim().isNotEmpty) {
      return dartDefineUrl.trim();
    }

    // 3. Fallback to localhost when .env is not present
    return _defaultLocalhostUrl;
  }

  static Uri uri(String path) {
    final base = baseUrl;
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    final cleanBase = base.endsWith('/') ? base : '$base/';
    return Uri.parse('$cleanBase$cleanPath');
  }

  static Map<String, String> headers([String? token]) {
    final map = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      map['Authorization'] = 'Bearer $token';
    }
    return map;
  }
}
