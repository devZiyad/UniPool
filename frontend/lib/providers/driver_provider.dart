import 'package:flutter/foundation.dart';
import '../models/ride.dart';
import '../models/booking.dart';
import '../models/location.dart';
import '../services/ride_service.dart';
import '../services/booking_service.dart';
import '../services/user_service.dart';

class DriverProvider with ChangeNotifier {
  List<Ride> _myRides = [];
  Ride? _activeRide;
  List<Booking> _pendingBookings = [];
  List<Booking> _acceptedBookings = [];
  Location? _pickupLocation;
  Location? _destinationLocation;
  DateTime? _departureTime;
  int _totalSeats = 4;
  int? _routeId;
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
  int? get routeId => _routeId;
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
      print('DriverProvider.loadMyRides - Loaded ${_myRides.length} rides');
      print(
        'DriverProvider.loadMyRides - Ride statuses: ${_myRides.map((r) => '${r.id}:${r.status}').join(', ')}',
      );

      // Find active ride (POSTED or IN_PROGRESS status) - case-insensitive
      try {
        _activeRide = _myRides.firstWhere(
          (ride) =>
              ride.status.toUpperCase() == 'POSTED' ||
              ride.status.toUpperCase() == 'IN_PROGRESS',
        );
        print(
          'DriverProvider.loadMyRides - Found active ride: ${_activeRide!.id} with status ${_activeRide!.status}',
        );
      } catch (e) {
        // No active ride found
        _activeRide = null;
        print('DriverProvider.loadMyRides - No active ride found');
      }
      if (_activeRide != null) {
        await loadBookingsForRide(_activeRide!.id);
      } else {
        _pendingBookings = [];
        _acceptedBookings = [];
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('DriverProvider.loadMyRides - Error: $e');
      _error = e.toString();
      _isLoading = false;
      _activeRide = null;
      notifyListeners();
    }
  }

  Future<void> loadBookingsForRide(int rideId) async {
    try {
      final bookings = await BookingService.getBookingsForRide(rideId);

      // Fetch user details for each booking to get phone number and rating
      final bookingsWithDetails = await Future.wait(
        bookings.map((booking) async {
          try {
            final user = await UserService.getUserById(booking.riderId);
            return Booking(
              id: booking.id,
              rideId: booking.rideId,
              riderId: booking.riderId,
              riderName: booking.riderName,
              seatsBooked: booking.seatsBooked,
              status: booking.status,
              costForThisRider: booking.costForThisRider,
              createdAt: booking.createdAt,
              cancelledAt: booking.cancelledAt,
              pickupLocationLabel: booking.pickupLocationLabel,
              dropoffLocationLabel: booking.dropoffLocationLabel,
              pickupTimeStart: booking.pickupTimeStart,
              pickupTimeEnd: booking.pickupTimeEnd,
              riderPhoneNumber: user.phoneNumber,
              riderRating: user.avgRatingAsRider,
            );
          } catch (e) {
            print(
              'Error fetching user details for rider ${booking.riderId}: $e',
            );
            // Return booking without user details if fetch fails
            return booking;
          }
        }),
      );

      _pendingBookings = bookingsWithDetails
          .where((b) => b.status.toUpperCase() == 'PENDING')
          .toList();
      _acceptedBookings = bookingsWithDetails
          .where((b) => b.status.toUpperCase() == 'CONFIRMED')
          .toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void setRouteId(int? routeId) {
    _routeId = routeId;
    notifyListeners();
  }

  void clearRideForm() {
    _pickupLocation = null;
    _destinationLocation = null;
    _departureTime = null;
    _totalSeats = 4;
    _routeId = null;
    _error = null;
    notifyListeners();
  }
}
