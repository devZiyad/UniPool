import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../providers/ride_provider.dart';
import '../../services/location_service.dart';
import '../../models/location.dart';
import '../../widgets/map_widget.dart';

class RiderDestinationSearchScreen extends StatefulWidget {
  const RiderDestinationSearchScreen({super.key});

  @override
  State<RiderDestinationSearchScreen> createState() =>
      _RiderDestinationSearchScreenState();
}

class _RiderDestinationSearchScreenState
    extends State<RiderDestinationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Location> _suggestions = [];
  MapController? _mapController;
  LatLng _currentLocation = const LatLng(26.0667, 50.5577); // Bahrain default

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchDestinations(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    try {
      final locations = await LocationService.searchLocations(
        query,
        latitude: _currentLocation.latitude,
        longitude: _currentLocation.longitude,
      );
      setState(() {
        _suggestions = locations;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error searching: $e')));
      }
    }
  }

  void _selectDestination(Location location) {
    Provider.of<RideProvider>(
      context,
      listen: false,
    ).setDestinationLocation(location);
    Navigator.pushNamed(context, '/rider/start-location');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          MapWidget(
            initialPosition: _currentLocation,
            zoom: 14,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          // Search overlay
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
                    'Where are you going today?',
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
                    onChanged: _searchDestinations,
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
                            onTap: () => _selectDestination(location),
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
