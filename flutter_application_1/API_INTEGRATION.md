# API Integration Summary

This document describes the integration of the Flutter frontend with the UniPool backend API.

## Overview

The frontend has been refactored to use the real backend API endpoints instead of the dummy backend service. All API calls are now made through a centralized API client with proper authentication and error handling.

## Architecture

### API Client (`lib/services/api_client.dart`)
- Centralized HTTP client with JWT token management
- Automatic token injection in request headers
- Secure token storage using `flutter_secure_storage`
- Automatic token clearing on 401 responses
- Base URL: `http://localhost:8080/api`

### Service Layer
All services are located in `lib/services/`:
- **AuthService**: Authentication (register, login, get current user)
- **LocationService**: Location management (create, search, reverse geocode)
- **VehicleService**: Vehicle management (create, update, activate, delete)
- **RideService**: Ride management (create, search, update, delete)
- **BookingService**: Booking management (create, get, cancel)

### Models
All data models are located in `lib/models/`:
- **User**: User profile and authentication data
- **Location**: Location/address data
- **Vehicle**: Vehicle information
- **Ride**: Ride details
- **Booking**: Booking information

## Key Changes

### 1. Authentication
- **Before**: Dummy in-memory authentication
- **After**: Real API authentication with JWT tokens
- Registration now requires: universityId, email, password, fullName, phoneNumber (optional)
- Tokens are stored securely using `flutter_secure_storage`
- Automatic token refresh on API calls

### 2. Location Management
- **Before**: Only OpenStreetMap Nominatim for search
- **After**: 
  - Still uses Nominatim for initial search
  - Locations are saved to backend when creating rides
  - Reverse geocoding uses backend API
  - Favorite locations can be stored

### 3. Ride Posting
- **Before**: Mock ride posting
- **After**: 
  - Real API integration
  - Requires vehicle registration first
  - Creates locations in backend if they don't exist
  - Proper error handling and user feedback

### 4. Booking Management
- **Before**: Not implemented
- **After**: 
  - View bookings for a ride
  - Real-time booking status
  - Booking details display

## Configuration

### Base URL
The API base URL is configured in `lib/services/api_client.dart`:
```dart
static const String baseUrl = 'http://localhost:8080/api';
```

**Important Notes:**
- For **Android Emulator**: Change to `http://10.0.2.2:8080/api`
- For **iOS Simulator**: `http://localhost:8080/api` works
- For **Physical Devices**: Use your computer's IP address (e.g., `http://192.168.1.100:8080/api`)

### Dependencies Added
- `flutter_secure_storage: ^9.0.0` - Secure token storage
- `intl: ^0.19.0` - Date/time formatting

## Usage Examples

### Register a User
```dart
final authResponse = await AuthService.register(
  universityId: 'S123456',
  email: 'user@university.edu',
  password: 'password123',
  fullName: 'John Doe',
  phoneNumber: '+1234567890',
  role: 'RIDER',
);
```

### Login
```dart
final authResponse = await AuthService.login(
  email: 'user@university.edu',
  password: 'password123',
);
```

### Create a Ride
```dart
final ride = await RideService.createRide(
  vehicleId: 1,
  pickupLocationId: 1,
  destinationLocationId: 2,
  departureTime: DateTime.now().add(Duration(hours: 2)),
  totalSeats: 4,
  basePrice: 10.0,
  pricePerSeat: 5.0,
);
```

### Search Rides
```dart
final rides = await RideService.searchRides(
  pickupLatitude: 26.0667,
  pickupLongitude: 50.5577,
  pickupRadiusKm: 5.0,
  destinationLatitude: 26.2000,
  destinationLongitude: 50.6000,
  destinationRadiusKm: 5.0,
  minAvailableSeats: 1,
);
```

## Error Handling

All API calls use try-catch blocks and display user-friendly error messages:
- Network errors
- Authentication errors (401) - automatically logs out
- Validation errors (400)
- Not found errors (404)
- Server errors (500)

## Next Steps / TODO

1. **Vehicle Registration Flow**: Add a UI for vehicle registration before posting rides
2. **Ride Search for Riders**: Implement ride search functionality for riders
3. **Booking Flow**: Complete booking creation and payment flow
4. **Real-time Updates**: Implement WebSocket or polling for ride tracking
5. **Image Upload**: Implement document/image upload for user verification
6. **Settings**: Add user settings management
7. **Notifications**: Integrate notification system
8. **Payment**: Integrate payment processing
9. **Rating System**: Add rating functionality

## Testing

To test the integration:
1. Start the backend server on `http://localhost:8080`
2. Update the base URL if using Android emulator or physical device
3. Run the Flutter app
4. Register a new user or login
5. Register a vehicle (required before posting rides)
6. Post a ride
7. View bookings

## Troubleshooting

### Connection Issues
- Check if backend is running
- Verify base URL matches your environment
- Check network permissions in Android/iOS

### Authentication Issues
- Clear app data and re-register
- Check token storage permissions
- Verify backend JWT configuration

### Location Issues
- Ensure location permissions are granted
- Check if GPS is enabled
- Verify backend location service is working

