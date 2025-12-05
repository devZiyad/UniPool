import 'dart:convert';
import '../models/vehicle.dart';
import 'api_client.dart';

class VehicleService {
  static Future<Vehicle> createVehicle({
    required String make,
    required String model,
    String? color,
    required String plateNumber,
    required int seatCount,
  }) async {
    final response = await ApiClient.post('/vehicles', {
      'make': make,
      'model': model,
      if (color != null) 'color': color,
      'plateNumber': plateNumber,
      'seatCount': seatCount,
    });

    return Vehicle.fromJson(jsonDecode(response.body));
  }

  static Future<List<Vehicle>> getMyVehicles() async {
    final response = await ApiClient.get('/vehicles/me');
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Vehicle.fromJson(json)).toList();
  }

  static Future<Vehicle> getVehicle(int id) async {
    final response = await ApiClient.get('/vehicles/$id');
    return Vehicle.fromJson(jsonDecode(response.body));
  }
}
