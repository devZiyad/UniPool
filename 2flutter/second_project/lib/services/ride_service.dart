import 'dart:convert';
import '../models/ride.dart';
import 'api_client.dart';

class RideService {
  static Future<Ride> createRide({
    required int vehicleId,
    required int pickupLocationId,
    required int destinationLocationId,
    required DateTime departureTimeStart,
    required DateTime departureTimeEnd,
    required int totalSeats,
    double? basePrice,
    double? pricePerSeat,
  }) async {
    final requestBody = {
      'vehicleId': vehicleId,
      'pickupLocationId': pickupLocationId,
      'destinationLocationId': destinationLocationId,
      'departureTimeStart': departureTimeStart.toIso8601String(),
      'departureTimeEnd': departureTimeEnd.toIso8601String(),
      'totalSeats': totalSeats,
      if (basePrice != null) 'basePrice': basePrice,
      if (pricePerSeat != null) 'pricePerSeat': pricePerSeat,
    };

    print('POST /api/rides - Request Body: ${jsonEncode(requestBody)}');

    final response = await ApiClient.post('/rides', requestBody);

    print('POST /api/rides - Response Status: ${response.statusCode}');
    print('POST /api/rides - Response Body: ${response.body}');

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

    final decoded = jsonDecode(response.body);
    List<dynamic> data;

    // Handle different response formats
    if (decoded is List) {
      data = decoded;
    } else if (decoded is Map && decoded.containsKey('rides')) {
      data = decoded['rides'] as List<dynamic>;
    } else if (decoded is Map && decoded.containsKey('data')) {
      data = decoded['data'] as List<dynamic>;
    } else {
      // Try to parse as array directly
      data = [decoded];
    }

    print('GET /api/rides/me/driver - Parsed Data Count: ${data.length}');
    if (data.isNotEmpty) {
      print('GET /api/rides/me/driver - First Ride: ${data[0]}');
      // Log status of all rides
      for (var rideData in data) {
        if (rideData is Map) {
          final rideId = rideData['rideId'] ?? rideData['id'];
          print('  Ride ID: $rideId, Status: ${rideData['status']}');
        }
      }
    }

    final rides = data.map((json) {
      try {
        return Ride.fromJson(json as Map<String, dynamic>);
      } catch (e) {
        print('Error parsing ride: $e');
        print('Ride data: $json');
        rethrow;
      }
    }).toList();

    print('GET /api/rides/me/driver - Parsed Rides Count: ${rides.length}');
    print(
      'GET /api/rides/me/driver - Ride statuses: ${rides.map((r) => '${r.id}:${r.status}').join(', ')}',
    );
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
