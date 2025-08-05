// lib/features/avatar/widgets/conversation_interface.dart
// ArionComply Conversation Interface - Core conversation UI component
// Main interface for user interaction with the AI expert

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/conversation_provider.dart';
import '../providers/voice_provider.dart';
import '../models/conversation_message.dart';
import 'voice_input_button.dart';

/// Main conversation interface widget
/// Displays conversation history and handles user input
class ConversationInterface extends ConsumerStatefulWidget {
  final bool showVoiceButton;
  final bool showInputField;
  final String? placeholder;
  final Function(String)? onMessageSent;
  
  const ConversationInterface({
    super.key,
    this.showVoiceButton = true,
    this.showInputField = true,
    this.placeholder,
    this.onMessageSent,
  });

  @override
  ConsumerState<ConversationInterface> createState() => _ConversationInterfaceState();
}

class _ConversationInterfaceState extends ConsumerState<ConversationInterface>
    with TickerProviderStateMixin {
  late TextEditingController _textController;
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  
  bool _isComposing = false;
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _textController = TextEditingController();
    _scrollController = ScrollController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _textController.addListener(_handleTextChange);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversation = ref.watch(conversationProvider);
    
    return Column(
      children: [
        // Conversation History
        Expanded(
          child: _buildConversationHistory(conversation),
        ),
        
        // Input Interface
        if (widget.showInputField || widget.showVoiceButton)
          _buildInputInterface(conversation),
      ],
    );
  }

  Widget _buildConversationHistory(ConversationState conversation) {
    if (conversation.messages.isEmpty) {
      return _buildEmptyState();
    }
    
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeController.value,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: conversation.messages.length + (conversation.isProcessing ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == conversation.messages.length && conversation.isProcessing) {
                return _buildTypingIndicator();
              }
              return _buildMessageBubble(conversation.messages[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.psychology,
            size: 64,
            color: AppColors.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Hi! I\'m your AI compliance expert',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me anything about compliance frameworks,\nregulations, or requirements',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildSuggestionChips(),
        ],
      ),
    );
  }

  Widget _buildSuggestionChips() {
    final suggestions = [
      'What is SOC 2?',
      'Help me choose a framework',
      'Start an assessment',
    ];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: suggestions.map((suggestion) => ActionChip(
        label: Text(suggestion),
        onPressed: () => _sendMessage(suggestion),
        backgroundColor: AppColors.surface,
        side: BorderSide(
          color: AppColors.primary.withOpacity(0.3),
        ),
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primary,
        ),
      )).toList(),
    );
  }

  Widget _buildMessageBubble(ConversationMessage message) {
    final isUser = message.type == MessageType.user;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAvatarIcon(),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: isUser ? null : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : null,
                ),
                border: isUser ? null : Border.all(
                  color: AppColors.border.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isUser ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  if (message.metadata.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _buildMessageMetadata(message.metadata, isUser),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    _formatMessageTime(message.timestamp),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isUser 
                          ? Colors.white.withOpacity(0.7)
                          : AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: 8),
            _buildUserIcon(),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatarIcon() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.psychology,
        color: AppColors.primary,
        size: 18,
      ),
    );
  }

  Widget _buildUserIcon() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.person,
        color: AppColors.textSecondary,
        size: 18,
      ),
    );
  }

  Widget _buildMessageMetadata(Map<String, dynamic> metadata, bool isUser) {
    if (metadata.isEmpty) return const SizedBox.shrink();
    
    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: metadata.entries.take(3).map((entry) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: isUser 
              ? Colors.white.withOpacity(0.2)
              : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${entry.key}: ${entry.value}',
          style: AppTextStyles.bodySmall.copyWith(
            color: isUser ? Colors.white : AppColors.textSecondary,
            fontSize: 9,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          _buildAvatarIcon(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
              border: Border.all(
                color: AppColors.border.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Thinking',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputInterface(ConversationState conversation) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border.withOpacity(0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (widget.showInputField) ...[
              Expanded(
                child: _buildTextInput(conversation),
              ),
              const SizedBox(width: 8),
            ],
            
            if (widget.showVoiceButton)
              VoiceInputButton(
                size: VoiceButtonSize.medium,
                style: VoiceButtonStyle.filled,
                onTranscription: _handleVoiceTranscription,
              ),
            
            if (widget.showInputField) ...[
              const SizedBox(width: 8),
              _buildSendButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput(ConversationState conversation) {
    return TextField(
      controller: _textController,
      decoration: InputDecoration(
        hintText: widget.placeholder ?? 'Ask me about compliance...',
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary.withOpacity(0.7),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: AppColors.border.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: AppColors.border.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: AppColors.primary,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        filled: true,
        fillColor: AppColors.background,
      ),
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textPrimary,
      ),
      onSubmitted: _handleSubmit,
      onChanged: _handleTextChange,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      enabled: !conversation.isProcessing,
    );
  }

  Widget _buildSendButton() {
    return Container(
      decoration: BoxDecoration(
        color: _isComposing && !ref.watch(conversationProvider).isProcessing
            ? AppColors.primary
            : AppColors.textSecondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        onPressed: _isComposing && !ref.watch(conversationProvider).isProcessing
            ? () => _handleSubmit(_textController.text)
            : null,
        icon: const Icon(Icons.send),
        color: Colors.white,
      ),
    );
  }

  void _handleTextChange(String text) {
    setState(() {
      _isComposing = text.trim().isNotEmpty;
    });
  }

  void _handleSubmit(String text) {
    if (text.trim().isEmpty) return;
    
    _sendMessage(text.trim());
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
  }

  void _sendMessage(String message) {
    // Send message through provider
    ref.read(conversationProvider.notifier).sendMessage(message);
    
    // Call optional callback
    widget.onMessageSent?.call(message);
    
    // Scroll to bottom
    _scrollToBottom();
  }

  void _handleVoiceTranscription(String transcription) {
    if (transcription.trim().isNotEmpty) {
      _sendMessage(transcription.trim());
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}