import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';

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
  late Animation<double> _riderAnimation;
  late Animation<double> _driverAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _riderAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _driverAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectRider() async {
    if (_riderExpanding || _driverExpanding) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    // Prevent selecting RIDER if university ID verification is pending
    if (user != null && !user.universityIdVerified) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'University ID verification is required to use Rider mode. Please wait for verification.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }
    
    setState(() {
      _riderExpanding = true;
    });
    
    _animationController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    try {
      final updatedUser = await UserService.updateRole('RIDER');
      authProvider.setUser(updatedUser);
    } catch (e) {
      // If role update fails, still allow navigation
    }
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/rider/destination-search');
    }
  }

  Future<void> _selectDriver() async {
    if (_riderExpanding || _driverExpanding) return;
    
    setState(() {
      _driverExpanding = true;
    });
    
    _animationController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final updatedUser = await UserService.updateRole('DRIVER');
      authProvider.setUser(updatedUser);
    } catch (e) {
      // If role update fails, still allow navigation
    }
    
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        '/driver/post-ride/destination-search',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isUniversityIdVerified = user?.universityIdVerified ?? false;
    
    return Scaffold(
      body: Stack(
        children: [
          // Rider section (top-left triangle)
          AnimatedBuilder(
            animation: _riderAnimation,
            builder: (context, child) {
              final scale = _riderExpanding
                  ? 1.0 + (_riderAnimation.value * 3.0)
                  : _riderHovered
                      ? 1.05
                      : 1.0;
              
              return Positioned.fill(
                child: _riderExpanding
                    ? Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue.shade600,
                              Colors.blue.shade400,
                            ],
                          ),
                        ),
                      )
                    : Transform.scale(
                        scale: scale,
                        alignment: Alignment.topLeft,
                        child: ClipPath(
                          clipper: DiagonalClipper(isTop: true),
                          child: MouseRegion(
                            onEnter: (_) {
                              if (!_riderExpanding && !_driverExpanding && isUniversityIdVerified) {
                                setState(() => _riderHovered = true);
                              }
                            },
                            onExit: (_) {
                              if (!_riderExpanding && !_driverExpanding) {
                                setState(() => _riderHovered = false);
                              }
                            },
                            child: GestureDetector(
                              onTap: isUniversityIdVerified ? _selectRider : null,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: !isUniversityIdVerified
                                        ? [
                                            Colors.grey.shade400,
                                            Colors.grey.shade300,
                                          ]
                                        : _riderHovered
                                            ? [
                                                Colors.blue.shade600,
                                                Colors.blue.shade400,
                                              ]
                                            : [
                                                Colors.blue.shade400,
                                                Colors.blue.shade300,
                                              ],
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 80, left: 40),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.person,
                                          size: _riderHovered && isUniversityIdVerified ? 80 : 64,
                                          color: !isUniversityIdVerified
                                              ? Colors.grey.shade600
                                              : Colors.white,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Rider',
                                          style: TextStyle(
                                            fontSize: _riderHovered && isUniversityIdVerified ? 36 : 28,
                                            fontWeight: FontWeight.bold,
                                            color: !isUniversityIdVerified
                                                ? Colors.grey.shade600
                                                : Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          !isUniversityIdVerified
                                              ? 'University ID verification required'
                                              : 'Search and join rides',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: !isUniversityIdVerified
                                                ? Colors.grey.shade600
                                                : Colors.white.withOpacity(0.9),
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
              );
            },
          ),
          // Driver section (bottom-right triangle)
          AnimatedBuilder(
            animation: _driverAnimation,
            builder: (context, child) {
              final scale = _driverExpanding
                  ? 1.0 + (_driverAnimation.value * 3.0)
                  : _driverHovered
                      ? 1.05
                      : 1.0;
              
              return Positioned.fill(
                child: _driverExpanding
                    ? Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.orange.shade600,
                              Colors.orange.shade400,
                            ],
                          ),
                        ),
                      )
                    : Transform.scale(
                        scale: scale,
                        alignment: Alignment.bottomRight,
                        child: ClipPath(
                          clipper: DiagonalClipper(isTop: false),
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
                            child: GestureDetector(
                              onTap: _selectDriver,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: _driverHovered
                                        ? [
                                            Colors.orange.shade600,
                                            Colors.orange.shade400,
                                          ]
                                        : [
                                            Colors.orange.shade400,
                                            Colors.orange.shade300,
                                          ],
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 80, right: 40),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Icon(
                                          Icons.directions_car,
                                          size: _driverHovered ? 80 : 64,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Driver',
                                          style: TextStyle(
                                            fontSize: _driverHovered ? 36 : 28,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Post rides and host passengers',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white.withOpacity(0.9),
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
