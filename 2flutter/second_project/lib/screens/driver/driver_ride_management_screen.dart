import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/driver_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../services/ride_service.dart';
import '../../services/booking_service.dart';
import '../../services/location_service.dart';
import '../../services/notification_service.dart';
import '../../models/ride.dart';

class DriverRideManagementScreen extends StatefulWidget {
  const DriverRideManagementScreen({super.key});

  @override
  State<DriverRideManagementScreen> createState() =>
      _DriverRideManagementScreenState();
}

class _DriverRideManagementScreenState
    extends State<DriverRideManagementScreen> {
  bool _isLoading = true;
  int _currentRideIndex = 0;
  Ride? _currentRideDetails;
  bool _isLoadingDetails = false;
  bool _isDeleting = false;
  // Reverse geocoded addresses for the ride
  String? _ridePickupAddress;
  String? _rideDestinationAddress;
  // Map of booking ID to reverse geocoded addresses
  Map<int, Map<String, String>> _bookingAddresses = {};

  @override
  void initState() {
    super.initState();
    _loadRides();
  }

  Future<void> _refreshData() async {
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);

    try {
      // Reload rides
      await driverProvider.loadMyRides();

      if (mounted) {
        // Filter out cancelled and completed rides
        final activeRides = driverProvider.myRides.where((ride) {
          final status = ride.status.toUpperCase();
          return status != 'CANCELLED' && status != 'COMPLETED';
        }).toList();

        if (activeRides.isNotEmpty) {
          // Ensure current index is valid
          int safeIndex = _currentRideIndex;
          if (safeIndex >= activeRides.length) {
            safeIndex = 0;
          }

          setState(() {
            _currentRideIndex = safeIndex;
          });

          // Reload details for current ride
          await _loadRideDetails(activeRides[safeIndex].id);
        } else {
          setState(() {
            _currentRideDetails = null;
          });
        }
      }
    } catch (e) {
      print('RideManagementScreen._refreshData - Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing data: ${e.toString()}'),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadRides() async {
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);

    try {
      await driverProvider.loadMyRides();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Filter out cancelled and completed rides and load details for the first ride (case-insensitive)
        final activeRides = driverProvider.myRides.where((ride) {
          final status = ride.status.toUpperCase();
          return status != 'CANCELLED' && status != 'COMPLETED';
        }).toList();
        print(
          'RideManagementScreen._loadRides - Total rides: ${driverProvider.myRides.length}',
        );
        print(
          'RideManagementScreen._loadRides - Active rides (non-cancelled): ${activeRides.length}',
        );
        print(
          'RideManagementScreen._loadRides - Ride statuses: ${driverProvider.myRides.map((r) => '${r.id}:${r.status}').join(', ')}',
        );
        if (activeRides.isNotEmpty) {
          setState(() {
            _currentRideIndex = 0;
          });
          _loadRideDetails(activeRides[0].id);
        }
      }
    } catch (e) {
      print('RideManagementScreen._loadRides - Error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading rides: ${e.toString()}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _loadRideDetails(int rideId) async {
    setState(() {
      _isLoadingDetails = true;
      _ridePickupAddress = null;
      _rideDestinationAddress = null;
      _bookingAddresses = {};
    });

    try {
      final rideDetails = await RideService.getRide(rideId);

      // Reverse geocode ride's pickup and destination
      String? pickupAddress;
      String? destinationAddress;

      try {
        pickupAddress = await LocationService.reverseGeocode(
          rideDetails.pickupLatitude,
          rideDetails.pickupLongitude,
        );
      } catch (e) {
        print('Error reverse geocoding pickup: $e');
        pickupAddress = rideDetails.pickupLocationLabel;
      }

      try {
        destinationAddress = await LocationService.reverseGeocode(
          rideDetails.destinationLatitude,
          rideDetails.destinationLongitude,
        );
      } catch (e) {
        print('Error reverse geocoding destination: $e');
        destinationAddress = rideDetails.destinationLocationLabel;
      }

      if (mounted) {
        setState(() {
          _currentRideDetails = rideDetails;
          _ridePickupAddress = pickupAddress;
          _rideDestinationAddress = destinationAddress;
        });

        // Load bookings for this ride
        final driverProvider = Provider.of<DriverProvider>(
          context,
          listen: false,
        );
        await driverProvider.loadBookingsForRide(rideId);

        // Reverse geocode addresses for all bookings
        await _reverseGeocodeBookings(driverProvider.acceptedBookings);
        await _reverseGeocodeBookings(driverProvider.pendingBookings);

        if (mounted) {
          setState(() {
            _isLoadingDetails = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDetails = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading ride details: ${e.toString()}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _startRide(Ride ride) async {
    try {
      // Update ride status to IN_PROGRESS
      await RideService.updateRideStatus(ride.id, 'IN_PROGRESS');

      // Get all accepted bookings for this ride
      final driverProvider = Provider.of<DriverProvider>(
        context,
        listen: false,
      );
      await driverProvider.loadBookingsForRide(ride.id);
      final bookings = driverProvider.acceptedBookings;

      // Send notifications to all riders
      final riderIds = bookings.map((b) => b.riderId).toList();
      if (riderIds.isNotEmpty) {
        try {
          await NotificationService.notifyRidersInRide(
            rideId: ride.id,
            riderIds: riderIds,
            title: 'Ride Started',
            body:
                'Your driver has started the ride. Please be ready at your pickup location.',
          );
        } catch (e) {
          print('Error sending notifications: $e');
          // Continue even if notifications fail
        }
      }

      // Reload ride details to get updated status
      await _loadRideDetails(ride.id);

      // Navigate to checklist screen
      if (mounted) {
        Navigator.pushNamed(context, '/driver/ride-checklist', arguments: ride);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting ride: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _reverseGeocodeBookings(List<dynamic> bookings) async {
    final Map<int, Map<String, String>> addresses = {};

    for (final booking in bookings) {
      try {
        String? pickupAddress;
        String? destinationAddress;

        // Get pickup coordinates from booking
        double? pickupLat = booking.pickupLatitude;
        double? pickupLon = booking.pickupLongitude;
        double? destLat = booking.dropoffLatitude;
        double? destLon = booking.dropoffLongitude;

        // If coordinates are not available, try to get from ride details
        if (pickupLat == null && _currentRideDetails != null) {
          pickupLat = _currentRideDetails!.pickupLatitude;
          pickupLon = _currentRideDetails!.pickupLongitude;
        }

        if (destLat == null && _currentRideDetails != null) {
          destLat = _currentRideDetails!.destinationLatitude;
          destLon = _currentRideDetails!.destinationLongitude;
        }

        // Reverse geocode pickup
        if (pickupLat != null && pickupLon != null) {
          try {
            pickupAddress = await LocationService.reverseGeocode(
              pickupLat,
              pickupLon,
            );
          } catch (e) {
            print('Error reverse geocoding booking pickup: $e');
            pickupAddress = booking.pickupLocationLabel ?? 'Unknown location';
          }
        } else {
          pickupAddress = booking.pickupLocationLabel ?? 'Unknown location';
        }

        // Reverse geocode destination
        if (destLat != null && destLon != null) {
          try {
            destinationAddress = await LocationService.reverseGeocode(
              destLat,
              destLon,
            );
          } catch (e) {
            print('Error reverse geocoding booking destination: $e');
            destinationAddress =
                booking.dropoffLocationLabel ?? 'Unknown location';
          }
        } else {
          destinationAddress =
              booking.dropoffLocationLabel ?? 'Unknown location';
        }

        addresses[booking.id] = {
          'pickup': pickupAddress ?? 'Unknown location',
          'destination': destinationAddress ?? 'Unknown location',
        };
      } catch (e) {
        print('Error processing booking ${booking.id}: $e');
        addresses[booking.id] = {
          'pickup': booking.pickupLocationLabel ?? 'Unknown location',
          'destination': booking.dropoffLocationLabel ?? 'Unknown location',
        };
      }
    }

    if (mounted) {
      setState(() {
        _bookingAddresses.addAll(addresses);
      });
    }
  }

  void _navigateToPreviousRide() {
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    final activeRides = driverProvider.myRides.where((ride) {
      final status = ride.status.toUpperCase();
      return status != 'CANCELLED' && status != 'COMPLETED';
    }).toList();
    if (activeRides.isEmpty) return;

    setState(() {
      _currentRideIndex =
          (_currentRideIndex - 1 + activeRides.length) % activeRides.length;
    });
    _loadRideDetails(activeRides[_currentRideIndex].id);
  }

  void _navigateToNextRide() {
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    final activeRides = driverProvider.myRides.where((ride) {
      final status = ride.status.toUpperCase();
      return status != 'CANCELLED' && status != 'COMPLETED';
    }).toList();
    if (activeRides.isEmpty) return;

    setState(() {
      _currentRideIndex = (_currentRideIndex + 1) % activeRides.length;
    });
    _loadRideDetails(activeRides[_currentRideIndex].id);
  }

  Future<void> _cancelRide() async {
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    final activeRides = driverProvider.myRides.where((ride) {
      final status = ride.status.toUpperCase();
      return status != 'CANCELLED' && status != 'COMPLETED';
    }).toList();

    if (activeRides.isEmpty) return;

    final rideToDelete = _currentRideDetails ?? activeRides[_currentRideIndex];
    final rideId = rideToDelete.id;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Ride'),
        content: const Text(
          'Are you sure you want to cancel this ride? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      print('Attempting to delete ride with ID: $rideId');
      await RideService.deleteRide(rideId);
      print('Ride deleted successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ride cancelled successfully'),
            duration: Duration(seconds: 3),
          ),
        );
        // Reload rides
        await _loadRides();
        // Adjust index if needed
        final updatedProvider = Provider.of<DriverProvider>(
          context,
          listen: false,
        );
        final updatedActiveRides = updatedProvider.myRides.where((ride) {
          final status = ride.status.toUpperCase();
          return status != 'CANCELLED' && status != 'COMPLETED';
        }).toList();
        if (mounted) {
          if (updatedActiveRides.isEmpty) {
            setState(() {
              _currentRideIndex = 0;
              _currentRideDetails = null;
              _isDeleting = false;
            });
          } else {
            // Adjust index if we deleted the last ride
            if (_currentRideIndex >= updatedActiveRides.length) {
              setState(() {
                _currentRideIndex = updatedActiveRides.length - 1;
              });
            }
            // Load details for the current ride
            await _loadRideDetails(updatedActiveRides[_currentRideIndex].id);
            if (mounted) {
              setState(() {
                _isDeleting = false;
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error deleting ride: $e');
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cancelling ride: ${e.toString()}'),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatTimeRangeWithEnd(
    DateTime? startTime,
    DateTime? endTime,
    DateTime fallbackTime,
  ) {
    final timeFormat = DateFormat('h:mm a');
    final dateFormat = DateFormat('MMM d');
    if (startTime != null && endTime != null) {
      // Check if start and end are on the same day
      final sameDay =
          startTime.year == endTime.year &&
          startTime.month == endTime.month &&
          startTime.day == endTime.day;

      if (sameDay) {
        return '${timeFormat.format(startTime)} - ${timeFormat.format(endTime)}';
      } else {
        // Different days - show date and time
        return '${dateFormat.format(startTime)} ${timeFormat.format(startTime)} - ${dateFormat.format(endTime)} ${timeFormat.format(endTime)}';
      }
    }
    return timeFormat.format(fallbackTime);
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final driverProvider = Provider.of<DriverProvider>(context);
    // Filter out cancelled and completed rides (case-insensitive comparison)
    final activeRides = driverProvider.myRides.where((ride) {
      final status = ride.status.toUpperCase();
      return status != 'CANCELLED' && status != 'COMPLETED';
    }).toList();

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ride Management')),
        drawer: AppDrawer(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (activeRides.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ride Management')),
        drawer: AppDrawer(),
        body: const Center(
          child: Text(
            'No rides available',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    // Ensure index is within bounds
    int safeIndex = _currentRideIndex;
    if (safeIndex >= activeRides.length) {
      safeIndex = 0;
      if (mounted) {
        setState(() {
          _currentRideIndex = 0;
        });
      }
    }
    final currentRide = activeRides[safeIndex];
    final rideToDisplay = _currentRideDetails ?? currentRide;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          Expanded(
            child: _isLoadingDetails
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _refreshData,
                    child: SingleChildScrollView(
                      physics:
                          const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh even when content is small
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Ride counter
                          Center(
                            child: Text(
                              'Ride ${safeIndex + 1} of ${activeRides.length}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Ride summary cards
                          Row(
                            children: [
                              Expanded(
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        Text(
                                          _formatTimeRangeWithEnd(
                                            rideToDisplay.departureTimeStart,
                                            rideToDisplay.departureTimeEnd,
                                            rideToDisplay.departureTime,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatDate(
                                            rideToDisplay.departureTimeStart ??
                                                rideToDisplay.departureTime,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          rideToDisplay
                                                  .destinationLocationLabel
                                                  .isNotEmpty
                                              ? rideToDisplay
                                                    .destinationLocationLabel
                                              : 'Destination',
                                          style: const TextStyle(fontSize: 14),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        Text(
                                          '${rideToDisplay.availableSeats}',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Available Seats',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${rideToDisplay.totalSeats - rideToDisplay.availableSeats}/${rideToDisplay.totalSeats} booked',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Route information
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Route',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Start location with address
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            color: Colors.green,
                                          ),
                                          const SizedBox(width: 8),
                                          const Expanded(
                                            child: Text(
                                              'Start Location',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 32,
                                        ),
                                        child: Text(
                                          _ridePickupAddress ??
                                              (rideToDisplay
                                                      .pickupLocationLabel
                                                      .isNotEmpty
                                                  ? rideToDisplay
                                                        .pickupLocationLabel
                                                  : 'Pickup location'),
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Destination location with address
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.place,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(width: 8),
                                          const Expanded(
                                            child: Text(
                                              'Destination',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 32,
                                        ),
                                        child: Text(
                                          _rideDestinationAddress ??
                                              (rideToDisplay
                                                      .destinationLocationLabel
                                                      .isNotEmpty
                                                  ? rideToDisplay
                                                        .destinationLocationLabel
                                                  : 'Destination location'),
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (rideToDisplay.estimatedDistanceKm !=
                                      null) ...[
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.straighten,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${rideToDisplay.estimatedDistanceKm!.toStringAsFixed(1)} km',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        if (rideToDisplay
                                                .estimatedDurationMinutes !=
                                            null) ...[
                                          const SizedBox(width: 16),
                                          const Icon(
                                            Icons.access_time,
                                            color: Colors.blue,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${rideToDisplay.estimatedDurationMinutes} min',
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Vehicle information
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Vehicle',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.directions_car,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${rideToDisplay.vehicleMake} ${rideToDisplay.vehicleModel}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.confirmation_number,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        rideToDisplay.vehiclePlateNumber,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Status and pricing
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Details',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Status:',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              rideToDisplay.status ==
                                                      'POSTED' ||
                                                  rideToDisplay.status ==
                                                      'IN_PROGRESS'
                                              ? Colors.green.withOpacity(0.2)
                                              : Colors.grey.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          rideToDisplay.status,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                rideToDisplay.status ==
                                                        'POSTED' ||
                                                    rideToDisplay.status ==
                                                        'IN_PROGRESS'
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (rideToDisplay.basePrice != null ||
                                      rideToDisplay.pricePerSeat != null) ...[
                                    const SizedBox(height: 12),
                                    if (rideToDisplay.basePrice != null)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Base Price:',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          Text(
                                            '\$${rideToDisplay.basePrice!.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (rideToDisplay.pricePerSeat != null)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Price per Seat:',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          Text(
                                            '\$${rideToDisplay.pricePerSeat!.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Requests section (only for active rides)
                          if (rideToDisplay.status == 'POSTED' ||
                              rideToDisplay.status == 'IN_PROGRESS') ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'New Requests',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/driver/incoming-requests',
                                    );
                                  },
                                  child: const Text('View all'),
                                ),
                              ],
                            ),
                            // Show only pending bookings in "New Requests"
                            Builder(
                              builder: (context) {
                                final pendingBookings =
                                    driverProvider.pendingBookings;

                                if (pendingBookings.isEmpty)
                                  return Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            const Icon(
                                              Icons.inbox,
                                              size: 48,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'No requests',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );

                                return Column(
                                  children: pendingBookings.map((booking) {
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      elevation: 2,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/driver/incoming-requests',
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Rider name and rating
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 24,
                                                    backgroundColor: Colors.blue
                                                        .withOpacity(0.1),
                                                    child: Text(
                                                      booking.riderName
                                                          .substring(0, 1)
                                                          .toUpperCase(),
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          booking.riderName,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                        if (booking
                                                                .riderRating !=
                                                            null)
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                Icons.star,
                                                                color: Colors
                                                                    .amber,
                                                                size: 16,
                                                              ),
                                                              const SizedBox(
                                                                width: 4,
                                                              ),
                                                              Text(
                                                                booking
                                                                    .riderRating!
                                                                    .toStringAsFixed(
                                                                      1,
                                                                    ),
                                                                style: const TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        else
                                                          const Text(
                                                            'No rating yet',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 6,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          booking.status ==
                                                              'PENDING'
                                                          ? Colors.orange
                                                                .withOpacity(
                                                                  0.1,
                                                                )
                                                          : Colors.green
                                                                .withOpacity(
                                                                  0.1,
                                                                ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      booking.status,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            booking.status ==
                                                                'PENDING'
                                                            ? Colors.orange
                                                            : Colors.green,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              // Start location
                                              if (booking.pickupLocationLabel !=
                                                      null ||
                                                  _bookingAddresses[booking
                                                          .id] !=
                                                      null)
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.location_on,
                                                      size: 20,
                                                      color: Colors.green,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        _bookingAddresses[booking
                                                                .id]?['pickup'] ??
                                                            booking
                                                                .pickupLocationLabel ??
                                                            'Unknown location',
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              // Destination location
                                              if (booking.dropoffLocationLabel !=
                                                      null ||
                                                  _bookingAddresses[booking
                                                          .id] !=
                                                      null) ...[
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.place,
                                                      size: 20,
                                                      color: Colors.red,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        _bookingAddresses[booking
                                                                .id]?['destination'] ??
                                                            booking
                                                                .dropoffLocationLabel ??
                                                            'Unknown location',
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                              // Departure time range
                                              if (booking.pickupTimeStart !=
                                                      null &&
                                                  booking.pickupTimeEnd !=
                                                      null) ...[
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.access_time,
                                                      size: 20,
                                                      color: Colors.blue,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        _formatTimeRangeWithEnd(
                                                          booking
                                                              .pickupTimeStart!,
                                                          booking
                                                              .pickupTimeEnd!,
                                                          booking
                                                              .pickupTimeStart!,
                                                        ),
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                              // Phone number with WhatsApp link
                                              if (booking.riderPhoneNumber !=
                                                      null &&
                                                  booking
                                                      .riderPhoneNumber!
                                                      .isNotEmpty) ...[
                                                const SizedBox(height: 12),
                                                InkWell(
                                                  onTap: () async {
                                                    final phoneNumber = booking
                                                        .riderPhoneNumber!
                                                        .replaceAll(
                                                          RegExp(r'[^\d+]'),
                                                          '',
                                                        );
                                                    final whatsappUrl =
                                                        'https://wa.me/$phoneNumber';
                                                    try {
                                                      final url = Uri.parse(
                                                        whatsappUrl,
                                                      );
                                                      if (await canLaunchUrl(
                                                        url,
                                                      )) {
                                                        await launchUrl(url);
                                                      } else {
                                                        if (mounted) {
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                'Could not open WhatsApp',
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      }
                                                    } catch (e) {
                                                      if (mounted) {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              'Error: ${e.toString()}',
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  },
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.phone,
                                                        size: 20,
                                                        color: Colors.green,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        booking
                                                            .riderPhoneNumber!,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.green,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      const Icon(
                                                        Icons.chat,
                                                        size: 16,
                                                        color: Colors.green,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                              // Accept/Reject buttons for PENDING bookings
                                              if (booking.status
                                                      .toUpperCase() ==
                                                  'PENDING') ...[
                                                const SizedBox(height: 16),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: OutlinedButton(
                                                        onPressed: () async {
                                                          try {
                                                            await BookingService.rejectBooking(
                                                              booking.id,
                                                            );
                                                            // Reload bookings
                                                            final driverProvider =
                                                                Provider.of<
                                                                  DriverProvider
                                                                >(
                                                                  context,
                                                                  listen: false,
                                                                );
                                                            await driverProvider
                                                                .loadBookingsForRide(
                                                                  rideToDisplay
                                                                      .id,
                                                                );
                                                            if (mounted) {
                                                              await _loadRideDetails(
                                                                rideToDisplay
                                                                    .id,
                                                              );
                                                            }
                                                          } catch (e) {
                                                            if (mounted) {
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    'Error rejecting booking: ${e.toString()}',
                                                                  ),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                ),
                                                              );
                                                            }
                                                          }
                                                        },
                                                        style: OutlinedButton.styleFrom(
                                                          foregroundColor:
                                                              Colors.red,
                                                          side:
                                                              const BorderSide(
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                        ),
                                                        child: const Text(
                                                          'Reject',
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: ElevatedButton(
                                                        onPressed: () async {
                                                          try {
                                                            await BookingService.acceptBooking(
                                                              booking.id,
                                                            );
                                                            // Reload bookings
                                                            final driverProvider =
                                                                Provider.of<
                                                                  DriverProvider
                                                                >(
                                                                  context,
                                                                  listen: false,
                                                                );
                                                            await driverProvider
                                                                .loadBookingsForRide(
                                                                  rideToDisplay
                                                                      .id,
                                                                );
                                                            if (mounted) {
                                                              await _loadRideDetails(
                                                                rideToDisplay
                                                                    .id,
                                                              );
                                                            }
                                                            if (mounted) {
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                const SnackBar(
                                                                  content: Text(
                                                                    'Booking accepted successfully',
                                                                  ),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .green,
                                                                ),
                                                              );
                                                            }
                                                          } catch (e) {
                                                            if (mounted) {
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    'Error accepting booking: ${e.toString()}',
                                                                  ),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                ),
                                                              );
                                                            }
                                                          }
                                                        },
                                                        style:
                                                            ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  Colors.green,
                                                              foregroundColor:
                                                                  Colors.white,
                                                            ),
                                                        child: const Text(
                                                          'Accept',
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            // Accepted riders section
                            if (driverProvider.acceptedBookings.isNotEmpty) ...[
                              const Text(
                                'Accepted Riders',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...driverProvider.acceptedBookings.map((booking) {
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Rider name and rating
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 24,
                                              backgroundColor: Colors.green
                                                  .withOpacity(0.1),
                                              child: Text(
                                                booking.riderName
                                                    .substring(0, 1)
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  if (booking.riderRating !=
                                                      null)
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.star,
                                                          color: Colors.amber,
                                                          size: 16,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          booking.riderRating!
                                                              .toStringAsFixed(
                                                                1,
                                                              ),
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 14,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                        ),
                                                      ],
                                                    )
                                                  else
                                                    const Text(
                                                      'No rating yet',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              '${booking.seatsBooked} seat${booking.seatsBooked > 1 ? 's' : ''}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        // Start location
                                        if (booking.pickupLocationLabel !=
                                                null ||
                                            _bookingAddresses[booking.id] !=
                                                null)
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on,
                                                size: 20,
                                                color: Colors.green,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  _bookingAddresses[booking
                                                          .id]?['pickup'] ??
                                                      booking
                                                          .pickupLocationLabel ??
                                                      'Unknown location',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        // Destination location
                                        if (booking.dropoffLocationLabel !=
                                                null ||
                                            _bookingAddresses[booking.id] !=
                                                null) ...[
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.place,
                                                size: 20,
                                                color: Colors.red,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  _bookingAddresses[booking
                                                          .id]?['destination'] ??
                                                      booking
                                                          .dropoffLocationLabel ??
                                                      'Unknown location',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        // Phone number with WhatsApp link
                                        if (booking.riderPhoneNumber != null &&
                                            booking
                                                .riderPhoneNumber!
                                                .isNotEmpty) ...[
                                          const SizedBox(height: 12),
                                          InkWell(
                                            onTap: () async {
                                              final phoneNumber = booking
                                                  .riderPhoneNumber!
                                                  .replaceAll(
                                                    RegExp(r'[^\d+]'),
                                                    '',
                                                  );
                                              final whatsappUrl =
                                                  'https://wa.me/$phoneNumber';
                                              try {
                                                // Import url_launcher
                                                final url = Uri.parse(
                                                  whatsappUrl,
                                                );
                                                if (await canLaunchUrl(url)) {
                                                  await launchUrl(url);
                                                } else {
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Could not open WhatsApp',
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                }
                                              } catch (e) {
                                                if (mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Error: ${e.toString()}',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.phone,
                                                  size: 20,
                                                  color: Colors.green,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  booking.riderPhoneNumber!,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.green,
                                                    decoration: TextDecoration
                                                        .underline,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                const Icon(
                                                  Icons.chat,
                                                  size: 16,
                                                  color: Colors.green,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 24),
                            ],
                          ],
                          // GO button (for POSTED rides) or IN PROGRESS button (for IN_PROGRESS rides)
                          if (rideToDisplay.status == 'POSTED' ||
                              rideToDisplay.status == 'IN_PROGRESS') ...[
                            ElevatedButton.icon(
                              onPressed: () async {
                                if (rideToDisplay.status == 'POSTED') {
                                  // First time - start the ride
                                  await _startRide(rideToDisplay);
                                } else {
                                  // Already in progress - just navigate to checklist
                                  if (mounted) {
                                    Navigator.pushNamed(
                                      context,
                                      '/driver/ride-checklist',
                                      arguments: rideToDisplay,
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.directions_car),
                              label: Text(
                                rideToDisplay.status == 'POSTED'
                                    ? 'GO'
                                    : 'IN PROGRESS',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    rideToDisplay.status == 'POSTED'
                                    ? Colors.green
                                    : Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          // Cancel ride button
                          OutlinedButton.icon(
                            onPressed: _isDeleting ? null : _cancelRide,
                            icon: _isDeleting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.cancel, color: Colors.red),
                            label: Text(
                              _isDeleting ? 'Cancelling...' : 'Cancel Ride',
                              style: const TextStyle(color: Colors.red),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
          ),
          // Navigation buttons at bottom
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left button
                  ElevatedButton.icon(
                    onPressed: activeRides.length > 1
                        ? _navigateToPreviousRide
                        : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                  // Right button
                  ElevatedButton.icon(
                    onPressed: activeRides.length > 1
                        ? _navigateToNextRide
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
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
