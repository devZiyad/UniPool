import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/driver_provider.dart';
import '../../services/ride_service.dart';
import '../../services/location_service.dart';
import '../../services/vehicle_service.dart';
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
  bool _isAMStart = true;
  bool _isAMEnd = true;
  int _totalSeats = 4;
  bool _isPosting = false;

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

    // Calculate hour correctly for AM/PM
    int hour = _startTime!.hour;
    if (!_isAMStart && hour != 12) {
      hour = hour + 12;
    } else if (_isAMStart && hour == 12) {
      hour = 0;
    }

    final now = DateTime.now();
    var departureTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      _startTime!.minute,
    );

    // If departure time is in the past, add one day
    if (departureTime.isBefore(now)) {
      departureTime = departureTime.add(const Duration(days: 1));
    }

    setState(() {
      _isPosting = true;
    });

    try {
      // Get user's active vehicles
      final vehicles = await VehicleService.getMyVehicles();
      final activeVehicles = vehicles.where((v) => v.active).toList();

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
        departureTime: departureTime,
        totalSeats: _totalSeats,
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
                  // Time selection
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Start'),
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
                            const Text('End'),
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
