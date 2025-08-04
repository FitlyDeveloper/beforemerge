import 'package:flutter/material.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/weight_goal_copy_screen.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/speed_screen.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/comfort_screen.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/calculation_screen.dart';
import 'package:fitness_app/core/widgets/responsive_scaffold.dart';

class GenderSelectionScreen extends StatefulWidget {
  final bool isMetric;
  final int initialWeight;
  final String? selectedGender;
  final int heightInCm;
  final DateTime birthDate;
  final String? gymGoal;

  const GenderSelectionScreen({
    super.key,
    required this.isMetric,
    required this.initialWeight,
    required this.selectedGender,
    required this.heightInCm,
    required this.birthDate,
    this.gymGoal,
  });

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  int? selectedIndex; // Track selected option
  String? selectedGoal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

          // Header content
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
                            value: 9 / 13,
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
                        'What\'s your weight goal?',
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
                        'This helps us plan your calorie intake.',
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

          // White box at bottom
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

          // Update the gender options position
          Positioned(
            top: MediaQuery.of(context).size.height * 0.42,
            left: 24,
            right: 24,
            child: Column(
              children: [
                _buildOption('Lose weight', index: 0),
                const SizedBox(height: 12),
                _buildOption('Maintain weight', index: 1),
                const SizedBox(height: 12),
                _buildOption('Gain weight', index: 2),
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

  Widget _buildOption(String text, {required int index}) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
          selectedGoal = text;
        });
      },
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : const Color(0xFFF0F1F3),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black,
              fontFamily: '.SF Pro Display',
            ),
          ),
        ),
      ),
    );
  }

  void _handleNavigation() {
    if (selectedGoal == "Maintain weight") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CalculationScreen(
            isMetric: widget.isMetric,
            initialWeight: widget.initialWeight,
            dreamWeight: widget.initialWeight,
            isGaining: false,
            speedValue: 0,
            gender: selectedIndex == 0
                ? 'Male'
                : selectedIndex == 1
                    ? 'Female'
                    : 'Other',
            heightInCm: widget.heightInCm,
            birthDate: widget.birthDate,
            gymGoal: widget.gymGoal ?? 'Maintain',
          ),
        ),
      );
    } else {
      // Normal flow - go to weight goal screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WeightGoalCopyScreen(
            isMetric: widget.isMetric,
            initialWeight: widget.initialWeight,
            selectedGoal: selectedGoal,
            gender: selectedIndex == 0
                ? 'Male'
                : selectedIndex == 1
                    ? 'Female'
                    : 'Other',
            heightInCm: widget.heightInCm,
            birthDate: widget.birthDate,
            gymGoal: widget.gymGoal,
          ),
        ),
      );
    }
  }
}
