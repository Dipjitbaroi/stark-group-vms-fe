import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle.dart';
import 'api_config.dart';
import 'api_exception.dart';

/// Network service for Vehicle domain REST endpoints.
class VehicleApiService {
  final http.Client _client;

  VehicleApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch all vehicles: GET /api/vehicles with optional query params (search, status, company, type)
  Future<List<Vehicle>> getAllVehicles({
    String? search,
    String? status,
    String? company,
    String? type,
    String? token,
  }) async {
    final queryParams = <String, String>{};
    if (search != null && search.trim().isNotEmpty) queryParams['search'] = search.trim();
    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') queryParams['status'] = status;
    if (company != null && company.isNotEmpty && company.toLowerCase() != 'all') queryParams['company'] = company;
    if (type != null && type.isNotEmpty && type.toLowerCase() != 'all') queryParams['type'] = type;

    final baseUri = ApiConfig.uri('vehicles');
    final url = queryParams.isEmpty
        ? baseUri
        : baseUri.replace(queryParameters: queryParams);

    try {
      final response = await _client.get(
        url,
        headers: ApiConfig.headers(token),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded.map((e) => Vehicle.fromJson(e as Map<String, dynamic>)).toList();
        }
        return [];
      }

      throw ApiException.fromResponse(response.statusCode, response.body);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        statusCode: 0,
        message: 'Failed to connect to VMS backend server. Please check that the server is running.',
      );
    }
  }

  /// Get single vehicle: GET /api/vehicles/{id}
  Future<Vehicle> getVehicleById(String id, {String? token}) async {
    final url = ApiConfig.uri('vehicles/$id');
    try {
      final response = await _client.get(
        url,
        headers: ApiConfig.headers(token),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Vehicle.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }

      throw ApiException.fromResponse(response.statusCode, response.body);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        statusCode: 0,
        message: 'Failed to connect to VMS backend server.',
      );
    }
  }

  /// Register new vehicle: POST /api/vehicles
  Future<Vehicle> createVehicle(Vehicle vehicle, {String? token}) async {
    final url = ApiConfig.uri('vehicles');
    final payload = jsonEncode(vehicle.toJson());

    try {
      final response = await _client.post(
        url,
        headers: ApiConfig.headers(token),
        body: payload,
      );

      if (response.statusCode == 201 || (response.statusCode >= 200 && response.statusCode < 300)) {
        return Vehicle.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }

      throw ApiException.fromResponse(response.statusCode, response.body);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        statusCode: 0,
        message: 'Network error communicating with VMS server during registration.',
      );
    }
  }

  /// Update vehicle: PUT /api/vehicles/{id}
  Future<Vehicle> updateVehicle(String id, Vehicle vehicle, {String? token}) async {
    final url = ApiConfig.uri('vehicles/$id');
    final payload = jsonEncode(vehicle.toJson());

    try {
      final response = await _client.put(
        url,
        headers: ApiConfig.headers(token),
        body: payload,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Vehicle.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }

      throw ApiException.fromResponse(response.statusCode, response.body);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        statusCode: 0,
        message: 'Network error communicating with VMS server during update.',
      );
    }
  }

  /// Delete vehicle: DELETE /api/vehicles/{id}
  Future<void> deleteVehicle(String id, {String? token}) async {
    final url = ApiConfig.uri('vehicles/$id');

    try {
      final response = await _client.delete(
        url,
        headers: ApiConfig.headers(token),
      );

      if (response.statusCode == 204 || (response.statusCode >= 200 && response.statusCode < 300)) {
        return;
      }

      throw ApiException.fromResponse(response.statusCode, response.body);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        statusCode: 0,
        message: 'Network error communicating with VMS server during deletion.',
      );
    }
  }
}
