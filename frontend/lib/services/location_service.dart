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

  /// Search locations using backend API
  ///
  /// [query] - The search query
  /// [latitude] - Optional latitude for location-based search (not used by backend, kept for compatibility)
  /// [longitude] - Optional longitude for location-based search (not used by backend, kept for compatibility)
  static Future<List<Location>> searchLocations(
    String query, {
    double? latitude,
    double? longitude,
  }) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      print('Location search request: query="$query"');

      final response = await ApiClient.post('/locations/search', {
        'query': query,
      });

      print('Location search response status: ${response.statusCode}');
      print('Location search response body: ${response.body}');

      final List<dynamic> data = jsonDecode(response.body);
      print('Location search: Parsed ${data.length} items from response');

      // Map the API response (OpenStreetMap/Nominatim format) to Location model
      final locations = <Location>[];
      for (final item in data) {
        try {
          if (item is! Map<String, dynamic>) {
            print('Location search: Skipping non-map item: $item');
            continue;
          }

          final json = item as Map<String, dynamic>;

          // Handle both documented format and actual OpenStreetMap format
          if (json.containsKey('label') && json.containsKey('latitude')) {
            // Documented format - use directly
            locations.add(Location.fromJson(json));
          } else {
            // OpenStreetMap/Nominatim format - map to Location model
            final latStr =
                json['lat'] as String? ?? json['latitude']?.toString();
            final lonStr =
                json['lon'] as String? ?? json['longitude']?.toString();

            if (latStr == null || lonStr == null) {
              print('Location search: Missing lat/lon in item: $json');
              continue;
            }

            final lat = double.tryParse(latStr);
            final lon = double.tryParse(lonStr);

            if (lat == null || lon == null) {
              print(
                'Location search: Invalid lat/lon format: lat=$latStr, lon=$lonStr',
              );
              continue;
            }

            // Use 'name' as label, fallback to 'display_name' if name is not available
            final name = json['name'] as String?;
            final displayName = json['display_name'] as String?;
            final label = name ?? displayName ?? 'Unknown Location';

            // Use 'display_name' as address
            final address = displayName;

            locations.add(
              Location(
                id: null, // Search results don't have backend IDs
                label: label,
                address: address,
                latitude: lat,
                longitude: lon,
                isFavorite: false,
              ),
            );
          }
        } catch (e) {
          print('Location search: Error processing item $item: $e');
          continue;
        }
      }

      print('Location search result: ${locations.length} locations found');

      return locations;
    } catch (e) {
      print('Location search error: $e');
      rethrow;
    }
  }

  /// Reverse geocode coordinates to address using backend API
  static Future<String> reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    try {
      final endpoint =
          '/locations/reverse-geocode?latitude=$latitude&longitude=$longitude';
      print('Reverse geocoding request: $endpoint');

      final response = await ApiClient.get(endpoint);

      print('Reverse geocoding response status: ${response.statusCode}');
      print('Reverse geocoding response body: ${response.body}');

      final data = jsonDecode(response.body);
      print('Reverse geocoding parsed data: $data');

      final address = data['address'] as String? ?? '$latitude, $longitude';
      print('Reverse geocoding result: $address');

      return address;
    } catch (e) {
      print('Reverse geocoding error: $e');
      // Fallback to coordinates if reverse geocoding fails
      return '$latitude, $longitude';
    }
  }

  /// Get route between two locations
  /// Returns a map with 'routeId' and 'routePolyline'
  static Future<Map<String, dynamic>?> getRoute(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) async {
    try {
      print(
        'Route request: start=($startLatitude, $startLongitude), end=($endLatitude, $endLongitude)',
      );

      final response = await ApiClient.post('/locations/route', {
        'startLatitude': startLatitude,
        'startLongitude': startLongitude,
        'endLatitude': endLatitude,
        'endLongitude': endLongitude,
      });

      print('Route response status: ${response.statusCode}');
      print('Route response body: ${response.body}');

      final data = jsonDecode(response.body);
      print('Route parsed data: $data');

      final routeId = data['id'] ?? data['routeId'];
      // Check for both 'routePolyline' (encoded string) and 'polyline' (GeoJSON object or JSON string)
      dynamic polylineData = data['routePolyline'] ?? data['polyline'];

      String? polylineString;
      List<List<double>>? coordinates;

      if (polylineData is String) {
        // Could be encoded polyline string or JSON string
        try {
          // Try to parse as JSON first (GeoJSON format)
          final parsed = jsonDecode(polylineData);
          if (parsed is Map && parsed.containsKey('coordinates')) {
            // It's a GeoJSON object as a string
            final coords = parsed['coordinates'] as List<dynamic>?;
            if (coords != null && coords.isNotEmpty) {
              coordinates = coords
                  .map((coord) {
                    if (coord is List && coord.length >= 2) {
                      // GeoJSON format is [longitude, latitude]
                      return [coord[0] as double, coord[1] as double];
                    }
                    return <double>[];
                  })
                  .where((c) => c.isNotEmpty)
                  .toList()
                  .cast<List<double>>();
              print(
                'Route coordinates (GeoJSON from string): ${coordinates.length} points',
              );
            }
          } else {
            // It's an encoded polyline string
            polylineString = polylineData;
            print('Route polyline (encoded string): $polylineString');
          }
        } catch (e) {
          // Not JSON, treat as encoded polyline string
          polylineString = polylineData;
          print(
            'Route polyline (encoded string, parse error: $e): $polylineString',
          );
        }
      } else if (polylineData is Map) {
        // GeoJSON format with coordinates (already parsed)
        final coords = polylineData['coordinates'] as List<dynamic>?;
        if (coords != null) {
          coordinates = coords
              .map((coord) {
                if (coord is List && coord.length >= 2) {
                  return [coord[0] as double, coord[1] as double];
                }
                return <double>[];
              })
              .where((c) => c.isNotEmpty)
              .toList()
              .cast<List<double>>();
          print('Route coordinates (GeoJSON): ${coordinates.length} points');
        }
      }

      print('Route ID: $routeId');

      if (routeId != null && (polylineString != null || coordinates != null)) {
        return {
          'routeId': routeId,
          'routePolyline': polylineString,
          'coordinates': coordinates,
        };
      }
      return null;
    } catch (e) {
      print('Route error: $e');
      return null;
    }
  }
}
