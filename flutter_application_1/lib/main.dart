import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swen Map',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Bahrain coordinates (center of the country)
  static const LatLng bahrainCenter = LatLng(26.0667, 50.5577);
  
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _startSearchController = TextEditingController();
  
  LatLng? _currentLocation;
  LatLng? _destinationLocation;
  String? _destinationName;
  LatLng? _startLocation;
  String? _startLocationName;
  bool _isLoading = true;
  bool _isSearching = false;
  bool _isSearchingStart = false;
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _startSearchResults = [];
  bool _isSelectingStart = false; // Track if we're in start location selection mode
  bool _isEditingLocation = false; // Track if we're editing a location
  String? _editingLocationType; // 'start' or 'destination'
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _startSearchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Permission granted, get current location
    if (permission == LocationPermission.whileInUse || 
        permission == LocationPermission.always) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _searchLocation(String query, {bool isStartLocation = false}) async {
    if (query.isEmpty) {
      setState(() {
        if (isStartLocation) {
          _startSearchResults = [];
          _isSearchingStart = false;
        } else {
          _searchResults = [];
          _isSearching = false;
        }
      });
      return;
    }

    setState(() {
      if (isStartLocation) {
        _isSearchingStart = true;
      } else {
        _isSearching = true;
      }
    });

    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$encodedQuery&format=json&limit=5',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'flutter_application_1'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          final results = data.map((item) => {
            'name': item['display_name'] as String,
            'lat': double.parse(item['lat'] as String),
            'lon': double.parse(item['lon'] as String),
          }).toList();
          
          if (isStartLocation) {
            _startSearchResults = results;
            _isSearchingStart = false;
          } else {
            _searchResults = results;
            _isSearching = false;
          }
        });
      } else {
        setState(() {
          if (isStartLocation) {
            _isSearchingStart = false;
          } else {
            _isSearching = false;
          }
        });
      }
    } catch (e) {
      setState(() {
        if (isStartLocation) {
          _isSearchingStart = false;
        } else {
          _isSearching = false;
        }
      });
    }
  }

  void _selectSearchResult(Map<String, dynamic> result, {bool isStartLocation = false}) {
    final location = LatLng(result['lat'], result['lon']);
    setState(() {
      if (isStartLocation || _editingLocationType == 'start') {
        _startLocation = location;
        _startLocationName = result['name'];
        _startSearchController.clear();
        _startSearchResults = [];
        _isSelectingStart = false;
        _isEditingLocation = false;
        _editingLocationType = null;
      } else {
        _destinationLocation = location;
        _destinationName = result['name'];
        _searchController.clear();
        _searchResults = [];
        _isEditingLocation = false;
        _editingLocationType = null;
      }
    });

    // Move map to location
    _mapController.move(location, 15.0);
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      if (_isSelectingStart || _editingLocationType == 'start') {
        _startLocation = point;
        _startLocationName = null;
        _isSelectingStart = false;
        _isEditingLocation = false;
        _editingLocationType = null;
      } else if (_editingLocationType == 'destination') {
        _destinationLocation = point;
        _destinationName = null;
        _isEditingLocation = false;
        _editingLocationType = null;
      } else {
        _destinationLocation = point;
        _destinationName = null;
      }
    });
  }

  void _onGoButtonPressed() {
    setState(() {
      _isSelectingStart = true;
      // Set default start location to current location if available
      if (_startLocation == null && _currentLocation != null) {
        _startLocation = _currentLocation;
        _startLocationName = 'Current Location';
      }
    });
  }

  void _cancelStartSelection() {
    setState(() {
      _isSelectingStart = false;
      _isEditingLocation = false;
      _editingLocationType = null;
      _startSearchController.clear();
      _startSearchResults = [];
    });
  }

  void _startEditingLocation(String locationType) {
    setState(() {
      _isEditingLocation = true;
      _editingLocationType = locationType;
      if (locationType == 'start') {
        _isSelectingStart = true;
      }
    });
  }

  void _cancelEditingLocation() {
    setState(() {
      _isEditingLocation = false;
      _editingLocationType = null;
      _isSelectingStart = false;
      _startSearchController.clear();
      _startSearchResults = [];
      _searchController.clear();
      _searchResults = [];
    });
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? const TimeOfDay(hour: 9, minute: 0),
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
      initialTime: _endTime ?? const TimeOfDay(hour: 17, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Use current location if available, otherwise use Bahrain center
    final centerLocation = _currentLocation ?? bahrainCenter;
    
    // Build markers list
    List<Marker> markers = [];
    
    // Add start location marker (green)
    if (_startLocation != null) {
      markers.add(
        Marker(
          point: _startLocation!,
          width: 80,
          height: 80,
          child: const Icon(
            Icons.location_on,
            color: Colors.green,
            size: 40,
          ),
        ),
      );
    } else if (_currentLocation != null && !_isSelectingStart) {
      // Show current location as blue marker when not selecting start
      markers.add(
        Marker(
          point: _currentLocation!,
          width: 80,
          height: 80,
          child: const Icon(
            Icons.location_on,
            color: Colors.blue,
            size: 40,
          ),
        ),
      );
    } else if (_currentLocation == null && !_isSelectingStart) {
      // Show Bahrain center if no current location
      markers.add(
        Marker(
          point: bahrainCenter,
          width: 80,
          height: 80,
          child: const Icon(
            Icons.location_on,
            color: Colors.grey,
            size: 40,
          ),
        ),
      );
    }
    
    // Add destination marker (red)
    if (_destinationLocation != null) {
      markers.add(
        Marker(
          point: _destinationLocation!,
          width: 80,
          height: 80,
          child: const Icon(
            Icons.place,
            color: Colors.red,
            size: 40,
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: centerLocation,
              initialZoom: _currentLocation != null ? 15.0 : 10.0,
              minZoom: 5.0,
              maxZoom: 18.0,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.flutter_application_1',
              ),
              MarkerLayer(
                markers: markers,
              ),
            ],
          ),
          // Floating bottom panel
          Positioned(
            left: 16,
            right: 16,
            bottom: 32,
            child: _shouldShowBothLocations()
                ? _buildBothLocationsPanel(context)
                : (_isSelectingStart || (_isEditingLocation && _editingLocationType == 'start'))
                    ? _buildStartLocationPanel(context)
                    : _buildDestinationPanel(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationPanel(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.location_searching, color: Colors.deepPurple),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isEditingLocation && _editingLocationType == 'destination'
                        ? 'Edit Destination'
                        : 'Enter Destination',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_isEditingLocation && _editingLocationType == 'destination')
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _cancelEditingLocation,
                  )
                else if (_destinationLocation != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _destinationLocation = null;
                        _destinationName = null;
                        _searchController.clear();
                        _searchResults = [];
                      });
                    },
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Search input
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a location...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchResults = [];
                              });
                            },
                          )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                _searchLocation(value);
              },
              onSubmitted: (value) {
                if (value.isNotEmpty && _searchResults.isNotEmpty) {
                  _selectSearchResult(_searchResults[0]);
                }
              },
            ),
          ),
          // Search results or pin drop instruction
          if (_searchResults.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  return ListTile(
                    leading: const Icon(Icons.place, color: Colors.deepPurple),
                    title: Text(
                      result['name'],
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () => _selectSearchResult(result),
                  );
                },
              ),
            )
          else if (_searchController.text.isEmpty && _destinationLocation == null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Search for a location or tap on the map to drop a pin',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (_destinationLocation != null)
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _destinationName ?? 'Destination pin dropped',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // GO button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onGoButtonPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'GO',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  bool _shouldShowBothLocations() {
    return _startLocation != null && _destinationLocation != null && !_isSelectingStart && !_isEditingLocation;
  }

  Widget _buildBothLocationsPanel(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Start Location
          InkWell(
            onTap: () => _startEditingLocation('start'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.green, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Location',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _startLocationName ?? 'Pin dropped',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit, color: Colors.grey, size: 20),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          // Destination Location
          InkWell(
            onTap: () => _startEditingLocation('destination'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.place, color: Colors.red, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Destination',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _destinationName ?? 'Pin dropped',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit, color: Colors.grey, size: 20),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          // Time Range Selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Time Range',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _selectStartTime,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[50],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.access_time, size: 20, color: Colors.deepPurple),
                              const SizedBox(width: 8),
                              Text(
                                _startTime != null
                                    ? _formatTime(_startTime!)
                                    : 'Start Time',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _startTime != null ? Colors.black87 : Colors.grey[600],
                                  fontWeight: _startTime != null ? FontWeight.w500 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'to',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _selectEndTime,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[50],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.access_time, size: 20, color: Colors.deepPurple),
                              const SizedBox(width: 8),
                              Text(
                                _endTime != null
                                    ? _formatTime(_endTime!)
                                    : 'End Time',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _endTime != null ? Colors.black87 : Colors.grey[600],
                                  fontWeight: _endTime != null ? FontWeight.w500 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildStartLocationPanel(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.my_location, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isEditingLocation ? 'Edit Start Location' : 'Select Start Location',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _isEditingLocation ? _cancelEditingLocation : _cancelStartSelection,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Search input
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _startSearchController,
              decoration: InputDecoration(
                hintText: 'Search for a location...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearchingStart
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : _startSearchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _startSearchController.clear();
                              setState(() {
                                _startSearchResults = [];
                              });
                            },
                          )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                _searchLocation(value, isStartLocation: true);
              },
              onSubmitted: (value) {
                if (value.isNotEmpty && _startSearchResults.isNotEmpty) {
                  _selectSearchResult(_startSearchResults[0], isStartLocation: true);
                }
              },
            ),
          ),
          // Current location button or search results
          if (_startSearchResults.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _startSearchResults.length,
                itemBuilder: (context, index) {
                  final result = _startSearchResults[index];
                  return ListTile(
                    leading: const Icon(Icons.place, color: Colors.green),
                    title: Text(
                      result['name'],
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () => _selectSearchResult(result, isStartLocation: true),
                  );
                },
              ),
            )
          else if (_startSearchController.text.isEmpty)
            Column(
              children: [
                // Current location option
                if (_currentLocation != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _startLocation = _currentLocation;
                          _startLocationName = 'Current Location';
                          _isSelectingStart = false;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.green.withOpacity(0.1),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.my_location, color: Colors.green),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Use Current Location',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (_startLocation == _currentLocation)
                              const Icon(Icons.check_circle, color: Colors.green),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Instruction
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Search for a location or tap on the map to drop a pin',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else if (_startLocation != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _startLocationName ?? 'Start location pin dropped',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
