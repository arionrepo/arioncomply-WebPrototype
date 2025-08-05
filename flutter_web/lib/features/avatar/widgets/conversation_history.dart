// lib/features/avatar/widgets/conversation_history.dart
// Conversation History Display - Shows expert-user conversation
// Key for building "my expert" relationship through visual conversation

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/conversation_message.dart';

class ConversationHistory extends StatefulWidget {
  final List<ConversationMessage> messages;
  final ScrollController? scrollController;
  final bool isProcessing;
  final bool showTimestamps;
  final bool enableSelection;

  const ConversationHistory({
    super.key,
    required this.messages,
    this.scrollController,
    this.isProcessing = false,
    this.showTimestamps = false,
    this.enableSelection = false,
  });

  @override
  State<ConversationHistory> createState() => _ConversationHistoryState();
}

class _ConversationHistoryState extends State<ConversationHistory>
    with TickerProviderStateMixin {
  
  late ScrollController _scrollController;
  late AnimationController _typingController;
  
  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    if (widget.isProcessing) {
      _typingController.repeat();
    }
  }

  @override
  void didUpdateWidget(ConversationHistory oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Auto-scroll to bottom when new messages arrive
    if (widget.messages.length > oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
    
    // Update typing animation
    if (widget.isProcessing != oldWidget.isProcessing) {
      if (widget.isProcessing) {
        _typingController.repeat();
      } else {
        _typingController.stop();
        _typingController.reset();
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    _typingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.conversationBackground,
      ),
      child: Column(
        children: [
          // Conversation header if needed
          if (widget.messages.isNotEmpty)
            _buildConversationHeader(),
          
          // Messages list
          Expanded(
            child: _buildMessagesList(),
          ),
          
          // Processing indicator
          if (widget.isProcessing)
            _buildProcessingIndicator(),
        ],
      ),
    );
  }

  /// Conversation header showing message count
  Widget _buildConversationHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            '${widget.messages.length} messages',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          if (widget.showTimestamps)
            Icon(
              Icons.schedule,
              size: 14,
              color: AppColors.textTertiary,
            ),
        ],
      ),
    );
  }

  /// Main messages list
  Widget _buildMessagesList() {
    if (widget.messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final message = widget.messages[index];
        final isFirstMessage = index == 0;
        final isLastMessage = index == widget.messages.length - 1;
        final previousMessage = index > 0 ? widget.messages[index - 1] : null;
        
        return _buildMessageBubble(
          message: message,
          isFirstMessage: isFirstMessage,
          isLastMessage: isLastMessage,
          showTimestamp: _shouldShowTimestamp(message, previousMessage),
        );
      },
    );
  }

  /// Empty state when no messages
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Start a conversation with your expert',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try asking about SOC 2, GDPR, or getting started',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  /// Individual message bubble
  Widget _buildMessageBubble({
    required ConversationMessage message,
    required bool isFirstMessage,
    required bool isLastMessage,
    required bool showTimestamp,
  }) {
    final isUser = message.type == MessageType.user;
    
    return Column(
      children: [
        // Timestamp if needed
        if (showTimestamp)
          _buildTimestamp(message.timestamp),
        
        // Message bubble
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: isUser 
                ? MainAxisAlignment.end 
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar for expert messages
              if (!isUser)
                _buildMessageAvatar(message),
              
              // Message content
              Flexible(
                child: _buildMessageContent(message, isUser),
              ),
              
              // Spacing for user messages
              if (isUser)
                const SizedBox(width: 48),
            ],
          ),
        ),
      ],
    );
  }

  /// Message avatar for expert messages
  Widget _buildMessageAvatar(ConversationMessage message) {
    return Container(
      margin: const EdgeInsets.only(right: 8, top: 4),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.primary,
        child: Icon(
          Icons.psychology,
          size: 18,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Message content bubble
  Widget _buildMessageContent(ConversationMessage message, bool isUser) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _getMessageBackgroundColor(message.type),
        borderRadius: _getMessageBorderRadius(isUser),
        border: Border.all(
          color: _getMessageBorderColor(message.type),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Message source indicator
          if (_shouldShowSourceIndicator(message))
            _buildSourceIndicator(message),
          
          // Message text
          SelectableText(
            message.content,
            style: _getMessageTextStyle(message.type),
            textAlign: TextAlign.left,
          ),
          
          // Message metadata
          if (message.metadata != null && message.metadata!.isNotEmpty)
            _buildMessageMetadata(message),
        ],
      ),
    );
  }

  /// Source indicator for voice/suggestion messages
  Widget _buildSourceIndicator(ConversationMessage message) {
    IconData icon;
    String label;
    
    switch (message.source) {
      case MessageSource.voice:
        icon = Icons.mic;
        label = 'Voice';
        break;
      case MessageSource.suggestion:
        icon = Icons.lightbulb_outline;
        label = 'Suggestion';
        break;
      default:
        return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  /// Message metadata display
  Widget _buildMessageMetadata(ConversationMessage message) {
    final metadata = message.metadata!;
    final hasConfidence = metadata.containsKey('confidence');
    final hasReasoningPath = metadata.containsKey('reasoning_path');
    
    if (!hasConfidence && !hasReasoningPath) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.border.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // AI Confidence indicator
          if (hasConfidence)
            _buildConfidenceIndicator(metadata['confidence'] as double),
          
          // Reasoning path for transparency
          if (hasReasoningPath)
            _buildReasoningPath(metadata['reasoning_path'] as String),
        ],
      ),
    );
  }

  /// AI Confidence indicator (key differentiator)
  Widget _buildConfidenceIndicator(double confidence) {
    final percentage = (confidence * 100).round();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.psychology,
          size: 12,
          color: AppColors.secondary,
        ),
        const SizedBox(width: 4),
        Text(
          'AI Confidence: $percentage%',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: confidence,
            child: Container(
              decoration: BoxDecoration(
                color: _getConfidenceColor(confidence),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// AI Reasoning path (transparency feature)
  Widget _buildReasoningPath(String reasoning) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.account_tree,
            size: 12,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              reasoning,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Timestamp display
  Widget _buildTimestamp(DateTime timestamp) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        DateFormat('MMM d, h:mm a').format(timestamp),
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  /// Processing indicator (typing animation)
  Widget _buildProcessingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Expert avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            child: Icon(
              Icons.psychology,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          
          // Typing indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.avatarMessageBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.border.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Expert is thinking',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 8),
                
                // Animated dots
                AnimatedBuilder(
                  animation: _typingController,
                  builder: (context, child) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (index) {
                        final delay = index * 0.2;
                        final value = (_typingController.value + delay) % 1.0;
                        final opacity = (0.4 + (0.6 * value)).clamp(0.0, 1.0);
                        
                        return Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(opacity),
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods

  bool _shouldShowTimestamp(ConversationMessage message, ConversationMessage? previousMessage) {
    if (!widget.showTimestamps) return false;
    if (previousMessage == null) return true;
    
    final timeDiff = message.timestamp.difference(previousMessage.timestamp);
    return timeDiff.inMinutes > 5;
  }

  bool _shouldShowSourceIndicator(ConversationMessage message) {
    return message.source == MessageSource.voice || 
           message.source == MessageSource.suggestion;
  }

  Color _getMessageBackgroundColor(MessageType type) {
    switch (type) {
      case MessageType.user:
        return AppColors.userMessageBackground;
      case MessageType.avatar:
        return AppColors.avatarMessageBackground;
      case MessageType.system:
        return AppColors.systemMessageBackground;
      case MessageType.error:
        return AppColors.errorBackground;
      default:
        return AppColors.surface;
    }
  }

  Color _getMessageBorderColor(MessageType type) {
    switch (type) {
      case MessageType.user:
        return AppColors.primary.withOpacity(0.2);
      case MessageType.avatar:
        return AppColors.border.withOpacity(0.3);
      case MessageType.system:
        return AppColors.border.withOpacity(0.2);
      case MessageType.error:
        return AppColors.error.withOpacity(0.3);
      default:
        return AppColors.border;
    }
  }

  BorderRadius _getMessageBorderRadius(bool isUser) {
    return BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isUser ? 18 : 6),
      bottomRight: Radius.circular(isUser ? 6 : 18),
    );
  }

  TextStyle _getMessageTextStyle(MessageType type) {
    switch (type) {
      case MessageType.user:
        return AppTextStyles.conversationMessage.copyWith(
          color: AppColors.textPrimary,
        );
      case MessageType.avatar:
        return AppTextStyles.avatarMessage.copyWith(
          color: AppColors.textPrimary,
        );
      case MessageType.system:
        return AppTextStyles.conversationMessage.copyWith(
          color: AppColors.textSecondary,
          fontStyle: FontStyle.italic,
        );
      case MessageType.error:
        return AppTextStyles.conversationMessage.copyWith(
          color: AppColors.error,
        );
      default:
        return AppTextStyles.conversationMessage;
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return AppColors.success;
    if (confidence >= 0.6) return AppColors.warning;
    return AppColors.error;
  }
}

// lib/shared/widgets/custom_text_field.dart
// Custom text field for conversation input



class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? hintText;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final Function(String)? onSubmitted;
  final Function(String)? onChanged;
  final InputDecoration? decoration;
  final TextStyle? style;

  const CustomTextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.hintText,
    this.enabled = true,
    this.maxLines,
    this.minLines,
    this.onSubmitted,
    this.onChanged,
    this.decoration,
    this.style,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        onSubmitted: widget.onSubmitted,
        onChanged: widget.onChanged,
        style: widget.style ?? AppTextStyles.bodyMedium,
        decoration: widget.decoration ?? InputDecoration(
          hintText: widget.hintText,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          filled: true,
          fillColor: AppColors.inputBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}