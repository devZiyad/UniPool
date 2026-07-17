import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MapLoadingScreen extends StatelessWidget {
  const MapLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: Stack(
        children: [
          // Skeleton map background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.lightGrayDivider,
                  AppTheme.lightGrayDivider.withOpacity(0.5),
                ],
              ),
            ),
            child: CustomPaint(
              painter: MapSkeletonPainter(),
            ),
          ),
          // Loading overlay
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.darkNavy.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryGreen,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Loading Map',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkNavy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Preparing your location...',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.softGrayText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MapSkeletonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.softGrayText.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw grid lines to simulate map tiles
    const gridSize = 80.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Draw a simple compass indicator
    final compassPaint = Paint()
      ..color = AppTheme.primaryGreen.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    final compassCenter = Offset(size.width - 60, 100);
    canvas.drawCircle(compassCenter, 20, compassPaint);
  }

  @override
  bool shouldRepaint(MapSkeletonPainter oldDelegate) => false;
}

