import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized API and Environment Configuration for Stark Group VMS Flutter Web application.
/// The API Base URL is dynamically resolved from the local `.env` file (`API_BASE_URL`)
/// or `--dart-define=API_BASE_URL=...` environment flags.
/// NO credentials, usernames, or passwords are ever stored or configured in the frontend.
class ApiConfig {
  /// Resolves an environment key from flutter_dotenv first, then falls back to dart-define environment.
  static String get(String key, {String defaultValue = ''}) {
    try {
      if (dotenv.isInitialized) {
        final val = dotenv.maybeGet(key);
        if (val != null && val.trim().isNotEmpty) {
          return val.trim();
        }
      }
    } catch (_) {}
    return String.fromEnvironment(key, defaultValue: defaultValue);
  }

  /// Backend REST API Base URL (loaded dynamically from .env API_BASE_URL or VMS_API_BASE_URL)
  static String get baseUrl {
    final envUrl = get('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;
    final altUrl = get('VMS_API_BASE_URL');
    if (altUrl.isNotEmpty) return altUrl;
    return const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080/api');
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
