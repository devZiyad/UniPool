import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'http://localhost:8080/api';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';

  // Get stored token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Save token
  static Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Clear token
  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Get headers with authentication
  static Future<Map<String, String>> getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (includeAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Handle error responses
  static String handleError(http.Response response) {
    try {
      final errorData = json.decode(response.body);
      if (errorData is Map<String, dynamic>) {
        if (errorData.containsKey('message')) {
          return errorData['message'] as String;
        }
        // Handle field-specific errors
        if (errorData.length == 1) {
          return errorData.values.first.toString();
        }
        return errorData.toString();
      }
      return 'An error occurred';
    } catch (e) {
      return 'An error occurred: ${response.statusCode}';
    }
  }

  // GET request
  static Future<http.Response> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool includeAuth = true,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(
        uri,
        headers: await getHeaders(includeAuth: includeAuth),
      );

      if (response.statusCode == 401) {
        await clearToken();
        throw ApiException('Unauthorized. Please login again.', 401);
      }

      return response;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}', 0);
    }
  }

  // POST request
  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await getHeaders(includeAuth: includeAuth),
        body: json.encode(body),
      );

      if (response.statusCode == 401) {
        await clearToken();
        throw ApiException('Unauthorized. Please login again.', 401);
      }

      return response;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}', 0);
    }
  }

  // PUT request
  static Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: await getHeaders(includeAuth: includeAuth),
        body: json.encode(body),
      );

      if (response.statusCode == 401) {
        await clearToken();
        throw ApiException('Unauthorized. Please login again.', 401);
      }

      return response;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}', 0);
    }
  }

  // PATCH request
  static Future<http.Response> patch(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: await getHeaders(includeAuth: includeAuth),
        body: json.encode(body),
      );

      if (response.statusCode == 401) {
        await clearToken();
        throw ApiException('Unauthorized. Please login again.', 401);
      }

      return response;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}', 0);
    }
  }

  // DELETE request
  static Future<http.Response> delete(
    String endpoint, {
    bool includeAuth = true,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: await getHeaders(includeAuth: includeAuth),
      );

      if (response.statusCode == 401) {
        await clearToken();
        throw ApiException('Unauthorized. Please login again.', 401);
      }

      return response;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}', 0);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}

