import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapProvider with ChangeNotifier {
  static final MapProvider _instance = MapProvider._internal();
  factory MapProvider() => _instance;
  MapProvider._internal();

  MapController? _mapController;
  LatLng? _lastKnownLocation;
  bool _isLocationReady = false;
  bool _isMapInitialized = false;

  MapController? get mapController => _mapController;
  LatLng? get lastKnownLocation => _lastKnownLocation;
  bool get isLocationReady => _isLocationReady;
  bool get isMapInitialized => _isMapInitialized;

  void initializeMap() {
    if (_mapController == null) {
      _mapController = MapController();
      _isMapInitialized = true;
      notifyListeners();
    }
  }

  Future<void> initializeLocation() async {
    if (_isLocationReady && _lastKnownLocation != null) {
      return; // Already initialized
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _lastKnownLocation = const LatLng(26.0667, 50.5577); // Bahrain default
        _isLocationReady = true;
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _lastKnownLocation = const LatLng(26.0667, 50.5577);
          _isLocationReady = true;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _lastKnownLocation = const LatLng(26.0667, 50.5577);
        _isLocationReady = true;
        notifyListeners();
        return;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        try {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          ).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Location request timed out');
            },
          );
          _lastKnownLocation = LatLng(position.latitude, position.longitude);
          _isLocationReady = true;
          notifyListeners();
        } catch (e) {
          _lastKnownLocation = const LatLng(26.0667, 50.5577);
          _isLocationReady = true;
          notifyListeners();
        }
      }
    } catch (e) {
      _lastKnownLocation = const LatLng(26.0667, 50.5577);
      _isLocationReady = true;
      notifyListeners();
    }
  }

  void updateLocation(LatLng location) {
    _lastKnownLocation = location;
    notifyListeners();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _mapController = null;
    _isMapInitialized = false;
    super.dispose();
  }
}

