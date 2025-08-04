import 'package:flutter/material.dart';

class DialogHelper {
  static void showStandardDialog({
    required BuildContext context,
    required String title,
    required String message,
    String? positiveButtonText,
    String? positiveButtonIcon,
    VoidCallback? onPositivePressed,
    String negativeButtonText = "",
    VoidCallback? onNegativePressed,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            width: 326,
            padding: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 18),
                // Message (can be split into bullet points if needed)
                ...message.split('\n').map((line) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.black, size: 22),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              line,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                SizedBox(height: 24),
                // Continue button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed:
                        onPositivePressed ?? () => Navigator.of(context).pop(),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      )),
                    ),
                    child: Text(
                      positiveButtonText ?? 'Continue',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
                // Close icon in top right
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.close, color: Colors.black, size: 26),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
