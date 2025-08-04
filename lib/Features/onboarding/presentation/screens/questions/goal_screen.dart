import 'package:shared_preferences/shared_preferences.dart';

class GoalScreen extends StatefulWidget {
  // ... (existing code)
}

class _GoalScreenState extends State<GoalScreen> {
  // ... (existing code)

  // Save goal to SharedPreferences
  Future<void> _saveGoal() async {
    if (_selectedGoal != null) {
      try {
        final prefs = await SharedPreferences.getInstance();

        // DEBUG: Show all current keys
        print("\n===== BEFORE SAVING GOAL =====");
        print("All SharedPreferences keys: ${prefs.getKeys()}");

        // Save data - log the exact keys being used
        print("\n===== SAVING GOAL TO THESE KEYS =====");
        String goalValue = _selectedGoal == GoalOption.maintain
            ? 'maintain'
            : _selectedGoal == GoalOption.lose
                ? 'lose'
                : 'gain';
        print("Goal key: 'goal', Value: $goalValue");

        // Convert enum to string
        String goal = _selectedGoal == GoalOption.maintain
            ? 'maintain'
            : _selectedGoal == GoalOption.lose
                ? 'lose'
                : 'gain';

        await prefs.setString('goal', goal);

        // DEBUG: Also save as isGaining flag for compatibility
        bool isGaining = _selectedGoal == GoalOption.gain;
        await prefs.setBool('isGaining', isGaining);
        print("Also saving as isGaining key: Value: $isGaining");

        // DEBUG: Verify data was saved correctly
        print("\n===== AFTER SAVING GOAL =====");
        print("All SharedPreferences keys: ${prefs.getKeys()}");
        String? savedGoal = prefs.getString('goal');
        bool? savedIsGaining = prefs.getBool('isGaining');
        print("Saved goal: $savedGoal");
        print("Saved isGaining: $savedIsGaining");
      } catch (e) {
        print('Error saving goal: $e');
      }
    }
  }

  // ... (rest of the existing code)
}
 