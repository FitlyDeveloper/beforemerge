import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Abstract class defining the authentication service interface
abstract class AuthService {
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<void> createUserWithEmailAndPassword(String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerification();
  bool isEmailVerified();
  dynamic getCurrentUser();
  Future<bool> checkIfEmailExists(String email);
}

/// Mock User class for testing
class MockUser {
  final String uid;
  final String? email;
  final bool emailVerified;

  MockUser({required this.uid, this.email, this.emailVerified = false});
}

/// Mock implementation of AuthService for testing
class MockAuthService implements AuthService {
  bool _isVerified = false;
  String? _currentUserEmail;
  // Mock storage for existing emails
  final Map<String, bool> _existingEmails = {
    // Pre-populate with some test emails for easier testing
    'test@example.com': false,
    'verified@example.com': true,
  };

  // Add a flag to simulate network issues
  bool _simulateNetworkIssue = false;

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Validate email and password
    if (email.isEmpty) {
      throw Exception('Email cannot be empty');
    }
    if (password.isEmpty) {
      throw Exception('Password cannot be empty');
    }

    // Simulate authentication logic
    if (!email.contains('@')) {
      throw Exception('Invalid email format');
    }

    if (password.length < 6) {
      throw Exception('Password is too weak');
    }

    // Success case - in a real app, this would return user credentials
    _currentUserEmail = email;
    // Check if this email is verified in our storage
    _isVerified = _existingEmails[email] ?? false;
    print('Mock sign in successful for $email (verified: $_isVerified)');
  }

  @override
  Future<void> createUserWithEmailAndPassword(
      String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Validate email and password
    if (email.isEmpty) {
      throw Exception('Email cannot be empty');
    }
    if (password.isEmpty) {
      throw Exception('Password cannot be empty');
    }

    // Simulate user creation logic
    if (!email.contains('@')) {
      throw Exception('Invalid email format');
    }

    if (password.length < 6) {
      throw Exception('Password is too weak');
    }

    // Store the email as existing but unverified
    _existingEmails[email] = false;

    // Success case - in a real app, this would create and return user credentials
    _currentUserEmail = email;
    _isVerified = false;
    print('Mock user created for $email');

    // Automatically send verification email
    try {
      await sendEmailVerification();
      print('Verification email automatically sent after account creation');
    } catch (e) {
      print('Failed to send automatic verification email: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Validate email
    if (email.isEmpty) {
      throw Exception('Email cannot be empty');
    }

    if (!email.contains('@')) {
      throw Exception('Invalid email format');
    }

    // Success case - in a real app, this would send a password reset email
    print('Mock password reset email sent to $email');
  }

  @override
  Future<void> sendEmailVerification() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (_simulateNetworkIssue) {
      // Randomly simulate a network issue (for testing)
      throw Exception('Network error: Could not send verification email');
    }

    if (_currentUserEmail == null) {
      throw Exception('No user is signed in');
    }

    // In a real app, this would send an email
    print('Mock verification email sent to $_currentUserEmail');

    // For testing purposes, we'll store the email as existing but not verified
    _existingEmails[_currentUserEmail!] = false;

    // For demo purposes, automatically verify after 5 seconds
    // This simulates the user clicking the verification link
    Future.delayed(const Duration(seconds: 5), () {
      if (_currentUserEmail != null) {
        _existingEmails[_currentUserEmail!] = true;
        _isVerified = true;
        print(
            'Mock email automatically verified for $_currentUserEmail after 5 seconds');
      }
    });
  }

  @override
  bool isEmailVerified() {
    // If we have a current user, check if their email is verified in our mock storage
    if (_currentUserEmail != null) {
      final verified = _existingEmails[_currentUserEmail!] ?? false;
      print('Checking verification status for $_currentUserEmail: $verified');
      return verified;
    }
    print('No current user, verification status: $_isVerified');
    return _isVerified;
  }

  @override
  MockUser? getCurrentUser() {
    if (_currentUserEmail == null) return null;

    // Get the verification status from our storage
    final verified = _existingEmails[_currentUserEmail!] ?? false;

    // Return a mock user with the correct verification status
    return MockUser(
        uid: 'mock-uid', email: _currentUserEmail, emailVerified: verified);
  }

  @override
  Future<bool> checkIfEmailExists(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _existingEmails.containsKey(email);
  }

  // Method to ensure a user exists with the given email
  Future<void> ensureUserExists(String email) async {
    // Set the current user email
    _currentUserEmail = email;

    // If the email doesn't exist in our storage, add it
    if (!_existingEmails.containsKey(email)) {
      _existingEmails[email] = false;
      print('Added user $email to mock storage');
    }

    // Check if this email is verified in our storage
    _isVerified = _existingEmails[email] ?? false;
    print('User $email exists in mock storage (verified: $_isVerified)');

    // If not verified, automatically verify after 5 seconds
    if (!_isVerified) {
      // For demo purposes, automatically verify after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        _existingEmails[email] = true;
        _isVerified = true;
        print('Mock email automatically verified for $email after 5 seconds');
      });
    }
  }

  // Method to force verify an email (for testing purposes)
  Future<void> forceVerifyEmail(String email) async {
    // Set the current user email
    _currentUserEmail = email;

    // Add the email to our storage if it doesn't exist
    if (!_existingEmails.containsKey(email)) {
      _existingEmails[email] = false;
      print('Added user $email to mock storage');
    }

    // Force the email to be verified
    _existingEmails[email] = true;
    _isVerified = true;
    print('Forced verification for $email');
  }
}

/// Real Firebase implementation of AuthService
class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Firebase sign in successful for $email');
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  @override
  Future<void> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Firebase user created for $email');

      // Send verification email immediately after account creation
      if (userCredential.user != null) {
        await userCredential.user!.sendEmailVerification();
        print('Verification email sent to $email');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Firebase password reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is signed in');
    }

    try {
      // Force reload the user to get the latest state
      await user.reload();
      user = _auth.currentUser; // Get the refreshed user

      // Check if already verified to avoid unnecessary emails
      if (user!.emailVerified) {
        print('Email is already verified for ${user.email}');
        return;
      }

      // Send verification with custom settings
      await user.sendEmailVerification(ActionCodeSettings(
        url: 'https://fitly-5651e.firebaseapp.com/verify?email=${user.email}',
        handleCodeInApp: true,
        androidPackageName: 'com.fitly.app',
        androidInstallApp: true,
        androidMinimumVersion: '12',
        iOSBundleId: 'com.fitly.app',
      ));

      print('Verification email sent to ${user.email}');
    } on FirebaseAuthException catch (e) {
      print('Failed to send verification email: ${e.code} - ${e.message}');
      if (e.code == 'too-many-requests') {
        throw Exception('Too many attempts. Please try again later.');
      } else {
        throw _handleFirebaseAuthException(e);
      }
    } catch (e) {
      print('Unknown error sending verification email: $e');
      throw Exception('Failed to send verification email: $e');
    }
  }

  @override
  bool isEmailVerified() {
    User? user = _auth.currentUser;
    // If no user is signed in, they can't be verified
    if (user == null) {
      return false;
    }

    // Return the verification status
    return user.emailVerified;
  }

  @override
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  @override
  Future<bool> checkIfEmailExists(String email) async {
    try {
      // Use fetchSignInMethodsForEmail instead of attempting to sign in
      // This method is specifically designed to check if an email exists
      // without triggering security measures or sending emails
      final methods = await _auth.fetchSignInMethodsForEmail(email);

      // If there are sign-in methods available for this email, it exists
      return methods.isNotEmpty;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error checking email: ${e.code} - ${e.message}');
      if (e.code == 'invalid-email') {
        throw Exception('Invalid email format');
      }
      // For any other errors, assume the email doesn't exist
      return false;
    }
  }

  Exception _handleFirebaseAuthException(FirebaseAuthException e) {
    print('Firebase Auth Error: ${e.code} - ${e.message}');
    switch (e.code) {
      case 'invalid-email':
        return Exception('Invalid email format');
      case 'user-disabled':
        return Exception('This account has been disabled');
      case 'user-not-found':
        return Exception('No account found with this email');
      case 'wrong-password':
        return Exception('Incorrect password');
      case 'email-already-in-use':
        return Exception('An account already exists with this email');
      case 'weak-password':
        return Exception('Password is too weak');
      case 'operation-not-allowed':
        return Exception('This operation is not allowed');
      default:
        return Exception('Authentication failed: ${e.message}');
    }
  }
}

/// Factory class to get the appropriate auth service based on configuration
class AuthServiceFactory {
  // Set this to true to use mock auth for testing
  static final bool useMockAuth = true;

  static AuthService getAuthService() {
    if (useMockAuth) {
      return MockAuthService();
    } else {
      return FirebaseAuthService();
    }
  }
}

// Note: For mobile platforms, you would implement a real Firebase auth service
// in a separate file that's only imported on mobile platforms
