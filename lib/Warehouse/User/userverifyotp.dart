import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:Lisofy/Warehouse/Partner/partner_registration_screen.dart';
import 'package:Lisofy/Warehouse/User/UserProvider/photo_provider.dart';
import 'package:Lisofy/Warehouse/User/getuserlocation.dart';
import 'package:Lisofy/Warehouse/User/models/user_data_model.dart';
import 'package:Lisofy/generated/l10n.dart';
import 'package:Lisofy/resources/app_theme.dart';
import 'package:Lisofy/resources/ImageAssets/ImagesAssets.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sms_autofill/sms_autofill.dart';

class UserVerifyOtp extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const UserVerifyOtp.userVerifyOtp(
      {super.key, required this.verificationId, required this.phoneNumber});
  @override
  State<UserVerifyOtp> createState() => UserVerifyOtpState();
}

class UserVerifyOtpState extends State<UserVerifyOtp> {
  String smsCode = '';
  String? _errorMessage;
  bool isLoading = false;

  // Future<void> _verifyOtp() async {
  //   if (!mounted) return;
  //
  //   setState(() {
  //     isLoading = true;
  //     _errorMessage = null;
  //   });
  //
  //   String otp = _otpController.text.trim();
  //
  //   if (otp.length != 6) {
  //     setState(() {
  //       _errorMessage = 'Please enter a valid 6-digit OTP.';
  //       isLoading = false;
  //     });
  //     return;
  //   }
  //
  //   try {
  //     print(" Starting Firebase OTP verification");
  //     print(" verificationId: ${widget.verificationId}");
  //     print(" OTP entered: $otp");
  //
  //     PhoneAuthCredential credential = PhoneAuthProvider.credential(
  //       verificationId: widget.verificationId,
  //       smsCode: otp,
  //     );
  //
  //     //  Firebase sign in with OTP
  //     UserCredential result = await FirebaseAuth.instance.signInWithCredential(credential);
  //
  //     if (result.user != null) {
  //       SharedPreferences prefs = await SharedPreferences.getInstance();
  //       print(" Firebase OTP Verified: UID = ${result.user!.uid}");
  //
  //       // 🔐 Print Firebase ID Token here
  //       String? idToken = await result.user?.getIdToken();
  //       print("🔐 Firebase ID Token: $idToken");
  //
  //       //  Now call your backend API for login/registration
  //       final response = await http.post(Uri.parse(
  //           'https://xpacesphere.com/api/Register/Registration?mobile=${widget.phoneNumber}'));
  //
  //       print(" API response: ${response.statusCode}");
  //       print(" API body: ${response.body}");
  //
  //       if (response.statusCode == 200) {
  //         final data = jsonDecode(response.body);
  //
  //         if (data['message'] == "Register Successfully") {
  //           await _storeUserData(true);
  //           trackButtonClick('OtpVerifyButton');
  //           if (mounted) {
  //             _navigateTo(context, PartnerRegistrationScreen(phone: widget.phoneNumber));
  //           }
  //         } else if (data['message'] == "Data retrieved successfully") {
  //           List<UserData> userData = (data['data'] as List)
  //               .map((e) => UserData.fromJson(e))
  //               .toList();
  //
  //           if (userData.isNotEmpty) {
  //             if (mounted) await _storeUserDetails(context, userData.first);
  //             if (mounted) _navigateTo(context, const GetUserLocation());
  //           } else {
  //             setError("User data not found.");
  //           }
  //         } else {
  //           setError("Unexpected response: ${data['message']}");
  //         }
  //       } else {
  //         setError("API error: ${response.statusCode}");
  //       }
  //     } else {
  //       setError("Firebase user is null. Something went wrong.");
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     print(" FirebaseAuthException: ${e.code} - ${e.message}");
  //     String errorMsg;
  //     switch (e.code) {
  //       case 'invalid-verification-code':
  //         errorMsg = 'Invalid OTP entered.';
  //         break;
  //       case 'session-expired':
  //         errorMsg = 'OTP session expired. Please request a new OTP.';
  //         break;
  //       case 'invalid-verification-id':
  //         errorMsg = 'Verification failed. Please try again.';
  //         break;
  //       default:
  //         errorMsg = 'Firebase error: ${e.message}';
  //     }
  //     setError(errorMsg);
  //   } catch (e) {
  //     print(" Unexpected Error: $e");
  //     setError("An unexpected error occurred.");
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         isLoading = false;
  //       });
  //     }
  //   }
  // }
  final TextEditingController _otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final List<String> _demoImages = [
  //   'https://xpacesphere.com/Content/NewFolder/warehouse_23.jpg',
  //   'https://xpacesphere.com/Content/NewFolder/warehouse_20.jpg',
  //   'https://xpacesphere.com/Content/NewFolder/warehouse_18.jpg',
  //   'https://xpacesphere.com/Content/NewFolder/warehouse_19.jpg',
  //   'https://xpacesphere.com/Content/NewFolder/warehouse_14.jpg'
  // ];

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
  //
  //     // Send token and phone number to backend
  //     final url = Uri.parse('http://65.2.82.196:8080/api/v1/auth/login');
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
  //       print('Login success: $responseData');
  //       print("➡️ Navigating to PartnerRegistrationScreen...");
  //       // ✅ Navigate to PartnerRegistrationScreen
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => PartnerRegistrationScreen(phone: '',)),
  //       );
  //     } else {
  //       print('API error: $responseData');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(responseData['message'] ?? 'Verification failed')),
  //       );
  //     }
  //   } catch (e) {
  //     print(' Error during verification: $e');
  //     // ScaffoldMessenger.of(context).showSnackBar(
  //     //   SnackBar(content: Text('Verification Successfully')),
  //     // );
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Verification Successful'),
  //         duration: Duration(seconds: 2), // optional
  //       ),
  //     );
  //   }
  // }

  // Future<void> _verifyOtp({
  //   required String verificationId,
  //   required String smsCode,
  //   required BuildContext context,
  // }) async {
  //   try {
  //     final credential = PhoneAuthProvider.credential(
  //       verificationId: verificationId,
  //       smsCode: smsCode,
  //     );
  //     // Sign in with Firebase
  //     final userCredential = await _auth.signInWithCredential(credential);
  //     final idToken = await userCredential.user?.getIdToken();
  //
  //     if (idToken == null) {
  //       throw Exception("Failed to retrieve ID token");
  //     }
  //
  //     final prefs = await SharedPreferences.getInstance();
  //     final phoneNumber = prefs.getString('phone') ?? "";
  //
  //     final response = await http.post(
  //       Uri.parse('http://15.206.189.22:8080/api/v1/auth/login'),
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
  //       debugPrint('✅ Login success: $responseData');
  //
  //       if (!context.mounted) return;
  //
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //           //builder: (_) => PartnerRegistrationScreen(phone: ''),
  //           builder: (_) => PartnerRegistrationScreen(phone: 'phoneNumber',),
  //         ),
  //       );
  //     } else {
  //       debugPrint('❌ API Error: $responseData');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(responseData['message'] ?? 'Login failed')),
  //       );
  //     }
  //   } catch (e) {
  //     debugPrint('🔥 Exception during OTP verification: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Verification failed, please try again.'),
  //         duration: Duration(seconds: 2),
  //       ),
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
      return;
    }

    setLoading(true);
    setError('');

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
      final phoneNumber =
          prefs.getString('phone') ?? '+91${widget.phoneNumber}';

      if (phoneNumber.isEmpty) {
        throw Exception("Phone number not found. Please login again.");
      }

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
              builder: (_) => PartnerRegistrationScreen(phone: phoneNumber),
            ),
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
      if (!context.mounted) return;
      _showSnackBar(
        context,
        'OTP verified, but login server is not responding. Please try again.',
      );
    } on SocketException catch (e) {
      debugPrint('🔥 Login server network error: $e');
      if (!context.mounted) return;
      _showSnackBar(
        context,
        'OTP verified, but login server is unreachable. Please check server/network.',
      );
    } catch (e) {
      debugPrint('🔥 Exception during OTP verification: $e');
      if (!context.mounted) return;
      _showSnackBar(context, e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setLoading(false);
    }
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

  void setError(String message) {
    if (mounted) {
      setState(() {
        _errorMessage = message.isEmpty ? null : message;
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

  Future<void> _storeUserDetails(BuildContext context, UserData user) async {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final profileUrl = "https://xpacesphere.com${user.userProfile}";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isUserLoggedIn', true);
    await prefs.setString('phone', widget.phoneNumber);
    await prefs.setString('name', user.name);
    await prefs.setString('email', user.mailid);
    await prefs.setString('profileImage', user.userProfile);
    if (kDebugMode) {
      print("ImageUrl: ${user.userProfile}");
    }
    profileProvider.setProfileImageUrl(profileUrl);
    if (kDebugMode) {
      print("Updated Profile URL: https://xpacesphere.com${user.userProfile}");
    }
  }

  Future<void> _storeUserData(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isUserLoggedIn', isLoggedIn);
    await prefs.setString('phone', widget.phoneNumber);
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => screen),
      (Route<dynamic> route) => false,
    );
  }

  Timer? _timer;
  int _start = 30;
  bool _isButtonDisabled = true;

  @override
  void initState() {
    super.initState();
    startTimer();
    listenForCode();
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

  /// Listen for OTP automatically
  void listenForCode() async {
    await SmsAutoFill().listenForCode();
  }

  /// This method gets triggered when an OTP is received
  void codeUpdated(String? code) {
    setState(() {
      _otpController.text = code ?? "";
    });
    if (_otpController.text.isNotEmpty) {
      if (kDebugMode) {
        print("Received OTP: $_otpController");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SafeArea(
              child: Column(
                children: [
                  Container(
                    color: AppTheme.primary,
                    height: screenHeight * 0.15,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: screenHeight * 0.015,
                        left: screenWidth * 0.03,
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                  margin: EdgeInsets.only(
                                      left: screenWidth * 0.045),
                                  child: Text(
                                    S.of(context).confirm_otp,
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
                                    "${S.of(context).otp_sent_to}: ${widget.phoneNumber}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.04,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Image.asset(
                              "assets/images/faceid.png",
                              height: screenHeight * 0.12,
                              width: screenHeight * 0.12,
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
                        padding: const EdgeInsets.only(top: 0),
                        child: SingleChildScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    EdgeInsets.only(top: screenHeight * 0.0),
                                child: Image.asset(
                                  ImageAssets.verifyOtpBanner,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: screenHeight * 0.05,
                                    left: screenWidth * 0.04,
                                    right: screenWidth * 0.04),
                                child: Column(
                                  children: [
                                    Center(
                                      child: PinCodeTextField(
                                        controller: _otpController,
                                        appContext: context,
                                        length: 6,
                                        onChanged: (value) {
                                          if (kDebugMode) {
                                            print(value);
                                          }
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
                                        onCompleted: (value) {
                                          FocusScope.of(context).unfocus();
                                          _verifyOtp(
                                            verificationId: widget
                                                .verificationId, // or wherever you're storing it
                                            smsCode: value, // OTP entered
                                            context: context,
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.002),
                                    if (_errorMessage != null)
                                      Text(
                                        _errorMessage!,
                                        style:
                                            const TextStyle(color: Colors.red),
                                      ),
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
                                                  // Handle resend OTP logic here
                                                },
                                          child: Text(
                                            S.of(context).resend_otp,
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
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();
                                    _verifyOtp(
                                      verificationId: widget
                                          .verificationId, // or wherever you're storing it
                                      //smsCode: smsCode,                         // OTP entered
                                      smsCode: _otpController.text.trim(),
                                      context: context,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: AppTheme.primary,
                                    minimumSize: Size(
                                        double.infinity, screenHeight * 0.06),
                                  ),
                                  child: Text(S.of(context).verify_proceed),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.017),
                              SizedBox(height: screenHeight * 0.1),
                              Text(
                                "By continuing, you agree to our Terms and Conditions",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.025,
                                  color: AppTheme.primary,
                                ),
                              ),
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

  void trackButtonClick(String buttonName) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'button_click',
      parameters: {
        'VerifyOtp': buttonName,
      },
    );
  }
}
