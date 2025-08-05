// FILE PATH: lib/features/avatar/providers/conversation_provider.dart
// Conversation Provider - State management for multi-modal conversation
// Referenced in conversation_interface.dart for conversation flow management

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/conversation_message.dart';
import '../models/expert_personality.dart';
import '../services/expert_personality_engine.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/constants/text_constants.dart';

/// Conversation state for the interface
class ConversationState {
  final List<ConversationMessage> messages;
  final bool isProcessing;
  final bool isListening;
  final bool isVoiceMode;
  final bool showSuggestions;
  final String? currentTranscript;
  final String? lastError;
  final DateTime? lastActivity;
  
  // ADD these new properties:
  final String? currentFramework;        // Current selected framework
  final int? assessmentStep;             // Current assessment step
  final double assessmentProgress;       // Assessment completion (0.0 to 1.0)
  final bool isDemoMode;                 // Whether in demo presentation mode
  final Map<String, dynamic> demoState; // Demo-specific state

  const ConversationState({
    this.messages = const [],
    this.isProcessing = false,
    this.isListening = false,
    this.isVoiceMode = false,
    this.showSuggestions = true,
    this.currentTranscript,
    this.lastError,
    this.lastActivity,
    // ADD these with defaults:
    this.currentFramework,
    this.assessmentStep,
    this.assessmentProgress = 0.0,
    this.isDemoMode = false,
    this.demoState = const {},
  });

ConversationState copyWith({
    List<ConversationMessage>? messages,
    bool? isProcessing,
    bool? isListening,
    bool? isVoiceMode,
    bool? showSuggestions,
    String? currentTranscript,
    String? lastError,
    DateTime? lastActivity,
    // ADD these parameters:
    String? currentFramework,
    int? assessmentStep,
    double? assessmentProgress,
    bool? isDemoMode,
    Map<String, dynamic>? demoState,
  }) {
    return ConversationState(
      messages: messages ?? this.messages,
      isProcessing: isProcessing ?? this.isProcessing,
      isListening: isListening ?? this.isListening,
      isVoiceMode: isVoiceMode ?? this.isVoiceMode,
      showSuggestions: showSuggestions ?? this.showSuggestions,
      currentTranscript: currentTranscript ?? this.currentTranscript,
      lastError: lastError ?? this.lastError,
      lastActivity: lastActivity ?? this.lastActivity,
      // ADD these assignments:
      currentFramework: currentFramework ?? this.currentFramework,
      assessmentStep: assessmentStep ?? this.assessmentStep,
      assessmentProgress: assessmentProgress ?? this.assessmentProgress,
      isDemoMode: isDemoMode ?? this.isDemoMode,
      demoState: demoState ?? this.demoState,
    );
  }

  // Helper getters
  List<ConversationMessage> get userMessages => 
      messages.where((m) => m.type == MessageType.user).toList();
  
  List<ConversationMessage> get avatarMessages => 
      messages.where((m) => m.type == MessageType.avatar).toList();
  
  ConversationMessage? get lastMessage => 
      messages.isNotEmpty ? messages.last : null;
  
  ConversationMessage? get lastUserMessage => 
      userMessages.isNotEmpty ? userMessages.last : null;
  
  ConversationMessage? get lastAvatarMessage => 
      avatarMessages.isNotEmpty ? avatarMessages.last : null;
  
  int get messageCount => messages.length;
  
  bool get hasConversation => messages.isNotEmpty;
  
  bool get isActive => isProcessing || isListening;
  
  bool get shouldShowWelcome => messages.isEmpty;

    /// Whether user has selected a framework
  bool get hasFrameworkSelected => currentFramework != null;
  
  /// Whether assessment is in progress
  bool get isAssessmentActive => assessmentStep != null && assessmentStep! > 0;
  
  /// Assessment progress percentage for display
  int get assessmentPercentage => (assessmentProgress * 100).round();
  
  /// Whether conversation has meaningful content (not just welcome)
  bool get hasSubstantiveConversation => messages.length > 2;
  
  /// Current demo step if in demo mode
  String? get currentDemoStep => isDemoMode ? demoState['current_step'] : null;
}

/// Conversation state notifier
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
    _initializeConversation();
    _setupVoiceListeners();
  }

  /// Initialize conversation with welcome message
  Future<void> _initializeConversation() async {
    try {
      // Load conversation history if available
      final savedMessages = await _loadConversationHistory();
      
      if (savedMessages.isNotEmpty) {
        state = state.copyWith(
          messages: savedMessages,
          showSuggestions: false,
          lastActivity: DateTime.now(),
        );
        
        if (kDebugMode) {
          print('💬 Loaded ${savedMessages.length} previous messages');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading conversation history: $e');
      }
    }
  }

  /// Add welcome message from avatar
  Future<void> addWelcomeMessage() async {
    if (state.hasConversation) return; // Don't add if conversation exists
    
    try {
      final welcomeResponse = _personalityEngine.generateWelcomeMessage();
      
      final welcomeMessage = ConversationMessage(
        id: _uuid.v4(),
        type: MessageType.avatar,
        source: MessageSource.system,
        content: welcomeResponse.content,
        timestamp: DateTime.now(),
        metadata: {
          'is_welcome': true,
          'emotion': welcomeResponse.emotion.toString(),
          'confidence': welcomeResponse.confidence,
        },
      );
      
      state = state.copyWith(
        messages: [welcomeMessage],
        showSuggestions: true,
        lastActivity: DateTime.now(),
      );
      
      await _saveConversationHistory();
      
      // Speak welcome if voice is enabled
      if (_audioService.ttsEnabled) {
        await _audioService.speak(welcomeResponse.content);
      }
      
      if (kDebugMode) {
        print('👋 Welcome message added');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error adding welcome message: $e');
      }
    }
  }

  /// Add user message to conversation
  Future<void> addUserMessage(
    String content, {
    MessageSource source = MessageSource.text,
  }) async {
    if (content.trim().isEmpty) return;
    
    try {
      final userMessage = ConversationMessage(
        id: _uuid.v4(),
        type: MessageType.user,
        source: source,
        content: content.trim(),
        timestamp: DateTime.now(),
      );
      
      // Add user message immediately
      state = state.copyWith(
        messages: [...state.messages, userMessage],
        showSuggestions: false,
        isProcessing: true,
        lastActivity: DateTime.now(),
        lastError: null,
      );
      
      await _saveConversationHistory();
      
      // Generate avatar response
      await _generateAvatarResponse(content);
      
      if (kDebugMode) {
        print('💬 User message added: ${content.substring(0, 50)}...');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error adding user message: $e');
      }
      
      state = state.copyWith(
        isProcessing: false,
        lastError: 'Failed to process your message. Please try again.',
      );
    }
  }

  /// Generate and add avatar response
  Future<void> _generateAvatarResponse(String userMessage) async {
    try {
      // Get conversation context (simplified for demo)
      final context = _buildConversationContext();
      
      // Generate response using personality engine
      final response = await _personalityEngine.generateResponse(
        userMessage: userMessage,
        context: context,
        previousMessages: _getMessageHistory(),
      );
      
      final avatarMessage = ConversationMessage(
        id: _uuid.v4(),
        type: MessageType.avatar,
        source: MessageSource.system,
        content: response.content,
        timestamp: DateTime.now(),
        metadata: {
          'emotion': response.emotion.toString(),
          'confidence': response.confidence,
          'response_type': response.responseType.toString(),
          'reasoning_path': 'Generated using expert personality engine',
        },
      );
      
      // Add avatar response
      state = state.copyWith(
        messages: [...state.messages, avatarMessage],
        isProcessing: false,
        showSuggestions: true,
        lastActivity: DateTime.now(),
      );
      
      await _saveConversationHistory();
      
      // Speak response if voice is enabled
      if (_audioService.ttsEnabled) {
        await _audioService.speak(response.content);
      }
      
      if (kDebugMode) {
        print('🤖 Avatar response generated (confidence: ${(response.confidence * 100).toStringAsFixed(1)}%)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error generating avatar response: $e');
      }
      
      // Add error message
      final errorMessage = ConversationMessage(
        id: _uuid.v4(),
        type: MessageType.error,
        source: MessageSource.system,
        content: TextConstants.genericError,
        timestamp: DateTime.now(),
      );
      
      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isProcessing: false,
        lastError: 'Failed to generate response',
      );
    }
  }

  /// Start voice listening
  Future<void> startListening() async {
    if (!_audioService.speechEnabled || state.isListening) return;
    
    try {
      final success = await _audioService.startListening();
      
      if (success) {
        state = state.copyWith(
          isListening: true,
          isVoiceMode: true,
          currentTranscript: '',
          lastError: null,
        );
        
        if (kDebugMode) {
          print('🎤 Started voice listening');
        }
      } else {
        state = state.copyWith(
          lastError: TextConstants.voiceError,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error starting voice listening: $e');
      }
      
      state = state.copyWith(
        lastError: 'Failed to start voice input. Please check microphone permissions.',
      );
    }
  }

  /// Stop voice listening
  Future<void> stopListening() async {
    if (!state.isListening) return;
    
    try {
      await _audioService.stopListening();
      
      state = state.copyWith(
        isListening: false,
      );
      
      // Process final transcript if available
      if (state.currentTranscript?.isNotEmpty == true) {
        await addUserMessage(
          state.currentTranscript!,
          source: MessageSource.voice,
        );
      }
      
      if (kDebugMode) {
        print('🎤 Stopped voice listening');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error stopping voice listening: $e');
      }
    }
  }

  /// Clear conversation history
  Future<void> clearConversation() async {
    try {
      state = const ConversationState();
      
      await _storageService.clearConversationHistory();
      
      // Add new welcome message
      await addWelcomeMessage();
      
      if (kDebugMode) {
        print('🧹 Conversation cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing conversation: $e');
      }
    }
  }

  /// Update voice transcript during listening
  void updateTranscript(String transcript) {
    if (state.isListening) {
      state = state.copyWith(
        currentTranscript: transcript,
        lastActivity: DateTime.now(),
      );
    }
  }

  /// Handle voice input error
  void handleVoiceError(String error) {
    state = state.copyWith(
      isListening: false,
      lastError: error,
    );
    
    if (kDebugMode) {
      print('🎤 Voice error: $error');
    }
  }

  /// Mark message as processing
  void setMessageProcessing(String messageId, bool processing) {
    final updatedMessages = state.messages.map((message) {
      if (message.id == messageId) {
        return message.copyWith(isProcessing: processing);
      }
      return message;
    }).toList();
    
    state = state.copyWith(messages: updatedMessages);
  }

  /// Update message content (for streaming responses)
  void updateMessageContent(String messageId, String newContent) {
    final updatedMessages = state.messages.map((message) {
      if (message.id == messageId) {
        return message.copyWith(content: newContent);
      }
      return message;
    }).toList();
    
    state = state.copyWith(messages: updatedMessages);
  }

  // Private helper methods

  void _setupVoiceListeners() {
    // Listen to speech results
    _audioService.speechResults.listen((transcript) {
      updateTranscript(transcript);
    });
    
    // Listen to listening state changes
    _audioService.listeningState.listen((isListening) {
      if (!isListening && state.isListening) {
        stopListening();
      }
    });
  }

  Future<List<ConversationMessage>> _loadConversationHistory() async {
    try {
      final messageData = await _storageService.loadConversationHistory();
      
      return messageData.map((data) {
        return ConversationMessage(
          id: data['id'] ?? _uuid.v4(),
          type: MessageType.values.firstWhere(
            (t) => t.toString() == data['type'],
            orElse: () => MessageType.user,
          ),
          source: MessageSource.values.firstWhere(
            (s) => s.toString() == data['source'],
            orElse: () => MessageSource.text,
          ),
          content: data['content'] ?? '',
          timestamp: DateTime.parse(data['timestamp'] ?? DateTime.now().toIso8601String()),
          metadata: data['metadata'] as Map<String, dynamic>?,
        );
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading conversation history: $e');
      }
      return [];
    }
  }

  Future<void> _saveConversationHistory() async {
    try {
      final messageData = state.messages.map((message) => {
        'id': message.id,
        'type': message.type.toString(),
        'source': message.source.toString(),
        'content': message.content,
        'timestamp': message.timestamp.toIso8601String(),
        'metadata': message.metadata,
      }).toList();
      
      await _storageService.saveConversationHistory(messageData);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving conversation history: $e');
      }
    }
  }

  ConversationContext _buildConversationContext() {
    // Simplified context building for demo
    return ConversationContext(
      conversationCount: state.messageCount,
      lastInteraction: DateTime.now(),
    );
  }

  List<String> _getMessageHistory() {
    return state.messages
        .where((m) => m.type == MessageType.user)
        .map((m) => m.content)
        .toList();
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

/// Provider for last conversation error
final conversationErrorProvider = Provider<String?>((ref) {
  final conversation = ref.watch(conversationProvider);
  return conversation.lastError;
});

/// Provider for last conversation error
final conversationErrorProvider = Provider<String?>((ref) {
  final conversation = ref.watch(conversationProvider);
  return conversation.lastError;
});

// ADD THE NEW PROVIDERS HERE ⬇️

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