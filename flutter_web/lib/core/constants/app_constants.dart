// FILE PATH: lib/core/constants/app_constants.dart
// App Constants - Core configuration values for ArionComply demo
// Referenced throughout the application for consistent configuration

class AppConstants {
  // App Identity
  static const String appName = 'ArionComply';
  static const String appTagline = 'Your AI Compliance Expert';
  static const String demoVersion = '1.0.0-demo';
  
  // Avatar Configuration
  static const String defaultAvatarName = 'Alex';
  static const String avatarRole = 'Senior Compliance Expert';
  static const Duration avatarResponseDelay = Duration(milliseconds: 800);
  static const Duration avatarTypingDelay = Duration(milliseconds: 1200);
  
  // Conversation Settings
  static const int maxConversationHistory = 50;
  static const Duration speechTimeout = Duration(seconds: 5);
  static const double speechConfidenceThreshold = 0.7;
  
  // Demo Business Logic
  static const List<String> supportedFrameworks = [
    'SOC 2',
    'ISO 27001', 
    'GDPR',
    'EU AI Act',
    'CCPA',
    'HIPAA'
  ];
  
  // Marketing & Embedding
  static const String marketingUrl = 'https://arioncomply.com';
  static const String embedQueryParam = 'embed';
  static const String sourceQueryParam = 'source';
  
  // Voice & Audio
  static const String defaultVoiceLocale = 'en-US';
  static const double defaultSpeechRate = 1.0;
  static const double defaultSpeechPitch = 1.0;
  static const double defaultSpeechVolume = 1.0;
  
  // AI Transparency (Key differentiator)
  static const bool enableExplainableAI = true;
  static const bool logAllAIDecisions = true;
  static const String aiTransparencyLevel = 'full'; // 'full', 'summary', 'minimal'
  
  // Demo Features Toggle
  static const bool enableVoiceInput = true;
  static const bool enableVoiceOutput = true;
  static const bool enable3DAvatar = true;
  static const bool enableEmbedding = true;
  static const bool enableAnalytics = true;
  
  // Responsive Breakpoints
  static const double mobileBreakpoint = 480;
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;
  
  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
}