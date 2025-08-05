// lib/features/assessment/screens/assessment_screen.dart
// ArionComply Assessment Flow - Avatar-driven compliance assessment
// NOT traditional forms - Conversational assessment with real-time analysis

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/responsive_layout.dart';
import '../../avatar/widgets/avatar_3d_display.dart';
import '../../avatar/widgets/conversation_interface.dart';
import '../../avatar/providers/avatar_state_provider.dart';
import '../../avatar/providers/conversation_provider.dart';

/// Assessment Screen - Conversational Compliance Assessment
/// Avatar guides user through assessment via natural conversation
class AssessmentScreen extends ConsumerStatefulWidget {
  final String framework;
  final int initialStep;
  
  const AssessmentScreen({
    super.key,
    required this.framework,
    this.initialStep = 1,
  });

  @override
  ConsumerState<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends ConsumerState<AssessmentScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _slideController;
  
  bool _isAssessmentStarted = false;
  int _currentDomain = 0;
  double _overallProgress = 0.0;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeAssessment();
  }

  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController.forward();
  }

  void _initializeAssessment() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final conversationNotifier = ref.read(conversationProvider.notifier);
      conversationNotifier.startAssessment(
        framework: widget.framework,
        step: widget.initialStep,
      );
      setState(() {
        _isAssessmentStarted = true;
      });
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversation = ref.watch(conversationProvider);
    
    // Update progress animation when conversation state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (conversation.assessmentProgress != _overallProgress) {
        _updateProgress(conversation.assessmentProgress);
      }
    });
    
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
          _buildAssessmentHeader(),
          _buildProgressIndicator(),
          Expanded(
            child: _buildAssessmentContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SafeArea(
      child: Column(
        children: [
          _buildAssessmentHeader(),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildAssessmentContent(),
                ),
                Expanded(
                  flex: 2,
                  child: _buildAssessmentSidebar(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SafeArea(
      child: Column(
        children: [
          _buildAssessmentHeader(),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildAssessmentSidebar(),
                ),
                Expanded(
                  flex: 2,
                  child: _buildAssessmentContent(),
                ),
                Expanded(
                  flex: 1,
                  child: _buildRealTimeAnalysis(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentHeader() {
    final frameworkData = _getFrameworkData(widget.framework);
    
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
            onPressed: () => _handleBackNavigation(),
            icon: const Icon(Icons.arrow_back),
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Icon(
            frameworkData['icon'],
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${frameworkData['name']} Assessment',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'AI-guided compliance evaluation',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildAssessmentActions(),
        ],
      ),
    );
  }

  Widget _buildAssessmentActions() {
    return Row(
      children: [
        TextButton.icon(
          onPressed: () => _pauseAssessment(),
          icon: const Icon(Icons.pause_circle_outline, size: 18),
          label: const Text('Pause'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: () => _saveProgress(),
          icon: const Icon(Icons.save_outlined, size: 18),
          label: const Text('Save'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Assessment Progress',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${(_overallProgress * 100).round()}% Complete',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return LinearPercentIndicator(
                lineHeight: 8,
                percent: _progressController.value,
                backgroundColor: AppColors.border.withOpacity(0.3),
                progressColor: AppColors.primary,
                barRadius: const Radius.circular(4),
                animation: false, // We handle animation manually
              );
            },
          ),
          const SizedBox(height: 8),
          _buildDomainIndicators(),
        ],
      ),
    );
  }

  Widget _buildDomainIndicators() {
    final domains = _getAssessmentDomains(widget.framework);
    
    return Row(
      children: List.generate(domains.length, (index) {
        final domain = domains[index];
        final isActive = index == _currentDomain;
        final isCompleted = domain['progress'] >= 1.0;
        
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCompleted 
                  ? AppColors.success.withOpacity(0.1)
                  : isActive 
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCompleted 
                    ? AppColors.success
                    : isActive 
                        ? AppColors.primary
                        : AppColors.border.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  domain['icon'],
                  color: isCompleted 
                      ? AppColors.success
                      : isActive 
                          ? AppColors.primary
                          : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  domain['name'],
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isActive 
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAssessmentContent() {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _slideController.value)),
          child: Opacity(
            opacity: _slideController.value,
            child: Column(
              children: [
                // Avatar Display
                const SizedBox(
                  height: 180,
                  child: Avatar3DDisplay(),
                ),
                const SizedBox(height: 16),
                
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

  Widget _buildAssessmentSidebar() {
    final conversation = ref.watch(conversationProvider);
    
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
            'Assessment Overview',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildCurrentDomainCard(),
          const SizedBox(height: 16),
          
          Text(
            'Key Questions',
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          
          Expanded(
            child: _buildKeyQuestionsList(),
          ),
          
          _buildAssessmentStats(),
        ],
      ),
    );
  }

  Widget _buildCurrentDomainCard() {
    final domains = _getAssessmentDomains(widget.framework);
    final currentDomain = domains[_currentDomain];
    
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
                currentDomain['icon'],
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                currentDomain['name'],
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currentDomain['description'],
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          LinearPercentIndicator(
            lineHeight: 4,
            percent: currentDomain['progress'],
            backgroundColor: AppColors.border.withOpacity(0.3),
            progressColor: AppColors.primary,
            barRadius: const Radius.circular(2),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyQuestionsList() {
    final questions = _getCurrentDomainQuestions();
    
    return ListView.builder(
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final question = questions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: question['answered'] 
                ? AppColors.success.withOpacity(0.1)
                : AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: question['answered'] 
                  ? AppColors.success.withOpacity(0.3)
                  : AppColors.warning.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                question['answered'] 
                    ? Icons.check_circle
                    : Icons.help_outline,
                color: question['answered'] 
                    ? AppColors.success
                    : AppColors.warning,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question['text'],
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAssessmentStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assessment Stats',
          style: AppTextStyles.titleSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        _buildStatRow('Questions', '47 / 120'),
        _buildStatRow('Time', '23 min'),
        _buildStatRow('Compliance', '78%'),
        _buildStatRow('Gaps Found', '12'),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
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

  Widget _buildRealTimeAnalysis() {
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
            'Real-time Analysis',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildAnalysisCard('Compliance Score', '78%', AppColors.warning),
          const SizedBox(height: 12),
          _buildAnalysisCard('Risk Level', 'Medium', AppColors.warning),
          const SizedBox(height: 12),
          _buildAnalysisCard('Gaps Identified', '12', AppColors.error),
          
          const SizedBox(height: 24),
          Text(
            'Key Findings',
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          
          Expanded(
            child: _buildFindingsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFindingsList() {
    final findings = [
      {'text': 'Missing access controls', 'severity': 'High'},
      {'text': 'Incomplete data inventory', 'severity': 'Medium'},
      {'text': 'Outdated policies', 'severity': 'Medium'},
      {'text': 'No incident response plan', 'severity': 'High'},
    ];
    
    return ListView.builder(
      itemCount: findings.length,
      itemBuilder: (context, index) {
        final finding = findings[index];
        final isHigh = finding['severity'] == 'High';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isHigh 
                ? AppColors.error.withOpacity(0.1)
                : AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                finding['text']!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${finding['severity']} Priority',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isHigh ? AppColors.error : AppColors.warning,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateProgress(double newProgress) {
    _progressController.animateTo(newProgress);
    setState(() {
      _overallProgress = newProgress;
    });
  }

  void _handleBackNavigation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Progress?'),
        content: const Text('Your assessment progress will be saved automatically.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _saveProgress();
              Navigator.of(context).pop();
              context.go('/frameworks');
            },
            child: const Text('Save & Exit'),
          ),
        ],
      ),
    );
  }

  void _pauseAssessment() {
    ref.read(conversationProvider.notifier).pauseAssessment();
  }

  void _saveProgress() {
    ref.read(conversationProvider.notifier).saveAssessmentProgress();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Assessment progress saved'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Map<String, dynamic> _getFrameworkData(String frameworkId) {
    final frameworks = {
      'soc2': {'name': 'SOC 2', 'icon': Icons.security},
      'gdpr': {'name': 'GDPR', 'icon': Icons.privacy_tip},
      'iso27001': {'name': 'ISO 27001', 'icon': Icons.verified_user},
      'hipaa': {'name': 'HIPAA', 'icon': Icons.local_hospital},
    };
    return frameworks[frameworkId] ?? frameworks['soc2']!;
  }

  List<Map<String, dynamic>> _getAssessmentDomains(String framework) {
    // Mock data - in production, this would come from the framework configuration
    return [
      {'name': 'Access', 'icon': Icons.key, 'progress': 0.8},
      {'name': 'Data', 'icon': Icons.storage, 'progress': 0.6},
      {'name': 'Systems', 'icon': Icons.computer, 'progress': 0.3},
      {'name': 'Processes', 'icon': Icons.settings, 'progress': 0.1},
    ];
  }

  List<Map<String, dynamic>> _getCurrentDomainQuestions() {
    // Mock data - in production, this would be dynamic based on current domain
    return [
      {'text': 'Do you have multi-factor authentication?', 'answered': true},
      {'text': 'Are access reviews conducted regularly?', 'answered': true},
      {'text': 'Is there a password policy in place?', 'answered': false},
      {'text': 'Are privileged accounts monitored?', 'answered': false},
    ];
  }
}