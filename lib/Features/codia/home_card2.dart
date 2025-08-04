import 'package:flutter/material.dart';
import 'dart:math' as math;

class HomeCard2 extends StatelessWidget {
  const HomeCard2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220, // Match height of the front card for smooth transition
      padding: EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Left Card - Steps
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: 8),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title
                  Text(
                    'Steps',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),

                  // Circular progress
                  SizedBox(height: 10),
                  Container(
                    width: 100,
                    height: 100,
                    child: CustomPaint(
                      painter: StepsProgressPainter(
                        progress: 0.5, // 5010/10000 = 0.5
                        progressColor:
                            Color(0xFFFF4D8D), // Pink color from image
                        backgroundColor: Color(0xFFEEEEEE),
                        strokeWidth: 10,
                      ),
                      child: Center(
                        child: Image.asset(
                          'images/steps.png',
                          width: 43,
                          height: 43,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 14),

                  // Steps count
                  Text(
                    '5010/10,000',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Card - Activity
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 8),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Center(
                    child: Text(
                      'Activity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 14),

                  // Calories burned
                  Row(
                    children: [
                      Image.asset(
                        'images/energy.png',
                        width: 20,
                        height: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '0',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            Text(
                              'Calories burned',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  // From steps
                  Row(
                    children: [
                      Image.asset(
                        'images/steps.png',
                        width: 20,
                        height: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '0',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            Text(
                              'From steps',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  // From workout
                  Row(
                    children: [
                      Image.asset(
                        'images/dumbbell.png',
                        width: 20,
                        height: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '0',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            Text(
                              'From workout',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StepsProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  StepsProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(StepsProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
