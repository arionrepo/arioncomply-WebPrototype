// lib/features/avatar/services/expert_personality_engine.dart
// Expert Personality Engine - Creates "My Expert" Relationship
// This is what makes users attach to their AI expert vs. using software

import 'dart:math';
import 'package:flutter/foundation.dart';

import '../models/expert_personality.dart';
import '../models/conversation_context.dart';
import '../../../core/services/ai_transparency_service.dart';

/// Expert Personality Engine
/// Creates consistent, relationship-building expert persona
/// Key differentiator: Users say "my expert" not "the software"
class ExpertPersonalityEngine {
  static ExpertPersonalityEngine? _instance;
  static ExpertPersonalityEngine get instance => 
      _instance ??= ExpertPersonalityEngine._();
  ExpertPersonalityEngine._();

  final AITransparencyService _transparencyService = AITransparencyService.instance;
  final Random _random = Random();
  
  // Expert personality configuration
  late ExpertPersonality _personality;
  late ConversationContext _context;
  
  /// Initialize expert personality with user preferences
  void initialize({
    String? userName,
    String? companyName,
    String? industry,
    List<String>? primaryFrameworks,
    ExpertPersonalityType? personalityType,
  }) {
    _personality = ExpertPersonality(
      name: 'Alex',
      role: 'Senior Compliance Expert',
      personalityType: personalityType ?? ExpertPersonalityType.professional,
      expertise: _buildExpertise(primaryFrameworks),
      communicationStyle: _buildCommunicationStyle(personalityType),
    );
    
    _context = ConversationContext(
      userName: userName,
      companyName: companyName,
      industry: industry,
      primaryFrameworks: primaryFrameworks ?? [],
    );
    
    if (kDebugMode) {
      print('🤖 Expert Personality Initialized:');
      print('   Name: ${_personality.name}');
      print('   Style: ${_personality.personalityType}');
      print('   User: ${_context.userName ?? "Anonymous"}');
    }
  }

  /// Generate expert response with personality
  /// This is where the "expert relationship" is built
  Future<ExpertResponse> generateResponse({
    required String userMessage,
    required ConversationContext context,
    List<String>? previousMessages,
  }) async {
    final traceId = _transparencyService.startDecision('generate_expert_response');
    
    try {
      // Analyze user intent and emotional context
      final intent = _analyzeUserIntent(userMessage);
      final emotionalContext = _analyzeEmotionalContext(userMessage, context);
      
      // Generate base response content
      final baseResponse = await _generateBaseResponse(
        userMessage: userMessage,
        intent: intent,
        context: context,
      );
      
      // Apply expert personality
      final personalizedResponse = _applyPersonality(
        baseResponse: baseResponse,
        intent: intent,
        emotionalContext: emotionalContext,
        context: context,
      );
      
      // Add relationship-building elements
      final finalResponse = _addRelationshipElements(
        response: personalizedResponse,
        context: context,
      );
      
      // Log decision for AI transparency
      _transparencyService.logDecision(
        traceId: traceId,
        decision: 'expert_response_generated',
        reasoning: 'Applied ${_personality.personalityType} personality with ${intent.type} intent',
        confidence: finalResponse.confidence,
        metadata: {
          'intent': intent.type.toString(),
          'emotion': emotionalContext.toString(),
          'personality_applied': true,
        },
      );
      
      return finalResponse;
      
    } catch (e) {
      _transparencyService.logError(traceId, 'Error generating expert response: $e');
      return _generateFallbackResponse(userMessage);
    }
  }

  /// Generate welcome message that establishes expert relationship
  ExpertResponse generateWelcomeMessage() {
    final welcomeMessages = [
      "Hi ${_getPersonalGreeting()}! I'm ${_personality.name}, your personal compliance expert. I'm here to help you navigate the world of compliance with confidence.",
      
      "Hello! I'm ${_personality.name}, and I'll be your dedicated compliance guide. Think of me as your ${_personality.role.toLowerCase()} who's available 24/7 to help you succeed.",
      
      "Welcome to ArionComply! I'm ${_personality.name}, your AI compliance expert. I'm excited to work with you on building a strong compliance program for ${_context.companyName ?? 'your organization'}.",
    ];
    
    final selectedMessage = welcomeMessages[_random.nextInt(welcomeMessages.length)];
    
    return ExpertResponse(
      content: selectedMessage,
      emotion: ExpertEmotion.welcoming,
      confidence: 1.0,
      responseType: ExpertResponseType.greeting,
      suggestedActions: _getWelcomeSuggestions(),
      metadata: {
        'is_welcome': true,
        'personality_type': _personality.personalityType.toString(),
      },
    );
  }

  /// Analyze user intent from message
  UserIntent _analyzeUserIntent(String message) {
    final lowerMessage = message.toLowerCase();
    
    // Framework-related intents
    if (lowerMessage.contains(RegExp(r'\b(soc 2|iso 27001|gdpr|hipaa|pci)\b'))) {
      return UserIntent(
        type: IntentType.frameworkInquiry,
        confidence: 0.9,
        entities: _extractFrameworks(message),
      );
    }
    
    // Getting started intents
    if (lowerMessage.contains(RegExp(r'\b(start|begin|help|new|setup)\b'))) {
      return UserIntent(
        type: IntentType.gettingStarted,
        confidence: 0.85,
      );
    }
    
    // Status/progress intents
    if (lowerMessage.contains(RegExp(r'\b(status|progress|ready|doing|complete)\b'))) {
      return UserIntent(
        type: IntentType.statusInquiry,
        confidence: 0.8,
      );
    }
    
    // Document creation intents
    if (lowerMessage.contains(RegExp(r'\b(create|generate|policy|document|template)\b'))) {
      return UserIntent(
        type: IntentType.documentCreation,
        confidence: 0.85,
      );
    }
    
    // Explanation intents
    if (lowerMessage.contains(RegExp(r'\b(what|why|how|explain|tell me)\b'))) {
      return UserIntent(
        type: IntentType.explanation,
        confidence: 0.7,
      );
    }
    
    return UserIntent(type: IntentType.general, confidence: 0.5);
  }

  /// Analyze emotional context of conversation
  EmotionalContext _analyzeEmotionalContext(String message, ConversationContext context) {
    final lowerMessage = message.toLowerCase();
    
    // Stress/urgency indicators
    if (lowerMessage.contains(RegExp(r'\b(urgent|asap|quickly|deadline|audit|help)\b'))) {
      return EmotionalContext.stressed;
    }
    
    // Confusion indicators
    if (lowerMessage.contains(RegExp(r'\b(confused|don\'t understand|unclear|complex)\b'))) {
      return EmotionalContext.confused;
    }
    
    // Excitement/enthusiasm indicators
    if (lowerMessage.contains(RegExp(r'\b(great|awesome|excited|love|perfect)\b'))) {
      return EmotionalContext.enthusiastic;
    }
    
    // Frustration indicators
    if (lowerMessage.contains(RegExp(r'\b(frustrated|difficult|hard|complicated)\b'))) {
      return EmotionalContext.frustrated;
    }
    
    return EmotionalContext.neutral;
  }

  /// Generate base response content
  Future<String> _generateBaseResponse({
    required String userMessage,
    required UserIntent intent,
    required ConversationContext context,
  }) async {
    // This would integrate with actual AI service in production
    // For demo, we'll use personality-driven template responses
    
    switch (intent.type) {
      case IntentType.frameworkInquiry:
        return _generateFrameworkResponse(intent.entities?.first ?? 'compliance');
        
      case IntentType.gettingStarted:
        return _generateGettingStartedResponse(context);
        
      case IntentType.statusInquiry:
        return _generateStatusResponse(context);
        
      case IntentType.documentCreation:
        return _generateDocumentCreationResponse(userMessage);
        
      case IntentType.explanation:
        return _generateExplanationResponse(userMessage);
        
      default:
        return _generateGeneralResponse(userMessage);
    }
  }

  /// Apply expert personality to response
  String _applyPersonality({
    required String baseResponse,
    required UserIntent intent,
    required EmotionalContext emotionalContext,
    required ConversationContext context,
  }) {
    final style = _personality.communicationStyle;
    
    // Add personality-specific elements
    String personalizedResponse = baseResponse;
    
    // Add encouragement based on personality
    if (style.isEncouraging && emotionalContext == EmotionalContext.stressed) {
      personalizedResponse = _addEncouragement(personalizedResponse);
    }
    
    // Add expertise indicators
    if (style.showsExpertise) {
      personalizedResponse = _addExpertiseIndicators(personalizedResponse, intent);
    }
    
    // Add personal touches
    if (style.isPersonal && context.userName != null) {
      personalizedResponse = _addPersonalTouches(personalizedResponse, context);
    }
    
    return personalizedResponse;
  }

  /// Add relationship-building elements
  ExpertResponse _addRelationshipElements({
    required String response,
    required ConversationContext context,
  }) {
    // Add proactive suggestions
    final suggestions = _generateProactiveSuggestions(context);
    
    // Determine appropriate emotion based on context
    final emotion = _determineExpertEmotion(context);
    
    // Add follow-up questions to build relationship
    final enhancedResponse = _addFollowUpQuestions(response, context);
    
    return ExpertResponse(
      content: enhancedResponse,
      emotion: emotion,
      confidence: 0.85,
      responseType: ExpertResponseType.guidance,
      suggestedActions: suggestions,
      metadata: {
        'relationship_building': true,
        'context_aware': true,
      },
    );
  }

  // Personality-specific response generators

  String _generateFrameworkResponse(String framework) {
    final responses = {
      'soc 2': "SOC 2 is one of my favorite frameworks to work with! It's designed to show your customers that you take data security seriously. Think of it as your 'trust certificate' for handling sensitive information.",
      
      'iso 27001': "ISO 27001 is the gold standard for information security management. I love how comprehensive it is - it covers everything from risk assessment to incident response. Perfect for organizations serious about security.",
      
      'gdpr': "GDPR is fascinating because it puts individuals back in control of their data. As your expert, I'll help you navigate the rights management, data processing requirements, and privacy by design principles.",
    };
    
    return responses[framework.toLowerCase()] ?? 
        "That's a great framework to focus on! Let me help you understand exactly what it requires and how we can implement it together.";
  }

  String _generateGettingStartedResponse(ConversationContext context) {
    if (context.companyName != null) {
      return "I'm excited to help ${context.companyName} build a strong compliance program! Let's start by understanding your current situation. What specific compliance requirements are driving your need right now?";
    } else {
      return "I'm here to guide you through every step of your compliance journey. Let's begin by understanding what brought you here today - is there a specific audit, customer requirement, or regulation you're working with?";
    }
  }

  String _generateStatusResponse(ConversationContext context) {
    return "Great question! Let me give you a comprehensive view of where you stand. Based on what I know about your situation, I can see several areas where we can make immediate progress. Would you like me to create a personalized assessment for you?";
  }

  // Helper methods for personality enhancement

  String _addEncouragement(String response) {
    final encouragements = [
      "Don't worry, we'll tackle this together! ",
      "I know compliance can feel overwhelming, but you're in good hands. ",
      "You're asking all the right questions - that's what I love to see! ",
    ];
    
    return encouragements[_random.nextInt(encouragements.length)] + response;
  }

  String _addExpertiseIndicators(String response, UserIntent intent) {
    final indicators = [
      "In my experience with hundreds of compliance programs, ",
      "Based on what I've seen work best in situations like yours, ",
      "As someone who's guided many organizations through this process, ",
    ];
    
    if (_random.nextBool()) {
      return indicators[_random.nextInt(indicators.length)] + response.toLowerCase();
    }
    return response;
  }

  String _addPersonalTouches(String response, ConversationContext context) {
    if (context.userName != null && _random.nextBool()) {
      return response.replaceFirst(
        RegExp(r'^'),
        '${context.userName}, '
      );
    }
    return response;
  }

  List<String> _generateProactiveSuggestions(ConversationContext context) {
    return [
      "Tell me about your industry requirements",
      "Let's assess your current compliance state", 
      "Show me what frameworks you need",
      "Help me understand your timeline",
    ];
  }

  ExpertEmotion _determineExpertEmotion(ConversationContext context) {
    // Determine appropriate emotion based on context
    return ExpertEmotion.professional;
  }

  String _addFollowUpQuestions(String response, ConversationContext context) {
    if (context.primaryFrameworks.isEmpty) {
      return "$response\n\nBy the way, what specific compliance frameworks are you most interested in? I can tailor my guidance to exactly what you need.";
    }
    return response;
  }

  // Utility methods

  String _getPersonalGreeting() {
    return _context.userName ?? 'there';
  }

  List<String> _getWelcomeSuggestions() {
    return [
      "Tell me about SOC 2",
      "Help me get started", 
      "What frameworks do I need?",
      "Assess my compliance readiness",
    ];
  }

  List<String> _extractFrameworks(String message) {
    final frameworks = <String>[];
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('soc 2')) frameworks.add('SOC 2');
    if (lowerMessage.contains('iso 27001')) frameworks.add('ISO 27001');
    if (lowerMessage.contains('gdpr')) frameworks.add('GDPR');
    if (lowerMessage.contains('hipaa')) frameworks.add('HIPAA');
    if (lowerMessage.contains('pci')) frameworks.add('PCI DSS');
    
    return frameworks;
  }

  ExpertResponse _generateFallbackResponse(String userMessage) {
    return ExpertResponse(
      content: "I want to give you the best guidance possible. Could you help me understand what specific aspect of compliance you'd like to explore? I'm here to help with any questions you have.",
      emotion: ExpertEmotion.helpful,
      confidence: 0.6,
      responseType: ExpertResponseType.clarification,
      suggestedActions: [
        "Ask about a specific framework",
        "Tell me about getting started",
        "Help with document creation",
      ],
    );
  }

  // Additional helper methods for response generation
  String _generateDocumentCreationResponse(String userMessage) {
    return "I'd be happy to help you create that document! I can generate professional, compliant documents tailored to your specific needs. What type of document are you looking to create, and what framework should it align with?";
  }

  String _generateExplanationResponse(String userMessage) {
    return "Great question! I love explaining compliance concepts in a way that makes sense. Let me break this down for you in practical terms that you can actually use...";
  }

  String _generateGeneralResponse(String userMessage) {
    return "I'm here to help you with anything compliance-related. Whether you need guidance on frameworks, help with documentation, or just want to understand your requirements better, I've got you covered. What can I help you with today?";
  }

  // Build expert configuration methods
  ExpertExpertise _buildExpertise(List<String>? frameworks) {
    return ExpertExpertise(
      primaryFrameworks: frameworks ?? ['SOC 2', 'ISO 27001', 'GDPR'],
      industries: ['Technology', 'Financial Services', 'Healthcare'],
      yearsExperience: 15,
      specializations: ['Risk Assessment', 'Audit Preparation', 'Policy Development'],
    );
  }

  CommunicationStyle _buildCommunicationStyle(ExpertPersonalityType? type) {
    switch (type ?? ExpertPersonalityType.professional) {
      case ExpertPersonalityType.friendly:
        return CommunicationStyle(
          isEncouraging: true,
          isPersonal: true,
          showsExpertise: true,
          usesAnalogies: true,
          proactiveGuidance: true,
        );
      case ExpertPersonalityType.authoritative:
        return CommunicationStyle(
          isEncouraging: false,
          isPersonal: false,
          showsExpertise: true,
          usesAnalogies: false,
          proactiveGuidance: true,
        );
      case ExpertPersonalityType.professional:
      default:
        return CommunicationStyle(
          isEncouraging: true,
          isPersonal: true,
          showsExpertise: true,
          usesAnalogies: true,
          proactiveGuidance: true,
        );
    }
  }
}