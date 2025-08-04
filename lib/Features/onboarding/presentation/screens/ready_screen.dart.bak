import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;
import 'package:fitness_app/Features/onboarding/presentation/screens/paying_screen.dart';
import 'package:confetti/confetti.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/sign_screen.dart';

class ReadyScreen extends StatefulWidget {
  final bool isMetric;
  final int initialWeight;
  final bool isGaining;

  const ReadyScreen({
    super.key,
    required this.isMetric,
    required this.initialWeight,
    required this.isGaining,
  });

  @override
  State<ReadyScreen> createState() => _ReadyScreenState();
}

class _ReadyScreenState extends State<ReadyScreen> {
  int? selectedIndex;
  late double currentWeight;
  late double initialWeight;
  late double speedValue;
  late final double minWeight;
  late final double maxWeight;
  double _dragAccumulator = 0;
  String? selectedGoal;
  late ConfettiController _confettiController;
  final GlobalKey _yesButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    initialWeight = widget.initialWeight.toDouble();
    currentWeight = initialWeight;
    if (widget.isMetric) {
      minWeight = 0;
      maxWeight = 350;
    } else {
      minWeight = 0;
      maxWeight = 700;
    }
    _confettiController = ConfettiController();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  // Premium brand colors
  final List<Color> confettiColors = [
    const Color(0xFFF5B000), // Gold
    const Color(0xFF7C3AED), // Purple
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFFF5B000).withOpacity(0.7), // Soft gold
    const Color(0xFF7C3AED).withOpacity(0.7), // Soft purple
    const Color(0xFF06B6D4).withOpacity(0.7), // Soft cyan
  ];

  // Get button position for confetti origin
  Offset _getConfettiOrigin() {
    final RenderBox? renderBox =
        _yesButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return Offset.zero;
    final position = renderBox.localToGlobal(Offset.zero);
    return Offset(
      position.dx + renderBox.size.width / 2,
      position.dy + renderBox.size.height / 2,
    );
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
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 40),
                            child: const LinearProgressIndicator(
                              value: 13 / 13, // Final screen
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
                          'Do you want to achieve\nyour dream body?',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            height: 1.21,
                            fontFamily: '.SF Pro Display',
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 205),
                        Center(
                          child: Column(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.85,
                                child: _buildSelectionBar('Yes, Lets go!'),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.85,
                                child:
                                    _buildSelectionBar('No. Stay where I am.'),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                        builder: (context) => const PayingScreen(),
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

            // Confetti layer
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: -math.pi / 2,
                  particleDrag: 0.02,
                  emissionFrequency: 0.02,
                  numberOfParticles: 200,
                  gravity: 0.2,
                  maxBlastForce: 100,
                  minBlastForce: 80,
                  shouldLoop: false,
                  displayTarget: false,
                  minimumSize: const Size(20, 20),
                  maximumSize: const Size(30, 30),
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple,
                    Colors.red,
                    Colors.indigo,
                    Colors.amber,
                  ],
                ),
              ),
            ),
          ],
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

  Widget _buildSelectionBar(String text) {
    bool isSelected = selectedGoal == text;
    bool isYesButton = text == 'Yes, Lets go!';

    return GestureDetector(
      onTap: () {
        if (isYesButton) {
          _handleYesButtonPress();
        } else {
          setState(() {
            selectedGoal = text;
          });
        }
      },
      child: Container(
        key: isYesButton ? _yesButtonKey : null,
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : const Color(0xFFF0F1F3),
          borderRadius: BorderRadius.circular(16),
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

  void _handleYesButtonPress() {
    setState(() {
      selectedGoal = 'Yes, Lets go!';
    });

    _confettiController.stop();
    Future.delayed(const Duration(milliseconds: 50), () {
      _confettiController.play();
    });
  }
}
