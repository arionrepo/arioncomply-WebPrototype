// FILE PATH: lib/features/avatar/models/avatar_state.dart
// Avatar state models - Missing models referenced in avatar_status_indicator.dart

/// Avatar current operational state
enum AvatarCurrentState {
  idle,
  listening,
  thinking,
  processing,
  speaking,
  error,
}

/// Avatar mood states for visual representation
enum AvatarMood {
  neutral,
  happy,
  focused,
  encouraging,
  serious,
  concerned,
}

/// Configuration for status display
class StatusConfig {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;

  const StatusConfig({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
  });
}

/// Configuration for mood display  
class MoodConfig {
  final IconData icon;
  final String label;
  final Color color;
  final String description;

  const MoodConfig({
    required this.icon,
    required this.label,
    required this.color,
    required this.description,
  });
}

/// Main avatar state model
class AvatarState {
  final AvatarCurrentState currentState;
  final AvatarMood mood;
  final String currentMessage;
  final bool isProcessing;
  final DateTime lastUpdate;

  const AvatarState({
    this.currentState = AvatarCurrentState.idle,
    this.mood = AvatarMood.neutral,
    this.currentMessage = '',
    this.isProcessing = false,
    DateTime? lastUpdate,
  }) : lastUpdate = lastUpdate ?? const DateTime.fromMillisecondsSinceEpoch(0);

  AvatarState copyWith({
    AvatarCurrentState? currentState,
    AvatarMood? mood,
    String? currentMessage,
    bool? isProcessing,
    DateTime? lastUpdate,
  }) {
    return AvatarState(
      currentState: currentState ?? this.currentState,
      mood: mood ?? this.mood,
      currentMessage: currentMessage ?? this.currentMessage,
      isProcessing: isProcessing ?? this.isProcessing,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvatarState &&
          runtimeType == other.runtimeType &&
          currentState == other.currentState &&
          mood == other.mood &&
          currentMessage == other.currentMessage &&
          isProcessing == other.isProcessing;

  @override
  int get hashCode =>
      currentState.hashCode ^
      mood.hashCode ^
      currentMessage.hashCode ^
      isProcessing.hashCode;
}