import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/signin.dart';
import 'package:fitness_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/sign_screen.dart';
import 'package:fitness_app/core/widgets/responsive_scaffold.dart';
import 'package:fitness_app/Features/onboarding/presentation/screens/questions/gender_screen.dart';

class VerificationScreen extends StatefulWidget {
  final String email;

  const VerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
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
    // Start periodic checking for email verification
    _startVerificationCheck();
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

  void _startVerificationCheck() {
    // Check immediately
    _checkEmailVerification();

    // Then check every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkEmailVerification();
    });
  }

  Future<void> _checkEmailVerification() async {
    if (_isChecking) return;

    setState(() {
      _isChecking = true;
    });

    try {
      // Get the current user or try to sign in properly if needed
      final currentUser = _auth.getCurrentUser();

      // If we have a user, check verification status
      if (currentUser != null) {
        // For Firebase, this will reload the user to get fresh data
        if (currentUser is User) {
          await currentUser.reload();
        }

        // Check if email is verified
        final isVerified = _auth.isEmailVerified();
        print(
            'Periodic check - verification status: $isVerified for ${widget.email}');

        if (isVerified && !_isVerified) {
          // Email was just verified
          setState(() {
            _isVerified = true;
          });

          // Cancel the timer as we don't need to check anymore
          _timer?.cancel();

          // No SnackBar notification to avoid unwanted popups
        }
      } else {
        print('No user found during periodic check, reinitializing...');
        // Try to reinitialize the user
        await _initializeUser();
      }
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  Future<void> _resendVerificationEmail() async {
    try {
      setState(() {
        _isChecking = true;
      });

      // Get the current user
      final currentUser = _auth.getCurrentUser();

      if (currentUser == null) {
        // Try to reinitialize the user
        await _initializeUser();

        // No SnackBar notification to avoid unwanted popups
        return;
      }

      // Send verification email
      await _auth.sendEmailVerification();
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

          // Header content (back arrow and progress bar) - Updated to match gender_screen.dart
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
                            builder: (context) => const SignScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 40),
                          child: LinearProgressIndicator(
                            value: 2 / 13,
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
                        'Verification',
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
                        'Check your email and verify your account.',
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

          // Verification content - rest of the screen
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: 24,
            right: 24,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
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
                      "We've sent a verification link to:",
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
                      onPressed: _resendCountdown == 0
                          ? _resendVerificationEmail
                          : null,
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.zero),
                        minimumSize: MaterialStateProperty.all(Size.zero),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        splashFactory: NoSplash.splashFactory,
                        overlayColor:
                            MaterialStateProperty.all(Colors.transparent),
                        foregroundColor:
                            MaterialStateProperty.resolveWith<Color>((states) {
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

          // Error message - positioned below the card
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).size.height * 0.25 - 40,
            child: Visibility(
              visible: _showErrorMessage,
              child: const Center(
                child: Text(
                  'Your email hasn\'t been verified yet.\nPlease check your inbox.',
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
                onPressed: () {
                  _verifyAndProceed();
                },
                child: const Text(
                  'Verify',
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
        ],
      ),
    );
  }

  Future<void> _verifyAndProceed() async {
    setState(() {
      _isChecking = true;
      _showErrorMessage = false;
    });

    try {
      // Make sure the user exists in the mock service
      await _initializeUser();

      // Force a check of the verification status
      await _checkEmailVerification();

      // Get the current user
      final currentUser = _auth.getCurrentUser();

      // If we have a user, check verification status
      if (currentUser != null) {
        // For Firebase, this will reload the user to get fresh data
        if (currentUser is User) {
          await currentUser.reload();
        }

        // Check if email is verified - print the result for debugging
        final isVerified = _auth.isEmailVerified();
        print('Verification check result: $isVerified for ${widget.email}');

        setState(() {
          _isVerified = isVerified;
        });

        if (isVerified) {
          // Email is verified, proceed to gender screen
          if (mounted) {
            print('Email verified, proceeding to gender screen');
            // Navigate to gender screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const GenderScreen(),
              ),
            );
          }
        } else {
          // For testing purposes in mock mode, force verification and proceed
          if (AuthServiceFactory.useMockAuth) {
            print('TEST MODE: Forcing verification and proceeding');

            // Force the email to be verified in the mock service
            final mockAuth = _auth as MockAuthService;
            await mockAuth.forceVerifyEmail(widget.email);

            // Navigate to gender screen
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const GenderScreen(),
                ),
              );
            }
          } else {
            // Email is not verified, show error message
            if (mounted) {
              print('Email not verified, showing error message');
              setState(() {
                _showErrorMessage = true;
              });
            }
          }
        }
      } else {
        // No user found, try to create one in test mode
        if (AuthServiceFactory.useMockAuth) {
          print('TEST MODE: Creating and verifying user');

          // Force the email to be verified in the mock service
          final mockAuth = _auth as MockAuthService;
          await mockAuth.forceVerifyEmail(widget.email);

          // Navigate to gender screen
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const GenderScreen(),
              ),
            );
          }
        } else {
          // No user and not in test mode, show error
          if (mounted) {
            setState(() {
              _showErrorMessage = true;
            });
          }
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
}
