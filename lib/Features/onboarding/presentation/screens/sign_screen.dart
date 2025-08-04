import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fitness_app/Features/onboarding_screen.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/paying_screen.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/box_screen.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/signin.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/gender_selection_screen.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/verification_screen.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/forgot_password_screen.dart';
import 'package:fitness_app/services/auth_service.dart';
import 'package:fitness_app/core/widgets/responsive_scaffold.dart';
import 'package:fitness_app/core/utils/device_size_adapter.dart';

class SignScreen extends StatefulWidget {
  const SignScreen({super.key});

  @override
  State<SignScreen> createState() => _SignScreenState();
}

class _SignScreenState extends State<SignScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  final AuthService _auth = AuthServiceFactory.getAuthService();
  String? selectedGoal;
  bool _obscurePassword = true;
  bool _isValidEmail = false;
  bool _isValidPassword = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateInputs);
    _passwordController.addListener(_validateInputs);
  }

  void _validateInputs() {
    setState(() {
      // Check if email is valid
      final email = _emailController.text.trim();
      _isValidEmail =
          email.isNotEmpty && email.contains('@') && email.contains('.');

      // Check if password is valid (at least 6 characters)
      final password = _passwordController.text;
      _isValidPassword = password.length >= 6;

      // Force rebuild to update password strength indicator
      if (password.isNotEmpty) {
        // This will trigger a rebuild with the new password
      }
    });
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateInputs);
    _passwordController.removeListener(_validateInputs);
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });

    // Get the email from the input field or use a default for testing
    final email = _emailController.text.isEmpty
        ? "test@example.com"
        : _emailController.text.trim();

    final password = _passwordController.text.isEmpty
        ? "password123" // Default password for testing
        : _passwordController.text.trim();

    try {
      // Check if email already exists
      final emailExists = await _auth.checkIfEmailExists(email);

      if (emailExists) {
        // Email already exists, try to send verification email again
        try {
          // Try to sign in first to get access to the user
          await _auth.signInWithEmailAndPassword(email, password);

          // Then send verification email
          await _auth.sendEmailVerification();

          print('Verification email sent to existing user: $email');
        } catch (signInError) {
          // If sign in fails, just navigate to verification screen
          print('Could not sign in to resend: $signInError');
        }

        // Navigate to verification screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VerificationScreen(
                email: email,
              ),
            ),
          );
        }
      } else {
        // Create new account if email doesn't exist
        await _auth.createUserWithEmailAndPassword(
          email,
          password,
        );

        // Send verification email
        await _auth.sendEmailVerification();
        print('Account created and verification email sent to: $email');

        if (mounted) {
          // Navigate to verification screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VerificationScreen(
                email: email,
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error during sign up: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildSelectionBar(String text) {
    bool isSelected = selectedGoal == text;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGoal = text;
        });
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : const Color(0xFFF0F1F3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black,
              fontFamily: '.SF Pro Display',
            ),
          ),
        ),
      ),
    );
  }

  // Create a responsive form container widget
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
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Colors.grey.withOpacity(0.3),
        ),
      ),
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

            // Form content - wrap in SingleChildScrollView for scrollability
            Positioned.fill(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Space for header
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.322),

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
                                          color: Colors.grey[600]!
                                              .withOpacity(0.7),
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
                            const SizedBox(height: 16),

                            // Password input with strength indicator in a Stack
                            Stack(
                              children: [
                                // Password field container
                                Column(
                                  children: [
                                    Stack(
                                      children: [
                                        Positioned(
                                          left: 0,
                                          right: 0,
                                          bottom: 0,
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
                                              obscureText: _obscurePassword,
                                              decoration: InputDecoration(
                                                hintText: 'Password',
                                                hintStyle: TextStyle(
                                                  color: Colors.grey[600]!
                                                      .withOpacity(0.7),
                                                  fontSize: 13.6,
                                                  fontFamily: '.SF Pro Display',
                                                ),
                                                border: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                                isDense: true,
                                                contentPadding: EdgeInsets.zero,
                                                suffixIcon: Transform.translate(
                                                  offset: const Offset(0, 1),
                                                  child: IconButton(
                                                    padding: EdgeInsets.zero,
                                                    icon: Icon(
                                                      _obscurePassword
                                                          ? Icons.visibility_off
                                                          : Icons.visibility,
                                                      color: Colors.black
                                                          .withOpacity(0.7),
                                                      size: 17,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _obscurePassword =
                                                            !_obscurePassword;
                                                      });
                                                    },
                                                    splashColor:
                                                        Colors.transparent,
                                                    highlightColor:
                                                        Colors.transparent,
                                                    hoverColor:
                                                        Colors.transparent,
                                                  ),
                                                ),
                                              ),
                                              controller: _passwordController,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Fixed space after password field
                                    const SizedBox(height: 24),
                                  ],
                                ),

                                // Password strength indicator overlaid
                                if (_passwordController.text.isNotEmpty)
                                  Positioned(
                                    left: 0,
                                    top:
                                        24, // Position it right below the password field
                                    child: Container(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: _buildPasswordStrengthIndicator(),
                                    ),
                                  ),
                              ],
                            ),

                            // Forgot Password - replaced with invisible placeholder to maintain layout
                            Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                height:
                                    24, // Same height as the previous text component
                                width: double.infinity,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // OR divider
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 19.2),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15.3,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: '.SF Pro Display',
                                ),
                              ),
                            ),

                            // Social login buttons
                            _buildSocialButton(
                              'Continue with Google',
                              'assets/images/google.png',
                              () {},
                            ),
                            const SizedBox(height: 12),
                            _buildSocialButton(
                              'Continue with Apple',
                              'assets/images/apple.png',
                              () {},
                            ),
                            const SizedBox(height: 12),
                            _buildSocialButton(
                              'Continue with Facebook',
                              'assets/images/facebook.png',
                              () {},
                            ),
                            const SizedBox(height: 26),

                            // Already have an account text
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SignInScreen(),
                                    ),
                                  );
                                },
                                child: RichText(
                                  text: TextSpan(
                                    text: "Already have an account? ",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13.6,
                                      fontFamily: '.SF Pro Display',
                                    ),
                                    children: const [
                                      TextSpan(
                                        text: 'Login',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 13.6,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // SizedBox to create space below the text
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.05),
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

            // Sign Up button
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
                  onPressed: _isLoading ? null : _signUp,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text(
                          'Sign Up',
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

            // Terms of service text with bold terms
            Positioned(
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).size.height * 0.032,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontFamily: '.SF Pro Display',
                      ),
                      children: const [
                        TextSpan(text: 'By signing up, you agree to our '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(text: '.'),
                      ],
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
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OnboardingScreen(),
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
                          'Sign Up',
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
                          "Let's customize Fitly for your goals.",
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
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    final password = _passwordController.text;
    final length = password.length;

    // Determine strength based only on length
    String strengthText;
    Color strengthColor;

    if (length < 6) {
      strengthText = 'Too short';
      strengthColor = const Color(0xFFFF3B30); // #FF3B30
    } else if (length >= 12) {
      strengthText = 'Very strong';
      strengthColor = const Color(0xFF00522E); // #00522E
    } else if (length >= 10) {
      strengthText = 'Strong';
      strengthColor = const Color(0xFF4CAF50); // #4CAF50
    } else if (length >= 8) {
      strengthText = 'Okay';
      strengthColor = const Color(0xFFFFD60A); // #FFD60A
    } else {
      strengthText = 'Weak';
      strengthColor = const Color(0xFFFF9500); // #FF9500
    }

    return Row(
      children: [
        Text(
          strengthText,
          style: TextStyle(
            color: strengthColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: '.SF Pro Display',
          ),
        ),
      ],
    );
  }

  // Helper method to build social login buttons with consistent styling
  Widget _buildSocialButton(
      String text, String iconPath, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          backgroundColor: MaterialStateProperty.all(Colors.white),
          foregroundColor: MaterialStateProperty.all(Colors.black),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          overlayColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) {
                return Colors.grey.withOpacity(0.2);
              }
              if (states.contains(MaterialState.hovered)) {
                return Colors.grey.withOpacity(0.1);
              }
              return null;
            },
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 50, right: 24),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Image.asset(iconPath, height: 24),
              ),
              const SizedBox(width: 17),
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      fontFamily: '.SF Pro Display',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
