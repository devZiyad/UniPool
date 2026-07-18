import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/driver_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../models/ride.dart';

class DriverHistoryScreen extends StatefulWidget {
  final bool showInTabBar;
  
  const DriverHistoryScreen({
    super.key,
    this.showInTabBar = false,
  });

  @override
  State<DriverHistoryScreen> createState() => _DriverHistoryScreenState();
}

class _DriverHistoryScreenState extends State<DriverHistoryScreen> {
  bool _isLoading = true;
  int _currentRideIndex = 0;
  List<Ride> _completedRides = [];

  @override
  void initState() {
    super.initState();
    _loadCompletedRides();
  }

  Future<void> _refreshData() async {
    await _loadCompletedRides();
  }

  Future<void> _loadCompletedRides() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final driverProvider = Provider.of<DriverProvider>(context, listen: false);
      
      // Get all rides for the driver
      await driverProvider.loadMyRides();
      final allRides = driverProvider.myRides;

      // Filter for completed rides
      final completedRides = allRides.where((ride) {
        return ride.status.toUpperCase() == 'COMPLETED';
      }).toList();

      if (mounted) {
        setState(() {
          _completedRides = completedRides;
          _isLoading = false;
          if (completedRides.isNotEmpty) {
            _currentRideIndex = 0;
          }
        });
      }
    } catch (e) {
      print('Error loading completed rides: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading history: ${e.toString()}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _navigateToPreviousRide() {
    if (_completedRides.isEmpty) return;

    setState(() {
      _currentRideIndex =
          (_currentRideIndex - 1 + _completedRides.length) % _completedRides.length;
    });
  }

  void _navigateToNextRide() {
    if (_completedRides.isEmpty) return;

    setState(() {
      _currentRideIndex = (_currentRideIndex + 1) % _completedRides.length;
    });
  }

  String _formatTimeRangeWithEnd(
    DateTime? startTime,
    DateTime? endTime,
    DateTime fallbackTime,
  ) {
    final timeFormat = DateFormat('h:mm a');
    final dateFormat = DateFormat('MMM d');
    if (startTime != null && endTime != null) {
      final sameDay =
          startTime.year == endTime.year &&
          startTime.month == endTime.month &&
          startTime.day == endTime.day;

      if (sameDay) {
        return '${timeFormat.format(startTime)} - ${timeFormat.format(endTime)}';
      } else {
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ride History')),
        drawer: widget.showInTabBar ? null : const AppDrawer(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_completedRides.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ride History')),
        drawer: widget.showInTabBar ? null : const AppDrawer(),
        body: const Center(
          child: Text(
            'No completed rides',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    // Ensure index is within bounds
    int safeIndex = _currentRideIndex;
    if (safeIndex >= _completedRides.length) {
      safeIndex = 0;
      if (mounted) {
        setState(() {
          _currentRideIndex = 0;
        });
      }
    }
    final currentRide = _completedRides[safeIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: widget.showInTabBar ? null : const AppDrawer(),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ride counter
                    Center(
                      child: Text(
                        'Ride ${safeIndex + 1} of ${_completedRides.length}',
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
                                      currentRide.departureTimeStart,
                                      currentRide.departureTimeEnd,
                                      currentRide.departureTime,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(
                                      currentRide.departureTimeStart ??
                                          currentRide.departureTime,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    currentRide.destinationLocationLabel.isNotEmpty
                                        ? currentRide.destinationLocationLabel
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
                                    '${currentRide.totalSeats - currentRide.availableSeats}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Seats Booked',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${currentRide.totalSeats} total',
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
                            // Start location
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
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
                                  padding: const EdgeInsets.only(left: 32),
                                  child: Text(
                                    currentRide.pickupLocationLabel.isNotEmpty
                                        ? currentRide.pickupLocationLabel
                                        : 'Pickup location',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Destination location
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.place,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
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
                                  padding: const EdgeInsets.only(left: 32),
                                  child: Text(
                                    currentRide.destinationLocationLabel.isNotEmpty
                                        ? currentRide.destinationLocationLabel
                                        : 'Destination location',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            if (currentRide.estimatedDistanceKm != null) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.straighten,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${currentRide.estimatedDistanceKm!.toStringAsFixed(1)} km',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  if (currentRide.estimatedDurationMinutes != null) ...[
                                    const SizedBox(width: 16),
                                    const Icon(
                                      Icons.access_time,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${currentRide.estimatedDurationMinutes} min',
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
                                    '${currentRide.vehicleMake} ${currentRide.vehicleModel}',
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
                                  currentRide.vehiclePlateNumber,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    color: Colors.green.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'COMPLETED',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (currentRide.basePrice != null ||
                                currentRide.pricePerSeat != null) ...[
                              const SizedBox(height: 12),
                              if (currentRide.basePrice != null)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Base Price:',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      'BD ${currentRide.basePrice!.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              if (currentRide.pricePerSeat != null)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Price per Seat:',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      'BD ${currentRide.pricePerSeat!.toStringAsFixed(2)}',
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
                  ElevatedButton.icon(
                    onPressed: _completedRides.length > 1
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
                  ElevatedButton.icon(
                    onPressed: _completedRides.length > 1
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
