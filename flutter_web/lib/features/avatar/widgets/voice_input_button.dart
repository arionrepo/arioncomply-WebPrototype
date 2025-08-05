// lib/features/avatar/widgets/voice_input_button.dart
// ArionComply Voice Input Button
// Interactive voice recording button with visual feedback and animations

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/voice_provider.dart';
import '../../../core/services/audio_service.dart';

/// Voice Input Button - Interactive voice recording with visual feedback
/// Shows recording state, audio levels, and provides haptic feedback
class VoiceInputButton extends ConsumerStatefulWidget {
  final VoiceButtonSize size;
  final VoiceButtonStyle style;
  final Function(String)? onTranscription;
  final VoidCallback? onStartRecording;
  final VoidCallback? onStopRecording;
  final bool enabled;
  final bool showLabel;
  
  const VoiceInputButton({
    super.key,
    this.size = VoiceButtonSize.medium,
    this.style = VoiceButtonStyle.filled,
    this.onTranscription,
    this.onStartRecording,
    this.onStopRecording,
    this.enabled = true,
    this.showLabel = false,
  });

  @override
  ConsumerState<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends ConsumerState<VoiceInputButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late AnimationController _waveController;
  late AnimationController _fadeController;
  
  bool _isPressed = false;
  bool _isHovered = false;
  double _currentAudioLevel = 0.0;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    _waveController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceProvider);
    
    // Update animations based on voice state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAnimations(voiceState);
    });
    
    return GestureDetector(
      onTapDown: widget.enabled ? _handleTapDown : null,
      onTapUp: widget.enabled ? _handleTapUp : null,
      onTapCancel: widget.enabled ? _handleTapCancel : null,
      onLongPressStart: widget.enabled ? _handleLongPressStart : null,
      onLongPressEnd: widget.enabled ? _handleLongPressEnd : null,
      child: MouseRegion(
        onEnter: _handleMouseEnter,
        onExit: _handleMouseExit,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _pulseController,
            _scaleController,
            _waveController,
            _fadeController,
          ]),
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildVoiceButton(voiceState),
                if (widget.showLabel) ...[
                  SizedBox(height: _getSpacing()),
                  _buildVoiceLabel(voiceState),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildVoiceButton(VoiceState voiceState) {
    final buttonSize = _getButtonSize();
    final isRecording = voiceState.isRecording;
    final isProcessing = voiceState.isProcessing;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulse rings for recording state
        if (isRecording) ..._buildPulseRings(buttonSize),
        
        // Audio level visualization
        if (isRecording) _buildAudioLevelRings(buttonSize),
        
        // Main button container
        Transform.scale(
          scale: 1.0 - (_scaleController.value * 0.05),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: _getButtonColor(voiceState),
              borderRadius: BorderRadius.circular(buttonSize / 2),
              boxShadow: _getButtonShadow(voiceState),
              border: _getButtonBorder(voiceState),
            ),
            child: _buildButtonContent(voiceState),
          ),
        ),
        
        // Processing indicator
        if (isProcessing) _buildProcessingIndicator(buttonSize),
      ],
    );
  }

  Widget _buildButtonContent(VoiceState voiceState) {
    final iconSize = _getIconSize();
    
    if (voiceState.isProcessing) {
      return Center(
        child: SizedBox(
          width: iconSize,
          height: iconSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getIconColor(voiceState),
            ),
          ),
        ),
      );
    }
    
    return Center(
      child: Icon(
        _getButtonIcon(voiceState),
        color: _getIconColor(voiceState),
        size: iconSize,
      ),
    );
  }

  List<Widget> _buildPulseRings(double buttonSize) {
    return List.generate(3, (index) {
      final delay = index * 0.3;
      final animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _pulseController,
        curve: Interval(delay, 1.0, curve: Curves.easeOut),
      ));
      
      return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Container(
            width: buttonSize + (animation.value * 40),
            height: buttonSize + (animation.value * 40),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(
                0.3 * (1 - animation.value),
              ),
              borderRadius: BorderRadius.circular(
                (buttonSize + (animation.value * 40)) / 2,
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildAudioLevelRings(double buttonSize) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: List.generate(5, (index) {
            final progress = (_waveController.value + (index * 0.2)) % 1.0;
            final scale = 1.0 + (progress * _currentAudioLevel * 0.5);
            
            return Transform.scale(
              scale: scale,
              child: Container(
                width: buttonSize + (index * 8),
                height: buttonSize + (index * 8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(
                    0.1 * (1 - progress) * _currentAudioLevel,
                  ),
                  borderRadius: BorderRadius.circular(
                    (buttonSize + (index * 8)) / 2,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildProcessingIndicator(double buttonSize) {
    return Container(
      width: buttonSize + 20,
      height: buttonSize + 20,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular((buttonSize + 20) / 2),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Lottie.asset(
        'assets/animations/voice_pulse.json',
        width: buttonSize + 20,
        height: buttonSize + 20,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildVoiceLabel(VoiceState voiceState) {
    String labelText;
    Color labelColor;
    
    if (voiceState.isRecording) {
      labelText = 'Recording...';
      labelColor = AppColors.error;
    } else if (voiceState.isProcessing) {
      labelText = 'Processing...';
      labelColor = AppColors.warning;
    } else if (voiceState.hasError) {
      labelText = 'Try again';
      labelColor = AppColors.error;
    } else {
      labelText = 'Tap to speak';
      labelColor = AppColors.textSecondary;
    }
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Text(
        labelText,
        key: ValueKey(labelText),
        style: _getLabelTextStyle().copyWith(color: labelColor),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _scaleController.forward();
    _triggerHapticFeedback();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
    _handleVoiceToggle();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    _startVoiceRecording();
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    _stopVoiceRecording();
  }

  void _handleMouseEnter(PointerEnterEvent event) {
    setState(() => _isHovered = true);
  }

  void _handleMouseExit(PointerExitEvent event) {
    setState(() => _isHovered = false);
  }

  void _handleVoiceToggle() {
    final voiceState = ref.read(voiceProvider);
    
    if (voiceState.isRecording) {
      _stopVoiceRecording();
    } else if (!voiceState.isProcessing) {
      _startVoiceRecording();
    }
  }

  void _startVoiceRecording() {
    _triggerHapticFeedback(HapticFeedbackType.selectionClick);
    ref.read(voiceProvider.notifier).startRecording();
    widget.onStartRecording?.call();
  }

  void _stopVoiceRecording() {
    _triggerHapticFeedback(HapticFeedbackType.selectionClick);
    ref.read(voiceProvider.notifier).stopRecording();
    widget.onStopRecording?.call();
  }

  void _updateAnimations(VoiceState voiceState) {
    if (voiceState.isRecording) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat();
      }
      if (!_waveController.isAnimating) {
        _waveController.repeat();
      }
      
      // Simulate audio level changes
      _updateAudioLevel(voiceState.audioLevel);
    } else {
      _pulseController.stop();
      _pulseController.reset();
      _waveController.stop();
      _waveController.reset();
      _currentAudioLevel = 0.0;
    }
  }

  void _updateAudioLevel(double level) {
    setState(() {
      _currentAudioLevel = level;
    });
  }

  void _triggerHapticFeedback([HapticFeedbackType type = HapticFeedbackType.lightImpact]) {
    HapticFeedback.selectionClick();
  }

  double _getButtonSize() {
    switch (widget.size) {
      case VoiceButtonSize.small:
        return 40;
      case VoiceButtonSize.medium:
        return 56;
      case VoiceButtonSize.large:
        return 72;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case VoiceButtonSize.small:
        return 20;
      case VoiceButtonSize.medium:
        return 28;
      case VoiceButtonSize.large:
        return 36;
    }
  }

  double _getSpacing() {
    switch (widget.size) {
      case VoiceButtonSize.small:
        return 8;
      case VoiceButtonSize.medium:
        return 12;
      case VoiceButtonSize.large:
        return 16;
    }
  }

  TextStyle _getLabelTextStyle() {
    switch (widget.size) {
      case VoiceButtonSize.small:
        return AppTextStyles.bodySmall;
      case VoiceButtonSize.medium:
        return AppTextStyles.bodyMedium;
      case VoiceButtonSize.large:
        return AppTextStyles.bodyLarge;
    }
  }

  Color _getButtonColor(VoiceState voiceState) {
    if (!widget.enabled) {
      return AppColors.textSecondary.withOpacity(0.3);
    }
    
    switch (widget.style) {
      case VoiceButtonStyle.filled:
        if (voiceState.isRecording) {
          return AppColors.error;
        } else if (voiceState.hasError) {
          return AppColors.error.withOpacity(0.8);
        } else {
          return _isHovered ? AppColors.primary.withOpacity(0.9) : AppColors.primary;
        }
      case VoiceButtonStyle.outlined:
        return _isHovered 
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent;
      case VoiceButtonStyle.text:
        return _isPressed 
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent;
    }
  }

  Color _getIconColor(VoiceState voiceState) {
    if (!widget.enabled) {
      return AppColors.textSecondary.withOpacity(0.5);
    }
    
    switch (widget.style) {
      case VoiceButtonStyle.filled:
        return Colors.white;
      case VoiceButtonStyle.outlined:
      case VoiceButtonStyle.text:
        if (voiceState.isRecording) {
          return AppColors.error;
        } else if (voiceState.hasError) {
          return AppColors.error;
        } else {
          return AppColors.primary;
        }
    }
  }

  IconData _getButtonIcon(VoiceState voiceState) {
    if (voiceState.isRecording) {
      return Icons.stop;
    } else if (voiceState.hasError) {
      return Icons.refresh;
    } else {
      return Icons.mic;
    }
  }

  List<BoxShadow> _getButtonShadow(VoiceState voiceState) {
    if (widget.style != VoiceButtonStyle.filled || !widget.enabled) {
      return [];
    }
    
    return [
      BoxShadow(
        color: _getButtonColor(voiceState).withOpacity(0.3),
        offset: const Offset(0, 2),
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ];
  }

  Border? _getButtonBorder(VoiceState voiceState) {
    if (widget.style != VoiceButtonStyle.outlined) {
      return null;
    }
    
    return Border.all(
      color: _getIconColor(voiceState),
      width: 2,
    );
  }
}

/// Voice button size options
enum VoiceButtonSize {
  small,
  medium,
  large,
}

/// Voice button style options
enum VoiceButtonStyle {
  filled,
  outlined,
  text,
}

/// Compact voice input for minimal space
class CompactVoiceButton extends ConsumerWidget {
  final Function(String)? onTranscription;
  
  const CompactVoiceButton({
    super.key,
    this.onTranscription,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceState = ref.watch(voiceProvider);
    
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: voiceState.isRecording 
            ? AppColors.error 
            : AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        onPressed: () => _handleVoiceToggle(ref),
        icon: Icon(
          voiceState.isRecording ? Icons.stop : Icons.mic,
          color: voiceState.isRecording 
              ? Colors.white 
              : AppColors.primary,
          size: 16,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  void _handleVoiceToggle(WidgetRef ref) {
    final voiceState = ref.read(voiceProvider);
    
    if (voiceState.isRecording) {
      ref.read(voiceProvider.notifier).stopRecording();
    } else {
      ref.read(voiceProvider.notifier).startRecording();
    }
  }
}