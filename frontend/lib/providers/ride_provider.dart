import 'package:flutter/foundation.dart';
import '../models/ride.dart';
import '../models/location.dart';
import '../services/ride_service.dart';

class RideProvider with ChangeNotifier {
  List<Ride> _availableRides = [];
  Ride? _selectedRide;
  Location? _pickupLocation;
  Location? _destinationLocation;
  DateTime? _departureTimeFrom;
  DateTime? _departureTimeTo;
  int _seatsNeeded = 1;
  bool _isLoading = false;
  String? _error;

  List<Ride> get availableRides => _availableRides;
  Ride? get selectedRide => _selectedRide;
  Location? get pickupLocation => _pickupLocation;
  Location? get destinationLocation => _destinationLocation;
  DateTime? get departureTimeFrom => _departureTimeFrom;
  DateTime? get departureTimeTo => _departureTimeTo;
  int get seatsNeeded => _seatsNeeded;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setPickupLocation(Location? location) {
    _pickupLocation = location;
    notifyListeners();
  }

  void setDestinationLocation(Location? location) {
    _destinationLocation = location;
    notifyListeners();
  }

  void setDepartureTimeRange(DateTime? from, DateTime? to) {
    _departureTimeFrom = from;
    _departureTimeTo = to;
    notifyListeners();
  }

  void setSeatsNeeded(int seats) {
    _seatsNeeded = seats;
    notifyListeners();
  }

  void setSelectedRide(Ride? ride) {
    _selectedRide = ride;
    notifyListeners();
  }

  Future<void> searchRides() async {
    // No longer require pickup and destination locations
    if (_departureTimeFrom == null || _departureTimeTo == null) {
      _error = 'Please select departure time range';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Convert local times to UTC before sending to API
      // The API expects all times in UTC, but we store them in local time for display
      final departureTimeFromUtc = _departureTimeFrom!.toUtc();
      final departureTimeToUtc = _departureTimeTo!.toUtc();
      
      // Search without location filters - only by time
      final allRides = await RideService.searchRides(
        departureTimeFrom: departureTimeFromUtc,
        departureTimeTo: departureTimeToUtc,
        minAvailableSeats: _seatsNeeded,
        sortBy: 'departureTime',
      );

      final now = DateTime.now();
      final searchStart = _departureTimeFrom!;
      final searchEnd = _departureTimeTo!;

      // Filter rides: show ride if its departureTime falls anywhere between
      // departureTimeFrom and departureTimeTo (inclusive)
      // Condition: departureTimeFrom <= ride.departureTime <= departureTimeTo
      print(
        'RideProvider.searchRides - Search time range: ${searchStart.toIso8601String()} to ${searchEnd.toIso8601String()}',
      );
      print(
        'RideProvider.searchRides - Total rides from API: ${allRides.length}',
      );

      _availableRides = allRides.where((ride) {
        // Check if ride is in the future
        final rideStartTime = ride.departureTimeStart ?? ride.departureTime;
        if (!rideStartTime.isAfter(now)) {
          return false;
        }

        // Get ride's departure time range
        // Use departureTimeStart/departureTimeEnd if available, otherwise use departureTime as both start and end
        final rideTimeStart = ride.departureTimeStart ?? ride.departureTime;
        final rideTimeEnd = ride.departureTimeEnd ?? ride.departureTime;

        // Check for time range overlap between ride's departure time range and search time range
        // Two ranges overlap if: rideStart <= searchEnd AND rideEnd >= searchStart
        final hasOverlap = rideTimeStart.compareTo(searchEnd) <= 0 &&
            rideTimeEnd.compareTo(searchStart) >= 0;

        if (hasOverlap) {
          print(
            '  Ride ${ride.id}: MATCH - Ride time range [${rideTimeStart.toIso8601String()}, ${rideTimeEnd.toIso8601String()}] overlaps with search range [${searchStart.toIso8601String()}, ${searchEnd.toIso8601String()}]',
          );
        } else {
          print(
            '  Ride ${ride.id}: NO MATCH - Ride time range [${rideTimeStart.toIso8601String()}, ${rideTimeEnd.toIso8601String()}] does not overlap with search range [${searchStart.toIso8601String()}, ${searchEnd.toIso8601String()}]',
          );
        }

        return hasOverlap;
      }).toList();

      print(
        'RideProvider.searchRides - Rides after intersection filter: ${_availableRides.length}',
      );

      // Sort by available seats (descending - most seats first)
      _availableRides.sort(
        (a, b) => b.availableSeats.compareTo(a.availableSeats),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _availableRides = [];
    _selectedRide = null;
    _pickupLocation = null;
    _destinationLocation = null;
    _departureTimeFrom = null;
    _departureTimeTo = null;
    _seatsNeeded = 1;
    _error = null;
    notifyListeners();
  }
}
