
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  ApiService({required this.baseUrl});

  // Helper method to get the authorization header
  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    if (requiresAuth) {
      final token = await secureStorage.read(key: 'token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Generic GET request
  Future<dynamic> get(String endpoint, {bool requiresAuth = true}) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
      );

      return _processResponse(response);
    } catch (e) {
      throw Exception('Failed to perform GET request: $e');
    }
  }

  // Generic POST request
  Future<dynamic> post(
    String endpoint,
    dynamic data, {
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );

      return _processResponse(response);
    } catch (e) {
      throw Exception('Failed to perform POST request: $e');
    }
  }

  // Generic PUT request
  Future<dynamic> put(
    String endpoint,
    dynamic data, {
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );

      return _processResponse(response);
    } catch (e) {
      throw Exception('Failed to perform PUT request: $e');
    }
  }

  // Process API response
  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      final errorMessage = errorBody['message'] ?? 'Unknown error occurred';
      throw Exception(errorMessage);
    }
  }

  // Save token to secure storage
  Future<void> saveToken(String token) async {
    await secureStorage.write(key: 'token', value: token);
  }

  // Delete token from secure storage
  Future<void> deleteToken() async {
    await secureStorage.delete(key: 'token');
  }

  // Check if token exists
  Future<bool> hasToken() async {
    final token = await secureStorage.read(key: 'token');
    return token != null;
  }

  Future<dynamic> delete(String endpoint, {bool requiresAuth = true}) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
      );

      // For 204 No Content responses, return empty success response
      if (response.statusCode == 204) {
        return {'success': true};
      }

      return _processResponse(response);
    } catch (e) {
      throw Exception('Failed to perform DELETE request: $e');
    }
  }
}
