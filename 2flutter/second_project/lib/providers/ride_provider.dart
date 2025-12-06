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
      // Search without location filters - only by time
      final allRides = await RideService.searchRides(
        departureTimeFrom: _departureTimeFrom,
        departureTimeTo: _departureTimeTo,
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

        // Get ride's departure time (use departureTimeStart if available, otherwise departureTime)
        final rideDepartureTime = ride.departureTimeStart ?? ride.departureTime;

        // Show ride if its departureTime falls within the search time range (inclusive)
        // Condition: searchStart <= rideDepartureTime <= searchEnd
        final matches =
            rideDepartureTime.compareTo(searchStart) >= 0 &&
            rideDepartureTime.compareTo(searchEnd) <= 0;

        if (matches) {
          print(
            '  Ride ${ride.id}: MATCH - Ride departureTime: ${rideDepartureTime.toIso8601String()} is within search range [${searchStart.toIso8601String()}, ${searchEnd.toIso8601String()}]',
          );
        } else {
          print(
            '  Ride ${ride.id}: NO MATCH - Ride departureTime: ${rideDepartureTime.toIso8601String()} is outside search range [${searchStart.toIso8601String()}, ${searchEnd.toIso8601String()}]',
          );
        }

        return matches;
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
