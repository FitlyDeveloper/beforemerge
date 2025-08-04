import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math; // Change this line to import math with alias
import 'package:fitness_app/Features/onboarding/presentation/screens/speed_screen.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/comfort_screen.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/gender_selection_screen.dart';

class WeightGoalCopyScreen extends StatefulWidget {
  final bool isMetric;
  final int initialWeight;
  final String? selectedGoal;
  final String gender;
  final int heightInCm;
  final DateTime birthDate;
  final String? gymGoal;

  const WeightGoalCopyScreen({
    super.key,
    required this.isMetric,
    required this.initialWeight,
    required this.selectedGoal,
    required this.gender,
    required this.heightInCm,
    required this.birthDate,
    this.gymGoal,
  });

  @override
  State<WeightGoalCopyScreen> createState() => _WeightGoalCopyScreenState();
}

class _WeightGoalCopyScreenState extends State<WeightGoalCopyScreen> {
  int? selectedIndex; // Track selected option
  late double currentWeight;
  late double initialWeight; // Add this to store the starting weight
  late final double minWeight;
  late final double maxWeight;
  double _dragAccumulator = 0;

  @override
  void initState() {
    super.initState();
    initialWeight = widget.initialWeight.toDouble();
    currentWeight = initialWeight;
    if (widget.isMetric) {
      minWeight = 0; // Minimum 0 kg
      maxWeight = 350; // Maximum 350 kg
    } else {
      minWeight = 0; // Minimum 0 lb
      maxWeight = 700; // Maximum 700 lb
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: _handleKeyPress,
      child: Scaffold(
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
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        GenderSelectionScreen(
                                  isMetric: widget.isMetric,
                                  initialWeight: widget.initialWeight,
                                  selectedGender: widget.gender,
                                  heightInCm: widget.heightInCm,
                                  birthDate: widget.birthDate,
                                ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 40),
                            child: const LinearProgressIndicator(
                              value: 10 / 13,
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
                          'What\'s your dream weight?',
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
                          'This helps us plan your calorie intake.',
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

            // Add after header content and before bottom elements
            Positioned(
              top: MediaQuery.of(context).size.height * 0.454,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  const Text(
                    'Dream Weight',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: '.SF Pro Display',
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${currentWeight.toInt()} ${widget.isMetric ? 'kg' : 'lb'}',
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                      fontFamily: '.SF Pro Display',
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 7),
                  SizedBox(
                    height: 84,
                    width: MediaQuery.of(context).size.width,
                    child: Listener(
                      onPointerSignal: (pointerSignal) {
                        if (pointerSignal is PointerScrollEvent) {
                          setState(() {
                            double scrollDelta = pointerSignal.scrollDelta.dy;
                            if (scrollDelta > 0 && currentWeight > minWeight) {
                              currentWeight =
                                  math.max(currentWeight - 1, minWeight);
                            } else if (scrollDelta < 0 &&
                                currentWeight < maxWeight) {
                              currentWeight =
                                  math.min(currentWeight + 1, maxWeight);
                            }
                          });
                        }
                      },
                      child: GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          setState(() {
                            _dragAccumulator += details.delta.dx;
                            double tickWidth =
                                MediaQuery.of(context).size.width / 40;

                            if (_dragAccumulator.abs() >= tickWidth) {
                              int change =
                                  (_dragAccumulator ~/ tickWidth).toInt();
                              double newWeight = currentWeight - change;

                              // Enforce limits
                              if (newWeight < minWeight) {
                                newWeight = minWeight;
                              } else if (newWeight > maxWeight) {
                                newWeight = maxWeight;
                              }

                              currentWeight = newWeight;
                              _dragAccumulator = _dragAccumulator % tickWidth;
                            }
                          });
                        },
                        child: Stack(
                          children: [
                            // Ruler
                            CustomPaint(
                              size: Size(
                                  MediaQuery.of(context).size.width + 58, 72),
                              painter: InfiniteRulerPainter(
                                scrollOffset: -(currentWeight - initialWeight) *
                                    (MediaQuery.of(context).size.width / 40),
                                tickSpacing:
                                    MediaQuery.of(context).size.width / 40,
                              ),
                            ),

                            // Lines and highlight
                            Center(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 84,
                                child: Stack(
                                  children: [
                                    // Gray line (initial weight) - Moves with ruler
                                    Positioned(
                                      left: MediaQuery.of(context).size.width /
                                              2 -
                                          (currentWeight - initialWeight) *
                                              (MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  40),
                                      top:
                                          18, // Adjusted to center with ruler ticks
                                      child: Container(
                                        width: 2.0,
                                        height: 36.0,
                                        color: Colors.grey.withOpacity(0.3),
                                      ),
                                    ),
                                    // Black line (dream weight) - Always centered
                                    Positioned(
                                      left:
                                          MediaQuery.of(context).size.width / 2,
                                      top:
                                          18, // Adjusted to center with ruler ticks
                                      child: Container(
                                        width: 2.0,
                                        height:
                                            36.0, // Changed from 2.4 to 1.0 to match ruler ticks and gray line
                                        color: Colors.black,
                                      ),
                                    ),
                                    // Highlight between lines
                                    Positioned(
                                      left: math.min(
                                        MediaQuery.of(context).size.width / 2,
                                        MediaQuery.of(context).size.width / 2 -
                                            (currentWeight - initialWeight) *
                                                (MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    40),
                                      ),
                                      width: ((currentWeight - initialWeight) *
                                              (MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  40))
                                          .abs(),
                                      top:
                                          18, // Adjusted to center with ruler ticks
                                      height:
                                          36.0, // Match exact height of ruler's big ticks
                                      child: Container(
                                        color: Colors.grey.withOpacity(0.3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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
                        builder: (context) => SpeedScreen(
                          isMetric: widget.isMetric,
                          initialWeight: widget.initialWeight,
                          dreamWeight: currentWeight.toInt(),
                          isGaining: widget.selectedGoal == 'Gain weight',
                          gender: widget.gender,
                          heightInCm: widget.heightInCm,
                          birthDate: widget.birthDate,
                          gymGoal: widget.gymGoal,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      fontFamily: '.SF Pro Display',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // Current weight text - Now as the last child in the main Stack
            Positioned(
              left: MediaQuery.of(context).size.width / 2 -
                  (currentWeight - initialWeight) *
                      (MediaQuery.of(context).size.width / 40) -
                  50,
              top: MediaQuery.of(context).size.height * 0.454 + 137,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Current Weight',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontFamily: '.SF Pro Display',
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${initialWeight.toInt()} ${widget.isMetric ? 'kg' : 'lb'}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontFamily: '.SF Pro Display',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String text, {required int index}) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : const Color(0xFFF0F1F3),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black,
              fontFamily: '.SF Pro Display',
            ),
          ),
        ),
      ),
    );
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        setState(() {
          if (currentWeight > minWeight) {
            currentWeight--;
          }
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        setState(() {
          if (currentWeight < maxWeight) {
            currentWeight++;
          }
        });
      }
    }
  }

  void _handleScroll(double delta) {
    setState(() {
      if (delta > 0) {
        // Scrolling down
        if (currentWeight > minWeight) {
          currentWeight--;
        }
      } else if (delta < 0) {
        // Scrolling up
        if (currentWeight < maxWeight) {
          currentWeight++;
        }
      }
    });
  }

  @override
  void dispose() {
    // Remove all widget tree references immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _dragAccumulator = 0;
          currentWeight = 0;
        });
      }
    });
    super.dispose();
  }
}

// Add this class at the top level of the file
class InfiniteRulerPainter extends CustomPainter {
  final double scrollOffset;
  final double tickSpacing;

  InfiniteRulerPainter({
    required this.scrollOffset,
    required this.tickSpacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    // Calculate base position that repeats every screen width
    final baseOffset = scrollOffset % size.width;

    // Draw three screens worth of ticks to ensure smooth scrolling
    for (int screen = -1; screen <= 1; screen++) {
      final screenOffset = baseOffset + (screen * size.width);

      // Draw ticks for current screen section
      for (int i = -20; i <= (size.width / tickSpacing + 20).ceil(); i++) {
        final x = screenOffset + (i * tickSpacing);

        // Only draw if within extended visible area
        if (x >= -size.width && x <= size.width * 2) {
          final height = (i % 5 == 0) ? 36.0 : 24.0;
          final y = (size.height - height) / 2;

          canvas.drawLine(
            Offset(x, y),
            Offset(x, y + height),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(InfiniteRulerPainter oldDelegate) {
    return scrollOffset != oldDelegate.scrollOffset;
  }
}

// Add this class at the top level
class HighlightPainter extends CustomPainter {
  final double initialX;
  final double currentX;

  HighlightPainter({
    required this.initialX,
    required this.currentX,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // Calculate rectangle bounds
    double left = math.min(initialX, currentX);
    double width = (currentX - initialX).abs();

    // Draw rectangle between the lines
    canvas.drawRect(
      Rect.fromLTWH(
        left + size.width / 2, // Adjust for center alignment
        0,
        width,
        size.height,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(HighlightPainter oldDelegate) {
    return initialX != oldDelegate.initialX || currentX != oldDelegate.currentX;
  }
}

// Add this class at the top of the file
class HighlightBetweenLines extends StatelessWidget {
  final double grayLineX;
  final double blackLineX;

  const HighlightBetweenLines({
    Key? key,
    required this.grayLineX,
    required this.blackLineX,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double left = math.min(grayLineX, blackLineX);
    final double width = (grayLineX - blackLineX).abs();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 1. Highlight rectangle
        Positioned(
          left: left,
          top: 0,
          width: width,
          bottom: 0,
          child: Container(
            color: Colors.grey.withOpacity(0.3),
          ),
        ),

        // 2. Gray line (current weight)
        Positioned(
          left: grayLineX,
          top: 0,
          bottom: 0,
          child: Container(
            width: 2,
            color: Colors.grey.withOpacity(0.8), // Changed to more visible gray
          ),
        ),

        // 3. Black line (dream weight)
        Positioned(
          left: blackLineX,
          top: 0,
          bottom: 0,
          child: Container(
            width: 2,
            color: Colors.black, // Keep black for dream weight
          ),
        ),
      ],
    );
  }
}
