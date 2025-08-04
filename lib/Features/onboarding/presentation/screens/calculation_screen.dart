import 'package:flutter/material.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/comfort_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalculationScreen extends StatefulWidget {
  final bool isMetric;
  final int initialWeight;
  final int dreamWeight;
  final bool isGaining;
  final double speedValue;
  final String gender;
  final int heightInCm;
  final DateTime birthDate;
  final String gymGoal;

  const CalculationScreen({
    super.key,
    required this.isMetric,
    required this.initialWeight,
    required this.dreamWeight,
    required this.isGaining,
    required this.speedValue,
    required this.gender,
    required this.heightInCm,
    required this.birthDate,
    required this.gymGoal,
  });

  @override
  State<CalculationScreen> createState() => _CalculationScreenState();
}

class _CalculationScreenState extends State<CalculationScreen> {
  late String workingGender;
  int calculatedCalories = 0;
  int tdee = 0;
  int dailyDeficit = 0;
  int proteinGrams = 0;
  int fatGrams = 0;
  int carbGrams = 0;
  bool isInitialized = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initial setup with passed gender
    workingGender = widget.gender;
    // Load gender from SharedPreferences then run calculations
    _initializeData();
  }

  // Initialize data asynchronously and ensure calculations use correct gender
  Future<void> _initializeData() async {
    try {
      // First check SharedPreferences for gender
      await _loadGenderFromPreferences();

      // Now do all calculations with the correct gender
      _runCalculations();

      // Set initialized flag
      setState(() {
        isInitialized = true;
        isLoading = false;
      });

      // Finally save all the calculated data
      await _saveDataToPreferences(widget.heightInCm);
    } catch (e) {
      print('Error in initialization: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Load gender from SharedPreferences
  Future<void> _loadGenderFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // First try user_gender key (primary)
      if (prefs.containsKey('user_gender')) {
        String storedGender = prefs.getString('user_gender')!;
        if (storedGender != workingGender) {
          print(
              'Loading gender from SharedPreferences (user_gender): "$storedGender" (was: "${widget.gender}")');
          workingGender = storedGender;
        }
      }
      // Then try gender key (backup)
      else if (prefs.containsKey('gender')) {
        String storedGender = prefs.getString('gender')!;
        if (storedGender != workingGender) {
          print(
              'Loading gender from SharedPreferences (gender): "$storedGender" (was: "${widget.gender}")');
          workingGender = storedGender;
        }
      } else {
        print(
            'No gender found in SharedPreferences, using constructor value: "${widget.gender}"');
      }
    } catch (e) {
      print('Error loading gender from SharedPreferences: $e');
    }
  }

  // Run all calculations with the correct gender
  void _runCalculations() {
    // Print debug values
    print('Initial values:');
    print('Weight: ${widget.initialWeight} ${widget.isMetric ? 'kg' : 'lbs'}');
    print('Final gender used for all calculations: "$workingGender"');
    print('Height used for calculation: ${widget.heightInCm} cm');
    print('Speed: ${widget.speedValue} ${widget.isMetric ? 'kg' : 'lbs'}/week');
    print('Birth date: ${widget.birthDate}');

    // Calculate age correctly - matches codia_page.dart logic
    DateTime today = DateTime.now();
    int userAge = today.year - widget.birthDate.year;
    if (today.month < widget.birthDate.month ||
        (today.month == widget.birthDate.month &&
            today.day < widget.birthDate.day)) {
      userAge--;
    }

    // Only check for maximum age (130)
    if (userAge > 130) {
      print(
          'WARNING: User appears to be over 130 years old (age: $userAge). Using maximum age of 130.');
      userAge = 130;
    }

    print('Calculated age: $userAge from birth date: ${widget.birthDate}');

    // Convert measurements if using imperial units
    final weightInKg = widget.isMetric
        ? widget.initialWeight
        : (widget.initialWeight * 0.453592).round();
    final dreamWeightInKg = widget.isMetric
        ? widget.dreamWeight
        : (widget.dreamWeight * 0.453592).round();

    // Use converted height
    final heightConverted = widget.heightInCm;

    print('Converted values:');
    print('Weight in kg: $weightInKg');
    print('Height in cm: $heightConverted');

    // NORMALIZE GOAL SPEED to exact increments (match codia_page.dart)
    double normalizedSpeed = widget.speedValue;
    if (widget.speedValue > 0) {
      if (widget.isMetric) {
        // Round to exactly 1 decimal place
        normalizedSpeed = (widget.speedValue * 10).round() / 10.0;
        print(
            'Normalized goal speed from ${widget.speedValue} to ${normalizedSpeed.toStringAsFixed(1)} kg/week');
      } else {
        // Round to exactly 1 decimal place for pounds
        normalizedSpeed = (widget.speedValue * 10).round() / 10.0;
        print(
            'Normalized goal speed from ${widget.speedValue} to ${normalizedSpeed.toStringAsFixed(1)} lb/week');
      }
    }

    // Round weightInKg to 1 decimal place (match codia_page.dart)
    double roundedWeightKg = (weightInKg * 10).round() / 10.0;
    double roundedDreamWeightKg = (dreamWeightInKg * 10).round() / 10.0;

    // Ensure height is a whole number (match codia_page.dart)
    int roundedHeight = heightConverted.round();

    // Calculate TDEE first using rounded values
    tdee = calculateTDEE(
      gender: workingGender,
      weightKg: roundedWeightKg.round(), // Use rounded weight
      heightCm: roundedHeight, // Use rounded height
      userAge: userAge, // Use the calculated age
    );

    print('TDEE calculated: $tdee');

    // Calculate daily deficit/surplus based on unit system with normalized speed
    if (widget.isMetric) {
      // Metric: Use 7700 kcal per kg
      // Round to 1 decimal place for metric values
      normalizedSpeed = (normalizedSpeed * 10).round() / 10.0;
      // Do NOT round the deficit calculation to maintain precision for small values
      double exactMetricDeficit = normalizedSpeed * 7700 / 7;
      dailyDeficit =
          exactMetricDeficit.floor().toInt(); // Weekly kg to daily calories
      print(
          'Metric calculation: ${normalizedSpeed.toStringAsFixed(3)} kg/week × 7700 ÷ 7 = ${exactMetricDeficit.toStringAsFixed(3)} → $dailyDeficit calories/day');
    } else {
      // Imperial: Use 3500 kcal per lb
      // For imperial values, keep full precision during calculation
      // For display only, round to 1 decimal place
      double displaySpeed = (normalizedSpeed * 10).round() / 10.0;
      // Do NOT round the deficit calculation to maintain precision for small values
      double exactDeficit = normalizedSpeed * 3500 / 7;
      dailyDeficit =
          exactDeficit.floor().toInt(); // Weekly lbs to daily calories
      print(
          'Imperial calculation: ${displaySpeed.toStringAsFixed(1)} lb/week × 3500 ÷ 7 = ${exactDeficit.toStringAsFixed(3)} → $dailyDeficit calories/day');
    }

    print('Daily deficit calculated: $dailyDeficit');

    // Calculate final target calories
    double rawCalculatedCalories = widget.isGaining
        ? tdee.toDouble() + dailyDeficit.toDouble()
        : tdee.toDouble() - dailyDeficit.toDouble();
    print('Raw calculated calories before flooring: $rawCalculatedCalories');

    // Ensure the calories match exactly with codia_page.dart by using floor instead of rounding
    calculatedCalories = rawCalculatedCalories.floorToDouble().toInt();

    print('Final target calories (floored): $calculatedCalories');

    // Define macro distribution based on gym goal - EXACT SAME AS IN codia_page.dart
    Map<String, Map<String, double>> macroTargets = {
      "Build Muscle": {
        "proteinPercent": 0.32,
        "carbPercent": 0.45,
        "fatPercent": 0.23,
      },
      "Gain Strength": {
        "proteinPercent": 0.28,
        "carbPercent": 0.42,
        "fatPercent": 0.30,
      },
      "Boost Endurance": {
        "proteinPercent": 0.18,
        "carbPercent": 0.60,
        "fatPercent": 0.22,
      },
      // Default balanced macros when no gym goal is selected
      "null": {
        "proteinPercent": 0.25,
        "carbPercent": 0.50,
        "fatPercent": 0.25,
      }
    };

    // Get the macro distribution for the selected gym goal (default to balanced macros if null or not found)
    print('Using gym goal for macros: "${widget.gymGoal}"');
    Map<String, double> selectedMacros =
        macroTargets["null"]!; // Default to balanced macros

    // Only try to use gymGoal if it's a valid key in the map - EXACTLY like in codia_page.dart
    String goalKey = widget.gymGoal ?? "null";
    if (macroTargets.containsKey(goalKey)) {
      selectedMacros = macroTargets[goalKey]!;
      print('Using macro distribution for: "$goalKey"');
    } else {
      print(
          'No matching macro distribution for: "$goalKey", using balanced default');
    }

    // Calculate macronutrient targets based on calorie goal and gym goal
    double proteinPercent = selectedMacros["proteinPercent"]!;
    double carbPercent = selectedMacros["carbPercent"]!;
    double fatPercent = selectedMacros["fatPercent"]!;

    // Log the selected macro distribution exactly like codia_page.dart
    print('Using macro distribution for gym goal: "${widget.gymGoal}"');
    print('- Protein: ${(proteinPercent * 100).toStringAsFixed(1)}%');
    print('- Carbs: ${(carbPercent * 100).toStringAsFixed(1)}%');
    print('- Fat: ${(fatPercent * 100).toStringAsFixed(1)}%');

    // Calculate macro targets in grams - EXACTLY as in codia_page.dart
    proteinGrams = ((calculatedCalories * proteinPercent) / 4).round();
    fatGrams = ((calculatedCalories * fatPercent) / 9).round();
    carbGrams = ((calculatedCalories * carbPercent) / 4).round();

    // Log the calculations with the exact same format as codia_page.dart
    print('Calculated macro targets for $calculatedCalories calories:');
    print(
        '- Protein: ${proteinGrams}g (${(calculatedCalories * proteinPercent).round()} kcal)');
    print(
        '- Fat: ${fatGrams}g (${(calculatedCalories * fatPercent).round()} kcal)');
    print(
        '- Carbs: ${carbGrams}g (${(calculatedCalories * carbPercent).round()} kcal)');
    print(
        '- Total: ${((calculatedCalories * proteinPercent) + (calculatedCalories * fatPercent) + (calculatedCalories * carbPercent)).round()} kcal');
  }

  // Save all important calculation data to SharedPreferences
  Future<void> _saveDataToPreferences(int heightInCm) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // CRITICAL: Double-check gender from SharedPreferences one more time
      // This ensures we always have the latest value
      if (prefs.containsKey('user_gender')) {
        String storedGender = prefs.getString('user_gender')!;
        if (storedGender != workingGender) {
          print(
              'CRITICAL UPDATE: Updating gender from "$workingGender" to "$storedGender" before saving data');
          workingGender = storedGender;
        }
      }

      // Print existing height values for debugging
      print('\nHEIGHT VALUES BEFORE SAVING:');
      List<String> heightKeys = [
        'user_height_cm',
        'heightInCm',
        'height_cm',
        'height'
      ];
      for (String key in heightKeys) {
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

      // Save gender - STORE IT IN BOTH KEYS for consistency across the app
      await prefs.setString('user_gender', workingGender);
      await prefs.setString(
          'gender', workingGender); // Add this to ensure codia_page finds it
      print(
          'Saved gender to both "user_gender" and "gender" keys: "$workingGender"');

      // Save weight - both in original and kg format if needed
      if (widget.isMetric) {
        await prefs.setDouble(
            'user_weight_kg', widget.initialWeight.toDouble());
      } else {
        // Convert to kg for consistent storage
        double weightInKg = widget.initialWeight * 0.453592;
        await prefs.setDouble('user_weight_kg', weightInKg);
        await prefs.setDouble(
            'original_weight_lbs', widget.initialWeight.toDouble());
      }

      // Save height in cm - CRITICAL: Store as both int and double using the CONVERTED height value
      print('\nSAVING HEIGHT VALUE:');
      print('Height value to save: $heightInCm cm (correctly converted)');
      await prefs.setInt('user_height_cm', heightInCm);
      await prefs.setDouble('heightInCm', heightInCm.toDouble());
      await prefs.setDouble('height_cm', heightInCm.toDouble());
      await prefs.setInt('height', heightInCm);

      // Also save original height in inches if using imperial
      if (!widget.isMetric) {
        int originalHeightInches = widget.heightInCm;
        await prefs.setInt('original_height_inches', originalHeightInches);
        print('Also saving original height: $originalHeightInches inches');
      }

      // Verify height was properly saved
      print('\nHEIGHT VALUES AFTER SAVING:');
      for (String key in heightKeys) {
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

      // Save birth date as string
      await prefs.setString('birth_date', widget.birthDate.toIso8601String());

      // Save weight goal - Make sure these are consistent
      // If speedValue is 0, set goal to 'maintain' explicitly
      if (widget.speedValue == 0) {
        await prefs.setString('goal', 'maintain');
        await prefs.setBool('isGaining', false); // Clear any previous value
        await prefs.setBool('isMaintaining', true); // Add a clear indicator
      } else {
        await prefs.setString('goal', widget.isGaining ? 'gain' : 'lose');
        await prefs.setBool('isGaining', widget.isGaining);
        await prefs.setBool('isMaintaining', false);
      }

      // Save goal speed - Be explicit about units and ensure consistency across all screens
      await prefs.setDouble('goal_speed', widget.speedValue);

      // Also save the kg equivalent for cross-screen compatibility
      if (!widget.isMetric && widget.speedValue > 0) {
        double speedInKg = widget.speedValue * 0.453592;
        await prefs.setDouble('goal_speed_kg_per_week', speedInKg);
      } else {
        await prefs.setDouble('goal_speed_kg_per_week', widget.speedValue);
      }

      // Save gym goal if not null
      if (widget.gymGoal != null && widget.gymGoal.isNotEmpty) {
        await prefs.setString('gymGoal', widget.gymGoal);
      }

      // Save metric/imperial preference
      await prefs.setBool('is_metric', widget.isMetric);

      // Convert weight to kg for calculations
      double weightKg = widget.isMetric
          ? widget.initialWeight.toDouble()
          : widget.initialWeight * 0.453592;

      // Calculate user age
      DateTime today = DateTime.now();
      int userAge = today.year - widget.birthDate.year;
      if (today.month < widget.birthDate.month ||
          (today.month == widget.birthDate.month &&
              today.day < widget.birthDate.day)) {
        userAge--;
      }

      // Calculate activity level - default to moderate activity (1.55)
      // In a real app, you would have the user select their activity level
      double activityLevel = 1.55;

      // Calculate daily calorie requirements based on gender, weight, height, and age
      // Using Mifflin-St Jeor Equation
      double bmr;
      if (workingGender == 'Female') {
        bmr =
            (10 * weightKg) + (6.25 * widget.heightInCm) - (5 * userAge) - 161;
      } else {
        bmr = (10 * weightKg) + (6.25 * widget.heightInCm) - (5 * userAge) + 5;
      }

      // Calculate TDEE (Total Daily Energy Expenditure)
      double tdee = bmr * activityLevel;

      // PERSONALIZED NUTRIENT TARGETS
      // ---------------------------

      print('\nCALCULATING PERSONALIZED NUTRIENT TARGETS:');

      // 1. Calculate vitamin targets based on user profile
      Map<String, double> vitaminTargets = _calculateVitaminTargets(
          workingGender, userAge, weightKg, widget.heightInCm);

      // 2. Calculate mineral targets based on user profile
      Map<String, double> mineralTargets = _calculateMineralTargets(
          workingGender, userAge, weightKg, widget.heightInCm);

      // 3. Calculate other nutrient targets based on user profile and calculated calories
      Map<String, double> otherNutrientTargets = _calculateOtherNutrientTargets(
          workingGender,
          userAge,
          weightKg,
          widget.heightInCm,
          calculatedCalories);

      // Save all calculated targets to SharedPreferences

      // Save vitamin targets
      for (var entry in vitaminTargets.entries) {
        // Standardize key format - replace spaces with underscores
        String normalizedKey = entry.key.toLowerCase().replaceAll(' ', '_');
        await prefs.setDouble('vitamin_target_$normalizedKey', entry.value);
        print('Saved vitamin target: ${entry.key} = ${entry.value}');
      }

      // Save mineral targets
      for (var entry in mineralTargets.entries) {
        // Standardize key format - replace spaces with underscores
        String normalizedKey = entry.key.toLowerCase().replaceAll(' ', '_');
        await prefs.setDouble('mineral_target_$normalizedKey', entry.value);
        print('Saved mineral target: ${entry.key} = ${entry.value}');
      }

      // Save other nutrient targets
      for (var entry in otherNutrientTargets.entries) {
        await prefs.setDouble(
            'nutrient_target_${entry.key.toLowerCase()}', entry.value);
        print('Saved nutrient target: ${entry.key} = ${entry.value}');
      }

      // EXPLICITLY SAVE MACRONUTRIENT TARGETS TO ENSURE THEY ARE PROPERLY STORED
      // These are the most important targets that need to be applied consistently
      await prefs.setDouble('nutrient_target_protein', proteinGrams.toDouble());
      await prefs.setDouble('nutrient_target_fat', fatGrams.toDouble());
      await prefs.setDouble('nutrient_target_carbs', carbGrams.toDouble());

      print('Explicitly saved macronutrient targets:');
      print('- Protein: ${proteinGrams}g');
      print('- Fat: ${fatGrams}g');
      print('- Carbs: ${carbGrams}g');

      // Also save calculated calories
      await prefs.setInt('calculated_calories', calculatedCalories);
      print('Saved calculated calories: $calculatedCalories');

      // Save the calculation date so we know when these values were last updated
      await prefs.setString('nutrient_targets_calculation_date',
          DateTime.now().toIso8601String());

      print(
          'All calculation data and personalized nutrient targets saved to SharedPreferences');
    } catch (e) {
      print('Error saving calculation data: $e');
    }
  }

  // Calculate vitamin targets based on user profile
  Map<String, double> _calculateVitaminTargets(
      String gender, int age, double weightKg, int heightCm) {
    Map<String, double> targets = {};

    // Vitamin A - now adjusted based on weight (larger people need more)
    double baseVitaminA = gender == 'Female' ? 700 : 900; // mcg RAE
    targets['Vitamin A'] = baseVitaminA * (weightKg / 70).clamp(0.85, 1.3);
    targets['Vitamin A'] =
        double.parse(targets['Vitamin A']!.toStringAsFixed(0));

    // Vitamin C - now adjusted based on weight and height
    double baseVitaminC = gender == 'Female' ? 75 : 90; // mg
    if (gender == 'Female' && age > 18 && age <= 50) {
      baseVitaminC = 85; // Increased for reproductive age
    }
    // Taller and heavier people need more vitamin C
    double heightFactor = (heightCm / 170).clamp(0.9, 1.2);
    double weightFactor = (weightKg / 70).clamp(0.9, 1.3);
    targets['Vitamin C'] = baseVitaminC * heightFactor * weightFactor;
    targets['Vitamin C'] =
        double.parse(targets['Vitamin C']!.toStringAsFixed(0));

    // Vitamin D - based on age with adjustment for weight and height
    double vitaminD = 15; // mcg (600 IU)
    if (age > 70) {
      vitaminD = 20; // mcg (800 IU) for seniors
    }
    // Higher BMI may need more vitamin D
    double bmi = weightKg / ((heightCm / 100) * (heightCm / 100));
    if (bmi > 30) {
      vitaminD += 5; // Significant increase for higher BMI individuals
    } else if (bmi > 25) {
      vitaminD += 2.5; // Moderate increase
    }
    targets['Vitamin D'] = vitaminD;

    // Vitamin E - adjusted for body weight
    double baseVitaminE = 15; // mg
    targets['Vitamin E'] = baseVitaminE * (weightKg / 70).clamp(0.9, 1.25);
    targets['Vitamin E'] =
        double.parse(targets['Vitamin E']!.toStringAsFixed(1));

    // Vitamin K - adjusted for body weight
    double baseVitaminK = gender == 'Female' ? 90 : 120; // mcg
    targets['Vitamin K'] = baseVitaminK * (weightKg / 70).clamp(0.9, 1.2);
    targets['Vitamin K'] =
        double.parse(targets['Vitamin K']!.toStringAsFixed(0));

    // B Vitamins - based on energy needs, weight, and height

    // Vitamin B1 (Thiamin) - directly related to caloric intake
    targets['Vitamin B1'] =
        (calculatedCalories / 1000) * 0.5; // 0.5 mg per 1000 calories
    targets['Vitamin B1'] =
        double.parse(targets['Vitamin B1']!.toStringAsFixed(1));

    // Vitamin B2 (Riboflavin) - directly related to caloric intake
    targets['Vitamin B2'] =
        (calculatedCalories / 1000) * 0.6; // 0.6 mg per 1000 calories
    targets['Vitamin B2'] =
        double.parse(targets['Vitamin B2']!.toStringAsFixed(1));

    // Vitamin B3 (Niacin) - directly related to caloric intake
    targets['Vitamin B3'] =
        (calculatedCalories / 1000) * 6.6; // 6.6 mg per 1000 calories
    targets['Vitamin B3'] =
        double.parse(targets['Vitamin B3']!.toStringAsFixed(1));

    // Vitamin B5 (Pantothenic Acid) - adjust based on weight
    double baseVitaminB5 = 5; // mg
    targets['Vitamin B5'] = baseVitaminB5 * (weightKg / 70).clamp(0.9, 1.2);
    targets['Vitamin B5'] =
        double.parse(targets['Vitamin B5']!.toStringAsFixed(1));

    // Vitamin B6 (Pyridoxine) - adjust based on protein intake and weight
    double baseVitaminB6 = 1.3; // mg
    if (gender == 'Female' && age > 50) {
      baseVitaminB6 = 1.5; // mg
    } else if (gender == 'Male' && age > 50) {
      baseVitaminB6 = 1.7; // mg
    }
    // Adjust for protein intake (stored in proteinGrams)
    double proteinFactor = (proteinGrams / 70).clamp(1.0, 1.3);
    targets['Vitamin B6'] = baseVitaminB6 * proteinFactor;
    targets['Vitamin B6'] =
        double.parse(targets['Vitamin B6']!.toStringAsFixed(1));

    // Vitamin B7 (Biotin) - adjust based on weight
    double baseVitaminB7 = 30; // mcg
    targets['Vitamin B7'] = baseVitaminB7 * (weightKg / 70).clamp(0.9, 1.2);
    targets['Vitamin B7'] =
        double.parse(targets['Vitamin B7']!.toStringAsFixed(0));

    // Vitamin B9 (Folate) - adjust based on caloric intake and age/gender
    double baseVitaminB9 = 400; // mcg
    if (gender == 'Female' && age >= 18 && age <= 50) {
      baseVitaminB9 = 600; // mcg for women of reproductive age
    }
    // Also adjust slightly based on caloric intake
    targets['Vitamin B9'] =
        baseVitaminB9 * (calculatedCalories / 2000).clamp(0.9, 1.15);
    targets['Vitamin B9'] =
        double.parse(targets['Vitamin B9']!.toStringAsFixed(0));

    // Vitamin B12 (Cobalamin) - adjust based on age and weight
    double baseVitaminB12 = 2.4; // mcg
    if (age > 50) {
      baseVitaminB12 = 2.8; // Slight increase for older adults
    }
    targets['Vitamin B12'] = baseVitaminB12 * (weightKg / 70).clamp(0.95, 1.15);
    targets['Vitamin B12'] =
        double.parse(targets['Vitamin B12']!.toStringAsFixed(1));

    return targets;
  }

  // Calculate mineral targets based on user profile
  Map<String, double> _calculateMineralTargets(
      String gender, int age, double weightKg, int heightCm) {
    Map<String, double> targets = {};

    // Calculate BMI for some adjustments
    double bmi = weightKg / ((heightCm / 100) * (heightCm / 100));

    // Calcium - based on age, gender, and weight
    double baseCalcium = 1000; // mg
    if (age <= 18) {
      baseCalcium = 1300; // mg
    } else if (age > 50) {
      baseCalcium = 1200; // mg
    }
    // Adjust based on weight - larger people need more calcium for bone support
    targets['Calcium'] = baseCalcium * (weightKg / 70).clamp(0.95, 1.2);
    targets['Calcium'] = double.parse(targets['Calcium']!.toStringAsFixed(0));

    // Chloride - adjust based on weight and activity level
    double baseChloride = 2300; // mg
    targets['Chloride'] = baseChloride * (weightKg / 70).clamp(0.9, 1.15);
    targets['Chloride'] = double.parse(targets['Chloride']!.toStringAsFixed(0));

    // Chromium - based on age, gender, and caloric intake
    double baseChromium = gender == 'Female' ? 25 : 35; // mcg
    if (age > 50) {
      baseChromium = gender == 'Female' ? 20 : 30; // mcg
    }
    // Adjust based on caloric intake
    targets['Chromium'] =
        baseChromium * (calculatedCalories / 2000).clamp(0.9, 1.2);
    targets['Chromium'] = double.parse(targets['Chromium']!.toStringAsFixed(0));

    // Copper - adjust based on weight
    double baseCopper = 900; // mcg
    targets['Copper'] = baseCopper * (weightKg / 70).clamp(0.9, 1.15);
    targets['Copper'] = double.parse(targets['Copper']!.toStringAsFixed(0));

    // Fluoride - adjust based on weight
    double baseFluoride = gender == 'Female' ? 3 : 4; // mg
    targets['Fluoride'] = baseFluoride * (weightKg / 70).clamp(0.9, 1.15);
    targets['Fluoride'] = double.parse(targets['Fluoride']!.toStringAsFixed(1));

    // Iodine - adjust based on weight and BMI
    double baseIodine = 150; // mcg
    // Additional iodine for higher BMI (thyroid function)
    double bmiFactor = bmi > 30 ? 1.15 : (bmi > 25 ? 1.08 : 1.0);
    targets['Iodine'] =
        baseIodine * bmiFactor * (weightKg / 70).clamp(0.95, 1.15);
    targets['Iodine'] = double.parse(targets['Iodine']!.toStringAsFixed(0));

    // Iron - significantly different based on gender, age, and weight
    double baseIron = 8; // mg
    if (gender == 'Female' && age >= 18 && age <= 50) {
      baseIron = 18; // mg for menstruating women
    }
    // Adjust based on weight (blood volume)
    targets['Iron'] = baseIron * (weightKg / 70).clamp(0.9, 1.2);
    targets['Iron'] = double.parse(targets['Iron']!.toStringAsFixed(1));

    // Magnesium - based on gender, age, weight, and height
    double baseMagnesium = gender == 'Female' ? 310 : 400; // mg
    if (gender == 'Female' && age > 30) {
      baseMagnesium = 320; // mg
    } else if (gender == 'Male' && age > 30) {
      baseMagnesium = 420; // mg
    }
    // Adjust for both height and weight
    double heightMagFactor = (heightCm / 170).clamp(0.95, 1.15);
    targets['Magnesium'] =
        baseMagnesium * heightMagFactor * (weightKg / 70).clamp(0.95, 1.2);
    targets['Magnesium'] =
        double.parse(targets['Magnesium']!.toStringAsFixed(0));

    // Manganese - adjust based on weight
    double baseManganese = gender == 'Female' ? 1.8 : 2.3; // mg
    targets['Manganese'] = baseManganese * (weightKg / 70).clamp(0.95, 1.15);
    targets['Manganese'] =
        double.parse(targets['Manganese']!.toStringAsFixed(1));

    // Molybdenum - adjust based on weight
    double baseMolybdenum = 45; // mcg
    targets['Molybdenum'] = baseMolybdenum * (weightKg / 70).clamp(0.95, 1.15);
    targets['Molybdenum'] =
        double.parse(targets['Molybdenum']!.toStringAsFixed(0));

    // Phosphorus - adjust based on weight and protein intake
    double basePhosphorus = 700; // mg
    // Adjust for protein intake, as higher protein diets may require more phosphorus
    double proteinFactor = (proteinGrams / 70).clamp(1.0, 1.2);
    targets['Phosphorus'] =
        basePhosphorus * proteinFactor * (weightKg / 70).clamp(0.95, 1.15);
    targets['Phosphorus'] =
        double.parse(targets['Phosphorus']!.toStringAsFixed(0));

    // Potassium - precisely based on weight and height
    // Taller and heavier individuals need more potassium
    double baseVal = 2000;
    double weightFactor = weightKg * 20; // 20mg per kg
    double heightFactor = (heightCm - 170) * 10; // 10mg per cm over/under 170cm
    targets['Potassium'] = baseVal + weightFactor + heightFactor;
    targets['Potassium'] =
        double.parse(targets['Potassium']!.toStringAsFixed(0));

    // Selenium - adjust based on weight
    double baseSelenium = 55; // mcg
    targets['Selenium'] = baseSelenium * (weightKg / 70).clamp(0.95, 1.2);
    targets['Selenium'] = double.parse(targets['Selenium']!.toStringAsFixed(0));

    // Sodium - adjust based on weight, height, and calculated calories
    double baseSodium = 2300; // mg
    // Active individuals and those with higher caloric needs may need more sodium
    double calorieAdjustment = (calculatedCalories / 2000).clamp(0.9, 1.3);
    targets['Sodium'] =
        baseSodium * calorieAdjustment * (weightKg / 70).clamp(0.95, 1.15);
    targets['Sodium'] = double.parse(targets['Sodium']!.toStringAsFixed(0));

    // Zinc - adjust based on weight, gender, and protein intake
    double baseZinc = gender == 'Female' ? 8 : 11; // mg
    // Higher protein diets require more zinc
    double zincProteinFactor = (proteinGrams / 70).clamp(1.0, 1.15);
    targets['Zinc'] =
        baseZinc * zincProteinFactor * (weightKg / 70).clamp(0.95, 1.15);
    targets['Zinc'] = double.parse(targets['Zinc']!.toStringAsFixed(1));

    return targets;
  }

  // Calculate other nutrient targets based on user profile and calculated calories
  Map<String, double> _calculateOtherNutrientTargets(String gender, int age,
      double weightKg, int heightCm, int dailyCalories) {
    Map<String, double> targets = {};

    // Calculate BMI for adjustments
    double bmi = weightKg / ((heightCm / 100) * (heightCm / 100));

    // Fiber - based on calorie intake (14g per 1000 calories)
    targets['Fiber'] = (dailyCalories / 1000) * 14;
    targets['Fiber'] = double.parse(targets['Fiber']!.toStringAsFixed(1));

    // Cholesterol - personalized based on caloric intake, weight and BMI
    // Base value of 300mg is standard dietary recommendation
    double baseChol = 300; // mg

    // For very active individuals or those with higher muscle mass (lower BMI but higher weight)
    // may need slightly higher cholesterol intake
    double cholFactor = 1.0;

    // Adjust based on BMI
    if (bmi < 25) {
      // Normal or underweight - adjust based on caloric needs
      cholFactor = (dailyCalories / 2000).clamp(0.9, 1.2);
    } else if (bmi >= 25 && bmi < 30) {
      // Overweight - keep closer to baseline
      cholFactor = (dailyCalories / 2200).clamp(0.85, 1.1);
    } else {
      // Obese - reduce slightly to account for health risks
      cholFactor = (dailyCalories / 2400).clamp(0.8, 1.0);
    }

    // Apply weight factor (larger people will have higher cholesterol needs)
    double weightFactor = (weightKg / 70).clamp(0.9, 1.15);

    // Calculate final cholesterol target
    targets['Cholesterol'] = baseChol * cholFactor * weightFactor;
    targets['Cholesterol'] =
        double.parse(targets['Cholesterol']!.toStringAsFixed(0));

    // Omega-3 - based on weight and health goals
    double omega3Base = 1500; // mg
    if (widget.gymGoal == "Build Muscle" || widget.gymGoal == "Gain Strength") {
      omega3Base += 300; // More for muscle building
    }
    // Adjust for weight
    targets['Omega3'] = omega3Base * (weightKg / 70);
    targets['Omega3'] = double.parse(targets['Omega3']!.toStringAsFixed(0));

    // Omega-6 - based on calorie intake
    targets['Omega6'] =
        (dailyCalories * 0.05) / 9; // 5% of calories from omega-6
    targets['Omega6'] = double.parse(targets['Omega6']!.toStringAsFixed(1));

    // Saturated fat - based on calorie intake (less than 10% of calories)
    targets['Saturated_fat'] = (dailyCalories * 0.1) / 9;
    targets['Saturated_fat'] =
        double.parse(targets['Saturated_fat']!.toStringAsFixed(1));

    // Protein - already calculated in main calculation logic
    targets['Protein'] = proteinGrams.toDouble();

    // Fat - already calculated in main calculation logic
    targets['Fat'] = fatGrams.toDouble();

    // Carbs - already calculated in main calculation logic
    targets['Carbs'] = carbGrams.toDouble();

    return targets;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // Show loading indicator while calculations are being performed
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Calculating your nutrition plan...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

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
                      const Text(
                        'Your Personalized\nNutrition Plan',
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
                        'Just a glimpse of what\'s coming.',
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

          // Nutrition Plan Card
          Positioned(
            top: MediaQuery.of(context).size.height * 0.37,
            left: 32,
            right: 32,
            child: Container(
              height: 220,
              padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Calorie stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Deficit
                      Column(
                        children: [
                          Text(
                            '-$tdee',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          Text(
                            'Deficit',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),

                      // Circular progress
                      Container(
                        width: 130,
                        height: 130,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Circle image
                            Transform.translate(
                              offset: Offset(0, -3.9),
                              child: Image.asset(
                                'assets/images/circle.png',
                                width: 130,
                                height: 130,
                                fit: BoxFit.contain,
                              ),
                            ),

                            // Remaining calories text
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$calculatedCalories',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                Text(
                                  'Remaining',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Burned
                      Column(
                        children: [
                          Text(
                            '0',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          Text(
                            'Burned',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 5),

                  // Macronutrient progress bars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Protein
                      Column(
                        children: [
                          Text(
                            'Protein',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            width: 80,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Color(0xFFEEEEEE),
                            ),
                            child: FractionallySizedBox(
                              widthFactor: 0,
                              alignment: Alignment.centerLeft,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Color(0xFFD7C1FF),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '0 / $proteinGrams g',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),

                      // Fat
                      Column(
                        children: [
                          Text(
                            'Fat',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            width: 80,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Color(0xFFEEEEEE),
                            ),
                            child: FractionallySizedBox(
                              widthFactor: 0,
                              alignment: Alignment.centerLeft,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Color(0xFFFFD8B1),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '0 / $fatGrams g',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),

                      // Carbs
                      Column(
                        children: [
                          Text(
                            'Carbs',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            width: 80,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Color(0xFFEEEEEE),
                            ),
                            child: FractionallySizedBox(
                              widthFactor: 0,
                              alignment: Alignment.centerLeft,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Color(0xFFB1EFD8),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '0 / $carbGrams g',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // White box at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.of(context).size.height * 0.153887,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.zero,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ComfortScreen(
                        isMetric: widget.isMetric,
                        initialWeight: widget.initialWeight,
                        dreamWeight: widget.dreamWeight,
                        isGaining: widget.isGaining,
                        speedValue: widget.speedValue,
                        isMaintaining: widget.speedValue == 0,
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
    );
  }

  Widget _buildMacroBar(String label, int current, int total, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontFamily: '.SF Pro Display',
              ),
            ),
            Text(
              '$current/$total g',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontFamily: '.SF Pro Display',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: current / total,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper method for the numbers
  Widget _buildNumber(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            fontFamily: '.SF Pro Display',
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontFamily: '.SF Pro Display',
          ),
        ),
      ],
    );
  }

  int calculateTDEE({
    required String gender,
    required int weightKg,
    required int heightCm,
    required int userAge,
  }) {
    // BMR using Mifflin-St Jeor Equation
    double bmr;

    // Print debug info about which gender is being used
    print('**CRITICAL DEBUG** - Using gender for BMR calculation: "$gender"');

    if (gender == 'Female') {
      print('Using FEMALE BMR formula');
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * userAge) - 161;
    } else if (gender == 'Male') {
      print('Using MALE BMR formula');
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * userAge) + 5;
    } else {
      // Default to average of male and female for "Other"
      print('Using OTHER/NEUTRAL BMR formula (average of male/female)');
      double maleBmr = (10 * weightKg) + (6.25 * heightCm) - (5 * userAge) + 5;
      double femaleBmr =
          (10 * weightKg) + (6.25 * heightCm) - (5 * userAge) - 161;
      bmr = (maleBmr + femaleBmr) / 2;
    }

    // Apply activity multiplier (1.2 for sedentary - little/no exercise)
    final tdee = bmr * 1.2;
    print('BMR calculated: $bmr, TDEE with multiplier: $tdee');

    return tdee.round();
  }
}

class CalorieArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    final paint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawArc(
      rect,
      -3.14,
      3.14,
      false,
      paint,
    );

    final progressPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawArc(
      rect,
      -3.14,
      2.1,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
