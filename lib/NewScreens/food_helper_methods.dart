import 'package:flutter/material.dart';

/// Helper methods for food-related functionality
class FoodHelpers {
  // Method to check if a string is empty
  static bool isEmpty(String? str) {
    return str == null || str.trim().isEmpty;
  }
  
  // Calculate estimated calories for a food item based on name and serving size
  static double estimateCaloriesForFood(String foodName, String servingSize) {
    double baseCalories = 100.0; // Default base calories
    double servingSizeMultiplier = 1.0;
    
    // Adjust for serving size if numerical values are present
    RegExp numericRegex = RegExp(r'(\d+(?:\.\d+)?)');
    var numericMatches = numericRegex.allMatches(servingSize);
    
    if (numericMatches.isNotEmpty) {
      try {
        double? sizeValue = double.tryParse(numericMatches.first.group(0) ?? '1');
        if (sizeValue != null) {
          // Adjust serving size multiplier based on common units
          if (servingSize.contains('cup') || servingSize.contains('cups')) {
            servingSizeMultiplier = sizeValue * 2.0; // 1 cup is about 200 calories for many foods
          } else if (servingSize.contains('tbsp') || servingSize.contains('tablespoon')) {
            servingSizeMultiplier = sizeValue * 0.3; // 1 tbsp is about 30 calories
          } else if (servingSize.contains('tsp') || servingSize.contains('teaspoon')) {
            servingSizeMultiplier = sizeValue * 0.1; // 1 tsp is about 10 calories
          } else if (servingSize.contains('oz') || servingSize.contains('ounce')) {
            servingSizeMultiplier = sizeValue * 0.7; // 1 oz is about 70 calories
          } else if (servingSize.contains('g') || servingSize.contains('gram')) {
            servingSizeMultiplier = sizeValue * 0.01; // 1g is about 1 calorie for many foods
          } else {
            // General multiplier for other units
            servingSizeMultiplier = sizeValue;
          }
        }
      } catch (e) {
        // If parsing fails, keep the default multiplier
        print('Could not parse serving size: $servingSize');
      }
    }
    
    // Adjust base calories based on food type
    String lowercaseName = foodName.toLowerCase();
    
    // High-calorie foods
    if (lowercaseName.contains('cake') || 
        lowercaseName.contains('pizza') || 
        lowercaseName.contains('burger') || 
        lowercaseName.contains('fries') || 
        lowercaseName.contains('chocolate') || 
        lowercaseName.contains('ice cream')) {
      baseCalories = 300.0;
    }
    // Medium-calorie foods
    else if (lowercaseName.contains('meat') || 
             lowercaseName.contains('chicken') || 
             lowercaseName.contains('fish') || 
             lowercaseName.contains('pasta') || 
             lowercaseName.contains('rice') || 
             lowercaseName.contains('bread')) {
      baseCalories = 200.0;
    }
    // Low-calorie foods
    else if (lowercaseName.contains('vegetable') || 
             lowercaseName.contains('fruit') || 
             lowercaseName.contains('salad') || 
             lowercaseName.contains('soup')) {
      baseCalories = 80.0;
    }
    
    return baseCalories * servingSizeMultiplier;
  }
  
  // Show a standard dialog with consistent styling
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
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            width: 326,
            height: message.length > 100 ? 222 : 182,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Message
                  Container(
                    width: 267,
                    margin: EdgeInsets.only(bottom: 20),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'SF Pro Display',
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // Action button (if provided)
                  if (positiveButtonText != null) 
                    Container(
                      width: 267,
                      height: 40,
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Centered text
                          Text(
                            positiveButtonText,
                            style: TextStyle(
                              color: positiveButtonColor,
                              fontSize: 16,
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // Icon if provided
                          if (positiveButtonIcon != null)
                            Positioned(
                              left: 70,
                              child: Image.asset(
                                positiveButtonIcon,
                                width: 20,
                                height: 20,
                                color: positiveButtonColor,
                              ),
                            ),
                          // Full-width button for tap area
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: onPositivePressed ?? () => Navigator.of(dialogContext).pop(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Cancel/Dismiss button
                  Container(
                    width: 267,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Centered text
                        Text(
                          negativeButtonText,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        // Full-width button for tap area
                        Positioned.fill(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: onNegativePressed ?? () => Navigator.of(dialogContext).pop(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} 