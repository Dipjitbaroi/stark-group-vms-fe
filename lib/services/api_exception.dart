import 'dart:convert';

/// Domain exception for API network and HTTP error responses.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, String> fieldErrors;

  ApiException({
    required this.statusCode,
    required this.message,
    Map<String, String>? fieldErrors,
  }) : fieldErrors = fieldErrors ?? const {};

  bool get isDuplicate => statusCode == 409;
  bool get isBadRequest => statusCode == 400;
  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;

  factory ApiException.fromResponse(int statusCode, String body) {
    String message = 'Request failed with status $statusCode.';
    Map<String, String> errors = {};

    try {
      if (body.trim().isNotEmpty) {
        final decoded = jsonDecode(body);
        if (decoded is Map<String, dynamic>) {
          if (decoded['message'] != null) {
            message = decoded['message'].toString();
          } else if (decoded['error'] != null) {
            message = decoded['error'].toString();
          }

          if (decoded['errors'] is Map) {
            (decoded['errors'] as Map).forEach((key, val) {
              errors[key.toString()] = val.toString();
            });
          }
        }
      }
    } catch (_) {
      // Fallback if response body is not JSON
      if (body.trim().isNotEmpty) {
        message = body;
      }
    }

    return ApiException(
      statusCode: statusCode,
      message: message,
      fieldErrors: errors,
    );
  }

  @override
  String toString() => message;
}
