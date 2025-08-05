// FILE PATH: lib/features/avatar/models/expert_personality.dart
// Expert Personality Models - Defines AI expert personality types and behaviors
// Extracted from expert_personality_engine.dart usage patterns

import 'package:flutter/foundation.dart';
import '../../../core/models/emotion_types.dart';

/// Expert personality types for different user preferences
enum ExpertPersonalityType {
  friendly,
  professional, 
  authoritative,
}

/// Expert emotional states for contextual responses
enum ExpertEmotion {
  neutral,
  happy,
  focused,
  encouraging,
  serious,
  celebratory,
  welcoming,
  helpful,
  concerned,
}

/// User intent types for conversation analysis
enum IntentType {
  frameworkInquiry,
  gettingStarted,
  statusInquiry,
  documentCreation,
  explanation,
  general,
}

/// Emotional context of user messages
enum EmotionalContext {
  neutral,
  stressed,
  confused,
  enthusiastic,
  frustrated,
}

/// Expert response types
enum ExpertResponseType {
  greeting,
  guidance,
  explanation,
  clarification,
  encouragement,
  instruction,
}

/// Expert's areas of expertise
class ExpertExpertise {
  final List<String> primaryFrameworks;
  final List<String> industries;
  final int yearsExperience;
  final List<String> specializations;

  const ExpertExpertise({
    required this.primaryFrameworks,
    required this.industries,
    required this.yearsExperience,
    required this.specializations,
  });

  ExpertExpertise copyWith({
    List<String>? primaryFrameworks,
    List<String>? industries,
    int? yearsExperience,
    List<String>? specializations,
  }) {
    return ExpertExpertise(
      primaryFrameworks: primaryFrameworks ?? this.primaryFrameworks,
      industries: industries ?? this.industries,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      specializations: specializations ?? this.specializations,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primaryFrameworks': primaryFrameworks,
      'industries': industries,
      'yearsExperience': yearsExperience,
      'specializations': specializations,
    };
  }

  factory ExpertExpertise.fromJson(Map<String, dynamic> json) {
    return ExpertExpertise(
      primaryFrameworks: List<String>.from(json['primaryFrameworks'] ?? []),
      industries: List<String>.from(json['industries'] ?? []),
      yearsExperience: json['yearsExperience'] ?? 10,
      specializations: List<String>.from(json['specializations'] ?? []),
    );
  }
}

/// Communication style configuration
class CommunicationStyle {
  final bool isEncouraging;
  final bool isPersonal;
  final bool showsExpertise;
  final bool usesAnalogies;
  final bool proactiveGuidance;

  const CommunicationStyle({
    required this.isEncouraging,
    required this.isPersonal,
    required this.showsExpertise,
    required this.usesAnalogies,
    required this.proactiveGuidance,
  });

  CommunicationStyle copyWith({
    bool? isEncouraging,
    bool? isPersonal,
    bool? showsExpertise,
    bool? usesAnalogies,
    bool? proactiveGuidance,
  }) {
    return CommunicationStyle(
      isEncouraging: isEncouraging ?? this.isEncouraging,
      isPersonal: isPersonal ?? this.isPersonal,
      showsExpertise: showsExpertise ?? this.showsExpertise,
      usesAnalogies: usesAnalogies ?? this.usesAnalogies,
      proactiveGuidance: proactiveGuidance ?? this.proactiveGuidance,
    );
  }
}

/// Main expert personality configuration
class ExpertPersonality {
  final String name;
  final String role;
  final ExpertPersonalityType personalityType;
  final ExpertExpertise expertise;
  final CommunicationStyle communicationStyle;

  const ExpertPersonality({
    required this.name,
    required this.role,
    required this.personalityType,
    required this.expertise,
    required this.communicationStyle,
  });

  ExpertPersonality copyWith({
    String? name,
    String? role,
    ExpertPersonalityType? personalityType,
    ExpertExpertise? expertise,
    CommunicationStyle? communicationStyle,
  }) {
    return ExpertPersonality(
      name: name ?? this.name,
      role: role ?? this.role,
      personalityType: personalityType ?? this.personalityType,
      expertise: expertise ?? this.expertise,
      communicationStyle: communicationStyle ?? this.communicationStyle,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'personalityType': personalityType.toString(),
      'expertise': expertise.toJson(),
      // CommunicationStyle doesn't need serialization for now
    };
  }

  factory ExpertPersonality.fromJson(Map<String, dynamic> json) {
    return ExpertPersonality(
      name: json['name'] ?? 'Alex',
      role: json['role'] ?? 'Senior Compliance Expert',
      personalityType: ExpertPersonalityType.values.firstWhere(
        (e) => e.toString() == json['personalityType'],
        orElse: () => ExpertPersonalityType.professional,
      ),
      expertise: ExpertExpertise.fromJson(json['expertise'] ?? {}),
      communicationStyle: const CommunicationStyle(
        isEncouraging: true,
        isPersonal: true,
        showsExpertise: true,
        usesAnalogies: true,
        proactiveGuidance: true,
      ),
    );
  }
}

/// User intent analysis result
class UserIntent {
  final IntentType type;
  final double confidence;
  final List<String>? entities;

  const UserIntent({
    required this.type,
    required this.confidence,
    this.entities,
  });

  UserIntent copyWith({
    IntentType? type,
    double? confidence,
    List<String>? entities,
  }) {
    return UserIntent(
      type: type ?? this.type,
      confidence: confidence ?? this.confidence,
      entities: entities ?? this.entities,
    );
  }
}

/// Expert response with metadata
class ExpertResponse {
  final String content;
  final ExpertEmotion emotion;
  final double confidence;
  final ExpertResponseType responseType;
  final List<String>? suggestedActions;
  final Map<String, dynamic>? metadata;

  const ExpertResponse({
    required this.content,
    required this.emotion,
    required this.confidence,
    required this.responseType,
    this.suggestedActions,
    this.metadata,
  });

  ExpertResponse copyWith({
    String? content,
    ExpertEmotion? emotion,
    double? confidence,
    ExpertResponseType? responseType,
    List<String>? suggestedActions,
    Map<String, dynamic>? metadata,
  }) {
    return ExpertResponse(
      content: content ?? this.content,
      emotion: emotion ?? this.emotion,
      confidence: confidence ?? this.confidence,
      responseType: responseType ?? this.responseType,
      suggestedActions: suggestedActions ?? this.suggestedActions,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'emotion': emotion.toString(),
      'confidence': confidence,
      'responseType': responseType.toString(),
      'suggestedActions': suggestedActions,
      'metadata': metadata,
    };
  }

  factory ExpertResponse.fromJson(Map<String, dynamic> json) {
    return ExpertResponse(
      content: json['content'] ?? '',
      emotion: ExpertEmotion.values.firstWhere(
        (e) => e.toString() == json['emotion'],
        orElse: () => ExpertEmotion.neutral,
      ),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      responseType: ExpertResponseType.values.firstWhere(
        (e) => e.toString() == json['responseType'],
        orElse: () => ExpertResponseType.guidance,
      ),
      suggestedActions: json['suggestedActions'] != null
          ? List<String>.from(json['suggestedActions'])
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// Predefined personality configurations
class ExpertPersonalities {
  static const ExpertPersonality friendly = ExpertPersonality(
    name: 'Alex',
    role: 'Friendly Compliance Guide',
    personalityType: ExpertPersonalityType.friendly,
    expertise: ExpertExpertise(
      primaryFrameworks: ['SOC 2', 'GDPR', 'ISO 27001'],
      industries: ['Technology', 'SaaS', 'Startups'],
      yearsExperience: 12,
      specializations: ['Implementation', 'Training', 'Documentation'],
    ),
    communicationStyle: CommunicationStyle(
      isEncouraging: true,
      isPersonal: true,
      showsExpertise: true,
      usesAnalogies: true,
      proactiveGuidance: true,
    ),
  );

  static const ExpertPersonality professional = ExpertPersonality(
    name: 'Alex',
    role: 'Senior Compliance Expert',
    personalityType: ExpertPersonalityType.professional,
    expertise: ExpertExpertise(
      primaryFrameworks: ['SOC 2', 'ISO 27001', 'GDPR', 'HIPAA'],
      industries: ['Enterprise', 'Healthcare', 'Financial Services'],
      yearsExperience: 15,
      specializations: ['Risk Assessment', 'Audit Preparation', 'Policy Development'],
    ),
    communicationStyle: CommunicationStyle(
      isEncouraging: true,
      isPersonal: true,
      showsExpertise: true,
      usesAnalogies: true,
      proactiveGuidance: true,
    ),
  );

  static const ExpertPersonality authoritative = ExpertPersonality(
    name: 'Alex',
    role: 'Chief Compliance Officer',
    personalityType: ExpertPersonalityType.authoritative,
    expertise: ExpertExpertise(
      primaryFrameworks: ['ISO 27001', 'SOC 2', 'PCI DSS', 'NIST'],
      industries: ['Enterprise', 'Government', 'Critical Infrastructure'],
      yearsExperience: 20,
      specializations: ['Executive Consulting', 'Program Architecture', 'Regulatory Strategy'],
    ),
    communicationStyle: CommunicationStyle(
      isEncouraging: false,
      isPersonal: false,
      showsExpertise: true,
      usesAnalogies: false,
      proactiveGuidance: true,
    ),
  );

  /// Get personality by type
  static ExpertPersonality getByType(ExpertPersonalityType type) {
    switch (type) {
      case ExpertPersonalityType.friendly:
        return friendly;
      case ExpertPersonalityType.authoritative:
        return authoritative;
      case ExpertPersonalityType.professional:
      default:
        return professional;
    }
  }

  /// List all available personalities
  static List<ExpertPersonality> get all => [
        friendly,
        professional,
        authoritative,
      ];
}