import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:Lisofy/Warehouse/Partner/partner_registration_screen.dart';
import 'package:Lisofy/resources/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../User/getuserlocation.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  const VerifyOtpScreen(
      {super.key, required this.verificationId, required this.phoneNumber});
  @override
  VerifyOtpScreenState createState() => VerifyOtpScreenState();
}

class VerifyOtpScreenState extends State<VerifyOtpScreen> {
  String? _errorMessage;
  bool isLoading = false;
  final TextEditingController _otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Future<void> _verifyOtp() async {
  //   setState(() {
  //     isLoading = true;
  //     _errorMessage = '';
  //   });
  //
  //   String otp = _otpController.text.trim();
  //
  //   if (otp.isEmpty || otp.length < 6) {
  //     setState(() {
  //       isLoading = false;
  //       _errorMessage = 'Please enter a 6-digit OTP.';
  //     });
  //     return;
  //   }
  //
  //   PhoneAuthCredential credential = PhoneAuthProvider.credential(
  //     verificationId: widget.verificationId,
  //     smsCode: otp,
  //   );
  //
  //   try {
  //     // Sign in using Firebase
  //     await _auth.signInWithCredential(credential);
  //
  //     //  API call after Firebase login
  //     String url = 'http://xpacesphere.com/api/Register/Registration?mobile=${widget.phoneNumber}';
  //     final response = await http.post(Uri.parse(url)).timeout(const Duration(seconds: 10));
  //
  //     debugPrint("📡 Registration API: $url");
  //     debugPrint("📦 Response status: ${response.statusCode}");
  //     debugPrint("📦 Response body: ${response.body}");
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       SharedPreferences prefs = await SharedPreferences.getInstance();
  //       await prefs.setBool('isLoggedIn', true);
  //       await prefs.setString('phone', widget.phoneNumber);
  //
  //       if (!mounted) return;
  //
  //       Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => PartnerRegistrationScreen(phone: widget.phoneNumber),
  //         ),
  //             (Route<dynamic> route) => false,
  //       );
  //     } else {
  //       setState(() {
  //         _errorMessage = 'Unexpected server response: ${response.statusCode}';
  //       });
  //     }
  //     } on FirebaseAuthException catch (e) {
  //     print("FirebaseAuthException:");
  //     print("Code    : ${e.code}");
  //     print("Message : ${e.message}");
  //
  //     setState(() {
  //       if (e.code == 'invalid-verification-code') {
  //         _errorMessage = 'Invalid OTP entered. Please check and try again.';
  //       } else if (e.code == 'session-expired') {
  //         _errorMessage = 'The OTP has expired. Please request a new one.';
  //       } else {
  //         _errorMessage = 'Firebase error: ${e.message}';
  //       }
  //     });
  //   } on SocketException catch (e) {
  //     print(" SocketException: ${e.message}");
  //     setState(() {
  //       _errorMessage = 'Network error. Please check your internet connection.';
  //     });
  //   } on TimeoutException catch (e) {
  //     print(" TimeoutException: ${e.message}");
  //     setState(() {
  //       _errorMessage = 'Server timeout. Please try again later.';
  //     });
  //   } catch (e, stackTrace) {
  //     print(" Unknown Error:");
  //     print("Error   : $e");
  //     print("Stack   : $stackTrace");
  //
  //     setState(() {
  //       _errorMessage = 'Unexpected error occurred: ${e.toString()}';
  //     });
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }}
  String smsCode = '';

  // Future<void> _verifyOtp({
  //   required String verificationId,
  //   required String smsCode,
  //   required BuildContext context,
  // }) async {
  //   try {
  //     // Create credential
  //     final credential = PhoneAuthProvider.credential(
  //       verificationId: verificationId,
  //       smsCode: smsCode,
  //     );
  //
  //     // Sign in
  //     final userCredential = await _auth.signInWithCredential(credential);
  //
  //     // Get token
  //     final idToken = await userCredential.user?.getIdToken();
  //     if (idToken == null) throw Exception("ID Token not found");
  //
  //     // Read phone number from SharedPreferences
  //     final prefs = await SharedPreferences.getInstance();
  //     final phoneNumber = prefs.getString('phone') ?? "";
  //     await prefs.setString('phone', widget.phoneNumber);
  //
  //     // Send token and phone number to backend
  //     // final url = Uri.parse('https://9eb9aaf9a259.ngrok-free.app/api/v1/auth/login');
  //     final url = Uri.parse('http://15.206.189.22:8080/api/v1/auth/login');
  //     final response = await http.post(
  //       url,
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         'firebaseToken': idToken,
  //         'phone': phoneNumber,
  //       }),
  //     );
  //
  //     final responseData = jsonDecode(response.body);
  //
  //     if (response.statusCode == 200) {
  //       print('✅ Login success: $responseData');
  //
  //       // ✅ Navigate to PartnerRegistrationScreen
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => PartnerRegistrationScreen(phone: 'phoneNumber',)),
  //       );
  //     } else {
  //       print('API error: $responseData');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(responseData['message'] ?? 'Verification failed')),
  //       );
  //     }
  //   } catch (e) {
  //     print('Error during verification: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Something went wrong.')),
  //     );
  //   }
  // }

  Future<void> _verifyOtp({
    required String verificationId,
    required String smsCode,
    required BuildContext context,
  }) async {
    if (isLoading) return;

    final enteredOtp = smsCode.trim();
    if (enteredOtp.length != 6) {
      setError('Please enter a valid 6-digit OTP.');
      if (context.mounted) {
        _showSnackBar(context, 'Please enter a valid 6-digit OTP.');
      }
      return;
    }

    setLoading(true);
    setError(null);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: enteredOtp,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        throw Exception("Failed to retrieve ID token");
      }

      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString('phone') ??
          prefs.getString('phoneNumber') ??
          widget.phoneNumber;

      if (phoneNumber.isEmpty) {
        throw Exception("Phone number not found. Please login again.");
      }

      await prefs.setString('phone', phoneNumber);
      await prefs.setString('phoneNumber', phoneNumber);

      final response = await http
          .post(
            Uri.parse('http://3.110.172.156:8083/api/v1/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'firebaseToken': idToken,
              'phone': phoneNumber,
            }),
          )
          .timeout(const Duration(seconds: 20));

      final responseData = _decodeResponse(response.body);
      debugPrint("📥 Response: $responseData");

      if (response.statusCode == 200) {
        debugPrint('✅ Login success');
        await prefs.setBool('isLoggedIn', true);

        // Extract and save userId if present
        final userId =
            responseData['user']?['id']; // adjust key if it's different
        if (userId != null) {
          await prefs.setInt('userId', userId);
          debugPrint("💾 User ID saved: $userId");

          if (!context.mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => GetUserLocation()),
          );
        } else {
          // New user – redirect to registration
          debugPrint("🆕 New user. Navigating to registration.");

          if (!context.mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => PartnerRegistrationScreen(phone: phoneNumber)),
          );
        }
      } else {
        debugPrint('❌ API Error: $responseData');
        final message = responseData['message']?.toString() ??
            'Login failed. Server returned ${response.statusCode}.';
        if (!context.mounted) return;
        _showSnackBar(context, message);
      }
    } on FirebaseAuthException catch (e) {
      debugPrint(
          '🔥 Firebase OTP verification failed: ${e.code} - ${e.message}');
      setError(_firebaseOtpErrorMessage(e));
    } on TimeoutException {
      await _continueAfterLoginServerFailure(
        'OTP verified, but login server is not responding.',
      );
    } on SocketException catch (e) {
      debugPrint('🔥 Login server network error: $e');
      await _continueAfterLoginServerFailure(
        'OTP verified, but login server is unreachable.',
      );
    } on http.ClientException catch (e) {
      debugPrint('🔥 Login server client error: $e');
      await _continueAfterLoginServerFailure(
        'OTP verified, but login server is unreachable.',
      );
    } catch (e) {
      debugPrint('🔥 Exception during OTP verification: $e');
      if (!context.mounted) return;
      _showSnackBar(context, e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setLoading(false);
    }
  }

  Future<void> _continueAfterLoginServerFailure(String message) async {
    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phone') ??
        prefs.getString('phoneNumber') ??
        widget.phoneNumber;

    await prefs.setString('phone', phoneNumber);
    await prefs.setString('phoneNumber', phoneNumber);

    if (!mounted) return;
    _showSnackBar(context, '$message Please complete registration.');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PartnerRegistrationScreen(phone: phoneNumber),
      ),
    );
  }

  Future<void> _onVerifyPressed() async {
    FocusScope.of(context).unfocus();
    await _verifyOtp(
      verificationId: widget.verificationId,
      smsCode: _otpController.text,
      context: context,
    );
  }

  Map<String, dynamic> _decodeResponse(String body) {
    if (body.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    return <String, dynamic>{'message': decoded.toString()};
  }

  String _firebaseOtpErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-verification-code':
        return 'Invalid OTP entered.';
      case 'session-expired':
        return 'OTP session expired. Please request a new OTP.';
      case 'invalid-verification-id':
        return 'OTP session is invalid. Please request a new OTP.';
      default:
        return e.message ?? 'OTP verification failed. Please try again.';
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void setError(String? message) {
    if (mounted) {
      setState(() {
        _errorMessage = message;
      });
    }
  }

  void setLoading(bool value) {
    if (mounted) {
      setState(() {
        isLoading = value;
      });
    }
  }

  Timer? _timer;
  int _start = 30;
  bool _isButtonDisabled = true;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _isButtonDisabled = true;
    _start = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_start > 0) {
          _start--;
        } else {
          _isButtonDisabled = false;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: AppTheme.primary,
            width: double.infinity,
            height: double.infinity,
            child: SafeArea(
              child: Column(
                children: [
                  Container(
                    color: AppTheme.primary,
                    height: screenHeight * 0.285,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: screenHeight * 0.015,
                        left: screenWidth * 0.03,
                      ),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_sharp,
                                  color: Colors.white),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              margin:
                                  EdgeInsets.only(left: screenWidth * 0.045),
                              child: Text(
                                "Confirm OTP",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.05,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              margin: EdgeInsets.only(
                                left: screenWidth * 0.045,
                                top: screenHeight * 0.01,
                              ),
                              child: Text(
                                "OTP has been sent to ${widget.phoneNumber}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.04,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              margin:
                                  EdgeInsets.only(right: screenWidth * 0.06),
                              child: Image.asset(
                                "assets/images/faceid.png",
                                height: screenHeight * 0.12,
                                width: screenHeight * 0.12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: screenWidth * 0.005),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(0),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 70, left: 40, right: 40),
                                child: Column(
                                  children: [
                                    Center(
                                      child: PinCodeTextField(
                                        controller: _otpController,
                                        appContext: context,
                                        length: 6,
                                        onChanged: (value) {},
                                        onCompleted: (value) {
                                          FocusScope.of(context).unfocus();
                                          _verifyOtp(
                                            verificationId:
                                                widget.verificationId,
                                            smsCode: value,
                                            context: context,
                                          );
                                        },
                                        pinTheme: PinTheme(
                                          errorBorderColor: Colors.red,
                                          shape: PinCodeFieldShape.box,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          fieldHeight: screenWidth * 0.12,
                                          fieldWidth: screenWidth * 0.12,
                                          activeFillColor: AppTheme.primary,
                                          selectedFillColor: AppTheme.primary,
                                          inactiveFillColor:
                                              Colors.grey.shade200,
                                          inactiveColor: Colors.grey.shade300,
                                          activeColor: AppTheme.primary,
                                          selectedColor: AppTheme.primary,
                                        ),
                                        keyboardType: TextInputType.number,
                                        animationType: AnimationType.slide,
                                        boxShadows: const [
                                          BoxShadow(
                                            color: Colors.white,
                                            blurRadius: 4,
                                          ),
                                        ],
                                        enableActiveFill: true,
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.002),
                                    if (_errorMessage != null)
                                      Text(
                                        _errorMessage!,
                                        style:
                                            const TextStyle(color: Colors.red),
                                      ),
                                    SizedBox(height: screenHeight * 0.002),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '$_start seconds',
                                          style: const TextStyle(
                                              color: AppTheme.primary),
                                        ),
                                        TextButton(
                                          onPressed: _isButtonDisabled
                                              ? null
                                              : () {
                                                  startTimer();
                                                },
                                          child: Text(
                                            'Resend OTP',
                                            style: TextStyle(
                                              color: _isButtonDisabled
                                                  ? Colors.grey
                                                  : AppTheme.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.07),
                              Container(
                                height: screenHeight * 0.06,
                                margin: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.03),
                                child: ElevatedButton(
                                  onPressed:
                                      isLoading ? null : _onVerifyPressed,
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: AppTheme.primary,
                                    disabledBackgroundColor: AppTheme.primary
                                        .withValues(alpha: 0.75),
                                    minimumSize: Size(
                                        double.infinity, screenHeight * 0.06),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: SpinKitCircle(
                                            color: Colors.white,
                                            size: 24.0,
                                          ),
                                        )
                                      : const Text('Verify & Proceed'),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.017),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    width: 100.0,
                                    height: 2,
                                    color: AppTheme.primary,
                                  ),
                                  SizedBox(width: screenHeight * 0.02),
                                  const Text(
                                    "or",
                                    style: TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: screenHeight * 0.02),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    width: 100.0,
                                    height: 2,
                                    color: AppTheme.primary,
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.017),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.lock,
                                      size: screenWidth * 0.025,
                                      color: AppTheme.primary),
                                  SizedBox(width: screenWidth * 0.01),
                                  Text(
                                    "Sign in with Password",
                                    style: TextStyle(
                                      color: AppTheme.primary,
                                      fontSize: screenWidth * 0.03,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.1),
                              Text(
                                "By signing in you agree to our",
                                style: TextStyle(
                                    color: AppTheme.primary,
                                    fontSize: screenWidth * 0.03),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Text(
                                "Terms and Conditions",
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.03,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.05),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
