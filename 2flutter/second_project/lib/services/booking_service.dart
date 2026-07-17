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
    
    try {
      final response = await ApiClient.post('/bookings', requestBody);
      
      print('POST /api/bookings - Response Status: ${response.statusCode}');
      print('POST /api/bookings - Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);
      
      // Check if the response is a Ride object instead of a Booking
      // (API sometimes returns the updated Ride instead of the Booking)
      if (responseData.containsKey('driverId') || responseData.containsKey('vehicleId')) {
        // This is a Ride object, not a Booking
        // The booking was successful (201 status), so we know it worked
        print('POST /api/bookings - Response is a Ride object, booking succeeded');
        
        // Try to find the booking in the bookings array
        if (responseData['bookings'] != null && 
            (responseData['bookings'] as List).isNotEmpty) {
          // Use the first booking from the array
          final bookingJson = responseData['bookings'][0];
          if (bookingJson is Map<String, dynamic>) {
            return Booking.fromJson(bookingJson);
          }
        }
        
        // If no booking in the array, the API returned a Ride but the booking was created
        // We'll create a minimal Booking object - the actual booking can be fetched later if needed
        // Since the booking succeeded (201), we know it exists on the server
        print('POST /api/bookings - No booking in Ride response, creating minimal Booking');
        return Booking(
          id: -1, // Temporary ID - indicates booking was created but not fully parsed
          rideId: responseData['rideId'] ?? rideId,
          riderId: -1, // Will need to be fetched later
          riderName: 'Unknown',
          seatsBooked: seats,
          status: 'PENDING',
          costForThisRider: 0.0,
          createdAt: DateTime.now(),
        );
      }
      
      // Check if response has bookingId and rideId (new simplified response format)
      if (responseData.containsKey('bookingId') && responseData.containsKey('rideId')) {
        print('POST /api/bookings - Response has bookingId and rideId');
        // Create a minimal Booking from the simplified response
        return Booking(
          id: responseData['bookingId'] is int 
              ? responseData['bookingId'] 
              : int.parse(responseData['bookingId'].toString()),
          rideId: responseData['rideId'] is int 
              ? responseData['rideId'] 
              : int.parse(responseData['rideId'].toString()),
          riderId: responseData['riderId'] ?? responseData['passengerId'] ?? 0,
          riderName: responseData['riderName'] ?? responseData['passengerName'] ?? 'Unknown',
          seatsBooked: responseData['seatsBooked'] ?? responseData['seats'] ?? seats,
          status: responseData['status'] ?? 'PENDING',
          costForThisRider: (responseData['costForThisRider'] ?? 0.0).toDouble(),
          createdAt: responseData['createdAt'] != null 
              ? DateTime.parse(responseData['createdAt'])
              : DateTime.now(),
          cancelledAt: responseData['cancelledAt'] != null
              ? DateTime.parse(responseData['cancelledAt'])
              : null,
          pickupLocationLabel: responseData['pickupLocationLabel'],
          dropoffLocationLabel: responseData['dropoffLocationLabel'],
          pickupTimeStart: responseData['pickupTimeStart'] != null
              ? DateTime.parse(responseData['pickupTimeStart']).toLocal()
              : null,
          pickupTimeEnd: responseData['pickupTimeEnd'] != null
              ? DateTime.parse(responseData['pickupTimeEnd']).toLocal()
              : null,
        );
      }
      
      // Normal case: response is a Booking object (with 'id' field)
      return Booking.fromJson(responseData);
    } catch (e) {
      print('POST /api/bookings - Error: $e');
      rethrow;
    }
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

  static Future<Booking> acceptBooking(int bookingId) async {
    final response = await ApiClient.post('/bookings/$bookingId/accept', {});
    return Booking.fromJson(jsonDecode(response.body));
  }

  static Future<void> rejectBooking(int bookingId) async {
    await ApiClient.post('/bookings/$bookingId/reject', {});
  }

  static Future<Booking> updateBookingStatus(int bookingId, String status) async {
    final response = await ApiClient.put('/bookings/$bookingId/status', {
      'status': status,
    });
    return Booking.fromJson(jsonDecode(response.body));
  }
}
