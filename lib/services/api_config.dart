/// Centralized API Configuration for Stark Group VMS Flutter Web application.
class ApiConfig {
  /// Default base URL pointing to the Spring Boot REST API.
  /// Can be overridden at runtime or via `--dart-define=API_BASE_URL=http://...`
  static String baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api',
  );

  static Uri uri(String path) {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    final cleanBase = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
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
