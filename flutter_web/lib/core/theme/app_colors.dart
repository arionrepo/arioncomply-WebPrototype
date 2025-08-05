// FILE PATH: lib/core/theme/app_colors.dart
// Color system optimized for compliance/professional context

import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors - Professional blue palette
  static const Color primary = Color(0xFF3B82F6); // Blue 500
  static const Color primaryDark = Color(0xFF1E40AF); // Blue 700
  static const Color primaryLight = Color(0xFF93C5FD); // Blue 300

  // Secondary colors - Compliance-focused purple
  static const Color secondary = Color(0xFF8B5CF6); // Purple 500
  static const Color secondaryDark = Color(0xFF7C3AED); // Purple 600
  static const Color secondaryLight = Color(0xFFA78BFA); // Purple 400

  // AI/Expert accent colors
  static const Color aiAccent = Color(0xFF06B6D4); // Cyan 500
  static const Color expertGreen = Color(0xFF10B981); // Emerald 500

  // Surface colors - Light theme
  static const Color background = Color(0xFFFAFAFA); // Gray 50
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color surfaceElevated = Color(0xFFF8FAFC); // Slate 50

  // Surface colors - Dark theme
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkSurfaceElevated = Color(0xFF334155); // Slate 700

  // Text colors - Light theme
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textTertiary = Color(0xFF94A3B8); // Slate 400

  // Text colors - Dark theme
  static const Color darkTextPrimary = Color(0xFFF1F5F9); // Slate 100
  static const Color darkTextSecondary = Color(0xFFCBD5E1); // Slate 300
  static const Color darkTextTertiary = Color(0xFF64748B); // Slate 500

  // Border and outline colors
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color borderStrong = Color(0xFFCBD5E1); // Slate 300
  static const Color darkBorder = Color(0xFF475569); // Slate 600

  // Input and interaction colors
  static const Color inputBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color inputBorder = Color(0xFFD1D5DB); // Gray 300
  static const Color inputFocused = primary;

  // Status colors
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color info = Color(0xFF3B82F6); // Blue 500

  // Avatar-specific colors
  static const Color avatarBackground = Color(0xFFF0F9FF); // Sky 50
  static const Color avatarGlow = primary;
  static const Color conversationBackground = Color(0xFFFAFAFA); // Gray 50

  // Gradient definitions for avatar background
  static const LinearGradient avatarGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF0F9FF), // Sky 50
      Color(0xFFE0F2FE), // Sky 100
    ],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primary,
      primaryDark,
    ],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      secondary,
      secondaryDark,
    ],
  );

  // Shadow colors
  static const Color shadowLight = Color(0x1A000000); // 10% black
  static const Color shadowMedium = Color(0x33000000); // 20% black
  static const Color shadowStrong = Color(0x4D000000); // 30% black

  // Semantic color mappings
  static Color get successBackground => success.withValues(alpha: 0.1);
  static Color get warningBackground => warning.withValues(alpha: 0.1);
  static Color get errorBackground => error.withValues(alpha: 0.1);
  static Color get infoBackground => info.withValues(alpha: 0.1);

  // Message bubble colors
  static const Color userMessageBackground = Color(0xFFEFF6FF); // Blue 50
  static const Color avatarMessageBackground = Color(0xFFFFFFFF); // White
  static const Color systemMessageBackground = Color(0xFFF8FAFC); // Slate 50
}