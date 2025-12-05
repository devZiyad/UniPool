import 'dart:convert';
import '../models/ride.dart';
import '../services/api_client.dart';

class RideService {
  // Create a new ride
  static Future<Ride> createRide({
    required int vehicleId,
    required int pickupLocationId,
    required int destinationLocationId,
    required DateTime departureTime,
    required int totalSeats,
    double? basePrice,
    double? pricePerSeat,
  }) async {
    try {
      final response = await ApiClient.post(
        '/rides',
        {
          'vehicleId': vehicleId,
          'pickupLocationId': pickupLocationId,
          'destinationLocationId': destinationLocationId,
          'departureTime': departureTime.toIso8601String(),
          'totalSeats': totalSeats,
          if (basePrice != null) 'basePrice': basePrice,
          if (pricePerSeat != null) 'pricePerSeat': pricePerSeat,
        },
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return Ride.fromJson(data);
      } else {
        throw ApiException(ApiClient.handleError(response), response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to create ride: ${e.toString()}', 0);
    }
  }

  // Get ride by ID
  static Future<Ride> getRide(int rideId) async {
    try {
      final response = await ApiClient.get('/rides/$rideId');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return Ride.fromJson(data);
      } else {
        throw ApiException(ApiClient.handleError(response), response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get ride: ${e.toString()}', 0);
    }
  }

  // Search rides
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
    try {
      final body = <String, dynamic>{};
      if (pickupLocationId != null) body['pickupLocationId'] = pickupLocationId;
      if (pickupLatitude != null) body['pickupLatitude'] = pickupLatitude;
      if (pickupLongitude != null) body['pickupLongitude'] = pickupLongitude;
      if (pickupRadiusKm != null) body['pickupRadiusKm'] = pickupRadiusKm;
      if (destinationLocationId != null) body['destinationLocationId'] = destinationLocationId;
      if (destinationLatitude != null) body['destinationLatitude'] = destinationLatitude;
      if (destinationLongitude != null) body['destinationLongitude'] = destinationLongitude;
      if (destinationRadiusKm != null) body['destinationRadiusKm'] = destinationRadiusKm;
      if (departureTimeFrom != null) body['departureTimeFrom'] = departureTimeFrom.toIso8601String();
      if (departureTimeTo != null) body['departureTimeTo'] = departureTimeTo.toIso8601String();
      if (minAvailableSeats != null) body['minAvailableSeats'] = minAvailableSeats;
      if (maxPrice != null) body['maxPrice'] = maxPrice;
      if (sortBy != null) body['sortBy'] = sortBy;

      final response = await ApiClient.post('/rides/search', body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        return data.map((json) => Ride.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ApiException(ApiClient.handleError(response), response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to search rides: ${e.toString()}', 0);
    }
  }

  // Get current user's rides as driver
  static Future<List<Ride>> getMyRidesAsDriver() async {
    try {
      final response = await ApiClient.get('/rides/me/driver');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        return data.map((json) => Ride.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ApiException(ApiClient.handleError(response), response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get rides: ${e.toString()}', 0);
    }
  }

  // Update ride
  static Future<Ride> updateRide({
    required int rideId,
    int? pickupLocationId,
    int? destinationLocationId,
    DateTime? departureTime,
    int? totalSeats,
    double? basePrice,
    double? pricePerSeat,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (pickupLocationId != null) body['pickupLocationId'] = pickupLocationId;
      if (destinationLocationId != null) body['destinationLocationId'] = destinationLocationId;
      if (departureTime != null) body['departureTime'] = departureTime.toIso8601String();
      if (totalSeats != null) body['totalSeats'] = totalSeats;
      if (basePrice != null) body['basePrice'] = basePrice;
      if (pricePerSeat != null) body['pricePerSeat'] = pricePerSeat;

      final response = await ApiClient.put('/rides/$rideId', body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return Ride.fromJson(data);
      } else {
        throw ApiException(ApiClient.handleError(response), response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to update ride: ${e.toString()}', 0);
    }
  }

  // Update ride status
  static Future<Ride> updateRideStatus({
    required int rideId,
    required String status, // POSTED, IN_PROGRESS, COMPLETED, CANCELLED
  }) async {
    try {
      final response = await ApiClient.patch(
        '/rides/$rideId/status',
        {'status': status},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return Ride.fromJson(data);
      } else {
        throw ApiException(ApiClient.handleError(response), response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to update ride status: ${e.toString()}', 0);
    }
  }

  // Delete/cancel ride
  static Future<void> deleteRide(int rideId) async {
    try {
      final response = await ApiClient.delete('/rides/$rideId');

      if (response.statusCode != 200) {
        throw ApiException(ApiClient.handleError(response), response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to delete ride: ${e.toString()}', 0);
    }
  }

  // Get available seats for a ride
  static Future<int> getAvailableSeats(int rideId) async {
    try {
      final response = await ApiClient.get('/rides/$rideId/available-seats');

      if (response.statusCode == 200) {
        return int.parse(response.body);
      } else {
        throw ApiException(ApiClient.handleError(response), response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get available seats: ${e.toString()}', 0);
    }
  }
}

