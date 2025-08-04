import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;
import 'package:fitness_app/Features/onboarding/presentation/screens/comfort_screen.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/calculation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpeedScreen extends StatefulWidget {
  final bool isMetric;
  final int initialWeight;
  final bool isGaining;
  final int dreamWeight;
  final String gender;
  final int heightInCm;
  final DateTime birthDate;
  final String? gymGoal;
  const SpeedScreen({
    super.key,
    required this.isMetric,
    required this.initialWeight,
    required this.isGaining,
    required this.dreamWeight,
    required this.gender,
    required this.heightInCm,
    required this.birthDate,
    this.gymGoal,
  });

  @override
  State<SpeedScreen> createState() => _SpeedScreenState();
}

class _SpeedScreenState extends State<SpeedScreen> {
  int? selectedIndex;
  late double currentWeight;
  late double initialWeight;
  late double speedValue;
  late final double minWeight;
  late final double maxWeight;
  double _dragAccumulator = 0;

  // Save goal speed to SharedPreferences
  Future<void> _saveGoalSpeed() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save speed value in kg/week
      double speedKgPerWeek =
          widget.isMetric ? speedValue : speedValue * 0.453592;
      await prefs.setDouble('goal_speed_kg_per_week', speedKgPerWeek);

      // Verify it was saved correctly
      final savedSpeed = prefs.getDouble('goal_speed_kg_per_week');
      print('Goal speed saved to SharedPreferences:');
      print('Key: goal_speed_kg_per_week, Value: $savedSpeed');

      // Print all keys for debugging
      print('All SharedPreferences keys after saving:');
      print(prefs.getKeys());
    } catch (e) {
      print('Error saving goal speed: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    initialWeight = widget.initialWeight.toDouble();
    currentWeight = initialWeight;
    speedValue = widget.isMetric ? 0.4 : 0.8;
    if (widget.isMetric) {
      minWeight = 0.1;
      maxWeight = 1.0;
    } else {
      minWeight = 0.1;
      maxWeight = 2.2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: _handleKeyPress,
      child: Scaffold(
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
                              value: 11 / 13,
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
                        Text(
                          widget.isGaining
                              ? 'How fast do you want to gain weight?'
                              : 'How fast do you want to lose weight?',
                          style: const TextStyle(
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

            // Add this section in the Stack
            Positioned(
              top: MediaQuery.of(context).size.height * 0.38,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    widget.isGaining
                        ? 'Weight gain speed per week'
                        : 'Weight loss speed per week',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: '.SF Pro Display',
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${speedValue.toStringAsFixed(1)} ${widget.isMetric ? 'kg' : 'lb'}',
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                      fontFamily: '.SF Pro Display',
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Animals row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.center,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: _getRecommendationText() ==
                                          'Slow & Sustainable'
                                      ? ColorFiltered(
                                          colorFilter: const ColorFilter.mode(
                                            Color(0xFF4D4DE2),
                                            BlendMode.srcIn,
                                          ),
                                          child: Image.asset(
                                            'assets/images/turtle.png',
                                            height: 48,
                                          ),
                                        )
                                      : Image.asset(
                                          'assets/images/turtle.png',
                                          height: 48,
                                        ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.center,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: _getRecommendationText() ==
                                          'Recommended'
                                      ? ColorFiltered(
                                          colorFilter: const ColorFilter.mode(
                                            Color(0xFF4D4DE2),
                                            BlendMode.srcIn,
                                          ),
                                          child: Image.asset(
                                            'assets/images/rabbit2.png',
                                            height: 48,
                                          ),
                                        )
                                      : Image.asset(
                                          'assets/images/rabbit2.png',
                                          height: 48,
                                        ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.center,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: _getRecommendationText() ==
                                          'Fatigue Risk'
                                      ? ColorFiltered(
                                          colorFilter: const ColorFilter.mode(
                                            Color(0xFF4D4DE2),
                                            BlendMode.srcIn,
                                          ),
                                          child: Image.asset(
                                            'assets/images/eagle.png',
                                            height: 48,
                                          ),
                                        )
                                      : Image.asset(
                                          'assets/images/eagle.png',
                                          height: 48,
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Slider
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 2,
                            activeTrackColor: Colors.black,
                            inactiveTrackColor: Colors.grey[300],
                            thumbColor: Colors.white,
                            overlayColor: Colors.black.withOpacity(0.05),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 17,
                            ),
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 12,
                              elevation: 4,
                            ),
                          ),
                          child: Slider(
                            value: speedValue,
                            min: widget.isMetric ? 0.1 : 0.1,
                            max: widget.isMetric ? 1.0 : 2.2,
                            onChanged: (value) {
                              setState(() {
                                speedValue = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Weight marks row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment(-0.3, 0),
                                child: Text(
                                  widget.isMetric ? '0.1 kg' : '0.1 lb',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[600],
                                    fontFamily: '.SF Pro Display',
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  widget.isMetric ? '0.5 kg' : '1.2 lb',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[600],
                                    fontFamily: '.SF Pro Display',
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment(0.3, 0),
                                child: Text(
                                  widget.isMetric ? '1.0 kg' : '2.2 lb',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[600],
                                    fontFamily: '.SF Pro Display',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),
                        // Recommended box
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F1F3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              _getRecommendationText(),
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontFamily: '.SF Pro Display',
                              ),
                            ),
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
                  onPressed: () async {
                    await _saveGoalSpeed();

                    // Get the user_gender from SharedPreferences to verify
                    final prefs = await SharedPreferences.getInstance();

                    // CRITICAL FIX: Get the most accurate gender value - prioritize user_gender over passed-in value
                    String mostRecentGender;
                    if (prefs.containsKey('user_gender')) {
                      mostRecentGender = prefs.getString('user_gender')!;
                      print(
                          'Using user_gender from SharedPreferences: "$mostRecentGender"');
                    } else if (prefs.containsKey('gender')) {
                      mostRecentGender = prefs.getString('gender')!;
                      print(
                          'Using gender from SharedPreferences: "$mostRecentGender"');
                    } else {
                      mostRecentGender = widget.gender;
                      print(
                          'No gender in SharedPreferences, using passed value: "$mostRecentGender"');
                    }

                    // Update both gender keys for consistency
                    await prefs.setString('user_gender', mostRecentGender);
                    await prefs.setString('gender', mostRecentGender);
                    print(
                        'Saved consistent gender to both keys: "$mostRecentGender"');

                    // Navigate to CalculationScreen with the correct gender
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CalculationScreen(
                          isMetric: widget.isMetric,
                          initialWeight: widget.initialWeight,
                          dreamWeight: widget.dreamWeight,
                          isGaining: widget.isGaining,
                          speedValue: speedValue,
                          gender:
                              mostRecentGender, // Use the most recent gender
                          heightInCm: widget.heightInCm,
                          birthDate: widget.birthDate,
                          gymGoal: widget.gymGoal ?? 'Maintain',
                        ),
                      ),
                    );
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
      ),
    );
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        setState(() {
          if (speedValue > minWeight) {
            speedValue--;
          }
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        setState(() {
          if (speedValue < maxWeight) {
            speedValue++;
          }
        });
      }
    }
  }

  String _getRecommendationText() {
    if (widget.isMetric) {
      // Metric ranges (kg)
      if (speedValue <= 0.3) {
        return 'Slow & Sustainable';
      } else if (speedValue <= 0.7) {
        return 'Recommended';
      } else {
        return 'Fatigue Risk';
      }
    } else {
      // Imperial ranges (lb)
      if (speedValue <= 0.7) {
        return 'Slow & Sustainable';
      } else if (speedValue <= 1.5) {
        return 'Recommended';
      } else {
        return 'Fatigue Risk';
      }
    }
  }

  // Add this helper method to determine which animal should be colored
  Widget _colorFilteredImage(String imagePath, bool shouldColor) {
    if (shouldColor) {
      return ColorFiltered(
        colorFilter: const ColorFilter.mode(
          Color(0xFF4D4DE2),
          BlendMode.srcIn,
        ),
        child: Image.asset(
          imagePath,
          height: 48,
        ),
      );
    }
    return Image.asset(
      imagePath,
      height: 48,
    );
  }
}
