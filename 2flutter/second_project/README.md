# UniPool Flutter Frontend

A comprehensive Flutter application for university carpooling, connecting riders with drivers.

## Features

### Authentication & Identity
- Welcome screen with login/register options
- User registration with email, password, and university ID
- Login functionality
- Document upload (Driving License, University Card, ID Card)
- Role selection (Rider/Driver)

### Rider Mode
- Destination search with map integration
- Start location selection
- Time range and filter selection
- Ride list with driver details and pricing
- Seat selection
- Pending driver approval screen
- Live ride tracking
- Driver rating after ride completion

### Driver Mode
- Post ride flow (destination → start location → route & time)
- Ride management dashboard
- Incoming ride requests
- Accept/decline requests
- Accepted riders management
- Live navigation during ride
- Rate passengers after ride

## Project Structure

```
lib/
├── main.dart                 # App entry point with routing
├── models/                   # Data models
│   ├── user.dart
│   ├── ride.dart
│   ├── booking.dart
│   ├── location.dart
│   ├── vehicle.dart
│   └── rating.dart
├── services/                 # API services
│   ├── api_client.dart
│   ├── auth_service.dart
│   ├── ride_service.dart
│   ├── booking_service.dart
│   ├── location_service.dart
│   ├── rating_service.dart
│   ├── tracking_service.dart
│   └── vehicle_service.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── ride_provider.dart
│   └── driver_provider.dart
└── screens/                  # UI screens
    ├── auth/
    │   ├── welcome_screen.dart
    │   ├── login_screen.dart
    │   ├── register_screen.dart
    │   └── my_information_screen.dart
    ├── role_selection_screen.dart
    ├── rider/
    │   ├── rider_destination_search_screen.dart
    │   ├── rider_start_location_screen.dart
    │   ├── rider_time_filters_screen.dart
    │   ├── rider_ride_list_screen.dart
    │   ├── rider_pending_approval_screen.dart
    │   ├── rider_live_tracking_screen.dart
    │   └── rider_rating_screen.dart
    └── driver/
        ├── driver_post_ride_destination_screen.dart
        ├── driver_post_ride_start_location_screen.dart
        ├── driver_post_ride_route_time_screen.dart
        ├── driver_ride_posted_confirmation_screen.dart
        ├── driver_ride_management_screen.dart
        ├── driver_incoming_requests_screen.dart
        ├── driver_accepted_riders_screen.dart
        ├── driver_navigation_screen.dart
        └── driver_rate_passenger_screen.dart
```

## Setup Instructions

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Backend URL**
   - The app is configured to use the production backend: `https://unipool.devziyad.me/api`
   - To change the backend URL, update `baseUrl` in `lib/services/api_client.dart`

3. **Maps Setup** (Required for map display)
   - Get a Google Maps API key for map display
   - For Android: Add to `android/app/src/main/AndroidManifest.xml`
   - For iOS: Add to `ios/Runner/AppDelegate.swift`
   - **Note**: Location search uses SerpApi (already configured), not Google Maps API

4. **Run the App**
   ```bash
   flutter run
   ```

## Backend Integration

The app integrates with the UniPool backend API at `https://unipool.devziyad.me/api`. The backend must be accessible and running for the app to function properly.

### Key API Endpoints Used:
- `/api/auth/register` - User registration
- `/api/auth/login` - User authentication
- `/api/rides/search` - Search for available rides
- `/api/bookings` - Create and manage bookings
- `/api/tracking/{rideId}` - GPS tracking
- `/api/ratings` - Submit ratings

## State Management

The app uses the Provider package for state management:
- **AuthProvider**: Manages user authentication state
- **RideProvider**: Manages ride search and selection state
- **DriverProvider**: Manages driver ride posting and management state

## Navigation Flow

### Rider Flow:
1. Welcome → Login/Register
2. My Information (Documents)
3. Role Selection
4. Destination Search → Start Location → Time & Filters
5. Ride List → Request Ride
6. Pending Approval → Live Tracking
7. Rating Screen

### Driver Flow:
1. Welcome → Login/Register
2. My Information (Documents)
3. Role Selection
4. Post Ride: Destination → Start Location → Route & Time
5. Ride Posted Confirmation
6. Ride Management → Incoming Requests
7. Accepted Riders → Navigation
8. Rate Passenger

## Notes

- The app requires internet connection for API calls
- **Location Search**: Uses SerpApi Google Maps API for location search (configured with API key)
- **Map Display**: Uses Google Maps Flutter for displaying maps (requires Google Maps API key)
- Image picker is used for document uploads
- JWT tokens are stored securely using SharedPreferences
- The app polls for booking status updates every 5 seconds

## Future Enhancements

- Push notifications for ride updates
- Real-time WebSocket connections
- Offline mode support
- Enhanced map features with route optimization
- Payment integration
- Chat functionality between riders and drivers
