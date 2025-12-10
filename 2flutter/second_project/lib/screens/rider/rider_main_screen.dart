import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'rider_unified_search_screen.dart';
import 'rider_bookings_screen.dart';
import 'rider_history_screen.dart';

class RiderMainScreen extends StatefulWidget {
  final int initialIndex;
  
  const RiderMainScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<RiderMainScreen> createState() => _RiderMainScreenState();
}

class _RiderMainScreenState extends State<RiderMainScreen> {
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
        return const RiderUnifiedSearchScreen(showInTabBar: true);
      case 1:
        return const RiderBookingsScreen(showInTabBar: true);
      case 2:
        return const RiderHistoryScreen(showInTabBar: true);
      default:
        return const RiderUnifiedSearchScreen(showInTabBar: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    // Only show tabs if user is a rider
    final isRider = user != null &&
        (user.role.toUpperCase() == 'RIDER' ||
            user.role.toUpperCase() == 'BOTH');

    if (!isRider) {
      // If not a rider, just show the search screen without tabs
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
            icon: Icon(Icons.search),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            activeIcon: Icon(Icons.event_note),
            label: 'My Bookings',
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

