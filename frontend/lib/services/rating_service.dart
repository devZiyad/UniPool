import 'dart:convert';
import '../models/rating.dart';
import 'api_client.dart';

class RatingService {
  static Future<Rating> createRating({
    required int bookingId,
    required int score,
    String? comment,
  }) async {
    final response = await ApiClient.post('/ratings', {
      'bookingId': bookingId,
      'score': score,
      if (comment != null) 'comment': comment,
    });

    return Rating.fromJson(jsonDecode(response.body));
  }

  static Future<List<Rating>> getRatingsForUser(int userId) async {
    final response = await ApiClient.get('/ratings/user/$userId');
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Rating.fromJson(json)).toList();
  }

  /// Check if a rating exists for a booking
  static Future<bool> hasRatingForBooking(int bookingId) async {
    try {
      final response = await ApiClient.get('/ratings/booking/$bookingId');
      return response.statusCode == 200;
    } catch (e) {
      // 404 means no rating exists
      return false;
    }
  }
}
