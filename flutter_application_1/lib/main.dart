import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'services/auth_service.dart';
import 'services/location_service.dart';
import 'services/ride_service.dart';
import 'services/vehicle_service.dart';
import 'services/booking_service.dart';
import 'models/location.dart' as LocationModel;
import 'models/booking.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniPool',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

// User account model
class UserAccount {
  String email;
  String password;
  String? universityIdImage;
  String? drivingLicenseImage;
  String? cprCardImage;
  String verificationStatus; // 'pending', 'approved', 'rejected'
  bool isVerified;
  bool canPostRides;
  bool canRequestRides;

  UserAccount({
    required this.email,
    required this.password,
    this.universityIdImage,
    this.drivingLicenseImage,
    this.cprCardImage,
    this.verificationStatus = 'pending',
    this.isVerified = false,
    this.canPostRides = false,
    this.canRequestRides = false,
  });
}

// Note: DummyBackendService removed - using real API services now

// Login Screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _universityIdController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _universityIdController.dispose();
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isSignUp) {
        // Sign up
        await AuthService.register(
          universityId: _universityIdController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
          phoneNumber: _phoneNumberController.text.trim().isEmpty
              ? null
              : _phoneNumberController.text.trim(),
          role: 'RIDER', // Default role, can be changed later
        );

        if (mounted) {
          // Navigate to home page after successful registration
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } else {
        // Login
        await AuthService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (mounted) {
          // Navigate to home page after successful login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('ApiException: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _skipLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const UserTypeSelectionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Skip Login button (top right)
              Positioned(
                top: 16,
                right: 16,
                child: TextButton(
                  onPressed: _skipLogin,
                  child: const Text(
                    'Skip Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              // Main content
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // UniPool Splash
                        const Text(
                          'UniPool',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isSignUp ? 'Create your account' : 'Welcome back',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 48),
                        // Email field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        // University ID field (only for sign up)
                        if (_isSignUp) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _universityIdController,
                            decoration: InputDecoration(
                              labelText: 'University ID',
                              prefixIcon: const Icon(Icons.badge),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: _isSignUp
                                ? (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your university ID';
                                    }
                                    return null;
                                  }
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _fullNameController,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: const Icon(Icons.person),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: _isSignUp
                                ? (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your full name';
                                    }
                                    return null;
                                  }
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneNumberController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Phone Number (Optional)',
                              prefixIcon: const Icon(Icons.phone),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.deepPurple,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    _isSignUp ? 'Sign Up' : 'Log In',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Toggle sign up/login
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                            });
                          },
                          child: Text(
                            _isSignUp
                                ? 'Already have an account? Log In'
                                : 'Don\'t have an account? Sign Up',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
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

// User Information Page
class UserInformationPage extends StatefulWidget {
  final String email;

  const UserInformationPage({super.key, required this.email});

  @override
  State<UserInformationPage> createState() => _UserInformationPageState();
}

class _UserInformationPageState extends State<UserInformationPage> {
  File? _universityIdImage;
  File? _drivingLicenseImage;
  File? _cprCardImage;
  bool _isSubmitting = false;

  Future<void> _pickImage(String type) async {
    try {
      // Check if image picker is available
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          if (type == 'university') {
            _universityIdImage = File(image.path);
          } else if (type == 'driving') {
            _drivingLicenseImage = File(image.path);
          } else if (type == 'cpr') {
            _cprCardImage = File(image.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error picking image';
        if (e.toString().contains('MissingPluginException')) {
          errorMessage =
              'Image picker not available. Please rebuild the app after adding the plugin.\n\nFor development: You can use dummy images by tapping the upload area again.';
        } else {
          errorMessage = 'Error: $e';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );

        // For development: Allow using dummy file paths if plugin fails
        if (e.toString().contains('MissingPluginException')) {
          // Create a dummy file path for development
          final dummyPath = '/dummy/${type}_image.jpg';
          setState(() {
            if (type == 'university') {
              _universityIdImage = File(dummyPath);
            } else if (type == 'driving') {
              _drivingLicenseImage = File(dummyPath);
            } else if (type == 'cpr') {
              _cprCardImage = File(dummyPath);
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Using dummy image for development. Rebuild app to enable real image picker.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _submitDocuments() async {
    if (_universityIdImage == null ||
        _drivingLicenseImage == null ||
        _cprCardImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload all required documents'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Note: Document upload functionality would need to be implemented
      // For now, just navigate to home page
      // In a real app, you'd upload images to the backend
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        // Navigate to home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildImageUploadCard({
    required String title,
    required String description,
    required File? image,
    required String type,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _pickImage(type),
              child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: image != null ? Colors.green : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(image, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to upload',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            if (image != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Uploaded',
                      style: TextStyle(color: Colors.green[700], fontSize: 12),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Documents'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please upload the following documents for verification:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            _buildImageUploadCard(
              title: '1. University ID',
              description:
                  'Upload a clear photo of your university identification card',
              image: _universityIdImage,
              type: 'university',
            ),
            _buildImageUploadCard(
              title: '2. Driving License',
              description: 'Upload a clear photo of your driving license',
              image: _drivingLicenseImage,
              type: 'driving',
            ),
            _buildImageUploadCard(
              title: '3. CPR Card',
              description: 'Upload a clear photo of your CPR card',
              image: _cprCardImage,
              type: 'cpr',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitDocuments,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Submit for Verification',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// User Type Selection Page (Driver/Rider)
class UserTypeSelectionPage extends StatelessWidget {
  const UserTypeSelectionPage({super.key});

  void _selectUserType(BuildContext context, String userType) {
    if (userType == 'driver') {
      // Navigate to HomePage (map page for drivers)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (userType == 'rider') {
      // Navigate to rider page (placeholder for now)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RiderHomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // UniPool Logo/Title
                  const Text(
                    'UniPool',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 48),
                  const Text(
                    'Select Your Role',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Driver Option
                  InkWell(
                    onTap: () => _selectUserType(context, 'driver'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
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
                        children: [
                          Icon(
                            Icons.drive_eta,
                            size: 64,
                            color: Colors.deepPurple[700],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Driver',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Offer rides and share your journey',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Rider Option
                  InkWell(
                    onTap: () => _selectUserType(context, 'rider'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
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
                        children: [
                          Icon(
                            Icons.person,
                            size: 64,
                            color: Colors.deepPurple[700],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Rider',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Find and request rides',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Rider Home Page (Placeholder)
class RiderHomePage extends StatelessWidget {
  const RiderHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Home'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 80, color: Colors.deepPurple),
            SizedBox(height: 24),
            Text(
              'Rider Home Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'This page will be developed for riders',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// Verification Pending Page
class VerificationPendingPage extends StatefulWidget {
  final String email;

  const VerificationPendingPage({super.key, required this.email});

  @override
  State<VerificationPendingPage> createState() =>
      _VerificationPendingPageState();
}

class _VerificationPendingPageState extends State<VerificationPendingPage> {
  @override
  Widget build(BuildContext context) {
    final status = 'pending'; // Would fetch from API in real app

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Status'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pending_actions, size: 80, color: Colors.orange[400]),
              const SizedBox(height: 24),
              Text(
                'Verification Pending',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your documents have been submitted and are under review.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Status: ${status.toUpperCase()}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[700],
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue to App',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
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
  bool _isSelectingStart =
      false; // Track if we're in start location selection mode
  bool _isEditingLocation = false; // Track if we're editing a location
  String? _editingLocationType; // 'start' or 'destination'
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  int? _numberOfSeats;

  @override
  void initState() {
    super.initState();
    // Add a safety timeout to prevent infinite loading
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    });
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
    try {
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
          Position position =
              await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high,
              ).timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  throw TimeoutException('Location request timed out');
                },
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
      } else {
        // Permission granted but not the expected type, still proceed
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // Catch any unexpected errors
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchLocation(
    String query, {
    bool isStartLocation = false,
  }) async {
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
          final results = data
              .map(
                (item) => {
                  'name': item['display_name'] as String,
                  'lat': double.parse(item['lat'] as String),
                  'lon': double.parse(item['lon'] as String),
                },
              )
              .toList();

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

  void _selectSearchResult(
    Map<String, dynamic> result, {
    bool isStartLocation = false,
  }) {
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
          child: const Icon(Icons.location_on, color: Colors.green, size: 40),
        ),
      );
    } else if (_currentLocation != null && !_isSelectingStart) {
      // Show current location as blue marker when not selecting start
      markers.add(
        Marker(
          point: _currentLocation!,
          width: 80,
          height: 80,
          child: const Icon(Icons.location_on, color: Colors.blue, size: 40),
        ),
      );
    } else if (_currentLocation == null && !_isSelectingStart) {
      // Show Bahrain center if no current location
      markers.add(
        Marker(
          point: bahrainCenter,
          width: 80,
          height: 80,
          child: const Icon(Icons.location_on, color: Colors.grey, size: 40),
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
          child: const Icon(Icons.place, color: Colors.red, size: 40),
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
              MarkerLayer(markers: markers),
            ],
          ),
          // Floating bottom panel
          Positioned(
            left: 16,
            right: 16,
            bottom: 32,
            child: _shouldShowBothLocations()
                ? _buildBothLocationsPanel(context)
                : (_isSelectingStart ||
                      (_isEditingLocation && _editingLocationType == 'start'))
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
          else if (_searchController.text.isEmpty &&
              _destinationLocation == null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Search for a location or tap on the map to drop a pin',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
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
    return _startLocation != null &&
        _destinationLocation != null &&
        !_isSelectingStart &&
        !_isEditingLocation;
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
                              const Icon(
                                Icons.access_time,
                                size: 20,
                                color: Colors.deepPurple,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _startTime != null
                                    ? _formatTime(_startTime!)
                                    : 'Start Time',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _startTime != null
                                      ? Colors.black87
                                      : Colors.grey[600],
                                  fontWeight: _startTime != null
                                      ? FontWeight.w500
                                      : FontWeight.normal,
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
                      style: TextStyle(fontSize: 14, color: Colors.grey),
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
                              const Icon(
                                Icons.access_time,
                                size: 20,
                                color: Colors.deepPurple,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _endTime != null
                                    ? _formatTime(_endTime!)
                                    : 'End Time',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _endTime != null
                                      ? Colors.black87
                                      : Colors.grey[600],
                                  fontWeight: _endTime != null
                                      ? FontWeight.w500
                                      : FontWeight.normal,
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
          // Seat Selector
          if (_startTime != null && _endTime != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Number of Seats',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(4, (index) {
                      final seatCount = index + 1;
                      final isSelected = _numberOfSeats == seatCount;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _numberOfSeats = seatCount;
                          });
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.deepPurple
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.deepPurple
                                  : Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$seatCount',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            // GO Button
            if (_numberOfSeats != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canPostRide() ? () => _postRide(context) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
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
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool _canPostRide() {
    return _startLocation != null &&
        _destinationLocation != null &&
        _startTime != null &&
        _endTime != null &&
        _numberOfSeats != null;
  }

  Future<void> _postRide(BuildContext context) async {
    if (!_canPostRide()) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // First, get or create vehicle (for now, we'll need at least one vehicle)
      // In a real app, you'd have a vehicle selection/creation flow
      final vehicles = await VehicleService.getMyVehicles();
      if (vehicles.isEmpty) {
        if (mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please register a vehicle first'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      final vehicle = vehicles.first;

      // Create or get locations
      LocationModel.Location? pickupLocation;
      LocationModel.Location? destinationLocation;

      // Try to find existing locations or create new ones
      try {
        final myLocations = await LocationService.getMyLocations();
        
        // Try to find matching pickup location
        for (var loc in myLocations) {
          final distance = _calculateDistance(
            loc.latitude,
            loc.longitude,
            _startLocation!.latitude,
            _startLocation!.longitude,
          );
          if (distance < 0.1) { // Within 100m
            pickupLocation = loc;
            break;
          }
        }

        // Try to find matching destination location
        for (var loc in myLocations) {
          final distance = _calculateDistance(
            loc.latitude,
            loc.longitude,
            _destinationLocation!.latitude,
            _destinationLocation!.longitude,
          );
          if (distance < 0.1) { // Within 100m
            destinationLocation = loc;
            break;
          }
        }
      } catch (e) {
        // Locations service might fail, continue anyway
      }

      // Create locations if not found
      if (pickupLocation == null) {
        try {
          final address = await LocationService.reverseGeocode(
            latitude: _startLocation!.latitude,
            longitude: _startLocation!.longitude,
          );
          pickupLocation = await LocationService.createLocation(
            label: _startLocationName ?? address,
            address: address,
            latitude: _startLocation!.latitude,
            longitude: _startLocation!.longitude,
          );
        } catch (e) {
          // If reverse geocode fails, create with coordinates
          pickupLocation = await LocationService.createLocation(
            label: _startLocationName ?? 'Start Location',
            latitude: _startLocation!.latitude,
            longitude: _startLocation!.longitude,
          );
        }
      }

      if (destinationLocation == null) {
        try {
          final address = await LocationService.reverseGeocode(
            latitude: _destinationLocation!.latitude,
            longitude: _destinationLocation!.longitude,
          );
          destinationLocation = await LocationService.createLocation(
            label: _destinationName ?? address,
            address: address,
            latitude: _destinationLocation!.latitude,
            longitude: _destinationLocation!.longitude,
          );
        } catch (e) {
          // If reverse geocode fails, create with coordinates
          destinationLocation = await LocationService.createLocation(
            label: _destinationName ?? 'Destination',
            latitude: _destinationLocation!.latitude,
            longitude: _destinationLocation!.longitude,
          );
        }
      }

      // Create departure datetime (combine today's date with selected time)
      final now = DateTime.now();
      final departureDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        _startTime!.hour,
        _startTime!.minute,
      );

      // Create the ride
      final ride = await RideService.createRide(
        vehicleId: vehicle.id,
        pickupLocationId: pickupLocation.id,
        destinationLocationId: destinationLocation.id,
        departureTime: departureDateTime,
        totalSeats: _numberOfSeats!,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ride successfully posted'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to ride details page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RideDetailsPage(
              rideId: ride.id,
              startLocation: _startLocation!,
              startLocationName: _startLocationName ?? pickupLocation?.label ?? 'Start Location',
              destinationLocation: _destinationLocation!,
              destinationName: _destinationName ?? destinationLocation?.label ?? 'Destination',
              startTime: _startTime!,
              endTime: _endTime!,
              numberOfSeats: _numberOfSeats!,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post ride: ${e.toString().replaceAll('ApiException: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
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
                    _isEditingLocation
                        ? 'Edit Start Location'
                        : 'Select Start Location',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _isEditingLocation
                      ? _cancelEditingLocation
                      : _cancelStartSelection,
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
                  _selectSearchResult(
                    _startSearchResults[0],
                    isStartLocation: true,
                  );
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
                    onTap: () =>
                        _selectSearchResult(result, isStartLocation: true),
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
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
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
                      const Icon(
                        Icons.info_outline,
                        color: Colors.grey,
                        size: 20,
                      ),
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

class RideDetailsPage extends StatefulWidget {
  final int? rideId;
  final LatLng startLocation;
  final String startLocationName;
  final LatLng destinationLocation;
  final String destinationName;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int numberOfSeats;

  const RideDetailsPage({
    super.key,
    this.rideId,
    required this.startLocation,
    required this.startLocationName,
    required this.destinationLocation,
    required this.destinationName,
    required this.startTime,
    required this.endTime,
    required this.numberOfSeats,
  });

  @override
  State<RideDetailsPage> createState() => _RideDetailsPageState();
}

class _RideDetailsPageState extends State<RideDetailsPage> {
  List<Booking> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.rideId != null) {
      _loadBookings();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadBookings() async {
    if (widget.rideId == null) return;

    try {
      final bookings = await BookingService.getRideBookings(widget.rideId!);
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load bookings: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Details'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Top section with location, time, and seats
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side: Start, Destination, Time Range
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Start Location
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Start',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    widget.startLocationName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Destination
                        Row(
                          children: [
                            const Icon(
                              Icons.place,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
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
                                  Text(
                                    widget.destinationName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Time Range
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.deepPurple,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Time Range',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    '${_formatTime(widget.startTime)} - ${_formatTime(widget.endTime)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Right side: Available Seats
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.deepPurple),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Available Seats',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.numberOfSeats}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Requests section
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: _bookings.isEmpty
                        ? Center(
                            child: Text(
                              'No New Requests',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[400],
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _bookings.length,
                            itemBuilder: (context, index) {
                              final booking = _bookings[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  leading: const Icon(Icons.person, color: Colors.deepPurple),
                                  title: Text(booking.riderName),
                                  subtitle: Text(
                                    '${booking.seatsBooked} seat(s) - ${booking.status}',
                                  ),
                                  trailing: Text(
                                    '\$${booking.costForThisRider.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
