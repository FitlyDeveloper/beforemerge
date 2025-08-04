import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/signin.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/questions/gender_screen.dart';
import 'package:fitness_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/sign_screen.dart';

class ResetScreen extends StatefulWidget {
  final String email;

  const ResetScreen({
    super.key,
    required this.email,
  });

  @override
  State<ResetScreen> createState() => _ResetScreenState();
}

class _ResetScreenState extends State<ResetScreen> {
  final AuthService _auth = AuthServiceFactory.getAuthService();
  bool _isVerified = false;
  bool _isChecking = false;
  bool _showErrorMessage = false;
  Timer? _timer;
  int _resendCountdown = 30;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    // Store the email in the mock service when the screen loads
    _initializeUser();
    // Start countdown immediately
    _resendCountdown = 30;
    _startResendCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startResendCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _countdownTimer?.cancel();
        }
      });
    });
  }

  void _resetResendCountdown() {
    setState(() {
      _resendCountdown = 30;
    });
    _countdownTimer?.cancel();
    _startResendCountdown();
  }

  Future<void> _resendResetEmail() async {
    try {
      setState(() {
        _isChecking = true;
      });

      // Send password reset email
      await _auth.sendPasswordResetEmail(widget.email);
      _resetResendCountdown();

      // No SnackBar notification to avoid unwanted popups
    } catch (e) {
      print('Failed to resend: ${e.toString()}');
      // No SnackBar notification to avoid unwanted popups
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _initializeUser() async {
    // If we're using the mock service, make sure the email is registered
    if (AuthServiceFactory.useMockAuth) {
      final mockAuth = _auth as MockAuthService;
      await mockAuth.ensureUserExists(widget.email);
    }
  }

  Future<void> _verifyAndProceed() async {
    setState(() {
      _isChecking = true;
      _showErrorMessage = false;
    });

    try {
      // For testing purposes in mock mode, force verification and proceed
      if (AuthServiceFactory.useMockAuth) {
        print('TEST MODE: Forcing verification and proceeding');

        // Force the email to be verified in the mock service
        final mockAuth = _auth as MockAuthService;
        await mockAuth.forceVerifyEmail(widget.email);

        // Navigate to sign in screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SignInScreen(),
            ),
          );
        }
      } else {
        // In real mode, check if the password reset was completed
        // This would typically involve checking if the user has set a new password

        // Navigate to sign in screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SignInScreen(),
            ),
          );
        }
      }
    } catch (e) {
      print('Error during verification: ${e.toString()}');
      if (mounted) {
        setState(() {
          _showErrorMessage = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if we're using the mock service
    final bool isTestMode = AuthServiceFactory.useMockAuth;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background gradient (matching sign_screen)
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

          // Header content - updated to match sign_screen.dart
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
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignInScreen(),
                          ),
                        ),
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
                        'Password Reset',
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
                        'Check your email & reset your password.',
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

          // Expanded area with verification card
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: 24,
            right: 24,
            child: Center(
              child: Transform.translate(
                offset: const Offset(0, -60),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        spreadRadius: 0,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "We've sent an email to:",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          fontFamily: '.SF Pro Display',
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 5.4),
                      Text(
                        widget.email,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          fontFamily: '.SF Pro Display',
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Image.asset(
                        'assets/images/email.png',
                        width: 70,
                        height: 70,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Didn't get the email?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          fontFamily: '.SF Pro Display',
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 5.4),
                      TextButton(
                        onPressed:
                            _resendCountdown == 0 ? _resendResetEmail : null,
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(EdgeInsets.zero),
                          minimumSize: MaterialStateProperty.all(Size.zero),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          splashFactory: NoSplash.splashFactory,
                          overlayColor:
                              MaterialStateProperty.all(Colors.transparent),
                          foregroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                                  (states) {
                            return _resendCountdown == 0
                                ? Colors.black
                                : const Color(0xFF666666);
                          }),
                        ),
                        child: _isChecking
                            ? const SizedBox(
                                height: 15,
                                width: 15,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : Text(
                                _resendCountdown > 0
                                    ? "Resend in ${_resendCountdown}s"
                                    : "Resend",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: '.SF Pro Display',
                                  color: _resendCountdown == 0
                                      ? Colors.black
                                      : const Color(0xFF666666),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Error message - positioned below the card
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).size.height * 0.25 - 40,
            child: Visibility(
              visible: _showErrorMessage,
              child: const Center(
                child: Text(
                  'Please check your inbox for the password reset link.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFF6565),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    fontFamily: '.SF Pro Display',
                  ),
                ),
              ),
            ),
          ),

          // White box at bottom - OUTSIDE of SafeArea
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

          // Next button - OUTSIDE of SafeArea
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
                onPressed: _isChecking
                    ? null
                    : () {
                        _verifyAndProceed();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  minimumSize: Size(double.infinity, 56),
                ),
                child: _isChecking
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
