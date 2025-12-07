import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    user?.fullName.substring(0, 1).toUpperCase() ?? 'U',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.fullName ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (user?.email != null)
                  Text(
                    user!.email,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile & Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile-settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.directions_car),
            title: const Text('My Vehicles'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/vehicles');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: const Text('Switch Mode'),
            subtitle: const Text('Change between Rider/Driver'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/role-selection');
            },
          ),
          // Rider-specific options (show for RIDER or BOTH roles)
          if (user != null &&
              (user.role.toUpperCase() == 'RIDER' ||
                  user.role.toUpperCase() == 'BOTH')) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Search for Ride'),
              subtitle: const Text(
                'Find rides by destination and start location',
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/rider/destination-search');
              },
            ),
          ],
          // Driver-specific options (show for DRIVER or BOTH roles)
          if (user != null &&
              (user.role.toUpperCase() == 'DRIVER' ||
                  user.role.toUpperCase() == 'BOTH')) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home - Post Ride'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/driver/post-ride/destination-search',
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_car_filled),
              title: const Text('Manage Ride'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/driver/ride-management');
              },
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              Navigator.pop(context);
              await AuthService.logout();
              if (context.mounted) {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
          ),
        ],
      ),
    );
  }
}
