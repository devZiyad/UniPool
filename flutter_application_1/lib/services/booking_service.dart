import 'dart:convert';
import '../models/booking.dart';
import '../services/api_client.dart';

class BookingService {
  // Create a new booking
  static Future<Booking> createBooking({
    required int rideId,
    required int seats,
  }) async {
    try {
      final response = await ApiClient.post(
        '/bookings',
        {
          'rideId': rideId,
          'seats': seats,
        },
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return Booking.fromJson(data);
      } else {
        throw ApiException(ApiClient.handleError(response), response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to create booking: ${e.toString()}', 0);
    }
  }

  // Get booking by ID
  static Future<Booking> getBooking(int bookingId) async {
    try {
      final response = await ApiClient.get('/bookings/$bookingId');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return Booking.fromJson(data);
      } else {
        throw ApiException(ApiClient.handleError(response), response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get booking: ${e.toString()}', 0);
    }
  }

  // Get current user's bookings
  static Future<List<Booking>> getMyBookings() async {
    try {
      final response = await ApiClient.get('/bookings/me');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        return data.map((json) => Booking.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ApiException(ApiClient.handleError(response), response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get bookings: ${e.toString()}', 0);
    }
  }

  // Get bookings for a specific ride (driver only)
  static Future<List<Booking>> getRideBookings(int rideId) async {
    try {
      final response = await ApiClient.get('/bookings/ride/$rideId');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        return data.map((json) => Booking.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ApiException(ApiClient.handleError(response), response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get ride bookings: ${e.toString()}', 0);
    }
  }

  // Cancel a booking
  static Future<void> cancelBooking(int bookingId) async {
    try {
      final response = await ApiClient.post(
        '/bookings/$bookingId/cancel',
        {},
      );

      if (response.statusCode != 200) {
        throw ApiException(ApiClient.handleError(response), response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to cancel booking: ${e.toString()}', 0);
    }
  }
}

