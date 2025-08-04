// FILE PATH: lib/core/constants/text_constants.dart
// Text Constants - Consistent messaging and copy throughout the app
// Supports localization and maintains brand voice consistency

class TextConstants {
  // App Identity & Branding
  static const String appName = 'ArionComply';
  static const String appTagline = 'Your AI Compliance Expert';
  static const String expertName = 'Alex';
  static const String expertRole = 'Senior Compliance Expert';

  // Welcome & Onboarding Messages
  static const String welcomeMessage = 
      "Hi! I'm Alex, your personal AI compliance expert. I'm here to help you navigate compliance requirements with confidence and build a strong program for your organization.";
  
  static const String newUserWelcome = 
      "Welcome to ArionComply! I'm Alex, and I'll be your dedicated compliance guide. Think of me as your expert who's available 24/7 to help you succeed.";
  
  static const String returningUserWelcome = 
      "Welcome back! I'm excited to continue working with you on your compliance journey. What can I help you with today?";

  // Framework-Specific Messages
  static const Map<String, String> frameworkIntroductions = {
    'soc2': "SOC 2 is one of my favorite frameworks to work with! It's designed to show your customers that you take data security seriously. Think of it as your 'trust certificate' for handling sensitive information.",
    
    'iso27001': "ISO 27001 is the gold standard for information security management. I love how comprehensive it is - it covers everything from risk assessment to incident response. Perfect for organizations serious about security.",
    
    'gdpr': "GDPR is fascinating because it puts individuals back in control of their data. I'll help you navigate the rights management, data processing requirements, and privacy by design principles.",
    
    'hipaa': "HIPAA is crucial for protecting patient health information. I'll guide you through the privacy and security rules, helping you create a compliant healthcare environment.",
    
    'pci': "PCI DSS is essential for anyone handling payment card data. I'll help you understand the requirements and implement the necessary security controls to protect cardholder information.",
    
    'ccpa': "CCPA gives California consumers powerful rights over their personal information. I'll help you understand your obligations and implement the necessary processes for compliance.",
  };

  // Common Responses & Phrases
  static const List<String> encouragingPhrases = [
    "You're asking all the right questions!",
    "That's a great point to consider.",
    "I can see you're thinking strategically about this.",
    "You're on the right track with that approach.",
    "That shows good compliance thinking!",
  ];

  static const List<String> processingMessages = [
    "Let me think about that for a moment...",
    "I'm analyzing the best approach for your situation...",
    "Considering your specific requirements...",
    "Reviewing the relevant compliance standards...",
    "Thinking through the implementation details...",
  ];

  static const List<String> clarificationPhrases = [
    "To give you the best guidance, could you tell me more about",
    "I want to make sure I understand your situation correctly.",
    "Help me understand your specific context so I can provide better guidance.",
    "A bit more detail would help me tailor my advice to your needs.",
    "To provide the most relevant guidance, I'd like to know",
  ];

  // Suggestion Prompts
  static const Map<String, List<String>> suggestionsByContext = {
    'new_user': [
      "Tell me about SOC 2",
      "Help me get started",
      "What frameworks do I need?",
      "Assess my compliance readiness",
    ],
    'framework_explorer': [
      "Compare SOC 2 vs ISO 27001",
      "Show me GDPR requirements",
      "Help with framework selection",
      "Explain compliance basics",
    ],
    'assessment_mode': [
      "Continue my assessment",
      "Review my progress",
      "Get implementation guidance",
      "Create compliance documents",
    ],
    'experienced_user': [
      "Audit preparation tips",
      "Policy template creation",
      "Risk assessment guidance",
      "Advanced compliance topics",
    ],
  };

  // Error Messages
  static const String genericError = 
      "I encountered an unexpected issue. Let me try a different approach to help you.";
  
  static const String networkError = 
      "I'm having trouble connecting right now. Please check your internet connection and try again.";
  
  static const String processingError = 
      "I'm having difficulty processing that request. Could you try rephrasing your question?";
  
  static const String voiceError = 
      "I couldn't quite catch that. Could you try speaking again or type your message instead?";

  // Success Messages
  static const String assessmentCompleted = 
      "Great job completing your assessment! I've identified several areas where we can strengthen your compliance program.";
  
  static const String documentCreated = 
      "I've created your document! It follows industry best practices and is tailored to your specific requirements.";
  
  static const String progressSaved = 
      "Your progress has been saved. You can continue anytime from where you left off.";

  // Call-to-Action Messages
  static const String getStartedCTA = 
      "Ready to build a strong compliance program? Let's start by understanding your specific needs.";
  
  static const String continueAssessmentCTA = 
      "Let's continue building your compliance program. What area would you like to focus on next?";
  
  static const String scheduleDemo = 
      "Want to see how ArionComply can transform your compliance program? Let's schedule a personalized demo.";

  // Help & Support
  static const String helpMessage = 
      "I'm here to help with any compliance questions you have. You can ask me about specific frameworks, request document creation, or get guidance on implementation strategies.";
  
  static const List<String> helpTopics = [
    "Ask about compliance frameworks (SOC 2, ISO 27001, GDPR, etc.)",
    "Request document creation and templates",
    "Get implementation guidance and best practices",
    "Understand audit preparation requirements",
    "Learn about risk assessment processes",
    "Explore industry-specific compliance needs",
  ];

  // Voice Interface Messages
  static const String voicePrompt = 
      "I'm listening... You can ask me anything about compliance.";
  
  static const String voiceStopPrompt = 
      "Tap the microphone again when you're ready to speak.";
  
  static const String voiceProcessing = 
      "I heard you, let me process that...";

  // Personality-Specific Phrases
  static const Map<String, Map<String, List<String>>> personalityPhrases = {
    'friendly': {
      'greetings': [
        "Hey there! Ready to tackle some compliance challenges?",
        "Hi! I'm excited to help you with your compliance journey.",
        "Hello! Let's make compliance less overwhelming and more achievable.",
      ],
      'encouragement': [
        "You've got this! Compliance might seem complex, but we'll break it down together.",
        "Don't worry, I'm here to guide you through every step.",
        "That's a great question! You're thinking like a compliance pro already.",
      ],
    },
    'professional': {
      'greetings': [
        "Good day. I'm here to assist with your compliance requirements.",
        "Hello. Let's work together to strengthen your compliance program.",
        "Greetings. I'm ready to help you achieve your compliance objectives.",
      ],
      'encouragement': [
        "Your systematic approach to compliance is commendable.",
        "This demonstrates strong risk management thinking.",
        "That's an excellent strategic consideration.",
      ],
    },
    'authoritative': {
      'greetings': [
        "I'm here to ensure your compliance program meets the highest standards.",
        "Let's establish a robust compliance framework for your organization.",
        "We'll build a compliance program that withstands any audit.",
      ],
      'encouragement': [
        "This approach aligns with industry best practices.",
        "You're implementing the right controls for your risk profile.",
        "This strategy will significantly strengthen your compliance posture.",
      ],
    },
  };

  // Industry-Specific Messages
  static const Map<String, String> industryWelcomeMessages = {
    'technology': "As a technology company, you're likely dealing with data privacy, security, and potentially SOC 2 requirements. I'm here to help you navigate these critical compliance areas.",
    
    'healthcare': "Healthcare organizations face unique compliance challenges with HIPAA, data security, and patient privacy. I'll help you create a comprehensive compliance program.",
    
    'financial': "Financial services require robust compliance programs covering data protection, operational risk, and regulatory requirements. Let's build a program that meets all your needs.",
    
    'saas': "SaaS companies typically need SOC 2 compliance to build customer trust and meet enterprise requirements. I'll guide you through the entire process.",
    
    'startup': "Startups need to build compliance into their foundation. I'll help you implement the right frameworks without slowing down your growth.",
  };

  // Status & Progress Messages
  static const String assessmentInProgress = 
      "Your assessment is in progress. You've completed {completed} out of {total} sections.";
  
  static const String nextStepsReady = 
      "Based on your assessment, I've identified {count} priority areas to focus on next.";
  
  static const String complianceGapFound = 
      "I've identified some gaps in your current compliance program. Let's work together to address them.";

  // Time-Based Messages
  static const Map<String, String> timeBasedGreetings = {
    'morning': "Good morning! Ready to make progress on your compliance program today?",
    'afternoon': "Good afternoon! Let's continue building your compliance framework.",
    'evening': "Good evening! I'm here whenever you need compliance guidance.",
  };

  // Footer & Legal
  static const String privacyNotice = 
      "Your conversations with me are private and secure. I don't store personal information without your permission.";
  
  static const String aiDisclosure = 
      "I'm an AI compliance expert designed to provide guidance and assistance. For specific legal advice, please consult with a qualified compliance attorney.";
  
  static const String dataHandling = 
      "I follow strict data handling protocols to ensure your information remains secure and confidential.";

  // Demo & Marketing Messages
  static const String demoIntroduction = 
      "Welcome to the ArionComply demo! I'll show you how our AI compliance expert can transform your compliance program.";
  
  static const String marketingValue = 
      "ArionComply makes compliance approachable, efficient, and stress-free. Let me show you how.";
  
  static const String embeddedWelcome = 
      "Hi! I'm your AI compliance expert. I can help you understand requirements, assess your readiness, and create the documents you need.";

  // Utility Methods
  static String getRandomFromList(List<String> list) {
    if (list.isEmpty) return '';
    return list[DateTime.now().millisecond % list.length];
  }

  static String getPersonalityPhrase(String personality, String category) {
    final phrases = personalityPhrases[personality]?[category];
    if (phrases == null || phrases.isEmpty) return '';
    return getRandomFromList(phrases);
  }

  static String getFrameworkIntroduction(String framework) {
    return frameworkIntroductions[framework.toLowerCase()] ?? 
           "That's a great framework to focus on! Let me help you understand exactly what it requires and how we can implement it together.";
  }

  static String getIndustryWelcome(String industry) {
    return industryWelcomeMessages[industry.toLowerCase()] ?? 
           "Every industry has unique compliance requirements. I'll help you navigate the specific challenges in your field.";
  }

  static String getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return timeBasedGreetings['morning']!;
    if (hour < 17) return timeBasedGreetings['afternoon']!;
    return timeBasedGreetings['evening']!;
  }

  static List<String> getSuggestionsByContext(String context) {
    return suggestionsByContext[context] ?? suggestionsByContext['new_user']!;
  }
}