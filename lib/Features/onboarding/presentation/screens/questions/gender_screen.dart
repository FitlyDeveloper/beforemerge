import 'package:flutter/material.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/next_intro_screen.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/signin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  static const int totalSteps = 7;
  static const int currentStep = 1;
  String? selectedGender;

  double get progress => currentStep / totalSteps;

  // Save selected gender to SharedPreferences
  Future<void> _saveGender() async {
    if (selectedGender != null) {
      try {
        final prefs = await SharedPreferences.getInstance();

        // Save data to both keys for consistency across the app
        await prefs.setString('user_gender', selectedGender!);
        await prefs.setString('gender', selectedGender!);

        // Verify it was saved correctly
        final savedGender = prefs.getString('user_gender');
        final savedGender2 = prefs.getString('gender');
        print('Gender saved to SharedPreferences:');
        print('Key: user_gender, Value: $savedGender');
        print('Key: gender, Value: $savedGender2');

        // Print all keys for debugging
        print('All SharedPreferences keys after saving:');
        print(prefs.getKeys());
      } catch (e) {
        print('Error saving gender: $e');
      }
    }
  }

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
                            value: 1 / 7,
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
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Gender options
          Positioned(
            top: MediaQuery.of(context).size.height * 0.42,
            left: 24,
            right: 24,
            child: Column(
              children: [
                _buildGenderOption('Male'),
                const SizedBox(height: 12),
                _buildGenderOption('Female'),
                const SizedBox(height: 12),
                _buildGenderOption('Other'),
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

          // Continue button
          Positioned(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).size.height * 0.06,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.0689,
              decoration: BoxDecoration(
                color: selectedGender != null ? Colors.black : Colors.grey[300],
                borderRadius: BorderRadius.circular(28),
              ),
              child: TextButton(
                onPressed: selectedGender != null
                    ? () async {
                        // Save gender before navigation
                        await _saveGender();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const NextIntroScreen(),
                          ),
                        );
                      }
                    : null,
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

  Widget _buildGenderOption(String gender) {
    final isSelected = selectedGender == gender;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = gender;
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
            gender,
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
