// FILE PATH: lib/core/app/app_config.dart
// Configuration for different environments and embedding modes

import 'package:flutter/foundation.dart';

class AppConfig {
  static AppConfig? _instance;
  static AppConfig get instance => _instance ??= AppConfig._();
  AppConfig._();
  
  // Environment Detection
  bool get isDemo => true; // Always true for this demo version
  bool get isWeb => kIsWeb;
  bool get isProduction => kReleaseMode;
  bool get isDebug => kDebugMode;
  
  // Embedding Detection (for marketing pages)
  bool _isEmbedded = false;
  bool get isEmbedded => _isEmbedded;
  
  String _embedSource = '';
  String get embedSource => _embedSource;
  
  // Initialize configuration based on URL parameters (web)
  void initialize({
    bool? embedded,
    String? source,
  }) {
    _isEmbedded = embedded ?? false;
    _embedSource = source ?? '';
    
    if (kDebugMode) {
      print('🔧 App Config Initialized:');
      print('   Embedded: $_isEmbedded');
      print('   Source: $_embedSource');
    }
  }
  
  // Feature flags for demo
  bool get enableFullFeatures => !isEmbedded;
  bool get enableNavigation => !isEmbedded;
  bool get enableUserAccounts => !isEmbedded;
  bool get enableAdvancedSettings => !isEmbedded;
  
  // Avatar behavior based on context
  bool get enableProactiveGuidance => true;
  bool get enablePersonalityEngine => true;
  bool get enableVoiceInteraction => true;
  bool get enableAITransparency => true;
  
  // API Configuration (demo endpoints)
  String get apiBaseUrl {
    if (isProduction) {
      return 'https://api.arioncomply.com';
    } else {
      return 'https://demo-api.arioncomply.com';
    }
  }
  
  // Analytics Configuration
  bool get enableAnalytics => isProduction;
  String get analyticsKey => isProduction ? 'prod_key' : 'demo_key';
}