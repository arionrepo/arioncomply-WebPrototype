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
    List<String>? conversationHistory,
  }) async {
    try {
      // Update context
      _context = context;
      
      // Analyze user intent and emotional context
      final intent = _analyzeUserIntent(userMessage);
      final emotionalContext = _analyzeEmotionalContext(userMessage, context);
      
      // Generate response based on personality and context
      final baseResponse = await _generateBaseResponse(
        userMessage: userMessage,
        intent: intent,
        context: context,
      );
      
      // Apply personality styling
      final personalizedResponse = _applyPersonalityStyle(
        baseResponse: baseResponse,
        emotionalContext: emotionalContext,
        intent: intent,
      );
      
      // Add transparency information
      await _transparencyService.logInteraction(
        userMessage: userMessage,
        expertResponse: personalizedResponse.content,
        personalityType: _personality.personalityType,
        confidence: personalizedResponse.confidence,
      );
      
      return personalizedResponse;
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error generating expert response: $e');
      }
      
      return ExpertResponse(
        content: "I apologize, but I'm having trouble processing your request right now. Could you please rephrase that?",
        emotion: ExpertEmotion.concerned,
        confidence: 0.5,
        responseType: ExpertResponseType.clarification,
        suggestedActions: ['Try rephrasing your question', 'Ask about a specific framework'],
      );
    }
  }

  /// Build expert expertise based on user preferences
  ExpertExpertise _buildExpertise(List<String>? primaryFrameworks) {
    return ExpertExpertise(
      primaryFrameworks: primaryFrameworks ?? ['SOC 2', 'ISO 27001', 'GDPR'],
      industries: ['Technology', 'Healthcare', 'Financial Services'],
      yearsExperience: 10,
      specializations: [
        'Risk Assessment',
        'Policy Development',
        'Audit Preparation',
        'Compliance Training',
      ],
    );
  }

  /// Build communication style based on personality type
  CommunicationStyle _buildCommunicationStyle(ExpertPersonalityType? type) {
    switch (type ?? ExpertPersonalityType.professional) {
      case ExpertPersonalityType.friendly:
        return const CommunicationStyle(
          isEncouraging: true,
          isPersonal: true,
          showsExpertise: false,
          usesAnalogies: true,
          proactiveGuidance: true,
        );
      case ExpertPersonalityType.professional:
        return const CommunicationStyle(
          isEncouraging: true,
          isPersonal: false,
          showsExpertise: true,
          usesAnalogies: false,
          proactiveGuidance: true,
        );
      case ExpertPersonalityType.authoritative:
        return const CommunicationStyle(
          isEncouraging: false,
          isPersonal: false,
          showsExpertise: true,
          usesAnalogies: false,
          proactiveGuidance: false,
        );
    }
  }

  /// Generate welcome message for new users
  ExpertResponse generateWelcomeMessage() {
    final welcomeMessages = [
      "Hello! I'm ${_personality.name}, your personal compliance expert. I'm here to help you navigate the world of compliance with confidence.",
      
      "Welcome! I'm ${_personality.name}, and I'll be your dedicated compliance guide. Think of me as your ${_personality.role.toLowerCase()} who's available 24/7 to help you succeed.",
      
      "Hi there! I'm ${_personality.name}, your AI compliance expert. I'm excited to work with you on building a strong compliance program for ${_context.companyName ?? 'your organization'}.",
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
    
    // Framework-related intents - FIXED: No more RegExp issues
    if (lowerMessage.contains('soc 2') || 
        lowerMessage.contains('iso 27001') || 
        lowerMessage.contains('gdpr') || 
        lowerMessage.contains('hipaa') || 
        lowerMessage.contains('pci')) {
      return UserIntent(
        type: IntentType.frameworkInquiry,
        confidence: 0.9,
        entities: _extractFrameworks(message),
      );
    }
    
    // Getting started intents
    if (lowerMessage.contains('start') || 
        lowerMessage.contains('begin') || 
        lowerMessage.contains('help') || 
        lowerMessage.contains('new') || 
        lowerMessage.contains('setup')) {
      return UserIntent(
        type: IntentType.gettingStarted,
        confidence: 0.85,
      );
    }
    
    // Status/progress intents
    if (lowerMessage.contains('status') || 
        lowerMessage.contains('progress') || 
        lowerMessage.contains('ready') || 
        lowerMessage.contains('doing') || 
        lowerMessage.contains('complete')) {
      return UserIntent(
        type: IntentType.statusInquiry,
        confidence: 0.8,
      );
    }
    
    // Document creation intents
    if (lowerMessage.contains('create') || 
        lowerMessage.contains('generate') || 
        lowerMessage.contains('policy') || 
        lowerMessage.contains('document') || 
        lowerMessage.contains('template')) {
      return UserIntent(
        type: IntentType.documentCreation,
        confidence: 0.85,
      );
    }
    
    // Explanation intents
    if (lowerMessage.contains('what') || 
        lowerMessage.contains('why') || 
        lowerMessage.contains('how') || 
        lowerMessage.contains('explain') || 
        lowerMessage.contains('tell me')) {
      return UserIntent(
        type: IntentType.explanation,
        confidence: 0.7,
      );
    }
    
    return UserIntent(type: IntentType.general, confidence: 0.5);
  }

  /// Analyze emotional context of conversation - FIXED: No more RegExp issues
  EmotionalContext _analyzeEmotionalContext(String message, ConversationContext context) {
    final lowerMessage = message.toLowerCase();
    
    // Stress/urgency indicators
    if (lowerMessage.contains('urgent') || 
        lowerMessage.contains('asap') || 
        lowerMessage.contains('quickly') || 
        lowerMessage.contains('deadline') || 
        lowerMessage.contains('audit') || 
        lowerMessage.contains('help')) {
      return EmotionalContext.stressed;
    }
    
    // Confusion indicators - FIXED: No more unterminated string issues
    if (lowerMessage.contains('confused') || 
        lowerMessage.contains('don\'t understand') || 
        lowerMessage.contains('unclear') || 
        lowerMessage.contains('complex')) {
      return EmotionalContext.confused;
    }
    
    // Excitement/enthusiasm indicators
    if (lowerMessage.contains('great') || 
        lowerMessage.contains('awesome') || 
        lowerMessage.contains('excited') || 
        lowerMessage.contains('love') || 
        lowerMessage.contains('perfect')) {
      return EmotionalContext.enthusiastic;
    }
    
    // Frustration indicators
    if (lowerMessage.contains('frustrated') || 
        lowerMessage.contains('difficult') || 
        lowerMessage.contains('hard') || 
        lowerMessage.contains('complicated')) {
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
        return _generateFrameworkResponse(intent.entities?.first ?? 'compliance framework');
      case IntentType.gettingStarted:
        return _generateGettingStartedResponse();
      case IntentType.statusInquiry:
        return _generateStatusResponse();
      case IntentType.documentCreation:
        return _generateDocumentCreationResponse();
      case IntentType.explanation:
        return _generateExplanationResponse(userMessage);
      case IntentType.general:
      default:
        return _generateGeneralResponse(userMessage);
    }
  }

  /// Apply personality styling to response
  ExpertResponse _applyPersonalityStyle({
    required String baseResponse,
    required EmotionalContext emotionalContext,
    required UserIntent intent,
  }) {
    String styledResponse = baseResponse;
    ExpertEmotion emotion = ExpertEmotion.neutral;
    
    // Apply personality-specific modifications
    switch (_personality.personalityType) {
      case ExpertPersonalityType.friendly:
        styledResponse = _applyFriendlyStyle(styledResponse);
        emotion = _getFriendlyEmotion(emotionalContext);
        break;
      case ExpertPersonalityType.professional:
        styledResponse = _applyProfessionalStyle(styledResponse);
        emotion = _getProfessionalEmotion(emotionalContext);
        break;
      case ExpertPersonalityType.authoritative:
        styledResponse = _applyAuthoritativeStyle(styledResponse);
        emotion = _getAuthoritativeEmotion(emotionalContext);
        break;
    }
    
    return ExpertResponse(
      content: styledResponse,
      emotion: emotion,
      confidence: intent.confidence,
      responseType: _getResponseType(intent.type),
      suggestedActions: _getSuggestedActions(intent.type),
      metadata: {
        'intent_type': intent.type.toString(),
        'emotional_context': emotionalContext.toString(),
        'personality_type': _personality.personalityType.toString(),
      },
    );
  }

  /// Extract frameworks from user message
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

  /// Get welcome suggestions for new users
  List<String> _getWelcomeSuggestions() {
    return [
      'Tell me about SOC 2 compliance',
      'Help me get started with GDPR',
      'What compliance frameworks do I need?',
      'Create a compliance checklist',
    ];
  }

  /// Generate framework-specific response
  String _generateFrameworkResponse(String framework) {
    return "I'd be happy to help you with $framework! This is one of my areas of expertise. Let me break down what you need to know and help you create a solid implementation plan.";
  }

  /// Generate getting started response
  String _generateGettingStartedResponse() {
    return "Great question! Let's start by understanding your current situation. What industry are you in, and which compliance frameworks are you most concerned about?";
  }

  /// Generate status response
  String _generateStatusResponse() {
    return "I can help you assess where you are in your compliance journey. Let me ask a few questions to understand your current progress and identify the next steps.";
  }

  /// Generate document creation response
  String _generateDocumentCreationResponse() {
    return "I'd be delighted to help you create compliance documents! I can generate policies, procedures, templates, and checklists tailored to your specific needs.";
  }

  /// Generate explanation response
  String _generateExplanationResponse(String userMessage) {
    return "That's a great question! I love helping people understand compliance better. Let me explain this in a way that makes sense for your situation.";
  }

  /// Generate general response
  String _generateGeneralResponse(String userMessage) {
    return "I'm here to help with all your compliance needs. Could you tell me more specifically what you'd like to work on today?";
  }

  /// Apply friendly personality style
  String _applyFriendlyStyle(String response) {
    // Add friendly touches like encouragement and personal connection
    if (!response.contains('!')) {
      response = response.replaceFirst('.', '!');
    }
    return response;
  }

  /// Apply professional personality style
  String _applyProfessionalStyle(String response) {
    // Keep it professional but supportive
    return response;
  }

  /// Apply authoritative personality style
  String _applyAuthoritativeStyle(String response) {
    // More direct and expert-focused
    return response.replaceAll('I think', 'In my experience').replaceAll('maybe', 'typically');
  }

  /// Get emotion for friendly personality
  ExpertEmotion _getFriendlyEmotion(EmotionalContext context) {
    switch (context) {
      case EmotionalContext.stressed:
        return ExpertEmotion.encouraging;
      case EmotionalContext.confused:
        return ExpertEmotion.helpful;
      case EmotionalContext.enthusiastic:
        return ExpertEmotion.celebratory;
      case EmotionalContext.frustrated:
        return ExpertEmotion.encouraging;
      case EmotionalContext.neutral:
      default:
        return ExpertEmotion.happy;
    }
  }

  /// Get emotion for professional personality
  ExpertEmotion _getProfessionalEmotion(EmotionalContext context) {
    switch (context) {
      case EmotionalContext.stressed:
        return ExpertEmotion.focused;
      case EmotionalContext.confused:
        return ExpertEmotion.helpful;
      case EmotionalContext.enthusiastic:
        return ExpertEmotion.encouraging;
      case EmotionalContext.frustrated:
        return ExpertEmotion.focused;
      case EmotionalContext.neutral:
      default:
        return ExpertEmotion.neutral;
    }
  }

  /// Get emotion for authoritative personality
  ExpertEmotion _getAuthoritativeEmotion(EmotionalContext context) {
    switch (context) {
      case EmotionalContext.stressed:
        return ExpertEmotion.serious;
      case EmotionalContext.confused:
        return ExpertEmotion.focused;
      case EmotionalContext.enthusiastic:
        return ExpertEmotion.neutral;
      case EmotionalContext.frustrated:
        return ExpertEmotion.serious;
      case EmotionalContext.neutral:
      default:
        return ExpertEmotion.serious;
    }
  }

  /// Get response type based on intent
  ExpertResponseType _getResponseType(IntentType intentType) {
    switch (intentType) {
      case IntentType.frameworkInquiry:
        return ExpertResponseType.explanation;
      case IntentType.gettingStarted:
        return ExpertResponseType.guidance;
      case IntentType.statusInquiry:
        return ExpertResponseType.guidance;
      case IntentType.documentCreation:
        return ExpertResponseType.instruction;
      case IntentType.explanation:
        return ExpertResponseType.explanation;
      case IntentType.general:
      default:
        return ExpertResponseType.clarification;
    }
  }

  /// Get suggested actions based on intent
  List<String> _getSuggestedActions(IntentType intentType) {
    switch (intentType) {
      case IntentType.frameworkInquiry:
        return ['Create an implementation plan', 'Generate a checklist', 'Schedule a compliance review'];
      case IntentType.gettingStarted:
        return ['Take a compliance assessment', 'Choose your frameworks', 'Set up your program'];
      case IntentType.statusInquiry:
        return ['Review current progress', 'Identify gaps', 'Plan next steps'];
      case IntentType.documentCreation:
        return ['Create a policy template', 'Generate procedures', 'Build a checklist'];
      case IntentType.explanation:
        return ['Learn more details', 'See examples', 'Get implementation guidance'];
      case IntentType.general:
      default:
        return ['Ask about specific frameworks', 'Get started with compliance', 'Create documents'];
    }
  }
}