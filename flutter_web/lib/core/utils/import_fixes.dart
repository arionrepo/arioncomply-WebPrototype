// FILE PATH: lib/core/utils/import_fixes.dart
// Consolidated fixes for missing imports and types

// Export all the commonly used types and widgets
export '../models/emotion_types.dart';
export '../theme/app_colors.dart';
export '../constants/text_constants.dart';
export '../services/ai_transparency_service.dart';
export '../../shared/widgets/responsive_layout.dart';
export '../../shared/utils/validation_utils.dart';

// Re-export Flutter essentials
export 'package:flutter/material.dart';
export 'package:flutter/foundation.dart';
export 'package:flutter_riverpod/flutter_riverpod.dart';

// Missing constants and utilities
const bool kDebugMode = true;

// Missing enum values
enum MessageSender {
  user,
  avatar,
  system,
}

enum HapticFeedbackType {
  lightImpact,
  mediumImpact,
  heavyImpact,
  selectionClick,
}

// Utility class for haptic feedback
class HapticUtils {
  static void triggerFeedback(HapticFeedbackType type) {
    // Platform-specific implementation would go here
    if (kDebugMode) {
      print('🔄 Haptic feedback: $type');
    }
  }
}

// Extension methods for convenience
extension StringExtensions on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

extension ListExtensions<T> on List<T> {
  T? get firstOrNull {
    return isEmpty ? null : first;
  }
  
  T? get lastOrNull {
    return isEmpty ? null : last;
  }
}