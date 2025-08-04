import 'package:flutter/material.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/next_intro_screen_4.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/weight_height_copy_screen.dart';

class NextIntroScreen3 extends StatefulWidget {
  final bool isMetric;
  final int initialWeight;

  const NextIntroScreen3({
    super.key,
    required this.isMetric,
    required this.initialWeight,
  });

  @override
  State<NextIntroScreen3> createState() => _NextIntroScreen3State();
}

class _NextIntroScreen3State extends State<NextIntroScreen3> {
  int? selectedIndex; // Track by index instead of title
  String? selectedGoal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Box 4 (background with gradient)
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
                            value: 5 / 13,
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
                        'What\'s your gym goal?',
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
                        'This helps us create your personalized plan.',
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

          // Main content with options
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.40),
                  _buildOption(
                    'Build Muscle',
                    'Focus on gaining size and definition',
                    null,
                    index: 0,
                    customIcon: Image.asset(
                      'assets/fonts/dumbbell.png',
                      width: 32,
                      height: 32,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildOption(
                    'Gain Strength',
                    'Build strength and break your limits',
                    null,
                    index: 1,
                    customIcon: Image.asset(
                      'assets/fonts/bicep.png',
                      width: 32,
                      height: 32,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildOption(
                    'Boost Endurance',
                    'Improve stamina and endure for longer',
                    null,
                    index: 2,
                    customIcon: Image.asset(
                      'assets/fonts/rabbit.png',
                      width: 32,
                      height: 32,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),

          // Box 5 (white box at bottom)
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

          // Box 6 (black button)
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
                onPressed: _handleNavigation,
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

  void _handleNavigation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NextIntroScreen4(
          isMetric: widget.isMetric,
          initialWeight: widget.initialWeight,
          gymGoal: selectedGoal, // Pass the selected gym goal
        ),
      ),
    );
  }

  Widget _buildOption(String title, String subtitle, IconData? icon,
      {Widget? customIcon, required int index}) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
          selectedGoal = title;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        height: 72,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            if (customIcon != null)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8FA),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: customIcon,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black,
                      fontFamily: '.SF Pro Display',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : Colors.grey[600],
                      fontFamily: '.SF Pro Display',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomIcons {
  static const IconData bicep = IconData(
    0xE900, // placeholder codepoint
    fontFamily: 'CustomIcons',
    fontPackage: null,
  );
}
