import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../services/tracking_service.dart';
import '../../models/ride.dart';
import '../../widgets/map_widget.dart';

class DriverNavigationScreen extends StatefulWidget {
  final Ride ride;

  const DriverNavigationScreen({super.key, required this.ride});

  @override
  State<DriverNavigationScreen> createState() => _DriverNavigationScreenState();
}

class _DriverNavigationScreenState extends State<DriverNavigationScreen> {
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
          MapWidget(
            initialPosition: LatLng(
              widget.ride.pickupLatitude,
              widget.ride.pickupLongitude,
            ),
            zoom: 14,
            markers: [
              Marker(
                point: LatLng(
                  widget.ride.pickupLatitude,
                  widget.ride.pickupLongitude,
                ),
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
              Marker(
                point: LatLng(
                  widget.ride.destinationLatitude,
                  widget.ride.destinationLongitude,
                ),
                width: 40,
                height: 40,
                child: const Icon(Icons.place, color: Colors.red, size: 40),
              ),
            ],
            polylines: [
              Polyline(
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
                strokeWidth: 4,
              ),
            ],
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
