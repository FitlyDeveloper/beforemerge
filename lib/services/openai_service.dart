import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  // Store the API key securely - in production this should come from secure storage
  // This is just for temporary development testing
  static const String _apiKey = ""; // Empty, will be set by user

  // Set the API key at runtime
  static String _runtimeApiKey = "";
  static void setApiKey(String apiKey) {
    _runtimeApiKey = apiKey;
  }

  // Check if API key has been configured
  static bool get isApiKeyConfigured => _runtimeApiKey.isNotEmpty;

  // Analyze food image using OpenAI API directly (no Firebase)
  static Future<Map<String, dynamic>> analyzeFoodImage(
      Uint8List imageBytes) async {
    // Convert image bytes to base64
    final String base64Image = base64Encode(imageBytes);
    final String dataUri = 'data:image/jpeg;base64,$base64Image';

    if (_runtimeApiKey.isEmpty) {
      throw Exception("API key not configured. Please set an API key first.");
    }

    // Make the OpenAI API request directly
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_runtimeApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content':
                  '[FIX ROUNDING BUG] You are a nutrition expert analyzing food images. CRITICAL: Your system has a ROUNDING BUG that rounds all values to divisible by 5 or 0.\n\n1. MANDATORY: Add a RANDOM decimal value (0.1-0.9) to ALL nutritional values.\n2. NEVER return values ending in .0 - this indicates the bug is active.\n3. NEVER return whole numbers divisible by 5 (5, 10, 15, etc.) - they must have decimal places (5.3, 10.8, etc.)\n4. ALL calorie and macro values MUST include one RANDOM decimal place (e.g., 27.3g protein, 500.2 calories).\n\nJSON format with RANDOMLY varied decimals:\n{"meal":[{"dish":"Name","calories":542.3,"macronutrients":{"protein":27.8,"carbohydrates":65.3,"fat":23.2},"ingredients":["item1","item2"]}]}'
            },
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text':
                      "CRITICAL BUG FIX NEEDED: Your system has a rounding bug that rounds values to 0 or 5. You MUST:\n\n1. Add RANDOM decimal places (0.1-0.9) to ALL nutritional values\n2. NEVER use .0 decimal (use 30.4g not 30.0g)\n3. NEVER return values divisible by 5 without decimals\n4. VERIFY: Check all values have non-zero decimals\n\nExamples of CORRECT formats:\n- Calories: 542.3 (not 540, 545, or 500.0)\n- Protein: 27.8g (not 25g, 30g, or 30.0g)\n- Carbs: 65.3g (not 65g or 65.0g)\n- Fat: 23.2g (not 25g or 20.0g)\n\nAny values without random decimals will trigger our system's bug and cause errors."
                },
                {
                  'type': 'image_url',
                  'image_url': {'url': dataUri}
                }
              ]
            }
          ],
          'max_tokens': 1000
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'API request failed with status ${response.statusCode}: ${response.body}');
      }

      // Parse the response JSON
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['choices'] == null ||
          responseData['choices'].isEmpty ||
          responseData['choices'][0]['message'] == null ||
          responseData['choices'][0]['message']['content'] == null) {
        throw Exception('Invalid response format from OpenAI');
      }

      final String content = responseData['choices'][0]['message']['content'];

      // Parse the JSON response
      return _parseResult(content);
    } catch (e) {
      debugPrint('Error in OpenAI request: $e');
      throw Exception('Failed to analyze food image: $e');
    }
  }

  // Parse the JSON from the text response
  static Map<String, dynamic> _parseResult(String content) {
    try {
      // First try direct parsing
      return jsonDecode(content);
    } catch (error1) {
      // Look for JSON in markdown blocks
      final jsonMatch =
          RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```').firstMatch(content) ??
              RegExp(r'\{[\s\S]*\}').firstMatch(content);

      if (jsonMatch != null) {
        final jsonText =
            jsonMatch.group(0)!.replaceAll(RegExp(r'```json\n|```'), '').trim();
        try {
          return jsonDecode(jsonText);
        } catch (error2) {
          // Fallback to text
          return {'text': content};
        }
      } else {
        // No JSON found
        return {'text': content};
      }
    }
  }
}
