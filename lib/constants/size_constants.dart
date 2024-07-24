import 'package:flutter/widgets.dart';

class SizeConstants {
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;
  static bool isSmallScreen(BuildContext context) => width(context) < 600;
  static bool isMediumScreen(BuildContext context) =>
      width(context) < 900 && width(context) > 600;
  static bool isLargeScreen(BuildContext context) =>
      width(context) <= 1200 && width(context) > 900;

// Padding
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;


  // Radius
  static const double smallRadius = 8.0;
  static const double mediumRadius = 16.0;
  static const double largeRadius = 24.0;
}

