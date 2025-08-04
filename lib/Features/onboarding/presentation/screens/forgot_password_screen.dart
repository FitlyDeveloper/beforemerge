import 'package:flutter/material.dart';
import 'package:fitness_app/services/auth_service.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/sign_screen.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/reset.dart';
import 'package:fitness_app/core/widgets/responsive_scaffold.dart';
import 'package:fitness_app/core/utils/device_size_adapter.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/signin.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  final AuthService _auth = AuthServiceFactory.getAuthService();
  bool _isValidEmail = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateEmail);
    _emailController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    setState(() {
      _isValidEmail = emailRegex.hasMatch(email);
    });
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (!_isValidEmail) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.sendPasswordResetEmail(email);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetScreen(email: email),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Create a responsive form container widget (copied from sign_screen.dart)
  Widget _buildResponsiveFormContainer({required Widget child}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: DeviceSizeAdapter.getScaledWidth(context, 342),
          ),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

          // Email input form - Updated to exactly match sign_screen.dart
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Space for header
                  SizedBox(height: MediaQuery.of(context).size.height * 0.322),

                  // Form elements container
                  _buildResponsiveFormContainer(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Email input
                          Stack(
                            children: [
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 4,
                                child: Container(
                                  height: 1,
                                  color: Colors.grey[300],
                                ),
                              ),
                              SizedBox(
                                height: 24,
                                child: Transform.translate(
                                  offset: const Offset(0, -8),
                                  child: TextField(
                                    cursorColor: Colors.black,
                                    cursorWidth: 1.2,
                                    showCursor: true,
                                    style: const TextStyle(
                                      fontSize: 13.6,
                                      fontFamily: '.SF Pro Display',
                                      color: Colors.black,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Email',
                                      hintStyle: TextStyle(
                                        color:
                                            Colors.grey[600]!.withOpacity(0.7),
                                        fontSize: 13.6,
                                        fontFamily: '.SF Pro Display',
                                      ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    controller: _emailController,
                                  ),
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

          // Continue button
          Positioned(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).size.height * 0.06,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.0689,
              decoration: BoxDecoration(
                color: _isValidEmail
                    ? Colors.black
                    : Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(28),
              ),
              child: TextButton(
                onPressed:
                    (_isLoading || !_isValidEmail) ? null : _resetPassword,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Text(
                        'Reset Password',
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

          // Header content - moved to be the last item in the Stack to ensure it's on top
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
                        onPressed: () {
                          print("BACK BUTTON PRESSED in ForgotPasswordScreen");
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignInScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 40),
                          child: LinearProgressIndicator(
                            value: 1 / 13,
                            minHeight: 2,
                            backgroundColor: const Color(0xFFE5E5EA),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.black),
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
                        'Forgot your password?',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          height: 1.21,
                          fontFamily: '.SF Pro Display',
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "No worries! Enter your email to recover access.",
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
