import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/driver_provider.dart';
import '../../providers/ride_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/ride_service.dart';
import '../../services/location_service.dart';
import '../../services/vehicle_service.dart';
import '../../widgets/app_drawer.dart';

class RiderTimeFiltersScreen extends StatefulWidget {
  const RiderTimeFiltersScreen({super.key});

  @override
  State<RiderTimeFiltersScreen> createState() => _RiderTimeFiltersScreenState();
}

class _RiderTimeFiltersScreenState extends State<RiderTimeFiltersScreen> {
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  DateTime? _startDate;
  DateTime? _endDate;
  int _totalSeats = 1; // For rider: seats needed, for driver: seats available
  bool _isPosting = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Initialize dates to today
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate = DateTime(now.year, now.month, now.day);
  }

  bool get _isDriver {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final role = authProvider.user?.role ?? '';
    return role == 'DRIVER' || role == 'BOTH';
  }

  String _formatTimeOfDay(TimeOfDay time) {
    int hour = time.hour;
    final String period;
    if (hour == 0) {
      hour = 12;
      period = 'AM';
    } else if (hour < 12) {
      period = 'AM';
    } else if (hour == 12) {
      period = 'PM';
    } else {
      hour = hour - 12;
      period = 'PM';
    }
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour : $minute $period';
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<void> _selectStartDate() async {
    final now = DateTime.now();
    final maxDate = now.add(const Duration(days: 2));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now,
      lastDate: maxDate,
      helpText: 'Select start date',
    );
    if (picked != null) {
      setState(() {
        _startDate = DateTime(picked.year, picked.month, picked.day);
        // If end date is before start date, update it
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final now = DateTime.now();
    final maxDate = now.add(const Duration(days: 2));
    final firstDate = _startDate ?? now;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? firstDate,
      firstDate: firstDate,
      lastDate: maxDate,
      helpText: 'Select end date',
    );
    if (picked != null) {
      setState(() {
        _endDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  Future<void> _postRide() async {
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    if (driverProvider.pickupLocation == null ||
        driverProvider.destinationLocation == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select locations')));
      return;
    }

    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select time range')));
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select dates')));
      return;
    }

    // Validate dates are within 2 days
    final now = DateTime.now();
    final maxDate = now.add(const Duration(days: 2));
    if (_startDate!.isAfter(maxDate) || _endDate!.isAfter(maxDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dates cannot be more than 2 days in advance'),
        ),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date cannot be before start date')),
      );
      return;
    }

    // TimeOfDay already stores hour in 24-hour format (0-23)
    // Calculate departure time start
    var departureTimeStart = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    // Calculate departure time end
    var departureTimeEnd = DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    // If departure time start is in the past and it's today, add one day
    final today = DateTime(now.year, now.month, now.day);
    final selectedStartDate = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
    );
    if (departureTimeStart.isBefore(now) &&
        selectedStartDate.year == today.year &&
        selectedStartDate.month == today.month &&
        selectedStartDate.day == today.day) {
      departureTimeStart = departureTimeStart.add(const Duration(days: 1));
      // Also adjust end time if it's on the same day
      if (_endDate!.year == _startDate!.year &&
          _endDate!.month == _startDate!.month &&
          _endDate!.day == _startDate!.day) {
        departureTimeEnd = departureTimeEnd.add(const Duration(days: 1));
      }
    }

    setState(() {
      _isPosting = true;
    });

    try {
      // Get user's active vehicles
      final vehicles = await VehicleService.getMyVehicles();
      final activeVehicles = vehicles.where((v) => v.active ?? false).toList();

      if (activeVehicles.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No active vehicles found. Please add a vehicle first.',
              ),
            ),
          );
        }
        setState(() {
          _isPosting = false;
        });
        return;
      }

      // Use the first active vehicle
      final vehicle = activeVehicles.first;

      // Create locations if they don't have IDs (e.g., selected from map)
      var pickupLocation = driverProvider.pickupLocation!;
      if (pickupLocation.id == null) {
        try {
          pickupLocation = await LocationService.createLocation(
            label: pickupLocation.label,
            address: pickupLocation.address,
            latitude: pickupLocation.latitude,
            longitude: pickupLocation.longitude,
          );
          print('Created pickup location with ID: ${pickupLocation.id}');
        } catch (e) {
          print('Error creating pickup location: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error creating pickup location: ${e.toString()}',
                ),
                duration: const Duration(seconds: 5),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() {
            _isPosting = false;
          });
          return;
        }
      }

      var destinationLocation = driverProvider.destinationLocation!;
      if (destinationLocation.id == null) {
        try {
          destinationLocation = await LocationService.createLocation(
            label: destinationLocation.label,
            address: destinationLocation.address,
            latitude: destinationLocation.latitude,
            longitude: destinationLocation.longitude,
          );
          print(
            'Created destination location with ID: ${destinationLocation.id}',
          );
        } catch (e) {
          print('Error creating destination location: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error creating destination location: ${e.toString()}',
                ),
                duration: const Duration(seconds: 5),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() {
            _isPosting = false;
          });
          return;
        }
      }

      // Ensure both locations have IDs
      if (pickupLocation.id == null || destinationLocation.id == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Location IDs are missing. Please try selecting locations again.',
              ),
              duration: Duration(seconds: 5),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isPosting = false;
        });
        return;
      }

      // Validate total seats doesn't exceed vehicle capacity
      if (_totalSeats > vehicle.seatCount) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Total seats ($_totalSeats) cannot exceed vehicle capacity (${vehicle.seatCount})',
              ),
            ),
          );
        }
        setState(() {
          _isPosting = false;
        });
        return;
      }

      print('Creating ride with:');
      print('  vehicleId: ${vehicle.id}');
      print('  pickupLocationId: ${pickupLocation.id}');
      print('  destinationLocationId: ${destinationLocation.id}');
      print('  departureTimeStart: ${departureTimeStart.toIso8601String()}');
      print('  departureTimeEnd: ${departureTimeEnd.toIso8601String()}');
      print('  totalSeats: $_totalSeats');

      final driverProvider = Provider.of<DriverProvider>(
        context,
        listen: false,
      );

      await RideService.createRide(
        vehicleId: vehicle.id,
        pickupLocationId: pickupLocation.id!,
        destinationLocationId: destinationLocation.id!,
        departureTimeStart: departureTimeStart,
        departureTimeEnd: departureTimeEnd,
        totalSeats: _totalSeats,
        routeId: driverProvider.routeId,
      );

      if (mounted) {
        Navigator.pushNamed(context, '/driver/ride-posted-confirmation');
      }
    } catch (e) {
      print('Error creating ride: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  Future<void> _searchRides() async {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    // Locations are no longer required for rider search - only time is needed
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select time range')));
      return;
    }

    final now = DateTime.now();
    // TimeOfDay already stores hour in 24-hour format (0-23)
    final startDateTime = DateTime(
      _startDate?.year ?? now.year,
      _startDate?.month ?? now.month,
      _startDate?.day ?? now.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    final endDateTime = DateTime(
      _endDate?.year ?? now.year,
      _endDate?.month ?? now.month,
      _endDate?.day ?? now.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    rideProvider.setDepartureTimeRange(startDateTime, endDateTime);
    rideProvider.setSeatsNeeded(_totalSeats);

    setState(() {
      _isSearching = true;
    });

    try {
      await rideProvider.searchRides();
      if (mounted) {
        Navigator.pushNamed(context, '/rider/ride-list');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final driverProvider = Provider.of<DriverProvider>(context);
    final rideProvider = Provider.of<RideProvider>(context);
    final pickup = _isDriver
        ? driverProvider.pickupLocation
        : rideProvider.pickupLocation;
    final destination = _isDriver
        ? driverProvider.destinationLocation
        : rideProvider.destinationLocation;

    return Scaffold(
      appBar: AppBar(title: Text(_isDriver ? 'Post Ride' : 'Search Rides')),
      drawer: AppDrawer(),
      body: Stack(
        children: [
          Container(
            color: Colors.grey[200],
            child: const Center(child: Text('Map View')),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Where are you going today?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Route preview
                  Row(
                    children: [
                      const Column(
                        children: [
                          CircleAvatar(
                            radius: 8,
                            backgroundColor: Colors.green,
                          ),
                          SizedBox(height: 4),
                          Text('Start'),
                        ],
                      ),
                      Expanded(
                        child: Container(
                          height: 2,
                          color: Colors.green,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                      const Column(
                        children: [
                          CircleAvatar(
                            radius: 8,
                            backgroundColor: Colors.green,
                          ),
                          SizedBox(height: 4),
                          Text('Destination'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(pickup?.label ?? 'Start location'),
                  Text(destination?.label ?? 'Destination'),
                  const SizedBox(height: 24),
                  // Date selection
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Start Date'),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _selectStartDate,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      _startDate != null
                                          ? DateFormat(
                                              'MMM dd, yyyy',
                                            ).format(_startDate!)
                                          : 'Select date',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('End Date'),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _selectEndDate,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      _endDate != null
                                          ? DateFormat(
                                              'MMM dd, yyyy',
                                            ).format(_endDate!)
                                          : 'Select date',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You can select dates up to 2 days in advance',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Time selection
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Start Time'),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _selectStartTime,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _startTime != null
                                      ? _formatTimeOfDay(_startTime!)
                                      : '07 : 00 AM',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.arrow_forward),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('End Time'),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _selectEndTime,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _endTime != null
                                      ? _formatTimeOfDay(_endTime!)
                                      : '09 : 00 AM',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Seats selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_isDriver ? 'Available Seats:' : 'Seats Needed:'),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              if (_totalSeats > 1) {
                                setState(() {
                                  _totalSeats--;
                                });
                              }
                            },
                          ),
                          Text(
                            '$_totalSeats',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                _totalSeats++;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: (_isPosting || _isSearching)
                        ? null
                        : (_isDriver ? _postRide : _searchRides),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isDriver ? Colors.black : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: (_isPosting || _isSearching)
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            _isDriver ? 'Post Ride' : 'Search Rides',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
