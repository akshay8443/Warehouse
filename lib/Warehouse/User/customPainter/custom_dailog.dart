import 'package:Lisofy/resources/app_theme.dart';
import 'package:Lisofy/resources/ImageAssets/ImagesAssets.dart';
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String message1;
  final String message2;
  final String message3;
  const CustomDialog({
    super.key,
    required this.title,
    required this.message1,
    required this.message2,
    required this.message3,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.03),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Lisofy",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                    SizedBox(
                      height: screenHeight * 0.01,
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        message1,
                        style: const TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        message2,
                        style: const TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        message3,
                        style: const TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      margin:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                      height: screenHeight * 0.03,
                      width: screenWidth * 0.3,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.01)),
                      child: const Center(
                          child: Text(
                        "Stay Tunned",
                        style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 16),
                      )),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Image.asset(
                ImageAssets.comingSoonCircle,
                width: 80,
                height: 80,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showCustomDialog(BuildContext context, String title, String message1,
    String message2, String message3) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      Future.delayed(const Duration(seconds: 5), () {
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      });
      return CustomDialog(
        title: title,
        message1: message1,
        message2: message2,
        message3: message3,
      );
    },
  );
}
