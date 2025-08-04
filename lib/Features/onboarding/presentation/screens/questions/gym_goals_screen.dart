import 'package:flutter/material.dart';
import 'package:fitness_app/Features/onboarding/presentation/widgets/onboarding_header.dart';
import 'package:fitness_app/core/widgets/responsive_scaffold.dart';

class GymGoalsScreen extends StatefulWidget {
  const GymGoalsScreen({super.key});

  @override
  State<GymGoalsScreen> createState() => _GymGoalsScreenState();
}

class _GymGoalsScreenState extends State<GymGoalsScreen> {
  String? selectedGoal;

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60), // Safe area top padding
            OnboardingHeader(
              progress: 2 / 7, // Adjust based on actual progress
              onBack: () => Navigator.pop(context),
            ),
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
            const SizedBox(height: 8),
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
            const SizedBox(height: 40),
            _buildGoalOption(
              'Build Muscle',
              'Focus on gaining size and definition',
              Icons.fitness_center,
            ),
            const SizedBox(height: 12),
            _buildGoalOption(
              'Gain Strength',
              'Build strength and break your limits',
              Icons.sports_gymnastics,
            ),
            const SizedBox(height: 12),
            _buildGoalOption(
              'Boost Endurance',
              'Improve stamina and endure for longer',
              Icons.directions_run,
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.0689,
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.0374),
              child: TextButton(
                onPressed: selectedGoal != null
                    ? () {
                        // Navigate to next screen
                      }
                    : null,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildGoalOption(String title, String subtitle, IconData icon) {
    final isSelected = selectedGoal == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGoal = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : const Color(0xFFF0F1F3),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.black,
                      fontFamily: '.SF Pro Display',
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: isSelected
                          ? Colors.white.withOpacity(0.7)
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
