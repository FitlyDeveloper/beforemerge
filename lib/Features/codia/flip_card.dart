import 'dart:math';
import 'package:flutter/material.dart';

// Flip Card Widget with front and back sides
class FlipCard extends StatefulWidget {
  final Widget frontSide;
  final Widget backSide;
  final Duration duration;
  final VoidCallback? onFlip;

  const FlipCard({
    Key? key,
    required this.frontSide,
    required this.backSide,
    this.duration = const Duration(milliseconds: 500),
    this.onFlip,
  }) : super(key: key);

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showFrontSide = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleCard() {
    if (_showFrontSide) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _showFrontSide = !_showFrontSide;
    if (widget.onFlip != null) {
      widget.onFlip!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleCard,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * pi;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspective
            ..rotateY(angle);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: _controller.value < 0.5
                ? widget.frontSide
                : Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: widget.backSide,
                  ),
          );
        },
      ),
    );
  }
}
