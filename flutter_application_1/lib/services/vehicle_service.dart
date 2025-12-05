import 'dart:convert';
import '../models/vehicle.dart';
import '../services/api_client.dart';

class VehicleService {
  // Register a new vehicle
  static Future<Vehicle> createVehicle({
    required String make,
    required String model,
    String? color,
    required String plateNumber,
    required int seatCount,
  }) async {
    try {
      final response = await ApiClient.post(
        '/vehicles',
        {
          'make': make,
          'model': model,
          if (color != null) 'color': color,
          'plateNumber': plateNumber,
          'seatCount': seatCount,
        },
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return Vehicle.fromJson(data);
      } else {
        throw ApiException(ApiClient.handleError(response), response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to create vehicle: ${e.toString()}', 0);
    }
  }

  // Get all vehicles for current user
  static Future<List<Vehicle>> getMyVehicles() async {
    try {
      final response = await ApiClient.get('/vehicles/me');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        return data.map((json) => Vehicle.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ApiException(ApiClient.handleError(response), response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get vehicles: ${e.toString()}', 0);
    }
  }

  // Get active vehicles
  static Future<List<Vehicle>> getActiveVehicles() async {
    try {
      final response = await ApiClient.get('/vehicles/me/active');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        return data.map((json) => Vehicle.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ApiException(ApiClient.handleError(response), response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get active vehicles: ${e.toString()}', 0);
    }
  }

  // Get vehicle by ID
  static Future<Vehicle> getVehicle(int vehicleId) async {
    try {
      final response = await ApiClient.get('/vehicles/$vehicleId');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return Vehicle.fromJson(data);
      } else {
        throw ApiException(ApiClient.handleError(response), response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get vehicle: ${e.toString()}', 0);
    }
  }

  // Update vehicle
  static Future<Vehicle> updateVehicle({
    required int vehicleId,
    String? make,
    String? model,
    String? color,
    String? plateNumber,
    int? seatCount,
    bool? active,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (make != null) body['make'] = make;
      if (model != null) body['model'] = model;
      if (color != null) body['color'] = color;
      if (plateNumber != null) body['plateNumber'] = plateNumber;
      if (seatCount != null) body['seatCount'] = seatCount;
      if (active != null) body['active'] = active;

      final response = await ApiClient.put(
        '/vehicles/$vehicleId',
        body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return Vehicle.fromJson(data);
      } else {
        throw ApiException(ApiClient.handleError(response), response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to update vehicle: ${e.toString()}', 0);
    }
  }

  // Activate vehicle
  static Future<Vehicle> activateVehicle(int vehicleId) async {
    try {
      final response = await ApiClient.put(
        '/vehicles/$vehicleId/activate',
        {},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return Vehicle.fromJson(data);
      } else {
        throw ApiException(ApiClient.handleError(response), response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to activate vehicle: ${e.toString()}', 0);
    }
  }

  // Delete vehicle
  static Future<void> deleteVehicle(int vehicleId) async {
    try {
      final response = await ApiClient.delete('/vehicles/$vehicleId');

      if (response.statusCode != 200) {
        throw ApiException(ApiClient.handleError(response), response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to delete vehicle: ${e.toString()}', 0);
    }
  }
}

