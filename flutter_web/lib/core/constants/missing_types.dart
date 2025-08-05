// FILE PATH: lib/core/constants/missing_types.dart
// Missing types and enums referenced throughout the project

import 'package:flutter/material.dart';
import '../models/avatar_state.dart';

// Haptic feedback types (simplified version)
enum HapticFeedbackType {
  lightImpact,
  mediumImpact,
  heavyImpact,
  selectionClick,
}

/// Message sender types for chat
enum MessageSender {
  user,
  avatar,
  system,
}

/// Expert response types
enum ExpertResponseType {
  guidance,
  explanation,
  warning,
  celebration,
  question,
}

/// Celebrating emotion constant for avatar
extension ExpertEmotionExtension on ExpertEmotion {
  static const ExpertEmotion celebrating = ExpertEmotion.happy;
}

/// Simple debug flag replacement
const bool kDebugMode = true;

/// Utility class for haptic feedback
class HapticUtils {
  static void triggerFeedback(HapticFeedbackType type) {
    // Platform-specific haptic feedback would go here
    // For now, just a placeholder
  }
}

/// Avatar provider export - temporary fix
// This should be moved to proper provider files once they're fixed
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Temporary avatar state provider until the main one is fixed
final avatarStateProvider = StateNotifierProvider<AvatarStateNotifier, AvatarState>((ref) {
  return AvatarStateNotifier();
});

class AvatarStateNotifier extends StateNotifier<AvatarState> {
  AvatarStateNotifier() : super(const AvatarState());

  void updateState(AvatarCurrentState newState) {
    state = state.copyWith(currentState: newState);
  }

  void updateMood(AvatarMood newMood) {
    state = state.copyWith(mood: newMood);
  }

  void setProcessing(bool processing) {
    state = state.copyWith(isProcessing: processing);
  }
}

/// Required imports for avatar_state.dart
import 'package:flutter/material.dart';

/// Temporary conversation interface widget - placeholder
class ConversationInterface extends StatelessWidget {
  final bool isEnabled;
  final Function(String)? onMessage;
  final VoidCallback? onVoiceToggle;

  const ConversationInterface({
    Key? key,
    this.isEnabled = true,
    this.onMessage,
    this.onVoiceToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('Conversation Interface Placeholder'),
          if (onMessage != null)
            ElevatedButton(
              onPressed: () => onMessage?.call('Test message'),
              child: const Text('Send Test Message'),
            ),
          if (onVoiceToggle != null)
            ElevatedButton(
              onPressed: onVoiceToggle,
              child: const Text('Toggle Voice'),
            ),
        ],
      ),
    );
  }
}