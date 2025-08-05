// lib/features/embedding/screens/embedded_widget_screen.dart
// Embedded Widget Screen - Clean interface for marketing integration
// Optimized for iframe embedding in blog posts, landing pages, etc.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Using relative imports that work regardless of file structure issues
import '../../../core/theme/app_colors.dart' show AppColors;

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
  bool _showLeadCapture = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeEmbedding();
  }

  void _initializeEmbedding() {
    // Basic initialization without external dependencies
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: Column(
        children: [
          // Minimal header for embedding
          if (!widget.minimal) _buildEmbedHeader(),

          // Main embedded content
          Expanded(
            child: _buildEmbeddedContent(),
          ),

          // Lead capture footer (appears after interaction)
          if (_showLeadCapture) _buildLeadCaptureSection(),
        ],
      ),
    );
  }

  /// Get background color with fallback
  Color _getBackgroundColor() {
    try {
      return AppColors.background;
    } catch (e) {
      return const Color(0xFFF5F7FB); // Fallback background color
    }
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
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.security_rounded,
            size: 80,
            color: _getPrimaryColor(),
          ),
          const SizedBox(height: 24),
          Text(
            'Get Started with ${widget.framework ?? 'Compliance'}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Let our expert guide you through ${widget.framework ?? 'compliance'} requirements step by step.',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildCTAButton(
            text: 'Start ${widget.framework ?? 'Compliance'} Assessment',
            onPressed: _handleFrameworkStart,
          ),
          const SizedBox(height: 16),
          _buildSecondaryButton(
            text: 'Learn More About ${widget.framework ?? 'Requirements'}',
            onPressed: _handleLearnMore,
          ),
        ],
      ),
    );
  }

  /// General expert embedded widget  
  Widget _buildGeneralExpertEmbed() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar placeholder
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _getPrimaryColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.person_rounded,
              size: 50,
              color: _getPrimaryColor(),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Meet Your Compliance Expert',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Get personalized guidance from Alex, your AI compliance expert. Available 24/7 to help you build and maintain your compliance program.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildCTAButton(
            text: 'Chat with Expert',
            onPressed: _handleChatStart,
          ),
          const SizedBox(height: 16),
          _buildSecondaryButton(
            text: 'Explore Frameworks',
            onPressed: _handleExploreFrameworks,
          ),
        ],
      ),
    );
  }

  /// Build embed header
  Widget _buildEmbedHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: _getSurfaceColor(),
        border: Border(
          bottom: BorderSide(
            color: _getBorderColor(),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security_rounded,
            size: 20,
            color: _getPrimaryColor(),
          ),
          const SizedBox(width: 8),
          const Text(
            'ArionComply',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const Spacer(),
          if (widget.source != null)
            TextButton(
              onPressed: _handleBrandingClick,
              child: const Text(
                'Powered by ArionComply',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build lead capture section
  Widget _buildLeadCaptureSection() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: _getSurfaceColor(),
        border: Border(
          top: BorderSide(
            color: _getBorderColor(),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Want to continue with a full assessment?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: _getBorderColor()),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _handleEmailSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getPrimaryColor(),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Get Started'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Free assessment • No spam • Unsubscribe anytime',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build primary CTA button
  Widget _buildCTAButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getPrimaryColor(),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Build secondary button
  Widget _buildSecondaryButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _getPrimaryColor(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: _getPrimaryColor()),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Color getters with fallbacks
  Color _getPrimaryColor() {
    try {
      return AppColors.primary;
    } catch (e) {
      return const Color(0xFF3B82F6); // Fallback primary color
    }
  }

  Color _getSurfaceColor() {
    try {
      return AppColors.surface;
    } catch (e) {
      return Colors.white; // Fallback surface color
    }
  }

  Color _getBorderColor() {
    try {
      return AppColors.border;
    } catch (e) {
      return const Color(0xFFE5E7EB); // Fallback border color
    }
  }

  /// Event handlers
  void _handleFrameworkStart() {
    _showLeadCapture = true;
    if (mounted) {
      setState(() {});
    }
    
    // Navigate or trigger action
    _trackEvent('framework_start', {
      'framework': widget.framework,
      'source': widget.source,
    });
  }

  void _handleChatStart() {
    _showLeadCapture = true;
    if (mounted) {
      setState(() {});
    }
    
    _trackEvent('chat_start', {
      'source': widget.source,
    });
  }

  void _handleLearnMore() {
    _trackEvent('learn_more', {
      'framework': widget.framework,
      'source': widget.source,
    });
  }

  void _handleExploreFrameworks() {
    _trackEvent('explore_frameworks', {
      'source': widget.source,
    });
  }

  void _handleBrandingClick() {
    _trackEvent('branding_click', {
      'source': widget.source,
    });
    
    // Open ArionComply website
    if (context.mounted) {
      // This would normally open external URL
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Visit ArionComply.com to learn more'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleEmailSubmit() {
    _trackEvent('email_submit', {
      'source': widget.source,
      'framework': widget.framework,
    });
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you! We\'ll be in touch soon.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  /// Simple event tracking
  void _trackEvent(String eventName, Map<String, dynamic> properties) {
    if (kDebugMode) {
      print('📊 Event: $eventName, Properties: $properties');
    }
    // This would integrate with analytics service in production
  }
}

/// Simple fallback AppColors class if the real one doesn't exist
class AppColors {
  static const Color primary = Color(0xFF3B82F6);
  static const Color background = Color(0xFFF5F7FB);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE5E7EB);
}