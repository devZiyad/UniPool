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

  Future<void> _editVehicle(Vehicle vehicle) async {
    final result = await Navigator.pushNamed(
      context,
      '/vehicles/add',
      arguments: vehicle,
    );
    if (result == true) {
      _loadVehicles();
    }
  }

  Future<void> _deleteVehicle(Vehicle vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text(
          'Are you sure you want to delete ${vehicle.make} ${vehicle.model} (${vehicle.plateNumber})? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await VehicleService.deleteVehicle(vehicle.id);
      if (mounted) {
        _loadVehicles();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting vehicle: $e')),
        );
      }
    }
  }

  Future<void> _activateVehicle(Vehicle vehicle) async {
    try {
      await VehicleService.activateVehicle(vehicle.id);
      if (mounted) {
        _loadVehicles();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${vehicle.make} ${vehicle.model} is now active'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error activating vehicle: $e')),
        );
      }
    }
  }

  Future<void> _deactivateVehicle(Vehicle vehicle) async {
    try {
      await VehicleService.updateVehicle(
        id: vehicle.id,
        active: false,
      );
      if (mounted) {
        _loadVehicles();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${vehicle.make} ${vehicle.model} is now inactive'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deactivating vehicle: $e')),
        );
      }
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
                        child: Column(
                          children: [
                            ListTile(
                          leading: CircleAvatar(
                            backgroundColor: (vehicle.active ?? false)
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
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) async {
                              if (value == 'edit') {
                                await _editVehicle(vehicle);
                              } else if (value == 'delete') {
                                await _deleteVehicle(vehicle);
                              } else if (value == 'activate') {
                                await _activateVehicle(vehicle);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              if (!(vehicle.active ?? false))
                                const PopupMenuItem(
                                  value: 'activate',
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle, size: 20),
                                      SizedBox(width: 8),
                                      Text('Set as Active'),
                                    ],
                                  ),
                                ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 20, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                            ),
                            // Active status switch
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SwitchListTile(
                                      title: Text(
                                        (vehicle.active ?? false) ? 'Active Vehicle' : 'Inactive Vehicle',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: (vehicle.active ?? false)
                                              ? Colors.green
                                              : Colors.grey[600],
                                        ),
                                      ),
                                      subtitle: Text(
                                        (vehicle.active ?? false)
                                            ? 'This vehicle will be used for new rides'
                                            : 'Tap to set as active vehicle',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      value: vehicle.active ?? false,
                                      onChanged: (value) async {
                                        if (value) {
                                          await _activateVehicle(vehicle);
                                        } else {
                                          // Deactivate by setting active to false
                                          await _deactivateVehicle(vehicle);
                                        }
                                      },
                                      secondary: Icon(
                                        (vehicle.active ?? false)
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: (vehicle.active ?? false)
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Set as Active button for inactive vehicles
                            if (!(vehicle.active ?? false))
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  bottom: 12,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _activateVehicle(vehicle),
                                    icon: const Icon(Icons.check_circle),
                                    label: const Text('Set as Active Vehicle'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.green,
                                      side: const BorderSide(color: Colors.green),
                                    ),
                                  ),
                                ),
                              ),
                          ],
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
