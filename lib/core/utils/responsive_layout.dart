import 'package:flutter/cupertino.dart';
import 'device_type.dart';

class ResponsiveLayout {
  static const double maxContentWidth = 800.0;
  static const double maxContentWidthTablet = 700.0;
  static const double maxContentWidthDesktop = 1200.0;

  static EdgeInsets getPadding(BuildContext context) {
    final deviceType = DeviceTypeHelper.getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.phone:
        return const EdgeInsets.all(16.0);
      case DeviceType.tablet:
        return const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0);
      case DeviceType.desktop:
        return const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0);
    }
  }

  static EdgeInsets getHorizontalPadding(BuildContext context) {
    final deviceType = DeviceTypeHelper.getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.phone:
        return const EdgeInsets.symmetric(horizontal: 16.0);
      case DeviceType.tablet:
        return const EdgeInsets.symmetric(horizontal: 32.0);
      case DeviceType.desktop:
        return const EdgeInsets.symmetric(horizontal: 48.0);
    }
  }

  static EdgeInsets getVerticalPadding(BuildContext context) {
    final deviceType = DeviceTypeHelper.getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.phone:
        return const EdgeInsets.symmetric(vertical: 16.0);
      case DeviceType.tablet:
        return const EdgeInsets.symmetric(vertical: 24.0);
      case DeviceType.desktop:
        return const EdgeInsets.symmetric(vertical: 32.0);
    }
  }

  static double getSpacing(BuildContext context) {
    final deviceType = DeviceTypeHelper.getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.phone:
        return 16.0;
      case DeviceType.tablet:
        return 24.0;
      case DeviceType.desktop:
        return 32.0;
    }
  }

  static double getLargeSpacing(BuildContext context) {
    final deviceType = DeviceTypeHelper.getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.phone:
        return 32.0;
      case DeviceType.tablet:
        return 48.0;
      case DeviceType.desktop:
        return 64.0;
    }
  }

  static double getMaxContentWidth(BuildContext context) {
    final deviceType = DeviceTypeHelper.getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.phone:
        return double.infinity;
      case DeviceType.tablet:
        return maxContentWidthTablet;
      case DeviceType.desktop:
        return maxContentWidthDesktop;
    }
  }

  static Widget constrainWidth(BuildContext context, Widget child) {
    final maxWidth = getMaxContentWidth(context);
    
    if (maxWidth == double.infinity) {
      return child;
    }
    
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }

  static int getGridCrossAxisCount(BuildContext context, {int phoneCount = 1, int tabletCount = 2, int desktopCount = 3}) {
    final deviceType = DeviceTypeHelper.getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.phone:
        return phoneCount;
      case DeviceType.tablet:
        return tabletCount;
      case DeviceType.desktop:
        return desktopCount;
    }
  }

  static double getIconSize(BuildContext context, {double phoneSize = 24.0, double tabletSize = 28.0, double desktopSize = 32.0}) {
    final deviceType = DeviceTypeHelper.getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.phone:
        return phoneSize;
      case DeviceType.tablet:
        return tabletSize;
      case DeviceType.desktop:
        return desktopSize;
    }
  }
}

