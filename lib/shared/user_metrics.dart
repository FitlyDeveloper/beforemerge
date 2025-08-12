import 'package:shared_preferences/shared_preferences.dart';

class UserMetrics {
  final double? weightKg;
  final double? heightCm;
  final int? ageYears;
  UserMetrics({this.weightKg, this.heightCm, this.ageYears});
}

Future<UserMetrics> loadUserMetrics() async {
  final prefs = await SharedPreferences.getInstance();
  
  // Debug: show all available keys
  final allKeys = prefs.getKeys().toList();
  print('[UserMetrics] Available keys: ${allKeys.join(', ')}');

  // Weight: use exactly the same keys and logic as codia_page.dart
  double? weight;
  bool weightFound = false;
  final weightKeys = ['user_weight_kg', 'weightInKg', 'weight_kg', 'weight'];
  
  print('[UserMetrics] Checking weight keys: $weightKeys');
  
  // First try to load weight as double from any key
  for (final key in weightKeys) {
    try {
      if (prefs.containsKey(key) && !weightFound) {
        final value = prefs.getDouble(key);
        if (value != null && value > 0) {
          weight = value;
          weightFound = true;
          print('[UserMetrics] Found weight as double in key: $key = $weight kg');
          break;
        }
      }
    } catch (e) {
      print('[UserMetrics] Error reading weight from $key as double: $e');
    }
  }

  // If weight not found as double, try integers
  if (!weightFound) {
    for (final key in weightKeys) {
      try {
        if (prefs.containsKey(key)) {
          final value = prefs.getInt(key);
          if (value != null && value > 0) {
            weight = value.toDouble();
            weightFound = true;
            print('[UserMetrics] Found weight as int in key: $key = $weight kg');
            break;
          }
        }
      } catch (e) {
        print('[UserMetrics] Error reading weight from $key as int: $e');
      }
    }
  }

  // Height: use exactly the same keys and logic as codia_page.dart
  double? height;
  bool heightFound = false;
  final heightKeys = ['user_height_cm', 'heightInCm', 'height_cm', 'height'];

  print('[UserMetrics] Checking height keys: $heightKeys');

  // First try to retrieve height as an INT from specific keys (in priority order)
  for (final key in ['user_height_cm', 'height']) {
    try {
      if (prefs.containsKey(key) && !heightFound) {
        final value = prefs.getInt(key);
        if (value != null && value > 0) {
          height = value.toDouble();
          heightFound = true;
          print('[UserMetrics] Found height as INT in key: $key = $height cm');
          break;
        }
      }
    } catch (e) {
      print('[UserMetrics] Error reading height from $key as int: $e');
    }
  }

  // If height not found as int in priority keys, try as DOUBLE from any key
  if (!heightFound) {
    for (final key in heightKeys) {
      try {
        if (prefs.containsKey(key)) {
          final value = prefs.getDouble(key);
          if (value != null && value > 0) {
            height = value;
            heightFound = true;
            print('[UserMetrics] Found height as DOUBLE in key: $key = $height cm');
            break;
          }
        }
      } catch (e) {
        print('[UserMetrics] Error reading height from $key as double: $e');
      }
    }
  }

  // Last resort: check all remaining keys as INT if we still haven't found height
  if (!heightFound) {
    for (final key in heightKeys) {
      try {
        if (prefs.containsKey(key)) {
          final value = prefs.getInt(key);
          if (value != null && value > 0) {
            height = value.toDouble();
            heightFound = true;
            print('[UserMetrics] Found height as INT (last resort) in key: $key = $height cm');
            break;
          }
        }
      } catch (e) {
        print('[UserMetrics] Error reading height from $key as int (last resort): $e');
      }
    }
  }

  // Age: use exactly the same logic as codia_page.dart
  int? age;
  List<String> birthDateKeys = ['birth_date', 'birthDate', 'user_birth_date', 'dob'];
  String? birthDateStr;

  print('[UserMetrics] Checking birth date keys: $birthDateKeys');

  for (String key in birthDateKeys) {
    if (prefs.containsKey(key)) {
      birthDateStr = prefs.getString(key);
      print('[UserMetrics] Found birth date in key: $key = $birthDateStr');
      break;
    }
  }

  if (birthDateStr != null) {
    try {
      DateTime birthDate = DateTime.parse(birthDateStr);
      DateTime today = DateTime.now();
      int a = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        a--;
      }
      if (a > 130) a = 130;
      age = a;
      print('[UserMetrics] Calculated age from birth date: $age');
    } catch (_) {
      print('[UserMetrics] Error parsing birth date: $birthDateStr');
    }
  }
  
  // Fallback to direct age if birth date not found
  if (age == null && prefs.containsKey('user_age')) {
    age = prefs.getInt('user_age');
    print('[UserMetrics] Found age directly: $age');
  }

  // Debug log (keep concise to avoid noise)
  print('[UserMetrics] Final result -> w=$weight, h=$height, a=$age');

  return UserMetrics(weightKg: weight, heightCm: height, ageYears: age);
}


