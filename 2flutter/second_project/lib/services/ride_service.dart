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
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Ride.fromJson(json)).toList();
  }

  static Future<Ride> updateRideStatus(int id, String status) async {
    final response = await ApiClient.patch('/rides/$id/status', {
      'status': status,
    });
    return Ride.fromJson(jsonDecode(response.body));
  }
}
