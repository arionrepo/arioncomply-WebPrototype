// FILE PATH: lib/features/avatar/widgets/conversation_interface.dart
// Conversation Interface Widget - Main chat interface

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Core imports
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/responsive_layout.dart';

// Providers
import '../providers/conversation_provider.dart';
import '../providers/avatar_state_provider.dart';

/// Main conversation interface widget
class ConversationInterface extends ConsumerStatefulWidget {
  final bool isEnabled;
  final Function(String)? onMessage;
  final VoidCallback? onVoiceToggle;

  const ConversationInterface({
    Key? key,
    this.isEnabled = true,
    this.onMessage,
    this.onVoiceToggle,
  }) : super(key: key);

  @override
  ConsumerState<ConversationInterface> createState() => _ConversationInterfaceState();
}

class _ConversationInterfaceState extends ConsumerState<ConversationInterface> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversation = ref.watch(conversationProvider);
    final avatarState = ref.watch(avatarStateProvider);

    return ResponsiveLayout(
      mobile: _buildMobileInterface(conversation, avatarState),
      tablet: _buildTabletInterface(conversation, avatarState),
      desktop: _buildDesktopInterface(conversation, avatarState),
    );
  }

  Widget _buildMobileInterface(conversation, avatarState) {
    return Column(
      children: [
        Expanded(child: _buildMessageList(conversation)),
        _buildMessageInput(conversation, avatarState),
      ],
    );
  }

  Widget _buildTabletInterface(conversation, avatarState) {
    return Column(
      children: [
        Expanded(child: _buildMessageList(conversation)),
        _buildMessageInput(conversation, avatarState),
      ],
    );
  }

  Widget _buildDesktopInterface(conversation, avatarState) {
    return Column(
      children: [
        Expanded(child: _buildMessageList(conversation)),
        _buildMessageInput(conversation, avatarState),
      ],
    );
  }

  Widget _buildMessageList(conversation) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: conversation.messages.length,
        itemBuilder: (context, index) {
          final message = conversation.messages[index];
          return _buildMessageBubble(message);
        },
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUserMessage = message['sender'] == 'user';
    final content = message['content']?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUserMessage 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (!isUserMessage) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: const Icon(
                Icons.psychology,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUserMessage 
                    ? AppColors.primary
                    : AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                content,
                style: TextStyle(
                  color: isUserMessage 
                      ? Colors.white
                      : AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (isUserMessage) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.secondary,
              child: const Icon(
                Icons.person,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput(conversation, avatarState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: widget.isEnabled && !conversation.isThinking,
              decoration: InputDecoration(
                hintText: conversation.isThinking 
                    ? 'Alex is thinking...'
                    : 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: _sendMessage,
              maxLines: null,
              textInputAction: TextInputAction.send,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: conversation.isThinking 
                ? null 
                : () => _sendMessage(_messageController.text),
            icon: conversation.isThinking
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  )
                : const Icon(Icons.send, color: AppColors.primary),
          ),
          if (widget.onVoiceToggle != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: widget.onVoiceToggle,
              icon: Icon(
                avatarState.voiceInputEnabled 
                    ? Icons.mic 
                    : Icons.mic_none,
                color: avatarState.voiceInputEnabled 
                    ? AppColors.success
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    // Send via callback if provided
    widget.onMessage?.call(text.trim());

    // Send via provider
    ref.read(conversationProvider.notifier).addUserMessage(text.trim());

    // Clear input
    _messageController.clear();

    // Scroll to bottom
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
}