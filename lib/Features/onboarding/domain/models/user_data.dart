class UserData {
  final String id;
  final int age;
  final String gender;
  final double height;
  final double weight;
  final double targetWeight;
  final String activityLevel;
  final List<String> fitnessGoals;
  final String workoutExperience;
  final Map<String, dynamic> lifestyle;
  final Map<String, dynamic> dietPreferences;
  
  UserData({
    required this.id,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.targetWeight,
    required this.activityLevel,
    required this.fitnessGoals,
    required this.workoutExperience,
    required this.lifestyle,
    required this.dietPreferences,
  });

  // Constructor
  // fromJson and toJson methods for Firebase
} 