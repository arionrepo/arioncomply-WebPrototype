// FILE PATH: lib/shared/widgets/responsive_layout.dart
// ResponsiveLayout - Missing widget referenced throughout the project

import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final double mobileMaxWidth;
  final double tabletMaxWidth;

  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.mobileMaxWidth = 600,
    this.tabletMaxWidth = 1200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        
        if (width >= tabletMaxWidth) {
          return desktop ?? tablet ?? mobile;
        } else if (width >= mobileMaxWidth) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

// Extension method for responsive layouts
extension ResponsiveContext on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < 600;
  bool get isTablet => MediaQuery.of(this).size.width >= 600 && MediaQuery.of(this).size.width < 1200;
  bool get isDesktop => MediaQuery.of(this).size.width >= 1200;
}

// Responsive values helper
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  T getValue(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= 1200) {
      return desktop ?? tablet ?? mobile;
    } else if (width >= 600) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}