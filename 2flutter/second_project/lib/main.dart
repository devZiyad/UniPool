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
import 'screens/rider/rider_main_screen.dart';
import 'screens/rider/rider_unified_search_screen.dart';
import 'screens/rider/rider_ride_list_screen.dart';
import 'screens/rider/rider_pending_approval_screen.dart';
import 'screens/rider/rider_live_tracking_screen.dart';
import 'screens/rider/rider_rating_screen.dart';
import 'screens/driver/driver_main_screen.dart';
import 'screens/driver/driver_ride_posted_confirmation_screen.dart';
import 'screens/driver/driver_incoming_requests_screen.dart';
import 'screens/driver/driver_accepted_riders_screen.dart';
import 'screens/driver/driver_navigation_screen.dart';
import 'screens/driver/driver_rate_passenger_screen.dart';
import 'screens/driver/driver_rate_all_riders_screen.dart';
import 'screens/driver/driver_ride_checklist_screen.dart';
import 'screens/vehicles/vehicles_management_screen.dart';
import 'screens/vehicles/add_vehicle_screen.dart';
import 'screens/profile/profile_settings_screen.dart';
import 'screens/admin/admin_users_management_screen.dart';
import 'models/vehicle.dart';
import 'models/ride.dart';
import 'models/booking.dart';
import 'theme/app_theme.dart';

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
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/my-information': (context) => const MyInformationScreen(),
          '/role-selection': (context) => const RoleSelectionScreen(),
          // Rider main screen with bottom tabs
          '/rider': (context) => const RiderMainScreen(initialIndex: 0),
          '/rider/bookings': (context) => const RiderMainScreen(initialIndex: 1),
          '/rider/history': (context) => const RiderMainScreen(initialIndex: 2),
          // Rider routes (using unified search screen)
          '/rider/destination-search': (context) =>
              const RiderUnifiedSearchScreen(),
          '/rider/start-location': (context) =>
              const RiderUnifiedSearchScreen(),
          '/rider/time-filters': (context) => const RiderUnifiedSearchScreen(),
          '/rider/ride-list': (context) => const RiderRideListScreen(),
          '/rider/pending-approval': (context) =>
              const RiderPendingApprovalScreen(),
          // '/rider/live-tracking' and '/rider/rating' are handled by onGenerateRoute
          // Driver main screen with bottom tabs
          '/driver': (context) => const DriverMainScreen(initialIndex: 0),
          '/driver/ride-management': (context) => const DriverMainScreen(initialIndex: 1),
          '/driver/history': (context) => const DriverMainScreen(initialIndex: 2),
          // Driver routes (using unified search screen)
          '/driver/post-ride/destination-search': (context) =>
              const RiderUnifiedSearchScreen(),
          '/driver/post-ride/start-location': (context) =>
              const RiderUnifiedSearchScreen(),
          '/driver/post-ride/route-time': (context) =>
              const RiderUnifiedSearchScreen(),
          '/driver/ride-posted-confirmation': (context) =>
              const DriverRidePostedConfirmationScreen(),
          '/driver/incoming-requests': (context) =>
              const DriverIncomingRequestsScreen(),
          '/driver/accepted-riders': (context) =>
              const DriverAcceptedRidersScreen(),
          // '/driver/navigation', '/driver/rate-passenger', and '/driver/ride-checklist' are handled by onGenerateRoute
          // Profile & Settings
          '/profile-settings': (context) => const ProfileSettingsScreen(),
          '/vehicles': (context) => const VehiclesManagementScreen(),
          '/vehicles/add': (context) {
            final vehicle = ModalRoute.of(context)?.settings.arguments;
            return AddVehicleScreen(
              vehicle: vehicle is Vehicle ? vehicle : null,
            );
          },
          // Admin routes
          '/admin/users': (context) => const AdminUsersManagementScreen(),
        },
        onGenerateRoute: (settings) {
          // Handle routes with parameters
          if (settings.name == '/rider/live-tracking') {
            final ride = settings.arguments;
            if (ride == null || ride is! Ride) {
              return MaterialPageRoute(
                builder: (context) => const Scaffold(
                  body: Center(child: Text('Error: Ride not provided')),
                ),
              );
            }
            return MaterialPageRoute(
              builder: (context) => RiderLiveTrackingScreen(ride: ride),
            );
          }
          if (settings.name == '/rider/rating') {
            final booking = settings.arguments;
            if (booking == null || booking is! Booking) {
              return MaterialPageRoute(
                builder: (context) => const Scaffold(
                  body: Center(child: Text('Error: Booking not provided')),
                ),
              );
            }
            return MaterialPageRoute(
              builder: (context) => RiderRatingScreen(booking: booking),
            );
          }
          if (settings.name == '/driver/navigation') {
            final ride = settings.arguments;
            if (ride == null || ride is! Ride) {
              return MaterialPageRoute(
                builder: (context) => const Scaffold(
                  body: Center(child: Text('Error: Ride not provided')),
                ),
              );
            }
            return MaterialPageRoute(
              builder: (context) => DriverNavigationScreen(ride: ride),
            );
          }
          if (settings.name == '/driver/rate-passenger') {
            final booking = settings.arguments;
            if (booking == null || booking is! Booking) {
              return MaterialPageRoute(
                builder: (context) => const Scaffold(
                  body: Center(child: Text('Error: Booking not provided')),
                ),
              );
            }
            return MaterialPageRoute(
              builder: (context) => DriverRatePassengerScreen(booking: booking),
            );
          }
          if (settings.name == '/driver/ride-checklist') {
            final ride = settings.arguments;
            if (ride == null || ride is! Ride) {
              return MaterialPageRoute(
                builder: (context) => const Scaffold(
                  body: Center(child: Text('Error: Ride not provided')),
                ),
              );
            }
            return MaterialPageRoute(
              builder: (context) => DriverRideChecklistScreen(ride: ride),
            );
          }
          if (settings.name == '/driver/rate-all-riders') {
            final ride = settings.arguments;
            if (ride == null || ride is! Ride) {
              return MaterialPageRoute(
                builder: (context) => const Scaffold(
                  body: Center(child: Text('Error: Ride not provided')),
                ),
              );
            }
            return MaterialPageRoute(
              builder: (context) => DriverRateAllRidersScreen(ride: ride),
            );
          }
          return null;
        },
      ),
    );
  }
}
