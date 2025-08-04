import 'package:flutter/material.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/questions/gender_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BasicInfoScreen extends StatefulWidget {
  const BasicInfoScreen({super.key});

  @override
  State<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime(DateTime.now().year - 25, 1, 1); // Default to 25 years ago
  
  // List of years, months, and days for the pickers
  final List<int> years = List.generate(100, (index) => DateTime.now().year - index);
  final List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June', 
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  final List<int> days = List.generate(31, (index) => index + 1);
  
  int selectedYearIndex = 25; // Default to 25 years ago
  int selectedMonthIndex = 0; // January
  int selectedDayIndex = 0; // 1st
  
  // Save birth date to SharedPreferences
  Future<void> _saveBirthDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Adjust day if needed for the selected month
      int maxDays = _getDaysInMonth(selectedMonthIndex + 1, years[selectedYearIndex]);
      int adjustedDay = (selectedDayIndex + 1) > maxDays ? maxDays : (selectedDayIndex + 1);
      
      // Create birth date
      final birthDate = DateTime(
        years[selectedYearIndex],
        selectedMonthIndex + 1,
        adjustedDay,
      );
      
      // Calculate age
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month || 
         (now.month == birthDate.month && now.day < birthDate.day)) {
        age--; // Adjust age if birthday hasn't occurred yet this year
      }
      
      // Save birth date as ISO string
      await prefs.setString('birth_date', birthDate.toIso8601String());
      // Also save calculated age for convenience
      await prefs.setInt('user_age', age);

      // Verify it was saved correctly
      final savedBirthDate = prefs.getString('birth_date');
      final savedAge = prefs.getInt('user_age');
      print('Birth date saved to SharedPreferences:');
      print('Key: birth_date, Value: $savedBirthDate');
      print('Key: user_age, Value: $savedAge');

      // Print all keys for debugging
      print('All SharedPreferences keys after saving:');
      print(prefs.getKeys());
    } catch (e) {
      print('Error saving birth date: $e');
    }
  }
  
  // Helper function to get the number of days in a month
  int _getDaysInMonth(int month, int year) {
    if (month == 2) {
      // February - check for leap year
      if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
        return 29; // Leap year
      } else {
        return 28; // Non-leap year
      }
    } else if ([4, 6, 9, 11].contains(month)) {
      return 30; // April, June, September, November
    } else {
      return 31; // All other months
    }
  }
  
  // Update days based on selected month and year
  void _updateDays() {
    int maxDays = _getDaysInMonth(selectedMonthIndex + 1, years[selectedYearIndex]);
    setState(() {
      days.clear();
      days.addAll(List.generate(maxDays, (index) => index + 1));
      // If selected day is now invalid, adjust it
      if (selectedDayIndex >= maxDays) {
        selectedDayIndex = maxDays - 1;
      }
    });
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
                            value: 0.3,
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
                        'When were you born?',
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
                        'This helps us calculate your calorie needs.',
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

          // Date Pickers
          Positioned(
            top: MediaQuery.of(context).size.height * 0.37,
            left: 0,
            right: 0,
            height: 250,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Month picker
                SizedBox(
                  width: 120,
                  child: ListWheelScrollView.useDelegate(
                    itemExtent: 45,
                    perspective: 0.005,
                    diameterRatio: 1.5,
                    physics: FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedMonthIndex = index;
                        _updateDays();
                      });
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: months.length,
                      builder: (context, index) {
                        final isSelected = index == selectedMonthIndex;
                        return Center(
                          child: Text(
                            months[index],
                            style: TextStyle(
                              fontSize: isSelected ? 20 : 16,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.black : Colors.grey[400],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // Day picker
                SizedBox(
                  width: 70,
                  child: ListWheelScrollView.useDelegate(
                    itemExtent: 45,
                    perspective: 0.005,
                    diameterRatio: 1.5,
                    physics: FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedDayIndex = index;
                      });
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: days.length,
                      builder: (context, index) {
                        final isSelected = index == selectedDayIndex;
                        return Center(
                          child: Text(
                            '${days[index]}',
                            style: TextStyle(
                              fontSize: isSelected ? 20 : 16,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.black : Colors.grey[400],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // Year picker
                SizedBox(
                  width: 80,
                  child: ListWheelScrollView.useDelegate(
                    itemExtent: 45,
                    perspective: 0.005,
                    diameterRatio: 1.5,
                    physics: FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedYearIndex = index;
                        _updateDays();
                      });
                    },
                    controller: FixedExtentScrollController(
                      initialItem: selectedYearIndex,
                    ),
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: years.length,
                      builder: (context, index) {
                        final isSelected = index == selectedYearIndex;
                        return Center(
                          child: Text(
                            '${years[index]}',
                            style: TextStyle(
                              fontSize: isSelected ? 20 : 16,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.black : Colors.grey[400],
                            ),
                          ),
                        );
                      },
                    ),
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

          // Continue button
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
                  await _saveBirthDate();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const GenderScreen(),
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
