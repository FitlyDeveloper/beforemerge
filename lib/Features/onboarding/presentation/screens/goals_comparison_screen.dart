import 'package:flutter/material.dart';

class GoalsComparisonScreen extends StatelessWidget {
  const GoalsComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Back button and progress bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                Padding(
                  padding: const EdgeInsets.only(top: 14, left: 16, right: 24),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.black, size: 24),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 40),
                          child: const LinearProgressIndicator(
                            value: 6 / 7,
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
              ],
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                const Text(
                  'Achieve your goals\n2X as fast with Fitly',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    height: 1.21,
                    fontFamily: '.SF Pro Display',
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                // Hourglass comparison container
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Without Fitly
                      Column(
                        children: [
                          const Text(
                            'Without Fitly',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              fontFamily: '.SF Pro Display',
                            ),
                          ),
                          const SizedBox(height: 16),
                          ClipRect(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              widthFactor: 0.5,
                              child: Image.asset(
                                'assets/images/hourglass.png',
                                height: 120,
                                width: 240,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '15%',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              fontFamily: '.SF Pro Display',
                            ),
                          ),
                        ],
                      ),
                      // With Fitly
                      Column(
                        children: [
                          const Text(
                            'With Fitly',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              fontFamily: '.SF Pro Display',
                            ),
                          ),
                          const SizedBox(height: 16),
                          ClipRect(
                            child: Align(
                              alignment: Alignment.centerRight,
                              widthFactor: 0.5,
                              child: Image.asset(
                                'assets/images/hourglass.png',
                                height: 120,
                                width: 240,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '2X',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              fontFamily: '.SF Pro Display',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Fitly makes progress effortless.',
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.grey[600],
                    fontFamily: '.SF Pro Display',
                  ),
                ),
              ],
            ),
          ),

          // Next button
          Positioned(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).size.height * 0.06,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.05512,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(28),
              ),
              child: TextButton(
                onPressed: () {
                  // Navigate to next screen
                },
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    fontFamily: '.SF Pro Display',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
