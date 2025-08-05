// lib/features/avatar/screens/avatar_home_screen.dart
// ArionComply Avatar-First Interface
// Revolutionary primary interface - NOT traditional UI with chat
// Avatar as main interface, conversation drives everything

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';


import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/responsive_layout.dart';
import '../providers/avatar_state_provider.dart';
import '../widgets/avatar_3d_display.dart';
import '../widgets/conversation_interface.dart';
import '../widgets/avatar_status_indicator.dart';
import '../widgets/voice_input_button.dart';

/// PRIMARY SCREEN - Avatar-First Interface
/// This is what users see first - NOT traditional web UI
/// Avatar drives all interactions through conversation
class AvatarHomeScreen extends ConsumerStatefulWidget {
  const AvatarHomeScreen({super.key});

  @override
  ConsumerState<AvatarHomeScreen> createState() => _AvatarHomeScreenState();
}

class _AvatarHomeScreenState extends ConsumerState<AvatarHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeAvatar();
  }
  
  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Start entrance animation
    _fadeController.forward();
    _scaleController.forward();
  }
  
  void _initializeAvatar() {
    // Initialize avatar with welcome message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(avatarStateProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatarState = ref.watch(avatarStateProvider);
    
    return Scaffold(
      backgroundColor: AppColors.avatarBackground,
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(avatarState),
        tablet: _buildTabletLayout(avatarState),
        desktop: _buildDesktopLayout(avatarState),
      ),
    );
  }

  /// Mobile Layout - Vertical stack with avatar on top
  Widget _buildMobileLayout(AvatarState avatarState) {
    return SafeArea(
      child: Column(
        children: [
          // Avatar Status Bar
          _buildAvatarStatusBar(avatarState),
          
          // Main Avatar Display (60% of screen)
          Expanded(
            flex: 6,
            child: _buildAvatarDisplay(avatarState),
          ),
          
          // Conversation Interface (40% of screen)
          Expanded(
            flex: 4,
            child: _buildConversationInterface(avatarState),
          ),
        ],
      ),
    );
  }

  /// Tablet Layout - Side-by-side with more space
  Widget _buildTabletLayout(AvatarState avatarState) {
    return SafeArea(
      child: Row(
        children: [
          // Avatar Display (60% width)
          Expanded(
            flex: 6,
            child: Column(
              children: [
                _buildAvatarStatusBar(avatarState),
                Expanded(child: _buildAvatarDisplay(avatarState)),
              ],
            ),
          ),
          
          // Conversation Interface (40% width)
          Expanded(
            flex: 4,
            child: _buildConversationInterface(avatarState),
          ),
        ],
      ),
    );
  }

  /// Desktop Layout - Optimized for larger screens
  Widget _buildDesktopLayout(AvatarState avatarState) {
    return SafeArea(
      child: Row(
        children: [
          // Avatar Display (70% width)
          Expanded(
            flex: 7,
            child: Column(
              children: [
                _buildAvatarStatusBar(avatarState),
                Expanded(child: _buildAvatarDisplay(avatarState)),
              ],
            ),
          ),
          
          // Conversation Interface (30% width)
          Expanded(
            flex: 3,
            child: _buildConversationInterface(avatarState),
          ),
        ],
      ),
    );
  }

  /// Avatar Status Bar - Shows avatar state and controls
  Widget _buildAvatarStatusBar(AvatarState avatarState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.95),
        border: Border(
          bottom: BorderSide(color: AppColors.border.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          // Avatar Status Indicator
          AvatarStatusIndicator(
            state: avatarState.currentState,
            isProcessing: avatarState.isProcessing,
          ),
          
          const SizedBox(width: 12),
          
          // Avatar Name and Role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  avatarState.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  avatarState.role,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Voice Settings Button
          IconButton(
            icon: Icon(
              avatarState.voiceEnabled ? Icons.volume_up : Icons.volume_off,
              color: AppColors.primary,
            ),
            onPressed: () => ref.read(avatarStateProvider.notifier).toggleVoice(),
            tooltip: 'Toggle Voice Output',
          ),
        ],
      ),
    );
  }

  /// Main Avatar Display - 3D Avatar with animations
  Widget _buildAvatarDisplay(AvatarState avatarState) {
    return FadeTransition(
      opacity: _fadeController,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
        ),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.avatarBackground,
                AppColors.avatarBackground.withOpacity(0.8),
              ],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background Effects
              _buildBackgroundEffects(),
              
              // Main Avatar
              Avatar3DDisplay(
                state: avatarState.currentState,
                isProcessing: avatarState.isProcessing,
                emotion: avatarState.currentEmotion,
              ),
              
              // Avatar Speech Bubble (when speaking)
              if (avatarState.isProcessing || avatarState.currentMessage.isNotEmpty)
                Positioned(
                  bottom: 80,
                  left: 20,
                  right: 20,
                  child: _buildSpeechBubble(avatarState),
                ),
              
              // Quick Action Hints
              if (avatarState.showHints)
                Positioned(
                  bottom: 20,
                  child: _buildQuickActionHints(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Background visual effects for avatar area
  Widget _buildBackgroundEffects() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Floating particles animation
          Positioned.fill(
            child: Lottie.asset(
              'assets/animations/floating_particles.json',
              fit: BoxFit.cover,
              repeat: true,
            ),
          ),
          
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  Colors.transparent,
                  AppColors.primary.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Speech bubble for avatar messages
  Widget _buildSpeechBubble(AvatarState avatarState) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (avatarState.isProcessing)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Thinking...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            )
          else
            Text(
              avatarState.currentMessage,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textPrimary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  /// Quick action hints for new users
  Widget _buildQuickActionHints() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lightbulb_outline, 
               size: 16, 
               color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            'Try: "Tell me about SOC 2" or "Help me get started"',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Conversation Interface - Multi-modal input/output
  Widget _buildConversationInterface(AvatarState avatarState) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          left: BorderSide(color: AppColors.border.withOpacity(0.3)),
        ),
      ),
      child: ConversationInterface(
        isEnabled: !avatarState.isProcessing,
        onMessage: (message) {
          ref.read(avatarStateProvider.notifier).processUserMessage(message);
        },
        onVoiceToggle: () {
          ref.read(avatarStateProvider.notifier).toggleVoiceInput();
        },
      ),
    );
  }
}

// lib/features/avatar/models/avatar_state.dart
// Avatar state management for conversation-driven interface

enum AvatarStateType {
  idle,
  listening,
  processing,
  speaking,
  explaining,
  celebrating,
  concerned,
}

enum AvatarEmotion {
  neutral,
  happy,
  focused,
  encouraging,
  serious,
  celebrating,
}

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
    );
  }
}