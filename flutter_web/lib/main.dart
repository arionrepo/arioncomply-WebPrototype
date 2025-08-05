// FILE PATH: lib/main.dart
// Main entry point - Fixed version with proper imports

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Core imports
import 'core/utils/import_fixes.dart'; // Consolidated imports
import 'core/theme/app_colors.dart';

// Features - Only import what exists
import 'features/avatar/screens/avatar_home_screen.dart';

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
        // Other routes will be added as screens are implemented
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
        // Additional nav items will be added as features are implemented
        const Divider(),
        ListTile(
          leading: const Icon(Icons.info, color: AppColors.textSecondary),
          title: const Text('Demo Version', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          subtitle: const Text('Basic features available', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
        ),
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