import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/ride.dart';
import '../../services/ride_service.dart';
import '../../services/location_service.dart';
import '../../services/notification_service.dart';
import '../../providers/driver_provider.dart';

class DriverRideChecklistScreen extends StatefulWidget {
  final Ride ride;

  const DriverRideChecklistScreen({super.key, required this.ride});

  @override
  State<DriverRideChecklistScreen> createState() =>
      _DriverRideChecklistScreenState();
}

class _DriverRideChecklistScreenState extends State<DriverRideChecklistScreen> {
  final Map<int, bool> _completedStops = {};
  List<Map<String, dynamic>> _stops = [];
  bool _isLoading = true;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _loadStops();
  }

  Future<void> _loadStops() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final driverProvider = Provider.of<DriverProvider>(
        context,
        listen: false,
      );
      await driverProvider.loadBookingsForRide(widget.ride.id);

      final bookings = driverProvider.acceptedBookings;
      final stops = <Map<String, dynamic>>[];

      // Add driver's start location as first stop
      String driverStartAddress = widget.ride.pickupLocationLabel;
      try {
        driverStartAddress = await LocationService.reverseGeocode(
          widget.ride.pickupLatitude,
          widget.ride.pickupLongitude,
        );
      } catch (e) {
        // Keep default label if reverse geocoding fails
      }

      stops.add({
        'type': 'driver_start',
        'label': 'Your Start Location',
        'address': driverStartAddress.isNotEmpty
            ? driverStartAddress
            : 'Unknown location',
        'latitude': widget.ride.pickupLatitude,
        'longitude': widget.ride.pickupLongitude,
        'bookingId': null,
        'riderName': null,
      });

      // Add each rider's pickup location
      for (final booking in bookings) {
        String? riderPickupAddress;
        try {
          if (booking.pickupLatitude != null &&
              booking.pickupLongitude != null) {
            riderPickupAddress = await LocationService.reverseGeocode(
              booking.pickupLatitude!,
              booking.pickupLongitude!,
            );
          } else {
            riderPickupAddress = booking.pickupLocationLabel;
          }
        } catch (e) {
          riderPickupAddress =
              booking.pickupLocationLabel ?? 'Unknown location';
        }

        final pickupLat = booking.pickupLatitude ?? widget.ride.pickupLatitude;
        final pickupLon =
            booking.pickupLongitude ?? widget.ride.pickupLongitude;

        stops.add({
          'type': 'rider_pickup',
          'label': '${booking.riderName}\'s Pickup',
          'address': riderPickupAddress ?? 'Unknown location',
          'latitude': pickupLat,
          'longitude': pickupLon,
          'bookingId': booking.id,
          'riderName': booking.riderName,
        });
      }

      // Add final destination
      String destinationAddress = widget.ride.destinationLocationLabel;
      try {
        destinationAddress = await LocationService.reverseGeocode(
          widget.ride.destinationLatitude,
          widget.ride.destinationLongitude,
        );
      } catch (e) {
        // Keep default label if reverse geocoding fails
      }

      stops.add({
        'type': 'destination',
        'label': 'Final Destination',
        'address': destinationAddress.isNotEmpty
            ? destinationAddress
            : 'Unknown location',
        'latitude': widget.ride.destinationLatitude,
        'longitude': widget.ride.destinationLongitude,
        'bookingId': null,
        'riderName': null,
      });

      setState(() {
        _stops = stops;
        // Initialize all stops as not completed
        for (int i = 0; i < stops.length; i++) {
          _completedStops[i] = false;
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading stops: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading stops: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _buildGoogleMapsUrl() {
    if (_stops.isEmpty) return '';

    // Build waypoints (all stops except origin and destination)
    final waypoints = <String>[];
    for (int i = 1; i < _stops.length - 1; i++) {
      final stop = _stops[i];
      waypoints.add('${stop['latitude']},${stop['longitude']}');
    }

    // Origin is first stop, destination is last stop
    final origin = '${_stops.first['latitude']},${_stops.first['longitude']}';
    final destination =
        '${_stops.last['latitude']},${_stops.last['longitude']}';

    String url = 'https://www.google.com/maps/dir/?api=1';
    url += '&origin=$origin';
    url += '&destination=$destination';
    if (waypoints.isNotEmpty) {
      url += '&waypoints=${waypoints.join('|')}';
    }

    return url;
  }

  Future<void> _openGoogleMapsForStop(int index) async {
    final stop = _stops[index];
    final url =
        'https://www.google.com/maps/search/?api=1&query=${stop['latitude']},${stop['longitude']}';

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open Google Maps')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  Future<void> _openAllStopsInGoogleMaps() async {
    final url = _buildGoogleMapsUrl();
    if (url.isEmpty) return;

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open Google Maps')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  Future<void> _confirmRideDone() async {
    final allCompleted = _completedStops.values.every((completed) => completed);
    if (!allCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all stops before confirming'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Ride Complete'),
        content: const Text(
          'Are you sure the ride is complete? This will mark the ride as completed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isCompleting = true;
    });

    try {
      await RideService.updateRideStatus(widget.ride.id, 'COMPLETED');

      // Send notifications to all riders that the ride is completed
      final driverProvider = Provider.of<DriverProvider>(
        context,
        listen: false,
      );
      await driverProvider.loadBookingsForRide(widget.ride.id);
      final bookings = driverProvider.acceptedBookings;

      final riderIds = bookings.map((b) => b.riderId).toList();
      if (riderIds.isNotEmpty) {
        try {
          await NotificationService.notifyRidersInRide(
            rideId: widget.ride.id,
            riderIds: riderIds,
            title: 'Ride Completed',
            body: 'Your ride has been completed. Please rate your driver.',
          );
        } catch (e) {
          print('Error sending completion notifications: $e');
          // Continue even if notifications fail
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ride marked as completed'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing ride: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ride Checklist')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _stops.length,
                    itemBuilder: (context, index) {
                      final stop = _stops[index];
                      final isCompleted = _completedStops[index] ?? false;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: CheckboxListTile(
                          value: isCompleted,
                          onChanged: (value) {
                            setState(() {
                              _completedStops[index] = value ?? false;
                            });
                          },
                          title: Text(
                            stop['label'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(stop['address'] as String),
                              if (stop['riderName'] != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Rider: ${stop['riderName']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _openGoogleMapsForStop(index),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.map,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Open in Google Maps',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          secondary: Icon(
                            index == 0
                                ? Icons.location_on
                                : index == _stops.length - 1
                                ? Icons.place
                                : Icons.person_pin,
                            color: isCompleted ? Colors.green : Colors.blue,
                            size: 32,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: _openAllStopsInGoogleMaps,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.map, color: Colors.blue),
                                const SizedBox(width: 8),
                                const Text(
                                  'Open All Stops in Google Maps',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _isCompleting ? null : _confirmRideDone,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: _isCompleting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text('Confirm Ride Done'),
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
