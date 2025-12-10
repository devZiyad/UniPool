import 'dart:convert';
import '../models/vehicle.dart';
import '../models/vehicle_type.dart';
import 'api_client.dart';

class VehicleService {
  static Future<Vehicle> createVehicle({
    required String make,
    required String model,
    String? color,
    required String plateNumber,
    required int seatCount,
    required VehicleType vehicleType,
  }) async {
    final response = await ApiClient.post('/vehicles', {
      'make': make,
      'model': model,
      if (color != null) 'color': color,
      'plateNumber': plateNumber,
      'seatCount': seatCount,
      'type': vehicleType.apiValue,
    });

    return Vehicle.fromJson(jsonDecode(response.body));
  }

  static Future<List<Vehicle>> getMyVehicles() async {
    final response = await ApiClient.get('/vehicles/me');
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Vehicle.fromJson(json)).toList();
  }

  static Future<List<Vehicle>> getMyActiveVehicles() async {
    final response = await ApiClient.get('/vehicles/me/active');
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Vehicle.fromJson(json)).toList();
  }

  static Future<Vehicle> getVehicle(int id) async {
    final response = await ApiClient.get('/vehicles/$id');
    return Vehicle.fromJson(jsonDecode(response.body));
  }

  static Future<Vehicle> updateVehicle({
    required int id,
    String? make,
    String? model,
    String? color,
    String? plateNumber,
    int? seatCount,
    bool? active,
    VehicleType? vehicleType,
  }) async {
    final Map<String, dynamic> body = {};
    if (make != null) body['make'] = make;
    if (model != null) body['model'] = model;
    if (color != null) body['color'] = color;
    if (plateNumber != null) body['plateNumber'] = plateNumber;
    if (seatCount != null) body['seatCount'] = seatCount;
    if (active != null) body['active'] = active;
    if (vehicleType != null) body['type'] = vehicleType.apiValue;

    final response = await ApiClient.put('/vehicles/$id', body);
    return Vehicle.fromJson(jsonDecode(response.body));
  }

  static Future<void> deleteVehicle(int id) async {
    final response = await ApiClient.delete('/vehicles/$id');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete vehicle: ${response.statusCode}');
    }
  }

  static Future<Vehicle> activateVehicle(int id) async {
    final response = await ApiClient.put('/vehicles/$id/activate', {});
    return Vehicle.fromJson(jsonDecode(response.body));
  }
}
