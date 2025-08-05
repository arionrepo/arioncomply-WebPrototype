// FILE PATH: lib/core/models/emotion_types.dart
// Unified emotion types to resolve mismatches between ExpertEmotion and AvatarEmotion

/// Expert emotion states (from personality engine)
enum ExpertEmotion {
  neutral,
  happy,
  focused,
  encouraging,
  serious,
  concerned,
  celebrating,
  welcoming,
  helpful,
}

/// Avatar emotion states (for display)
enum AvatarEmotion {
  neutral,
  happy,
  focused,
  encouraging,
  serious,
  concerned,
  celebrating,
  welcoming,
  helpful,
}

/// Utility class to convert between emotion types
class EmotionConverter {
  /// Convert ExpertEmotion to AvatarEmotion
  static AvatarEmotion expertToAvatar(ExpertEmotion expert) {
    switch (expert) {
      case ExpertEmotion.neutral:
        return AvatarEmotion.neutral;
      case ExpertEmotion.happy:
        return AvatarEmotion.happy;
      case ExpertEmotion.focused:
        return AvatarEmotion.focused;
      case ExpertEmotion.encouraging:
        return AvatarEmotion.encouraging;
      case ExpertEmotion.serious:
        return AvatarEmotion.serious;
      case ExpertEmotion.concerned:
        return AvatarEmotion.concerned;
      case ExpertEmotion.celebrating:
        return AvatarEmotion.celebrating;
      case ExpertEmotion.welcoming:
        return AvatarEmotion.welcoming;
      case ExpertEmotion.helpful:
        return AvatarEmotion.helpful;
    }
  }

  /// Convert AvatarEmotion to ExpertEmotion
  static ExpertEmotion avatarToExpert(AvatarEmotion avatar) {
    switch (avatar) {
      case AvatarEmotion.neutral:
        return ExpertEmotion.neutral;
      case AvatarEmotion.happy:
        return ExpertEmotion.happy;
      case AvatarEmotion.focused:
        return ExpertEmotion.focused;
      case AvatarEmotion.encouraging:
        return ExpertEmotion.encouraging;
      case AvatarEmotion.serious:
        return ExpertEmotion.serious;
      case AvatarEmotion.concerned:
        return ExpertEmotion.concerned;
      case AvatarEmotion.celebrating:
        return ExpertEmotion.celebrating;
      case AvatarEmotion.welcoming:
        return ExpertEmotion.welcoming;
      case AvatarEmotion.helpful:
        return ExpertEmotion.helpful;
    }
  }
}