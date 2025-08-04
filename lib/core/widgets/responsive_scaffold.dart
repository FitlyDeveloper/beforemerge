import 'package:flutter/material.dart';
import 'package:fitness_app/core/utils/device_size_adapter.dart';

/// A scaffold that maintains consistent layouts across different device sizes
/// by scaling the content based on the device size.
class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final bool extendBody;
  final bool extendBodyBehindAppBar;

  const ResponsiveScaffold({
    Key? key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final screenSize = MediaQuery.of(context).size;

    // Calculate the scale factor to maintain aspect ratio
    final widthScale = screenSize.width / DeviceSizeAdapter.referenceWidth;
    final heightScale = screenSize.height / DeviceSizeAdapter.referenceHeight;
    final scale = widthScale < heightScale ? widthScale : heightScale;

    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: Center(
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.center,
          child: SizedBox(
            width: DeviceSizeAdapter.referenceWidth,
            height: DeviceSizeAdapter.referenceHeight,
            child: MediaQuery(
              // Override the MediaQuery to use the reference device size
              data: DeviceSizeAdapter.getFixedMediaQuery(context),
              child: body,
            ),
          ),
        ),
      ),
    );
  }
}
