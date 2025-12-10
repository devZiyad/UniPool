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
          // Only show Switch Mode if university ID is verified
          if (user != null && user.universityIdVerified) ...[
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
          ],
          // Rider-specific options (show for RIDER or BOTH roles)
          if (user != null &&
              (user.role.toUpperCase() == 'RIDER' ||
                  user.role.toUpperCase() == 'BOTH')) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Rider Home'),
              subtitle: const Text('Go to rider main screen'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/rider');
              },
            ),
          ],
          // Driver-specific options (show for DRIVER or BOTH roles)
          if (user != null &&
              (user.role.toUpperCase() == 'DRIVER' ||
                  user.role.toUpperCase() == 'BOTH')) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('My Vehicles'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/vehicles');
              },
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Driver Home'),
              subtitle: const Text('Go to driver main screen'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/driver');
              },
            ),
          ],
          // Admin-specific options
          if (user != null && user.role.toUpperCase() == 'ADMIN') ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('User Management'),
              subtitle: const Text('Manage all users and verifications'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/admin/users');
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
