import 'package:Lisofy/Warehouse/Partner/otp_screen.dart';
import 'package:Lisofy/Warehouse/User/userlogin.dart';
import 'package:Lisofy/generated/l10n.dart';
import 'package:Lisofy/resources/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    bool shouldExit = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).exit_app),
        content: Text(S.of(context).logout_confirmation),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(S.of(context).no),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text(S.of(context).yes),
          ),
        ],
      ),
    );

    return shouldExit;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitConfirmationDialog(context).then((exit) {
          if (exit && context.mounted) {
            Navigator.of(context).pop(result);
          }
        });
      },
      child: Scaffold(
        backgroundColor: AppTheme.primary,
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          "assets/images/Ellipse1.png",
                          height: 60,
                          width: 60,
                        ),
                        Image.asset(
                          "assets/images/Ellipse2.png",
                          height: 60,
                          width: 60,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.13,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            margin: const EdgeInsets.only(top: 0),
                            child: Image.asset(
                              "assets/images/Ellipse33.png",
                              height: 60,
                              width: 60,
                            )),
                        Container(
                            margin: const EdgeInsets.only(top: 50, right: 20),
                            child: Image.asset(
                              "assets/images/Ellipse3.png",
                              height: 60,
                              width: 60,
                            )),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.17,
                    ),
                    const Text(
                      "Logo",
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.12,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      width: 300, // Set your desired width
                      height: 50, // Set your desired height
                      child: ElevatedButton(
                        onPressed: () {
                          if (kDebugMode) {
                            print('Button Pressed');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedIndex = 0;
                                  });

                                  //User Screen
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const UserLogin()));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _selectedIndex == 0
                                        ? AppTheme.primary
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'User',
                                    style: TextStyle(
                                      color: _selectedIndex == 0
                                          ? Colors.white
                                          : Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedIndex = 1;
                                  });
                                  // Partner Screen
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const OTPScreen()));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _selectedIndex == 1
                                        ? AppTheme.primary
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Partner',
                                    style: TextStyle(
                                      color: _selectedIndex == 1
                                          ? Colors.white
                                          : Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                  top: MediaQuery.of(context).padding.top + 40.0,
                  left: 0,
                  right: 0,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(
                              25)), // Adjust the radius as needed
                      child: Image.asset(
                        "assets/images/demoScreenImage.png",
                        height: 170,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
