import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = 'https://unipool.devziyad.me/api';
  static String? _token;

  static Future<void> setToken(String? token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString('token', token);
    } else {
      await prefs.remove('token');
    }
  }

  static Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    return _token;
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  static Future<http.Response> get(String endpoint) async {
    await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );
    _handleError(response);
    return response;
  }

  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic>? body,
  ) async {
    await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    _handleError(response);
    return response;
  }

  static Future<http.Response> put(
    String endpoint,
    Map<String, dynamic>? body,
  ) async {
    await getToken();
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    _handleError(response);
    return response;
  }

  static Future<http.Response> patch(
    String endpoint,
    Map<String, dynamic>? body,
  ) async {
    await getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    _handleError(response);
    return response;
  }

  static Future<http.Response> delete(String endpoint) async {
    await getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );
    _handleError(response);
    return response;
  }

  static void _handleError(http.Response response) {
    if (response.statusCode == 401) {
      setToken(null);
      throw Exception('Unauthorized - Please login again');
    }
    if (response.statusCode >= 400) {
      try {
        if (response.body.isNotEmpty) {
          final error = jsonDecode(response.body);
          // Handle different error response formats
          String errorMessage = 'An error occurred';
          
          if (error is Map<String, dynamic>) {
            // Check for message field
            if (error.containsKey('message')) {
              errorMessage = error['message'].toString();
            } 
            // Check for field-specific validation errors
            else if (error.keys.isNotEmpty) {
              final fieldErrors = error.entries
                  .where((e) => e.key != 'status' && e.key != 'timestamp')
                  .map((e) => '${e.key}: ${e.value}')
                  .join(', ');
              if (fieldErrors.isNotEmpty) {
                errorMessage = fieldErrors;
              }
            }
          } else if (error is String) {
            errorMessage = error;
          }
          
          print('API Error (${response.statusCode}): $errorMessage');
          print('Full error response: ${response.body}');
          throw Exception(errorMessage);
        } else {
          throw Exception('An error occurred: ${response.statusCode}');
        }
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception('An error occurred: ${response.statusCode}');
      }
    }
  }
}
