import 'package:flutter/foundation.dart';
import '../models/ride.dart';
import '../models/booking.dart';
import '../models/location.dart';
import '../services/ride_service.dart';
import '../services/booking_service.dart';

class DriverProvider with ChangeNotifier {
  List<Ride> _myRides = [];
  Ride? _activeRide;
  List<Booking> _pendingBookings = [];
  List<Booking> _acceptedBookings = [];
  Location? _pickupLocation;
  Location? _destinationLocation;
  DateTime? _departureTime;
  int _totalSeats = 4;
  bool _isLoading = false;
  String? _error;

  List<Ride> get myRides => _myRides;
  Ride? get activeRide => _activeRide;
  List<Booking> get pendingBookings => _pendingBookings;
  List<Booking> get acceptedBookings => _acceptedBookings;
  Location? get pickupLocation => _pickupLocation;
  Location? get destinationLocation => _destinationLocation;
  DateTime? get departureTime => _departureTime;
  int get totalSeats => _totalSeats;
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

  void setDepartureTime(DateTime? time) {
    _departureTime = time;
    notifyListeners();
  }

  void setTotalSeats(int seats) {
    _totalSeats = seats;
    notifyListeners();
  }

  Future<void> loadMyRides() async {
    _isLoading = true;
    notifyListeners();

    try {
      _myRides = await RideService.getMyRidesAsDriver();
      _activeRide = _myRides.firstWhere(
        (ride) => ride.status == 'POSTED' || ride.status == 'IN_PROGRESS',
        orElse: () => _myRides.first,
      );
      if (_activeRide != null) {
        await loadBookingsForRide(_activeRide!.id);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBookingsForRide(int rideId) async {
    try {
      final bookings = await BookingService.getBookingsForRide(rideId);
      _pendingBookings = bookings.where((b) => b.status == 'PENDING').toList();
      _acceptedBookings = bookings
          .where((b) => b.status == 'CONFIRMED')
          .toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearRideForm() {
    _pickupLocation = null;
    _destinationLocation = null;
    _departureTime = null;
    _totalSeats = 4;
    _error = null;
    notifyListeners();
  }
}
