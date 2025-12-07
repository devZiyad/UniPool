import 'dart:convert';
import '../models/user.dart';
import 'api_client.dart';

class AdminService {
  /// Get all users (Admin only)
  static Future<List<User>> getAllUsers() async {
    final response = await ApiClient.get('/admin/users');
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => User.fromJson(json)).toList();
  }

  /// Get user by ID (Admin only)
  static Future<User> getUserById(int userId) async {
    final response = await ApiClient.get('/admin/users/$userId');
    return User.fromJson(jsonDecode(response.body));
  }

  /// Enable or disable a user (Admin only)
  static Future<User> setUserEnabled(int userId, bool enabled) async {
    final response = await ApiClient.put('/admin/users/$userId/enable', {
      'enabled': enabled,
    });
    return User.fromJson(jsonDecode(response.body));
  }

  /// Verify or reject a user's university ID (Admin only)
  static Future<User> verifyUniversityId(int userId, bool verified) async {
    final response = await ApiClient.put('/admin/users/$userId/verify-university-id', {
      'verified': verified,
    });
    return User.fromJson(jsonDecode(response.body));
  }

  /// Verify or reject a user as a driver (Admin only)
  static Future<User> verifyDriver(int userId, bool verified) async {
    final response = await ApiClient.put('/admin/users/$userId/verify-driver', {
      'verified': verified,
    });
    return User.fromJson(jsonDecode(response.body));
  }
}

