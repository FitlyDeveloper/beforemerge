import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;
import 'package:fitness_app/Features/onboarding/presentation/screens/ready_screen.dart';

class ComfortScreen extends StatefulWidget {
  final bool isMetric;
  final int initialWeight;
  final int dreamWeight;
  final bool isGaining;
  final double speedValue;
  final bool isMaintaining;

  const ComfortScreen({
    super.key,
    required this.isMetric,
    required this.initialWeight,
    required this.dreamWeight,
    required this.isGaining,
    required this.speedValue,
    this.isMaintaining = false,
  });

  @override
  State<ComfortScreen> createState() => _ComfortScreenState();
}

class _ComfortScreenState extends State<ComfortScreen> {
  int? selectedIndex;
  late double currentWeight;
  late double initialWeight;
  late double speedValue;
  late final double minWeight;
  late final double maxWeight;
  double _dragAccumulator = 0;
  late String weightDifferenceText;
  late String timeFrameText;

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

    // Calculate weight difference (X)
    double weightDiff =
        (widget.dreamWeight - widget.initialWeight).abs().toDouble();
    weightDifferenceText = '$weightDiff ${widget.isMetric ? 'kg' : 'lb'}';

    // Handle time frame text
    if (widget.isMaintaining) {
      timeFrameText = 'Maintenance';
    } else {
      // Calculate weeks (C = X/Y) - Use speed value directly as it's already in correct decimal
      double weeks = weightDiff / widget.speedValue;

      // Format the time frame text based on number of weeks
      if (weeks <= 4) {
        timeFrameText = '${weeks.round()} weeks';
      } else {
        // Convert weeks to months
        double months = weeks / 4;

        if (months >= 60) {
          timeFrameText = '60+ months';
        } else {
          timeFrameText = '${months.round()} months';
        }
      }
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
                mainAxisSize: MainAxisSize.min,
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
                              value: 12 / 13,
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
                  // Centered text section
                  Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Transform.translate(
                          offset: const Offset(0, -15),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w700,
                                    height: 1.21,
                                    fontFamily: '.SF Pro Display',
                                    letterSpacing: -0.5,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    if (widget.isMaintaining) ...[
                                      const TextSpan(text: 'Fitly makes\n'),
                                      TextSpan(
                                        text: 'maintaining',
                                        style: const TextStyle(
                                            color: Color(0xFF4D4DE2)),
                                      ),
                                      const TextSpan(
                                          text: ' weight\nfeel effortless'),
                                    ] else ...[
                                      const TextSpan(text: 'Fitly makes '),
                                      widget.isGaining
                                          ? const TextSpan(text: 'gaining\n')
                                          : const TextSpan(text: 'losing\n'),
                                      TextSpan(
                                        text: weightDifferenceText,
                                        style: const TextStyle(
                                            color: Color(0xFF4D4DE2)),
                                      ),
                                      const TextSpan(text: ' in '),
                                      TextSpan(
                                        text: timeFrameText,
                                        style: const TextStyle(
                                            color: Color(0xFF4D4DE2)),
                                      ),
                                      const TextSpan(
                                          text: '\nfeel effortless!'),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '90% of Fitly users see\nprogress that lasts.',
                                textAlign: TextAlign.center,
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
                        builder: (context) => ReadyScreen(
                          isMetric: widget.isMetric,
                          initialWeight: widget.initialWeight,
                          isGaining: widget.isGaining,
                        ),
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
}
