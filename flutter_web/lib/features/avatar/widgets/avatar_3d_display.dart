// FILE PATH: lib/features/avatar/widgets/avatar_3d_display.dart
// Avatar 3D Display Widget - Main avatar visual component
// Referenced in avatar_home_screen.dart as the central avatar interface

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../core/theme/app_colors.dart';
import '../models/expert_personality.dart';
import '../providers/avatar_state_provider.dart';

/// 3D Avatar Display Widget - Central visual component of the avatar interface
class Avatar3DDisplay extends StatefulWidget {
  final AvatarStateType state;
  final bool isProcessing;
  final ExpertEmotion emotion;
  final double size;
  final VoidCallback? onTap;

  const Avatar3DDisplay({
    super.key,
    required this.state,
    required this.isProcessing,
    required this.emotion,
    this.size = 200.0,
    this.onTap,
  });

  @override
  State<Avatar3DDisplay> createState() => _Avatar3DDisplayState();
}

class _Avatar3DDisplayState extends State<Avatar3DDisplay>
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _glowController;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }
  
  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
      value: 1.0,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // Start ambient animations
    _startAmbientAnimations();
  }
  
  void _startAmbientAnimations() {
    // Gentle rotation when idle
    if (widget.state == AvatarStateType.idle) {
      _rotationController.repeat();
    }
    
    // Pulse when processing
    if (widget.isProcessing) {
      _pulseController.repeat(reverse: true);
    }
  }
  
  @override
  void didUpdateWidget(Avatar3DDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update animations based on state changes
    if (widget.state != oldWidget.state) {
      _updateAnimationsForState();
    }
    
    if (widget.isProcessing != oldWidget.isProcessing) {
      _updateProcessingAnimation();
    }
    
    if (widget.emotion != oldWidget.emotion) {
      _updateEmotionAnimation();
    }
  }
  
  void _updateAnimationsForState() {
    switch (widget.state) {
      case AvatarStateType.idle:
        _rotationController.repeat();
        _pulseController.stop();
        _scaleController.animateTo(1.0);
        break;
        
      case AvatarStateType.listening:
        _rotationController.stop();
        _pulseController.repeat(reverse: true);
        _scaleController.animateTo(1.1);
        break;
        
      case AvatarStateType.processing:
        _rotationController.repeat();
        _pulseController.repeat(reverse: true);
        _scaleController.animateTo(0.95);
        break;
        
      case AvatarStateType.speaking:
        _rotationController.stop();
        _pulseController.stop();
        _scaleController.animateTo(1.05);
        break;
        
      case AvatarStateType.explaining:
        _rotationController.forward();
        _pulseController.stop();
        _scaleController.animateTo(1.02);
        break;
        
      case AvatarStateType.celebrating:
        _rotationController.repeat();
        _scaleController.animateTo(1.2);
        _glowController.repeat(reverse: true);
        break;
        
      case AvatarStateType.concerned:
        _rotationController.stop();
        _pulseController.stop();
        _scaleController.animateTo(0.9);
        break;
    }
  }
  
  void _updateProcessingAnimation() {
    if (widget.isProcessing) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }
  
  void _updateEmotionAnimation() {
    // Subtle animation changes based on emotion
    switch (widget.emotion) {
      case ExpertEmotion.happy:
      case ExpertEmotion.celebrating:
        _scaleController.animateTo(1.1);
        break;
      case ExpertEmotion.focused:
        _scaleController.animateTo(1.05);
        break;
      case ExpertEmotion.concerned:
        _scaleController.animateTo(0.95);
        break;
      default:
        _scaleController.animateTo(1.0);
        break;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background glow effect
            _buildBackgroundGlow(),
            
            // Main avatar container
            _buildAvatarContainer(),
            
            // State indicator overlay
            _buildStateIndicator(),
            
            // Processing overlay
            if (widget.isProcessing)
              _buildProcessingOverlay(),
          ],
        ),
      ),
    );
  }
  
  /// Background glow effect
  Widget _buildBackgroundGlow() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          width: widget.size * 1.3,
          height: widget.size * 1.3,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                _getGlowColor().withOpacity(0.3 * _glowController.value),
                _getGlowColor().withOpacity(0.1 * _glowController.value),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// Main avatar container with animations
  Widget _buildAvatarContainer() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _pulseController,
        _rotationController,
        _scaleController,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleController.value * (1.0 + (_pulseController.value * 0.1)),
          child: Transform.rotate(
            angle: _rotationController.value * 2 * 3.14159,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _getAvatarGradient(),
                border: Border.all(
                  color: _getBorderColor(),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getShadowColor(),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: _buildAvatarContent(),
            ),
          ),
        );
      },
    );
  }
  
  /// Avatar content - Lottie animation or fallback
  Widget _buildAvatarContent() {
    final animationPath = _getAnimationPath();
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.size / 2),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: _buildAvatarAnimation(animationPath),
      ),
    );
  }
  
  /// Build avatar animation with fallback
  Widget _buildAvatarAnimation(String animationPath) {
    // Try to load Lottie animation, fallback to icon if not available
    return FutureBuilder<bool>(
      future: _checkAssetExists(animationPath),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data == true) {
          return Lottie.asset(
            animationPath,
            fit: BoxFit.contain,
            repeat: _shouldRepeatAnimation(),
            animate: true,
          );
        } else {
          // Fallback to animated icon
          return _buildFallbackAvatar();
        }
      },
    );
  }
  
  /// Fallback avatar when Lottie animations are not available
  Widget _buildFallbackAvatar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getAvatarColor(),
      ),
      child: Icon(
        _getAvatarIcon(),
        size: widget.size * 0.4,
        color: Colors.white,
      ),
    );
  }
  
  /// State indicator overlay
  Widget _buildStateIndicator() {
    if (widget.state == AvatarStateType.idle) return const SizedBox.shrink();
    
    return Positioned(
      bottom: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getStateColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getStateIcon(),
              size: 12,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              _getStateText(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Processing overlay animation
  Widget _buildProcessingOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.2),
        ),
        child: Center(
          child: SizedBox(
            width: widget.size * 0.3,
            height: widget.size * 0.3,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // Helper methods for dynamic styling
  
  String _getAnimationPath() {
    switch (widget.state) {
      case AvatarStateType.idle:
        return 'assets/avatars/alex_idle.json';
      case AvatarStateType.listening:
        return 'assets/avatars/alex_listening.json';
      case AvatarStateType.processing:
      case AvatarStateType.explaining:
        return 'assets/avatars/alex_thinking.json';
      case AvatarStateType.speaking:
        return 'assets/avatars/alex_speaking.json';
      case AvatarStateType.celebrating:
        return 'assets/avatars/alex_celebrating.json';
      case AvatarStateType.concerned:
        return 'assets/avatars/alex_concerned.json';
      default:
        return 'assets/avatars/alex_idle.json';
    }
  }
  
  bool _shouldRepeatAnimation() {
    return widget.state == AvatarStateType.idle ||
           widget.state == AvatarStateType.listening ||
           widget.state == AvatarStateType.processing;
  }
  
  Color _getGlowColor() {
    switch (widget.emotion) {
      case ExpertEmotion.happy:
      case ExpertEmotion.celebrating:
        return AppColors.success;
      case ExpertEmotion.focused:
      case ExpertEmotion.encouraging:
        return AppColors.primary;
      case ExpertEmotion.concerned:
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }
  
  Gradient _getAvatarGradient() {
    switch (widget.emotion) {
      case ExpertEmotion.happy:
      case ExpertEmotion.celebrating:
        return LinearGradient(
          colors: [AppColors.success, AppColors.success.withOpacity(0.7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case ExpertEmotion.concerned:
        return LinearGradient(
          colors: [AppColors.warning, AppColors.warning.withOpacity(0.7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      default:
        return AppColors.primaryGradient;
    }
  }
  
  Color _getBorderColor() {
    if (widget.isProcessing) return AppColors.secondary;
    
    switch (widget.state) {
      case AvatarStateType.listening:
        return AppColors.success;
      case AvatarStateType.speaking:
        return AppColors.primary;
      case AvatarStateType.celebrating:
        return AppColors.success;
      case AvatarStateType.concerned:
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }
  
  Color _getShadowColor() {
    return _getBorderColor().withOpacity(0.3);
  }
  
  Color _getAvatarColor() {
    return _getBorderColor();
  }
  
  IconData _getAvatarIcon() {
    switch (widget.state) {
      case AvatarStateType.listening:
        return Icons.mic;
      case AvatarStateType.processing:
        return Icons.psychology;
      case AvatarStateType.speaking:
      case AvatarStateType.explaining:
        return Icons.chat_bubble;
      case AvatarStateType.celebrating:
        return Icons.celebration;
      case AvatarStateType.concerned:
        return Icons.help_outline;
      default:
        return Icons.psychology;
    }
  }
  
  Color _getStateColor() {
    switch (widget.state) {
      case AvatarStateType.listening:
        return AppColors.success;
      case AvatarStateType.processing:
        return AppColors.secondary;
      case AvatarStateType.speaking:
      case AvatarStateType.explaining:
        return AppColors.primary;
      case AvatarStateType.celebrating:
        return AppColors.success;
      case AvatarStateType.concerned:
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }
  
  IconData _getStateIcon() {
    switch (widget.state) {
      case AvatarStateType.listening:
        return Icons.mic;
      case AvatarStateType.processing:
        return Icons.hourglass_top;
      case AvatarStateType.speaking:
        return Icons.volume_up;
      case AvatarStateType.explaining:
        return Icons.lightbulb;
      case AvatarStateType.celebrating:
        return Icons.celebration;
      case AvatarStateType.concerned:
        return Icons.warning;
      default:
        return Icons.circle;
    }
  }
  
  String _getStateText() {
    switch (widget.state) {
      case AvatarStateType.listening:
        return 'Listening';
      case AvatarStateType.processing:
        return 'Thinking';
      case AvatarStateType.speaking:
        return 'Speaking';
      case AvatarStateType.explaining:
        return 'Explaining';
      case AvatarStateType.celebrating:
        return 'Celebrating';
      case AvatarStateType.concerned:
        return 'Concerned';
      default:
        return '';
    }
  }
  
  Future<bool> _checkAssetExists(String path) async {
    try {
      // In a real app, you'd check if the asset exists
      // For demo purposes, we'll assume they don't exist and use fallback
      return false;
    } catch (e) {
      return false;
    }
  }
}