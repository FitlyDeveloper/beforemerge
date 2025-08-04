import 'package:flutter/material.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/next_intro_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeightGoalScreen extends StatefulWidget {
  const WeightGoalScreen({Key? key}) : super(key: key);

  @override
  State<WeightGoalScreen> createState() => _WeightGoalScreenState();
}

class _WeightGoalScreenState extends State<WeightGoalScreen> {
  static const int totalSteps = 7;
  static const int currentStep = 3;
  String? selectedGoal;

  // Save goal to SharedPreferences
  Future<void> _saveGoal() async {
    if (selectedGoal != null) {
      try {
        final prefs = await SharedPreferences.getInstance();

        // Convert goal to lowercase for consistency
        String goal = selectedGoal!.toLowerCase().split(' ')[0]; // 'lose', 'maintain', or 'gain'
        await prefs.setString('user_goal', goal);

        // Verify it was saved correctly
        final savedGoal = prefs.getString('user_goal');
        print('Goal saved to SharedPreferences:');
        print('Key: user_goal, Value: $savedGoal');

        // Print all keys for debugging
        print('All SharedPreferences keys after saving:');
        print(prefs.getKeys());
      } catch (e) {
        print('Error saving goal: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use a completely different approach with AppBar
    return Scaffold(
      backgroundColor: Colors.white,
      // Use AppBar with zero height
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: Container(
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
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Top spacing - MUCH SMALLER than before
            SizedBox(height: 20),

            // Back button and progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.black, size: 24),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 40),
                      child: LinearProgressIndicator(
                        value: currentStep / totalSteps,
                        minHeight: 2,
                        backgroundColor: const Color(0xFFE5E5EA),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Title and subtitle
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 20),
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
                  const SizedBox(height: 8),
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

            // Weight goal options
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildGoalOption('Lose weight'),
                  const SizedBox(height: 12),
                  _buildGoalOption('Maintain weight'),
                  const SizedBox(height: 12),
                  _buildGoalOption('Gain weight'),
                ],
              ),
            ),

            // Spacer
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),

            // Next button
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40),
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.0689,
                decoration: BoxDecoration(
                  color: selectedGoal != null ? Colors.black : Colors.grey[300],
                  borderRadius: BorderRadius.circular(28),
                ),
                child: TextButton(
                  onPressed: selectedGoal != null
                      ? () async {
                          await _saveGoal();
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
                      fontWeight: FontWeight.w500,
                      fontFamily: '.SF Pro Display',
                      color: selectedGoal != null ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalOption(String goal) {
    final isSelected = selectedGoal == goal;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGoal = goal;
        });
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : const Color(0xFFF0F1F3),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Center(
          child: Text(
            goal,
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
}
