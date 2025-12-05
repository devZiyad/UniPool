import 'dart:convert';
import '../models/location.dart';
import 'api_client.dart';

class LocationService {
  static Future<Location> createLocation({
    required String label,
    String? address,
    required double latitude,
    required double longitude,
    bool isFavorite = false,
  }) async {
    final response = await ApiClient.post('/locations', {
      'label': label,
      if (address != null) 'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'isFavorite': isFavorite,
    });

    return Location.fromJson(jsonDecode(response.body));
  }

  static Future<List<Location>> getMyLocations() async {
    final response = await ApiClient.get('/locations/me');
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Location.fromJson(json)).toList();
  }

  static Future<List<Location>> getFavoriteLocations() async {
    final response = await ApiClient.get('/locations/me/favorites');
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Location.fromJson(json)).toList();
  }

  static Future<List<Location>> searchLocations(String query) async {
    final response = await ApiClient.post('/locations/search', {
      'query': query,
    });
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Location.fromJson(json)).toList();
  }

  static Future<String> reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    final response = await ApiClient.get(
      '/locations/reverse-geocode?latitude=$latitude&longitude=$longitude',
    );
    final data = jsonDecode(response.body);
    return data['address'] ?? '';
  }
}
