import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location.dart';

class SerpApiService {
  static const String apiKey =
      '201ab1fd9c02bc215528fb7032ff1afed7063c5848cc5b2394f63d1cebabb0f6';
  static const String baseUrl = 'https://serpapi.com/search.json';

  /// Search for locations using SerpApi Google Maps API
  ///
  /// [query] - The search query (e.g., "pizza", "University Main Gate")
  /// [latitude] - Optional latitude for location-based search
  /// [longitude] - Optional longitude for location-based search
  /// [zoom] - Optional zoom level (default: 14)
  static Future<List<Location>> searchLocations({
    required String query,
    double? latitude,
    double? longitude,
    int zoom = 14,
  }) async {
    try {
      final Map<String, String> params = {
        'engine': 'google_maps',
        'type': 'search',
        'q': query,
        'api_key': apiKey,
        'hl': 'en', // Language: English
      };

      // Add location parameters if provided
      if (latitude != null && longitude != null) {
        params['ll'] = '@$latitude,$longitude,${zoom}z';
      }

      final uri = Uri.parse(baseUrl).replace(queryParameters: params);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final localResults = data['local_results'] as List<dynamic>?;

        if (localResults == null) {
          return [];
        }

        return localResults.map((result) {
          final gps = result['gps_coordinates'] as Map<String, dynamic>?;
          final lat = gps?['latitude']?.toDouble() ?? 0.0;
          final lng = gps?['longitude']?.toDouble() ?? 0.0;

          return Location(
            id: 0, // SerpApi doesn't provide IDs, will be set by backend
            label: result['title'] as String? ?? query,
            address: result['address'] as String?,
            latitude: lat,
            longitude: lng,
            isFavorite: false,
          );
        }).toList();
      } else {
        throw Exception('SerpApi request failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching locations: $e');
    }
  }

  /// Reverse geocode coordinates to get address
  ///
  /// [latitude] - Latitude coordinate
  /// [longitude] - Longitude coordinate
  static Future<String> reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    try {
      // Use a nearby search to get address information
      final params = {
        'engine': 'google_maps',
        'type': 'search',
        'q': '$latitude,$longitude',
        'api_key': apiKey,
        'hl': 'en',
        'll': '@$latitude,$longitude,14z',
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: params);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final localResults = data['local_results'] as List<dynamic>?;

        if (localResults != null && localResults.isNotEmpty) {
          return localResults[0]['address'] as String? ??
              '$latitude, $longitude';
        }
      }

      return '$latitude, $longitude';
    } catch (e) {
      return '$latitude, $longitude';
    }
  }
}
