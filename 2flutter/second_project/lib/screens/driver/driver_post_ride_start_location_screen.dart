import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/driver_provider.dart';
import '../../services/location_service.dart';
import '../../models/location.dart';
import '../../widgets/map_widget.dart';
import '../../widgets/app_drawer.dart';
import '../../utils/polyline_decoder.dart';

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
  MapController? _mapController;
  LatLng _currentLocation = const LatLng(26.0667, 50.5577);
  LatLng? _selectedLocation;
  bool _isLoadingLocation = false;
  bool _isInitializing = true;
  List<LatLng>? _routePoints;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isInitializing = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isInitializing = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isInitializing = false;
        });
        return;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(const Duration(seconds: 10));

        final currentLatLng = LatLng(position.latitude, position.longitude);

        // Create location directly from coordinates (skip SerpApi)
        final location = Location(
          id: null,
          label: 'Current Location',
          address:
              '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
          latitude: position.latitude,
          longitude: position.longitude,
          userId: null,
          isFavorite: false,
        );

        setState(() {
          _currentLocation = currentLatLng;
          _selectedLocation = currentLatLng;
          _searchController.text =
              '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
          _suggestions = [location];
          _isInitializing = false;
        });

        // Set as pickup location by default
        Provider.of<DriverProvider>(
          context,
          listen: false,
        ).setPickupLocation(location);

        _mapController?.move(currentLatLng, 14);
      } else {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

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

  Future<void> _onMapTap(LatLng point) async {
    setState(() {
      _selectedLocation = point;
      _isLoadingLocation = true;
    });

    // Get address using reverse geocoding
    String address =
        '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}';
    try {
      address = await LocationService.reverseGeocode(
        point.latitude,
        point.longitude,
      );
    } catch (e) {
      // Keep default coordinates if reverse geocoding fails
    }

    final location = Location(
      id: null,
      label: 'Selected Location',
      address: address,
      latitude: point.latitude,
      longitude: point.longitude,
      userId: null,
      isFavorite: false,
    );

    setState(() {
      _searchController.text = address;
      _suggestions = [location];
      _isLoadingLocation = false;
    });
  }

  void _selectStartLocation(Location location) {
    Provider.of<DriverProvider>(
      context,
      listen: false,
    ).setPickupLocation(location);
    _fetchRouteIfReady();
    Navigator.pushNamed(context, '/driver/post-ride/route-time');
  }

  Future<void> _fetchRouteIfReady() async {
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    final pickup = driverProvider.pickupLocation;
    final destination = driverProvider.destinationLocation;

    if (pickup != null && destination != null) {
      try {
        final routeData = await LocationService.getRoute(
          pickup.latitude,
          pickup.longitude,
          destination.latitude,
          destination.longitude,
        );

        if (routeData != null) {
          final routeId = routeData['routeId'];
          final routeIdInt = routeId is int
              ? routeId
              : (routeId != null ? int.tryParse(routeId.toString()) : null);

          // Store routeId in provider
          Provider.of<DriverProvider>(
            context,
            listen: false,
          ).setRouteId(routeIdInt);

          List<LatLng>? decodedPoints;

          // Check if we have encoded polyline string
          if (routeData['routePolyline'] != null) {
            final polyline = routeData['routePolyline'] as String;
            decodedPoints = decodePolyline(polyline);
          }
          // Check if we have GeoJSON coordinates
          else if (routeData['coordinates'] != null) {
            final coords = routeData['coordinates'] as List<List<double>>;
            decodedPoints = coords.map((coord) {
              // GeoJSON format is [longitude, latitude]
              return LatLng(coord[1], coord[0]);
            }).toList();
          }

          setState(() {
            _routePoints = decodedPoints;
          });
        } else {
          Provider.of<DriverProvider>(context, listen: false).setRouteId(null);
          setState(() {
            _routePoints = null;
          });
        }
      } catch (e) {
        print('Error fetching route: $e');
        Provider.of<DriverProvider>(context, listen: false).setRouteId(null);
        setState(() {
          _routePoints = null;
        });
      }
    } else {
      Provider.of<DriverProvider>(context, listen: false).setRouteId(null);
      setState(() {
        _routePoints = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Select Start Location')),
      drawer: AppDrawer(),
      body: Stack(
        children: [
          MapWidget(
            initialPosition: _currentLocation,
            zoom: 14,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            myLocationEnabled: true,
            onTap: _onMapTap,
            markers: _selectedLocation != null
                ? [
                    Marker(
                      point: _selectedLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  ]
                : null,
            // Hide route on start location selection screen
            polylines: null,
          ),
          // Center pin indicator (only show when no location selected)
          if (_selectedLocation == null)
            const Center(
              child: Icon(Icons.location_on, color: Colors.blue, size: 40),
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
                  const SizedBox(height: 8),
                  const Text(
                    'Tap on the map or search to change location',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search start location',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _isLoadingLocation
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : null,
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _selectedLocation != null
                        ? () {
                            if (_suggestions.isNotEmpty) {
                              _selectStartLocation(_suggestions.first);
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Confirm Location'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
