import 'package:flutter/material.dart';

class DialogHelper {
  static void showStandardDialog({
    required BuildContext context,
    required String title,
    required String message,
    String? positiveButtonText,
    String? positiveButtonIcon,
    Color positiveButtonColor = Colors.black,
    VoidCallback? onPositivePressed,
    String negativeButtonText = "Cancel",
    VoidCallback? onNegativePressed,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            if (negativeButtonText.isNotEmpty)
              TextButton(
                onPressed: onNegativePressed ?? () => Navigator.of(context).pop(),
                child: Text(negativeButtonText),
              ),
            if (positiveButtonText != null && positiveButtonText.isNotEmpty)
              TextButton(
                onPressed: onPositivePressed,
                      style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(positiveButtonColor),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                child: Text(positiveButtonText),
              ),
          ],
        );
      },
    );
  }
}

