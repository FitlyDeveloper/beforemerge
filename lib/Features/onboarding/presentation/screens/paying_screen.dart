import 'package:flutter/material.dart';
import 'package:fitness_app/core/widgets/responsive_scaffold.dart';
import 'package:fitness_app/Features/codia/codia_page.dart';

class PayingScreen extends StatelessWidget {
  const PayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.grey[100]!.withOpacity(0.9),
                ],
              ),
            ),
          ),

          // Header content (back arrow and progress bar)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.07),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.black, size: 24),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 40),
                          child: const LinearProgressIndicator(
                            value: 7 / 7,
                            minHeight: 2,
                            backgroundColor: Color(0xFFE5E5EA),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 21.2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hard pay wall',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          height: 1.21,
                          fontFamily: '.SF Pro Display',
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your personalized plan is ready.',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                          fontFamily: '.SF Pro Display',
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Add this after the header content and before the bottom white box
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    const Color(0xFFF0F1F3)
                        .withRed(250), // Increased red tint from 245 to 250
                    const Color(0xFFF0F1F3), // Original color in middle
                    const Color(0xFFF0F1F3)
                        .withGreen(250), // Increased green tint from 245 to 250
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              height: MediaQuery.of(context).size.height * 0.33,
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.28,
                  child: Image.asset(
                    'assets/images/hourglass.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // Bottom white box and button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.of(context).size.height * 0.148887,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),

          // Add "Start Now, Pay Later" as a separate Positioned widget
          Positioned(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).size.height * 0.15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 19,
                  height: 19,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 13,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Start Now, Pay Later',
                  style: TextStyle(
                    fontSize: 14.25,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontFamily: '.SF Pro Display',
                  ),
                ),
              ],
            ),
          ),

          // Add this before the closing of Stack
          Positioned(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).size.height * 0.06,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.0689,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(28),
              ),
              child: TextButton(
                onPressed: () {
                  // Navigate to CodiaPage
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CodiaPage(),
                    ),
                  );
                },
                child: const Text(
                  'Try for \$0.00',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    fontFamily: '.SF Pro Display',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // Add pricing text below black button
          Positioned(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).size.height * 0.028,
            child: const Center(
              child: Text(
                'Only \$39.99 per year (\$3.33/mo)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                  fontFamily: '.SF Pro Display',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
