// FILE PATH: lib/features/avatar/providers/avatar_state_provider.dart
// Avatar State Provider - Fixed version for demo

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

// Core imports
import '../../../core/models/emotion_types.dart';
import '../../../core/constants/text_constants.dart';
import '../../../core/services/storage_service.dart';

// Models
import '../models/expert_personality.dart';
import '../models/conversation_context.dart';

// Services
import '../services/expert_personality_engine.dart';
import '../../../core/services/audio_service.dart';

/// Avatar state for the interface
enum AvatarStateType {
  idle,
  listening,
  processing,
  speaking,
  explaining,
  celebrating,
  concerned,
}

/// Complete avatar state
class AvatarState {
  final String name;
  final String role;
  final AvatarStateType currentState;
  final AvatarEmotion currentEmotion;
  final String currentMessage;
  final bool isProcessing;
  final bool voiceEnabled;
  final bool voiceInputEnabled;
  final bool showHints;
  final List<String> conversationHistory;
  final DateTime lastInteraction;
  final ConversationContext context;
  final ExpertPersonalityType personalityType;
  final double confidenceLevel;

  const AvatarState({
    this.name = 'Alex',
    this.role = 'Senior Compliance Expert',
    this.currentState = AvatarStateType.idle,
    this.currentEmotion = AvatarEmotion.neutral,
    this.currentMessage = '',
    this.isProcessing = false,
    this.voiceEnabled = true,
    this.voiceInputEnabled = false,
    this.showHints = true,
    this.conversationHistory = const [],
    required this.lastInteraction,
    this.context = const ConversationContext(),
    this.personalityType = ExpertPersonalityType.professional,
    this.confidenceLevel = 1.0,
  });

  AvatarState copyWith({
    String? name,
    String? role,
    AvatarStateType? currentState,
    AvatarEmotion? currentEmotion,
    String? currentMessage,
    bool? isProcessing,
    bool? voiceEnabled,
    bool? voiceInputEnabled,
    bool? showHints,
    List<String>? conversationHistory,
    DateTime? lastInteraction,
    ConversationContext? context,
    ExpertPersonalityType? personalityType,
    double? confidenceLevel,
  }) {
    return AvatarState(
      name: name ?? this.name,
      role: role ?? this.role,
      currentState: currentState ?? this.currentState,
      currentEmotion: currentEmotion ?? this.currentEmotion,
      currentMessage: currentMessage ?? this.currentMessage,
      isProcessing: isProcessing ?? this.isProcessing,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      voiceInputEnabled: voiceInputEnabled ?? this.voiceInputEnabled,
      showHints: showHints ?? this.showHints,
      conversationHistory: conversationHistory ?? this.conversationHistory,
      lastInteraction: lastInteraction ?? this.lastInteraction,
      context: context ?? this.context,
      personalityType: personalityType ?? this.personalityType,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvatarState &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          currentState == other.currentState &&
          currentEmotion == other.currentEmotion &&
          isProcessing == other.isProcessing;

  @override
  int get hashCode =>
      name.hashCode ^
      currentState.hashCode ^
      currentEmotion.hashCode ^
      isProcessing.hashCode;
}

/// Avatar State Notifier
class AvatarStateNotifier extends StateNotifier<AvatarState> {
  final ExpertPersonalityEngine _personalityEngine;
  final AudioService _audioService;
  final StorageService _storageService;

  AvatarStateNotifier(
    this._personalityEngine,
    this._audioService,
    this._storageService,
  ) : super(AvatarState(
          lastInteraction: DateTime.now(),
          currentMessage: TextConstants.welcomeMessage,
          currentEmotion: AvatarEmotion.welcoming,
        )) {
    _initialize();
  }

  bool get mounted => true; // Simple mounted check for demo

  /// Initialize the avatar state
  Future<void> _initialize() async {
    try {
      // Load previous conversation context if available
      final history = await _storageService.loadConversationHistory();
      final lastInteraction = DateTime.now();
      
      state = state.copyWith(
        conversationHistory: history.map((msg) => msg['content']?.toString() ?? '').toList(),
        lastInteraction: lastInteraction,
        currentMessage: history.isEmpty 
            ? TextConstants.welcomeMessage 
            : "Welcome back! Ready to continue where we left off?",
        currentEmotion: history.isEmpty 
            ? AvatarEmotion.welcoming 
            : AvatarEmotion.happy,
      );

      if (kDebugMode) {
        print('🤖 Avatar initialized with ${history.length} previous messages');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing avatar state: $e');
      }
      // Fallback to default state
      state = state.copyWith(
        currentMessage: TextConstants.welcomeMessage,
        currentEmotion: AvatarEmotion.welcoming,
      );
    }
  }

  /// Update avatar state
  void updateState(AvatarStateType newState) {
    state = state.copyWith(
      currentState: newState,
      lastInteraction: DateTime.now(),
    );
  }

  /// Update avatar emotion
  void updateEmotion(AvatarEmotion newEmotion) {
    state = state.copyWith(
      currentEmotion: newEmotion,
      lastInteraction: DateTime.now(),
    );
  }

  /// Set processing state
  void setProcessing(bool processing) {
    state = state.copyWith(
      isProcessing: processing,
      currentState: processing ? AvatarStateType.processing : AvatarStateType.idle,
      lastInteraction: DateTime.now(),
    );
  }

  /// Update current message
  void updateMessage(String message) {
    state = state.copyWith(
      currentMessage: message,
      lastInteraction: DateTime.now(),
    );
  }

  /// Toggle voice input
  void toggleVoiceInput() {
    final newVoiceState = !state.voiceInputEnabled;
    state = state.copyWith(
      voiceInputEnabled: newVoiceState,
      currentState: newVoiceState ? AvatarStateType.listening : AvatarStateType.idle,
      lastInteraction: DateTime.now(),
    );
  }

  /// Process user message
  Future<void> processUserMessage(String message) async {
    if (message.trim().isEmpty) return;

    try {
      // Update state to processing
      setProcessing(true);
      
      // Add user message to history
      final updatedHistory = [...state.conversationHistory, message];
      state = state.copyWith(
        conversationHistory: updatedHistory,
        currentState: AvatarStateType.thinking,
      );

      // Get response from personality engine
      final response = await _personalityEngine.generateResponse(
        message,
        state.personalityType,
      );

      // Convert expert emotion to avatar emotion
      final avatarEmotion = EmotionConverter.expertToAvatar(response.emotion);

      // Update with response
      state = state.copyWith(
        currentMessage: response.content,
        currentEmotion: avatarEmotion,
        currentState: AvatarStateType.speaking,
        conversationHistory: [...updatedHistory, response.content],
        isProcessing: false,
        lastInteraction: DateTime.now(),
      );

      // Save conversation
      await _saveConversation();

      // Return to idle after speaking
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          state = state.copyWith(
            currentState: AvatarStateType.idle,
            currentEmotion: AvatarEmotion.helpful,
          );
        }
      });

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error processing message: $e');
      }
      
      state = state.copyWith(
        currentMessage: "I'm having trouble processing that. Could you try rephrasing?",
        currentEmotion: AvatarEmotion.concerned,
        currentState: AvatarStateType.idle,
        isProcessing: false,
        lastInteraction: DateTime.now(),
      );
    }
  }

  /// Save current conversation
  Future<void> _saveConversation() async {
    try {
      final messages = state.conversationHistory
          .asMap()
          .entries
          .map((entry) => {
                'id': entry.key.toString(),
                'content': entry.value,
                'timestamp': DateTime.now().toIso8601String(),
                'sender': entry.key % 2 == 0 ? 'user' : 'avatar',
              })
          .toList();

      await _storageService.saveConversationHistory(messages);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving conversation: $e');
      }
    }
  }

  /// Change personality type
  void changePersonality(ExpertPersonalityType personalityType) {
    state = state.copyWith(
      personalityType: personalityType,
      currentMessage: "I've adjusted my communication style. How can I help you?",
      currentEmotion: AvatarEmotion.helpful,
      lastInteraction: DateTime.now(),
    );
    
    if (kDebugMode) {
      print('🎭 Personality changed to: $personalityType');
    }
  }

  /// Clear conversation and reset
  Future<void> clearConversation() async {
    state = state.copyWith(
      conversationHistory: [],
      currentMessage: TextConstants.welcomeMessage,
      currentState: AvatarStateType.idle,
      currentEmotion: AvatarEmotion.welcoming,
      showHints: true,
      lastInteraction: DateTime.now(),
    );
    
    await _storageService.clearConversationHistory();
    
    if (kDebugMode) {
      print('🧹 Conversation cleared');
    }
  }

  /// Set avatar to celebrating state
  void celebrate(String message) {
    state = state.copyWith(
      currentState: AvatarStateType.celebrating,
      currentEmotion: AvatarEmotion.celebrating,
      currentMessage: message,
      lastInteraction: DateTime.now(),
    );
    
    // Return to idle after celebration
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        state = state.copyWith(
          currentState: AvatarStateType.idle,
          currentEmotion: AvatarEmotion.happy,
        );
      }
    });
  }
}

/// Provider for avatar state
final avatarStateProvider = StateNotifierProvider<AvatarStateNotifier, AvatarState>((ref) {
  return AvatarStateNotifier(
    ExpertPersonalityEngine.instance,
    AudioService.instance,
    StorageService.instance,
  );
});

/// Provider for checking if avatar is processing
final avatarProcessingProvider = Provider<bool>((ref) {
  final avatarState = ref.watch(avatarStateProvider);
  return avatarState.isProcessing;
});

/// Provider for current avatar emotion
final avatarEmotionProvider = Provider<AvatarEmotion>((ref) {
  final avatarState = ref.watch(avatarStateProvider);
  return avatarState.currentEmotion;
});

/// Provider for current avatar state
final avatarCurrentStateProvider = Provider<AvatarStateType>((ref) {
  final avatarState = ref.watch(avatarStateProvider);
  return avatarState.currentState;
});

/// Provider for voice input state
final voiceInputProvider = Provider<bool>((ref) {
  final avatarState = ref.watch(avatarStateProvider);
  return avatarState.voiceInputEnabled;
});