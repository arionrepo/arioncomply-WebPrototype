// lib/features/avatar/widgets/avatar_status_indicator.dart
// ArionComply Avatar Status Indicator
// Visual indicator showing avatar state, mood, and activity status

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/avatar_state.dart';
import '../providers/avatar_state_provider.dart';


/// Avatar Status Indicator - Shows current avatar state and mood
/// Provides visual feedback about what the avatar is doing
class AvatarStatusIndicator extends ConsumerStatefulWidget {
  final AvatarStatusSize size;
  final bool showLabel;
  final bool showMood;
  final VoidCallback? onTap;
  
  const AvatarStatusIndicator({
    super.key,
    this.size = AvatarStatusSize.medium,
    this.showLabel = true,
    this.showMood = false,
    this.onTap,
  });

  @override
  ConsumerState<AvatarStatusIndicator> createState() => _AvatarStatusIndicatorState();
}

class _AvatarStatusIndicatorState extends ConsumerState<AvatarStatusIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _breatheController;
  late AnimationController _fadeController;
  
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
    
    _breatheController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _breatheController.repeat(reverse: true);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _breatheController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatarState = ref.watch(avatarStateProvider);
    
    // Update animations based on avatar state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAnimations(avatarState);
    });
    
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _pulseController,
          _breatheController,
          _fadeController,
        ]),
        builder: (context, child) {
          return Container(
            padding: _getPadding(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusIndicator(avatarState),
                if (widget.showLabel) ...[
                  SizedBox(height: _getSpacing() * 0.5),
                  _buildStatusLabel(avatarState),
                ],
                if (widget.showMood) ...[
                  SizedBox(height: _getSpacing() * 0.3),
                  _buildMoodIndicator(avatarState),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusIndicator(AvatarState avatarState) {
    final statusConfig = _getStatusConfig(avatarState.currentState);
    final size = _getIndicatorSize();
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background circle
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: statusConfig.backgroundColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(size / 2),
          ),
        ),
        
        // Pulse effect for active states
        if (_shouldShowPulse(avatarState.currentState))
          Transform.scale(
            scale: 1.0 + (_pulseController.value * 0.3),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: statusConfig.backgroundColor.withOpacity(
                  0.3 * (1 - _pulseController.value),
                ),
                borderRadius: BorderRadius.circular(size / 2),
              ),
            ),
          ),
        
        // Breathing effect for idle state
        if (avatarState.currentState == AvatarCurrentState.idle)
          Transform.scale(
            scale: 1.0 + (_breatheController.value * 0.1),
            child: Container(
              width: size * 0.8,
              height: size * 0.8,
              decoration: BoxDecoration(
                color: statusConfig.backgroundColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(size / 2),
              ),
            ),
          ),
        
        // Main status icon
        Opacity(
          opacity: _fadeController.value,
          child: Icon(
            statusConfig.icon,
            color: statusConfig.iconColor,
            size: _getIconSize(),
          ),
        ),
        
        // Activity indicator for thinking/processing
        if (_shouldShowActivity(avatarState.currentState))
          _buildActivityIndicator(),
      ],
    );
  }

  Widget _buildActivityIndicator() {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        width: _getActivityIndicatorSize(),
        height: _getActivityIndicatorSize(),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(_getActivityIndicatorSize() / 2),
        ),
        child: Center(
          child: SizedBox(
            width: _getActivityIndicatorSize() * 0.6,
            height: _getActivityIndicatorSize() * 0.6,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusLabel(AvatarState avatarState) {
    final statusConfig = _getStatusConfig(avatarState.currentState);
    
    return Text(
      statusConfig.label,
      style: _getLabelTextStyle().copyWith(
        color: statusConfig.textColor,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildMoodIndicator(AvatarState avatarState) {
    final moodConfig = _getMoodConfig(avatarState.mood);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          moodConfig.icon,
          color: moodConfig.color,
          size: _getMoodIconSize(),
        ),
        SizedBox(width: _getSpacing() * 0.2),
        Text(
          moodConfig.label,
          style: _getMoodTextStyle().copyWith(
            color: moodConfig.color,
          ),
        ),
      ],
    );
  }

  void _updateAnimations(AvatarState avatarState) {
    switch (avatarState.currentState) {
      case AvatarCurrentState.speaking:
      case AvatarCurrentState.listening:
        if (!_pulseController.isAnimating) {
          _pulseController.repeat(reverse: true);
        }
        break;
      case AvatarCurrentState.thinking:
      case AvatarCurrentState.processing:
        if (!_pulseController.isAnimating) {
          _pulseController.repeat();
        }
        break;
      case AvatarCurrentState.idle:
        _pulseController.stop();
        _pulseController.reset();
        break;
      case AvatarCurrentState.error:
        _pulseController.stop();
        _pulseController.reset();
        break;
    }
  }

  bool _shouldShowPulse(AvatarCurrentState state) {
    return state == AvatarCurrentState.speaking ||
           state == AvatarCurrentState.listening;
  }

  bool _shouldShowActivity(AvatarCurrentState state) {
    return state == AvatarCurrentState.thinking ||
           state == AvatarCurrentState.processing;
  }

  StatusConfig _getStatusConfig(AvatarCurrentState state) {
    switch (state) {
      case AvatarCurrentState.idle:
        return StatusConfig(
          icon: Icons.psychology,
          label: 'Ready to help',
          backgroundColor: AppColors.primary,
          iconColor: AppColors.primary,
          textColor: AppColors.textPrimary,
        );
      case AvatarCurrentState.listening:
        return StatusConfig(
          icon: Icons.mic,
          label: 'Listening...',
          backgroundColor: AppColors.success,
          iconColor: AppColors.success,
          textColor: AppColors.success,
        );
      case AvatarCurrentState.thinking:
        return StatusConfig(
          icon: Icons.psychology,
          label: 'Thinking...',
          backgroundColor: AppColors.warning,
          iconColor: AppColors.warning,
          textColor: AppColors.warning,
        );
      case AvatarCurrentState.speaking:
        return StatusConfig(
          icon: Icons.record_voice_over,
          label: 'Speaking',
          backgroundColor: AppColors.primary,
          iconColor: AppColors.primary,
          textColor: AppColors.primary,
        );
      case AvatarCurrentState.processing:
        return StatusConfig(
          icon: Icons.settings,
          label: 'Processing...',
          backgroundColor: AppColors.info,
          iconColor: AppColors.info,
          textColor: AppColors.info,
        );
      case AvatarCurrentState.error:
        return StatusConfig(
          icon: Icons.error_outline,
          label: 'Something went wrong',
          backgroundColor: AppColors.error,
          iconColor: AppColors.error,
          textColor: AppColors.error,
        );
    }
  }

  MoodConfig _getMoodConfig(AvatarMood mood) {
    switch (mood) {
      case AvatarMood.neutral:
        return MoodConfig(
          icon: Icons.sentiment_neutral,
          label: 'Neutral',
          color: AppColors.textSecondary,
        );
      case AvatarMood.happy:
        return MoodConfig(
          icon: Icons.sentiment_very_satisfied,
          label: 'Happy',
          color: AppColors.success,
        );
      case AvatarMood.focused:
        return MoodConfig(
          icon: Icons.center_focus_strong,
          label: 'Focused',
          color: AppColors.primary,
        );
      case AvatarMood.concerned:
        return MoodConfig(
          icon: Icons.sentiment_dissatisfied,
          label: 'Concerned',
          color: AppColors.warning,
        );
      case AvatarMood.confused:
        return MoodConfig(
          icon: Icons.help_outline,
          label: 'Confused',
          color: AppColors.warning,
        );
    }
  }

  double _getIndicatorSize() {
    switch (widget.size) {
      case AvatarStatusSize.small:
        return 32;
      case AvatarStatusSize.medium:
        return 48;
      case AvatarStatusSize.large:
        return 64;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case AvatarStatusSize.small:
        return 16;
      case AvatarStatusSize.medium:
        return 24;
      case AvatarStatusSize.large:
        return 32;
    }
  }

  double _getActivityIndicatorSize() {
    switch (widget.size) {
      case AvatarStatusSize.small:
        return 12;
      case AvatarStatusSize.medium:
        return 16;
      case AvatarStatusSize.large:
        return 20;
    }
  }

  double _getMoodIconSize() {
    switch (widget.size) {
      case AvatarStatusSize.small:
        return 12;
      case AvatarStatusSize.medium:
        return 14;
      case AvatarStatusSize.large:
        return 16;
    }
  }

  double _getSpacing() {
    switch (widget.size) {
      case AvatarStatusSize.small:
        return 8;
      case AvatarStatusSize.medium:
        return 12;
      case AvatarStatusSize.large:
        return 16;
    }
  }

  EdgeInsets _getPadding() {
    final spacing = _getSpacing();
    return EdgeInsets.all(spacing * 0.5);
  }

  TextStyle _getLabelTextStyle() {
    switch (widget.size) {
      case AvatarStatusSize.small:
        return AppTextStyles.bodySmall;
      case AvatarStatusSize.medium:
        return AppTextStyles.bodyMedium;
      case AvatarStatusSize.large:
        return AppTextStyles.bodyLarge;
    }
  }

  TextStyle _getMoodTextStyle() {
    switch (widget.size) {
      case AvatarStatusSize.small:
        return AppTextStyles.bodySmall.copyWith(fontSize: 10);
      case AvatarStatusSize.medium:
        return AppTextStyles.bodySmall;
      case AvatarStatusSize.large:
        return AppTextStyles.bodyMedium;
    }
  }
}

/// Avatar status size options
enum AvatarStatusSize {
  small,
  medium,
  large,
}

/// Status configuration for different avatar states
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

/// Mood configuration for avatar emotions
class MoodConfig {
  final IconData icon;
  final String label;
  final Color color;

  const MoodConfig({
    required this.icon,
    required this.label,
    required this.color,
  });
}

/// Compact status indicator for minimal UI space
class CompactStatusIndicator extends ConsumerWidget {
  final bool showPulse;
  
  const CompactStatusIndicator({
    super.key,
    this.showPulse = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarState = ref.watch(avatarStateProvider);
    final statusConfig = _getStatusConfig(avatarState.currentState);
    
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: statusConfig.backgroundColor,
        borderRadius: BorderRadius.circular(6),
        boxShadow: showPulse && _shouldPulse(avatarState.currentState)
            ? [
                BoxShadow(
                  color: statusConfig.backgroundColor.withOpacity(0.6),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }

  StatusConfig _getStatusConfig(AvatarCurrentState state) {
    switch (state) {
      case AvatarCurrentState.idle:
        return StatusConfig(
          icon: Icons.circle,
          label: '',
          backgroundColor: AppColors.primary,
          iconColor: AppColors.primary,
          textColor: AppColors.textPrimary,
        );
      case AvatarCurrentState.listening:
        return StatusConfig(
          icon: Icons.circle,
          label: '',
          backgroundColor: AppColors.success,
          iconColor: AppColors.success,
          textColor: AppColors.success,
        );
      case AvatarCurrentState.thinking:
      case AvatarCurrentState.processing:
        return StatusConfig(
          icon: Icons.circle,
          label: '',
          backgroundColor: AppColors.warning,
          iconColor: AppColors.warning,
          textColor: AppColors.warning,
        );
      case AvatarCurrentState.speaking:
        return StatusConfig(
          icon: Icons.circle,
          label: '',
          backgroundColor: AppColors.primary,
          iconColor: AppColors.primary,
          textColor: AppColors.primary,
        );
      case AvatarCurrentState.error:
        return StatusConfig(
          icon: Icons.circle,
          label: '',
          backgroundColor: AppColors.error,
          iconColor: AppColors.error,
          textColor: AppColors.error,
        );
    }
  }

  bool _shouldPulse(AvatarCurrentState state) {
    return state == AvatarCurrentState.speaking ||
           state == AvatarCurrentState.listening ||
           state == AvatarCurrentState.thinking ||
           state == AvatarCurrentState.processing;
  }
}