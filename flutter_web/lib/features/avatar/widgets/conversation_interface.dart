// lib/features/avatar/widgets/conversation_interface.dart
// Multi-Modal Conversation System (Voice + Text)
// Core of "Personal AI Expert" experience - natural conversation drives everything

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../providers/conversation_provider.dart';
import '../models/conversation_message.dart';
import 'voice_input_button.dart';
import 'conversation_history.dart';

/// Multi-Modal Conversation Interface
/// Supports both voice and text input seamlessly
/// This is what makes ArionComply revolutionary - conversation drives everything
class ConversationInterface extends ConsumerStatefulWidget {
  final bool isEnabled;
  final Function(String) onMessage;
  final VoidCallback onVoiceToggle;

  const ConversationInterface({
    super.key,
    required this.isEnabled,
    required this.onMessage,
    required this.onVoiceToggle,
  });

  @override
  ConsumerState<ConversationInterface> createState() => 
      _ConversationInterfaceState();
}

class _ConversationInterfaceState extends ConsumerState<ConversationInterface>
    with TickerProviderStateMixin {
  
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _textFocusNode = FocusNode();
  
  late AnimationController _slideController;
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeConversation();
  }
  
  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideController.forward();
  }
  
  void _initializeConversation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Start with welcome message from avatar
      ref.read(conversationProvider.notifier).addWelcomeMessage();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _textFocusNode.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversation = ref.watch(conversationProvider);
    
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      )),
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.conversationBackground,
          border: Border(
            left: BorderSide(color: AppColors.border.withOpacity(0.2)),
          ),
        ),
        child: Column(
          children: [
            // Conversation Header
            _buildConversationHeader(conversation),
            
            // Conversation History
            Expanded(
              child: _buildConversationHistory(conversation),
            ),
            
            // Input Interface
            _buildInputInterface(conversation),
          ],
        ),
      ),
    );
  }

  /// Conversation header with mode indicators
  Widget _buildConversationHeader(ConversationState conversation) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          // Conversation mode indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  conversation.isVoiceMode ? Icons.mic : Icons.chat_bubble_outline,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  conversation.isVoiceMode ? 'Voice' : 'Text',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Clear conversation button
          IconButton(
            icon: Icon(Icons.refresh, size: 20, color: AppColors.textSecondary),
            onPressed: () => _clearConversation(),
            tooltip: 'Start New Conversation',
          ),
        ],
      ),
    );
  }

  /// Conversation history display
  Widget _buildConversationHistory(ConversationState conversation) {
    return ConversationHistory(
      messages: conversation.messages,
      scrollController: _scrollController,
      isProcessing: conversation.isProcessing,
    );
  }

  /// Multi-modal input interface (voice + text)
  Widget _buildInputInterface(ConversationState conversation) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border.withOpacity(0.1)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick suggestion chips
          if (conversation.showSuggestions)
            _buildSuggestionChips(conversation),
          
          const SizedBox(height: 12),
          
          // Main input row
          Row(
            children: [
              // Voice input button
              VoiceInputButton(
                isActive: conversation.isListening,
                isEnabled: widget.isEnabled && !conversation.isProcessing,
                onPressed: () => _toggleVoiceInput(conversation),
                onLongPressStart: (_) => _startVoiceInput(),
                onLongPressEnd: (_) => _stopVoiceInput(),
              ),
              
              const SizedBox(width: 12),
              
              // Text input field
              Expanded(
                child: _buildTextInput(conversation),
              ),
              
              const SizedBox(width: 12),
              
              // Send button
              _buildSendButton(conversation),
            ],
          ),
          
          // Voice mode indicator
          if (conversation.isListening)
            _buildVoiceIndicator(),
        ],
      ),
    );
  }

  /// Quick suggestion chips for common questions
  Widget _buildSuggestionChips(ConversationState conversation) {
    final suggestions = [
      'Tell me about SOC 2',
      'Help me get started',
      'What frameworks do I need?',
      'Create a security policy',
    ];

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ActionChip(
            label: Text(
              suggestions[index],
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
              ),
            ),
            backgroundColor: AppColors.primary.withOpacity(0.1),
            side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
            onPressed: () => _sendSuggestionMessage(suggestions[index]),
          );
        },
      ),
    );
  }

  /// Text input field
  Widget _buildTextInput(ConversationState conversation) {
    return CustomTextField(
      controller: _textController,
      focusNode: _textFocusNode,
      hintText: conversation.isVoiceMode 
          ? 'Or type your message...' 
          : 'Ask your compliance expert anything...',
      enabled: widget.isEnabled && !conversation.isProcessing,
      maxLines: 3,
      minLines: 1,
      onSubmitted: (_) => _sendTextMessage(),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }

  /// Send message button
  Widget _buildSendButton(ConversationState conversation) {
    final hasText = _textController.text.trim().isNotEmpty;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: IconButton(
        icon: Icon(
          Icons.send_rounded,
          color: hasText && widget.isEnabled 
              ? AppColors.primary 
              : AppColors.textSecondary,
        ),
        onPressed: hasText && widget.isEnabled && !conversation.isProcessing
            ? _sendTextMessage
            : null,
        tooltip: 'Send Message',
      ),
    );
  }

  /// Voice input indicator
  Widget _buildVoiceIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulsing mic icon
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              _pulseController.repeat(reverse: true);
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.2),
                child: Icon(
                  Icons.mic,
                  color: AppColors.primary,
                  size: 20,
                ),
              );
            },
          ),
          
          const SizedBox(width: 8),
          
          Text(
            'Listening... Tap to stop',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Event Handlers

  void _toggleVoiceInput(ConversationState conversation) {
    if (conversation.isListening) {
      _stopVoiceInput();
    } else {
      _startVoiceInput();
    }
  }

  void _startVoiceInput() {
    ref.read(conversationProvider.notifier).startListening();
  }

  void _stopVoiceInput() {
    ref.read(conversationProvider.notifier).stopListening();
  }

  void _sendTextMessage() {
    final message = _textController.text.trim();
    if (message.isNotEmpty) {
      widget.onMessage(message);
      _textController.clear();
      ref.read(conversationProvider.notifier).addUserMessage(message);
    }
  }

  void _sendSuggestionMessage(String suggestion) {
    widget.onMessage(suggestion);
    ref.read(conversationProvider.notifier).addUserMessage(suggestion);
  }

  void _clearConversation() {
    ref.read(conversationProvider.notifier).clearConversation();
  }
}

// lib/features/avatar/models/conversation_message.dart
// Message models for conversation system

enum MessageType {
  user,
  avatar,
  system,
  error,
}

enum MessageSource {
  text,
  voice,
  suggestion,
  system,
}

class ConversationMessage {
  final String id;
  final MessageType type;
  final MessageSource source;
  final String content;
  final DateTime timestamp;
  final bool isProcessing;
  final Map<String, dynamic>? metadata;

  const ConversationMessage({
    required this.id,
    required this.type,
    required this.source,
    required this.content,
    required this.timestamp,
    this.isProcessing = false,
    this.metadata,
  });

  ConversationMessage copyWith({
    String? id,
    MessageType? type,
    MessageSource? source,
    String? content,
    DateTime? timestamp,
    bool? isProcessing,
    Map<String, dynamic>? metadata,
  }) {
    return ConversationMessage(
      id: id ?? this.id,
      type: type ?? this.type,
      source: source ?? this.source,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isProcessing: isProcessing ?? this.isProcessing,
      metadata: metadata ?? this.metadata,
    );
  }
}
