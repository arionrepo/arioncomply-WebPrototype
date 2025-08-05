// lib/features/framework/screens/framework_selection_screen.dart
// ArionComply Framework Selection - Avatar-driven conversation interface
// NOT traditional selection UI - Avatar guides user through framework choice

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/responsive_layout.dart';
import '../../avatar/widgets/avatar_3d_display.dart';
import '../../avatar/widgets/conversation_interface.dart';
import '../../avatar/providers/avatar_state_provider.dart';
import '../../avatar/providers/conversation_provider.dart';

/// Framework Selection via Avatar Conversation
/// User doesn't pick from a list - Avatar asks questions and recommends
class FrameworkSelectionScreen extends ConsumerStatefulWidget {
  final String? selectedFramework;
  final String? marketingSource;
  final bool autoStart;
  
  const FrameworkSelectionScreen({
    super.key,
    this.selectedFramework,
    this.marketingSource,
    this.autoStart = false,
  });

  @override
  ConsumerState<FrameworkSelectionScreen> createState() => _FrameworkSelectionScreenState();
}

class _FrameworkSelectionScreenState extends ConsumerState<FrameworkSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _enterController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeFrameworkSelection();
  }

  void _initializeAnimations() {
    _enterController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _enterController.forward();
  }

  void _initializeFrameworkSelection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _isInitialized = true;
        _handleInitialContext();
      }
    });
  }

  void _handleInitialContext() {
    final conversationNotifier = ref.read(conversationProvider.notifier);
    
    if (widget.selectedFramework != null) {
      // Pre-selected framework (from marketing/deep link)
      _handlePreselectedFramework();
    } else if (widget.autoStart) {
      // Auto-start conversation
      conversationNotifier.startFrameworkDiscovery();
    } else {
      // Normal entry - Avatar introduces framework selection
      conversationNotifier.introduceFrameworkSelection();
    }
  }

  void _handlePreselectedFramework() {
    final conversationNotifier = ref.read(conversationProvider.notifier);
    final frameworkName = _getFrameworkDisplayName(widget.selectedFramework!);
    
    conversationNotifier.confirmFrameworkChoice(
      framework: widget.selectedFramework!,
      source: widget.marketingSource,
    );
  }

  String _getFrameworkDisplayName(String frameworkId) {
    final frameworks = {
      'soc2': 'SOC 2',
      'gdpr': 'GDPR',
      'iso27001': 'ISO 27001',
      'hipaa': 'HIPAA',
      'pci-dss': 'PCI DSS',
      'nist': 'NIST Cybersecurity Framework',
    };
    return frameworks[frameworkId] ?? frameworkId.toUpperCase();
  }

  @override
  void dispose() {
    _enterController.dispose();
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
    );
  }

  Widget _buildMobileLayout() {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildAvatarInterface(),
          ),
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
            child: _buildAvatarInterface(),
          ),
          Expanded(
            flex: 2,
            child: _buildFrameworkContext(),
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
            flex: 2,
            child: _buildAvatarInterface(),
          ),
          Expanded(
            flex: 3,
            child: _buildFrameworkContext(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.arrow_back),
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            'Choose Your Framework',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        TextButton.icon(
          onPressed: () => context.go('/chat'),
          icon: const Icon(Icons.chat_bubble_outline, size: 18),
          label: const Text('Chat Only'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: () => context.go('/demo'),
          icon: const Icon(Icons.play_circle_outline, size: 18),
          label: const Text('Demo'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarInterface() {
    return AnimatedBuilder(
      animation: _enterController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_enterController.value * 0.2),
          child: Opacity(
            opacity: _enterController.value,
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Avatar Display
                const SizedBox(
                  height: 200,
                  child: Avatar3DDisplay(),
                ),
                const SizedBox(height: 20),
                // Conversation Interface
                const Expanded(
                  child: ConversationInterface(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFrameworkContext() {
    final conversation = ref.watch(conversationProvider);
    
    return Container(
      padding: const EdgeInsets.all(24),
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
            'Framework Selection',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Our AI expert will help you choose the right compliance framework based on your company\'s needs.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          
          if (conversation.currentFramework != null) ...[
            _buildCurrentFrameworkCard(conversation.currentFramework!),
            const SizedBox(height: 24),
          ],
          
          _buildFrameworkOverview(),
          
          const Spacer(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildCurrentFrameworkCard(String framework) {
    final frameworkData = _getFrameworkData(framework);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                frameworkData['icon'],
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                frameworkData['name'],
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            frameworkData['description'],
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrameworkOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Frameworks',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ..._getAllFrameworks().map((framework) => _buildFrameworkListItem(framework)),
      ],
    );
  }

  Widget _buildFrameworkListItem(Map<String, dynamic> framework) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            framework['icon'],
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            framework['name'],
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _startAssessment(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Start Assessment'),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => _resetSelection(),
          child: const Text('Choose Different Framework'),
        ),
      ],
    );
  }

  void _startAssessment() {
    final conversation = ref.read(conversationProvider);
    if (conversation.currentFramework != null) {
      context.go('/assessment/${conversation.currentFramework}');
    }
  }

  void _resetSelection() {
    ref.read(conversationProvider.notifier).resetFrameworkSelection();
  }

  Map<String, dynamic> _getFrameworkData(String frameworkId) {
    final frameworks = _getAllFrameworks();
    return frameworks.firstWhere(
      (f) => f['id'] == frameworkId,
      orElse: () => frameworks.first,
    );
  }

  List<Map<String, dynamic>> _getAllFrameworks() {
    return [
      {
        'id': 'soc2',
        'name': 'SOC 2',
        'icon': Icons.security,
        'description': 'Service Organization Control 2 - Data security and availability',
      },
      {
        'id': 'gdpr',
        'name': 'GDPR',
        'icon': Icons.privacy_tip,
        'description': 'General Data Protection Regulation - EU privacy compliance',
      },
      {
        'id': 'iso27001',
        'name': 'ISO 27001',
        'icon': Icons.verified_user,
        'description': 'Information Security Management System standard',
      },
      {
        'id': 'hipaa',
        'name': 'HIPAA',
        'icon': Icons.local_hospital,
        'description': 'Health Insurance Portability and Accountability Act',
      },
      {
        'id': 'pci-dss',
        'name': 'PCI DSS',
        'icon': Icons.credit_card,
        'description': 'Payment Card Industry Data Security Standard',
      },
      {
        'id': 'nist',
        'name': 'NIST CSF',
        'icon': Icons.shield,
        'description': 'NIST Cybersecurity Framework',
      },
    ];
  }
}