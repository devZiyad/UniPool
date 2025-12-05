import 'dart:convert';
import '../models/location.dart';
import 'api_client.dart';
import 'serpapi_service.dart';

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

  /// Search locations using SerpApi Google Maps API
  ///
  /// [query] - The search query
  /// [latitude] - Optional latitude for location-based search
  /// [longitude] - Optional longitude for location-based search
  static Future<List<Location>> searchLocations(
    String query, {
    double? latitude,
    double? longitude,
  }) async {
    return await SerpApiService.searchLocations(
      query: query,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Reverse geocode coordinates to address using SerpApi
  static Future<String> reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    return await SerpApiService.reverseGeocode(latitude, longitude);
  }
}
