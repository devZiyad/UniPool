import 'dart:convert';
import '../models/user.dart';
import 'api_client.dart';

class UserService {
  static Future<User> getCurrentUser() async {
    final response = await ApiClient.get('/users/me');
    return User.fromJson(jsonDecode(response.body));
  }

  static Future<User> updateProfile({
    required String fullName,
    String? phoneNumber,
  }) async {
    final response = await ApiClient.put('/users/me', {
      'fullName': fullName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
    });
    return User.fromJson(jsonDecode(response.body));
  }

  static Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await ApiClient.put('/users/me/password', {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });
  }

  static Future<User> updateRole(String role) async {
    final response = await ApiClient.put('/users/me/role', {'role': role});
    return User.fromJson(jsonDecode(response.body));
  }
}
