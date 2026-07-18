import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryGreen = Color(0xFF00C389);
  static const Color primaryGreenLight = Color(0xFF4CE090);
  
  // Secondary Colors
  static const Color darkNavy = Color(0xFF1A1C1E);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrayDivider = Color(0xFFE9ECEF);
  static const Color softGrayText = Color(0xFFAEB4C2);
  
  // Additional semantic colors
  static const Color error = Color(0xFFE53935);
  static const Color success = primaryGreen;
  static const Color warning = Color(0xFFFFB300);
  static const Color info = Color(0xFF2196F3);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: primaryGreen,
        primaryContainer: primaryGreenLight,
        secondary: darkNavy,
        secondaryContainer: darkNavy.withOpacity(0.1),
        surface: white,
        surfaceContainerHighest: lightGrayDivider,
        error: error,
        onPrimary: white,
        onSecondary: white,
        onSurface: darkNavy,
        onError: white,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: white,
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: darkNavy,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: darkNavy,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: darkNavy,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: lightGrayDivider, width: 1),
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreen,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkNavy,
          side: const BorderSide(color: lightGrayDivider, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGrayDivider, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGrayDivider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(
          color: softGrayText,
          fontSize: 16,
        ),
        labelStyle: const TextStyle(
          color: softGrayText,
          fontSize: 14,
        ),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: darkNavy,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: darkNavy,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: darkNavy,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: darkNavy,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: darkNavy,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: darkNavy,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: darkNavy,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: darkNavy,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: darkNavy,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: darkNavy,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: darkNavy,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          color: softGrayText,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        labelLarge: TextStyle(
          color: darkNavy,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: softGrayText,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: softGrayText,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: lightGrayDivider,
        thickness: 1,
        space: 1,
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: darkNavy,
        size: 24,
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: white,
        elevation: 4,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: primaryGreen,
        unselectedItemColor: softGrayText,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: lightGrayDivider,
        deleteIconColor: darkNavy,
        labelStyle: const TextStyle(
          color: darkNavy,
          fontSize: 14,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      
      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkNavy,
        contentTextStyle: const TextStyle(
          color: white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: const TextStyle(
          color: darkNavy,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: darkNavy,
          fontSize: 16,
        ),
      ),
      
      // Drawer Theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: white,
      ),
      
      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        textColor: darkNavy,
        iconColor: darkNavy,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
  
  // Helper method to create gradient
  static LinearGradient get primaryGradient {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primaryGreen, primaryGreenLight],
    );
  }
  
  // Helper method for secondary button style
  static ButtonStyle get secondaryButtonStyle {
    return ElevatedButton.styleFrom(
      backgroundColor: darkNavy,
      foregroundColor: white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

