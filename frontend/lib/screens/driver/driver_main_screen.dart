import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'driver_ride_management_screen.dart';
import 'driver_history_screen.dart';
import '../rider/rider_unified_search_screen.dart';

class DriverMainScreen extends StatefulWidget {
  final int initialIndex;
  
  const DriverMainScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<DriverMainScreen> createState() => _DriverMainScreenState();
}

class _DriverMainScreenState extends State<DriverMainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        // Post Ride - show unified search screen in driver mode
        return const RiderUnifiedSearchScreen(
          showInTabBar: true,
          forceDriverMode: true,
        );
      case 1:
        return const DriverRideManagementScreen(showInTabBar: true);
      case 2:
        return const DriverHistoryScreen(showInTabBar: true);
      default:
        return const RiderUnifiedSearchScreen(
          showInTabBar: true,
          forceDriverMode: true,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    // Only show tabs if user is a driver
    final isDriver = user != null &&
        (user.role.toUpperCase() == 'DRIVER' ||
            user.role.toUpperCase() == 'BOTH');

    if (!isDriver) {
      // If not a driver, just show the post ride screen without tabs
      return const RiderUnifiedSearchScreen();
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _getScreen(0),
          _getScreen(1),
          _getScreen(2),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: AppTheme.softGrayText,
        backgroundColor: AppTheme.white,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Post Ride',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car_filled),
            activeIcon: Icon(Icons.directions_car_filled),
            label: 'Manage Ride',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
