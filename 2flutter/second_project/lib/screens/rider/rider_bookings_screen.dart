import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/booking_service.dart';
import '../../services/ride_service.dart';
import '../../services/rating_service.dart';
import '../../models/booking.dart';
import '../../models/ride.dart';
import '../../widgets/app_drawer.dart';

class RiderBookingsScreen extends StatefulWidget {
  final bool showInTabBar;

  const RiderBookingsScreen({super.key, this.showInTabBar = false});

  @override
  State<RiderBookingsScreen> createState() => _RiderBookingsScreenState();
}

class _RiderBookingsScreenState extends State<RiderBookingsScreen> {
  List<Booking> _bookings = [];
  Map<int, Ride> _rideDetails = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bookings = await BookingService.getMyBookings();

      // Fetch ride details for each booking
      final rideDetailsMap = <int, Ride>{};
      for (final booking in bookings) {
        try {
          final ride = await RideService.getRide(booking.rideId);
          rideDetailsMap[booking.rideId] = ride;
        } catch (e) {
          print(
            'Error loading ride ${booking.rideId} for booking ${booking.id}: $e',
          );
        }
      }

      // Filter out bookings where the ride is cancelled or completed
      // But check for completed rides that need rating
      final validBookings = <Booking>[];
      Booking? completedBookingNeedingRating;

      for (final booking in bookings) {
        final ride = rideDetailsMap[booking.rideId];
        if (ride == null) {
          // If we couldn't load the ride, skip it
          continue;
        }

        final rideStatus = ride.status.toUpperCase();

        // Skip cancelled rides
        if (rideStatus == 'CANCELLED') {
          continue;
        }

        // Check if booking is completed and needs rating
        // (Bookings are now marked as COMPLETED when ride is completed)
        if (booking.status.toUpperCase() == 'COMPLETED') {
          // Check if rating already exists
          final hasRating = await RatingService.hasRatingForBooking(booking.id);
          if (!hasRating) {
            // This booking needs rating - store it for navigation
            completedBookingNeedingRating ??= booking;
            // Don't add to validBookings - completed bookings shouldn't show in bookings list
            continue;
          }
        }

        // Only show PENDING and CONFIRMED bookings (not completed)
        if (booking.status.toUpperCase() == 'PENDING' ||
            booking.status.toUpperCase() == 'CONFIRMED') {
          validBookings.add(booking);
        }
      }

      if (mounted) {
        setState(() {
          _bookings = validBookings;
          _rideDetails = rideDetailsMap;
          _isLoading = false;
        });

        // Navigate to rating screen if there's a completed booking that needs rating
        if (completedBookingNeedingRating != null) {
          // Small delay to ensure UI is ready
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.pushNamed(
                context,
                '/rider/rating',
                arguments: completedBookingNeedingRating,
              );
            }
          });
        }
      }
    } catch (e) {
      print('Error loading bookings: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _formatTimeRange(DateTime? start, DateTime? end, DateTime? fallback) {
    if (start == null && end == null) {
      if (fallback != null) {
        return DateFormat('MMM d, y • h:mm a').format(fallback);
      }
      return 'Time not specified';
    }

    if (start != null && end != null) {
      final startDate = DateFormat('MMM d, y').format(start);
      final endDate = DateFormat('MMM d, y').format(end);

      if (startDate == endDate) {
        // Same day
        return '${DateFormat('MMM d, y').format(start)} • ${DateFormat('h:mm a').format(start)} - ${DateFormat('h:mm a').format(end)}';
      } else {
        // Different days
        return '${DateFormat('MMM d, y • h:mm a').format(start)} - ${DateFormat('MMM d, y • h:mm a').format(end)}';
      }
    }

    if (start != null) {
      return DateFormat('MMM d, y • h:mm a').format(start);
    }

    if (end != null) {
      return DateFormat('MMM d, y • h:mm a').format(end);
    }

    return 'Time not specified';
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'CONFIRMED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBookings,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading bookings',
                    style: TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadBookings,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _bookings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No active bookings',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadBookings,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _bookings.length,
                itemBuilder: (context, index) {
                  final booking = _bookings[index];
                  final ride = _rideDetails[booking.rideId];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    booking.status,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  booking.status,
                                  style: TextStyle(
                                    color: _getStatusColor(booking.status),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Text(
                                '${booking.seatsBooked} ${booking.seatsBooked == 1 ? 'seat' : 'seats'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Driver information
                          if (ride != null) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 20,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Driver: ${ride.driverName}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (ride.driverRating != null) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  Text(
                                    ride.driverRating!.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Vehicle information
                            Row(
                              children: [
                                Icon(
                                  Icons.directions_car,
                                  size: 20,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${ride.vehicleMake} ${ride.vehicleModel} • ${ride.vehiclePlateNumber}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),

                            // Driver's route
                            Text(
                              'Driver\'s Route',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Container(
                                      width: 2,
                                      height: 20,
                                      color: Colors.grey[300],
                                    ),
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ride.pickupLocationLabel,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        ride.destinationLocationLabel,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatTimeRange(
                                ride.departureTimeStart,
                                ride.departureTimeEnd,
                                ride.departureTime,
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                          ],

                          // Rider's pickup and dropoff
                          Text(
                            'Your Pickup & Dropoff',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Container(
                                    width: 2,
                                    height: 20,
                                    color: Colors.grey[300],
                                  ),
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.purple,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      booking.pickupLocationLabel ??
                                          'Pickup location',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      booking.dropoffLocationLabel ??
                                          'Dropoff location',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (booking.pickupTimeStart != null ||
                              booking.pickupTimeEnd != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _formatTimeRange(
                                booking.pickupTimeStart,
                                booking.pickupTimeEnd,
                                null,
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),

                          // Cost
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Cost',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '\$${booking.costForThisRider.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
