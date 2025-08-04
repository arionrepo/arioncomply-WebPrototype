// FILE PATH: lib/features/embedding/screens/embedded_widget_screen.dart
// Embedded Widget Screen - Clean interface for marketing integration
// Optimized for iframe embedding in blog posts, landing pages, etc.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/app/app_config.dart';
import '../../avatar/screens/avatar_home_screen.dart';
import '../../framework/screens/framework_selection_screen.dart';
import '../widgets/embed_header.dart';
import '../widgets/lead_capture_form.dart';
import '../providers/embedding_provider.dart';

class EmbeddedWidgetScreen extends ConsumerStatefulWidget {
  final String? framework;
  final String? source;
  final bool minimal;

  const EmbeddedWidgetScreen({
    super.key,
    this.framework,
    this.source,
    this.minimal = false,
  });

  @override
  ConsumerState<EmbeddedWidgetScreen> createState() => _EmbeddedWidgetScreenState();
}

class _EmbeddedWidgetScreenState extends ConsumerState<EmbeddedWidgetScreen> {
  @override
  void initState() {
    super.initState();
    _initializeEmbedding();
  }

  void _initializeEmbedding() {
    // Configure app for embedded mode
    AppConfig.instance.initialize(
      embedded: true,
      source: widget.source,
    );

    // Track embedding analytics
    ref.read(embeddingProvider.notifier).trackEmbedLoad(
      framework: widget.framework,
      source: widget.source,
      minimal: widget.minimal,
    );
  }

  @override
  Widget build(BuildContext context) {
    final embeddingState = ref.watch(embeddingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Minimal header for embedding
          if (!widget.minimal)
            EmbedHeader(
              source: widget.source,
              onBrandingClick: () => _handleBrandingClick(),
            ),

          // Main embedded content
          Expanded(
            child: _buildEmbeddedContent(),
          ),

          // Lead capture footer (appears after interaction)
          if (embeddingState.showLeadCapture)
            _buildLeadCaptureSection(),
        ],
      ),
    );
  }

  /// Build embedded content based on configuration
  Widget _buildEmbeddedContent() {
    if (widget.framework != null) {
      return _buildFrameworkSpecificEmbed();
    } else {
      return _buildGeneralExpertEmbed();
    }
  }

  /// Framework-specific embedded widget
  Widget _buildFrameworkSpecificEmbed() {
    return FrameworkSelectionScreen(
      selectedFramework: widget.framework!,
      marketingSource: widget.source ?? 'embed',
      embedded: true,
      onComplete: (result) => _handleEmbedComplete(result),
    );
  }

  /// General expert chat embedded widget
  Widget _buildGeneralExpertEmbed() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 600),
      child: AvatarHomeScreen(
        embedded: true,
        initialMessage: _getInitialMessage(),
        onInteraction: () => _handleFirstInteraction(),
      ),
    );
  }

  /// Lead capture section that appears after engagement
  Widget _buildLeadCaptureSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: LeadCaptureForm(
        source: widget.source,
        framework: widget.framework,
        onSubmit: (leadData) => _handleLeadCapture(leadData),
        onSkip: () => _handleLeadSkip(),
      ),
    );
  }

  /// Get contextual initial message based on source
  String _getInitialMessage() {
    if (widget.framework != null) {
      return "Hi! I'm your ${widget.framework} compliance expert. Let me help you understand what's needed for certification.";
    }
    
    return "Hi! I'm ArionComply, your AI compliance expert. What compliance challenge can I help you with today?";
  }

  /// Handle branding click - opens full app
  void _handleBrandingClick() {
    ref.read(embeddingProvider.notifier).trackBrandingClick();
    context.go('/');
  }

  /// Handle first user interaction
  void _handleFirstInteraction() {
    ref.read(embeddingProvider.notifier).trackFirstInteraction();
    
    // Show lead capture after meaningful engagement
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        ref.read(embeddingProvider.notifier).showLeadCapture();
      }
    });
  }

  /// Handle embed completion
  void _handleEmbedComplete(Map<String, dynamic> result) {
    ref.read(embeddingProvider.notifier).trackEmbedComplete(result);
    ref.read(embeddingProvider.notifier).showLeadCapture();
  }

  /// Handle lead capture submission
  void _handleLeadCapture(Map<String, dynamic> leadData) {
    ref.read(embeddingProvider.notifier).submitLead(leadData);
    
    // Redirect to full app with context
    context.go('/onboarding?source=${widget.source}&framework=${widget.framework}');
  }

  /// Handle lead capture skip
  void _handleLeadSkip() {
    ref.read(embeddingProvider.notifier).skipLeadCapture();
  }
}

// lib/features/embedding/widgets/embed_header.dart
// Minimal header for embedded widgets

class EmbedHeader extends StatelessWidget {
  final String? source;
  final VoidCallback? onBrandingClick;

  const EmbedHeader({
    super.key,
    this.source,
    this.onBrandingClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          // ArionComply logo/branding
          GestureDetector(
            onTap: onBrandingClick,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.security,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'ArionComply',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Source indicator (for analytics)
          if (source != null)
            Text(
              'via $source',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
        ],
      ),
    );
  }
}

// lib/features/embedding/widgets/lead_capture_form.dart
// Lead capture form for marketing conversion

class LeadCaptureForm extends ConsumerStatefulWidget {
  final String? source;
  final String? framework;
  final Function(Map<String, dynamic>) onSubmit;
  final VoidCallback onSkip;

  const LeadCaptureForm({
    super.key,
    this.source,
    this.framework,
    required this.onSubmit,
    required this.onSkip,
  });

  @override
  ConsumerState<LeadCaptureForm> createState() => _LeadCaptureFormState();
}

class _LeadCaptureFormState extends ConsumerState<LeadCaptureForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();
  final _roleController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _companyController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            'Get your personalized compliance roadmap',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          // Form fields
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(