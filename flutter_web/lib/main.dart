// lib/main.dart
// ArionComply Demo - Main App Entry Point
// Revolutionary "Personal AI Expert" Platform
// Avatar-first interface, not traditional web UI

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import 'core/app/app.dart';
import 'core/services/storage_service.dart';
import 'core/services/audio_service.dart';

import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize core services for demo
  await _initializeServices();
  
  // Log startup for demo tracking
  if (kDebugMode) {
    print('🚀 ArionComply Demo Starting...');
    print('📱 Platform: ${defaultTargetPlatform.name}');
    print('🌐 Web: ${kIsWeb ? "YES" : "NO"}');
  }
  
  runApp(
    ProviderScope(
      child: ArionComplyDemoApp(),
    ),
  );
}

/// Initialize essential services for demo functionality
Future<void> _initializeServices() async {
  try {
    // Initialize local storage for demo data persistence
    await StorageService.initialize();
    
    // Initialize audio services for voice interaction
    await AudioService.initialize();
    
    if (kDebugMode) {
      print('✅ Demo services initialized successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Service initialization error: $e');
    }
  }
}

// lib/core/app/app.dart
// Main App Widget - Avatar-Centric Design



class ArionComplyDemoApp extends StatelessWidget {
  const ArionComplyDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ArionComply - Your AI Compliance Expert',
      debugShowCheckedModeBanner: false,
      
      // Avatar-centric theme design
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      
      // Router configuration for demo flows
      routerConfig: AppRouter.config,
      
      // Builder for global avatar overlay capability
      builder: (context, child) {
        return MediaQuery(
          // Ensure text scaling works across devices
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context).textScaler.clamp(
              minScaleFactor: 0.8,
              maxScaleFactor: 1.2,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

// lib/core/app/app_constants.dart
// Core constants for ArionComply demo

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
  
  // Responsive Breakpoints (matching HTML mockup system)
  static const double mobileBreakpoint = 480;
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;
  
  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  
  // Colors (Will be defined in theme)
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color aiPurple = Color(0xFF8B5CF6);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
}

// lib/core/app/app_config.dart
// Configuration for different environments and embedding modes



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
}// FILE PATH: lib/main.dart
// Main entry point - Fixed version with proper imports

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Core imports
import 'core/theme/app_colors.dart';
import 'core/routing/app_router.dart';

// Features
import 'features/avatar/screens/avatar_home_screen.dart';
import 'features/assessment/screens/assessment_screen.dart';
import 'features/framework/screens/framework_selection_screen.dart';
import 'features/demo/screens/demo_showcase_screen.dart';
import 'features/chat/screens/standalone_chat_screen.dart';

// Shared widgets
import 'shared/widgets/responsive_layout.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArionComply Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: _createMaterialColor(AppColors.primary),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const MainScreen(),
      routes: {
        '/avatar': (context) => const AvatarHomeScreen(),
        '/assessment': (context) => const AssessmentScreen(),
        '/framework': (context) => const FrameworkSelectionScreen(),
        '/demo': (context) => const DemoShowcaseScreen(),
        '/chat': (context) => const StandaloneChatScreen(),
      },
    );
  }

  // Helper to create MaterialColor from Color
  MaterialColor _createMaterialColor(Color color) {
    final int red = color.red;
    final int green = color.green;
    final int blue = color.blue;

    final Map<int, Color> shades = {
      50: Color.fromRGBO(red, green, blue, .1),
      100: Color.fromRGBO(red, green, blue, .2),
      200: Color.fromRGBO(red, green, blue, .3),
      300: Color.fromRGBO(red, green, blue, .4),
      400: Color.fromRGBO(red, green, blue, .5),
      500: Color.fromRGBO(red, green, blue, .6),
      600: Color.fromRGBO(red, green, blue, .7),
      700: Color.fromRGBO(red, green, blue, .8),
      800: Color.fromRGBO(red, green, blue, .9),
      900: Color.fromRGBO(red, green, blue, 1),
    };

    return MaterialColor(color.value, shades);
  }
}

// Simple main screen with navigation
class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(context),
        tablet: _buildTabletLayout(context),
        desktop: _buildDesktopLayout(context),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return const AvatarHomeScreen(); // Default to avatar screen on mobile
  }

  Widget _buildTabletLayout(BuildContext context) {
    return const AvatarHomeScreen(); // Default to avatar screen on tablet
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Navigation sidebar
        Container(
          width: 250,
          color: AppColors.surfaceSecondary,
          child: _buildNavigationSidebar(context),
        ),
        // Main content
        const Expanded(
          child: AvatarHomeScreen(),
        ),
      ],
    );
  }

  Widget _buildNavigationSidebar(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'ArionComply',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 24),
        _buildNavItem(context, 'Avatar Chat', '/avatar', Icons.psychology),
        _buildNavItem(context, 'Assessment', '/assessment', Icons.assessment),
        _buildNavItem(context, 'Framework', '/framework', Icons.account_tree),
        _buildNavItem(context, 'Demo', '/demo', Icons.play_circle),
        _buildNavItem(context, 'Chat', '/chat', Icons.chat),
      ],
    );
  }

  Widget _buildNavItem(BuildContext context, String title, String route, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }
}