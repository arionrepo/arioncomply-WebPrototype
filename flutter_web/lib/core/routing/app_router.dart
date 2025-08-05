// lib/core/routing/app_router.dart
// ArionComply Routing System - Web-friendly with embedding support
// Supports marketing embedding, deep links, and avatar-first navigation

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/avatar/screens/avatar_home_screen.dart';
import '../../features/framework/screens/framework_selection_screen.dart';
import '../../features/assessment/screens/assessment_screen.dart';
import '../../features/chat/screens/standalone_chat_screen.dart';
import '../../features/demo/screens/demo_showcase_screen.dart';
import '../../features/embedding/screens/embedded_widget_screen.dart';
import '../app/app_config.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  
  static GoRouter get config => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: kDebugMode,
    
    // URL path strategy for web deployment
    //urlPathStrategy: UrlPathStrategy.path,
    
    routes: [
      // Main Avatar Interface Route (Primary)
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) {
          _handleEmbeddingParams(state);
          return const AvatarHomeScreen();
        },
      ),

      // Framework Selection (Conversation-driven)
      GoRoute(
        path: '/frameworks',
        name: 'frameworks',
        builder: (context, state) {
          return const FrameworkSelectionScreen();
        },
      ),

      // Specific Framework Routes (for marketing deep links)
      GoRoute(
        path: '/framework/:id',
        name: 'framework-detail',
        builder: (context, state) {
          final frameworkId = state.pathParameters['id'] ?? '';
          return FrameworkSelectionScreen(selectedFramework: frameworkId);
        },
      ),

      // Assessment Flow
      GoRoute(
        path: '/assessment/:framework',
        name: 'assessment',
        builder: (context, state) {
          final framework = state.pathParameters['framework'] ?? '';
          final step = state.uri.queryParameters['step'];
          return AssessmentScreen(
            framework: framework,
            initialStep: step != null ? int.tryParse(step) : 1,
          );
        },
      ),

      // Standalone Chat Interface
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) {
          final context = state.uri.queryParameters['context'] ?? '';
          return StandaloneChatScreen(initialContext: context);
        },
      ),

      // Demo Showcase (for stakeholder demos)
      GoRoute(
        path: '/demo',
        name: 'demo',
        builder: (context, state) {
          return const DemoShowcaseScreen();
        },
      ),

      // Embedded Widget Routes (for marketing integration)
      GoRoute(
        path: '/embed',
        name: 'embed',
        builder: (context, state) {
          final framework = state.uri.queryParameters['framework'];
          final source = state.uri.queryParameters['source'];
          final minimal = state.uri.queryParameters['minimal'] == 'true';
          
          return EmbeddedWidgetScreen(
            framework: framework,
            source: source,
            minimal: minimal,
          );
        },
      ),

      // Marketing Landing Pages (SEO-friendly URLs)
      GoRoute(
        path: '/soc2-assessment',
        name: 'soc2-landing',
        builder: (context, state) {
          return _buildMarketingLanding('soc2', state);
        },
      ),

      GoRoute(
        path: '/gdpr-assessment',
        name: 'gdpr-landing',
        builder: (context, state) {
          return _buildMarketingLanding('gdpr', state);
        },
      ),

      GoRoute(
        path: '/iso27001-assessment',
        name: 'iso27001-landing',
        builder: (context, state) {
          return _buildMarketingLanding('iso27001', state);
        },
      ),

      // Quick Start Flow (for new users)
      GoRoute(
        path: '/quick-start',
        name: 'quick-start',
        builder: (context, state) {
          return const AvatarHomeScreen(showOnboarding: true);
        },
      ),

      // Error/404 Route
      GoRoute(
        path: '/404',
        name: 'not-found',
        builder: (context, state) {
          return const NotFoundScreen();
        },
      ),
    ],

    // Global error handling
    errorBuilder: (context, state) {
      return ErrorScreen(error: state.error);
    },

    // Redirect logic for embedding and deep links
    redirect: (context, state) {
      return _handleRedirects(context, state);
    },
  );

  /// Handle embedding parameters from URL
  static void _handleEmbeddingParams(GoRouterState state) {
    final isEmbedded = state.uri.queryParameters['embed'] == 'true' ||
                       state.uri.queryParameters['embedded'] == 'true';
    final source = state.uri.queryParameters['source'];
    
    if (isEmbedded || source != null) {
      AppConfig.instance.initialize(
        embedded: isEmbedded,
        source: source,
      );
      
      if (kDebugMode) {
        print('🔗 Embedding detected: $isEmbedded, source: $source');
      }
    }
  }

  /// Build marketing landing page with avatar interface
  static Widget _buildMarketingLanding(String framework, GoRouterState state) {
    final source = state.uri.queryParameters['source'] ?? 'direct';
    
    // Track marketing attribution
    _trackMarketingVisit(framework, source);
    
    return FrameworkSelectionScreen(
      selectedFramework: framework,
      marketingSource: source,
      autoStart: true, // Automatically start assessment
    );
  }

  /// Handle redirects based on app state and parameters
  static String? _handleRedirects(BuildContext context, GoRouterState state) {
    // Redirect old paths to new avatar-first interface
    if (state.matchedLocation == '/wizard' || 
        state.matchedLocation == '/wizzard') {
      return '/';
    }

    // Redirect traditional assessment URLs to new flow
    if (state.matchedLocation.startsWith('/assessment/') && 
        !state.uri.queryParameters.containsKey('framework')) {
      final parts = state.matchedLocation.split('/');
      if (parts.length >= 3) {
        return '/framework/${parts[2]}';
      }
    }

    // Handle framework shortcuts
    final frameworkShortcuts = {
      '/soc2': '/framework/soc2',
      '/gdpr': '/framework/gdpr',
      '/iso27001': '/framework/iso27001',
      '/hipaa': '/framework/hipaa',
    };

    if (frameworkShortcuts.containsKey(state.matchedLocation)) {
      return frameworkShortcuts[state.matchedLocation];
    }

    return null; // No redirect needed
  }

  /// Track marketing visit for analytics
  static void _trackMarketingVisit(String framework, String source) {
    if (kDebugMode) {
      print('📊 Marketing Visit: $framework from $source');
    }
    // In production: send to analytics service
  }

  // Navigation helper methods

  /// Navigate to framework selection with conversation context
  static void goToFrameworks(BuildContext context, {String? preselected}) {
    if (preselected != null) {
      context.goNamed('framework-detail', pathParameters: {'id': preselected});
    } else {
      context.goNamed('frameworks');
    }
  }

  /// Navigate to assessment with framework context
  static void goToAssessment(BuildContext context, String framework, {int? step}) {
    final uri = Uri(
      path: '/assessment/$framework',
      queryParameters: step != null ? {'step': step.toString()} : null,
    );
    context.go(uri.toString());
  }

  /// Navigate to chat with context
  static void goToChat(BuildContext context, {String? chatContext}) {
    final uri = Uri(
      path: '/chat',
      queryParameters: chatContext != null ? {'context': chatContext} : null,
    );
    context.go(uri.toString());
  }

  /// Generate marketing URLs for embedding
  static String generateMarketingUrl({
    required String framework,
    String? source,
    bool embedded = false,
    bool minimal = false,
  }) {
    final queryParams = <String, String>{};
    
    if (source != null) queryParams['source'] = source;
    if (embedded) queryParams['embed'] = 'true';
    if (minimal) queryParams['minimal'] = 'true';
    
    final uri = Uri(
      path: '/framework/$framework',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    
    return uri.toString();
  }

  /// Generate embed widget URL
  static String generateEmbedUrl({
    String? framework,
    String? source,
    bool minimal = false,
  }) {
    final queryParams = <String, String>{};
    
    if (framework != null) queryParams['framework'] = framework;
    if (source != null) queryParams['source'] = source;
    if (minimal) queryParams['minimal'] = 'true';
    
    final uri = Uri(
      path: '/embed',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    
    return uri.toString();
  }
}

// lib/core/routing/route_observer.dart
// Route observer for analytics and state management



class AppRouteObserver extends RouteObserver<ModalRoute<dynamic>> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logRouteChange('PUSH', route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _logRouteChange('POP', route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _logRouteChange('REPLACE', newRoute, oldRoute);
  }

  void _logRouteChange(String action, Route<dynamic>? route, Route<dynamic>? previousRoute) {
    if (kDebugMode && route != null) {
      print('🧭 Route $action: ${route.settings.name ?? 'unnamed'}');
      if (route.settings.arguments != null) {
        print('   Args: ${route.settings.arguments}');
      }
    }
  }
}

// lib/features/avatar/screens/avatar_home_screen.dart (updated)
// Avatar Home Screen with onboarding support



class AvatarHomeScreen extends ConsumerStatefulWidget {
  final bool showOnboarding;
  
  const AvatarHomeScreen({
    super.key,
    this.showOnboarding = false,
  });

  @override
  ConsumerState<AvatarHomeScreen> createState() => _AvatarHomeScreenState();
}

class _AvatarHomeScreenState extends ConsumerState<AvatarHomeScreen> {
  // Implementation from previous artifact with onboarding support
  
  @override
  void initState() {
    super.initState();
    
    if (widget.showOnboarding) {
      _initializeWithOnboarding();
    } else {
      _initializeNormal();
    }
  }
  
  void _initializeWithOnboarding() {
    // Show extended onboarding flow
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(avatarStateProvider.notifier).initializeWithOnboarding();
    });
  }
  
  void _initializeNormal() {
    // Standard initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(avatarStateProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Same implementation as previous artifact
    return const Placeholder(); // Will be filled with previous implementation
  }
}

// lib/features/common/screens/error_screen.dart
// Error handling screens


class ErrorScreen extends StatelessWidget {
  final Object? error;
  
  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'We encountered an unexpected error. Please try again.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Return to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 24),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'The page you\'re looking for doesn\'t exist.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Talk to Your Expert'),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/core/routing/app_routes.dart
// Route constants and utilities

class AppRoutes {
  // Route names
  static const String home = '/';
  static const String frameworks = '/frameworks';
  static const String assessment = '/assessment';
  static const String chat = '/chat';
  static const String demo = '/demo';
  static const String embed = '/embed';
  
  // Marketing landing pages
  static const String soc2Landing = '/soc2-assessment';
  static const String gdprLanding = '/gdpr-assessment';
  static const String iso27001Landing = '/iso27001-assessment';
  
  // Utility methods
  static String frameworkDetail(String id) => '/framework/$id';
  static String assessmentWithFramework(String framework) => '/assessment/$framework';
  
  // Marketing URL generators
  static String marketingUrl(String framework, {String? source}) {
    final uri = Uri(
      path: '/framework/$framework',
      queryParameters: source != null ? {'source': source} : null,
    );
    return uri.toString();
  }
  
  static String embedUrl({String? framework, String? source, bool minimal = false}) {
    final queryParams = <String, String>{};
    if (framework != null) queryParams['framework'] = framework;
    if (source != null) queryParams['source'] = source;
    if (minimal) queryParams['minimal'] = 'true';
    
    final uri = Uri(
      path: '/embed',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return uri.toString();
  }
}