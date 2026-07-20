import 'package:Lisofy/resources/app_theme.dart';

import 'package:Lisofy/Warehouse/User/express_interest_date_time.dart';
import 'package:Lisofy/generated/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpressInterestScreen extends StatefulWidget {
  final dynamic id;
  const ExpressInterestScreen({super.key, required this.id});
  @override
  State<ExpressInterestScreen> createState() => _ExpressInterestScreenState();
}

class _ExpressInterestScreenState extends State<ExpressInterestScreen> {
  String _selectedPossession = 'Select date of possession';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  late TextEditingController phoneController;
  final TextEditingController companyController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController messengerController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    phoneController = TextEditingController();
    _loadPrefilledValue();
  }

  Future<void> _loadPrefilledValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? prefilledValue = prefs.getString('phone');
    if (prefilledValue != null && prefilledValue.isNotEmpty) {
      phoneController.text = prefilledValue;
      if (kDebugMode) {
        print("Data: $prefilledValue");
      }
      if (prefilledValue.startsWith("+91")) {
        prefilledValue = prefilledValue.replaceFirst("+91", "");
        if (kDebugMode) {
          print("Prefilled (without +91): $prefilledValue");
        }
        phoneController.text = prefilledValue;
      }
    } else {
      if (kDebugMode) {
        print("No prefilled phone number found.");
      }
    }
  }

  List<String> possessions = [
    'Immediate',
    'Within 15 days',
    'Within 30 days',
    'Within 60 days',
  ];
  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    companyController.dispose();
    designationController.dispose();
    messengerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: AppTheme.primary,
              width: double.infinity,
              child: SafeArea(
                child: Column(
                  children: [
                    Container(
                      color: AppTheme.primary,
                      height: screenHeight * 0.13,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: screenHeight * 0.05,
                          left: screenWidth * 0.04,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: const Icon(
                                      Icons.arrow_back_ios_new_sharp,
                                      color: Colors.white,
                                    )),
                                Text(
                                  S.of(context).express_interest,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white),
                                )
                              ],
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
                          padding: EdgeInsets.all(screenWidth * 0.06),
                          child: SingleChildScrollView(
                              child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Container(
                                  height: screenHeight * 0.07,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.06),
                                  child: TextFormField(
                                    controller: nameController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your name';
                                      } else if (!RegExp(r'^[a-zA-Z\s]+$')
                                          .hasMatch(value)) {
                                        return 'Name can only contain letters';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      labelText: S.of(context).name,
                                      labelStyle: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14),
                                      hintText: 'Ankesh Yadav',
                                      hintStyle: const TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                          width: 1.5,
                                        ),
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                          width: 2.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 13,
                                ),
                                Container(
                                  height: screenHeight * 0.07,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.06),
                                  child: TextFormField(
                                    controller: emailController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      } else if (!RegExp(
                                              r'^[\w-.]+@([\w-]+\.)+\w{2,4}$')
                                          .hasMatch(value)) {
                                        return 'Enter a valid email';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                      labelStyle: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14),
                                      hintText: 'Please enter your email',
                                      hintStyle: TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                          width: 1.5,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                          width: 2.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 13,
                                ),
                                Container(
                                  height: screenHeight * 0.07,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.06),
                                  child: TextFormField(
                                    controller: phoneController,
                                    readOnly: true,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(10),
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      labelText: S.of(context).phone_number,
                                      labelStyle: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14),
                                      hintText:
                                          'Please enter your phone number',
                                      hintStyle: const TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                          width: 1.5,
                                        ),
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                          width: 2.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 13,
                                ),
                                Container(
                                  height: screenHeight * 0.07,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.06),
                                  child: TextFormField(
                                    controller: companyController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your company name';
                                      } else if (!RegExp(r'^[a-zA-Z\s]+$')
                                          .hasMatch(value)) {
                                        return 'Company name  can only contain letters';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      labelText: S
                                          .of(context)
                                          .company_name, // Label Text
                                      labelStyle: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14),
                                      hintText:
                                          'Please enter your company name ',
                                      hintStyle: const TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                          width: 1.5,
                                        ),
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                          width: 2.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 13,
                                ),
                                Container(
                                  height: screenHeight * 0.07,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.06),
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your designation';
                                      } else if (!RegExp(r'^[a-zA-Z\s]+$')
                                          .hasMatch(value)) {
                                        return 'Designation can only contain letters';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.text,
                                    controller: designationController,
                                    decoration: InputDecoration(
                                      labelText: S.of(context).designation,
                                      labelStyle: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14),
                                      hintText:
                                          'e.g. CEO / MD / VP / Ops Manager / Employee',
                                      hintStyle: const TextStyle(
                                          color: Colors.grey, fontSize: 11),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                          width: 1.5,
                                        ),
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                          width: 2.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: screenWidth * 0.055),
                                    child: Text(
                                      S.of(context).select_date_of_possession,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                Container(
                                  height: screenHeight * 0.07,
                                  padding:
                                      EdgeInsets.only(left: screenWidth * 0.04),
                                  margin: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.06),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        color: Colors.grey, width: 1.5),
                                  ),
                                  child: PopupMenuButton<String>(
                                    onSelected: (String value) {
                                      setState(() {
                                        FocusScope.of(context).unfocus();
                                        _selectedPossession = value;
                                      });
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return possessions
                                          .map<PopupMenuEntry<String>>(
                                              (String value) {
                                        return PopupMenuItem<String>(
                                          value: value,
                                          child: Container(
                                            height: screenHeight * 0.04,
                                            margin: EdgeInsets.only(
                                                top: screenWidth * 0.04),
                                            width: screenWidth * 0.3,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 10),
                                            child: Text(value,
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                          ),
                                        );
                                      }).toList();
                                    },
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      side:
                                          const BorderSide(color: Colors.grey),
                                    ),
                                    offset: const Offset(0, 50),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _selectedPossession,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14),
                                          ),
                                        ),
                                        Container(
                                          width: screenWidth * 0.15,
                                          height: double.infinity,
                                          color: AppTheme.primary,
                                          child: const Icon(
                                            Icons.keyboard_arrow_down,
                                            size: 35,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: screenHeight * 0.02,
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: screenWidth * 0.055),
                                    child: Text(
                                      S.of(context).messenger,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.05),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.grey, width: 1.5),
                                    color: Colors.white,
                                  ),
                                  child: TextFormField(
                                    controller: messengerController,
                                    validator: (value) {
                                      if (value == null ||
                                          value.split(' ').isEmpty) {
                                        return 'Message must contain at least some words';
                                      }
                                      return null;
                                    },
                                    maxLines: 4,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    keyboardType: TextInputType.multiline,
                                  ),
                                ),
                                SizedBox(
                                  height: screenHeight * 0.02,
                                ),
                                Container(
                                  height: screenHeight * 0.06,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.03),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey, width: 2),
                                    borderRadius: BorderRadius.circular(
                                        screenWidth * 0.38),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        screenWidth * 0.38),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          if (kDebugMode) {
                                            print(
                                                "Phone${phoneController.text}");
                                          }
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => ExpressInterestDateTime(
                                                      name: nameController.text
                                                          .toString(),
                                                      email: emailController.text
                                                          .toString(),
                                                      companyName:
                                                          companyController.text
                                                              .toString(),
                                                      designation:
                                                          designationController
                                                              .text
                                                              .toString(),
                                                      phone: phoneController.text
                                                          .toString(),
                                                      msg: messengerController
                                                          .text
                                                          .toString(),
                                                      dateOfPossession:
                                                          _selectedPossession
                                                              .toString(),
                                                      id: widget.id)));
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: AppTheme.primary,
                                        minimumSize: Size(double.infinity,
                                            screenHeight * 0.06),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(21),
                                        ),
                                      ),
                                      child: Text(S.of(context).submit),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
