// lib/core/app/app.dart
// Main App Widget - Avatar-Centric Design
// Contains the MaterialApp.router setup and global configuration

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../routing/app_router.dart';
import 'app_config.dart';

/// Main ArionComply Demo App Widget
/// This is the root widget that sets up the entire app
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
      
      // Support for web embedding
      routeInformationProvider: AppConfig.instance.isEmbedded 
          ? null 
          : PlatformRouteInformationProvider(
              initialRouteInformation: const RouteInformation(
                location: '/',
              ),
            ),
    );
  }
}