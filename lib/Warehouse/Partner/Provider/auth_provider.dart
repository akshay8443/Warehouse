import 'dart:async';
import 'package:Lisofy/Warehouse/Partner/verify_otp_screen.dart';
import 'package:Lisofy/Warehouse/Partner/partner_registration_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;
        String? p = user?.phoneNumber.toString();
        if (kDebugMode) {
          print("ppp pp${p!}");
        }

        if (user != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userEmail', user.email ?? '');
          await prefs.setString('userName', user.displayName ?? '');
          await prefs.setBool('isLoggedIn', true);
          await prefs.setBool('isUserLoggedIn', false);

          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => const PartnerRegistrationScreen(
                        phone: '',
                      )),
              (route) => false,
            );
          }
          Fluttertoast.showToast(
              msg: "Signed in...",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      }
    } catch (e) {
      setErrorMessage('Something went wrong. Please try again.');
    } finally {
      setLoading(false);
    }
  }

  // Future<void> verifyPhoneNumber(String phoneNumber, BuildContext context) async {
  //   setLoading(true);
  //   try {
  //     await _auth.verifyPhoneNumber(
  //       phoneNumber: phoneNumber,
  //       verificationCompleted: (PhoneAuthCredential credential) async {
  //         await _auth.signInWithCredential(credential);
  //         setLoading(false);
  //       },
  //       verificationFailed: (FirebaseAuthException e) {
  //         setErrorMessage(e.message);
  //         setLoading(false);
  //       },
  //       codeSent: (String verificationId, int? resendToken) {
  //         print("verificationId generated: $verificationId");
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => VerifyOtpScreen(
  //               verificationId: verificationId,
  //               phoneNumber: phoneNumber,
  //             ),
  //           ),
  //         );
  //       },
  //       codeAutoRetrievalTimeout: (String verificationId) {
  //         setLoading(false);
  //       },
  //       timeout: const Duration(seconds: 60),
  //     );
  //   } catch (e) {
  //     setErrorMessage('Failed to verify phone number. Please try again.');
  //     setLoading(false);
  //   }
  // }

  Future<void> verifyPhoneNumber(
      String phoneNumber, BuildContext context) async {
    setLoading(true);
    try {
      // Store phone number for later use
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('phoneNumber', phoneNumber);
      await prefs.setString('phone', phoneNumber);

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential);
            debugPrint("Auto-verification completed.");
          } catch (e) {
            debugPrint("Auto-verification failed: $e");
          }
          setLoading(false);
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint("Verification failed: ${e.code} - ${e.message}");
          setErrorMessage(e.message ?? "Verification failed.");
          setLoading(false);
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint("OTP code sent. VerificationId: $verificationId");

          setLoading(false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyOtpScreen(
                verificationId: verificationId,
                phoneNumber: phoneNumber,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint("Code auto-retrieval timed out.");
          setLoading(false);
        },
      );
    } catch (e) {
      debugPrint("Exception occurred during phone verification: $e");
      setErrorMessage('Something went wrong. Please try again.');
      setLoading(false);
    }
  }
}
