// FILE PATH: lib/features/avatar/providers/avatar_state_provider.dart
// Avatar State Provider - Central state management for avatar interface
// Referenced in avatar_home_screen.dart for avatar behavior and state

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../models/expert_personality.dart';
import '../models/conversation_context.dart';
import '../services/expert_personality_engine.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/constants/text_constants.dart';

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

/// Avatar emotional states
enum AvatarEmotion {
  neutral,
  happy,
  focused,
  encouraging,
  serious,
  celebrating,
  welcoming,
  helpful,
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
    DateTime? lastInteraction,
    this.context = const ConversationContext(),
    this.personalityType = ExpertPersonalityType.professional,
    this.confidenceLevel = 1.0,
  }) : lastInteraction = lastInteraction ?? DateTime.now();

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

  /// Get user's preferred greeting based on context
  String get personalizedGreeting {
    if (context.isNewUser) {
      return TextConstants.newUserWelcome;
    } else if (context.conversationCount > 0) {
      return TextConstants.returningUserWelcome.replaceAll(
        'back!', 
        'back, ${context.greetingName}!'
      );
    }
    return TextConstants.welcomeMessage;
  }

  /// Check if avatar should show onboarding hints
  bool get shouldShowOnboarding => context.isNewUser || conversationHistory.isEmpty;

  /// Get contextual suggestions for current state
  List<String> get contextualSuggestions {
    if (shouldShowOnboarding) {
      return TextConstants.getSuggestionsByContext('new_user');
    } else if (context.hasFrameworkPreferences) {
      return TextConstants.getSuggestionsByContext('assessment_mode');
    } else {
      return TextConstants.getSuggestionsByContext('framework_explorer');
    }
  }
}

/// Avatar state notifier for managing avatar behavior
class AvatarStateNotifier extends StateNotifier<AvatarState> {
  final ExpertPersonalityEngine _personalityEngine;
  final AudioService _audioService;
  final StorageService _storageService;

  AvatarStateNotifier(
    this._personalityEngine,
    this._audioService,
    this._storageService,
  ) : super(const AvatarState());

  /// Initialize avatar with user context
  Future<void> initialize() async {
    try {
      // Load saved context if available
      final savedContext = await _storageService.loadConversationContext();
      final savedPersonality = await _storageService.loadExpertPersonality();
      
      // Initialize personality engine
      _personalityEngine.initialize(
        userName: savedContext?.userName,
        companyName: savedContext?.companyName,
        industry: savedContext?.industry,
        primaryFrameworks: savedContext?.primaryFrameworks,
        personalityType: savedPersonality,
      );
      
      // Set initial state
      final initialMessage = _getInitialMessage(savedContext);
      
      state = state.copyWith(
        currentState: AvatarStateType.idle,
        currentEmotion: AvatarEmotion.welcoming,
        currentMessage: initialMessage,
        context: savedContext ?? const ConversationContext(),
        personalityType: savedPersonality ?? ExpertPersonalityType.professional,
        lastInteraction: DateTime.now(),
      );
      
      // Speak welcome message if voice is enabled
      if (state.voiceEnabled) {
        await _audioService.speak(initialMessage);
      }
      
      if (kDebugMode) {
        print('🤖 Avatar initialized: ${state.name} (${state.personalityType})');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Avatar initialization error: $e');
      }
      
      // Fallback to default state
      state = state.copyWith(
        currentMessage: TextConstants.welcomeMessage,
        currentEmotion: AvatarEmotion.welcoming,
      );
    }
  }

  /// Initialize with onboarding flow
  Future<void> initializeWithOnboarding() async {
    await initialize();
    
    state = state.copyWith(
      showHints: true,
      currentMessage: TextConstants.newUserWelcome,
      currentEmotion: AvatarEmotion.welcoming,
    );
    
    // Show extended onboarding hints
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        state = state.copyWith(
          currentMessage: "I'd love to learn about your company and compliance needs. What brings you here today?",
        );
      }
    });
  }

  /// Process user message and generate response
  Future<void> processUserMessage(String message) async {
    if (state.isProcessing) return;

    try {
      // Update state to processing
      state = state.copyWith(
        isProcessing: true,
        currentState: AvatarStateType.processing,
        currentEmotion: AvatarEmotion.focused,
        currentMessage: TextConstants.getRandomFromList(TextConstants.processingMessages),
      );

      // Add to conversation history
      final updatedHistory = [...state.conversationHistory, message];
      
      // Update context with new interaction
      final updatedContext = state.context.incrementConversation();
      
      // Generate expert response
      final response = await _personalityEngine.generateResponse(
        userMessage: message,
        context: updatedContext,
        previousMessages: updatedHistory,
      );

      // Update state with response
      state = state.copyWith(
        isProcessing: false,
        currentState: AvatarStateType.explaining,
        currentEmotion: response.emotion,
        currentMessage: response.content,
        conversationHistory: updatedHistory,
        context: updatedContext,
        confidenceLevel: response.confidence,
        lastInteraction: DateTime.now(),
      );

      // Save updated context
      await _storageService.saveConversationContext(updatedContext);

      // Speak response if voice is enabled
      if (state.voiceEnabled) {
        state = state.copyWith(currentState: AvatarStateType.speaking);
        await _audioService.speak(response.content);
        
        if (mounted) {
          state = state.copyWith(currentState: AvatarStateType.idle);
        }
      }

      // Hide hints after first interaction
      if (state.showHints && updatedHistory.length > 1) {
        state = state.copyWith(showHints: false);
      }

      if (kDebugMode) {
        print('🤖 Avatar processed message: ${message.substring(0, 50)}...');
        print('   Response confidence: ${(response.confidence * 100).toStringAsFixed(1)}%');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error processing user message: $e');
      }
      
      // Reset to error state
      state = state.copyWith(
        isProcessing: false,
        currentState: AvatarStateType.concerned,
        currentEmotion: AvatarEmotion.concerned,
        currentMessage: TextConstants.genericError,
      );
    }
  }

  /// Toggle voice output
  Future<void> toggleVoice() async {
    final newVoiceEnabled = !state.voiceEnabled;
    
    state = state.copyWith(voiceEnabled: newVoiceEnabled);
    
    // Save preference
    await _storageService.updateUserPreference('voice_enabled', newVoiceEnabled);
    
    // Provide feedback
    final message = newVoiceEnabled 
        ? "Voice output enabled. I'll speak my responses out loud."
        : "Voice output disabled. I'll communicate through text only.";
    
    state = state.copyWith(
      currentMessage: message,
      currentEmotion: AvatarEmotion.helpful,
    );
    
    if (kDebugMode) {
      print('🔊 Voice output ${newVoiceEnabled ? "enabled" : "disabled"}');
    }
  }

  /// Toggle voice input
  Future<void> toggleVoiceInput() async {
    final newVoiceInputEnabled = !state.voiceInputEnabled;
    
    state = state.copyWith(
      voiceInputEnabled: newVoiceInputEnabled,
      currentState: newVoiceInputEnabled ? AvatarStateType.listening : AvatarStateType.idle,
    );
    
    if (newVoiceInputEnabled) {
      state = state.copyWith(
        currentMessage: TextConstants.voicePrompt,
        currentEmotion: AvatarEmotion.focused,
      );
    }
    
    if (kDebugMode) {
      print('🎤 Voice input ${newVoiceInputEnabled ? "enabled" : "disabled"}');
    }
  }

  /// Update avatar emotion based on context
  void updateEmotion(AvatarEmotion emotion) {
    state = state.copyWith(
      currentEmotion: emotion,
      lastInteraction: DateTime.now(),
    );
  }

  /// Update conversation context
  Future<void> updateContext(ConversationContext newContext) async {
    state = state.copyWith(
      context: newContext,
      lastInteraction: DateTime.now(),
    );
    
    await _storageService.saveConversationContext(newContext);
  }

  /// Change expert personality
  Future<void> changePersonality(ExpertPersonalityType personalityType) async {
    state = state.copyWith(
      personalityType: personalityType,
      lastInteraction: DateTime.now(),
    );
    
    // Reinitialize personality engine
    _personalityEngine.initialize(
      userName: state.context.userName,
      companyName: state.context.companyName,
      industry: state.context.industry,
      primaryFrameworks: state.context.primaryFrameworks,
      personalityType: personalityType,
    );
    
    // Save preference
    await _storageService.saveExpertPersonality(personalityType);
    
    // Update message to reflect personality change
    final personalityName = personalityType.toString().split('.').last;
    state = state.copyWith(
      currentMessage: "I've adjusted my communication style to be more $personalityName. How does this feel?",
      currentEmotion: AvatarEmotion.helpful,
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

  /// Handle voice input result
  Future<void> handleVoiceInput(String transcript) async {
    if (transcript.trim().isNotEmpty) {
      await processUserMessage(transcript);
    }
    
    // Reset voice input state
    state = state.copyWith(
      voiceInputEnabled: false,
      currentState: AvatarStateType.idle,
    );
  }

  // Private helper methods

  String _getInitialMessage(ConversationContext? context) {
    if (context == null || context.isNewUser) {
      return TextConstants.newUserWelcome;
    } else if (context.userName != null) {
      return "Welcome back, ${context.userName}! Ready to continue building your compliance program?";
    } else {
      return TextConstants.welcomeMessage;
    }
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

/// Provider for checking if avatar is speaking
final avatarSpeakingProvider = Provider<bool>((ref) {
  final avatarState = ref.watch(avatarStateProvider);
  return avatarState.currentState == AvatarStateType.speaking;
});

/// Provider for checking if avatar needs onboarding
final needsOnboardingProvider = Provider<bool>((ref) {
  final avatarState = ref.watch(avatarStateProvider);
  return avatarState.shouldShowOnboarding;
});

/// Provider for contextual suggestions
final contextualSuggestionsProvider = Provider<List<String>>((ref) {
  final avatarState = ref.watch(avatarStateProvider);
  return avatarState.contextualSuggestions;
});

/// Provider for avatar confidence level (for UI indicators)
final avatarConfidenceProvider = Provider<double>((ref) {
  final avatarState = ref.watch(avatarStateProvider);
  return avatarState.confidenceLevel;
});