import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'api_exception.dart';

/// Network service for authentication endpoints.
class AuthApiService {
  final http.Client _client;

  AuthApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Authenticate against POST /api/auth/login
  Future<Map<String, dynamic>> login(String emailOrUsername, String password) async {
    final url = ApiConfig.uri('auth/login');
    final payload = jsonEncode({
      'emailOrUsername': emailOrUsername.trim(),
      'password': password,
    });

    try {
      final response = await _client.post(
        url,
        headers: ApiConfig.headers(),
        body: payload,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        return {'emailOrUsername': emailOrUsername};
      }

      throw ApiException.fromResponse(response.statusCode, response.body);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        statusCode: 0,
        message: 'Unable to reach VMS backend server. Please check your network connection.',
      );
    }
  }
}
