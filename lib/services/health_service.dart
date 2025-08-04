import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math' as math;

/// A simplified health service that provides mock health data
/// This is used as a fallback when the health package is not available or not working
class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  final _random = math.Random();

  // Request authorization - always returns true for mock
  Future<bool> requestAuthorization() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  // Get step count for today - returns random or cached value
  Future<int> getStepCount() async {
    try {
      // Try to fetch cached data
      final prefs = await SharedPreferences.getInstance();
      final cachedSteps = prefs.getInt('last_steps_count');
      final lastUpdate = prefs.getString('last_steps_update');

      // If we have recent cached data (less than 1 hour old), use it
      if (cachedSteps != null && lastUpdate != null) {
        final lastUpdateTime = DateTime.parse(lastUpdate);
        if (DateTime.now().difference(lastUpdateTime).inHours < 1) {
          return cachedSteps;
        }
      }

      // Generate realistic step count (between 2000 and 8000)
      final steps = 2000 + _random.nextInt(6000);

      // Cache the result
      await prefs.setInt('last_steps_count', steps);
      await prefs.setString(
          'last_steps_update', DateTime.now().toIso8601String());

      return steps;
    } catch (e) {
      debugPrint("Error getting step count: $e");
      // Return a fallback value
      return 4500 + _random.nextInt(1000);
    }
  }

  // Get calories burned today - returns a value proportional to steps
  Future<double> getCaloriesBurned() async {
    try {
      // Get the step count and calculate calories
      final steps = await getStepCount();
      // Average calorie burn is around 0.04 calories per step
      final calories = steps * (0.038 + _random.nextDouble() * 0.01);

      // Cache the result
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('last_calories_burned', calories);
      await prefs.setString(
          'last_calories_update', DateTime.now().toIso8601String());

      return calories;
    } catch (e) {
      debugPrint("Error getting calories burned: $e");
      // Return a fallback value
      return 150.0 + _random.nextDouble() * 50;
    }
  }

  // Get distance walked/run today in kilometers - returns a value proportional to steps
  Future<double> getDistance() async {
    try {
      // Get the step count and calculate distance
      final steps = await getStepCount();
      // Average stride length is around 0.7-0.8 meters (0.0007-0.0008 km per step)
      final distance = steps * (0.0007 + _random.nextDouble() * 0.0002);

      // Cache the result
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('last_distance', distance);
      await prefs.setString(
          'last_distance_update', DateTime.now().toIso8601String());

      return distance;
    } catch (e) {
      debugPrint("Error getting distance: $e");
      // Return a fallback value
      return 3.0 + _random.nextDouble() * 1.5;
    }
  }

  // Get heart rate - returns a random realistic value
  Future<int> getHeartRate() async {
    try {
      // Generate a realistic heart rate (between 60 and 90 at rest)
      final heartRate = 60 + _random.nextInt(30);

      // Cache the result
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_heart_rate', heartRate);
      await prefs.setString('last_hr_update', DateTime.now().toIso8601String());

      return heartRate;
    } catch (e) {
      debugPrint("Error getting heart rate: $e");
      // Return a fallback value
      return 72 + _random.nextInt(10);
    }
  }

  // Get weight in kg - returns a random realistic value or cached
  Future<double> getWeight() async {
    try {
      // Try to fetch cached data first
      final prefs = await SharedPreferences.getInstance();
      final cachedWeight = prefs.getDouble('last_weight');

      if (cachedWeight != null) {
        return cachedWeight;
      }

      // Generate a realistic weight (between 50 and 100 kg)
      final weight = 50.0 + _random.nextDouble() * 50.0;

      // Cache the result
      await prefs.setDouble('last_weight', weight);
      await prefs.setString(
          'last_weight_update', DateTime.now().toIso8601String());

      return weight;
    } catch (e) {
      debugPrint("Error getting weight: $e");
      // Return a fallback value
      return 70.0 + _random.nextDouble() * 10.0;
    }
  }

  // Get height in cm - returns a random realistic value or cached
  Future<double> getHeight() async {
    try {
      // Try to fetch cached data first
      final prefs = await SharedPreferences.getInstance();
      final cachedHeight = prefs.getDouble('last_height');

      if (cachedHeight != null) {
        return cachedHeight;
      }

      // Generate a realistic height (between 150 and 190 cm)
      final height = 150.0 + _random.nextDouble() * 40.0;

      // Cache the result
      await prefs.setDouble('last_height', height);
      await prefs.setString(
          'last_height_update', DateTime.now().toIso8601String());

      return height;
    } catch (e) {
      debugPrint("Error getting height: $e");
      // Return a fallback value
      return 170.0 + _random.nextDouble() * 10.0;
    }
  }
}
