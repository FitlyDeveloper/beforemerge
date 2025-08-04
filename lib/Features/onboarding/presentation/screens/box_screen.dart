import 'package:flutter/material.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/next_intro_screen.dart';
import 'package:fitness_app/core/widgets/responsive_scaffold.dart';

class BoxScreen extends StatefulWidget {
  const BoxScreen({super.key});

  @override
  State<BoxScreen> createState() => _BoxScreenState();
}

class _BoxScreenState extends State<BoxScreen> {
  String? selectedGender;

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Box 1 (background with gradient)
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

          // Box 1 (main content)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.07), // Adjust for safe area
                  // Back arrow and progress bar row
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.black, size: 24),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              right: 40), // Match left padding (24 + 16)
                          child: const LinearProgressIndicator(
                            value: 2 / 13,
                            minHeight: 2,
                            backgroundColor: Color(0xFFE5E5EA),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Title
                  const Text(
                    'How do you identify?',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      height: 1.21,
                      fontFamily: '.SF Pro Display',
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  Text(
                    'This helps us personalize your plan.',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                      fontFamily: '.SF Pro Display',
                      color: Colors.grey[600],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Spacer(flex: 35), // 35% of space
                        _buildGenderOption('Male'),
                        const SizedBox(height: 12),
                        _buildGenderOption('Female'),
                        const SizedBox(height: 12),
                        _buildGenderOption('Other'),
                        Spacer(flex: 65), // 65% of space (30% difference)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Box 2 (white box at bottom)
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

          // Box 3 (black button)
          Positioned(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).size.height * 0.06,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.0689,
              decoration: BoxDecoration(
                color: selectedGender != null
                    ? Colors.black
                    : const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(28),
              ),
              child: TextButton(
                onPressed: selectedGender != null
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NextIntroScreen(),
                          ),
                        );
                      }
                    : null,
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    fontFamily: '.SF Pro Display',
                    color: selectedGender != null ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String gender) {
    final isSelected = selectedGender == gender;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = gender;
        });
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Center(
          child: Text(
            gender,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black,
              fontFamily: '.SF Pro Display',
            ),
          ),
        ),
      ),
    );
  }
}
