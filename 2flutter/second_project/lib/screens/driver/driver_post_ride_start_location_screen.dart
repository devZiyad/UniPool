import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/driver_provider.dart';
import '../../services/location_service.dart';
import '../../models/location.dart';

class DriverPostRideStartLocationScreen extends StatefulWidget {
  const DriverPostRideStartLocationScreen({super.key});

  @override
  State<DriverPostRideStartLocationScreen> createState() =>
      _DriverPostRideStartLocationScreenState();
}

class _DriverPostRideStartLocationScreenState
    extends State<DriverPostRideStartLocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Location> _suggestions = [];
  GoogleMapController? _mapController;
  LatLng _currentLocation = const LatLng(26.0667, 50.5577);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchLocations(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    try {
      final locations = await LocationService.searchLocations(query);
      setState(() {
        _suggestions = locations;
      });
    } catch (e) {
      // Handle error
    }
  }

  void _selectStartLocation(Location location) {
    Provider.of<DriverProvider>(
      context,
      listen: false,
    ).setPickupLocation(location);
    Navigator.pushNamed(context, '/driver/post-ride/route-time');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 14,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            myLocationEnabled: true,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Where are you going from today?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search destinations',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: _searchLocations,
                  ),
                  if (_suggestions.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          final location = _suggestions[index];
                          return ListTile(
                            leading: const Icon(
                              Icons.location_on,
                              color: Colors.grey,
                            ),
                            title: Text(location.label),
                            subtitle: Text(location.address ?? ''),
                            onTap: () => _selectStartLocation(location),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
