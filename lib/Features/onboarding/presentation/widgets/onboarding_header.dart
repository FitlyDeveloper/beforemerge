import 'package:flutter/material.dart';

class OnboardingHeader extends StatelessWidget {
  final double progress;
  final VoidCallback onBack;

  const OnboardingHeader({
    super.key,
    required this.progress,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
                  icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
                  onPressed: onBack,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 40),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 2,
                      backgroundColor: const Color(0xFFE5E5EA),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 