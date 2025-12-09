import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../providers/ride_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/ride.dart';
import '../../services/booking_service.dart';
import '../../services/location_service.dart';
import '../../widgets/map_widget.dart';
import '../../utils/polyline_decoder.dart';

class RiderRideListScreen extends StatefulWidget {
  const RiderRideListScreen({super.key});

  @override
  State<RiderRideListScreen> createState() => _RiderRideListScreenState();
}

class _RiderRideListScreenState extends State<RiderRideListScreen> {
  Ride? _selectedRide;
  List<LatLng>? _routePoints;

  @override
  void initState() {
    super.initState();
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    final pickup = rideProvider.pickupLocation;
    final destination = rideProvider.destinationLocation;

    if (pickup != null && destination != null) {
      try {
        final routeData = await LocationService.getRoute(
          pickup.latitude,
          pickup.longitude,
          destination.latitude,
          destination.longitude,
        );

        if (routeData != null) {
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

          if (mounted) {
            setState(() {
              _routePoints = decodedPoints;
            });
          }
        }
      } catch (e) {
        print('Error fetching route: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = Provider.of<RideProvider>(context);
    final rides = rideProvider.availableRides;
    final seatsNeeded = rideProvider.seatsNeeded;
    final pickupLocation = rideProvider.pickupLocation;
    final destinationLocation = rideProvider.destinationLocation;

    // Default location (Bahrain center)
    LatLng centerLocation = const LatLng(26.0667, 50.5577);

    // Use pickup location if available, otherwise use destination, otherwise default
    if (pickupLocation != null) {
      centerLocation = LatLng(
        pickupLocation.latitude,
        pickupLocation.longitude,
      );
    } else if (destinationLocation != null) {
      centerLocation = LatLng(
        destinationLocation.latitude,
        destinationLocation.longitude,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Rides'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to time filters screen
            // Check if user is driver or rider to use correct route
            final authProvider = Provider.of<AuthProvider>(
              context,
              listen: false,
            );
            final role = authProvider.user?.role ?? '';
            final isDriver = role == 'DRIVER' || role == 'BOTH';

            if (isDriver) {
              Navigator.pushReplacementNamed(
                context,
                '/driver/post-ride/route-time',
              );
            } else {
              Navigator.pushReplacementNamed(context, '/rider/time-filters');
            }
          },
        ),
      ),
      body: Stack(
        children: [
          // Map background
          MapWidget(
            initialPosition: centerLocation,
            zoom: 13,
            myLocationEnabled: true,
            polylines: _routePoints != null && _routePoints!.isNotEmpty
                ? [
                    Polyline(
                      points: _routePoints!,
                      color: Colors.blue,
                      strokeWidth: 4,
                    ),
                  ]
                : null,
          ),
          // Bottom sheet
          DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Choose your ride',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: rides.length,
                        itemBuilder: (context, index) {
                          final ride = rides[index];
                          final isSelected = _selectedRide?.id == ride.id;
                          final price = (ride.pricePerSeat ?? 0) * seatsNeeded;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.green
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedRide = ride;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.directions_car,
                                      color: isSelected
                                          ? Colors.green
                                          : Colors.grey,
                                      size: 40,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ride.driverName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${price.toStringAsFixed(2)} BHD',
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${ride.estimatedDurationMinutes ?? 0}m to arrive',
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.people,
                                                size: 16,
                                              ),
                                              Text(
                                                '${ride.availableSeats} Seats',
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Request button
                          ElevatedButton(
                            onPressed: _selectedRide == null
                                ? null
                                : () async {
                                    try {
                                      // Get required data from ride
                                      final ride = _selectedRide!;
                                      final pickupLocationId =
                                          ride.pickupLocationId;
                                      final dropoffLocationId =
                                          ride.destinationLocationId;

                                      // Use the ride's departure time range for pickup time
                                      // Note: ride times are stored in local time (converted from UTC API response)
                                      // but we need to send UTC times to the API
                                      var pickupTimeStart =
                                          ride.departureTimeStart ??
                                          ride.departureTime;
                                      var pickupTimeEnd =
                                          ride.departureTimeEnd ??
                                          ride.departureTime;

                                      // Ensure pickupTimeStart is in the future (check in UTC since API validates in UTC)
                                      // API requires pickupTimeStart to be in the future when converted to UTC
                                      final nowUtc = DateTime.now().toUtc();
                                      final pickupTimeStartUtc = pickupTimeStart
                                          .toUtc();

                                      if (pickupTimeStartUtc.isBefore(nowUtc) ||
                                          pickupTimeStartUtc.isAtSameMomentAs(
                                            nowUtc,
                                          )) {
                                        // If the ride's departure time is in the past (in UTC), use current UTC time + 2 minutes
                                        // Add buffer to account for any timezone differences
                                        final futureUtc = nowUtc.add(
                                          const Duration(minutes: 2),
                                        );
                                        pickupTimeStart = futureUtc.toLocal();

                                        // Adjust pickupTimeEnd to maintain the same duration from original times
                                        final originalDuration = pickupTimeEnd
                                            .difference(
                                              ride.departureTimeStart ??
                                                  ride.departureTime,
                                            );
                                        pickupTimeEnd = pickupTimeStart.add(
                                          originalDuration,
                                        );

                                        // Ensure minimum 1 minute difference
                                        if (pickupTimeEnd.isAtSameMomentAs(
                                              pickupTimeStart,
                                            ) ||
                                            pickupTimeEnd.isBefore(
                                              pickupTimeStart,
                                            )) {
                                          pickupTimeEnd = pickupTimeStart.add(
                                            const Duration(minutes: 1),
                                          );
                                        }
                                      }

                                      // If both times are the same (no time range), add a small buffer
                                      // to ensure pickupTimeEnd is after pickupTimeStart
                                      if (pickupTimeStart.isAtSameMomentAs(
                                        pickupTimeEnd,
                                      )) {
                                        pickupTimeEnd = pickupTimeEnd.add(
                                          const Duration(minutes: 1),
                                        );
                                      }

                                      // Ensure pickupTimeEnd is after pickupTimeStart
                                      if (pickupTimeEnd.isBefore(
                                        pickupTimeStart,
                                      )) {
                                        // Swap if they're in wrong order
                                        final temp = pickupTimeStart;
                                        pickupTimeStart = pickupTimeEnd;
                                        pickupTimeEnd = temp;
                                      }

                                      // Final check: ensure pickupTimeStart is still in the future (in UTC)
                                      // The BookingService will convert these local times to UTC before sending
                                      final finalNowUtc = DateTime.now()
                                          .toUtc();
                                      final finalPickupTimeStartUtc =
                                          pickupTimeStart.toUtc();
                                      if (finalPickupTimeStartUtc.isBefore(
                                            finalNowUtc,
                                          ) ||
                                          finalPickupTimeStartUtc
                                              .isAtSameMomentAs(finalNowUtc)) {
                                        // Use current UTC + 2 minutes to ensure it's in the future
                                        final futureUtc = finalNowUtc.add(
                                          const Duration(minutes: 2),
                                        );
                                        pickupTimeStart = futureUtc.toLocal();
                                        if (pickupTimeEnd.isBefore(
                                              pickupTimeStart,
                                            ) ||
                                            pickupTimeEnd.isAtSameMomentAs(
                                              pickupTimeStart,
                                            )) {
                                          pickupTimeEnd = pickupTimeStart.add(
                                            const Duration(minutes: 1),
                                          );
                                        }
                                      }

                                      print('Creating booking with:');
                                      print('  rideId: ${ride.id}');
                                      print(
                                        '  pickupLocationId: $pickupLocationId',
                                      );
                                      print(
                                        '  dropoffLocationId: $dropoffLocationId',
                                      );
                                      print(
                                        '  pickupTimeStart: ${pickupTimeStart.toIso8601String()}',
                                      );
                                      print(
                                        '  pickupTimeEnd: ${pickupTimeEnd.toIso8601String()}',
                                      );
                                      print(
                                        '  Ride departureTimeStart: ${ride.departureTimeStart?.toIso8601String()}',
                                      );
                                      print(
                                        '  Ride departureTimeEnd: ${ride.departureTimeEnd?.toIso8601String()}',
                                      );

                                      final booking =
                                          await BookingService.createBooking(
                                            rideId: ride.id,
                                            seats: seatsNeeded,
                                            pickupLocationId: pickupLocationId,
                                            dropoffLocationId:
                                                dropoffLocationId,
                                            pickupTimeStart: pickupTimeStart,
                                            pickupTimeEnd: pickupTimeEnd,
                                          );

                                      // Backend should automatically create a notification for the driver
                                      // Type: BOOKING_REQUESTED
                                      // Title: "New Booking Request"
                                      // Body: "A rider has requested to join your ride #${ride.id}"
                                      print(
                                        'Booking created: ${booking.id}. Driver (ID: ${ride.driverId}) should receive notification.',
                                      );

                                      if (mounted) {
                                        Navigator.pushNamed(
                                          context,
                                          '/rider/bookings',
                                        );
                                      }
                                    } catch (e) {
                                      print('Booking error: $e');
                                      if (mounted) {
                                        // Extract error message
                                        String errorMessage =
                                            'Failed to create booking';
                                        if (e.toString().contains(
                                          'Exception:',
                                        )) {
                                          errorMessage = e
                                              .toString()
                                              .replaceFirst('Exception: ', '');
                                        } else {
                                          errorMessage = e.toString();
                                        }

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(errorMessage),
                                            backgroundColor: Colors.red,
                                            duration: const Duration(
                                              seconds: 5,
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Request',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
