import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/driver_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../services/ride_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadRides();
  }

  Future<void> _loadRides() async {
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);

    try {
      await driverProvider.loadMyRides();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Filter out cancelled rides and load details for the first ride (case-insensitive)
        final activeRides = driverProvider.myRides
            .where((ride) => ride.status.toUpperCase() != 'CANCELLED')
            .toList();
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
    });

    try {
      final rideDetails = await RideService.getRide(rideId);
      if (mounted) {
        setState(() {
          _currentRideDetails = rideDetails;
          _isLoadingDetails = false;
        });
        // Load bookings for this ride
        final driverProvider = Provider.of<DriverProvider>(
          context,
          listen: false,
        );
        await driverProvider.loadBookingsForRide(rideId);
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

  void _navigateToPreviousRide() {
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    final activeRides = driverProvider.myRides
        .where((ride) => ride.status != 'CANCELLED')
        .toList();
    if (activeRides.isEmpty) return;

    setState(() {
      _currentRideIndex =
          (_currentRideIndex - 1 + activeRides.length) % activeRides.length;
    });
    _loadRideDetails(activeRides[_currentRideIndex].id);
  }

  void _navigateToNextRide() {
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    final activeRides = driverProvider.myRides
        .where((ride) => ride.status != 'CANCELLED')
        .toList();
    if (activeRides.isEmpty) return;

    setState(() {
      _currentRideIndex = (_currentRideIndex + 1) % activeRides.length;
    });
    _loadRideDetails(activeRides[_currentRideIndex].id);
  }

  Future<void> _cancelRide() async {
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    final activeRides = driverProvider.myRides
        .where((ride) => ride.status != 'CANCELLED')
        .toList();

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
        final updatedActiveRides = updatedProvider.myRides
            .where((ride) => ride.status != 'CANCELLED')
            .toList();
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
    // Filter out cancelled rides (case-insensitive comparison)
    final activeRides = driverProvider.myRides
        .where((ride) => ride.status.toUpperCase() != 'CANCELLED')
        .toList();

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
      appBar: AppBar(title: const Text('Ride Management')),
      drawer: AppDrawer(),
      body: Column(
        children: [
          Expanded(
            child: _isLoadingDetails
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
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
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        rideToDisplay
                                                .pickupLocationLabel
                                                .isNotEmpty
                                            ? rideToDisplay.pickupLocationLabel
                                            : 'Pickup location',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.place, color: Colors.red),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        rideToDisplay
                                                .destinationLocationLabel
                                                .isNotEmpty
                                            ? rideToDisplay
                                                  .destinationLocationLabel
                                            : 'Destination location',
                                        style: const TextStyle(fontSize: 16),
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
                                          style: const TextStyle(fontSize: 14),
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
                                            rideToDisplay.status == 'POSTED' ||
                                                rideToDisplay.status ==
                                                    'IN_PROGRESS'
                                            ? Colors.green.withOpacity(0.2)
                                            : Colors.grey.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
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
                          // Show all bookings (both pending and confirmed)
                          Builder(
                            builder: (context) {
                              final allBookings = [
                                ...driverProvider.pendingBookings,
                                ...driverProvider.acceptedBookings,
                              ];
                              
                              if (allBookings.isEmpty)
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
                                children: allBookings.map((booking) {
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
                                            // Rider name
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 24,
                                                  backgroundColor:
                                                      Colors.blue.withOpacity(0.1),
                                                  child: Text(
                                                    booking.riderName
                                                        .substring(0, 1)
                                                        .toUpperCase(),
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    booking.riderName,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: booking.status == 'PENDING'
                                                        ? Colors.orange.withOpacity(0.1)
                                                        : Colors.green.withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    booking.status,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: booking.status == 'PENDING'
                                                          ? Colors.orange
                                                          : Colors.green,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            // Start location
                                            if (booking.pickupLocationLabel != null)
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
                                                      booking.pickupLocationLabel!,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            // Destination location
                                            if (booking.dropoffLocationLabel != null) ...[
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
                                                      booking.dropoffLocationLabel!,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                            // Departure time range
                                            if (booking.pickupTimeStart != null &&
                                                booking.pickupTimeEnd != null) ...[
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
                                                        booking.pickupTimeStart!,
                                                        booking.pickupTimeEnd!,
                                                        booking.pickupTimeStart!,
                                                      ),
                                                      style: const TextStyle(
                                                        fontSize: 14,
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Accepted Riders',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/driver/accepted-riders',
                                    );
                                  },
                                  child: const Text('View all'),
                                ),
                              ],
                            ),
                            ...driverProvider.acceptedBookings.take(3).map((
                              booking,
                            ) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Colors.green,
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(booking.riderName),
                                  subtitle: Text(
                                    '${booking.seatsBooked} seat${booking.seatsBooked > 1 ? 's' : ''} confirmed',
                                  ),
                                  trailing: const Icon(Icons.arrow_forward),
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/driver/accepted-riders',
                                    );
                                  },
                                ),
                              );
                            }),
                            const SizedBox(height: 24),
                          ],
                          // Action buttons
                          if (rideToDisplay.status == 'POSTED')
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/driver/accepted-riders',
                                );
                              },
                              icon: const Icon(Icons.directions_car),
                              label: const Text('Start Ride'),
                              style: ElevatedButton.styleFrom(
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
