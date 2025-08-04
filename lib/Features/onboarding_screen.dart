import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/questions/gender_screen.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/box_screen.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/sign_screen.dart';
import 'package:fitness_app/core/widgets/responsive_scaffold.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int index = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: RawKeyboardListener(
          focusNode: FocusNode(),
          autofocus: true,
          onKey: (event) {
            if (event is RawKeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
                  index < 4) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
                  index > 0) {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            }
          },
          child: Stack(
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
              PageView.builder(
                controller: _pageController,
                itemCount: 5,
                onPageChanged: (value) {
                  setState(() {
                    index = value;
                  });
                },
                itemBuilder: (context, pageIndex) {
                  return Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: MediaQuery.of(context).size.height * 0.48,
                        child: pageIndex == 0
                            ? Container(
                                color: Colors.black,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return ClipRect(
                                      child: Transform.scale(
                                        scale: 1.3, // 30% zoom
                                        child: Center(
                                          child: Image.asset(
                                            'assets/images/transformation2.jpg',
                                            fit: BoxFit.cover,
                                            width: constraints.maxWidth,
                                            height: constraints.maxHeight,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Container(
                                color: Colors.black,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Image.asset(
                                      pageIndex == 1
                                          ? 'assets/images/foodstart.png'
                                          : pageIndex == 2
                                              ? 'assets/images/tracker.png'
                                              : pageIndex == 3
                                                  ? 'assets/images/exercise.png'
                                                  : 'assets/images/socialapp.png',
                                      fit: BoxFit.cover,
                                      width: constraints.maxWidth,
                                      height: constraints.maxHeight,
                                    );
                                  },
                                ),
                              ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.45,
                        left: -1,
                        right: -1,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white,
                                Colors.grey[100]!.withOpacity(0.9),
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(31),
                              topRight: Radius.circular(31),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              24,
                              24,
                              24,
                              20,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  pageIndex == 1
                                      ? 'Track Your Meals\nin Seconds'
                                      : pageIndex == 2
                                          ? 'Dynamic Calorie Tracking'
                                          : pageIndex == 3
                                              ? 'Track All Your Workouts\nin One Place'
                                              : pageIndex == 4
                                                  ? 'Track Friends &\nShare Your Journey'
                                                  : 'Achieving Your Dream Body\nMade Easy',
                                  style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w700,
                                    height: 1.21,
                                    fontFamily: '.SF Pro Display',
                                    letterSpacing: -0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01),
                                Text(
                                  pageIndex == 1
                                      ? 'Snap a photo and AI calculates your calories, protein, fats, and carbs instantly'
                                      : pageIndex == 2
                                          ? 'For the first time ever, your calorie limit updates live as you move'
                                          : pageIndex == 3
                                              ? 'No more switching apps—track every workout, run, and cardio in one app'
                                              : pageIndex == 4
                                                  ? "See your friends' workouts, meals, progress and get fit together"
                                                  : 'Track your nutrition, workouts, and progress all in one place',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    height: 1.3,
                                    fontFamily: '.SF Pro Display',
                                    color: Colors.grey[700],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              // Pagination dots - moved closer to white box
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.1648,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return GestureDetector(
                      onTap: () {
                        // Navigate to the selected page when dot is tapped
                        _pageController.animateToPage(
                          i,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == index
                              ? Colors.black
                              : const Color(0xFFDADADA),
                        ),
                      ),
                    );
                  }),
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Start Now',
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
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Second Screen',
          style: TextStyle(
            fontSize: 24,
            fontFamily: '.SF Pro Display',
          ),
        ),
      ),
    );
  }
}
