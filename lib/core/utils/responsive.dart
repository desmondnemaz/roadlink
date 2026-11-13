import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Enum representing the screen device category based on width breakpoints.
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Breakpoints for responsive layouts across Mobile, Tablet, and Web/Desktop.
class Breakpoints {
  Breakpoints._();

  /// Max width for mobile devices (phones).
  static const double mobile = 600;

  /// Max width for tablets / small laptops.
  static const double tablet = 1024;

  /// Default maximum content width for centered web layouts.
  static const double maxContentWidth = 1280;
}

/// A responsive utility widget and helper class for building adaptive
/// Mobile, Tablet, and Web/Desktop interfaces.
class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  /// Returns true if running on the Web platform.
  static bool get isWeb => kIsWeb;

  /// Returns true if running on a native mobile platform (Android or iOS).
  static bool get isMobilePlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Returns true if the screen width is within the mobile breakpoint (< 600px).
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < Breakpoints.mobile;

  /// Returns true if the screen width is within the tablet breakpoint (>= 600px and < 1024px).
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= Breakpoints.mobile && width < Breakpoints.tablet;
  }

  /// Returns true if the screen width is desktop/web size (>= 1024px).
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= Breakpoints.tablet;

  /// Determines the [DeviceType] based on the given width or current [BuildContext].
  static DeviceType deviceTypeOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return deviceTypeFromWidth(width);
  }

  /// Determines the [DeviceType] from a raw width value.
  static DeviceType deviceTypeFromWidth(double width) {
    if (width >= Breakpoints.tablet) {
      return DeviceType.desktop;
    } else if (width >= Breakpoints.mobile) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }

  /// Returns a value based on the active screen breakpoint.
  /// If [tablet] is omitted, it falls back to [mobile].
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    final type = deviceTypeOf(context);
    switch (type) {
      case DeviceType.desktop:
        return desktop;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }

  /// Returns responsive horizontal padding suitable for the current screen size.
  ///
  /// Follows the Figma layout defaults: mobile page inset 24 px and desktop
  /// workspace inset 36 px. Tablet is not specified in Figma and uses the
  /// mobile value.
  static EdgeInsets horizontalPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: value<double>(
        context,
        mobile: 24.0,
        tablet: 24.0,
        desktop: 36.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = deviceTypeFromWidth(constraints.maxWidth);
        switch (deviceType) {
          case DeviceType.desktop:
            return desktop;
          case DeviceType.tablet:
            return tablet ?? mobile;
          case DeviceType.mobile:
            return mobile;
        }
      },
    );
  }
}

/// A builder widget that exposes the [DeviceType] and [BoxConstraints]
/// for custom responsive widget trees.
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    BoxConstraints constraints,
    DeviceType deviceType,
  ) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = Responsive.deviceTypeFromWidth(constraints.maxWidth);
        return builder(context, constraints, deviceType);
      },
    );
  }
}

/// Constrains the maximum width of content on large web/desktop screens
/// while keeping full width on mobile devices.
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxContentWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxContentWidth = Breakpoints.maxContentWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );
  }
}

/// Custom scroll behavior enabling smooth touch, mouse drag, and trackpad
/// scrolling across both Mobile and Web platforms.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

/// Convenient [BuildContext] extensions for responsive design.
extension ResponsiveContext on BuildContext {
  /// Full size of the current media (screen/window).
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Width of the current screen/window.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Height of the current screen/window.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Current [DeviceType] (`mobile`, `tablet`, or `desktop`).
  DeviceType get deviceType => Responsive.deviceTypeOf(this);

  /// True if screen width is < 600px.
  bool get isMobile => Responsive.isMobile(this);

  /// True if screen width is >= 600px and < 1024px.
  bool get isTablet => Responsive.isTablet(this);

  /// True if screen width is >= 1024px.
  bool get isDesktop => Responsive.isDesktop(this);

  /// True if the device is in portrait orientation.
  bool get isPortrait =>
      MediaQuery.orientationOf(this) == Orientation.portrait;

  /// True if the device is in landscape orientation.
  bool get isLandscape =>
      MediaQuery.orientationOf(this) == Orientation.landscape;

  /// Helper to pick a responsive value directly from [BuildContext].
  T responsiveValue<T>({
    required T mobile,
    T? tablet,
    required T desktop,
  }) =>
      Responsive.value<T>(
        this,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      );
}

