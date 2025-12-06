import 'dart:convert';
import '../models/booking.dart';
import 'api_client.dart';

class BookingService {
  static Future<Booking> createBooking({
    required int rideId,
    required int seats,
    required int pickupLocationId,
    required int dropoffLocationId,
    required DateTime pickupTimeStart,
    required DateTime pickupTimeEnd,
  }) async {
    // Convert to UTC for API
    final pickupTimeStartUtc = pickupTimeStart.toUtc();
    final pickupTimeEndUtc = pickupTimeEnd.toUtc();
    
    final requestBody = {
      'rideId': rideId,
      'seats': seats,
      'pickupLocationId': pickupLocationId,
      'dropoffLocationId': dropoffLocationId,
      'pickupTimeStart': pickupTimeStartUtc.toIso8601String(),
      'pickupTimeEnd': pickupTimeEndUtc.toIso8601String(),
    };
    
    print('POST /api/bookings - Request Body: ${jsonEncode(requestBody)}');
    
    final response = await ApiClient.post('/bookings', requestBody);
    
    print('POST /api/bookings - Response Status: ${response.statusCode}');
    print('POST /api/bookings - Response Body: ${response.body}');

    return Booking.fromJson(jsonDecode(response.body));
  }

  static Future<Booking> getBooking(int id) async {
    final response = await ApiClient.get('/bookings/$id');
    return Booking.fromJson(jsonDecode(response.body));
  }

  static Future<List<Booking>> getMyBookings() async {
    final response = await ApiClient.get('/bookings/me');
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Booking.fromJson(json)).toList();
  }

  static Future<List<Booking>> getBookingsForRide(int rideId) async {
    final response = await ApiClient.get('/bookings/ride/$rideId');
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Booking.fromJson(json)).toList();
  }

  static Future<void> cancelBooking(int bookingId) async {
    await ApiClient.post('/bookings/$bookingId/cancel', null);
  }
}
