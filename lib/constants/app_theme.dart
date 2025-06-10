import 'package:flutter/material.dart';

/// App theme constants and color definitions
/// Based on the exact color palette from PRD specifications
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Modern light theme with clean aesthetics and vibrant accents
  static const Color _pureWhite = Color(0xFFFFFFFF);         // Pure white - main background
  static const Color _lightGray = Color(0xFFF8F9FA);         // Light gray - card backgrounds
  static const Color _softGray = Color(0xFFF1F3F4);          // Soft gray - elevated elements
  static const Color _darkText = Color(0xFF1A1A1A);          // Dark text - main content
  static const Color _mediumGray = Color(0xFF6C757D);        // Medium gray - secondary text
  static const Color _lightBorder = Color(0xFFE9ECEF);       // Light border - subtle separators
  static const Color _vibrantBlue = Color(0xFF007AFF);       // Modern vibrant blue - primary accent
  static const Color _modernGreen = Color(0xFF34C759);       // Modern green - completed tasks
  static const Color _elegantPurple = Color(0xFF5856D6);     // Elegant purple - interactive elements
  static const Color _warmRed = Color(0xFFFF3B30);           // Warm red for errors
  static const Color _subtleGray = Color(0xFFDEE2E6);        // Subtle gray borders
  static const Color _activeBlue = Color(0xFFF0F8FF);        // Very light blue - active state backgrounds

  /// Main app theme with exact PRD color specifications
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        // Modern clean light color scheme
        primary: _vibrantBlue,              // #007AFF - Modern vibrant blue - interactive elements
        primaryContainer: _activeBlue,      // #F0F8FF - Very light blue - active state backgrounds
        secondary: _modernGreen,            // #34C759 - Modern green - completed tasks
        secondaryContainer: _softGray,      // #F1F3F4 - Soft gray - elevated elements
        tertiary: _elegantPurple,           // #5856D6 - Elegant purple - time/date highlights
        surface: _pureWhite,                // #FFFFFF - Pure white - main background
        surfaceContainer: _lightGray,       // #F8F9FA - Light gray - card backgrounds
        surfaceContainerHighest: _softGray, // #F1F3F4 - Soft gray - elevated elements
        error: _warmRed,                    // #FF3B30 - Warm red for errors
        onPrimary: _pureWhite,              // #FFFFFF - Pure white on primary
        onPrimaryContainer: _darkText,      // #1A1A1A - Dark text on primary container
        onSecondary: _pureWhite,            // White on green completion
        onSecondaryContainer: _darkText,    // #1A1A1A - Dark text on secondary container
        onTertiary: _pureWhite,             // White on purple time highlight
        onSurface: _darkText,               // #1A1A1A - Dark text - main text
        onSurfaceVariant: _mediumGray,      // #6C757D - Medium gray - secondary text
        outline: _subtleGray,               // #DEE2E6 - Subtle gray borders
        outlineVariant: _lightBorder,       // #E9ECEF - Light border - subtle separators
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: _pureWhite,  // Ensure scaffold uses pure white background
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0, // Flat design
          backgroundColor: _vibrantBlue,
          foregroundColor: _pureWhite,
        ),
      ),
      cardTheme: const CardTheme(
        elevation: 0, // Flat design
        color: _lightGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      textTheme: textTheme,
    );
  }

  /// Custom text theme matching PRD typography hierarchy
  static const TextTheme textTheme = TextTheme(
    // Time display (48px, bold, cyan) - Visual anchor
    displayLarge: TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.bold,
      color: _elegantPurple,       // #5856D6 - Elegant purple for time prominence
      letterSpacing: -1.0,
      height: 1.0,
    ),
    // Day/Date headers (24px, medium, white)
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      color: _pureWhite,           // #FFFFFF - Pure white for headers
      letterSpacing: -0.25,
      height: 1.2,
    ),
    // Task text (16px, regular, white)
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: _pureWhite,           // #FFFFFF - Pure white for main text
      height: 1.4,
    ),
    // Secondary text (14px, regular, light gray)
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: _lightGray,           // #B8B8B8 - Light gray for secondary text
      height: 1.4,
    ),
    // Placeholder text (16px, light, muted gray)
    bodySmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w300,
      color: _mediumGray,          // #6C757D - Medium gray for placeholders
      height: 1.4,
    ),
    // Day navigation labels (14px, medium, varies)
    labelMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: _lightGray,           // #B8B8B8 - Light gray for labels
      letterSpacing: 0.1,
    ),
    // Titles and headers
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      color: _pureWhite,           // #FFFFFF - Pure white for titles
      letterSpacing: -0.25,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: _pureWhite,           // #FFFFFF - Pure white for medium titles
      letterSpacing: 0.15,
    ),
  );

  /// Layout constants from PRD specifications
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;     // Screen padding horizontal
  static const double paddingXL = 32.0;

  /// Task-specific dimensions from PRD
  static const double taskItemHeight = 44.0;     // Touch-friendly task height
  static const double checkboxSize = 20.0;       // Checkbox size
  static const double taskSpacing = 8.0;         // Spacing between tasks
  static const double sidebarWidth = 80.0;       // Day navigation width

  /// Border radius constants
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;

  /// Animation durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
} 