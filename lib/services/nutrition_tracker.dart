import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NutritionTracker {
  // Singleton pattern
  static final NutritionTracker _instance = NutritionTracker._internal();
  factory NutritionTracker() => _instance;
  NutritionTracker._internal();

  // Nutrient categories with their measurement units
  static final Map<String, Map<String, String>> nutrientUnits = {
    'vitamins': {
      'vitamin_a': 'mcg',
      'vitamin_c': 'mg',
      'vitamin_d': 'mcg',
      'vitamin_e': 'mg',
      'vitamin_k': 'mg',
      'vitamin_b1': 'mg',
      'vitamin_b2': 'mg',
      'vitamin_b3': 'mg',
      'vitamin_b5': 'mg',
      'vitamin_b6': 'mg',
      'vitamin_b7': 'mcg',
      'vitamin_b9': 'mcg',
      'vitamin_b12': 'mcg',
    },
    'minerals': {
      'calcium': 'mg',
      'chloride': 'mg',
      'chromium': 'mcg',
      'copper': 'mcg',
      'fluoride': 'mg',
      'iodine': 'mcg',
      'iron': 'mg',
      'magnesium': 'mg',
      'manganese': 'mg',
      'molybdenum': 'mcg',
      'phosphorus': 'mg',
      'potassium': 'mg',
      'selenium': 'mcg',
      'sodium': 'mg',
      'zinc': 'mg',
    },
    'others': {
      'fiber': 'g',
      'cholesterol': 'mg',
      'omega3': 'mg',
      'omega6': 'g',
      'sugar': 'g',
      'saturated_fat': 'g',
    }
  };

  // Nutrient friendly names for display
  static final Map<String, String> friendlyNames = {
    // Vitamins
    'vitamin_a': 'Vitamin A',
    'vitamin_c': 'Vitamin C',
    'vitamin_d': 'Vitamin D',
    'vitamin_e': 'Vitamin E',
    'vitamin_k': 'Vitamin K',
    'vitamin_b1': 'Vitamin B1',
    'vitamin_b2': 'Vitamin B2',
    'vitamin_b3': 'Vitamin B3',
    'vitamin_b5': 'Vitamin B5',
    'vitamin_b6': 'Vitamin B6',
    'vitamin_b7': 'Vitamin B7',
    'vitamin_b9': 'Vitamin B9',
    'vitamin_b12': 'Vitamin B12',

    // Minerals
    'calcium': 'Calcium',
    'chloride': 'Chloride',
    'chromium': 'Chromium',
    'copper': 'Copper',
    'fluoride': 'Fluoride',
    'iodine': 'Iodine',
    'iron': 'Iron',
    'magnesium': 'Magnesium',
    'manganese': 'Manganese',
    'molybdenum': 'Molybdenum',
    'phosphorus': 'Phosphorus',
    'potassium': 'Potassium',
    'selenium': 'Selenium',
    'sodium': 'Sodium',
    'zinc': 'Zinc',

    // Others
    'fiber': 'Fiber',
    'cholesterol': 'Cholesterol',
    'omega3': 'Omega-3',
    'omega6': 'Omega-6',
    'sugar': 'Sugar',
    'saturated_fat': 'Saturated Fats',
  };

  // Get stored RDI value for a nutrient
  Future<int> getNutrientRDI(String nutrientKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('rdi_$nutrientKey') ?? 0;
  }

  // Get consumed value for a nutrient for today
  Future<int> getNutrientConsumed(String nutrientKey) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayKey();
    return prefs.getInt('consumed_${today}_$nutrientKey') ?? 0;
  }

  // Update consumed value for a nutrient
  Future<void> updateNutrientConsumed(String nutrientKey, int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayKey();
    final currentAmount = prefs.getInt('consumed_${today}_$nutrientKey') ?? 0;
    await prefs.setInt(
        'consumed_${today}_$nutrientKey', currentAmount + amount);
  }

  // Update all nutrient values from food analysis data
  Future<void> updateFromFoodAnalysis(Map<String, dynamic> foodData) async {
    try {
      print("Processing nutrition values from food analysis");
      print("Keys in foodData: ${foodData.keys.join(', ')}");
      
      // First, handle main macros if available
      if (foodData.containsKey('calories')) {
        // Ensure we're storing as an integer
        int calories = _parseIntValue(foodData['calories']);
        if (calories > 0) {
          print("Found calories: $calories");
        }
      }
      
      if (foodData.containsKey('protein')) {
        int protein = _parseIntValue(foodData['protein']);
        if (protein > 0) {
          print("Found protein: $protein g");
        }
      }
      
      if (foodData.containsKey('fat')) {
        int fat = _parseIntValue(foodData['fat']);
        if (fat > 0) {
          print("Found fat: $fat g");
        }
      }
      
      if (foodData.containsKey('carbs')) {
        int carbs = _parseIntValue(foodData['carbs']);
        if (carbs > 0) {
          print("Found carbs: $carbs g");
        }
      }

      // Process vitamins
      if (foodData.containsKey('vitamins') && foodData['vitamins'] is Map) {
        Map<String, dynamic> vitamins = Map<String, dynamic>.from(foodData['vitamins']);
        print("Processing ${vitamins.length} vitamins");
        await _processNutrientCategory('vitamins', vitamins);
      }

      // Process minerals
      if (foodData.containsKey('minerals') && foodData['minerals'] is Map) {
        Map<String, dynamic> minerals = Map<String, dynamic>.from(foodData['minerals']);
        print("Processing ${minerals.length} minerals");
        await _processNutrientCategory('minerals', minerals);
      }

      // Process other nutrients from various possible locations
      if (foodData.containsKey('other_nutrients') && foodData['other_nutrients'] is Map) {
        Map<String, dynamic> otherNutrients = Map<String, dynamic>.from(foodData['other_nutrients']);
        print("Processing ${otherNutrients.length} other nutrients from other_nutrients field");
        await _processNutrientCategory('others', otherNutrients);
      }
      
      // Look for nutrients directly in the root of the object
      // Process nutrients that might be in various places
      if (foodData.containsKey('nutrition_other') && foodData['nutrition_other'] is Map) {
        Map<String, dynamic> nutritionOther = Map<String, dynamic>.from(foodData['nutrition_other']);
        print("Processing ${nutritionOther.length} items from nutrition_other field");
        await _processNutrientCategory('others', nutritionOther);
      }

      // Look for common nutrients that might be at the root level
      final otherNutrients = {
        'fiber': foodData['fiber'],
        'cholesterol': foodData['cholesterol'],
        'sugar': foodData['sugar'],
        'saturated_fat': foodData['saturated_fat'],
        'omega3': foodData['omega3'] ?? foodData['omega_3'],
        'omega6': foodData['omega6'] ?? foodData['omega_6'],
      };

      // Filter out null values and process
      final filteredOtherNutrients = Map<String, dynamic>.fromEntries(
          otherNutrients.entries.where((entry) => entry.value != null));

      if (filteredOtherNutrients.isNotEmpty) {
        print("Processing ${filteredOtherNutrients.length} nutrients from root level");
        await _processNutrientCategory('others', filteredOtherNutrients);
      }

      print('Updated nutrient consumption from food analysis');
    } catch (e) {
      print('Error updating nutrients from food analysis: $e');
    }
  }

  // Helper method to process a category of nutrients
  Future<void> _processNutrientCategory(
      String category, Map<String, dynamic> nutrients) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayKey();
    final categoryUnits = nutrientUnits[category] ?? {};

    print("Processing nutrient category: $category");
    
    for (final entry in nutrients.entries) {
      final originalKey = entry.key;
      final normalizedKey = _normalizeNutrientKey(originalKey);
      
      // Skip empty or null values
      if (entry.value == null) continue;
      
      // Convert the value to an integer (amount in the appropriate unit)
      // Always round to nearest whole number - no decimals
      final int nutrientValue = _parseIntValue(entry.value);
      
      // Only update if the value is greater than 0
      if (nutrientValue > 0) {
        final String storageKey = 'consumed_${today}_$normalizedKey';
        final currentValue = prefs.getInt(storageKey) ?? 0;
        final newValue = currentValue + nutrientValue;
        
        await prefs.setInt(storageKey, newValue);
        print("  Saved $normalizedKey: $newValue (added $nutrientValue to existing $currentValue)");
      }
    }
  }

  // Helper method to normalize nutrient keys to our standard format
  String _normalizeNutrientKey(String key) {
    if (key == null || key.isEmpty) return 'unknown';
    
    final lowerKey = key.toLowerCase();

    // Handle vitamin naming variations
    if (lowerKey == 'a' || lowerKey == 'vit a' || lowerKey == 'vit_a') {
      return 'vitamin_a';
    } else if (lowerKey == 'c' || lowerKey == 'vit c' || lowerKey == 'vit_c') {
      return 'vitamin_c';
    } else if (lowerKey == 'd' || lowerKey == 'vit d' || lowerKey == 'vit_d') {
      return 'vitamin_d';
    } else if (lowerKey == 'e' || lowerKey == 'vit e' || lowerKey == 'vit_e') {
      return 'vitamin_e';
    } else if (lowerKey == 'k' || lowerKey == 'vit k' || lowerKey == 'vit_k') {
      return 'vitamin_k';
    }
    // Handle B vitamins
    else if (lowerKey == 'b1' ||
        lowerKey == 'thiamin' ||
        lowerKey == 'thiamine') {
      return 'vitamin_b1';
    } else if (lowerKey == 'b2' || lowerKey == 'riboflavin') {
      return 'vitamin_b2';
    } else if (lowerKey == 'b3' || lowerKey == 'niacin') {
      return 'vitamin_b3';
    } else if (lowerKey == 'b5' || lowerKey == 'pantothenic acid') {
      return 'vitamin_b5';
    } else if (lowerKey == 'b6' || lowerKey == 'pyridoxine') {
      return 'vitamin_b6';
    } else if (lowerKey == 'b7' || lowerKey == 'biotin') {
      return 'vitamin_b7';
    } else if (lowerKey == 'b9' ||
        lowerKey == 'folate' ||
        lowerKey == 'folic acid') {
      return 'vitamin_b9';
    } else if (lowerKey == 'b12' || lowerKey == 'cobalamin') {
      return 'vitamin_b12';
    }

    // Handle other nutrients
    else if (lowerKey == 'dietary fiber' || lowerKey == 'dietary_fiber' || lowerKey == 'dietary-fiber') {
      return 'fiber';
    } else if (lowerKey == 'omega-3' || lowerKey == 'omega_3') {
      return 'omega3';
    } else if (lowerKey == 'omega-6' || lowerKey == 'omega_6') {
      return 'omega6';
    } else if (lowerKey.contains('saturated') && lowerKey.contains('fat')) {
      return 'saturated_fat';
    }

    // Convert hyphens to underscores for consistent storage
    return lowerKey.replaceAll('-', '_');
  }

  // Helper method to extract numeric value and ensure it's an integer
  int _parseIntValue(dynamic value) {
    if (value == null) return 0;
    
    // For numeric values, round to nearest integer
    if (value is num) {
      return value.round();  // Always round to nearest whole number
    } 
    // For strings, extract any numeric part
    else if (value is String) {
      // Extract numeric part from the string (e.g., "15mg" -> 15)
      final match = RegExp(r'(\d+\.?\d*)').firstMatch(value);
      if (match != null && match.group(1) != null) {
        double? parsedValue = double.tryParse(match.group(1)!);
        if (parsedValue != null) {
          return parsedValue.round();  // Round to nearest whole number
        }
      }
    }
    return 0;
  }

  // Get today's date as a string key (format: YYYY-MM-DD)
  String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // Reset today's consumed nutrients (for testing purposes)
  Future<void> resetTodayConsumption() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayKey();

    // Get all keys from SharedPreferences
    final keys = prefs.getKeys();

    // Filter keys that start with today's consumption prefix
    final todayKeys =
        keys.where((key) => key.startsWith('consumed_${today}_')).toList();

    // Remove all today's consumption values
    for (final key in todayKeys) {
      await prefs.remove(key);
    }

    print('Reset today\'s nutrient consumption');
  }
}
 