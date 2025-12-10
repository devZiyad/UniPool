import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../providers/driver_provider.dart';
import '../../providers/ride_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/location_service.dart';
import '../../services/ride_service.dart';
import '../../services/vehicle_service.dart';
import '../../models/location.dart';
import '../../models/vehicle.dart';
import '../../widgets/map_widget.dart';
import '../../widgets/app_drawer.dart';
import '../../utils/polyline_decoder.dart';
import '../../theme/app_theme.dart';

enum SearchStep { destination, startLocation, timeFilters }

class RiderUnifiedSearchScreen extends StatefulWidget {
  final bool showInTabBar;
  
  const RiderUnifiedSearchScreen({
    super.key,
    this.showInTabBar = false,
  });

  @override
  State<RiderUnifiedSearchScreen> createState() =>
      _RiderUnifiedSearchScreenState();
}

class _RiderUnifiedSearchScreenState extends State<RiderUnifiedSearchScreen> {
  SearchStep _currentStep = SearchStep.destination;
  MapController? _mapController;
  LatLng _currentLocation = const LatLng(26.0667, 50.5577);
  LatLng? _userLocation; // User's actual GPS location
  LatLng? _selectedDestinationLocation;
  LatLng? _selectedStartLocation;
  bool _isInitializing = true;
  bool _hasUserLocation = false;
  List<LatLng>? _routePoints;
  int? _routeId;

  // Destination search
  final TextEditingController _destinationSearchController =
      TextEditingController();
  List<Location> _destinationSuggestions = [];

  // Start location search
  final TextEditingController _startSearchController = TextEditingController();
  List<Location> _startSuggestions = [];

  // Time filters
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  int _totalSeats = 1;
  bool _isPosting = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDateTime = DateTime(now.year, now.month, now.day, 7, 0);
    _endDateTime = DateTime(now.year, now.month, now.day, 9, 0);
    // Determine initial step based on route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = ModalRoute.of(context);
      if (route != null) {
        final routeName = route.settings.name;
        if (routeName == '/rider/start-location' ||
            routeName == '/driver/post-ride/start-location') {
          setState(() {
            _currentStep = SearchStep.startLocation;
          });
          _initializeStartLocation();
        } else if (routeName == '/rider/time-filters' ||
            routeName == '/driver/post-ride/route-time') {
          setState(() {
            _currentStep = SearchStep.timeFilters;
          });
        } else if (routeName == '/rider/destination-search' ||
            routeName == '/driver/post-ride/destination-search') {
          // Fetch location when navigating to destination step
          setState(() {
            _currentStep = SearchStep.destination;
          });
          _getCurrentLocation();
        }
      }
    });
    _getCurrentLocation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch location every time the page becomes visible (e.g., when navigating back)
    if (_currentStep == SearchStep.destination) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isInitializing = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isInitializing = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isInitializing = false;
        });
        return;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(const Duration(seconds: 10));

        final currentLatLng = LatLng(position.latitude, position.longitude);

        setState(() {
          _currentLocation = currentLatLng;
          _userLocation = currentLatLng; // Store user's GPS location
          _hasUserLocation = true;
          _isInitializing = false;
        });

        _mapController?.move(currentLatLng, 14);
      } else {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  void dispose() {
    _destinationSearchController.dispose();
    _startSearchController.dispose();
    super.dispose();
  }

  // Destination search methods
  Future<void> _searchDestinations(String query) async {
    if (query.isEmpty) {
      setState(() {
        _destinationSuggestions = [];
      });
      return;
    }

    try {
      print('_searchDestinations: Searching for "$query"');
      final locations = await LocationService.searchLocations(
        query,
        latitude: _currentLocation.latitude,
        longitude: _currentLocation.longitude,
      );
      print('_searchDestinations: Got ${locations.length} locations');
      if (mounted) {
        setState(() {
          _destinationSuggestions = locations;
          print(
            '_searchDestinations: Updated state with ${_destinationSuggestions.length} suggestions',
          );
        });
      }
    } catch (e, stackTrace) {
      print('_searchDestinations: Error: $e');
      print('_searchDestinations: Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _destinationSuggestions = [];
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error searching: $e')));
      }
    }
  }

  Future<void> _onDestinationMapTap(LatLng point) async {
    setState(() {
      _selectedDestinationLocation = point;
    });

    // Get address using reverse geocoding
    String address =
        '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}';
    try {
      address = await LocationService.reverseGeocode(
        point.latitude,
        point.longitude,
      );
    } catch (e) {
      // Keep default coordinates if reverse geocoding fails
    }

    final location = Location(
      id: null,
      label: address, // Use address as label instead of "Selected Location"
      address: address,
      latitude: point.latitude,
      longitude: point.longitude,
      userId: null,
      isFavorite: false,
    );

    setState(() {
      _destinationSearchController.text = address;
      _destinationSuggestions = [location];
    });
    _fetchRouteIfReady();
  }

  void _selectDestination(Location location) {
    Provider.of<RideProvider>(
      context,
      listen: false,
    ).setDestinationLocation(location);
    Provider.of<DriverProvider>(
      context,
      listen: false,
    ).setDestinationLocation(location);
    setState(() {
      _currentStep = SearchStep.startLocation;
      // Don't auto-set start location - let user choose
      _selectedStartLocation = null;
      _routePoints = null; // Clear route when destination changes
      // Pin the selected destination on the map
      _selectedDestinationLocation = LatLng(
        location.latitude,
        location.longitude,
      );
    });
    _initializeStartLocation();
    _fetchRouteIfReady();
  }

  // Start location search methods
  Future<void> _searchStartLocations(String query) async {
    if (query.isEmpty) {
      setState(() {
        _startSuggestions = [];
      });
      return;
    }

    try {
      print('_searchStartLocations: Searching for "$query"');
      final locations = await LocationService.searchLocations(
        query,
        latitude: _currentLocation.latitude,
        longitude: _currentLocation.longitude,
      );
      print('_searchStartLocations: Got ${locations.length} locations');
      if (mounted) {
        setState(() {
          _startSuggestions = locations;
          print(
            '_searchStartLocations: Updated state with ${_startSuggestions.length} suggestions',
          );
        });
      }
    } catch (e, stackTrace) {
      print('_searchStartLocations: Error: $e');
      print('_searchStartLocations: Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _startSuggestions = [];
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error searching: $e')));
      }
    }
  }

  Future<void> _onStartMapTap(LatLng point) async {
    setState(() {
      _selectedStartLocation = point;
    });

    // Get address using reverse geocoding
    String address =
        '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}';
    try {
      address = await LocationService.reverseGeocode(
        point.latitude,
        point.longitude,
      );
    } catch (e) {
      // Keep default coordinates if reverse geocoding fails
    }

    final location = Location(
      id: null,
      label: address, // Use address as label instead of "Selected Location"
      address: address,
      latitude: point.latitude,
      longitude: point.longitude,
      userId: null,
      isFavorite: false,
    );

    setState(() {
      _startSearchController.text = address;
      _startSuggestions = [location];
    });
    _fetchRouteIfReady();
  }

  void _initializeStartLocation() {
    // Set current location as default pickup location
    // Only create location suggestion if user location is available
    if (_userLocation != null) {
      final location = Location(
        id: null,
        label: 'Current Location',
        address:
            '${_userLocation!.latitude.toStringAsFixed(6)}, ${_userLocation!.longitude.toStringAsFixed(6)}',
        latitude: _userLocation!.latitude,
        longitude: _userLocation!.longitude,
        userId: null,
        isFavorite: false,
      );

      // Set as default pickup location in providers
      Provider.of<RideProvider>(
        context,
        listen: false,
      ).setPickupLocation(location);
      Provider.of<DriverProvider>(
        context,
        listen: false,
      ).setPickupLocation(location);

      setState(() {
        if (_selectedStartLocation == null) {
          _startSearchController.text =
              '${_userLocation!.latitude.toStringAsFixed(6)}, ${_userLocation!.longitude.toStringAsFixed(6)}';
        }
        // Only add to suggestions if not already there
        if (_startSuggestions.isEmpty ||
            _startSuggestions.first.label != 'Current Location') {
          _startSuggestions = [location];
        }
      });
    }
  }

  void _selectStartLocation(Location location) {
    Provider.of<RideProvider>(
      context,
      listen: false,
    ).setPickupLocation(location);
    Provider.of<DriverProvider>(
      context,
      listen: false,
    ).setPickupLocation(location);

    // Only set _selectedStartLocation if it's a manually pinned location
    // (not the current location)
    if (location.label != 'Current Location' ||
        _userLocation == null ||
        location.latitude != _userLocation!.latitude ||
        location.longitude != _userLocation!.longitude) {
      setState(() {
        _selectedStartLocation = LatLng(location.latitude, location.longitude);
      });
    } else {
      // Using current location - don't show blue pin
      setState(() {
        _selectedStartLocation = null;
      });
    }

    setState(() {
      _currentStep = SearchStep.timeFilters;
    });
    _fetchRouteIfReady();
  }

  Future<void> _fetchRouteIfReady() async {
    // Get locations from providers
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);

    final pickup = _isDriver
        ? driverProvider.pickupLocation
        : rideProvider.pickupLocation;
    final destination = _isDriver
        ? driverProvider.destinationLocation
        : rideProvider.destinationLocation;

    // Only fetch route if both locations are available
    if (pickup != null && destination != null) {
      try {
        final routeData = await LocationService.getRoute(
          pickup.latitude,
          pickup.longitude,
          destination.latitude,
          destination.longitude,
        );

        if (routeData != null) {
          final routeId = routeData['routeId'];
          List<LatLng>? decodedPoints;

          // Check if we have encoded polyline string
          if (routeData['routePolyline'] != null) {
            final polyline = routeData['routePolyline'] as String;
            decodedPoints = decodePolyline(polyline);
          }
          // Check if we have GeoJSON coordinates
          else if (routeData['coordinates'] != null) {
            final coords = routeData['coordinates'] as List<List<double>>;
            decodedPoints = coords.map((coord) {
              // GeoJSON format is [longitude, latitude]
              return LatLng(coord[1], coord[0]);
            }).toList();
          }

          final routeIdInt = routeId is int
              ? routeId
              : (routeId != null ? int.tryParse(routeId.toString()) : null);

          // Store routeId in providers
          if (_isDriver) {
            Provider.of<DriverProvider>(
              context,
              listen: false,
            ).setRouteId(routeIdInt);
          }

          if (decodedPoints != null && decodedPoints.isNotEmpty) {
            setState(() {
              _routePoints = decodedPoints;
              _routeId = routeIdInt;
            });
          } else {
            setState(() {
              _routePoints = null;
              _routeId = routeIdInt;
            });
          }
        } else {
          if (_isDriver) {
            Provider.of<DriverProvider>(
              context,
              listen: false,
            ).setRouteId(null);
          }
          setState(() {
            _routePoints = null;
            _routeId = null;
          });
        }
      } catch (e) {
        print('Error fetching route: $e');
        if (_isDriver) {
          Provider.of<DriverProvider>(context, listen: false).setRouteId(null);
        }
        setState(() {
          _routePoints = null;
          _routeId = null;
        });
      }
    } else {
      if (_isDriver) {
        Provider.of<DriverProvider>(context, listen: false).setRouteId(null);
      }
      setState(() {
        _routePoints = null;
        _routeId = null;
      });
    }
  }

  // Time filter methods
  bool get _isDriver {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final role = authProvider.user?.role ?? '';
    return role == 'DRIVER' || role == 'BOTH';
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
    if (_startDateTime == null || _endDateTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select date and time range')));
      return;
    }

    final now = DateTime.now();
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

      var pickupLocation = driverProvider.pickupLocation!;
      if (pickupLocation.id == null) {
        try {
          pickupLocation = await LocationService.createLocation(
            label: pickupLocation.label,
            address: pickupLocation.address,
            latitude: pickupLocation.latitude,
            longitude: pickupLocation.longitude,
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error creating pickup location: ${e.toString()}',
                ),
                duration: const Duration(seconds: 5),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() {
            _isPosting = false;
          });
          return;
        }
      }

      var destinationLocation = driverProvider.destinationLocation!;
      if (destinationLocation.id == null) {
        try {
          destinationLocation = await LocationService.createLocation(
            label: destinationLocation.label,
            address: destinationLocation.address,
            latitude: destinationLocation.latitude,
            longitude: destinationLocation.longitude,
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error creating destination location: ${e.toString()}',
                ),
                duration: const Duration(seconds: 5),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() {
            _isPosting = false;
          });
          return;
        }
      }

      if (pickupLocation.id == null || destinationLocation.id == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Location IDs are missing. Please try selecting locations again.',
              ),
              duration: Duration(seconds: 5),
            ),
          );
        }
        setState(() {
          _isPosting = false;
        });
        return;
      }

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
        routeId: _routeId,
      );

      if (mounted) {
        Navigator.pushNamed(context, '/driver/ride-posted-confirmation');
      }
    } catch (e) {
      print('Error creating ride: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
      setState(() {
        _isPosting = false;
      });
    }
  }

  Future<void> _searchRides() async {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    if (_startDateTime == null || _endDateTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select date and time range')));
      return;
    }

    final startDateTime = _startDateTime!;
    final endDateTime = _endDateTime!;

    rideProvider.setDepartureTimeRange(startDateTime, endDateTime);
    rideProvider.setSeatsNeeded(_totalSeats);

    setState(() {
      _isSearching = true;
    });

    try {
      await rideProvider.searchRides();
      if (mounted) {
        Navigator.pushNamed(context, '/rider/ride-list');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  List<Marker> _getMarkers() {
    List<Marker> markers = [];

    // Show user's current location with arrow icon (persist across steps)
    if (_hasUserLocation && _userLocation != null) {
      markers.add(
        Marker(
          point: _userLocation!,
          width: 50,
          height: 50,
          child: Transform.rotate(
            angle: 0.785398, // 45 degrees in radians (pointing down-right)
            child: const Icon(Icons.navigation, color: Colors.green, size: 50),
          ),
        ),
      );
    }

    // Show destination marker with pin icon if user pinned a location
    if (_selectedDestinationLocation != null) {
      markers.add(
        Marker(
          point: _selectedDestinationLocation!,
          width: 50,
          height: 50,
          child: const Icon(Icons.place, color: Colors.red, size: 50),
        ),
      );
    }

    // Show start location marker with pin icon only if user pinned a location
    // (not if it's just the user's current location)
    // Keep pin visible during time filters and seat selection screen
    if (_selectedStartLocation != null &&
        (_currentStep == SearchStep.startLocation ||
            _currentStep == SearchStep.timeFilters) &&
        (_userLocation == null ||
            _selectedStartLocation!.latitude != _userLocation!.latitude ||
            _selectedStartLocation!.longitude != _userLocation!.longitude)) {
      markers.add(
        Marker(
          point: _selectedStartLocation!,
          width: 50,
          height: 50,
          child: const Icon(Icons.place, color: Colors.blue, size: 50),
        ),
      );
    }

    return markers;
  }

  Widget? _getCenterPin() {
    // Only show center pin if no location is pinned for the current step
    if (_currentStep == SearchStep.destination &&
        _selectedDestinationLocation == null) {
      return null; // Hide center pin until location is pinned
    }
    if (_currentStep == SearchStep.startLocation &&
        _selectedStartLocation == null) {
      return null; // Hide center pin until location is pinned
    }
    return null;
  }

  String _getAppBarTitle() {
    switch (_currentStep) {
      case SearchStep.destination:
        return 'Select Destination';
      case SearchStep.startLocation:
        return 'Select Start Location';
      case SearchStep.timeFilters:
        return _isDriver ? 'Post Ride' : 'Search Rides';
    }
  }

  void _onMapTap(LatLng point) {
    switch (_currentStep) {
      case SearchStep.destination:
        _onDestinationMapTap(point);
        break;
      case SearchStep.startLocation:
        _onStartMapTap(point);
        break;
      case SearchStep.timeFilters:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        leading: _currentStep != SearchStep.destination
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    if (_currentStep == SearchStep.timeFilters) {
                      _currentStep = SearchStep.startLocation;
                    } else if (_currentStep == SearchStep.startLocation) {
                      _currentStep = SearchStep.destination;
                      // Fetch location when navigating to destination step
                      _getCurrentLocation();
                    }
                  });
                },
              )
            : null,
      ),
      drawer: widget.showInTabBar ? null : const AppDrawer(),
      body: Stack(
        children: [
          MapWidget(
            initialPosition: _currentLocation,
            zoom: 14,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            myLocationEnabled: true,
            onTap: _onMapTap,
            markers: _getMarkers(),
            polylines:
                (_currentStep == SearchStep.timeFilters &&
                    _routePoints != null &&
                    _routePoints!.isNotEmpty)
                ? [
                    Polyline(
                      points: _routePoints!,
                      color: Colors.blue,
                      strokeWidth: 4,
                    ),
                  ]
                : null,
          ),
          if (_getCenterPin() != null) _getCenterPin()!,
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(child: _buildBottomPanel()),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    switch (_currentStep) {
      case SearchStep.destination:
        return _buildDestinationPanel();
      case SearchStep.startLocation:
        return _buildStartLocationPanel();
      case SearchStep.timeFilters:
        return _buildTimeFiltersPanel();
    }
  }

  Widget _buildDestinationPanel() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Where are you going today?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap on the map or search to select destination',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _destinationSearchController,
              decoration: InputDecoration(
                hintText: 'Search destinations',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _searchDestinations,
            ),
            if (_destinationSuggestions.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _destinationSuggestions.length,
                  itemBuilder: (context, index) {
                    final location = _destinationSuggestions[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.location_on,
                        color: Colors.grey,
                      ),
                      title: Text(location.label),
                      subtitle: Text(location.address ?? ''),
                      onTap: () => _selectDestination(location),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStartLocationPanel() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Where are you going from today?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap on the map or search to change location',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _startSearchController,
              decoration: InputDecoration(
                hintText: 'Search start location',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _searchStartLocations,
            ),
            if (_startSuggestions.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _startSuggestions.length,
                  itemBuilder: (context, index) {
                    final location = _startSuggestions[index];
                    final isCurrentLocation =
                        location.label == 'Current Location';
                    return ListTile(
                      leading: isCurrentLocation
                          ? Transform.rotate(
                              angle: 0.785398, // 45 degrees in radians
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.navigation,
                                  color: Colors.green,
                                  size: 24,
                                ),
                              ),
                            )
                          : const Icon(Icons.location_on, color: Colors.grey),
                      title: Text(location.label),
                      subtitle: Text(location.address ?? ''),
                      onTap: () => _selectStartLocation(location),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _userLocation != null
                  ? () {
                      // Use current location
                      if (_userLocation != null) {
                        final location = Location(
                          id: null,
                          label: 'Current Location',
                          address:
                              '${_userLocation!.latitude.toStringAsFixed(6)}, ${_userLocation!.longitude.toStringAsFixed(6)}',
                          latitude: _userLocation!.latitude,
                          longitude: _userLocation!.longitude,
                          userId: null,
                          isFavorite: false,
                        );
                        _selectStartLocation(location);
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.rotate(
                    angle: 0.785398, // 45 degrees in radians
                    child: const Icon(
                      Icons.navigation,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Use Current Location',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFiltersPanel() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isDriver ? 'Post Your Ride' : 'Search for Rides',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
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
                                  color: Colors.grey,
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
                                  color: Colors.grey,
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
            const SizedBox(height: 24),
            // Seats selector
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_isDriver ? 'Available Seats' : 'Seats Needed'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle),
                      onPressed: _totalSeats > 1
                          ? () {
                              setState(() {
                                _totalSeats--;
                              });
                            }
                          : null,
                    ),
                    Text('$_totalSeats', style: const TextStyle(fontSize: 24)),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
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
            const SizedBox(height: 32),
            // Action button
            ElevatedButton(
              onPressed: (_isDriver ? _isPosting : _isSearching)
                  ? null
                  : (_isDriver ? _postRide : _searchRides),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkNavy,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: (_isDriver ? _isPosting : _isSearching)
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                      ),
                    )
                  : Text(_isDriver ? 'Post Ride' : 'Search Rides'),
            ),
          ],
        ),
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
                  backgroundColor: AppTheme.darkNavy,
                  foregroundColor: AppTheme.white,
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
