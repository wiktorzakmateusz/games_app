import 'package:flutter/cupertino.dart';

enum DeviceType {
  phone,
  tablet,
  desktop,
}

class DeviceTypeHelper {
  static const double tabletBreakpoint = 600.0;
  static const double desktopBreakpoint = 1200.0;

  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= desktopBreakpoint) {
      return DeviceType.desktop;
    } else if (width >= tabletBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.phone;
    }
  }

  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  static bool isPhone(BuildContext context) {
    return getDeviceType(context) == DeviceType.phone;
  }

  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}

