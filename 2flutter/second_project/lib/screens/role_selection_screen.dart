import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Choose Your Mode',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'How would you like to use UniPool?',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Rider Mode Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: () async {
                    // Update role to RIDER when rider mode is selected
                    final authProvider = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    );
                    try {
                      final updatedUser = await UserService.updateRole('RIDER');
                      authProvider.setUser(updatedUser);
                    } catch (e) {
                      // If role update fails, still allow navigation
                      // User might already have RIDER role
                    }
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(
                        context,
                        '/rider/destination-search',
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(Icons.person, size: 64, color: Colors.green),
                        const SizedBox(height: 16),
                        const Text(
                          'Rider Mode',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Search and join rides',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Driver Mode Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: () async {
                    // Update role to DRIVER when driver mode is selected
                    final authProvider = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    );
                    try {
                      final updatedUser = await UserService.updateRole('DRIVER');
                      authProvider.setUser(updatedUser);
                    } catch (e) {
                      // If role update fails, still allow navigation
                      // User might already have DRIVER role
                    }
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(
                        context,
                        '/driver/post-ride/destination-search',
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.directions_car,
                          size: 64,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Driver Mode',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Post rides and host passengers',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
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
