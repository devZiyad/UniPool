import 'dart:convert';
import '../models/location.dart';
import '../services/api_client.dart';

class LocationService {
  // Create a new location
  static Future<Location> createLocation({
    required String label,
    String? address,
    required double latitude,
    required double longitude,
    bool isFavorite = false,
  }) async {
    try {
      final response = await ApiClient.post(
        '/locations',
        {
          'label': label,
          if (address != null) 'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'isFavorite': isFavorite,
        },
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return Location.fromJson(data);
      } else {
        throw ApiException(ApiClient.handleError(response), response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to create location: ${e.toString()}', 0);
    }
  }

  // Get all locations for current user
  static Future<List<Location>> getMyLocations() async {
    try {
      final response = await ApiClient.get('/locations/me');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        return data.map((json) => Location.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ApiException(ApiClient.handleError(response), response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get locations: ${e.toString()}', 0);
    }
  }

  // Get favorite locations
  static Future<List<Location>> getFavoriteLocations() async {
    try {
      final response = await ApiClient.get('/locations/me/favorites');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        return data.map((json) => Location.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ApiException(ApiClient.handleError(response), response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get favorite locations: ${e.toString()}', 0);
    }
  }

  // Search locations
  static Future<List<Location>> searchLocations(String query) async {
    try {
      final response = await ApiClient.post(
        '/locations/search',
        {'query': query},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        return data.map((json) => Location.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ApiException(ApiClient.handleError(response), response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to search locations: ${e.toString()}', 0);
    }
  }

  // Reverse geocode coordinates to address
  static Future<String> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await ApiClient.get(
        '/locations/reverse-geocode',
        queryParams: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data['address'] as String;
      } else {
        throw ApiException(ApiClient.handleError(response), response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to reverse geocode: ${e.toString()}', 0);
    }
  }

  // Update location
  static Future<Location> updateLocation({
    required int locationId,
    String? label,
    String? address,
    double? latitude,
    double? longitude,
    bool? isFavorite,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (label != null) body['label'] = label;
      if (address != null) body['address'] = address;
      if (latitude != null) body['latitude'] = latitude;
      if (longitude != null) body['longitude'] = longitude;
      if (isFavorite != null) body['isFavorite'] = isFavorite;

      final response = await ApiClient.put(
        '/locations/$locationId',
        body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return Location.fromJson(data);
      } else {
        throw ApiException(ApiClient.handleError(response), response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to update location: ${e.toString()}', 0);
    }
  }

  // Delete location
  static Future<void> deleteLocation(int locationId) async {
    try {
      final response = await ApiClient.delete('/locations/$locationId');

      if (response.statusCode != 200) {
        throw ApiException(ApiClient.handleError(response), response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to delete location: ${e.toString()}', 0);
    }
  }
}

