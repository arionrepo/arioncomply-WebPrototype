// lib/shared/widgets/responsive_layout.dart
// ArionComply Responsive Layout System
// Adaptive layout for mobile, tablet, and desktop with breakpoint management

import 'package:flutter/material.dart';

/// Responsive layout widget that adapts to different screen sizes
/// Provides mobile, tablet, and desktop breakpoints with optional scaling
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final double mobileBreakpoint;
  final double tabletBreakpoint;
  final bool enableScaling;
  final EdgeInsets? padding;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.mobileBreakpoint = 600,
    this.tabletBreakpoint = 1024,
    this.enableScaling = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = _getDeviceType(screenWidth);
    
    Widget child = _getChildForDevice(deviceType);
    
    if (enableScaling) {
      child = _applyScaling(child, screenWidth, deviceType);
    }
    
    if (padding != null) {
      child = Padding(padding: padding!, child: child);
    }
    
    return child;
  }

  DeviceType _getDeviceType(double width) {
    if (width >= tabletBreakpoint) {
      return DeviceType.desktop;
    } else if (width >= mobileBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }

  Widget _getChildForDevice(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }

  Widget _applyScaling(Widget child, double screenWidth, DeviceType deviceType) {
    double scaleFactor = 1.0;
    
    switch (deviceType) {
      case DeviceType.mobile:
        // Scale down slightly on very small screens
        if (screenWidth < 360) {
          scaleFactor = 0.9;
        }
        break;
      case DeviceType.tablet:
        // No scaling for tablet
        scaleFactor = 1.0;
        break;
      case DeviceType.desktop:
        // Scale up slightly on very large screens
        if (screenWidth > 1600) {
          scaleFactor = 1.1;
        }
        break;
    }
    
    return Transform.scale(
      scale: scaleFactor,
      child: child,
    );
  }

  /// Static method to get current device type
  static DeviceType getDeviceType(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1024) {
      return DeviceType.desktop;
    } else if (screenWidth >= 600) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }

  /// Static method to check if device is mobile
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// Static method to check if device is tablet
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// Static method to check if device is desktop
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  /// Static method to get appropriate padding for device type
  static EdgeInsets getPaddingForDevice(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return const EdgeInsets.all(16);
      case DeviceType.tablet:
        return const EdgeInsets.all(24);
      case DeviceType.desktop:
        return const EdgeInsets.all(32);
    }
  }

  /// Static method to get appropriate margin for device type
  static EdgeInsets getMarginForDevice(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return const EdgeInsets.all(8);
      case DeviceType.tablet:
        return const EdgeInsets.all(12);
      case DeviceType.desktop:
        return const EdgeInsets.all(16);
    }
  }

  /// Static method to get maximum width for content
  static double getMaxContentWidth(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return double.infinity;
      case DeviceType.tablet:
        return 800;
      case DeviceType.desktop:
        return 1200;
    }
  }
}

/// Device type enumeration
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Responsive builder widget for more granular control
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;
  final double mobileBreakpoint;
  final double tabletBreakpoint;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
    this.mobileBreakpoint = 600,
    this.tabletBreakpoint = 1024,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = _getDeviceType(screenWidth);
    
    return builder(context, deviceType);
  }

  DeviceType _getDeviceType(double width) {
    if (width >= tabletBreakpoint) {
      return DeviceType.desktop;
    } else if (width >= mobileBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }
}

/// Responsive value class for different screen sizes
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
    switch (ResponsiveLayout.getDeviceType(context)) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }
}

/// Responsive spacing utilities
class ResponsiveSpacing {
  static const ResponsiveValue<double> small = ResponsiveValue(
    mobile: 8,
    tablet: 12,
    desktop: 16,
  );

  static const ResponsiveValue<double> medium = ResponsiveValue(
    mobile: 16,
    tablet: 24,
    desktop: 32,
  );

  static const ResponsiveValue<double> large = ResponsiveValue(
    mobile: 24,
    tablet: 32,
    desktop: 48,
  );

  static const ResponsiveValue<double> extraLarge = ResponsiveValue(
    mobile: 32,
    tablet: 48,
    desktop: 64,
  );

  static double getSmall(BuildContext context) => small.getValue(context);
  static double getMedium(BuildContext context) => medium.getValue(context);
  static double getLarge(BuildContext context) => large.getValue(context);
  static double getExtraLarge(BuildContext context) => extraLarge.getValue(context);
}

/// Responsive grid helper
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final ResponsiveValue<int> columns;
  final double spacing;
  final double runSpacing;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.columns = const ResponsiveValue(mobile: 1, tablet: 2, desktop: 3),
    this.spacing = 16,
    this.runSpacing = 16,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final columnCount = columns.getValue(context);
    final rows = <Widget>[];
    
    for (int i = 0; i < children.length; i += columnCount) {
      final rowChildren = <Widget>[];
      
      for (int j = 0; j < columnCount && i + j < children.length; j++) {
        rowChildren.add(Expanded(child: children[i + j]));
        
        if (j < columnCount - 1 && i + j + 1 < children.length) {
          rowChildren.add(SizedBox(width: spacing));
        }
      }
      
      // Fill remaining columns with empty expanded widgets
      while (rowChildren.length < columnCount * 2 - 1) {
        rowChildren.add(const Expanded(child: SizedBox()));
        if (rowChildren.length < columnCount * 2 - 1) {
          rowChildren.add(SizedBox(width: spacing));
        }
      }
      
      rows.add(Row(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisAlignment: mainAxisAlignment,
        children: rowChildren,
      ));
      
      if (i + columnCount < children.length) {
        rows.add(SizedBox(height: runSpacing));
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}

/// Responsive container with max width constraints
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final ResponsiveValue<double>? maxWidth;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool center;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.margin,
    this.center = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget container = child;
    
    if (padding != null) {
      container = Padding(padding: padding!, child: container);
    }
    
    if (maxWidth != null) {
      container = ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth!.getValue(context),
        ),
        child: container,
      );
    }
    
    if (center) {
      container = Center(child: container);
    }
    
    if (margin != null) {
      container = Container(
        margin: margin,
        child: container,
      );
    }
    
    return container;
  }
}

/// Extension methods for responsive utilities
extension ResponsiveContext on BuildContext {
  DeviceType get deviceType => ResponsiveLayout.getDeviceType(this);
  bool get isMobile => ResponsiveLayout.isMobile(this);
  bool get isTablet => ResponsiveLayout.isTablet(this);
  bool get isDesktop => ResponsiveLayout.isDesktop(this);
  
  EdgeInsets get responsivePadding => ResponsiveLayout.getPaddingForDevice(this);
  EdgeInsets get responsiveMargin => ResponsiveLayout.getMarginForDevice(this);
  double get maxContentWidth => ResponsiveLayout.getMaxContentWidth(this);
  
  double get smallSpacing => ResponsiveSpacing.getSmall(this);
  double get mediumSpacing => ResponsiveSpacing.getMedium(this);
  double get largeSpacing => ResponsiveSpacing.getLarge(this);
  double get extraLargeSpacing => ResponsiveSpacing.getExtraLarge(this);
}