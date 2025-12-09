import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/rating_service.dart';
import '../../services/ride_service.dart';
import '../../services/notification_service.dart';
import '../../providers/driver_provider.dart';
import '../../models/ride.dart';
import '../../models/booking.dart';

class DriverRateAllRidersScreen extends StatefulWidget {
  final Ride ride;

  const DriverRateAllRidersScreen({super.key, required this.ride});

  @override
  State<DriverRateAllRidersScreen> createState() =>
      _DriverRateAllRidersScreenState();
}

class _DriverRateAllRidersScreenState extends State<DriverRateAllRidersScreen> {
  final Map<int, int> _ratings = {}; // bookingId -> rating
  final Map<int, TextEditingController> _commentControllers = {};
  bool _isLoading = true;
  bool _isSubmitting = false;
  List<Booking> _bookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
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

      // Initialize ratings and comment controllers for each booking
      for (final booking in bookings) {
        _ratings[booking.id] = 0;
        _commentControllers[booking.id] = TextEditingController();
      }

      if (mounted) {
        setState(() {
          _bookings = bookings;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading bookings: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading riders: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _allRated() {
    return _bookings.isNotEmpty &&
        _bookings.every(
          (booking) =>
              _ratings[booking.id] != null && _ratings[booking.id]! > 0,
        );
  }

  Future<void> _submitAllRatings() async {
    if (!_allRated()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please rate all riders before completing'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Submit rating for each rider
      for (final booking in _bookings) {
        try {
          await RatingService.createRating(
            bookingId: booking.id,
            score: _ratings[booking.id]!,
            comment: _commentControllers[booking.id]!.text.isEmpty
                ? null
                : _commentControllers[booking.id]!.text,
          );
        } catch (e) {
          print('Error rating rider ${booking.riderName} (${booking.id}): $e');
          // Continue with other ratings even if one fails
        }
      }

      // Mark ride as completed
      await RideService.updateRideStatus(widget.ride.id, 'COMPLETED');

      // Send notifications to all riders that the ride is completed
      final riderIds = _bookings.map((b) => b.riderId).toList();
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
            content: Text('Ride completed and all riders rated!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back to ride management (ride will be hidden as it's now completed)
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
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
      appBar: AppBar(title: const Text('Rate Your Riders')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No riders to rate',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final booking = _bookings[index];
                      final rating = _ratings[booking.id] ?? 0;
                      final commentController =
                          _commentControllers[booking.id]!;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.grey,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          booking.riderName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (booking.riderRating != null) ...[
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                size: 16,
                                                color: Colors.amber,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                booking.riderRating!
                                                    .toStringAsFixed(1),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Friendliness',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (index) {
                                  return IconButton(
                                    icon: Icon(
                                      index < rating
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 36,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _ratings[booking.id] = index + 1;
                                      });
                                    },
                                  );
                                }),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: commentController,
                                decoration: InputDecoration(
                                  hintText: 'Additional comments (optional)...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                maxLines: 3,
                              ),
                            ],
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
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitAllRatings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _allRated()
                            ? Colors.green
                            : Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: _isSubmitting
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
                          : Text(
                              _allRated()
                                  ? 'Complete Ride & Submit Ratings'
                                  : 'Rate All Riders to Complete',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
