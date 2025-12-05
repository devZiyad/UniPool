import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/tracking_service.dart';
import '../../models/ride.dart';

class RiderLiveTrackingScreen extends StatefulWidget {
  final Ride ride;

  const RiderLiveTrackingScreen({super.key, required this.ride});

  @override
  State<RiderLiveTrackingScreen> createState() =>
      _RiderLiveTrackingScreenState();
}

class _RiderLiveTrackingScreenState extends State<RiderLiveTrackingScreen> {
  GoogleMapController? _mapController;
  LatLng? _driverLocation;

  @override
  void initState() {
    super.initState();
    _pollDriverLocation();
  }

  void _pollDriverLocation() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        TrackingService.getCurrentLocation(widget.ride.id).then((data) {
          setState(() {
            _driverLocation = LatLng(
              data['latitude'] as double,
              data['longitude'] as double,
            );
          });
          _pollDriverLocation();
        });
      }
    });
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
              if (_driverLocation != null)
                Marker(
                  markerId: const MarkerId('driver'),
                  position: _driverLocation!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                ),
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
                  Text(
                    'Your Ride is arriving in 3 mins',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.ride.driverName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                Text('${widget.ride.driverRating ?? 0.0}'),
                              ],
                            ),
                            Text(
                              '${widget.ride.vehicleMake} - ${widget.ride.vehiclePlateNumber}',
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.phone, color: Colors.green),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.message, color: Colors.green),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.green),
                      Expanded(child: Text(widget.ride.pickupLocationLabel)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.black),
                      Expanded(
                        child: Text(widget.ride.destinationLocationLabel),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Cancel ride
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancel Ride'),
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
