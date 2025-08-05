// FILE PATH: lib/core/theme/app_text_styles.dart
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