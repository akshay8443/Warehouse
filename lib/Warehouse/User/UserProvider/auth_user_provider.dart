import 'dart:async';
import 'package:Lisofy/Warehouse/User/getuserlocation.dart';
import 'package:Lisofy/Warehouse/User/userverifyotp.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthUserProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _showAll = false;
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  bool get isLoading => _isLoading;
  bool get isResending => _isResending;
  String? get errorMessage => _errorMessage;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setResending(bool value) {
    _isResending = value;
    notifyListeners();
  }

  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    setLoading(true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setLoading(false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', user.email ?? '');
        await prefs.setString('Name', user.displayName ?? '');
        await prefs.setBool('isUserLoggedIn', true);
        await prefs.setBool('isLoggedIn', false);

        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const GetUserLocation()),
            (route) => false,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Signed in successfully with ${user.email}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setErrorMessage('Something went wrong. Please try again.');
    } finally {
      if (context.mounted) {
        setLoading(false);
      }
    }
  }

  Future<void> verifyPhoneNumber(
      String phoneNumber, BuildContext context) async {
    setErrorMessage(null);
    setLoading(true);

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),

        // ✅ Auto Verification (only on some devices)
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            final userCredential = await _auth.signInWithCredential(credential);
            final idToken = await userCredential.user?.getIdToken();

            if (idToken != null) {
              await saveToPrefs("firebaseToken", idToken);
              await saveToPrefs("phone", phoneNumber);
            }

            if (kDebugMode) {
              print(" Firebase Token (auto verification): $idToken");
            }

            setLoading(false);
            // Navigate to home or call your login API here
          } catch (e) {
            if (kDebugMode) {
              print("Auto-verification error: $e");
            }
            setLoading(false);
          }
        },

        // ❌ Failed to verify
        verificationFailed: (FirebaseAuthException e) {
          if (kDebugMode) {
            print("❌ Firebase verification failed: ${e.code} - ${e.message}");
          }
          setErrorMessage(_phoneAuthErrorMessage(e));
          setLoading(false);
        },

        // 📩 Code sent (OTP)
        codeSent: (String verificationId, int? resendToken) async {
          setLoading(false);

          String newPhone = phoneNumber;
          if (newPhone.startsWith("+91")) {
            newPhone = newPhone.replaceFirst("+91", "");
          }

          await saveToPrefs("phoneNumber", phoneNumber);
          await saveToPrefs("phone", phoneNumber);

          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserVerifyOtp.userVerifyOtp(
                verificationId: verificationId,
                phoneNumber: newPhone,
              ),
            ),
          );
        },

        // 🔁 Auto-retrieval timeout
        codeAutoRetrievalTimeout: (String verificationId) {
          setLoading(false);
          if (kDebugMode) {
            print("⌛️ Code auto retrieval timed out");
          }
        },
      );
    } catch (e, stackTrace) {
      setErrorMessage('Failed to verify phone number. Please try again.');
      setLoading(false);
      if (kDebugMode) {
        print("🚫 Error in verifyPhoneNumber: $e");
        print(stackTrace);
      }
    }
  }

  String _phoneAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Please enter a valid mobile number.';
      case 'too-many-requests':
        return 'Too many OTP requests. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      case 'app-not-authorized':
        return 'This app is not authorized for Firebase OTP. Please check Firebase SHA/package setup.';
      case 'captcha-check-failed':
      case 'missing-client-identifier':
        return 'Firebase app verification failed. Please try again or check Firebase setup.';
      case 'quota-exceeded':
        return 'OTP quota exceeded. Please try again later.';
      default:
        return e.message ?? 'Failed to send OTP. Please try again.';
    }
  }

// Helper function to store string in SharedPreferences
  Future<void> saveToPrefs(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  ///for Measurements class show more details
  bool get showAll => _showAll;

  void toggleShowAll() {
    _showAll = !_showAll;
    notifyListeners();
  }
}
