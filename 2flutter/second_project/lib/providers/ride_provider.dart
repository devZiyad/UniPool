import 'package:flutter/foundation.dart';
import '../models/ride.dart';
import '../models/location.dart';
import '../services/ride_service.dart';
import '../services/location_service.dart';

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
    if (_pickupLocation == null || _destinationLocation == null) {
      _error = 'Please select pickup and destination locations';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _availableRides = await RideService.searchRides(
        pickupLatitude: _pickupLocation!.latitude,
        pickupLongitude: _pickupLocation!.longitude,
        pickupRadiusKm: 5.0,
        destinationLatitude: _destinationLocation!.latitude,
        destinationLongitude: _destinationLocation!.longitude,
        destinationRadiusKm: 5.0,
        departureTimeFrom: _departureTimeFrom,
        departureTimeTo: _departureTimeTo,
        minAvailableSeats: _seatsNeeded,
        sortBy: 'distance',
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
