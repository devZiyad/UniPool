import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';
import '../services/booking_service.dart';
import '../services/rating_service.dart';
import '../theme/app_theme.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  bool _riderHovered = false;
  bool _driverHovered = false;
  bool _riderExpanding = false;
  bool _driverExpanding = false;
  late AnimationController _animationController;
  late Animation<double> _circleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _circleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    // Check for completed rides that need rating
    _checkForCompletedRides();
  }

  Future<void> _checkForCompletedRides() async {
    try {
      final bookings = await BookingService.getMyBookings();

      // Find completed bookings that need rating
      for (final booking in bookings) {
        // Check for COMPLETED bookings (bookings are now marked as COMPLETED when ride is completed)
        if (booking.status.toUpperCase() == 'COMPLETED') {
          try {
            // Check if rating exists
            final hasRating = await RatingService.hasRatingForBooking(
              booking.id,
            );
            if (!hasRating && mounted) {
              // Navigate to rating screen
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  Navigator.pushNamed(
                    context,
                    '/rider/rating',
                    arguments: booking,
                  );
                }
              });
              break; // Only navigate to first unrated completed booking
            }
          } catch (e) {
            print('Error checking booking ${booking.id}: $e');
          }
        }
      }
    } catch (e) {
      print('Error checking for completed rides: $e');
      // Don't show error to user, just log it
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectRider() async {
    if (_riderExpanding || _driverExpanding) return;

    setState(() {
      _riderExpanding = true;
    });

    _animationController.forward();
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final updatedUser = await UserService.updateRole('RIDER');
      authProvider.setUser(updatedUser);
    } catch (e) {
      // If role update fails, still allow navigation
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/rider');
    }
  }

  Future<void> _selectDriver() async {
    if (_riderExpanding || _driverExpanding) return;

    setState(() {
      _driverExpanding = true;
    });

    _animationController.forward();
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final updatedUser = await UserService.updateRole('DRIVER');
      authProvider.setUser(updatedUser);
    } catch (e) {
      // If role update fails, still allow navigation
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/driver');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Calculate the maximum radius needed to cover the entire screen from a corner
    // Distance from corner to opposite corner
    final maxRadiusSqrt = math.sqrt(
      size.width * size.width + size.height * size.height,
    );

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: Stack(
        children: [
          // Rider section (top-left triangle)
          Positioned.fill(
            child: ClipPath(
              clipper: DiagonalClipper(isTop: true),
              child: GestureDetector(
                onTap: _selectRider,
                child: MouseRegion(
                  onEnter: (_) {
                    if (!_riderExpanding && !_driverExpanding) {
                      setState(() => _riderHovered = true);
                    }
                  },
                  onExit: (_) {
                    if (!_riderExpanding && !_driverExpanding) {
                      setState(() => _riderHovered = false);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _riderHovered
                            ? [
                                AppTheme.primaryGreen,
                                AppTheme.primaryGreenLight,
                              ]
                            : [
                                AppTheme.primaryGreen.withOpacity(0.8),
                                AppTheme.primaryGreenLight.withOpacity(0.8),
                              ],
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 80,
                          left: 40,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.person,
                              size: _riderHovered ? 80 : 64,
                              color: AppTheme.white,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Rider',
                              style: TextStyle(
                                fontSize: _riderHovered ? 36 : 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Search and join rides',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Driver section (bottom-right triangle)
          Positioned.fill(
            child: ClipPath(
              clipper: DiagonalClipper(isTop: false),
              child: GestureDetector(
                onTap: _selectDriver,
                child: MouseRegion(
                  onEnter: (_) {
                    if (!_riderExpanding && !_driverExpanding) {
                      setState(() => _driverHovered = true);
                    }
                  },
                  onExit: (_) {
                    if (!_riderExpanding && !_driverExpanding) {
                      setState(() => _driverHovered = false);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _driverHovered
                            ? [
                                AppTheme.darkNavy,
                                AppTheme.darkNavy.withOpacity(0.8),
                              ]
                            : [
                                AppTheme.darkNavy.withOpacity(0.8),
                                AppTheme.darkNavy.withOpacity(0.6),
                              ],
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 80,
                          right: 40,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.directions_car,
                              size: _driverHovered ? 80 : 64,
                              color: AppTheme.white,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Driver',
                              style: TextStyle(
                                fontSize: _driverHovered ? 36 : 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Post rides and host passengers',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.white.withOpacity(0.9),
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Expanding circle overlay
          if (_riderExpanding || _driverExpanding)
            AnimatedBuilder(
              animation: _circleAnimation,
              builder: (context, child) {
                final radius = _circleAnimation.value * maxRadiusSqrt;
                final center = _riderExpanding
                    ? Offset(0, 0) // Top-left corner
                    : Offset(size.width, size.height); // Bottom-right corner

                return CustomPaint(
                  painter: CircleExpansionPainter(
                    center: center,
                    radius: radius,
                    color: _riderExpanding
                        ? AppTheme.primaryGreen
                        : AppTheme.darkNavy,
                  ),
                  size: size,
                );
              },
            ),
        ],
      ),
    );
  }
}

class DiagonalClipper extends CustomClipper<Path> {
  final bool isTop;

  DiagonalClipper({required this.isTop});

  @override
  Path getClip(Size size) {
    final path = Path();

    if (isTop) {
      // Top-left triangle: top-left corner, top-right corner, bottom-left corner
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(0, size.height);
      path.close();
    } else {
      // Bottom-right triangle: top-right corner, bottom-right corner, bottom-left corner
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
    }

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class CircleExpansionPainter extends CustomPainter {
  final Offset center;
  final double radius;
  final Color color;

  CircleExpansionPainter({
    required this.center,
    required this.radius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CircleExpansionPainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.center != center ||
        oldDelegate.color != color;
  }
}
