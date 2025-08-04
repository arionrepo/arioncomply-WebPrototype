// FILE PATH: lib/features/avatar/models/conversation_context.dart
// Conversation Context - Maintains user and conversation state for personalization
// Referenced in expert_personality_engine.dart for context-aware responses

import 'package:flutter/foundation.dart';

/// Context information about the user and their compliance needs
class ConversationContext {
  final String? userName;
  final String? companyName;
  final String? industry;
  final String? companySize;
  final List<String> primaryFrameworks;
  final Map<String, dynamic> userPreferences;
  final DateTime? lastInteraction;
  final int conversationCount;
  final List<String> completedAssessments;
  final Map<String, dynamic> userProfile;

  const ConversationContext({
    this.userName,
    this.companyName,
    this.industry,
    this.companySize,
    this.primaryFrameworks = const [],
    this.userPreferences = const {},
    this.lastInteraction,
    this.conversationCount = 0,
    this.completedAssessments = const [],
    this.userProfile = const {},
  });

  ConversationContext copyWith({
    String? userName,
    String? companyName,
    String? industry,
    String? companySize,
    List<String>? primaryFrameworks,
    Map<String, dynamic>? userPreferences,
    DateTime? lastInteraction,
    int? conversationCount,
    List<String>? completedAssessments,
    Map<String, dynamic>? userProfile,
  }) {
    return ConversationContext(
      userName: userName ?? this.userName,
      companyName: companyName ?? this.companyName,
      industry: industry ?? this.industry,
      companySize: companySize ?? this.companySize,
      primaryFrameworks: primaryFrameworks ?? this.primaryFrameworks,
      userPreferences: userPreferences ?? this.userPreferences,
      lastInteraction: lastInteraction ?? this.lastInteraction,
      conversationCount: conversationCount ?? this.conversationCount,
      completedAssessments: completedAssessments ?? this.completedAssessments,
      userProfile: userProfile ?? this.userProfile,
    );
  }

  /// Update context with new user information
  ConversationContext updateUserInfo({
    String? userName,
    String? companyName,
    String? industry,
    String? companySize,
  }) {
    return copyWith(
      userName: userName ?? this.userName,
      companyName: companyName ?? this.companyName,
      industry: industry ?? this.industry,
      companySize: companySize ?? this.companySize,
      lastInteraction: DateTime.now(),
    );
  }

  /// Add a framework to user's interests
  ConversationContext addFramework(String framework) {
    if (primaryFrameworks.contains(framework)) {
      return this;
    }
    
    return copyWith(
      primaryFrameworks: [...primaryFrameworks, framework],
      lastInteraction: DateTime.now(),
    );
  }

  /// Update user preferences
  ConversationContext updatePreferences(Map<String, dynamic> newPreferences) {
    final updatedPreferences = Map<String, dynamic>.from(userPreferences);
    updatedPreferences.addAll(newPreferences);
    
    return copyWith(
      userPreferences: updatedPreferences,
      lastInteraction: DateTime.now(),
    );
  }

  /// Mark an assessment as completed
  ConversationContext addCompletedAssessment(String assessmentId) {
    if (completedAssessments.contains(assessmentId)) {
      return this;
    }
    
    return copyWith(
      completedAssessments: [...completedAssessments, assessmentId],
      lastInteraction: DateTime.now(),
    );
  }

  /// Increment conversation count
  ConversationContext incrementConversation() {
    return copyWith(
      conversationCount: conversationCount + 1,
      lastInteraction: DateTime.now(),
    );
  }

  /// Check if user is new (first-time interaction)
  bool get isNewUser => conversationCount == 0 && userName == null;

  /// Check if user has provided basic info
  bool get hasBasicInfo => userName != null || companyName != null;

  /// Check if user has framework preferences
  bool get hasFrameworkPreferences => primaryFrameworks.isNotEmpty;

  /// Check if user has completed any assessments
  bool get hasCompletedAssessments => completedAssessments.isNotEmpty;

  /// Get user's preferred greeting name
  String get greetingName => userName ?? 'there';

  /// Get company reference for personalization
  String get companyReference => companyName ?? 'your organization';

  /// Check if user is in a specific industry
  bool isInIndustry(String targetIndustry) {
    return industry?.toLowerCase() == targetIndustry.toLowerCase();
  }

  /// Check if user is interested in a specific framework
  bool isInterestedIn(String framework) {
    return primaryFrameworks.any((f) => 
        f.toLowerCase().contains(framework.toLowerCase()));
  }

  /// Get personalization level (0.0 to 1.0)
  double get personalizationLevel {
    double score = 0.0;
    
    if (userName != null) score += 0.2;
    if (companyName != null) score += 0.2;
    if (industry != null) score += 0.2;
    if (primaryFrameworks.isNotEmpty) score += 0.2;
    if (conversationCount > 0) score += 0.1;
    if (completedAssessments.isNotEmpty) score += 0.1;
    
    return score.clamp(0.0, 1.0);
  }

  /// Get user expertise level based on interaction history
  UserExpertiseLevel get expertiseLevel {
    if (completedAssessments.length >= 3) {
      return UserExpertiseLevel.advanced;
    } else if (completedAssessments.isNotEmpty || conversationCount > 5) {
      return UserExpertiseLevel.intermediate;
    } else {
      return UserExpertiseLevel.beginner;
    }
  }

  /// Serialize to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'companyName': companyName,
      'industry': industry,
      'companySize': companySize,
      'primaryFrameworks': primaryFrameworks,
      'userPreferences': userPreferences,
      'lastInteraction': lastInteraction?.toIso8601String(),
      'conversationCount': conversationCount,
      'completedAssessments': completedAssessments,
      'userProfile': userProfile,
    };
  }

  /// Deserialize from JSON
  factory ConversationContext.fromJson(Map<String, dynamic> json) {
    return ConversationContext(
      userName: json['userName'] as String?,
      companyName: json['companyName'] as String?,
      industry: json['industry'] as String?,
      companySize: json['companySize'] as String?,
      primaryFrameworks: List<String>.from(json['primaryFrameworks'] ?? []),
      userPreferences: Map<String, dynamic>.from(json['userPreferences'] ?? {}),
      lastInteraction: json['lastInteraction'] != null
          ? DateTime.parse(json['lastInteraction'])
          : null,
      conversationCount: json['conversationCount'] ?? 0,
      completedAssessments: List<String>.from(json['completedAssessments'] ?? []),
      userProfile: Map<String, dynamic>.from(json['userProfile'] ?? {}),
    );
  }

  /// Create empty context for new users
  factory ConversationContext.empty() {
    return const ConversationContext();
  }

  /// Create context from basic user info
  factory ConversationContext.fromUserInfo({
    String? userName,
    String? companyName,
    String? industry,
    List<String>? frameworks,
  }) {
    return ConversationContext(
      userName: userName,
      companyName: companyName,
      industry: industry,
      primaryFrameworks: frameworks ?? [],
      lastInteraction: DateTime.now(),
      conversationCount: 1,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ConversationContext &&
        other.userName == userName &&
        other.companyName == companyName &&
        other.industry == industry &&
        listEquals(other.primaryFrameworks, primaryFrameworks) &&
        other.conversationCount == conversationCount;
  }

  @override
  int get hashCode {
    return Object.hash(
      userName,
      companyName,
      industry,
      primaryFrameworks,
      conversationCount,
    );
  }

  @override
  String toString() {
    return 'ConversationContext('
        'user: $userName, '
        'company: $companyName, '
        'frameworks: $primaryFrameworks, '
        'conversations: $conversationCount'
        ')';
  }
}

/// User expertise levels for tailored communication
enum UserExpertiseLevel {
  beginner,
  intermediate,
  advanced,
}

/// Extension methods for expertise level
extension UserExpertiseLevelExtension on UserExpertiseLevel {
  String get displayName {
    switch (this) {
      case UserExpertiseLevel.beginner:
        return 'New to Compliance';
      case UserExpertiseLevel.intermediate:
        return 'Some Experience';
      case UserExpertiseLevel.advanced:
        return 'Compliance Professional';
    }
  }

  String get description {
    switch (this) {
      case UserExpertiseLevel.beginner:
        return 'Just getting started with compliance requirements';
      case UserExpertiseLevel.intermediate:
        return 'Has some experience with compliance frameworks';
      case UserExpertiseLevel.advanced:
        return 'Experienced compliance professional';
    }
  }

  /// Should responses include detailed explanations?
  bool get needsDetailedExplanations {
    return this == UserExpertiseLevel.beginner;
  }

  /// Should responses use technical terminology?
  bool get canHandleTechnicalTerms {
    return this != UserExpertiseLevel.beginner;
  }

  /// Should responses include implementation guidance?
  bool get needsImplementationGuidance {
    return this != UserExpertiseLevel.advanced;
  }
}

/// Context-aware conversation utilities
class ConversationContextUtils {
  /// Generate personalized greeting based on context
  static String generateGreeting(ConversationContext context) {
    if (context.isNewUser) {
      return "Hi there! I'm Alex, your AI compliance expert. I'm here to help you navigate compliance requirements with confidence.";
    }
    
    if (context.userName != null) {
      if (context.conversationCount > 5) {
        return "Welcome back, ${context.userName}! Ready to continue building your compliance program?";
      } else {
        return "Hi ${context.userName}! Great to see you again. How can I help you today?";
      }
    }
    
    return "Hello! I'm Alex, your compliance expert. How can I assist you today?";
  }

  /// Get contextual suggestions based on user history
  static List<String> getContextualSuggestions(ConversationContext context) {
    final suggestions = <String>[];
    
    if (context.isNewUser) {
      suggestions.addAll([
        "Help me get started with compliance",
        "What frameworks do I need?",
        "Tell me about SOC 2",
        "How does compliance work?",
      ]);
    } else if (context.hasFrameworkPreferences) {
      suggestions.addAll([
        "Continue my ${context.primaryFrameworks.first} assessment",
        "Show me my compliance progress",
        "Create a security policy",
        "Help with audit preparation",
      ]);
    } else {
      suggestions.addAll([
        "Assess my compliance needs",
        "Tell me about GDPR",
        "Help with SOC 2 preparation",
        "Create compliance documentation",
      ]);
    }
    
    return suggestions;
  }

  /// Determine if context suggests user needs onboarding
  static bool needsOnboarding(ConversationContext context) {
    return context.isNewUser || 
           (!context.hasBasicInfo && context.conversationCount < 3);
  }

  /// Get recommended next steps based on context
  static List<String> getRecommendedNextSteps(ConversationContext context) {
    final steps = <String>[];
    
    if (!context.hasBasicInfo) {
      steps.add("Tell me about your company and compliance needs");
    }
    
    if (!context.hasFrameworkPreferences) {
      steps.add("Identify which compliance frameworks you need");
    }
    
    if (!context.hasCompletedAssessments) {
      steps.add("Complete a compliance readiness assessment");
    }
    
    if (steps.isEmpty) {
      steps.addAll([
        "Review your compliance program",
        "Update your security policies",
        "Prepare for your next audit",
      ]);
    }
    
    return steps;
  }
}