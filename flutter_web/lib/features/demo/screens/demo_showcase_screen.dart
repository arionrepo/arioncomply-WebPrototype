// lib/features/demo/screens/demo_showcase_screen.dart
// ArionComply Demo Showcase - For stakeholder presentations
// Controlled demo flow showing key features and value propositions

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

/// Demo Showcase Screen for Stakeholder Presentations
/// Scripted demo flow showing key ArionComply capabilities
class DemoShowcaseScreen extends ConsumerStatefulWidget {
  const DemoShowcaseScreen({super.key});

  @override
  ConsumerState<DemoShowcaseScreen> createState() => _DemoShowcaseScreenState();
}

class _DemoShowcaseScreenState extends ConsumerState<DemoShowcaseScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late PageController _pageController;
  
  int _currentStep = 0;
  bool _isDemoActive = false;
  bool _isAutoPlay = false;
  
  final List<DemoStep> _demoSteps = [
    DemoStep(
      title: 'AI-Powered Compliance Expert',
      description: 'Meet Alex, your personal compliance consultant',
      action: DemoAction.avatarIntroduction,
      duration: const Duration(seconds: 5),
    ),
    DemoStep(
      title: 'Intelligent Framework Selection',
      description: 'AI analyzes your company to recommend the right framework',
      action: DemoAction.frameworkDiscovery,
      duration: const Duration(seconds: 8),
    ),
    DemoStep(
      title: 'Conversational Assessment',
      description: 'Natural conversation replaces complex forms',
      action: DemoAction.conversationalAssessment,
      duration: const Duration(seconds: 10),
    ),
    DemoStep(
      title: 'Real-time Gap Analysis',
      description: 'Instant identification of compliance gaps',
      action: DemoAction.gapAnalysis,
      duration: const Duration(seconds: 6),
    ),
    DemoStep(
      title: 'Actionable Recommendations',
      description: 'Specific, prioritized action items',
      action: DemoAction.recommendations,
      duration: const Duration(seconds: 8),
    ),
    DemoStep(
      title: 'Continuous Monitoring',
      description: 'Ongoing compliance tracking and updates',
      action: DemoAction.monitoring,
      duration: const Duration(seconds: 5),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeDemo();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pageController = PageController();
    _fadeController.forward();
  }

  void _initializeDemo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conversationProvider.notifier).initializeDemoMode();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pageController.dispose();
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
          _buildDemoHeader(),
          Expanded(
            child: _buildDemoContent(),
          ),
          _buildDemoControls(),
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
                _buildDemoHeader(),
                Expanded(child: _buildDemoContent()),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildDemoSidebar(),
                _buildDemoControls(),
              ],
            ),
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
            child: _buildDemoSidebar(),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildDemoHeader(),
                Expanded(child: _buildDemoContent()),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: _buildDemoInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoHeader() {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ArionComply Demo',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'AI-Powered Compliance Made Simple',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildDemoStatus(),
        ],
      ),
    );
  }

  Widget _buildDemoStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _isDemoActive ? AppColors.success : AppColors.warning,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isDemoActive ? Icons.play_circle_filled : Icons.pause_circle_filled,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            _isDemoActive ? 'Demo Active' : 'Demo Paused',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoContent() {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeController.value,
          child: Column(
            children: [
              // Demo Step Indicator
              _buildStepIndicator(),
              const SizedBox(height: 20),
              
              // Avatar Interface
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
        );
      },
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(_demoSteps.length, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 4,
              decoration: BoxDecoration(
                color: isCompleted 
                    ? AppColors.success
                    : isActive 
                        ? AppColors.primary
                        : AppColors.border.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDemoSidebar() {
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
            'Demo Steps',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _demoSteps.length,
              itemBuilder: (context, index) {
                return _buildStepCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(int index) {
    final step = _demoSteps[index];
    final isActive = index == _currentStep;
    final isCompleted = index < _currentStep;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive 
            ? AppColors.primary.withOpacity(0.1)
            : isCompleted
                ? AppColors.success.withOpacity(0.1)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive 
              ? AppColors.primary
              : isCompleted
                  ? AppColors.success
                  : AppColors.border.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCompleted 
                    ? Icons.check_circle
                    : isActive
                        ? Icons.play_circle_filled
                        : Icons.circle_outlined,
                color: isCompleted 
                    ? AppColors.success
                    : isActive
                        ? AppColors.primary
                        : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  step.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isActive 
                        ? AppColors.primary
                        : AppColors.textPrimary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            step.description,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoInfo() {
    final currentStep = _demoSteps[_currentStep];
    
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
            'Current Step',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentStep.title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentStep.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          _buildKeyFeatures(),
          
          const Spacer(),
          _buildDemoMetrics(),
        ],
      ),
    );
  }

  Widget _buildKeyFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Features',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...[
          'AI-powered conversation',
          'Real-time compliance analysis',
          'Automated gap identification',
          'Actionable recommendations',
          'Continuous monitoring',
        ].map((feature) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                feature,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildDemoMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Demo Metrics',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildMetricRow('Step', '${_currentStep + 1}/${_demoSteps.length}'),
        _buildMetricRow('Duration', '~5 minutes'),
        _buildMetricRow('Completion', '${((_currentStep + 1) / _demoSteps.length * 100).round()}%'),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
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

  Widget _buildDemoControls() {
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
          // Previous Step
          IconButton(
            onPressed: _currentStep > 0 ? _previousStep : null,
            icon: const Icon(Icons.skip_previous),
            color: _currentStep > 0 ? AppColors.primary : AppColors.textSecondary,
          ),
          
          // Play/Pause
          IconButton(
            onPressed: _toggleDemo,
            icon: Icon(_isDemoActive ? Icons.pause : Icons.play_arrow),
            color: AppColors.primary,
          ),
          
          // Next Step
          IconButton(
            onPressed: _currentStep < _demoSteps.length - 1 ? _nextStep : null,
            icon: const Icon(Icons.skip_next),
            color: _currentStep < _demoSteps.length - 1 ? AppColors.primary : AppColors.textSecondary,
          ),
          
          const Spacer(),
          
          // Auto-play toggle
          Row(
            children: [
              Text(
                'Auto-play',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Switch(
                value: _isAutoPlay,
                onChanged: (value) => setState(() => _isAutoPlay = value),
                activeColor: AppColors.primary,
              ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // Reset Demo
          TextButton(
            onPressed: _resetDemo,
            child: const Text('Reset'),
          ),
          
          // Exit Demo
          ElevatedButton(
            onPressed: () => context.go('/'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Exit Demo'),
          ),
        ],
      ),
    );
  }

  void _toggleDemo() {
    setState(() {
      _isDemoActive = !_isDemoActive;
    });
    
    if (_isDemoActive) {
      _executeDemoStep(_currentStep);
    }
  }

  void _nextStep() {
    if (_currentStep < _demoSteps.length - 1) {
      setState(() {
        _currentStep++;
      });
      
      if (_isDemoActive) {
        _executeDemoStep(_currentStep);
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _resetDemo() {
    setState(() {
      _currentStep = 0;
      _isDemoActive = false;
    });
    ref.read(conversationProvider.notifier).resetDemoMode();
  }

  void _executeDemoStep(int stepIndex) {
    final step = _demoSteps[stepIndex];
    final conversationNotifier = ref.read(conversationProvider.notifier);
    
    switch (step.action) {
      case DemoAction.avatarIntroduction:
        conversationNotifier.executeDemoIntroduction();
        break;
      case DemoAction.frameworkDiscovery:
        conversationNotifier.executeDemoFrameworkDiscovery();
        break;
      case DemoAction.conversationalAssessment:
        conversationNotifier.executeDemoAssessment();
        break;
      case DemoAction.gapAnalysis:
        conversationNotifier.executeDemoGapAnalysis();
        break;
      case DemoAction.recommendations:
        conversationNotifier.executeDemoRecommendations();
        break;
      case DemoAction.monitoring:
        conversationNotifier.executeDemoMonitoring();
        break;
    }
    
    // Auto-advance if enabled
    if (_isAutoPlay) {
      Future.delayed(step.duration, () {
        if (_isDemoActive && _currentStep < _demoSteps.length - 1) {
          _nextStep();
        }
      });
    }
  }
}

/// Demo step configuration
class DemoStep {
  final String title;
  final String description;
  final DemoAction action;
  final Duration duration;
  
  const DemoStep({
    required this.title,
    required this.description,
    required this.action,
    required this.duration,
  });
}

/// Demo action types
enum DemoAction {
  avatarIntroduction,
  frameworkDiscovery,
  conversationalAssessment,
  gapAnalysis,
  recommendations,
  monitoring,
}