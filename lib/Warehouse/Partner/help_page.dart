import 'package:Lisofy/resources/app_theme.dart';
import 'package:Lisofy/Warehouse/Partner/add_warehouse.dart';
import 'package:Lisofy/Warehouse/User/user_profile_screen.dart';
import 'package:Lisofy/generated/l10n.dart';
import 'package:flutter/material.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});
  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
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
                      height: screenHeight * 0.18,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: screenHeight * 0.025,
                          left: screenWidth * 0.025,
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        InkWell(
                                          child: const Icon(
                                            Icons.arrow_back_ios_new,
                                            color: Colors.white,
                                          ),
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        SizedBox(
                                          width: screenWidth * 0.05,
                                        ),
                                        Text(
                                          S.of(context).help,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                const Spacer(),
                                SizedBox(width: screenWidth * 0.01),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: screenWidth * 0.005),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(0),
                            topRight: Radius.circular(screenWidth * 0.1),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.08),
                          child: SingleChildScrollView(
                              child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                    right: screenWidth * 0.6,
                                    bottom: screenHeight * 0.05),
                                height: screenHeight * 0.02,
                                width: screenWidth * 0.3,
                                decoration: BoxDecoration(
                                    color: AppTheme.primary,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Center(
                                    child: Text(
                                  S.of(context).all_topics,
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.white),
                                )),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      S.of(context).troubleshooting,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                            Icons
                                                .keyboard_double_arrow_right_rounded,
                                            size: 16,
                                            color: Colors.grey))
                                  ],
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.012),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      S.of(context).referral,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                            Icons
                                                .keyboard_double_arrow_right_rounded,
                                            size: 16,
                                            color: Colors.grey))
                                  ],
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.012),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      S.of(context).payments,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                            Icons
                                                .keyboard_double_arrow_right_rounded,
                                            size: 16,
                                            color: Colors.grey))
                                  ],
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.012),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      S.of(context).subscriptions,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                            Icons
                                                .keyboard_double_arrow_right_rounded,
                                            size: 16,
                                            color: Colors.grey))
                                  ],
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.012),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      S.of(context).add_warehouse_now,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const AddWareHouse()));
                                        },
                                        icon: const Icon(
                                            Icons
                                                .keyboard_double_arrow_right_rounded,
                                            size: 16,
                                            color: Colors.grey))
                                  ],
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.012),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      S.of(context).my_account,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const UserProfileScreen()));
                                        },
                                        icon: const Icon(
                                            Icons
                                                .keyboard_double_arrow_right_rounded,
                                            size: 16,
                                            color: Colors.grey))
                                  ],
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.012),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      S.of(context).subscriptions,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                            Icons
                                                .keyboard_double_arrow_right_rounded,
                                            size: 16,
                                            color: Colors.grey))
                                  ],
                                ),
                              ),
                            ],
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
