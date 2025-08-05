// lib/core/services/audio_service.dart
// ArionComply Audio Service - Multi-modal conversation support
// Handles speech-to-text, text-to-speech, and voice interaction

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../models/expert_personality.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';

class AudioService {
  static AudioService? _instance;
  static AudioService get instance => _instance ??= AudioService._();
  AudioService._();

  // Speech-to-Text components
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';

  // Text-to-Speech components
  final FlutterTts _textToSpeech = FlutterTts();
  bool _ttsEnabled = false;
  bool _isSpeaking = false;
  
  // Voice settings
  double _speechRate = 1.0;
  double _speechPitch = 1.0;
  double _speechVolume = 1.0;
  String _voiceLanguage = 'en-US';
  
  // Stream controllers for reactive updates
  final StreamController<String> _speechResultController = 
      StreamController<String>.broadcast();
  final StreamController<bool> _listeningStateController = 
      StreamController<bool>.broadcast();
  final StreamController<bool> _speakingStateController = 
      StreamController<bool>.broadcast();

  // Public streams
  Stream<String> get speechResults => _speechResultController.stream;
  Stream<bool> get listeningState => _listeningStateController.stream;
  Stream<bool> get speakingState => _speakingStateController.stream;

  // Getters
  bool get speechEnabled => _speechEnabled;
  bool get ttsEnabled => _ttsEnabled;
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  String get lastWords => _lastWords;

  /// Initialize audio services
  static Future<void> initialize() async {
    await instance._initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await _initializeSpeechToText();
      await _initializeTextToSpeech();
      
      if (kDebugMode) {
        print('🎤 Audio services initialized successfully');
        print('   Speech-to-Text: $_speechEnabled');
        print('   Text-to-Speech: $_ttsEnabled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Audio service initialization error: $e');
      }
    }
  }

  /// Initialize Speech-to-Text
  Future<void> _initializeSpeechToText() async {
    try {
      // Request microphone permission
      final permissionStatus = await Permission.microphone.request();
      if (permissionStatus != PermissionStatus.granted) {
        if (kDebugMode) {
          print('⚠️ Microphone permission denied');
        }
        return;
      }

      // Initialize speech recognition
      _speechEnabled = await _speechToText.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
        debugLogging: kDebugMode,
      );

      if (_speechEnabled) {
        // Get available locales
        final locales = await _speechToText.locales();
        if (kDebugMode) {
          print('🌍 Available speech locales: ${locales.length}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Speech-to-Text initialization error: $e');
      }
    }
  }

  /// Initialize Text-to-Speech
  Future<void> _initializeTextToSpeech() async {
    try {
      _ttsEnabled = true;

      // Configure TTS settings
      await _textToSpeech.setLanguage(_voiceLanguage);
      await _textToSpeech.setSpeechRate(_speechRate);
      await _textToSpeech.setPitch(_speechPitch);
      await _textToSpeech.setVolume(_speechVolume);

      // Set completion handler
      _textToSpeech.setCompletionHandler(() {
        _isSpeaking = false;
        _speakingStateController.add(false);
        if (kDebugMode) {
          print('🔊 TTS completed');
        }
      });

      // Set start handler
      _textToSpeech.setStartHandler(() {
        _isSpeaking = true;
        _speakingStateController.add(true);
        if (kDebugMode) {
          print('🔊 TTS started');
        }
      });

      // Get available voices
      if (kDebugMode) {
        final voices = await _textToSpeech.getVoices;
        print('🎵 Available TTS voices: ${voices.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Text-to-Speech initialization error: $e');
      }
    }
  }

  /// Start listening for speech input
  Future<bool> startListening() async {
    if (!_speechEnabled || _isListening) {
      return false;
    }

    try {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: _voiceLanguage,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );

      _isListening = true;
      _listeningStateController.add(true);
      
      if (kDebugMode) {
        print('🎤 Started listening for speech');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error starting speech recognition: $e');
      }
      return false;
    }
  }

  /// Stop listening for speech input
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _speechToText.stop();
      _isListening = false;
      _listeningStateController.add(false);
      
      if (kDebugMode) {
        print('🎤 Stopped listening for speech');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error stopping speech recognition: $e');
      }
    }
  }

  /// Speak text using TTS
  Future<void> speak(String text) async {
    if (!_ttsEnabled || text.isEmpty) return;

    try {
      // Stop any current speech
      await stopSpeaking();
      
      // Start speaking
      await _textToSpeech.speak(text);
      
      if (kDebugMode) {
        print('🔊 Speaking: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error speaking text: $e');
      }
    }
  }

  /// Stop current speech
  Future<void> stopSpeaking() async {
    if (!_isSpeaking) return;

    try {
      await _textToSpeech.stop();
      _isSpeaking = false;
      _speakingStateController.add(false);
      
      if (kDebugMode) {
        print('🔊 Stopped speaking');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error stopping speech: $e');
      }
    }
  }

  /// Update voice settings
  Future<void> updateVoiceSettings({
    double? rate,
    double? pitch,
    double? volume,
    String? language,
  }) async {
    if (!_ttsEnabled) return;

    try {
      if (rate != null && rate != _speechRate) {
        _speechRate = rate.clamp(0.1, 3.0);
        await _textToSpeech.setSpeechRate(_speechRate);
      }

      if (pitch != null && pitch != _speechPitch) {
        _speechPitch = pitch.clamp(0.1, 2.0);
        await _textToSpeech.setPitch(_speechPitch);
      }

      if (volume != null && volume != _speechVolume) {
        _speechVolume = volume.clamp(0.0, 1.0);
        await _textToSpeech.setVolume(_speechVolume);
      }

      if (language != null && language != _voiceLanguage) {
        _voiceLanguage = language;
        await _textToSpeech.setLanguage(_voiceLanguage);
      }

      if (kDebugMode) {
        print('🎛️ Voice settings updated: rate=$_speechRate, pitch=$_speechPitch, volume=$_speechVolume');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating voice settings: $e');
      }
    }
  }

  /// Get current voice settings
  VoiceSettings get voiceSettings => VoiceSettings(
    rate: _speechRate,
    pitch: _speechPitch,
    volume: _speechVolume,
    language: _voiceLanguage,
  );

  // Event handlers

  void _onSpeechResult(result) {
    _lastWords = result.recognizedWords;
    _speechResultController.add(_lastWords);
    
    if (kDebugMode) {
      print('🎤 Speech result: $_lastWords (confidence: ${result.confidence})');
    }
  }

  void _onSpeechStatus(String status) {
    if (kDebugMode) {
      print('🎤 Speech status: $status');
    }
    
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
      _listeningStateController.add(false);
    }
  }

  void _onSpeechError(error) {
    if (kDebugMode) {
      print('❌ Speech error: $error');
    }
    
    _isListening = false;
    _listeningStateController.add(false);
  }

  /// Dispose resources
  void dispose() {
    _speechResultController.close();
    _listeningStateController.close();
    _speakingStateController.close();
  }
}

// lib/features/avatar/widgets/voice_input_button.dart
// Voice input button component


class VoiceInputButton extends ConsumerStatefulWidget {
  final bool isActive;
  final bool isEnabled;
  final VoidCallback? onPressed;
  final GestureLongPressStartCallback? onLongPressStart;
  final GestureLongPressEndCallback? onLongPressEnd;

  const VoiceInputButton({
    super.key,
    required this.isActive,
    required this.isEnabled,
    this.onPressed,
    this.onLongPressStart,
    this.onLongPressEnd,
  });

  @override
  ConsumerState<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends ConsumerState<VoiceInputButton>
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(VoiceInputButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isActive && !oldWidget.isActive) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isEnabled ? widget.onPressed : null,
      onLongPressStart: widget.isEnabled ? widget.onLongPressStart : null,
      onLongPressEnd: widget.isEnabled ? widget.onLongPressEnd : null,
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.95).animate(
          CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
        ),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: widget.isActive ? AppColors.primary : AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.isActive 
                  ? AppColors.primary 
                  : AppColors.border,
              width: 2,
            ),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pulse animation when active
              if (widget.isActive)
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 56 + (_pulseController.value * 20),
                      height: 56 + (_pulseController.value * 20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withOpacity(
                            0.5 - (_pulseController.value * 0.5),
                          ),
                          width: 2,
                        ),
                      ),
                    );
                  },
                ),
              
              // Microphone icon
              Icon(
                widget.isActive ? Icons.mic : Icons.mic_none,
                size: 24,
                color: widget.isActive 
                    ? Colors.white 
                    : (widget.isEnabled ? AppColors.primary : AppColors.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// lib/core/services/voice_settings.dart
// Voice settings data model

class VoiceSettings {
  final double rate;
  final double pitch;
  final double volume;
  final String language;

  const VoiceSettings({
    required this.rate,
    required this.pitch,
    required this.volume,
    required this.language,
  });

  VoiceSettings copyWith({
    double? rate,
    double? pitch,
    double? volume,
    String? language,
  }) {
    return VoiceSettings(
      rate: rate ?? this.rate,
      pitch: pitch ?? this.pitch,
      volume: volume ?? this.volume,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rate': rate,
      'pitch': pitch,
      'volume': volume,
      'language': language,
    };
  }

  factory VoiceSettings.fromJson(Map<String, dynamic> json) {
    return VoiceSettings(
      rate: (json['rate'] as num?)?.toDouble() ?? 1.0,
      pitch: (json['pitch'] as num?)?.toDouble() ?? 1.0,
      volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
      language: json['language'] as String? ?? 'en-US',
    );
  }

  // Predefined voice personalities
  static const VoiceSettings professional = VoiceSettings(
    rate: 1.0,
    pitch: 1.0,
    volume: 1.0,
    language: 'en-US',
  );

  static const VoiceSettings friendly = VoiceSettings(
    rate: 1.1,
    pitch: 1.1,
    volume: 1.0,
    language: 'en-US',
  );

  static const VoiceSettings authoritative = VoiceSettings(
    rate: 0.9,
    pitch: 0.9,
    volume: 1.0,
    language: 'en-US',
  );
}

// lib/features/avatar/providers/voice_provider.dart
// Voice interaction state management



/// Voice service provider
final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService.instance;
});

/// Voice settings provider
final voiceSettingsProvider = StateProvider<VoiceSettings>((ref) {
  return VoiceSettings.professional;
});

/// Voice input state provider
final voiceInputProvider = StateNotifierProvider<VoiceInputNotifier, VoiceInputState>((ref) {
  return VoiceInputNotifier(ref.read(audioServiceProvider));
});

class VoiceInputState {
  final bool isListening;
  final bool isProcessing;
  final String currentTranscript;
  final String? lastResult;
  final String? error;

  const VoiceInputState({
    this.isListening = false,
    this.isProcessing = false,
    this.currentTranscript = '',
    this.lastResult,
    this.error,
  });

  VoiceInputState copyWith({
    bool? isListening,
    bool? isProcessing,
    String? currentTranscript,
    String? lastResult,
    String? error,
  }) {
    return VoiceInputState(
      isListening: isListening ?? this.isListening,
      isProcessing: isProcessing ?? this.isProcessing,
      currentTranscript: currentTranscript ?? this.currentTranscript,
      lastResult: lastResult ?? this.lastResult,
      error: error ?? this.error,
    );
  }
}

class VoiceInputNotifier extends StateNotifier<VoiceInputState> {
  final AudioService _audioService;

  VoiceInputNotifier(this._audioService) : super(const VoiceInputState()) {
    _setupListeners();
  }

  void _setupListeners() {
    // Listen to speech results
    _audioService.speechResults.listen((transcript) {
      state = state.copyWith(
        currentTranscript: transcript,
        error: null,
      );
    });

    // Listen to listening state changes
    _audioService.listeningState.listen((isListening) {
      state = state.copyWith(
        isListening: isListening,
        error: null,
      );
    });
  }

  /// Start voice input
  Future<void> startListening() async {
    state = state.copyWith(isProcessing: true, error: null);
    
    final success = await _audioService.startListening();
    
    state = state.copyWith(
      isProcessing: false,
      error: success ? null : 'Failed to start voice input',
    );
  }

  /// Stop voice input
  Future<void> stopListening() async {
    await _audioService.stopListening();
    
    // Save the last result
    if (state.currentTranscript.isNotEmpty) {
      state = state.copyWith(
        lastResult: state.currentTranscript,
        currentTranscript: '',
      );
    }
  }

  /// Clear voice input state
  void clear() {
    state = const VoiceInputState();
  }
}

// lib/features/avatar/services/voice_personality_service.dart
// Voice personality matching expert persona

class VoicePersonalityService {
  static VoicePersonalityService? _instance;
  static VoicePersonalityService get instance => 
      _instance ??= VoicePersonalityService._();
  VoicePersonalityService._();

  /// Apply voice settings based on expert personality
  Future<void> applyPersonalityToVoice({
    required ExpertPersonalityType personalityType,
    required ExpertEmotion currentEmotion,
  }) async {
    final voiceSettings = _getVoiceSettingsForPersonality(
      personalityType, 
      currentEmotion,
    );
    
    await AudioService.instance.updateVoiceSettings(
      rate: voiceSettings.rate,
      pitch: voiceSettings.pitch,
      volume: voiceSettings.volume,
      language: voiceSettings.language,
    );
  }

  /// Get voice settings for personality type and emotion
  VoiceSettings _getVoiceSettingsForPersonality(
    ExpertPersonalityType personalityType,
    ExpertEmotion emotion,
  ) {
    // Base settings for personality type
    VoiceSettings baseSettings;
    
    switch (personalityType) {
      case ExpertPersonalityType.friendly:
        baseSettings = VoiceSettings.friendly;
        break;
      case ExpertPersonalityType.authoritative:
        baseSettings = VoiceSettings.authoritative;
        break;
      case ExpertPersonalityType.professional:
      default:
        baseSettings = VoiceSettings.professional;
        break;
    }

    // Adjust for current emotion
    switch (emotion) {
      case ExpertEmotion.encouraging:
        return baseSettings.copyWith(
          rate: baseSettings.rate + 0.1,
          pitch: baseSettings.pitch + 0.1,
        );
      
      case ExpertEmotion.concerned:
        return baseSettings.copyWith(
          rate: baseSettings.rate - 0.1,
          pitch: baseSettings.pitch - 0.1,
        );
      
      case ExpertEmotion.celebratory:
        return baseSettings.copyWith(
          rate: baseSettings.rate + 0.2,
          pitch: baseSettings.pitch + 0.2,
        );
      
      default:
        return baseSettings;
    }
  }
}