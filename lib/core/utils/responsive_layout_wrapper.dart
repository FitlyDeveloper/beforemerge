import 'package:flutter/material.dart';

/// A wrapper widget that maintains a consistent layout based on a reference device size (iPhone 13)
/// while adapting to different screen sizes.
class ResponsiveLayoutWrapper extends StatelessWidget {
  final Widget child;

  // iPhone 13 dimensions (reference device)
  static const double referenceWidth = 390.0;
  static const double referenceHeight = 844.0;

  const ResponsiveLayoutWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Calculate the scale factor to maintain aspect ratio
    final widthScale = screenWidth / referenceWidth;
    final heightScale = screenHeight / referenceHeight;

    // Use FittedBox to scale the content while maintaining aspect ratio
    return FittedBox(
      fit: BoxFit.contain,
      alignment: Alignment.center,
      child: SizedBox(
        width: referenceWidth,
        height: referenceHeight,
        child: MediaQuery(
          // Override the MediaQuery to use the reference device size
          data: MediaQuery.of(context).copyWith(
            size: const Size(referenceWidth, referenceHeight),
            devicePixelRatio: 1.0,
          ),
          child: child,
        ),
      ),
    );
  }
}
