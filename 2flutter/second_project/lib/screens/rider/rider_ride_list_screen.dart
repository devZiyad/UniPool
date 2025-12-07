import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ride_provider.dart';
import '../../models/ride.dart';
import '../../services/booking_service.dart';

class RiderRideListScreen extends StatefulWidget {
  const RiderRideListScreen({super.key});

  @override
  State<RiderRideListScreen> createState() => _RiderRideListScreenState();
}

class _RiderRideListScreenState extends State<RiderRideListScreen> {
  Ride? _selectedRide;
  int _seatsNeeded = 2;

  @override
  Widget build(BuildContext context) {
    final rideProvider = Provider.of<RideProvider>(context);
    final rides = rideProvider.availableRides;

    return Scaffold(
      body: Stack(
        children: [
          // Map background
          Container(
            color: Colors.grey[200],
            child: const Center(child: Text('Map View')),
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
                          final price = (ride.pricePerSeat ?? 0) * _seatsNeeded;

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
                          // Seats selector
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    if (_seatsNeeded > 1) {
                                      setState(() {
                                        _seatsNeeded--;
                                      });
                                    }
                                  },
                                ),
                                Text(
                                  '$_seatsNeeded seats',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    if (_selectedRide != null &&
                                        _seatsNeeded <
                                            _selectedRide!.availableSeats) {
                                      setState(() {
                                        _seatsNeeded++;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Request button
                          ElevatedButton(
                            onPressed: _selectedRide == null
                                ? null
                                : () async {
                                    try {
                                      // Get required data from ride
                                      final ride = _selectedRide!;
                                      final pickupLocationId = ride.pickupLocationId;
                                      final dropoffLocationId = ride.destinationLocationId;
                                      
                                      // Use the ride's departure time range for pickup time
                                      // The pickup time must be within the ride's departure time range
                                      var pickupTimeStart = ride.departureTimeStart ?? ride.departureTime;
                                      var pickupTimeEnd = ride.departureTimeEnd ?? ride.departureTime;
                                      
                                      // Ensure pickupTimeStart is in the future (check in UTC since API validates in UTC)
                                      // API requires pickupTimeStart to be in the future when converted to UTC
                                      final nowUtc = DateTime.now().toUtc();
                                      final pickupTimeStartUtc = pickupTimeStart.toUtc();
                                      
                                      if (pickupTimeStartUtc.isBefore(nowUtc) || pickupTimeStartUtc.isAtSameMomentAs(nowUtc)) {
                                        // If the ride's departure time is in the past (in UTC), use current UTC time + 2 minutes
                                        // Add buffer to account for any timezone differences
                                        final futureUtc = nowUtc.add(const Duration(minutes: 2));
                                        pickupTimeStart = futureUtc.toLocal();
                                        
                                        // Adjust pickupTimeEnd to maintain the same duration from original times
                                        final originalDuration = pickupTimeEnd.difference(ride.departureTimeStart ?? ride.departureTime);
                                        pickupTimeEnd = pickupTimeStart.add(originalDuration);
                                        
                                        // Ensure minimum 1 minute difference
                                        if (pickupTimeEnd.isAtSameMomentAs(pickupTimeStart) || pickupTimeEnd.isBefore(pickupTimeStart)) {
                                          pickupTimeEnd = pickupTimeStart.add(const Duration(minutes: 1));
                                        }
                                      }
                                      
                                      // If both times are the same (no time range), add a small buffer
                                      // to ensure pickupTimeEnd is after pickupTimeStart
                                      if (pickupTimeStart.isAtSameMomentAs(pickupTimeEnd)) {
                                        pickupTimeEnd = pickupTimeEnd.add(const Duration(minutes: 1));
                                      }
                                      
                                      // Ensure pickupTimeEnd is after pickupTimeStart
                                      if (pickupTimeEnd.isBefore(pickupTimeStart)) {
                                        // Swap if they're in wrong order
                                        final temp = pickupTimeStart;
                                        pickupTimeStart = pickupTimeEnd;
                                        pickupTimeEnd = temp;
                                      }
                                      
                                      // Final check: ensure pickupTimeStart is still in the future (in UTC)
                                      final finalNowUtc = DateTime.now().toUtc();
                                      final finalPickupTimeStartUtc = pickupTimeStart.toUtc();
                                      if (finalPickupTimeStartUtc.isBefore(finalNowUtc) || finalPickupTimeStartUtc.isAtSameMomentAs(finalNowUtc)) {
                                        // Use current UTC + 2 minutes to ensure it's in the future
                                        final futureUtc = finalNowUtc.add(const Duration(minutes: 2));
                                        pickupTimeStart = futureUtc.toLocal();
                                        if (pickupTimeEnd.isBefore(pickupTimeStart) || pickupTimeEnd.isAtSameMomentAs(pickupTimeStart)) {
                                          pickupTimeEnd = pickupTimeStart.add(const Duration(minutes: 1));
                                        }
                                      }
                                      
                                      print('Creating booking with:');
                                      print('  rideId: ${ride.id}');
                                      print('  pickupLocationId: $pickupLocationId');
                                      print('  dropoffLocationId: $dropoffLocationId');
                                      print('  pickupTimeStart: ${pickupTimeStart.toIso8601String()}');
                                      print('  pickupTimeEnd: ${pickupTimeEnd.toIso8601String()}');
                                      print('  Ride departureTimeStart: ${ride.departureTimeStart?.toIso8601String()}');
                                      print('  Ride departureTimeEnd: ${ride.departureTimeEnd?.toIso8601String()}');
                                      
                                      await BookingService.createBooking(
                                        rideId: ride.id,
                                        seats: _seatsNeeded,
                                        pickupLocationId: pickupLocationId,
                                        dropoffLocationId: dropoffLocationId,
                                        pickupTimeStart: pickupTimeStart,
                                        pickupTimeEnd: pickupTimeEnd,
                                      );
                                      if (mounted) {
                                        Navigator.pushNamed(
                                          context,
                                          '/rider/pending-approval',
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(e.toString()),
                                            backgroundColor: Colors.red,
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
