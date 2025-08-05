// FILE PATH: lib/core/constants/text_constants.dart
// Text Constants - All app text in one place

class TextConstants {
  // Welcome messages
  static const String welcomeMessage = "Hi! I'm Alex, your compliance expert. I'm here to help you build a robust compliance program. What would you like to work on today?";
  
  static const String newUserWelcome = "Welcome to ArionComply! I'm Alex, and I'll be your guide through compliance requirements. Let's start by understanding your business - what industry are you in?";
  
  static const String returningUserWelcome = "Welcome back! Ready to continue building your compliance program?";

  // Avatar states
  static const String avatarIdle = "Ready to help";
  static const String avatarListening = "I'm listening...";
  static const String avatarThinking = "Let me think about that...";
  static const String avatarSpeaking = "Here's what I think...";
  static const String avatarProcessing = "Processing your request...";
  static const String avatarError = "Something went wrong";

  // Error messages
  static const String genericError = "I'm having trouble processing that. Could you try rephrasing?";
  static const String networkError = "I'm having connectivity issues. Please check your internet connection.";
  static const String voiceError = "I couldn't hear that clearly. Could you try again?";
  
  // Success messages
  static const String assessmentComplete = "Great! I've gathered enough information to provide personalized recommendations.";
  static const String frameworkSelected = "Excellent choice! Let's dive into the requirements.";
  static const String progressSaved = "Your progress has been saved automatically.";

  // Onboarding
  static const String onboardingTitle = "Meet Alex";
  static const String onboardingSubtitle = "Your AI compliance expert";
  static const String onboardingDescription = "Alex will guide you through compliance requirements, help you build documentation, and ensure you're audit-ready.";
  
  // Navigation
  static const String navHome = "Home";
  static const String navAssessment = "Assessment";
  static const String navFrameworks = "Frameworks";
  static const String navChat = "Chat";
  static const String navDemo = "Demo";

  // Buttons
  static const String btnGetStarted = "Get Started";
  static const String btnContinue = "Continue";
  static const String btnSkip = "Skip";
  static const String btnNext = "Next";
  static const String btnBack = "Back";
  static const String btnSave = "Save";
  static const String btnCancel = "Cancel";
  static const String btnRetry = "Try Again";
  static const String btnClear = "Clear";
  static const String btnSend = "Send";

  // Placeholders
  static const String messagePlaceholder = "Type your message...";
  static const String searchPlaceholder = "Search...";
  static const String emailPlaceholder = "Enter your email";
  static const String companyPlaceholder = "Enter company name";

  // Framework names
  static const String frameworkSOC2 = "SOC 2";
  static const String frameworkISO27001 = "ISO 27001";
  static const String frameworkGDPR = "GDPR";
  static const String frameworkHIPAA = "HIPAA";
  static const String frameworkPCIDSS = "PCI DSS";

  // Assessment questions
  static const List<String> assessmentQuestions = [
    "Let's start with your current security posture. Do you have multi-factor authentication enabled for all employees?",
    "How do you currently manage user permissions and access reviews?",
    "Tell me about your data handling practices. How do you classify and protect sensitive information?",
    "What monitoring and logging systems do you have in place?",
    "How do you handle incident response and business continuity planning?",
  ];

  // Personality descriptions
  static const Map<String, String> personalityDescriptions = {
    'friendly': 'Encouraging and approachable, perfect for getting started',
    'professional': 'Balanced and thorough, ideal for most business needs',
    'authoritative': 'Direct and comprehensive, best for executive-level guidance',
  };

  // Demo content
  static const String demoTitle = "Interactive Demo";
  static const String demoDescription = "Experience how Alex guides you through compliance requirements";
  
  // Legal
  static const String privacyNotice = "Your conversations are processed securely and never shared.";
  static const String dataRetention = "Conversation data is stored locally and can be cleared anytime.";
  
  // Accessibility
  static const String accessibilityVoiceButton = "Toggle voice input";
  static const String accessibilityMenuButton = "Open menu";
  static const String accessibilitySendButton = "Send message";
  static const String accessibilityCloseButton = "Close";
}