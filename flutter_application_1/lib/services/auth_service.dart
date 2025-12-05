import 'dart:convert';
import '../models/user.dart';
import '../services/api_client.dart';

class AuthService {
  // Register a new user
  static Future<AuthResponse> register({
    required String universityId,
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    String role = 'RIDER',
  }) async {
    try {
      final response = await ApiClient.post(
        '/auth/register',
        {
          'universityId': universityId,
          'email': email,
          'password': password,
          'fullName': fullName,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
          'role': role,
        },
        includeAuth: false,
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final authResponse = AuthResponse.fromJson(data);
        await ApiClient.setToken(authResponse.token);
        return authResponse;
      } else {
        throw ApiException(ApiClient.handleError(response), response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Registration failed: ${e.toString()}', 0);
    }
  }

  // Login user
  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.post(
        '/auth/login',
        {
          'email': email,
          'password': password,
        },
        includeAuth: false,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final authResponse = AuthResponse.fromJson(data);
        await ApiClient.setToken(authResponse.token);
        return authResponse;
      } else {
        throw ApiException(ApiClient.handleError(response), response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Login failed: ${e.toString()}', 0);
    }
  }

  // Get current user
  static Future<User> getCurrentUser() async {
    try {
      final response = await ApiClient.get('/auth/me');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return User.fromJson(data);
      } else {
        throw ApiException(ApiClient.handleError(response), response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get user: ${e.toString()}', 0);
    }
  }

  // Logout
  static Future<void> logout() async {
    await ApiClient.clearToken();
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await ApiClient.getToken();
    return token != null && token.isNotEmpty;
  }
}

