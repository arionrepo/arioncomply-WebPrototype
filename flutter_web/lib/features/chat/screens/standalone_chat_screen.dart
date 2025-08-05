// lib/features/chat/screens/standalone_chat_screen.dart
// ArionComply Standalone Chat - Pure chat interface without avatar
// Minimal interface for users who prefer traditional chat

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/responsive_layout.dart';
import '../../avatar/providers/conversation_provider.dart';
import '../../avatar/models/conversation_message.dart';
import '../../avatar/widgets/voice_input_button.dart';

/// Standalone Chat Screen - Traditional chat interface
/// For users who prefer chat-only interaction without avatar
class StandaloneChatScreen extends ConsumerStatefulWidget {
  final String? initialContext;
  
  const StandaloneChatScreen({
    super.key,
    this.initialContext,
  });

  @override
  ConsumerState<StandaloneChatScreen> createState() => _StandaloneChatScreenState();
}

class _StandaloneChatScreenState extends ConsumerState<StandaloneChatScreen>
    with TickerProviderStateMixin {
  late TextEditingController _messageController;
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  
  bool _isTyping = false;
  bool _showScrollToBottom = false;
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeChat();
  }

  void _initializeControllers() {
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scrollController.addListener(_handleScroll);
    _fadeController.forward();
  }

  void _initializeChat() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final conversationNotifier = ref.read(conversationProvider.notifier);
      conversationNotifier.initializeStandaloneChat(
        context: widget.initialContext,
      );
    });
  }

  void _handleScroll() {
    final showScrollButton = _scrollController.hasClients &&
        _scrollController.offset > 100;
    
    if (showScrollButton != _showScrollToBottom) {
      setState(() {
        _showScrollToBottom = showScrollButton;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
      floatingActionButton: _showScrollToBottom ? _buildScrollToBottomFAB() : null,
    );
  }

  Widget _buildMobileLayout() {
    return SafeArea(
      child: Column(
        children: [
          _buildChatHeader(),
          Expanded(
            child: _buildChatContent(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SafeArea(
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildChatHeader(),
                Expanded(child: _buildChatContent()),
                _buildMessageInput(),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: _buildChatSidebar(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SafeArea(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: _buildChatSidebar(),
          ),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildChatHeader(),
                Expanded(child: _buildChatContent()),
                _buildMessageInput(),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: _buildChatInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.arrow_back),
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          
          // AI Status Indicator
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.smart_toy,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Compliance Expert',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Ready to help with compliance questions',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          _buildChatActions(),
        ],
      ),
    );
  }

  Widget _buildChatActions() {
    return Row(
      children: [
        IconButton(
          onPressed: () => _exportChat(),
          icon: const Icon(Icons.download),
          color: AppColors.textSecondary,
          tooltip: 'Export Chat',
        ),
        IconButton(
          onPressed: () => _clearChat(),
          icon: const Icon(Icons.clear_all),
          color: AppColors.textSecondary,
          tooltip: 'Clear Chat',
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
          onSelected: _handleMenuSelection,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'avatar',
              child: Row(
                children: [
                  Icon(Icons.person),
                  SizedBox(width: 8),
                  Text('Switch to Avatar Mode'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'assessment',
              child: Row(
                children: [
                  Icon(Icons.assignment),
                  SizedBox(width: 8),
                  Text('Start Assessment'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 8),
                  Text('Chat Settings'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChatContent() {
    final conversation = ref.watch(conversationProvider);
    
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeController.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: conversation.messages.isEmpty
                ? _buildEmptyState()
                : _buildMessageList(conversation.messages),
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
            Icons.chat_bubble_outline,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Start a Conversation',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me anything about compliance, frameworks, or regulations',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildQuickStartButtons(),
        ],
      ),
    );
  }

  Widget _buildQuickStartButtons() {
    final quickStarts = [
      {'text': 'What is SOC 2?', 'query': 'Tell me about SOC 2 compliance'},
      {'text': 'GDPR basics', 'query': 'Explain GDPR requirements'},
      {'text': 'Start assessment', 'query': 'I want to start a compliance assessment'},
    ];
    
    return Column(
      children: quickStarts.map((item) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        width: 250,
        child: OutlinedButton(
          onPressed: () => _sendQuickStart(item['query']!),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Text(item['text']!),
        ),
      )).toList(),
    );
  }

  Widget _buildMessageList(List<ConversationMessage> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      itemCount: messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && _isTyping) {
          return _buildTypingIndicator();
        }
        return _buildMessageBubble(messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(ConversationMessage message) {
    final isUser = message.sender == MessageSender.user;
    
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
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser 
                    ? AppColors.primary
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: isUser ? null : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : null,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isUser 
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (message.metadata.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildMessageMetadata(message.metadata, isUser),
                  ],
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
        Icons.smart_toy,
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
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: metadata.entries.map((entry) => Chip(
        label: Text(
          '${entry.key}: ${entry.value}',
          style: AppTextStyles.bodySmall.copyWith(
            color: isUser ? Colors.white : AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
        backgroundColor: isUser 
            ? Colors.white.withOpacity(0.2)
            : AppColors.primary.withOpacity(0.1),
        side: BorderSide.none,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                  width: 20,
                  height: 20,
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

  Widget _buildMessageInput() {
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask about compliance, regulations, or frameworks...',
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
              ),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              onSubmitted: _handleSubmit,
              onChanged: _handleTextChange,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          
          // Voice Input Button
          const VoiceInputButton(),
          
          const SizedBox(width: 8),
          
          // Send Button
          Container(
            decoration: BoxDecoration(
              color: _messageController.text.trim().isNotEmpty
                  ? AppColors.primary
                  : AppColors.textSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: _messageController.text.trim().isNotEmpty
                  ? () => _handleSubmit(_messageController.text)
                  : null,
              icon: const Icon(Icons.send),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatSidebar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(
            color: AppColors.border.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chat Features',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureList(),
        ],
      ),
    );
  }

  Widget _buildChatInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          left: BorderSide(
            color: AppColors.border.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chat Information',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildChatStats(),
        ],
      ),
    );
  }

  Widget _buildFeatureList() {
    final features = [
      'Ask compliance questions',
      'Get framework explanations',
      'Start assessments',
      'Export conversations',
      'Voice input support',
    ];
    
    return Column(
      children: features.map((feature) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.primary,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                feature,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildChatStats() {
    final conversation = ref.watch(conversationProvider);
    
    return Column(
      children: [
        _buildStatRow('Messages', '${conversation.messages.length}'),
        _buildStatRow('Session', '15 min'),
        _buildStatRow('Mode', 'Chat Only'),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollToBottomFAB() {
    return FloatingActionButton.small(
      onPressed: _scrollToBottom,
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
    );
  }

  void _handleSubmit(String text) {
    if (text.trim().isEmpty) return;
    
    final conversationNotifier = ref.read(conversationProvider.notifier);
    conversationNotifier.sendMessage(text.trim());
    
    _messageController.clear();
    _scrollToBottom();
    
    setState(() {
      _isTyping = true;
    });
    
    // Simulate AI response delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
        _scrollToBottom();
      }
    });
  }

  void _handleTextChange(String text) {
    setState(() {}); // Rebuild to update send button state
  }

  void _sendQuickStart(String query) {
    _messageController.text = query;
    _handleSubmit(query);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _exportChat() {
    // Implement chat export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chat export functionality coming soon')),
    );
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear the conversation history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(conversationProvider.notifier).clearConversation();
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'avatar':
        context.go('/');
        break;
      case 'assessment':
        context.go('/frameworks');
        break;
      case 'settings':
        // Implement settings
        break;
    }
  }
}