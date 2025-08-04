import 'package:flutter/material.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/questions/weight_goal_screen.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeightHeightScreen extends StatefulWidget {
  const WeightHeightScreen({super.key});

  @override
  State<WeightHeightScreen> createState() => _WeightHeightScreenState();
}

class _WeightHeightScreenState extends State<WeightHeightScreen> {
  static const int totalSteps = 7;
  static const int currentStep = 2;

  // Units
  bool isImperial = true;

  // Weight values
  int selectedWeight = 150;
  List<int> weightOptions = List.generate(100, (index) => 100 + index);

  // Height values (imperial)
  int selectedFeet = 5;
  int selectedInches = 7;
  // Height value in cm (for metric)
  int selectedHeight = 170; // Will update based on unit system
  List<int> feetOptions = List.generate(8, (index) => index + 3); // 3-10 feet
  List<int> inchesOptions = List.generate(12, (index) => index); // 0-11 inches

  double get progress => currentStep / totalSteps;

  // Calculate height in centimeters based on feet and inches
  int _getHeightInCm() {
    if (isImperial) {
      // Convert feet and inches to cm for imperial
      double heightInCm = ((selectedFeet * 12 + selectedInches) * 2.54);
      print(
          'Converting height: $selectedFeet feet $selectedInches inches = ${heightInCm.toInt()} cm');
      return heightInCm.toInt();
    } else {
      // For metric, height is already in cm
      print('Using metric height: $selectedHeight cm');
      return selectedHeight;
    }
  }

  // Save weight and height to SharedPreferences
  Future<void> _saveWeightHeight() async {
    if (selectedWeight != null && _getHeightInCm() != null) {
      try {
        final prefs = await SharedPreferences.getInstance();

        // DEBUG: Show all current keys
        print("\n===== BEFORE SAVING WEIGHT & HEIGHT =====");
        print("All SharedPreferences keys: ${prefs.getKeys()}");
        print("HEIGHT VALUES BEFORE SAVING:");
        for (String key in [
          'user_height_cm',
          'heightInCm',
          'height_cm',
          'height'
        ]) {
          try {
            if (prefs.containsKey(key)) {
              if (prefs.getInt(key) != null) {
                print('$key (Int): ${prefs.getInt(key)}');
              } else if (prefs.getDouble(key) != null) {
                print('$key (Double): ${prefs.getDouble(key)}');
              } else {
                print('$key: exists but type is not int or double');
              }
            } else {
              print('$key: does not exist');
            }
          } catch (e) {
            print('$key: Error reading - $e');
          }
        }

        // Calculate height in cm
        final int heightInCm = _getHeightInCm();
        print("\nSAVING HEIGHT VALUE:");
        print("Height value to save: $heightInCm cm (correctly converted)");

        if (isImperial) {
          print(
              "Also saving original height: $selectedFeet feet $selectedInches inches");
          // CRITICAL DEBUG: Verify the inches value is reasonable
          if (selectedInches < 0 || selectedInches > 11) {
            print(
                "WARNING: Inches value ($selectedInches) is invalid! Should be 0-11");
          }
        }

        // Save weight - using proper conversion if needed
        double weightToSave;
        if (isImperial) {
          // Convert pounds to kg if using imperial
          weightToSave = selectedWeight * 0.453592;
          print(
              "Weight to save: $weightToSave kg (converted from ${selectedWeight}lbs)");
        } else {
          weightToSave = selectedWeight.toDouble();
          print("Weight to save: $weightToSave kg");
        }

        // Save weight first
        await prefs.setDouble('user_weight_kg', weightToSave);

        // CRITICAL: Save height in EVERY possible format to ensure it's always accessible
        // 1. Save as integer
        await prefs.setInt('user_height_cm', heightInCm);
        await prefs.setInt('height', heightInCm);

        // 2. Save as double
        await prefs.setDouble('heightInCm', heightInCm.toDouble());
        await prefs.setDouble('height_cm', heightInCm.toDouble());

        // 3. Save units preference
        await prefs.setBool('is_metric', !isImperial);

        // 4. IMPORTANT: Save original height values in original units
        // This is critical for proper height retrieval
        if (isImperial) {
          // CRITICAL FIX: Verify inches is in the correct range (0-11)
          int inchesToSave = selectedInches;
          // If inches is out of range, reset to a valid value
          if (inchesToSave < 0 || inchesToSave > 11) {
            print(
                "CRITICAL FIX: Correcting invalid inches value $inchesToSave to valid range (0-11)");
            // Get the correct inches value from the wheel position
            inchesToSave = selectedInches % 12;
            print("Corrected inches value: $inchesToSave");
          }

          await prefs.setInt('original_height_feet', selectedFeet);
          await prefs.setInt('original_height_inches', inchesToSave);
          await prefs.setInt('original_weight_lbs', selectedWeight);
        }

        // DEBUG: Verify data was saved correctly
        print("\nHEIGHT VALUES AFTER SAVING:");
        for (String key in [
          'user_height_cm',
          'heightInCm',
          'height_cm',
          'height'
        ]) {
          try {
            if (prefs.containsKey(key)) {
              if (prefs.getInt(key) != null) {
                print('$key (Int): ${prefs.getInt(key)}');
              } else if (prefs.getDouble(key) != null) {
                print('$key (Double): ${prefs.getDouble(key)}');
              } else {
                print('$key: exists but type is not int or double');
              }
            } else {
              print('$key: does not exist');
            }
          } catch (e) {
            print('$key: Error reading - $e');
          }
        }

        print("All calculation data saved to SharedPreferences");

        // Additional verification for the height to ensure it was saved properly
        int? savedHeightInt = prefs.getInt('user_height_cm');
        double? savedHeightDouble = prefs.getDouble('heightInCm');
        int? savedFeet =
            isImperial ? prefs.getInt('original_height_feet') : null;
        int? savedInches =
            isImperial ? prefs.getInt('original_height_inches') : null;

        print("Final verification:");
        print("- Saved height (cm): $savedHeightInt");
        print("- Saved height (cm as double): $savedHeightDouble");
        if (isImperial) {
          print("- Original feet: $savedFeet");
          print("- Original inches: $savedInches");

          // Final verification of conversion
          int totalInches = (savedFeet ?? 0) * 12 + (savedInches ?? 0);
          double calculatedCm = totalInches * 2.54;
          print(
              "- Verification: $savedFeet'$savedInches\" = $totalInches inches = ${calculatedCm.toInt()} cm");

          if (calculatedCm.toInt() != savedHeightInt) {
            print(
                "ERROR: Height conversion mismatch! Stored cm ($savedHeightInt) doesn't match calculated cm (${calculatedCm.toInt()})");
          }
        }
      } catch (e) {
        print('Error saving weight and height: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // If we're not using imperial units (so metric), initialize with a reasonable value
    if (!isImperial) {
      selectedHeight = 170; // Default metric height in cm
    } else {
      // Calculate the metric equivalent of our default imperial height
      selectedHeight = _getHeightInCm();
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

          // Main content
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button and progress bar
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
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 2,
                          backgroundColor: const Color(0xFFE5E5EA),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),

                // Title and subtitle
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24, top: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weight & Height',
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

                // Fixed layout container to match iPhone 13 mini proportions
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Get available height after accounting for top elements and bottom area
                    final availableHeight = constraints.maxHeight -
                        150; // Subtract for bottom padding
                    // iPhone 13 mini height: 812 points
                    // Reference height for spacing calculation - the key to consistency
                    const referenceHeight = 812.0;
                    // Scale factor based on device height
                    final scaleFactor =
                        MediaQuery.of(context).size.height / referenceHeight;

                    // Position the toggle at the exact same relative position as on iPhone 13 mini
                    return Container(
                      height: availableHeight,
                      padding: EdgeInsets.zero, // Remove padding from container
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // Center all children
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Create fixed spacing that matches iPhone 13 mini
                          SizedBox(height: 60 * scaleFactor),

                          // Unit toggle - fixed position with guaranteed centering
                          Container(
                            width: double
                                .infinity, // Full width to allow centering
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Imperial',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Switch(
                                  value: !isImperial,
                                  onChanged: (value) {
                                    setState(() {
                                      bool wasImperial = isImperial;
                                      isImperial = !value;

                                      // When switching between units, preserve the height
                                      if (wasImperial && !isImperial) {
                                        // Convert from imperial to metric
                                        selectedHeight = _getHeightInCm();
                                        print(
                                            'Switched to metric: height = $selectedHeight cm (converted from ${selectedFeet}ft ${selectedInches}in)');
                                      } else if (!wasImperial && isImperial) {
                                        // Convert from metric to imperial - approximate
                                        double totalInches =
                                            selectedHeight / 2.54;
                                        selectedFeet =
                                            (totalInches / 12).floor();
                                        selectedInches =
                                            (totalInches % 12).round();
                                        print(
                                            'Switched to imperial: height = ${selectedFeet}ft ${selectedInches}in (converted from ${selectedHeight}cm)');
                                      }
                                    });
                                  },
                                  activeColor: Colors.black,
                                  inactiveThumbColor: Colors.black,
                                  inactiveTrackColor: Colors.grey[300],
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Metric',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Fixed spacing from toggle to labels
                          SizedBox(height: 30 * scaleFactor),

                          // COMBINED LABELS AND PICKERS - GUARANTEED ALIGNMENT
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                children: [
                                  // LEFT SIDE - WEIGHT COLUMN
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Weight label
                                        Text(
                                          'Weight',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                                        // Fixed spacing - always 20 pixels on all devices
                                        const SizedBox(height: 20),
                                        // Weight picker
                                        Expanded(
                                          child: ClipRect(
                                            child: OverflowBox(
                                              maxHeight: double.infinity,
                                              child: ListWheelScrollView
                                                  .useDelegate(
                                                itemExtent: 45,
                                                perspective: 0.005,
                                                diameterRatio: 1.5,
                                                physics:
                                                    FixedExtentScrollPhysics(),
                                                onSelectedItemChanged: (index) {
                                                  setState(() {
                                                    selectedWeight =
                                                        weightOptions[index];
                                                  });
                                                },
                                                childDelegate:
                                                    ListWheelChildBuilderDelegate(
                                                  childCount:
                                                      weightOptions.length,
                                                  builder: (context, index) {
                                                    final weight =
                                                        weightOptions[index];
                                                    final isSelected = weight ==
                                                        selectedWeight;
                                                    return Center(
                                                      child: Text(
                                                        '$weight lb',
                                                        style: TextStyle(
                                                          fontSize: isSelected
                                                              ? 20
                                                              : 16,
                                                          fontWeight: isSelected
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                  .normal,
                                                          color: isSelected
                                                              ? Colors.black
                                                              : Colors
                                                                  .grey[400],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // RIGHT SIDE - HEIGHT COLUMN
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Height label
                                        Container(
                                          width: double.infinity,
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Height',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        // Fixed spacing - always 20 pixels on all devices
                                        const SizedBox(height: 20),
                                        // Height pickers
                                        Expanded(
                                          child: isImperial
                                              // IMPERIAL MODE: Show feet and inches
                                              ? Row(
                                                  // Use center alignment with fixed spacing between pickers
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    // Feet picker
                                                    SizedBox(
                                                      width: 70,
                                                      child: ClipRect(
                                                        child: OverflowBox(
                                                          maxHeight:
                                                              double.infinity,
                                                          child:
                                                              ListWheelScrollView
                                                                  .useDelegate(
                                                            itemExtent: 45,
                                                            perspective: 0.005,
                                                            diameterRatio: 1.5,
                                                            physics:
                                                                FixedExtentScrollPhysics(),
                                                            onSelectedItemChanged:
                                                                (index) {
                                                              setState(() {
                                                                selectedFeet =
                                                                    feetOptions[
                                                                        index];
                                                              });
                                                            },
                                                            childDelegate:
                                                                ListWheelChildBuilderDelegate(
                                                              childCount:
                                                                  feetOptions
                                                                      .length,
                                                              builder: (context,
                                                                  index) {
                                                                final feet =
                                                                    feetOptions[
                                                                        index];
                                                                final isSelected =
                                                                    feet ==
                                                                        selectedFeet;
                                                                return Center(
                                                                  child: Text(
                                                                    '$feet ft',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          isSelected
                                                                              ? 20
                                                                              : 16,
                                                                      fontWeight: isSelected
                                                                          ? FontWeight
                                                                              .bold
                                                                          : FontWeight
                                                                              .normal,
                                                                      color: isSelected
                                                                          ? Colors
                                                                              .black
                                                                          : Colors
                                                                              .grey[400],
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                    // Fixed spacing between ft and in pickers
                                                    const SizedBox(width: 24),

                                                    // Inches picker
                                                    SizedBox(
                                                      width: 70,
                                                      child: ClipRect(
                                                        child: OverflowBox(
                                                          maxHeight:
                                                              double.infinity,
                                                          child:
                                                              ListWheelScrollView
                                                                  .useDelegate(
                                                            itemExtent: 45,
                                                            perspective: 0.005,
                                                            diameterRatio: 1.5,
                                                            physics:
                                                                FixedExtentScrollPhysics(),
                                                            onSelectedItemChanged:
                                                                (index) {
                                                              setState(() {
                                                                selectedInches =
                                                                    inchesOptions[
                                                                        index];
                                                              });
                                                            },
                                                            childDelegate:
                                                                ListWheelChildBuilderDelegate(
                                                              childCount:
                                                                  inchesOptions
                                                                      .length,
                                                              builder: (context,
                                                                  index) {
                                                                final inches =
                                                                    inchesOptions[
                                                                        index];
                                                                final isSelected =
                                                                    inches ==
                                                                        selectedInches;
                                                                return Center(
                                                                  child: Text(
                                                                    '$inches in',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          isSelected
                                                                              ? 20
                                                                              : 16,
                                                                      fontWeight: isSelected
                                                                          ? FontWeight
                                                                              .bold
                                                                          : FontWeight
                                                                              .normal,
                                                                      color: isSelected
                                                                          ? Colors
                                                                              .black
                                                                          : Colors
                                                                              .grey[400],
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              // METRIC MODE: Show cm picker
                                              : Container(
                                                  width: 170,
                                                  child: ClipRect(
                                                    child: OverflowBox(
                                                      maxHeight:
                                                          double.infinity,
                                                      child: ListWheelScrollView
                                                          .useDelegate(
                                                        itemExtent: 45,
                                                        perspective: 0.005,
                                                        diameterRatio: 1.5,
                                                        physics:
                                                            FixedExtentScrollPhysics(),
                                                        onSelectedItemChanged:
                                                            (index) {
                                                          setState(() {
                                                            // Range from 140cm to 220cm
                                                            selectedHeight =
                                                                140 + index;
                                                            print(
                                                                'Selected metric height: $selectedHeight cm');
                                                          });
                                                        },
                                                        // Calculate initial index based on current height
                                                        controller:
                                                            FixedExtentScrollController(
                                                          initialItem:
                                                              selectedHeight -
                                                                  140,
                                                        ),
                                                        childDelegate:
                                                            ListWheelChildBuilderDelegate(
                                                          childCount:
                                                              81, // 140cm to 220cm
                                                          builder:
                                                              (context, index) {
                                                            final height =
                                                                140 + index;
                                                            final isSelected =
                                                                height ==
                                                                    selectedHeight;
                                                            return Center(
                                                              child: Text(
                                                                '$height cm',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      isSelected
                                                                          ? 20
                                                                          : 16,
                                                                  fontWeight: isSelected
                                                                      ? FontWeight
                                                                          .bold
                                                                      : FontWeight
                                                                          .normal,
                                                                  color: isSelected
                                                                      ? Colors
                                                                          .black
                                                                      : Colors.grey[
                                                                          400],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
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
                          ),
                        ],
                      ),
                    );
                  },
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

          // Continue button
          Positioned(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).size.height * 0.05,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.064,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextButton(
                onPressed: () async {
                  // Save weight and height before navigation
                  await _saveWeightHeight();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WeightGoalScreen(),
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
    );
  }
}
