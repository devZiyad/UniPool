import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/tracking_service.dart';
import '../../models/ride.dart';

class DriverNavigationScreen extends StatefulWidget {
  final Ride ride;

  const DriverNavigationScreen({super.key, required this.ride});

  @override
  State<DriverNavigationScreen> createState() => _DriverNavigationScreenState();
}

class _DriverNavigationScreenState extends State<DriverNavigationScreen> {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    TrackingService.startTracking(widget.ride.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                widget.ride.pickupLatitude,
                widget.ride.pickupLongitude,
              ),
              zoom: 14,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            markers: {
              Marker(
                markerId: const MarkerId('pickup'),
                position: LatLng(
                  widget.ride.pickupLatitude,
                  widget.ride.pickupLongitude,
                ),
              ),
              Marker(
                markerId: const MarkerId('destination'),
                position: LatLng(
                  widget.ride.destinationLatitude,
                  widget.ride.destinationLongitude,
                ),
              ),
            },
            polylines: {
              Polyline(
                polylineId: const PolylineId('route'),
                points: [
                  LatLng(
                    widget.ride.pickupLatitude,
                    widget.ride.pickupLongitude,
                  ),
                  LatLng(
                    widget.ride.destinationLatitude,
                    widget.ride.destinationLongitude,
                  ),
                ],
                color: Colors.green,
                width: 4,
              ),
            },
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Column(
                    children: [
                      CircleAvatar(),
                      SizedBox(height: 4),
                      Text('Hello John'),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          Text('4.0'),
                        ],
                      ),
                    ],
                  ),
                  const Text(
                    '+10 Min',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    '2 Seats',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
