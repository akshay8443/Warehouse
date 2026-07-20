import 'package:Lisofy/resources/app_theme.dart';
import 'dart:convert';
import 'dart:io';
import 'package:Lisofy/Localization/languages.dart';
import 'package:Lisofy/Warehouse/Partner/document_upload.dart';
import 'package:Lisofy/Warehouse/User/notification_setting.dart';
import 'package:Lisofy/Warehouse/User/UserProvider/photo_provider.dart';
import 'package:Lisofy/Warehouse/User/UserProvider/rating_provider.dart';
import 'package:Lisofy/Warehouse/User/post_property_page.dart';
import 'package:Lisofy/Warehouse/User/userlogin.dart';
import 'package:Lisofy/Warehouse/User/website_viewer.dart';
import 'package:Lisofy/generated/l10n.dart';
import 'package:Lisofy/resources/ImageAssets/ImagesAssets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http_parser/http_parser.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});
  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  late String phone = '';
  late String name = '';
  String userFile = "";
  String email = "";
  @override
  void initState() {
    super.initState();
    getSharedPreference();
    final ratingProvider = Provider.of<RatingProvider>(context, listen: false);
    Future.microtask(() {
      ratingProvider.fetchUserFeedback(phone);
    });
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController additionalPhoneController =
      TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final String phoneNumber = '+917007221530';
  final TextEditingController _messageController = TextEditingController();
  Future<void> _logoutAndRedirect(BuildContext context) async {
    final navigator = Navigator.of(context);
    try {
      /// Sign out from Google
      await _googleSignIn.signOut();

      /// Sign out from Firebase Authentication (for phone auth)
      FirebaseAuth auth = FirebaseAuth.instance;
      User? currentUser = auth.currentUser;
      if (currentUser != null) {
        await auth.signOut();
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('email');
      await prefs.remove('phone');
      await prefs.remove('Name');
      await prefs.setBool('isUserLoggedIn', false);
      if (!context.mounted) return;
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const UserLogin()),
        (route) => false,
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error during logout: $e");
      }
    }
  }

  Future<bool> _showLogoutConfirmationDialog(BuildContext context) async {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.outline,
          title: Text(
            S.of(context).log_out,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: Row(
            children: [
              Image.asset(
                ImageAssets.appLogo,
                fit: BoxFit.fill,
                height: screenHeight * 0.06,
                width: screenWidth * 0.2,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  S.of(context).logout_confirmation,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                S.of(context).no,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text(
                S.of(context).yes,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  color: AppTheme.primary,
                  width: double.infinity,
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        color: AppTheme.primary,
                        height: screenHeight * 0.28,
                        child: const Text(
                          "",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: screenWidth * 0.005),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(0),
                              topRight: Radius.circular(screenWidth * 0.15),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(0),
                            child: SingleChildScrollView(
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: screenHeight * 0.14,
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.02,
                                  ),
                                  Container(
                                      color: AppTheme.primary,
                                      width: double.infinity,
                                      height: screenHeight * 0.18,
                                      child: Stack(
                                        children: [
                                          Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0, top: 5),
                                                child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      S
                                                          .of(context)
                                                          .looking_for_rent_your_properties,
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w800),
                                                    )),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0, top: 5),
                                                child: Row(
                                                  children: [
                                                    Image.asset(
                                                        "assets/images/CheckMark.png"),
                                                    Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          S
                                                              .of(context)
                                                              .verified_property_and_owner,
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0, top: 5),
                                                child: Row(
                                                  children: [
                                                    Image.asset(
                                                        "assets/images/CheckMark.png"),
                                                    Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          S
                                                              .of(context)
                                                              .larger_collection_of_warehouses,
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    PageRouteBuilder(
                                                      transitionDuration:
                                                          const Duration(
                                                              milliseconds:
                                                                  500),
                                                      pageBuilder: (_, __,
                                                              ___) =>
                                                          const PostYourPropertyScreen(),
                                                      transitionsBuilder: (_,
                                                          animation,
                                                          __,
                                                          child) {
                                                        return SlideTransition(
                                                          position: Tween<
                                                              Offset>(
                                                            begin: const Offset(
                                                                0, 1),
                                                            end: const Offset(
                                                                0, 0),
                                                          ).animate(
                                                              CurvedAnimation(
                                                            parent: animation,
                                                            curve:
                                                                Curves.easeOut,
                                                          )),
                                                          child: child,
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 15.0, top: 12),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Container(
                                                      height:
                                                          screenHeight * 0.03,
                                                      width: screenWidth * 0.6,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(7),
                                                      ),
                                                      child: Center(
                                                          child: Text(
                                                        S
                                                            .of(context)
                                                            .post_your_property_free,
                                                        style: const TextStyle(
                                                            color: AppTheme
                                                                .primary,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            fontSize: 8),
                                                      )),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                          Align(
                                              alignment: Alignment.centerRight,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Image.asset(
                                                  "assets/images/Ellipse.png",
                                                ),
                                              )),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 6.0),
                                            child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Image.asset(
                                                    "assets/images/house1.png")),
                                          )
                                        ],
                                      )),
                                  SizedBox(
                                    height: screenHeight * 0.02,
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.08),
                                    height: screenHeight * 0.035,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 0, horizontal: 0),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary,
                                      borderRadius: BorderRadius.circular(6),
                                      border:
                                          Border.all(color: AppTheme.primary),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: screenHeight * 0.1,
                                          width: screenWidth * 0.1,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: const Icon(
                                            Icons.wifi_calling_3_outlined,
                                            color: AppTheme.primary,
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.1),
                                        InkWell(
                                          child: Text(
                                            S.of(context).call_for_assistance,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          onTap: () async {
                                            final call =
                                                Uri.parse('tel:+91 7007221530');
                                            if (await canLaunchUrl(call)) {
                                              launchUrl(call);
                                            } else {
                                              throw 'Could not launch $call';
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20.0, top: 10),
                                    child: Text(
                                      S.of(context).account,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _showUploadDocumentDialog(context);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      height: screenHeight * 0.05,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: Row(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(left: 4.0),
                                            child: Icon(
                                              Icons.file_present_outlined,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(width: screenHeight * 0.02),
                                          Text(
                                            S.of(context).contracts_documents,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                          const Spacer(),
                                          const Padding(
                                            padding:
                                                EdgeInsets.only(right: 8.0),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Icon(
                                                Icons.arrow_forward_ios,
                                                size: 15,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.02,
                                  ),
                                  Consumer<RatingProvider>(
                                    builder: (context, provider, child) {
                                      bool isKYCComplete =
                                          provider.panCardStatus == 1 &&
                                              provider.aadharCardStatus == 1 &&
                                              provider.selfiStatus == 1;

                                      return GestureDetector(
                                        onTap: isKYCComplete
                                            ? null // Disable tap if KYC is complete
                                            : () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const DocumentUpload()),
                                                );
                                              },
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          height: screenHeight * 0.05,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 0),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border:
                                                Border.all(color: Colors.grey),
                                          ),
                                          child: Row(
                                            children: [
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(left: 4.0),
                                                child: Icon(
                                                  Icons.file_present_outlined,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              SizedBox(
                                                  width: screenHeight * 0.02),
                                              Text(
                                                isKYCComplete
                                                    ? S
                                                        .of(context)
                                                        .already_completed
                                                    : S
                                                        .of(context)
                                                        .complete_kyc,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isKYCComplete
                                                      ? Colors.green
                                                      : Colors.black,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                              const Spacer(),

                                              // Show yellow warning icon if KYC is not complete
                                              if (!isKYCComplete)
                                                const Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 8.0),
                                                  child: Icon(
                                                    Icons.warning_amber_rounded,
                                                    size: 18,
                                                    color: Colors.amber,
                                                  ),
                                                ),

                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8.0),
                                                child: isKYCComplete
                                                    ? const Icon(
                                                        Icons.check_circle,
                                                        size: 18,
                                                        color: Colors.green,
                                                      )
                                                    : const Icon(
                                                        Icons.arrow_forward_ios,
                                                        size: 15,
                                                        color: Colors.grey,
                                                      ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.02,
                                  ),
                                  InkWell(
                                    onTap: () {},
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      height: screenHeight * 0.05,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: Row(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(left: 8.0),
                                            child: Icon(
                                              Icons.diamond_outlined,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(width: screenHeight * 0.02),
                                          Text(
                                            S.of(context).subscriptions,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                          const Spacer(),
                                          const Padding(
                                            padding:
                                                EdgeInsets.only(right: 8.0),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Icon(
                                                Icons.arrow_forward_ios,
                                                size: 15,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.02,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    height: screenHeight * 0.05,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 0, horizontal: 0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: Row(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(left: 8.0),
                                          child: Icon(
                                            Icons.share,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        Text(
                                          S.of(context).referral,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        const Spacer(),
                                        const Padding(
                                          padding: EdgeInsets.only(right: 8.0),
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Icon(Icons.arrow_forward_ios,
                                                size: 15, color: Colors.grey),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20.0, top: 10, bottom: 5),
                                    child: Text(
                                      S.of(context).general,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      _sendEmail(context);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      height: screenHeight * 0.05,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: Row(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(left: 4.0),
                                            child: Icon(
                                              Icons.support_agent,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(width: 15),
                                          Text(
                                            S.of(context).help_and_support,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                          const Spacer(),
                                          const Padding(
                                            padding:
                                                EdgeInsets.only(right: 8.0),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 15,
                                                  color: Colors.grey),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.02,
                                  ),
                                  InkWell(
                                    onTap: () => _sendWhatsAppMessage(),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      height: screenHeight * 0.05,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: Row(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(left: 4.0),
                                            child: Icon(
                                              Icons.connect_without_contact,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(width: screenHeight * 0.02),
                                          Text(
                                            S.of(context).connect_with_whatsapp,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                          const Spacer(),
                                          const Padding(
                                            padding:
                                                EdgeInsets.only(right: 8.0),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 15,
                                                  color: Colors.grey),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.02,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const NotificationSetting()));
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      height: screenHeight * 0.05,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: Row(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(left: 4.0),
                                            child: Icon(
                                              Icons.edit_notifications_sharp,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(width: screenHeight * 0.02),
                                          Text(
                                            S.of(context).notification_setting,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                          const Spacer(),
                                          const Padding(
                                            padding:
                                                EdgeInsets.only(right: 8.0),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 15,
                                                  color: Colors.grey),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20.0, top: 10, bottom: 5),
                                    child: Text(
                                      S.of(context).general,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.01,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => WebViewScreen(
                                              url:
                                                  'https://xpacesphere.com/Privacy%20Policy%20for%20Xpace%20Sphere.html',
                                              title:
                                                  S.of(context).privacy_policy),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      height: screenHeight * 0.05,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: Row(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(left: 4.0),
                                            child: Icon(
                                              Icons.policy_outlined,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(width: screenHeight * 0.02),
                                          Text(
                                            S.of(context).privacy_policy,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                          const Spacer(),
                                          const Padding(
                                            padding:
                                                EdgeInsets.only(right: 8.0),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 15,
                                                  color: Colors.grey),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.01,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => WebViewScreen(
                                              url:
                                                  'https://xpacesphere.com/Terms%20of%20use.html',
                                              title: S
                                                  .of(context)
                                                  .terms_and_conditions),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      height: screenHeight * 0.05,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: Row(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(left: 4.0),
                                            child: Icon(
                                              Icons
                                                  .collections_bookmark_outlined,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(width: screenHeight * 0.02),
                                          Text(
                                            S.of(context).terms_and_conditions,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                          const Spacer(),
                                          const Padding(
                                            padding:
                                                EdgeInsets.only(right: 8.0),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 15,
                                                  color: Colors.grey),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.03,
                                  ),
                                  Center(
                                    child: InkWell(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20.0, top: 10, bottom: 10),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.logout_rounded,
                                                color: Colors.red),
                                            const SizedBox(width: 10),
                                            Text(
                                              S.of(context).log_out,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors
                                                    .red, // Red text for logout
                                              ),
                                            ),
                                            const Spacer(),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 0.0),
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors
                                                        .white, // Background color for the dropdown
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12), // Rounded corners
                                                    border: Border.all(
                                                        color: AppTheme.primary,
                                                        width: 2),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withValues(
                                                                alpha: 0.6),
                                                        spreadRadius: 2,
                                                        blurRadius: 5,
                                                        offset: const Offset(0,
                                                            3), // Shadow position
                                                      ),
                                                    ],
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 0),
                                                  child: DropdownButton<Locale>(
                                                    icon: const Icon(
                                                      Icons.keyboard_arrow_down,
                                                      color: AppTheme.primary,
                                                      size: 24,
                                                    ),
                                                    value:
                                                        languageProvider.locale,
                                                    onChanged:
                                                        (Locale? newLocale) {
                                                      if (newLocale != null) {
                                                        languageProvider
                                                            .setLocale(
                                                                newLocale);
                                                      }
                                                    },
                                                    underline: Container(),
                                                    dropdownColor: Colors.white,
                                                    isDense: true,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    items: LanguageProvider
                                                        .supportedLocales
                                                        .map((Locale locale) {
                                                      return DropdownMenuItem(
                                                        value: locale,
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                                Icons.language,
                                                                color: Colors
                                                                    .blueAccent,
                                                                size: 18),
                                                            Text(
                                                              languageProvider
                                                                  .getLanguageName(
                                                                      locale),
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      onTap: () async {
                                        final navigator = Navigator.of(context);
                                        bool shouldLogout =
                                            await _showLogoutConfirmationDialog(
                                                navigator.context);
                                        if (!context.mounted) return;
                                        if (shouldLogout) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            _logoutAndRedirect(
                                                navigator.context);
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20.0, top: 0, bottom: 0),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 24,
                                            width: 24,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                border: Border.all(
                                                    color: Colors.black)),
                                            child: const Center(
                                                child: Icon(Icons.add)),
                                          ),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          Text(
                                            S.of(context).follow_us_on,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          InkWell(
                                            child: Image.asset(
                                                "assets/images/Facebook.png"),
                                            onTap: () {
                                              _openFacebookProfile();
                                            },
                                          ),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          InkWell(
                                            child: Image.asset(
                                                "assets/images/Instagram.png"),
                                            onTap: () {
                                              _openInstagramProfile();
                                            },
                                          ),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          InkWell(
                                            child: Image.asset(
                                                "assets/images/TwitterX.png"),
                                            onTap: () {
                                              _openTwitterProfile();
                                            },
                                          )
                                        ],
                                      )),
                                  Consumer<RatingProvider>(
                                    builder: (context, ratingProvider, _) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          SizedBox(height: screenHeight * 0.04),
                                          Align(
                                            alignment: Alignment.center,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 22.0),
                                              child: Text(
                                                S
                                                    .of(context)
                                                    .we_value_your_feedback,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.primary,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: screenHeight * 0.02),
                                          Align(
                                            alignment: Alignment.center,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 22.0),
                                              child: Text(
                                                S
                                                    .of(context)
                                                    .your_comments_and_ratings_help_us_to_improve,
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: screenHeight * 0.02),
                                          // AnimatedSwitcher for smooth transition
                                          AnimatedSwitcher(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            child: ratingProvider.isSubmitted
                                                ? _buildFeedbackSubmitted(
                                                    ratingProvider)
                                                : _buildFeedbackForm(
                                                    ratingProvider, phone),
                                          ),
                                        ],
                                      );
                                    },
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
          // Red container on top of both blue and white sections
          Positioned(
            top: screenHeight * 0.15,
            left: screenWidth * 0.15,
            child: Container(
              height: screenHeight * 0.23,
              width: screenWidth * 0.7,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade600,
                    spreadRadius: 1,
                    blurRadius: 15,
                  )
                ],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white),
              ),
              child: Column(
                children: [
                  const Spacer(),
                  Text(
                    name.isNotEmpty ? name : 'Guest',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: screenHeight * 0.035),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.wifi_calling_3_outlined,
                          color: AppTheme.primary,
                        ),
                        SizedBox(width: screenHeight * 0.005),
                        Text(
                          phone.isNotEmpty ? phone : '',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _showEditDialog(context, phone);
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                          bottom: screenHeight * 0.02,
                          left: screenWidth * 0.02,
                          right: screenWidth * 0.02),
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        width: double.infinity,
                        height: screenHeight * 0.04,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: AppTheme.primary),
                        ),
                        child: Center(
                          child: Text(
                            S.of(context).edit_profile,
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w400,
                                fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Consumer<ProfileProvider>(
            builder: (context, profileProvider, child) {
              return Positioned(
                top: screenHeight * 0.08,
                left: screenWidth / 2 - 45,
                child: GestureDetector(
                  onTap: () => _pickImage(context),
                  child: Stack(
                    children: [
                      Container(
                        width: screenWidth * 0.23,
                        height: screenHeight * 0.13,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primary,
                            width: 2.0,
                          ),
                        ),
                        child: profileProvider.profileImage != null
                            ? CircleAvatar(
                                //radius: 45,
                                backgroundColor: AppTheme.primary,
                                backgroundImage:
                                    FileImage(profileProvider.profileImage!),
                              )
                            : CachedNetworkImage(
                                imageUrl: profileProvider.profileImageUrl ?? "",
                                imageBuilder: (context, imageProvider) {
                                  return CircleAvatar(
                                    //radius: 45,
                                    backgroundColor: AppTheme.primary,
                                    backgroundImage: imageProvider,
                                  );
                                },
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: const CircleAvatar(
                                    //radius: 45,
                                    backgroundColor: AppTheme.primary,
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const CircleAvatar(
                                  //radius: 45,
                                  backgroundColor: AppTheme.primary,
                                  backgroundImage:
                                      AssetImage("assets/images/userround.png"),
                                ),
                              ),
                      ),
                      Positioned(
                        bottom: screenHeight * 0.008,
                        right: screenWidth * 0.03,
                        child: InkWell(
                          onTap: () => _pickImage(context),
                          child: const CircleAvatar(
                            radius: 8,
                            backgroundColor: AppTheme.primary,
                            child: Icon(
                              Icons.camera_alt,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSubmitted(RatingProvider ratingProvider) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          S.of(context).thanks_for_feedback,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${"${S.of(context).upload_document}:"} ${ratingProvider.rating}/5",
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600),
            ),
            const Icon(
              Icons.star,
              color: Colors.amber,
            )
          ],
        ),
        SizedBox(height: screenHeight * 0.02),
        AnimatedScale(
          scale: 1.1,
          duration: const Duration(milliseconds: 300),
          child: ElevatedButton(
            onPressed: () => ratingProvider.enableEditing(),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.02,
                  vertical: screenHeight * 0.005),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.orangeAccent,
            ),
            child: Text(
              S.of(context).edit_feedback,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.035),
      ],
    );
  }

  Widget _buildFeedbackForm(RatingProvider ratingProvider, String phone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          S.of(context).rate_your_experience,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Center(
          child: RatingBar.builder(
            initialRating: ratingProvider.rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 6.0),
            itemBuilder: (context, _) =>
                const Icon(Icons.star, color: Colors.amber),
            onRatingUpdate: (rating) {
              ratingProvider.setRating(rating);
            },
          ),
        ),
        const SizedBox(height: 20),
        Text(
          S.of(context).your_comment,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        FadeTransition(
          opacity: ratingProvider.isSubmitting
              ? const AlwaysStoppedAnimation(0.5)
              : const AlwaysStoppedAnimation(1.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              maxLines: 4,
              controller: ratingProvider.commentController,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: S.of(context).write_something_valuable,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                ratingProvider.setComment(value);
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: ratingProvider.isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : ElevatedButton(
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      if (!ratingProvider.isSubmitted &&
                          !ratingProvider.isEditing) {
                        ratingProvider.submitFeedback(phone);
                      } else {
                        ratingProvider.updateFeedback(phone);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: AppTheme.primary,
                    ),
                    child: Text(
                      ratingProvider.isSubmitted
                          ? S.of(context).submit_feedback
                          : S.of(context).submit_feedback,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<void> getSharedPreference() async {
    if (kDebugMode) {
      print("Shared");
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (kDebugMode) {
      print("Initialized");
    }
    name = prefs.getString("name") ?? "Default Name";
    phone = prefs.getString("phone") ?? "Default Phone";
    if (phone.startsWith("+91")) {
      phone = phone.substring(3);
    }
    phoneController.text = phone;
    nameController.text = name;
    _fetchProfileImage();
    setState(() {});
  }

  Future<void> _fetchProfileImage() async {
    try {
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      await fetchProfileImage(profileProvider, phone);
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching profile image: $e");
      }
    }
  }

  Future<void> fetchProfileImage(
      ProfileProvider profileProvider, String phone) async {
    final response = await http.get(
      Uri.parse(
          'https://xpacesphere.com/api/Register/GetRegistr?mobile=$phone'),
    );
    if (kDebugMode) {
      print("API Response: ${response.body}");
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data.containsKey('data') && data['data'].isNotEmpty) {
        final userData = data['data'][0];

        final String relativeImageUrl = userData['userProfile'] ?? "";
        final String userFile = userData['userfile'] ?? "";
        final String name = userData['name'] ?? "";
        final String email = userData['mailid'] ?? "";

        if (kDebugMode) {
          print("Relative Image URL: $relativeImageUrl");
        }
        if (kDebugMode) {
          print("USERPROFILE: $userFile");
        }
        if (kDebugMode) {
          print("User Name: $name");
        }
        if (kDebugMode) {
          print("User Email: $email");
        }

        SharedPreferences pref = await SharedPreferences.getInstance();
        await pref.setString("email", email);
        await pref.setString("name", name);

        if (kDebugMode) {
          print("Saved Email: ${pref.getString("email")}");
        }
        if (kDebugMode) {
          print("Saved Name: ${pref.getString("name")}");
        }
        if (relativeImageUrl.isNotEmpty) {
          final String fullImageUrl =
              'https://xpacesphere.com$relativeImageUrl';
          if (kDebugMode) {
            print("Full Image URL: $fullImageUrl");
          }
          profileProvider.setProfileImageUrl(fullImageUrl);
        } else {
          if (kDebugMode) {
            print("User profile image is null or empty.");
          }
        }
      } else {
        if (kDebugMode) {
          print("No user data or userProfile found in the response.");
        }
      }
    } else {
      if (kDebugMode) {
        print(
            'Failed to load profile image with status code: ${response.statusCode}');
      }
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (!context.mounted) return;
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      if (kDebugMode) {
        print('Picked image: ${imageFile.path}');
      }
      profileProvider.setProfileImage(imageFile);
      if (kDebugMode) {
        print('Updated profile image in provider.');
      }
      _uploadImage(imageFile, phone).then((uploadedImageUrl) {
        if (!context.mounted) return;
        if (uploadedImageUrl != null) {
          profileProvider.setProfileImageUrl(uploadedImageUrl);
          if (kDebugMode) {
            print('Uploaded image URL: $uploadedImageUrl');
          }
        }
      }).catchError((error) {
        if (kDebugMode) {
          print("Error uploading image: $error");
        }
      });
    }
  }

  Future<String?> _uploadImage(File imageFile, String phone) async {
    final uri = Uri.parse('https://xpacesphere.com/api/Register/UPDRegistr');
    final request = http.MultipartRequest('PUT', uri)
      ..fields['Mobile'] = phone
      ..files.add(await http.MultipartFile.fromPath(
        'UserProfile',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        // Read the response body
        final responseBody = await response.stream.bytesToString();
        if (kDebugMode) {
          print("Response Code: ${response.statusCode}");
        }
        if (kDebugMode) {
          print("Response Body: $responseBody");
        }

        final responseData = json.decode(responseBody);
        if (responseData['status'] == 'success') {
          return responseData['imageUrl'];
        } else {
          if (kDebugMode) {
            print("Error: ${responseData['message']}");
          }
          return null;
        }
      } else {
        if (kDebugMode) {
          print("Image upload failed with status: ${response.statusCode}");
        }
        final responseBody = await response.stream.bytesToString();
        if (kDebugMode) {
          print("Error response body: $responseBody");
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error uploading image: $e");
      }
      return null;
    }
  }

  void _showEditDialog(BuildContext context, String phone) {
    final screenHeight = MediaQuery.of(context).size.height;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 1,
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                S.of(context).edit_profile,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            body: Stack(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            labelStyle: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w500),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: phoneController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w500),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: additionalPhoneController,
                          keyboardType: TextInputType.number,
                          maxLength: 10,
                          decoration: InputDecoration(
                            labelText: 'Additional Phone Number',
                            labelStyle: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w500),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          enableSuggestions: true,
                          decoration: InputDecoration(
                            labelText: 'Add email address',
                            labelStyle: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w500),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Align(
                            alignment: Alignment.bottomRight,
                            child: DeleteAccountButton(
                              phone: phone,
                            )),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              S.of(context).cancel,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () async {
                              await _submitFormWithAnimation(
                                context,
                                nameController,
                                phoneController,
                                additionalPhoneController,
                                emailController,
                              );
                            },
                            child: Text(S.of(context).submit,
                                style: const TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitFormWithAnimation(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController phoneController,
    TextEditingController additionalPhoneController,
    TextEditingController emailController,
  ) async {
    final navigator = Navigator.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: navigator.context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: SpinKitCircle(
            color: AppTheme.primary,
          ),
        ),
      );
    });

    final uri = Uri.parse('https://xpacesphere.com/api/Register/UPDRegistr');
    final request = http.MultipartRequest('PUT', uri)
      ..fields['Name'] = nameController.text
      ..fields['Mobile'] = phoneController.text
      ..fields['OPMobile'] = additionalPhoneController.text
      ..fields[' Mailid'] = emailController.text;
    bool success = false;
    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("Response Status Code: ${response.statusCode}");
        }
        success = true;
        SharedPreferences pref = await SharedPreferences.getInstance();
        await pref.setString("name", nameController.text.toString());
        await pref.setString("email", emailController.text.toString());
      } else {
        if (kDebugMode) {
          print("Error Message: $responseBody");
        }
        success = false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error submitting form: $e");
      }
      success = false;
    }
    if (!context.mounted) return;
    navigator.pop();
    if (!context.mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: navigator.context,
        barrierDismissible: true,
        builder: (_) => Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(20),
            child: Material(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: success
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 80,
                              key: ValueKey('success'),
                            )
                          : const Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 80,
                              key: ValueKey('error'),
                            ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      success
                          ? S.of(context).upload_document
                          : S.of(context).failed_update_profile,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        additionalPhoneController.clear();
                        emailController.clear();
                        navigator.pop();
                        navigator.pop();
                      },
                      child: Text(S.of(context).ok),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  void _sendWhatsAppMessage() async {
    String message = _messageController.text.trim();
    String encodedMessage = Uri.encodeComponent(message);
    String url = 'https://wa.me/$phoneNumber?text=$encodedMessage';
    final messenger = ScaffoldMessenger.of(context);
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (!context.mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open WhatsApp!')),
      );
    }
  }

  Future<void> _sendEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'yankesh278@gmail.com',
      query: 'subject=Help%20Request',
    );
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        if (!context.mounted) return;
        messenger.showSnackBar(
          const SnackBar(
            content: Text("Our team will connect with you soon."),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw 'Could not launch email app';
      }
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Unable to open email app. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showUploadDocumentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF1F8E9),
                  Color(0xFFFFFDE7),
                  Color(0xFFFBE9E7)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                elevation: 1,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  S.of(context).upload_document,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
              ),
              body: Column(
                children: [
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      S.of(context).please_upload_document,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                      child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final navigator = Navigator.of(context);
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['jpg', 'pdf', 'docx'],
                        );
                        if (!context.mounted) return;
                        if (result != null) {
                          PlatformFile file = result.files.first;
                          String? filePath = file.path;
                          if (filePath != null) {
                            if (kDebugMode) {
                              print('Selected file path: $filePath');
                            }
                            if (kDebugMode) {
                              print('Mobile number: $phone');
                            }
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              showDialog(
                                context: navigator.context,
                                barrierDismissible: false,
                                builder: (_) => const Center(
                                  child: SpinKitCircle(
                                    color: AppTheme.primary,
                                  ),
                                ),
                              );
                            });
                            var request = http.MultipartRequest(
                              'POST',
                              Uri.parse(
                                  'https://xpacesphere.com/api/Wherehousedt/UploadDocuments'),
                            );
                            request.fields['mobile'] = phone;
                            request.files.add(await http.MultipartFile.fromPath(
                                'UserFile', filePath));
                            if (kDebugMode) {
                              print('API Endpoint: ${request.url}');
                            }
                            if (kDebugMode) {
                              print('Request Fields: ${request.fields}');
                            }
                            if (kDebugMode) {
                              print('File Upload: $filePath');
                            }
                            var response = await request.send();

                            if (!context.mounted) return;
                            navigator.pop();
                            if (response.statusCode == 200) {
                              var responseBody =
                                  await response.stream.bytesToString();
                              if (kDebugMode) {
                                print('Response (200): $responseBody');
                              }
                              navigator.pop();
                              Fluttertoast.showToast(
                                msg: "Document uploaded successfully!",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                              );
                            } else {
                              var errorBody =
                                  await response.stream.bytesToString();
                              if (kDebugMode) {
                                print(
                                    'Error Response (${response.statusCode}): $errorBody');
                              }
                              Fluttertoast.showToast(
                                msg:
                                    "Failed to upload document. Please try again.",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                              );
                            }
                          } else {
                            if (kDebugMode) {
                              print('No file path available.');
                            }
                            Fluttertoast.showToast(
                              msg: "No file selected.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                            );
                          }
                        } else {
                          if (kDebugMode) {
                            print('File selection canceled.');
                          }
                          Fluttertoast.showToast(
                            msg: "File selection canceled.",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                          );
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                        Fluttertoast.showToast(
                          msg: "An error occurred. Please try again.",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side:
                            const BorderSide(color: AppTheme.primary, width: 3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.upload,
                          color: Colors.black,
                          size: 20,
                        ),
                        Text(
                          S.of(context).upload_document,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )),
                  const Spacer(),
                ],
              ),
              bottomNavigationBar: SafeArea(
                top: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            S.of(context).cancel,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            Fluttertoast.showToast(
                              msg: S.of(context).no_document_uploaded,
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                            );
                            Navigator.of(context).pop();
                          },
                          child: Text(S.of(context).submit,
                              style: const TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

void _openInstagramProfile() async {
  const String instagramUrl = 'instagram://user?username=a_tinyhunter';
  const String fallbackUrl = 'https://www.instagram.com/a_tinyhunter/';

  try {
    bool launched = await launchUrl(Uri.parse(instagramUrl),
        mode: LaunchMode.externalApplication);
    if (!launched) {
      await launchUrl(Uri.parse(fallbackUrl),
          mode: LaunchMode.externalApplication);
    }
  } catch (e) {
    await launchUrl(Uri.parse(fallbackUrl),
        mode: LaunchMode.externalApplication);
  }
}

void _openFacebookProfile() async {
  const String facebookAppUrl = 'fb://profile/100009158840334';
  const String fallbackUrl =
      'https://www.facebook.com/profile.php?id=100009158840334';

  try {
    bool launched = await launchUrl(Uri.parse(facebookAppUrl),
        mode: LaunchMode.externalApplication);
    if (!launched) {
      await launchUrl(Uri.parse(fallbackUrl),
          mode: LaunchMode.externalApplication);
    }
  } catch (e) {
    await launchUrl(Uri.parse(fallbackUrl),
        mode: LaunchMode.externalApplication);
  }
}

void _openTwitterProfile() async {
  const String twitterAppUrl = 'twitter://user?screen_name=AnkeshYada78626';
  const String fallbackUrl = 'https://twitter.com/AnkeshYada78626';

  try {
    bool launched = await launchUrl(Uri.parse(twitterAppUrl),
        mode: LaunchMode.externalApplication);
    if (!launched) {
      await launchUrl(Uri.parse(fallbackUrl),
          mode: LaunchMode.externalApplication);
    }
  } catch (e) {
    await launchUrl(Uri.parse(fallbackUrl),
        mode: LaunchMode.externalApplication);
  }
}

class DeleteAccountButton extends StatelessWidget {
  final dynamic phone;
  const DeleteAccountButton({super.key, this.phone});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.3),
          ),
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          elevation: 5,
          shadowColor: Colors.black.withValues(alpha: 0.3),
        ),
        onPressed: () {
          _showDeleteConfirmationDialog(context);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.delete,
              color: Colors.white,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              S.of(context).delete_account,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppTheme.outline,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.07),
          ),
          elevation: 16,
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 300),
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon(
                  //   Icons.warning_amber_outlined,
                  //   size: screenWidth * 0.15,
                  //   color: Colors.orangeAccent,
                  // ),
                  Image.asset(
                    ImageAssets.appLogo,
                    fit: BoxFit.fill,
                    height: screenHeight * 0.065,
                    width: screenWidth * 0.3,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  const Text(
                    'Are you sure?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    S.of(context).confirm_delete_account,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _buildDialogButton(
                        context,
                        label: 'Cancel',
                        color: Colors.grey,
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                        },
                      ),
                      _buildDialogButton(
                        context,
                        label: 'Delete',
                        color: Colors.red,
                        onPressed: () async {
                          var response = await _deleteAccount(phone);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                          if (response == 200) {
                            if (kDebugMode) {
                              print("Clearing data$response");
                            }
                            await _clearData();
                            if (context.mounted) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (_) => const UserLogin()),
                              );
                            }
                          } else {
                            if (context.mounted) {
                              // _showErrorDialog(context);
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<int> _deleteAccount(String phoneNumber) async {
    if (kDebugMode) {
      print("Delete account is called ");
    }
    try {
      final Uri apiUrl =
          Uri.parse('https://xpacesphere.com/api/Register/RegistrDeletes');
      final Map<String, String> formData = {'Mobile': phoneNumber};
      if (kDebugMode) {
        print("Mobile$formData");
      }
      final response = await http.delete(
        apiUrl,
        body: formData,
      );
      if (kDebugMode) {
        print("Response${response.statusCode}");
        print("Response${response.body}");
      }
      return response.statusCode;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting account: $e');
      }
      return 500;
    }
  }

  Future<void> _clearData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Widget _buildDialogButton(BuildContext context,
      {required String label,
      required Color color,
      required VoidCallback onPressed}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.1),
        ),
        padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.01, horizontal: screenWidth * 0.07),
        elevation: 5,
        shadowColor: Colors.black.withValues(alpha: 0.3),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
