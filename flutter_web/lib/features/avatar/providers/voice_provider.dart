// lib/features/avatar/providers/voice_provider.dart
// Voice interaction state management for ArionComply
// Handles voice recording, processing, and playback state

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/audio_service.dart';

/// Voice interaction state
class VoiceState {
  final bool isRecording;
  final bool isProcessing;
  final bool isPlaying;
  final bool hasError;
  final String? errorMessage;
  final String currentTranscript;
  final double audioLevel;
  final Duration recordingDuration;
  final VoiceInputMode inputMode;

  const VoiceState({
    this.isRecording = false,
    this.isProcessing = false,
    this.isPlaying = false,
    this.hasError = false,
    this.errorMessage,
    this.currentTranscript = '',
    this.audioLevel = 0.0,
    this.recordingDuration = Duration.zero,
    this.inputMode = VoiceInputMode.pushToTalk,
  });

  VoiceState copyWith({
    bool? isRecording,
    bool? isProcessing,
    bool? isPlaying,
    bool? hasError,
    String? errorMessage,
    String? currentTranscript,
    double? audioLevel,
    Duration? recordingDuration,
    VoiceInputMode? inputMode,
  }) {
    return VoiceState(
      isRecording: isRecording ?? this.isRecording,
      isProcessing: isProcessing ?? this.isProcessing,
      isPlaying: isPlaying ?? this.isPlaying,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      currentTranscript: currentTranscript ?? this.currentTranscript,
      audioLevel: audioLevel ?? this.audioLevel,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      inputMode: inputMode ?? this.inputMode,
    );
  }

  /// Whether voice input is currently active
  bool get isActive => isRecording || isProcessing;

  /// Whether voice system is available
  bool get isAvailable => !hasError;

  /// Current status message for display
  String get statusMessage {
    if (hasError) return errorMessage ?? 'Voice error';
    if (isProcessing) return 'Processing...';
    if (isRecording) return 'Listening...';
    if (isPlaying) return 'Speaking...';
    return 'Ready';
  }
}

/// Voice input modes
enum VoiceInputMode {
  pushToTalk,     // Hold to record
  tapToToggle,    // Tap to start/stop
  continuous,     // Always listening
}

/// Voice state notifier
class VoiceNotifier extends StateNotifier<VoiceState> {
  final AudioService _audioService;
  
  VoiceNotifier(this._audioService) : super(const VoiceState()) {
    _initializeVoiceService();
  }

  /// Initialize voice service and set up listeners
  Future<void> _initializeVoiceService() async {
    try {
      // Listen to speech results
      _audioService.speechResults.listen((transcript) {
        state = state.copyWith(
          currentTranscript: transcript,
          hasError: false,
          errorMessage: null,
        );
      });

      // Listen to listening state changes
      _audioService.listeningState.listen((isListening) {
        state = state.copyWith(
          isRecording: isListening,
          hasError: false,
        );
      });

      // Listen to speaking state changes
      _audioService.speakingState.listen((isSpeaking) {
        state = state.copyWith(
          isPlaying: isSpeaking,
        );
      });

      // Initialize audio service
      final initialized = await _audioService.initialize();
      if (!initialized) {
        state = state.copyWith(
          hasError: true,
          errorMessage: 'Failed to initialize voice services',
        );
      }

      if (kDebugMode) {
        print('🎤 Voice provider initialized: ${initialized ? 'success' : 'failed'}');
      }
    } catch (e) {
      state = state.copyWith(
        hasError: true,
        errorMessage: 'Voice initialization error: $e',
      );
      
      if (kDebugMode) {
        print('❌ Voice provider initialization error: $e');
      }
    }
  }

  /// Start voice recording
  Future<void> startRecording() async {
    if (state.isRecording || state.isProcessing) return;

    try {
      state = state.copyWith(
        isProcessing: true,
        hasError: false,
        errorMessage: null,
        currentTranscript: '',
      );

      final success = await _audioService.startListening();
      
      if (success) {
        state = state.copyWith(
          isRecording: true,
          isProcessing: false,
          recordingDuration: Duration.zero,
        );
        
        // Start recording duration timer
        _startRecordingTimer();
      } else {
        state = state.copyWith(
          isProcessing: false,
          hasError: true,
          errorMessage: 'Failed to start recording',
        );
      }

      if (kDebugMode) {
        print('🎤 Recording started: $success');
      }
    } catch (e) {
      state = state.copyWith(
        isRecording: false,
        isProcessing: false,
        hasError: true,
        errorMessage: 'Recording error: $e',
      );
      
      if (kDebugMode) {
        print('❌ Recording start error: $e');
      }
    }
  }

  /// Stop voice recording
  Future<void> stopRecording() async {
    if (!state.isRecording) return;

    try {
      state = state.copyWith(isProcessing: true);

      await _audioService.stopListening();
      
      state = state.copyWith(
        isRecording: false,
        isProcessing: false,
      );

      if (kDebugMode) {
        print('🎤 Recording stopped');
      }
    } catch (e) {
      state = state.copyWith(
        isRecording: false,
        isProcessing: false,
        hasError: true,
        errorMessage: 'Stop recording error: $e',
      );
      
      if (kDebugMode) {
        print('❌ Recording stop error: $e');
      }
    }
  }

  /// Toggle recording state
  Future<void> toggleRecording() async {
    if (state.isRecording) {
      await stopRecording();
    } else {
      await startRecording();
    }
  }

  /// Speak text using TTS
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;

    try {
      state = state.copyWith(isPlaying: true);
      
      await _audioService.speak(text);
      
      // Note: isPlaying will be set to false by the speaking state listener
    } catch (e) {
      state = state.copyWith(
        isPlaying: false,
        hasError: true,
        errorMessage: 'Speech error: $e',
      );
      
      if (kDebugMode) {
        print('❌ Speech error: $e');
      }
    }
  }

  /// Stop current speech
  Future<void> stopSpeaking() async {
    try {
      await _audioService.stopSpeaking();
      state = state.copyWith(isPlaying: false);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Stop speaking error: $e');
      }
    }
  }

  /// Clear current transcript
  void clearTranscript() {
    state = state.copyWith(currentTranscript: '');
  }

  /// Update audio level (for visualization)
  void updateAudioLevel(double level) {
    if (state.isRecording) {
      state = state.copyWith(audioLevel: level.clamp(0.0, 1.0));
    }
  }

  /// Set voice input mode
  void setInputMode(VoiceInputMode mode) {
    state = state.copyWith(inputMode: mode);
    
    if (kDebugMode) {
      print('🎤 Voice input mode changed to: $mode');
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(
      hasError: false,
      errorMessage: null,
    );
  }

  /// Reset voice state
  void reset() {
    state = const VoiceState();
  }

  /// Start recording duration timer
  void _startRecordingTimer() {
    // In a real implementation, you'd use a periodic timer
    // For now, we'll simulate with a simple duration update
    Future.delayed(const Duration(milliseconds: 100), () {
      if (state.isRecording && mounted) {
        state = state.copyWith(
          recordingDuration: state.recordingDuration + const Duration(milliseconds: 100),
        );
        _startRecordingTimer();
      }
    });
  }

  @override
  void dispose() {
    // Clean up resources
    if (state.isRecording) {
      _audioService.stopListening();
    }
    if (state.isPlaying) {
      _audioService.stopSpeaking();
    }
    super.dispose();
  }
}

/// Voice provider
final voiceProvider = StateNotifierProvider<VoiceNotifier, VoiceState>((ref) {
  return VoiceNotifier(AudioService.instance);
});

/// Voice availability provider
final voiceAvailableProvider = Provider<bool>((ref) {
  final voice = ref.watch(voiceProvider);
  return voice.isAvailable;
});

/// Voice active provider
final voiceActiveProvider = Provider<bool>((ref) {
  final voice = ref.watch(voiceProvider);
  return voice.isActive;
});

/// Current transcript provider
final voiceTranscriptProvider = Provider<String>((ref) {
  final voice = ref.watch(voiceProvider);
  return voice.currentTranscript;
});

/// Voice status message provider
final voiceStatusProvider = Provider<String>((ref) {
  final voice = ref.watch(voiceProvider);
  return voice.statusMessage;
});

/// Voice input mode provider
final voiceInputModeProvider = Provider<VoiceInputMode>((ref) {
  final voice = ref.watch(voiceProvider);
  return voice.inputMode;
});