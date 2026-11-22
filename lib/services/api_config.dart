import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized API and Environment Configuration for Stark Group VMS Flutter Web application.
/// Strictly resolves the API Base URL from the local `.env` file (`API_BASE_URL`).
/// If `.env` is not present or key is missing, safely falls back to localhost.
class ApiConfig {
  static const String _defaultLocalhostUrl = 'http://localhost:8080/api';

  /// Resolves an environment key from flutter_dotenv (.env).
  static String get(String key) {
    try {
      if (dotenv.isInitialized) {
        final val = dotenv.maybeGet(key);
        if (val != null && val.trim().isNotEmpty) {
          return val.trim();
        }
      }
    } catch (_) {}
    return '';
  }

  /// Backend REST API Base URL:
  /// - Gets value from .env file (API_BASE_URL or VMS_API_BASE_URL)
  /// - If .env is not present or key is missing, falls back to localhost:8080
  static String get baseUrl {
    final envUrl = get('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;

    final altUrl = get('VMS_API_BASE_URL');
    if (altUrl.isNotEmpty) return altUrl;

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
