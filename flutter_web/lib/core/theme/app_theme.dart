// lib/core/theme/app_theme.dart
// ArionComply Theme System - Professional appearance for demos
// Avatar-centric design with compliance industry aesthetics

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get light => _lightTheme;
  static ThemeData get dark => _darkTheme;

  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Color scheme optimized for compliance/professional context
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      background: AppColors.background,
      error: AppColors.error,
    ),

    // Typography system for professional appearance
    textTheme: AppTextStyles.lightTextTheme,
    
    // Avatar-centric app bar theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: AppTextStyles.titleLarge.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),

    // Cards for conversation bubbles and panels
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
    ),

    // Elevated buttons for primary actions
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: AppColors.primary.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: AppTextStyles.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Outlined buttons for secondary actions
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: AppTextStyles.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Text buttons for tertiary actions
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: AppTextStyles.labelMedium.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // Icon button theme
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    // Input decoration for conversation interface
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.error, width: 1),
      ),
      contentPadding: const EdgeInsets.all(16),
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textTertiary,
      ),
    ),

    // Floating Action Button (for voice input)
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: const CircleBorder(),
    ),

    // Chip theme for suggestions
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary.withOpacity(0.1),
      labelStyle: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textPrimary,
      ),
      side: BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // Progress indicator theme
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.border.withOpacity(0.3),
      circularTrackColor: AppColors.border.withOpacity(0.3),
    ),

    // Divider theme
    dividerTheme: DividerThemeData(
      color: AppColors.border.withOpacity(0.5),
      thickness: 1,
      space: 1,
    ),

    // Bottom sheet theme (for mobile)
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      elevation: 8,
    ),

    // Dialog theme
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      titleTextStyle: AppTextStyles.titleLarge.copyWith(
        color: AppColors.textPrimary,
      ),
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
    ),

    // Tooltip theme
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: AppTextStyles.bodySmall.copyWith(
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
  );

  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.darkSurface,
      background: AppColors.darkBackground,
      error: AppColors.error,
    ),

    textTheme: AppTextStyles.darkTextTheme,
    
    // Dark theme variations of other theme components...
    // (Similar structure but with dark colors)
  );
}

// lib/core/theme/app_colors.dart
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
  static Color get successBackground => success.withOpacity(0.1);
  static Color get warningBackground => warning.withOpacity(0.1);
  static Color get errorBackground => error.withOpacity(0.1);
  static Color get infoBackground => info.withOpacity(0.1);

  // Message bubble colors
  static const Color userMessageBackground = Color(0xFFEFF6FF); // Blue 50
  static const Color avatarMessageBackground = Color(0xFFFFFFFF); // White
  static const Color systemMessageBackground = Color(0xFFF8FAFC); // Slate 50
}

// lib/core/theme/app_text_styles.dart
// Typography system for professional compliance interface

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Font family - Professional and readable
  static const String fontFamily = 'Inter';

  // Base text styles
  static const TextStyle _baseStyle = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    height: 1.4, // Good line height for readability
  );

  // Display styles (for hero text, headers)
  static final TextStyle displayLarge = _baseStyle.copyWith(
    fontSize: 57,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -1.5,
  );

  static final TextStyle displayMedium = _baseStyle.copyWith(
    fontSize: 45,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -1.0,
  );

  static final TextStyle displaySmall = _baseStyle.copyWith(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.5,
  );

  // Headline styles (for section headers)
  static final TextStyle headlineLarge = _baseStyle.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static final TextStyle headlineMedium = _baseStyle.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static final TextStyle headlineSmall = _baseStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // Title styles (for component titles)
  static final TextStyle titleLarge = _baseStyle.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static final TextStyle titleMedium = _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static final TextStyle titleSmall = _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );

  // Label styles (for buttons, form labels)
  static final TextStyle labelLarge = _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static final TextStyle labelMedium = _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
  );

  static final TextStyle labelSmall = _baseStyle.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
  );

  // Body styles (for content text)
  static final TextStyle bodyLarge = _baseStyle.copyWith(
    fontSize: 16,
    height: 1.5,
  );

  static final TextStyle bodyMedium = _baseStyle.copyWith(
    fontSize: 14,
    height: 1.5,
  );

  static final TextStyle bodySmall = _baseStyle.copyWith(
    fontSize: 12,
    height: 1.4,
  );

  // Specialized styles for avatar interface
  static final TextStyle avatarWelcome = displaySmall.copyWith(
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle avatarMessage = bodyLarge.copyWith(
    color: AppColors.textPrimary,
    height: 1.6,
  );

  static final TextStyle expertRole = bodyMedium.copyWith(
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle conversationMessage = bodyMedium.copyWith(
    height: 1.5,
  );

  static final TextStyle suggestionChip = labelMedium.copyWith(
    color: AppColors.primary,
    fontWeight: FontWeight.w500,
  );

  // Light theme text theme
  static final TextTheme lightTextTheme = TextTheme(
    displayLarge: displayLarge.copyWith(color: AppColors.textPrimary),
    displayMedium: displayMedium.copyWith(color: AppColors.textPrimary),
    displaySmall: displaySmall.copyWith(color: AppColors.textPrimary),
    headlineLarge: headlineLarge.copyWith(color: AppColors.textPrimary),
    headlineMedium: headlineMedium.copyWith(color: AppColors.textPrimary),
    headlineSmall: headlineSmall.copyWith(color: AppColors.textPrimary),
    titleLarge: titleLarge.copyWith(color: AppColors.textPrimary),
    titleMedium: titleMedium.copyWith(color: AppColors.textPrimary),
    titleSmall: titleSmall.copyWith(color: AppColors.textSecondary),
    labelLarge: labelLarge.copyWith(color: AppColors.textPrimary),
    labelMedium: labelMedium.copyWith(color: AppColors.textSecondary),
    labelSmall: labelSmall.copyWith(color: AppColors.textTertiary),
    bodyLarge: bodyLarge.copyWith(color: AppColors.textPrimary),
    bodyMedium: bodyMedium.copyWith(color: AppColors.textSecondary),
    bodySmall: bodySmall.copyWith(color: AppColors.textTertiary),
  );

  // Dark theme text theme
  static final TextTheme darkTextTheme = TextTheme(
    displayLarge: displayLarge.copyWith(color: AppColors.darkTextPrimary),
    displayMedium: displayMedium.copyWith(color: AppColors.darkTextPrimary),
    displaySmall: displaySmall.copyWith(color: AppColors.darkTextPrimary),
    headlineLarge: headlineLarge.copyWith(color: AppColors.darkTextPrimary),
    headlineMedium: headlineMedium.copyWith(color: AppColors.darkTextPrimary),
    headlineSmall: headlineSmall.copyWith(color: AppColors.darkTextPrimary),
    titleLarge: titleLarge.copyWith(color: AppColors.darkTextPrimary),
    titleMedium: titleMedium.copyWith(color: AppColors.darkTextPrimary),
    titleSmall: titleSmall.copyWith(color: AppColors.darkTextSecondary),
    labelLarge: labelLarge.copyWith(color: AppColors.darkTextPrimary),
    labelMedium: labelMedium.copyWith(color: AppColors.darkTextSecondary),
    labelSmall: labelSmall.copyWith(color: AppColors.darkTextTertiary),
    bodyLarge: bodyLarge.copyWith(color: AppColors.darkTextPrimary),
    bodyMedium: bodyMedium.copyWith(color: AppColors.darkTextSecondary),
    bodySmall: bodySmall.copyWith(color: AppColors.darkTextTertiary),
  );
}

// lib/core/theme/app_spacing.dart
// Consistent spacing system

class AppSpacing {
  // Base spacing unit
  static const double unit = 8.0;

  // Spacing scale
  static const double xs = unit * 0.5; // 4px
  static const double sm = unit * 1; // 8px
  static const double md = unit * 2; // 16px
  static const double lg = unit * 3; // 24px
  static const double xl = unit * 4; // 32px
  static const double xxl = unit * 6; // 48px
  static const double xxxl = unit * 8; // 64px

  // Common padding values
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  // Horizontal padding
  static const EdgeInsets paddingHorizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(horizontal: lg);

  // Vertical padding
  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(vertical: lg);

  // Common margin values
  static const EdgeInsets marginXS = EdgeInsets.all(xs);
  static const EdgeInsets marginSM = EdgeInsets.all(sm);
  static const EdgeInsets marginMD = EdgeInsets.all(md);
  static const EdgeInsets marginLG = EdgeInsets.all(lg);

  // Border radius values
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
}