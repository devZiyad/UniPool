import 'dart:convert';
import 'api_client.dart';

class TrackingService {
  static Future<void> startTracking(int rideId) async {
    await ApiClient.post('/tracking/$rideId/start', null);
  }

  static Future<void> updateLocation(
    int rideId,
    double latitude,
    double longitude,
  ) async {
    await ApiClient.post('/tracking/$rideId/update', {
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  static Future<Map<String, dynamic>> getCurrentLocation(int rideId) async {
    final response = await ApiClient.get('/tracking/$rideId');
    return jsonDecode(response.body);
  }

  static Future<void> stopTracking(int rideId) async {
    await ApiClient.post('/tracking/$rideId/stop', null);
  }
}
