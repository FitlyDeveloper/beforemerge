import 'package:flutter/material.dart';

/// A utility class that provides methods to adapt UI elements to maintain
/// consistent layouts across different device sizes.
class DeviceSizeAdapter {
  // iPhone 13 dimensions (reference device)
  static const double referenceWidth = 390.0;
  static const double referenceHeight = 844.0;

  /// Returns a fixed height that maintains the same proportions as on iPhone 13
  static double getScaledHeight(BuildContext context, double height) {
    final screenHeight = MediaQuery.of(context).size.height;
    return height * (screenHeight / referenceHeight);
  }

  /// Returns a fixed width that maintains the same proportions as on iPhone 13
  static double getScaledWidth(BuildContext context, double width) {
    final screenWidth = MediaQuery.of(context).size.width;
    return width * (screenWidth / referenceWidth);
  }

  /// Returns a fixed size that maintains the same proportions as on iPhone 13
  static double getScaledSize(BuildContext context, double size) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Use the smaller scale factor to ensure the UI fits on the screen
    final widthScale = screenWidth / referenceWidth;
    final heightScale = screenHeight / referenceHeight;
    final scale = widthScale < heightScale ? widthScale : heightScale;

    return size * scale;
  }

  /// Returns a fixed padding that maintains the same proportions as on iPhone 13
  static EdgeInsets getScaledPadding(BuildContext context, EdgeInsets padding) {
    return EdgeInsets.only(
      left: getScaledWidth(context, padding.left),
      top: getScaledHeight(context, padding.top),
      right: getScaledWidth(context, padding.right),
      bottom: getScaledHeight(context, padding.bottom),
    );
  }

  /// Returns a fixed position that maintains the same proportions as on iPhone 13
  static double getScaledPositionY(BuildContext context, double position) {
    return getScaledHeight(context, position);
  }

  /// Returns a fixed position that maintains the same proportions as on iPhone 13
  static double getScaledPositionX(BuildContext context, double position) {
    return getScaledWidth(context, position);
  }

  /// Returns a MediaQuery that uses the reference device size
  static MediaQueryData getFixedMediaQuery(BuildContext context) {
    return MediaQuery.of(context).copyWith(
      size: const Size(referenceWidth, referenceHeight),
    );
  }
}
