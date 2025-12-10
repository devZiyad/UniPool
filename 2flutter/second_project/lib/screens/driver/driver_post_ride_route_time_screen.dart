import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/driver_provider.dart';
import '../../services/ride_service.dart';
import '../../services/location_service.dart';
import '../../services/vehicle_service.dart';
import '../../models/vehicle.dart';
import '../../widgets/app_drawer.dart';
import '../../theme/app_theme.dart';

class DriverPostRideRouteTimeScreen extends StatefulWidget {
  const DriverPostRideRouteTimeScreen({super.key});

  @override
  State<DriverPostRideRouteTimeScreen> createState() =>
      _DriverPostRideRouteTimeScreenState();
}

class _DriverPostRideRouteTimeScreenState
    extends State<DriverPostRideRouteTimeScreen> {
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  int _totalSeats = 4;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    // Initialize to today with default times
    final now = DateTime.now();
    _startDateTime = DateTime(now.year, now.month, now.day, 7, 0);
    _endDateTime = DateTime(now.year, now.month, now.day, 9, 0);
  }

  Future<void> _selectDateTimeRange() async {
    final now = DateTime.now();
    final maxDate = now.add(const Duration(days: 2));
    
    // Initialize with current values or defaults
    DateTime initialStart = _startDateTime ?? DateTime(now.year, now.month, now.day, 7, 0);
    DateTime initialEnd = _endDateTime ?? DateTime(now.year, now.month, now.day, 9, 0);

    // Show unified picker in a single dialog
    final result = await showDialog<Map<String, DateTime>>(
      context: context,
      builder: (context) => _UnifiedDateTimeRangePicker(
        initialStart: initialStart,
        initialEnd: initialEnd,
        firstDate: now,
        lastDate: maxDate,
      ),
    );

    if (result != null) {
      setState(() {
        _startDateTime = result['start']!;
        _endDateTime = result['end']!;
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
                      color: isActive ? AppTheme.primaryGreen : AppTheme.softGrayText,
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

    if (_startDateTime == null || _endDateTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select date and time range')));
      return;
    }

    // Validate dates are within 2 days
    final now = DateTime.now();
    final maxDate = now.add(const Duration(days: 2));
    if (_startDateTime!.isAfter(maxDate) || _endDateTime!.isAfter(maxDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dates cannot be more than 2 days in advance'),
        ),
      );
      return;
    }

    if (_endDateTime!.isBefore(_startDateTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date/time cannot be before start date/time')),
      );
      return;
    }

    // Use the date-time values directly
    var departureTimeStart = _startDateTime!;
    var departureTimeEnd = _endDateTime!;

    // If departure time start is in the past and it's today, add one day
    final today = DateTime(now.year, now.month, now.day);
    final selectedStartDate = DateTime(
      _startDateTime!.year,
      _startDateTime!.month,
      _startDateTime!.day,
    );
    if (departureTimeStart.isBefore(now) &&
        selectedStartDate.year == today.year &&
        selectedStartDate.month == today.month &&
        selectedStartDate.day == today.day) {
      departureTimeStart = departureTimeStart.add(const Duration(days: 1));
      // Also adjust end time if it's on the same day
      if (_endDateTime!.year == _startDateTime!.year &&
          _endDateTime!.month == _startDateTime!.month &&
          _endDateTime!.day == _startDateTime!.day) {
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
            color: AppTheme.lightGrayDivider,
            child: const Center(child: Text('Map View')),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.white,
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
                            backgroundColor: AppTheme.primaryGreen,
                          ),
                          SizedBox(height: 4),
                          Text('Start'),
                        ],
                      ),
                      Expanded(
                        child: Container(
                          height: 2,
                          color: AppTheme.primaryGreen,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                      const Column(
                        children: [
                          CircleAvatar(
                            radius: 8,
                            backgroundColor: AppTheme.primaryGreen,
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
                  // Unified Date-Time Range Selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Departure Time Range',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _selectDateTimeRange,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.lightGrayDivider),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Start',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.softGrayText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _startDateTime != null
                                          ? DateFormat('MMM dd, yyyy • HH:mm')
                                              .format(_startDateTime!)
                                          : 'Select start date & time',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(Icons.arrow_forward, size: 20),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'End',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.softGrayText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _endDateTime != null
                                          ? DateFormat('MMM dd, yyyy • HH:mm')
                                              .format(_endDateTime!)
                                          : 'Select end date & time',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You can select dates up to 2 days in advance',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.softGrayText,
                          fontStyle: FontStyle.italic,
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
                      backgroundColor: AppTheme.darkNavy,
                      foregroundColor: AppTheme.white,
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
                                AppTheme.white,
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

class _UnifiedDateTimeRangePicker extends StatefulWidget {
  final DateTime initialStart;
  final DateTime initialEnd;
  final DateTime firstDate;
  final DateTime lastDate;

  const _UnifiedDateTimeRangePicker({
    required this.initialStart,
    required this.initialEnd,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_UnifiedDateTimeRangePicker> createState() => _UnifiedDateTimeRangePickerState();
}

class _UnifiedDateTimeRangePickerState extends State<_UnifiedDateTimeRangePicker> {
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    // Use start date as the selected date
    _selectedDate = DateTime(
      widget.initialStart.year,
      widget.initialStart.month,
      widget.initialStart.day,
    );
    _startTime = TimeOfDay.fromDateTime(widget.initialStart);
    _endTime = TimeOfDay.fromDateTime(widget.initialEnd);
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day);
    });
  }

  void _incrementStartHour() {
    setState(() {
      final newHour = (_startTime.hour + 1) % 24;
      _startTime = TimeOfDay(hour: newHour, minute: _startTime.minute);
      _validateTimes();
    });
  }

  void _decrementStartHour() {
    setState(() {
      final newHour = (_startTime.hour - 1 + 24) % 24;
      _startTime = TimeOfDay(hour: newHour, minute: _startTime.minute);
      _validateTimes();
    });
  }

  void _incrementStartMinute() {
    setState(() {
      int newMinute = _startTime.minute + 15;
      int newHour = _startTime.hour;
      if (newMinute >= 60) {
        newMinute = 0;
        newHour = (newHour + 1) % 24;
      }
      _startTime = TimeOfDay(hour: newHour, minute: newMinute);
      _validateTimes();
    });
  }

  void _decrementStartMinute() {
    setState(() {
      int newMinute = _startTime.minute - 15;
      int newHour = _startTime.hour;
      if (newMinute < 0) {
        newMinute = 45;
        newHour = (newHour - 1 + 24) % 24;
      }
      _startTime = TimeOfDay(hour: newHour, minute: newMinute);
      _validateTimes();
    });
  }

  void _incrementEndHour() {
    setState(() {
      final newHour = (_endTime.hour + 1) % 24;
      _endTime = TimeOfDay(hour: newHour, minute: _endTime.minute);
      _validateTimes();
    });
  }

  void _decrementEndHour() {
    setState(() {
      final newHour = (_endTime.hour - 1 + 24) % 24;
      _endTime = TimeOfDay(hour: newHour, minute: _endTime.minute);
      _validateTimes();
    });
  }

  void _incrementEndMinute() {
    setState(() {
      int newMinute = _endTime.minute + 15;
      int newHour = _endTime.hour;
      if (newMinute >= 60) {
        newMinute = 0;
        newHour = (newHour + 1) % 24;
      }
      _endTime = TimeOfDay(hour: newHour, minute: newMinute);
      _validateTimes();
    });
  }

  void _decrementEndMinute() {
    setState(() {
      int newMinute = _endTime.minute - 15;
      int newHour = _endTime.hour;
      if (newMinute < 0) {
        newMinute = 45;
        newHour = (newHour - 1 + 24) % 24;
      }
      _endTime = TimeOfDay(hour: newHour, minute: newMinute);
      _validateTimes();
    });
  }

  void _validateTimes() {
    // Ensure end time is after start time
    if (_endTime.hour < _startTime.hour || 
        (_endTime.hour == _startTime.hour && _endTime.minute <= _startTime.minute)) {
      _endTime = TimeOfDay(
        hour: (_startTime.hour + 1) % 24,
        minute: _startTime.minute,
      );
    }
  }

  void _confirm() {
    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    final endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    // Validate end is after start
    if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time'),
        ),
      );
      return;
    }

    Navigator.of(context).pop({
      'start': startDateTime,
      'end': endDateTime,
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxDate = widget.lastDate;
    final firstDate = widget.firstDate;
    
    // Generate available dates (today, tomorrow, day after)
    final availableDates = <DateTime>[];
    for (int i = 0; i <= 2; i++) {
      final date = firstDate.add(Duration(days: i));
      if (!date.isAfter(maxDate)) {
        availableDates.add(date);
      }
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Date & Time Range',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Inline Date Selection
              const Text(
                'Date',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: availableDates.map((date) {
                  final isSelected = date.year == _selectedDate.year &&
                      date.month == _selectedDate.month &&
                      date.day == _selectedDate.day;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () => _selectDate(date),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.darkNavy : AppTheme.lightGrayDivider,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                DateFormat('EEE').format(date),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected ? AppTheme.white : AppTheme.softGrayText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('dd').format(date),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? AppTheme.white : AppTheme.darkNavy,
                                ),
                              ),
                              Text(
                                DateFormat('MMM').format(date),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected ? AppTheme.white : AppTheme.softGrayText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              // Inline Time Range Selection
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Start Time',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.lightGrayDivider),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_drop_up),
                                    onPressed: _incrementStartHour,
                                  ),
                                  Text(
                                    _startTime.hour.toString().padLeft(2, '0'),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.arrow_drop_down),
                                    onPressed: _decrementStartHour,
                                  ),
                                ],
                              ),
                              const Text(':', style: TextStyle(fontSize: 24)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_drop_up),
                                    onPressed: _incrementStartMinute,
                                  ),
                                  Text(
                                    _startTime.minute.toString().padLeft(2, '0'),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.arrow_drop_down),
                                    onPressed: _decrementStartMinute,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Icon(Icons.arrow_forward, size: 24),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'End Time',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.lightGrayDivider),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_drop_up),
                                    onPressed: _incrementEndHour,
                                  ),
                                  Text(
                                    _endTime.hour.toString().padLeft(2, '0'),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.arrow_drop_down),
                                    onPressed: _decrementEndHour,
                                  ),
                                ],
                              ),
                              const Text(':', style: TextStyle(fontSize: 24)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_drop_up),
                                    onPressed: _incrementEndMinute,
                                  ),
                                  Text(
                                    _endTime.minute.toString().padLeft(2, '0'),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.arrow_drop_down),
                                    onPressed: _decrementEndMinute,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Confirm',
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
    );
  }
}
