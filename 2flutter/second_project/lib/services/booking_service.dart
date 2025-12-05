import 'dart:convert';
import '../models/booking.dart';
import 'api_client.dart';

class BookingService {
  static Future<Booking> createBooking({
    required int rideId,
    required int seats,
  }) async {
    final response = await ApiClient.post('/bookings', {
      'rideId': rideId,
      'seats': seats,
    });

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
