import 'dart:convert';
import '../models/ride.dart';
import 'api_client.dart';

class RideService {
  static Future<Ride> createRide({
    required int vehicleId,
    required int pickupLocationId,
    required int destinationLocationId,
    required DateTime departureTime,
    required int totalSeats,
    double? basePrice,
    double? pricePerSeat,
  }) async {
    final response = await ApiClient.post('/rides', {
      'vehicleId': vehicleId,
      'pickupLocationId': pickupLocationId,
      'destinationLocationId': destinationLocationId,
      'departureTime': departureTime.toIso8601String(),
      'totalSeats': totalSeats,
      if (basePrice != null) 'basePrice': basePrice,
      if (pricePerSeat != null) 'pricePerSeat': pricePerSeat,
    });

    return Ride.fromJson(jsonDecode(response.body));
  }

  static Future<List<Ride>> searchRides({
    int? pickupLocationId,
    double? pickupLatitude,
    double? pickupLongitude,
    double? pickupRadiusKm,
    int? destinationLocationId,
    double? destinationLatitude,
    double? destinationLongitude,
    double? destinationRadiusKm,
    DateTime? departureTimeFrom,
    DateTime? departureTimeTo,
    int? minAvailableSeats,
    double? maxPrice,
    String? sortBy,
  }) async {
    final body = <String, dynamic>{};
    if (pickupLocationId != null) body['pickupLocationId'] = pickupLocationId;
    if (pickupLatitude != null) body['pickupLatitude'] = pickupLatitude;
    if (pickupLongitude != null) body['pickupLongitude'] = pickupLongitude;
    if (pickupRadiusKm != null) body['pickupRadiusKm'] = pickupRadiusKm;
    if (destinationLocationId != null)
      body['destinationLocationId'] = destinationLocationId;
    if (destinationLatitude != null)
      body['destinationLatitude'] = destinationLatitude;
    if (destinationLongitude != null)
      body['destinationLongitude'] = destinationLongitude;
    if (destinationRadiusKm != null)
      body['destinationRadiusKm'] = destinationRadiusKm;
    if (departureTimeFrom != null)
      body['departureTimeFrom'] = departureTimeFrom.toIso8601String();
    if (departureTimeTo != null)
      body['departureTimeTo'] = departureTimeTo.toIso8601String();
    if (minAvailableSeats != null)
      body['minAvailableSeats'] = minAvailableSeats;
    if (maxPrice != null) body['maxPrice'] = maxPrice;
    if (sortBy != null) body['sortBy'] = sortBy;

    final response = await ApiClient.post('/rides/search', body);
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Ride.fromJson(json)).toList();
  }

  static Future<Ride> getRide(int id) async {
    final response = await ApiClient.get('/rides/$id');
    return Ride.fromJson(jsonDecode(response.body));
  }

  static Future<List<Ride>> getMyRidesAsDriver() async {
    final response = await ApiClient.get('/rides/me/driver');
    print('GET /api/rides/me/driver - Response Status: ${response.statusCode}');
    print('GET /api/rides/me/driver - Response Body: ${response.body}');
    final List<dynamic> data = jsonDecode(response.body);
    print('GET /api/rides/me/driver - Parsed Data Count: ${data.length}');
    if (data.isNotEmpty) {
      print('GET /api/rides/me/driver - First Ride: ${data[0]}');
    }
    final rides = data.map((json) => Ride.fromJson(json)).toList();
    print('GET /api/rides/me/driver - Parsed Rides Count: ${rides.length}');
    return rides;
  }

  static Future<Ride> updateRideStatus(int id, String status) async {
    final response = await ApiClient.patch('/rides/$id/status', {
      'status': status,
    });
    return Ride.fromJson(jsonDecode(response.body));
  }

  static Future<void> deleteRide(int id) async {
    final response = await ApiClient.delete('/rides/$id');
    print('DELETE /api/rides/$id - Response Status: ${response.statusCode}');
    print('DELETE /api/rides/$id - Response Body: ${response.body}');
    // The API returns 200 OK with empty body on success
    // Also accept 204 No Content as success (common for DELETE operations)
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete ride: ${response.statusCode}');
    }
  }
}
