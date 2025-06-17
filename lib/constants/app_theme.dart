import 'package:flutter/material.dart';

/// Modern, futuristic theme configuration for Pare app
/// Implements glass morphism, sophisticated gradients, and clean typography
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Enhanced color palette with modern, futuristic tones
  /// Background colors with glass morphism support
  static const Color _richBlack = Color(0xFF0A0A0B);        // Deepest background
  static const Color _surfaceDark = Color(0xFF1C1C1E);      // Card backgrounds  
  static const Color _surfaceElevated = Color(0xFF2C2C2E);  // Elevated elements
  static const Color _glassBackground = Color(0x10FFFFFF);   // Glass morphism overlay
  static const Color _glassBorder = Color(0x20FFFFFF);      // Glass borders
  
  /// Text colors with enhanced hierarchy
  static const Color _textPrimary = Color(0xFFFFFFFF);      // Pure white - main text
  static const Color _textSecondary = Color(0xFFE5E5E7);    // Light grey - secondary
  static const Color _textTertiary = Color(0xFF8E8E93);     // Medium grey - tertiary
  
  /// Accent colors with modern vibrancy
  static const Color _primaryBlue = Color(0xFF007AFF);      // iOS Blue - interactive
  static const Color _successGreen = Color(0xFF34C759);     // Green - completion
  static const Color _accentOrange = Color(0xFFFF9F0A);     // Orange - time highlights
  static const Color _errorRed = Color(0xFFFF3B30);         // Red - destructive actions
  
  /// Border and outline colors
  static const Color _borderSubtle = Color(0xFF38383A);     // Subtle borders
  static const Color _borderEmphasized = Color(0xFF48484A); // Emphasized borders

  /// Modern light theme with futuristic glass morphism
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      /// Enhanced color scheme for modern UI
      colorScheme: const ColorScheme.light(
        brightness: Brightness.light,
        primary: Color(0xFF1A1A1A),           // Dark primary for light theme
        onPrimary: Color(0xFFFFFFFF),         // White on primary
        primaryContainer: Color(0xFFF8F9FA),  // Very light container
        onPrimaryContainer: Color(0xFF1A1A1A), // Dark text on light container
        
        secondary: _successGreen,              // Success green
        onSecondary: Color(0xFF000000),       // Black on green
        secondaryContainer: Color(0xFFE8F8F0), // Light green container
        onSecondaryContainer: Color(0xFF1A1A1A),
        
        tertiary: _accentOrange,              // Accent orange
        onTertiary: Color(0xFF000000),        // Black on orange
        
        surface: Color(0xFFFFFFFF),           // Pure white surface
        onSurface: Color(0xFF1A1A1A),         // Dark text on surface
        surfaceContainer: Color(0xFFF8F9FA),  // Light container
        onSurfaceVariant: Color(0xFF8E8E93),  // Secondary text
        
        outline: Color(0xFFE5E5EA),           // Light borders
        outlineVariant: Color(0xFFF2F2F7),   // Subtle borders
        
        shadow: Color(0x0A000000),            // Subtle shadows
        surfaceTint: Color(0xFF007AFF),       // Blue tint
        
        error: _errorRed,                     // Error red
        onError: Color(0xFFFFFFFF),           // White on error
      ),

      /// Modern app bar theme with glass effect
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Color(0x95FFFFFF),    // Semi-transparent white
        foregroundColor: Color(0xFF1A1A1A),   // Dark text
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
          letterSpacing: -0.5,
        ),
      ),

      /// Enhanced button themes with modern styling
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: const Color(0xFF1A1A1A),
          foregroundColor: const Color(0xFFFFFFFF),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      /// Modern card theme with glass morphism
      cardTheme: CardTheme(
        elevation: 0,
        shadowColor: Colors.transparent,
        color: const Color(0xFFF8F9FA),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: Color(0xFFE5E5EA),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      /// Modern input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFE5E5EA),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFE5E5EA),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF1A1A1A),
            width: 2,
          ),
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF8E8E93),
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),

      textTheme: modernTextTheme,
    );
  }

  /// Dark theme with enhanced glass morphism and modern styling
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: _primaryBlue,
        onPrimary: _textPrimary,
        primaryContainer: _surfaceElevated,
        onPrimaryContainer: _textSecondary,
        
        secondary: _successGreen,
        onSecondary: _richBlack,
        secondaryContainer: Color(0xFF1C3A2E),
        onSecondaryContainer: _textSecondary,
        
        tertiary: _accentOrange,
        onTertiary: _richBlack,
        
        surface: _richBlack,
        onSurface: _textPrimary,
        surfaceContainer: _surfaceDark,
        surfaceContainerHighest: _surfaceElevated,
        onSurfaceVariant: _textTertiary,
        
        outline: _borderSubtle,
        outlineVariant: _borderEmphasized,
        
        shadow: Color(0x40000000),
        surfaceTint: _primaryBlue,
        
        error: _errorRed,
        onError: _textPrimary,
      ),

      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Color(0x95000000),
        foregroundColor: _textPrimary,
      ),

      textTheme: modernTextTheme,
    );
  }

  /// Modern typography system with enhanced hierarchy
  static const TextTheme modernTextTheme = TextTheme(
    // Time display - Large, prominent with modern styling
    displayLarge: TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.w200,       // Ultra light for modern look
      color: Color(0xFF1A1A1A),         // Dark for light theme
      letterSpacing: -2.0,              // Tight spacing for modern feel
      height: 0.9,
    ),
    
    // Headers and day names
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w300,      // Light weight
      color: Color(0xFF1A1A1A),
      letterSpacing: -1.0,
      height: 1.1,
    ),
    
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,      // Regular weight
      color: Color(0xFF1A1A1A),
      letterSpacing: -0.5,
      height: 1.2,
    ),
    
    // Task text and body content
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Color(0xFF1A1A1A),
      height: 1.4,
      letterSpacing: 0.1,
    ),
    
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Color(0xFF8E8E93),
      height: 1.4,
      letterSpacing: 0.1,
    ),
    
    // Labels and secondary text
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,      // Medium weight for labels
      color: Color(0xFF1A1A1A),
      letterSpacing: 0.2,
    ),
    
    labelMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Color(0xFF8E8E93),
      letterSpacing: 0.3,
    ),
    
    // Titles
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,      // Semi-bold for titles
      color: Color(0xFF1A1A1A),
      letterSpacing: -0.3,
    ),
    
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Color(0xFF1A1A1A),
      letterSpacing: -0.2,
    ),
  );

  /// Enhanced layout constants for modern spacing
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 40.0;

  /// Modern dimension constants
  static const double taskItemHeight = 56.0;        // Increased for better touch
  static const double checkboxSize = 24.0;          // Larger checkbox
  static const double taskSpacing = 12.0;           // More generous spacing
  static const double sidebarWidth = 88.0;          // Wider sidebar

  /// Modern border radius constants
  static const double radiusS = 12.0;               // Increased minimum radius
  static const double radiusM = 16.0;
  static const double radiusL = 20.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;

  /// Enhanced animation durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationExtra = Duration(milliseconds: 800);

  /// Glass morphism effect decoration
  static BoxDecoration glassDecoration({
    Color? backgroundColor,
    Color? borderColor,
    double borderRadius = 16.0,
    double borderWidth = 1.0,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? _glassBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? _glassBorder,
        width: borderWidth,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A000000),
          blurRadius: 20,
          offset: Offset(0, 4),
        ),
        BoxShadow(
          color: Color(0x05000000),
          blurRadius: 40,
          offset: Offset(0, 8),
        ),
      ],
    );
  }

  /// Modern card decoration with elevation
  static BoxDecoration modernCardDecoration({
    Color? backgroundColor,
    Color? borderColor,
    double borderRadius = 20.0,
    bool elevated = true,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? const Color(0xFFF8F9FA),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? const Color(0xFFE5E5EA),
        width: 1.0,
      ),
      boxShadow: elevated ? [
        const BoxShadow(
          color: Color(0x08000000),
          blurRadius: 16,
          offset: Offset(0, 2),
        ),
        const BoxShadow(
          color: Color(0x04000000),
          blurRadius: 32,
          offset: Offset(0, 8),
        ),
      ] : null,
    );
  }
} 