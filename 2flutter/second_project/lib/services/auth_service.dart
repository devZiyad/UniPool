import 'dart:convert';
import '../models/user.dart';
import 'api_client.dart';
import 'push_notification_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> register({
    required String universityId,
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    String role = 'RIDER',
  }) async {
    final response = await ApiClient.post('/auth/register', {
      'universityId': universityId,
      'email': email,
      'password': password,
      'fullName': fullName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      'role': role,
    });

    final data = jsonDecode(response.body);
    await ApiClient.setToken(data['token']);
    return {'token': data['token'], 'user': User.fromJson(data['user'])};
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post('/auth/login', {
      'email': email,
      'password': password,
    });

    final data = jsonDecode(response.body);
    await ApiClient.setToken(data['token']);
    return {'token': data['token'], 'user': User.fromJson(data['user'])};
  }

  static Future<User> getCurrentUser() async {
    final response = await ApiClient.get('/auth/me');
    return User.fromJson(jsonDecode(response.body));
  }

  static Future<void> logout() async {
    // Stop polling for notifications on logout
    try {
      final pushService = PushNotificationService();
      pushService.stopPolling();
      pushService.clearShownNotificationIds();
    } catch (e) {
      print('Error stopping push notifications on logout: $e');
    }
    await ApiClient.setToken(null);
  }
}
