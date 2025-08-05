// FILE PATH: lib/features/avatar/providers/conversation_provider.dart
// Conversation Provider - Fixed version for demo

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

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

/// Conversation state
class ConversationState {
  final List<Map<String, dynamic>> messages;
  final bool isActive;
  final bool isListening;
  final bool isThinking;
  final String? currentTranscript;
  final String? lastError;
  final String? currentFramework;
  final int? assessmentStep;
  final double assessmentProgress;
  final bool isDemoMode;
  final DateTime lastUpdate;

  const ConversationState({
    this.messages = const [],
    this.isActive = false,
    this.isListening = false,
    this.isThinking = false,
    this.currentTranscript,
    this.lastError,
    this.currentFramework,
    this.assessmentStep,
    this.assessmentProgress = 0.0,
    this.isDemoMode = false,
    DateTime? lastUpdate,
  }) : lastUpdate = lastUpdate ?? const DateTime.fromMillisecondsSinceEpoch(0);

  ConversationState copyWith({
    List<Map<String, dynamic>>? messages,
    bool? isActive,
    bool? isListening,
    bool? isThinking,
    String? currentTranscript,
    String? lastError,
    String? currentFramework,
    int? assessmentStep,
    double? assessmentProgress,
    bool? isDemoMode,
    DateTime? lastUpdate,
  }) {
    return ConversationState(
      messages: messages ?? this.messages,
      isActive: isActive ?? this.isActive,
      isListening: isListening ?? this.isListening,
      isThinking: isThinking ?? this.isThinking,
      currentTranscript: currentTranscript ?? this.currentTranscript,
      lastError: lastError ?? this.lastError,
      currentFramework: currentFramework ?? this.currentFramework,
      assessmentStep: assessmentStep ?? this.assessmentStep,
      assessmentProgress: assessmentProgress ?? this.assessmentProgress,
      isDemoMode: isDemoMode ?? this.isDemoMode,
      lastUpdate: lastUpdate ?? DateTime.now(),
    );
  }

  int get messageCount => messages.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationState &&
          runtimeType == other.runtimeType &&
          messages.length == other.messages.length &&
          isActive == other.isActive &&
          isListening == other.isListening &&
          isThinking == other.isThinking;

  @override
  int get hashCode =>
      messages.length.hashCode ^
      isActive.hashCode ^
      isListening.hashCode ^
      isThinking.hashCode;
}

/// Conversation State Notifier
class ConversationNotifier extends StateNotifier<ConversationState> {
  final ExpertPersonalityEngine _personalityEngine;
  final AudioService _audioService;
  final StorageService _storageService;
  final Uuid _uuid = const Uuid();

  ConversationNotifier(
    this._personalityEngine,
    this._audioService,
    this._storageService,
  ) : super(const ConversationState()) {
    _initialize();
  }

  bool get mounted => true; // Simple mounted check for demo

  /// Initialize conversation
  Future<void> _initialize() async {
    try {
      final history = await _storageService.loadConversationHistory();
      
      state = state.copyWith(
        messages: history,
        lastUpdate: DateTime.now(),
      );

      if (kDebugMode) {
        print('💬 Conversation initialized with ${history.length} messages');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing conversation: $e');
      }
    }
  }

  /// Start conversation
  void startConversation() {
    state = state.copyWith(
      isActive: true,
      lastUpdate: DateTime.now(),
    );
  }

  /// End conversation
  void endConversation() {
    state = state.copyWith(
      isActive: false,
      isListening: false,
      isThinking: false,
      currentTranscript: null,
      lastUpdate: DateTime.now(),
    );
  }

  /// Add user message
  Future<void> addUserMessage(String content) async {
    final message = {
      'id': _uuid.v4(),
      'content': content,
      'sender': 'user',
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'text',
    };

    state = state.copyWith(
      messages: [...state.messages, message],
      isThinking: true,
      lastUpdate: DateTime.now(),
    );

    await _processUserMessage(content);
  }

  /// Process user message and generate response
  Future<void> _processUserMessage(String content) async {
    try {
      // Generate response
      final response = await _personalityEngine.generateResponse(
        content,
        ExpertPersonalityType.professional,
      );

      await _addAvatarMessage(response.content, {
        'emotion': response.emotion.toString(),
        'confidence': response.confidence,
        'responseType': response.responseType.toString(),
      });

      state = state.copyWith(
        isThinking: false,
        lastUpdate: DateTime.now(),
      );

    } catch (e) {
      await _addAvatarMessage(
        "I'm having trouble processing that. Could you try rephrasing?",
        {'error': true},
      );
      
      state = state.copyWith(
        isThinking: false,
        lastError: e.toString(),
        lastUpdate: DateTime.now(),
      );

      if (kDebugMode) {
        print('❌ Error processing message: $e');
      }
    }
  }

  /// Add avatar message
  Future<void> _addAvatarMessage(String content, Map<String, dynamic>? metadata) async {
    final message = {
      'id': _uuid.v4(),
      'content': content,
      'sender': 'avatar',
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'text',
      if (metadata != null) ...metadata,
    };

    state = state.copyWith(
      messages: [...state.messages, message],
      lastUpdate: DateTime.now(),
    );

    // Save conversation
    await _saveConversation();
  }

  /// Start listening for voice input
  void startListening() {
    state = state.copyWith(
      isListening: true,
      currentTranscript: null,
      lastUpdate: DateTime.now(),
    );
  }

  /// Stop listening for voice input
  void stopListening() {
    state = state.copyWith(
      isListening: false,
      lastUpdate: DateTime.now(),
    );
  }

  /// Update transcript during voice input
  void updateTranscript(String transcript) {
    state = state.copyWith(
      currentTranscript: transcript,
      lastUpdate: DateTime.now(),
    );
  }

  /// Handle voice input result
  Future<void> handleVoiceResult(String transcript) async {
    stopListening();
    if (transcript.trim().isNotEmpty) {
      await addUserMessage(transcript);
    }
  }

  /// Clear conversation
  Future<void> clearConversation() async {
    state = const ConversationState();
    await _storageService.clearConversationHistory();
    
    if (kDebugMode) {
      print('🧹 Conversation cleared');
    }
  }

  /// Save conversation to storage
  Future<void> _saveConversation() async {
    try {
      await _storageService.saveConversationHistory(state.messages);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving conversation: $e');
      }
    }
  }

  /// Set current framework
  void setFramework(String framework) {
    state = state.copyWith(
      currentFramework: framework,
      lastUpdate: DateTime.now(),
    );
  }

  /// Start assessment
  Future<void> startAssessment() async {
    state = state.copyWith(
      assessmentStep: 1,
      assessmentProgress: 0.0,
      lastUpdate: DateTime.now(),
    );

    await _addAssessmentQuestion();
  }

  /// Add assessment question
  Future<void> _addAssessmentQuestion() async {
    final questions = [
      "Let's start with your current security posture. Do you have multi-factor authentication enabled for all employees?",
      "How do you currently manage user permissions and access reviews?",
      "Tell me about your data handling practices. How do you classify and protect sensitive information?",
      "What monitoring and logging systems do you have in place?",
    ];

    final currentStep = state.assessmentStep ?? 1;
    if (currentStep <= questions.length) {
      await _addAvatarMessage(
        questions[currentStep - 1],
        {'assessment_question': true, 'step': currentStep}
      );
    }
  }

  /// Progress assessment
  Future<void> progressAssessment() async {
    final currentStep = (state.assessmentStep ?? 1) + 1;
    final progress = currentStep / 4.0; // 4 total questions

    state = state.copyWith(
      assessmentStep: currentStep,
      assessmentProgress: progress.clamp(0.0, 1.0),
      lastUpdate: DateTime.now(),
    );

    if (currentStep <= 4) {
      await _addAssessmentQuestion();
    } else {
      await _completeAssessment();
    }
  }

  /// Complete assessment
  Future<void> _completeAssessment() async {
    await _addAvatarMessage(
      "Great! I've gathered enough information to provide personalized recommendations. Based on your responses, I can see several areas where we can strengthen your compliance posture.",
      {'assessment_complete': true}
    );

    state = state.copyWith(
      assessmentProgress: 1.0,
      lastUpdate: DateTime.now(),
    );
  }

  /// Toggle demo mode
  void toggleDemoMode() {
    state = state.copyWith(
      isDemoMode: !state.isDemoMode,
      lastUpdate: DateTime.now(),
    );
  }
}

/// Provider for conversation state
final conversationProvider = StateNotifierProvider<ConversationNotifier, ConversationState>((ref) {
  return ConversationNotifier(
    ExpertPersonalityEngine.instance,
    AudioService.instance,
    StorageService.instance,
  );
});

/// Provider for checking if conversation is active
final conversationActiveProvider = Provider<bool>((ref) {
  final conversation = ref.watch(conversationProvider);
  return conversation.isActive;
});

/// Provider for current transcript during voice input
final currentTranscriptProvider = Provider<String?>((ref) {
  final conversation = ref.watch(conversationProvider);
  return conversation.currentTranscript;
});

/// Provider for conversation message count
final messageCountProvider = Provider<int>((ref) {
  final conversation = ref.watch(conversationProvider);
  return conversation.messageCount;
});

/// Provider for last conversation error (single definition)
final conversationErrorProvider = Provider<String?>((ref) {
  final conversation = ref.watch(conversationProvider);
  return conversation.lastError;
});

/// Provider for current selected framework
final currentFrameworkProvider = Provider<String?>((ref) {
  final conversation = ref.watch(conversationProvider);
  return conversation.currentFramework;
});

/// Provider for assessment progress
final assessmentProgressProvider = Provider<double>((ref) {
  final conversation = ref.watch(conversationProvider);
  return conversation.assessmentProgress;
});

/// Provider for demo mode state
final isDemoModeProvider = Provider<bool>((ref) {
  final conversation = ref.watch(conversationProvider);
  return conversation.isDemoMode;
});