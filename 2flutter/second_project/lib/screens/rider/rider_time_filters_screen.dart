import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/ride_provider.dart';

class RiderTimeFiltersScreen extends StatefulWidget {
  const RiderTimeFiltersScreen({super.key});

  @override
  State<RiderTimeFiltersScreen> createState() => _RiderTimeFiltersScreenState();
}

class _RiderTimeFiltersScreenState extends State<RiderTimeFiltersScreen> {
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isAMStart = true;
  bool _isAMEnd = true;

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

  void _searchRides() {
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select time range')));
      return;
    }

    final now = DateTime.now();
    final startDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _isAMStart ? _startTime!.hour : _startTime!.hour + 12,
      _startTime!.minute,
    );
    final endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _isAMEnd ? _endTime!.hour : _endTime!.hour + 12,
      _endTime!.minute,
    );

    Provider.of<RideProvider>(
      context,
      listen: false,
    ).setDepartureTimeRange(startDateTime, endDateTime);

    Provider.of<RideProvider>(context, listen: false).searchRides().then((_) {
      Navigator.pushNamed(context, '/rider/ride-list');
    });
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = Provider.of<RideProvider>(context);
    final pickup = rideProvider.pickupLocation;
    final destination = rideProvider.destinationLocation;

    return Scaffold(
      body: Stack(
        children: [
          // Map placeholder
          Container(
            color: Colors.grey[200],
            child: const Center(child: Text('Map View')),
          ),
          // Bottom sheet
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
                          Text('Pick-up'),
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
                          Text('Drop off'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('My current location'),
                  Text(destination?.label ?? 'Destination'),
                  const SizedBox(height: 24),
                  const Text(
                    'Select time:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Start'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
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
                                ),
                              ],
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
                                      foregroundColor: _isAMStart
                                          ? Colors.white
                                          : Colors.black,
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
                                      foregroundColor: !_isAMStart
                                          ? Colors.white
                                          : Colors.black,
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
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
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
                                ),
                              ],
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
                                      foregroundColor: _isAMEnd
                                          ? Colors.white
                                          : Colors.black,
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
                                      foregroundColor: !_isAMEnd
                                          ? Colors.white
                                          : Colors.black,
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
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _searchRides,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_car),
                        SizedBox(width: 8),
                        Text(
                          'Go Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
