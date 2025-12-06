import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/driver_provider.dart';
import '../../widgets/app_drawer.dart';

class DriverRideManagementScreen extends StatefulWidget {
  const DriverRideManagementScreen({super.key});

  @override
  State<DriverRideManagementScreen> createState() =>
      _DriverRideManagementScreenState();
}

class _DriverRideManagementScreenState
    extends State<DriverRideManagementScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkActiveRide();
  }

  Future<void> _checkActiveRide() async {
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);

    // Load rides to check for active one
    try {
      await driverProvider.loadMyRides();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading ride: ${e.toString()}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  String _formatTimeRange(DateTime departureTime) {
    final timeFormat = DateFormat('h:mm a');
    return timeFormat.format(departureTime);
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final driverProvider = Provider.of<DriverProvider>(context);
    final activeRide = driverProvider.activeRide;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ride Management')),
        drawer: AppDrawer(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // If no rides at all, show "no current rides" message
    if (driverProvider.myRides.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ride Management')),
        drawer: AppDrawer(),
        body: const Center(
          child: Text(
            'No current rides',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    // If no active ride, show empty state
    if (activeRide == null ||
        (activeRide.status != 'POSTED' && activeRide.status != 'IN_PROGRESS')) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ride Management')),
        drawer: AppDrawer(),
        body: const Center(
          child: Text(
            'No current rides',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ride Management')),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                            _formatTimeRange(activeRide.departureTime),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(activeRide.departureTime),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            activeRide.destinationLocationLabel.isNotEmpty
                                ? activeRide.destinationLocationLabel
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
                            '${activeRide.availableSeats}',
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
                            '${activeRide.totalSeats - activeRide.availableSeats}/${activeRide.totalSeats} booked',
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
                        const Icon(Icons.location_on, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            activeRide.pickupLocationLabel.isNotEmpty
                                ? activeRide.pickupLocationLabel
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
                            activeRide.destinationLocationLabel.isNotEmpty
                                ? activeRide.destinationLocationLabel
                                : 'Destination location',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    if (activeRide.estimatedDistanceKm != null) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.straighten, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            '${activeRide.estimatedDistanceKm!.toStringAsFixed(1)} km',
                            style: const TextStyle(fontSize: 14),
                          ),
                          if (activeRide.estimatedDurationMinutes != null) ...[
                            const SizedBox(width: 16),
                            const Icon(Icons.access_time, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              '${activeRide.estimatedDurationMinutes} min',
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
            // Requests section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'New Requests',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/driver/incoming-requests');
                  },
                  child: const Text('View all'),
                ),
              ],
            ),
            if (driverProvider.pendingBookings.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.inbox, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'No pending requests',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...driverProvider.pendingBookings.take(3).map((booking) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        booking.riderName.substring(0, 1).toUpperCase(),
                      ),
                    ),
                    title: Text(booking.riderName),
                    subtitle: Text(
                      '${booking.seatsBooked} seat${booking.seatsBooked > 1 ? 's' : ''} requested',
                    ),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.pushNamed(context, '/driver/incoming-requests');
                    },
                  ),
                );
              }),
            const SizedBox(height: 24),
            // Accepted riders section
            if (driverProvider.acceptedBookings.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Accepted Riders',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/driver/accepted-riders');
                    },
                    child: const Text('View all'),
                  ),
                ],
              ),
              ...driverProvider.acceptedBookings.take(3).map((booking) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.check, color: Colors.white),
                    ),
                    title: Text(booking.riderName),
                    subtitle: Text(
                      '${booking.seatsBooked} seat${booking.seatsBooked > 1 ? 's' : ''} confirmed',
                    ),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.pushNamed(context, '/driver/accepted-riders');
                    },
                  ),
                );
              }),
            ],
            const SizedBox(height: 24),
            // Action buttons
            if (activeRide.status == 'POSTED')
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/driver/accepted-riders');
                },
                icon: const Icon(Icons.directions_car),
                label: const Text('Start Ride'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
