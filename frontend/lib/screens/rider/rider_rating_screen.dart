import 'package:flutter/material.dart';
import '../../services/rating_service.dart';
import '../../services/ride_service.dart';
import '../../models/booking.dart';
import '../../models/ride.dart';

class RiderRatingScreen extends StatefulWidget {
  final Booking booking;

  const RiderRatingScreen({super.key, required this.booking});

  @override
  State<RiderRatingScreen> createState() => _RiderRatingScreenState();
}

class _RiderRatingScreenState extends State<RiderRatingScreen> {
  final Map<String, int> _ratings = {
    'Punctuality': 0,
    'Driving Experience': 0,
    'Safety': 0,
    'Car Condition': 0,
    'Attitude': 0,
  };
  final TextEditingController _commentController = TextEditingController();
  Ride? _ride;
  bool _isLoadingRide = true;

  @override
  void initState() {
    super.initState();
    _loadRideDetails();
  }

  Future<void> _loadRideDetails() async {
    try {
      final ride = await RideService.getRide(widget.booking.rideId);
      if (mounted) {
        setState(() {
          _ride = ride;
          _isLoadingRide = false;
        });
      }
    } catch (e) {
      print('Error loading ride details: $e');
      if (mounted) {
        setState(() {
          _isLoadingRide = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    final avgRating =
        _ratings.values.where((r) => r > 0).fold(0, (sum, r) => sum + r) /
        _ratings.values.where((r) => r > 0).length;

    if (avgRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide at least one rating')),
      );
      return;
    }

    try {
      await RatingService.createRating(
        bookingId: widget.booking.id,
        score: avgRating.round(),
        comment: _commentController.text.isEmpty
            ? null
            : _commentController.text,
      );

      if (mounted) {
        // Navigate back to bookings screen after rating
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final driverName = _ride?.driverName ?? 'Driver';
    final driverRating = _ride?.driverRating;

    return Scaffold(
      appBar: AppBar(title: Text('How was your trip with $driverName?')),
      body: _isLoadingRide
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const CircleAvatar(radius: 40, backgroundColor: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    driverName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (driverRating != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          driverRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 32),
                  ..._ratings.keys.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: List.generate(5, (index) {
                              return IconButton(
                                icon: Icon(
                                  index < _ratings[category]!
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 32,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _ratings[category] = index + 1;
                                  });
                                },
                              );
                            }),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Additional comments...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submitRating,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Submit Review',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
