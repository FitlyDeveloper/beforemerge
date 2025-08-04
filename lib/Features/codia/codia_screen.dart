import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fitness_app/Features/codia/codia_page.dart';

class CodiaScreen extends StatelessWidget {
  const CodiaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Make status bar transparent
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: ClipRect(
        child: CodiaPage(),
      ),
    );
  }
}
