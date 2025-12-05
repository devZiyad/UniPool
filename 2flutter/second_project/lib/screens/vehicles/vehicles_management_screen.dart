import 'package:flutter/material.dart';
import '../../models/vehicle.dart';
import '../../services/vehicle_service.dart';
import '../../widgets/app_drawer.dart';

class VehiclesManagementScreen extends StatefulWidget {
  const VehiclesManagementScreen({super.key});

  @override
  State<VehiclesManagementScreen> createState() =>
      _VehiclesManagementScreenState();
}

class _VehiclesManagementScreenState extends State<VehiclesManagementScreen> {
  List<Vehicle> _vehicles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final vehicles = await VehicleService.getMyVehicles();
      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading vehicles: $e')));
      }
    }
  }

  Future<void> _addVehicle() async {
    final result = await Navigator.pushNamed(context, '/vehicles/add');
    if (result == true) {
      _loadVehicles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Vehicles')),
      drawer: AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vehicles.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.directions_car_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No vehicles found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add your first vehicle to start posting rides',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _addVehicle,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Vehicle'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _vehicles.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final vehicle = _vehicles[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: vehicle.active
                                ? Colors.green
                                : Colors.grey,
                            child: const Icon(
                              Icons.directions_car,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            '${vehicle.make} ${vehicle.model}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Plate: ${vehicle.plateNumber}'),
                              if (vehicle.color != null)
                                Text('Color: ${vehicle.color}'),
                              Text('Seats: ${vehicle.seatCount}'),
                              Row(
                                children: [
                                  Icon(
                                    vehicle.active
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    size: 16,
                                    color: vehicle.active
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    vehicle.active ? 'Active' : 'Inactive',
                                    style: TextStyle(
                                      color: vehicle.active
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              // TODO: Navigate to edit vehicle
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: _addVehicle,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Vehicle'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
