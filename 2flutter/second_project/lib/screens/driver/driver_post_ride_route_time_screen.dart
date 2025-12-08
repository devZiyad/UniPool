import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/driver_provider.dart';
import '../../services/ride_service.dart';
import '../../services/location_service.dart';
import '../../services/vehicle_service.dart';
import '../../models/vehicle.dart';
import '../../widgets/app_drawer.dart';

class DriverPostRideRouteTimeScreen extends StatefulWidget {
  const DriverPostRideRouteTimeScreen({super.key});

  @override
  State<DriverPostRideRouteTimeScreen> createState() =>
      _DriverPostRideRouteTimeScreenState();
}

class _DriverPostRideRouteTimeScreenState
    extends State<DriverPostRideRouteTimeScreen> {
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isAMStart = true;
  bool _isAMEnd = true;
  int _totalSeats = 4;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    // Initialize dates to today
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate = DateTime(now.year, now.month, now.day);
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

  Future<Vehicle?> _showVehicleSelectionDialog() async {
    try {
      final vehicles = await VehicleService.getMyVehicles();

      if (vehicles.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No vehicles found. Please add a vehicle first.'),
            ),
          );
        }
        return null;
      }

      return showDialog<Vehicle>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Vehicle'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  final isActive = vehicle.active ?? false;
                  return ListTile(
                    leading: Icon(
                      isActive ? Icons.check_circle : Icons.circle_outlined,
                      color: isActive ? Colors.green : Colors.grey,
                    ),
                    title: Text(
                      '${vehicle.make} ${vehicle.model}',
                      style: TextStyle(
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      '${vehicle.plateNumber} • ${vehicle.seatCount} seats${isActive ? ' • Active' : ''}',
                    ),
                    onTap: () {
                      Navigator.of(context).pop(vehicle);
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading vehicles: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
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

    // Calculate hour correctly for AM/PM
    int startHour = _startTime!.hour;
    if (!_isAMStart && startHour != 12) {
      startHour = startHour + 12;
    } else if (_isAMStart && startHour == 12) {
      startHour = 0;
    }

    int endHour = _endTime!.hour;
    if (!_isAMEnd && endHour != 12) {
      endHour = endHour + 12;
    } else if (_isAMEnd && endHour == 12) {
      endHour = 0;
    }

    // Calculate departure time start
    var departureTimeStart = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      startHour,
      _startTime!.minute,
    );

    // Calculate departure time end
    var departureTimeEnd = DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      endHour,
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

    // Show vehicle selection dialog
    final selectedVehicle = await _showVehicleSelectionDialog();
    if (selectedVehicle == null) {
      return; // User cancelled or no vehicles available
    }

    setState(() {
      _isPosting = true;
    });

    try {
      final driverProvider = Provider.of<DriverProvider>(
        context,
        listen: false,
      );
      final vehicle = selectedVehicle;

      // Create locations if they don't have IDs (e.g., selected from map)
      var pickupLocation = driverProvider.pickupLocation!;
      if (pickupLocation.id == null) {
        pickupLocation = await LocationService.createLocation(
          label: pickupLocation.label,
          address: pickupLocation.address,
          latitude: pickupLocation.latitude,
          longitude: pickupLocation.longitude,
        );
      }

      var destinationLocation = driverProvider.destinationLocation!;
      if (destinationLocation.id == null) {
        destinationLocation = await LocationService.createLocation(
          label: destinationLocation.label,
          address: destinationLocation.address,
          latitude: destinationLocation.latitude,
          longitude: destinationLocation.longitude,
        );
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            duration: const Duration(seconds: 5),
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

  @override
  Widget build(BuildContext context) {
    final driverProvider = Provider.of<DriverProvider>(context);
    final pickup = driverProvider.pickupLocation;
    final destination = driverProvider.destinationLocation;

    return Scaffold(
      appBar: AppBar(title: const Text('Post Ride')),
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
                                      ? '${_startTime!.hour.toString().padLeft(2, '0')} : ${_startTime!.minute.toString().padLeft(2, '0')}'
                                      : '07 : 00',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _isAMStart = true;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isAMStart
                                          ? Colors.green
                                          : Colors.grey[300],
                                    ),
                                    child: const Text('AM'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _isAMStart = false;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: !_isAMStart
                                          ? Colors.green
                                          : Colors.grey[300],
                                    ),
                                    child: const Text('PM'),
                                  ),
                                ),
                              ],
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
                                      ? '${_endTime!.hour.toString().padLeft(2, '0')} : ${_endTime!.minute.toString().padLeft(2, '0')}'
                                      : '09 : 00',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _isAMEnd = true;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isAMEnd
                                          ? Colors.green
                                          : Colors.grey[300],
                                    ),
                                    child: const Text('AM'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _isAMEnd = false;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: !_isAMEnd
                                          ? Colors.green
                                          : Colors.grey[300],
                                    ),
                                    child: const Text('PM'),
                                  ),
                                ),
                              ],
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
                      const Text('Available Seats:'),
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
                    onPressed: _isPosting ? null : _postRide,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isPosting
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
                        : const Text(
                            'Post Ride',
                            style: TextStyle(
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
