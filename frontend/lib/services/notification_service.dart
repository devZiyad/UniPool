import 'dart:convert';
import '../models/notification.dart';
import 'api_client.dart';

class NotificationService {
  /// Get all notifications for current user
  static Future<List<Notification>> getMyNotifications() async {
    final response = await ApiClient.get('/notifications/me');
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Notification.fromJson(json)).toList();
  }

  /// Get unread notifications for current user
  static Future<List<Notification>> getUnreadNotifications() async {
    final response = await ApiClient.get('/notifications/me/unread');
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Notification.fromJson(json)).toList();
  }

  /// Get count of unread notifications
  static Future<int> getUnreadCount() async {
    final response = await ApiClient.get('/notifications/me/unread-count');
    final data = jsonDecode(response.body);
    return data['count'] as int? ?? 0;
  }

  /// Mark a notification as read
  static Future<void> markAsRead(int notificationId) async {
    await ApiClient.post('/notifications/$notificationId/read', {});
  }

  /// Mark all notifications as read
  static Future<void> markAllAsRead() async {
    await ApiClient.post('/notifications/me/read-all', {});
  }

  /// Send notification to a specific user
  /// Note: The backend should automatically create notifications for:
  /// - BOOKING_REQUESTED: When a rider creates a booking (notifies driver)
  /// - BOOKING_CONFIRMED: When a driver accepts a booking (notifies rider)
  /// - RIDE_STARTED: When a driver starts a ride (notifies rider)
  /// This method is kept for compatibility but notifications should be created by backend
  static Future<void> sendNotification({
    required int userId,
    required String type,
    required String title,
    required String body,
  }) async {
    try {
      // Try to send notification - backend may have this endpoint
      await ApiClient.post('/notifications/send', {
        'userId': userId,
        'type': type,
        'title': title,
        'body': body,
      });
    } catch (e) {
      // If endpoint doesn't exist, notifications should be created automatically
      // by the backend when events occur (booking created, confirmed, ride started)
      print('Notification send endpoint may not exist: $e');
      print('Notifications should be created automatically by backend');
    }
  }

  /// Send notifications to all riders in a ride
  /// Note: Backend should automatically create RIDE_STARTED notifications
  /// when ride status changes to IN_PROGRESS
  static Future<void> notifyRidersInRide({
    required int rideId,
    required List<int> riderIds,
    required String title,
    required String body,
  }) async {
    try {
      // Try bulk notification endpoint if it exists
      await ApiClient.post('/notifications/ride/$rideId/notify-riders', {
        'title': title,
        'body': body,
      });
    } catch (e) {
      // Fallback: send individual notifications
      print('Bulk notification endpoint may not exist, trying individual: $e');
      for (final riderId in riderIds) {
        try {
          await sendNotification(
            userId: riderId,
            type: 'RIDE_STARTED',
            title: title,
            body: body,
          );
        } catch (e) {
          print('Error sending notification to rider $riderId: $e');
        }
      }
    }
  }
}
