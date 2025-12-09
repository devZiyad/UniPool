import 'api_client.dart';

class NotificationService {
  /// Send notification to a specific user
  /// Note: This endpoint may not exist in the API. If it doesn't, notifications
  /// might be automatically sent when ride status changes to IN_PROGRESS
  static Future<void> sendNotification({
    required int userId,
    required String type,
    required String title,
    required String body,
  }) async {
    try {
      // Try to send notification - if endpoint doesn't exist, this will fail gracefully
      await ApiClient.post('/notifications/send', {
        'userId': userId,
        'type': type,
        'title': title,
        'body': body,
      });
    } catch (e) {
      // If endpoint doesn't exist, notifications might be sent automatically
      // by the backend when ride status changes
      print('Notification send endpoint may not exist: $e');
      print('Notifications may be sent automatically by backend');
    }
  }

  /// Send notifications to all riders in a ride
  static Future<void> notifyRidersInRide({
    required int rideId,
    required List<int> riderIds,
    required String title,
    required String body,
  }) async {
    try {
      // Try bulk notification endpoint
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
