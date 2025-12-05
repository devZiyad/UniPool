import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

/// A wrapper widget that uses flutter_map with OpenStreetMap
class MapWidget extends StatefulWidget {
  final LatLng initialPosition;
  final double zoom;
  final Function(MapController)? onMapCreated;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;
  final List<Marker>? markers;
  final List<Polyline>? polylines;
  final Function(LatLng)? onTap;

  const MapWidget({
    super.key,
    required this.initialPosition,
    this.zoom = 14.0,
    this.onMapCreated,
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = false,
    this.markers,
    this.polylines,
    this.onTap,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final MapController _mapController = MapController();
  LatLng _currentPosition = const LatLng(26.0667, 50.5577); // Bahrain default
  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.initialPosition;
    if (widget.onMapCreated != null) {
      widget.onMapCreated!(_mapController);
    }
    if (widget.myLocationEnabled) {
      _requestLocationPermission();
    }
  }

  Future<void> _requestLocationPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      // Permission granted, get current location
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        try {
          Position position =
              await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high,
              ).timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  throw Exception('Location request timed out');
                },
              );
          setState(() {
            _currentPosition = LatLng(position.latitude, position.longitude);
            _locationPermissionGranted = true;
            // Center map on current location
            _mapController.move(_currentPosition, widget.zoom);
          });
        } catch (e) {
          // If location fails, use initial position (Bahrain default)
          setState(() {
            _locationPermissionGranted = false;
          });
        }
      }
    } catch (e) {
      // Handle errors silently, use default position
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentPosition,
        initialZoom: widget.zoom,
        minZoom: 3.0,
        maxZoom: 18.0,
        onTap: widget.onTap != null
            ? (tapPosition, point) {
                widget.onTap!(point);
              }
            : null,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.second_project',
        ),
        if (widget.markers != null) MarkerLayer(markers: widget.markers!),
        if (widget.polylines != null)
          PolylineLayer(polylines: widget.polylines!),
        if (widget.myLocationButtonEnabled && _locationPermissionGranted)
          RichAttributionWidget(
            alignment: AttributionAlignment.bottomRight,
            attributions: [
              TextSourceAttribution('OpenStreetMap contributors', onTap: () {}),
            ],
          ),
      ],
    );
  }
}
