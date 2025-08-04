import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/openai_service.dart';

class ApiKeyDialog extends StatefulWidget {
  final VoidCallback onApiKeySet;

  const ApiKeyDialog({Key? key, required this.onApiKeySet}) : super(key: key);

  @override
  _ApiKeyDialogState createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<ApiKeyDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveApiKey(String apiKey) async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      // Save the API key to secure storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('openai_api_key', apiKey);

      // Set it in the OpenAI service
      OpenAIService.setApiKey(apiKey);

      // Notify parent
      widget.onApiKeySet();

      // Close the dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorText = 'Failed to save API key: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('OpenAI API Key'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Enter your OpenAI API key to enable food image analysis. This key will be stored securely on your device.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'sk-...',
              labelText: 'API Key',
              errorText: _errorText,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
            obscureText: _obscureText,
            onChanged: (value) {
              if (_errorText != null) {
                setState(() {
                  _errorText = null;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () {
                  final apiKey = _controller.text.trim();
                  if (apiKey.isEmpty) {
                    setState(() {
                      _errorText = 'API key cannot be empty';
                    });
                    return;
                  }
                  if (!apiKey.startsWith('sk-')) {
                    setState(() {
                      _errorText = 'Invalid API key format';
                    });
                    return;
                  }
                  _saveApiKey(apiKey);
                },
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

// Show the API key dialog
Future<void> showApiKeyDialog(
    BuildContext context, VoidCallback onApiKeySet) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return ApiKeyDialog(onApiKeySet: onApiKeySet);
    },
  );
}
