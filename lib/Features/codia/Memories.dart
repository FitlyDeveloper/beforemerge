import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<StatefulWidget> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background4.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                // Header with back button and title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 29)
                      .copyWith(top: 16, bottom: 8.5),
              child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                      // Back button (styled like signin.dart - simple IconButton)
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.black, size: 24),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),

                      // Memories title (sized like 'Today' text but centered position)
                    Text(
                        'Memories',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SF Pro Display',
                          color: Colors.black,
                          decoration: TextDecoration.none,
                        ),
                      ),

                      // Empty space to balance the header (same width as back button)
                      SizedBox(width: 24),
                  ],
                ),
              ),

                // Slim gray divider line
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 29),
                  height: 0.5,
                  color: Color(0xFFBDBDBD),
                ),

                // January 2025 Calendar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 29).copyWith(top: 20, bottom: 8),
                        child: Container(
                    padding: EdgeInsets.all(20),
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
                children: [
                        // Month header
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            'January 2025',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                          ),
                        ),
                      ),

                        // Weekday headers
                  Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                            _buildWeekdayHeader('Mon'),
                            _buildWeekdayHeader('Tue'),
                            _buildWeekdayHeader('Wed'),
                            _buildWeekdayHeader('Thu'),
                            _buildWeekdayHeader('Fri'),
                            _buildWeekdayHeader('Sat'),
                            _buildWeekdayHeader('Sun'),
                          ],
                        ),

                        SizedBox(height: 15),

                        // Calendar days
                        _buildCalendarGrid(
                            31, 15), // January has 31 days, highlight day 15
                      ],
                    ),
                  ),
                ),

                // December 2024 Calendar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 29).copyWith(top: 8, bottom: 8),
                        child: Container(
                    padding: EdgeInsets.all(20),
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
                children: [
                        // Month header
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            'December 2024',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                          ),
                        ),
                      ),

                        // Weekday headers
                  Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                            _buildWeekdayHeader('Mon'),
                            _buildWeekdayHeader('Tue'),
                            _buildWeekdayHeader('Wed'),
                            _buildWeekdayHeader('Thu'),
                            _buildWeekdayHeader('Fri'),
                            _buildWeekdayHeader('Sat'),
                            _buildWeekdayHeader('Sun'),
                          ],
                        ),

                        SizedBox(height: 15),

                        // Calendar days
                        _buildCalendarGrid(
                            31, null), // December has 31 days, no highlight
                      ],
                    ),
                  ),
                ),

                // Add space at the bottom
                SizedBox(height: 90),
              ],
            ),
                          ),
                        ),
                      ),
    );
  }

  Widget _buildWeekdayHeader(String day) {
    return Text(
      day,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
  }

  Widget _buildCalendarGrid(int daysInMonth, int? highlightDay) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: daysInMonth,
      itemBuilder: (context, index) {
        final day = index + 1;
        return _buildCalendarDay(day, isHighlighted: day == highlightDay);
      },
    );
  }

  Widget _buildCalendarDay(int day, {bool isHighlighted = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: isHighlighted
            ? Border.all(color: Color(0xFFDADADA), width: 1.875)
            : null,
        shape: BoxShape.circle,
      ),
      child: Center(
                          child: Text(
          day.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
