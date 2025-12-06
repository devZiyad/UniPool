import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/ride_provider.dart';
import 'providers/driver_provider.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/my_information_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/rider/rider_destination_search_screen.dart';
import 'screens/rider/rider_start_location_screen.dart';
import 'screens/rider/rider_time_filters_screen.dart';
import 'screens/rider/rider_ride_list_screen.dart';
import 'screens/rider/rider_pending_approval_screen.dart';
import 'screens/rider/rider_live_tracking_screen.dart';
import 'screens/rider/rider_rating_screen.dart';
import 'screens/driver/driver_ride_posted_confirmation_screen.dart';
import 'screens/driver/driver_ride_management_screen.dart';
import 'screens/driver/driver_incoming_requests_screen.dart';
import 'screens/driver/driver_accepted_riders_screen.dart';
import 'screens/driver/driver_navigation_screen.dart';
import 'screens/driver/driver_rate_passenger_screen.dart';
import 'screens/vehicles/vehicles_management_screen.dart';
import 'screens/vehicles/add_vehicle_screen.dart';
import 'screens/profile/profile_settings_screen.dart';

void main() {
  runApp(const UniPoolApp());
}

class UniPoolApp extends StatelessWidget {
  const UniPoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RideProvider()),
        ChangeNotifierProvider(create: (_) => DriverProvider()),
      ],
      child: MaterialApp(
        title: 'UniPool',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/my-information': (context) => const MyInformationScreen(),
          '/role-selection': (context) => const RoleSelectionScreen(),
          // Rider routes (using unified screens)
          '/rider/destination-search': (context) =>
              const RiderDestinationSearchScreen(),
          '/rider/start-location': (context) =>
              const RiderStartLocationScreen(),
          '/rider/time-filters': (context) => const RiderTimeFiltersScreen(),
          '/rider/ride-list': (context) => const RiderRideListScreen(),
          '/rider/pending-approval': (context) =>
              const RiderPendingApprovalScreen(),
          '/rider/live-tracking': (context) {
            // This would need to get the ride from context or state
            // For now, using a placeholder
            throw UnimplementedError('Need to pass ride');
          },
          '/rider/rating': (context) {
            // This would need to get the booking from context or state
            throw UnimplementedError('Need to pass booking');
          },
          // Driver routes (using unified screens - same as rider)
          '/driver/post-ride/destination-search': (context) =>
              const RiderDestinationSearchScreen(),
          '/driver/post-ride/start-location': (context) =>
              const RiderStartLocationScreen(),
          '/driver/post-ride/route-time': (context) =>
              const RiderTimeFiltersScreen(),
          '/driver/ride-posted-confirmation': (context) =>
              const DriverRidePostedConfirmationScreen(),
          '/driver/ride-management': (context) =>
              const DriverRideManagementScreen(),
          '/driver/incoming-requests': (context) =>
              const DriverIncomingRequestsScreen(),
          '/driver/accepted-riders': (context) =>
              const DriverAcceptedRidersScreen(),
          '/driver/navigation': (context) {
            // This would need to get the ride from context or state
            throw UnimplementedError('Need to pass ride');
          },
          '/driver/rate-passenger': (context) {
            // This would need to get the booking from context or state
            throw UnimplementedError('Need to pass booking');
          },
          // Profile & Settings
          '/profile-settings': (context) => const ProfileSettingsScreen(),
          '/vehicles': (context) => const VehiclesManagementScreen(),
          '/vehicles/add': (context) => const AddVehicleScreen(),
        },
        onGenerateRoute: (settings) {
          // Handle routes with parameters
          if (settings.name == '/rider/live-tracking') {
            final ride = settings.arguments as dynamic;
            return MaterialPageRoute(
              builder: (context) => RiderLiveTrackingScreen(ride: ride),
            );
          }
          if (settings.name == '/rider/rating') {
            final booking = settings.arguments as dynamic;
            return MaterialPageRoute(
              builder: (context) => RiderRatingScreen(booking: booking),
            );
          }
          if (settings.name == '/driver/navigation') {
            final ride = settings.arguments as dynamic;
            return MaterialPageRoute(
              builder: (context) => DriverNavigationScreen(ride: ride),
            );
          }
          if (settings.name == '/driver/rate-passenger') {
            final booking = settings.arguments as dynamic;
            return MaterialPageRoute(
              builder: (context) => DriverRatePassengerScreen(booking: booking),
            );
          }
          return null;
        },
      ),
    );
  }
}
