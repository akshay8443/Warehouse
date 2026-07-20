import 'package:Lisofy/resources/app_theme.dart';
import 'package:Lisofy/generated/l10n.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  final String? payload;
  final List<Map<String, String>> notifications;
  const NotificationScreen(
      {super.key, this.payload, this.notifications = const []});
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
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
                          top: screenHeight * 0.070,
                          left: screenWidth * 0.045,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              S.of(context).notifications,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
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
                            topRight: Radius.circular(screenWidth * 0.2),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.06),
                          child: widget.notifications.isEmpty
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: screenHeight * 0.4,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            screenWidth * 0.6),
                                        color: AppTheme.primary,
                                        border: Border.all(
                                            color: Colors.grey, width: 3),
                                      ),
                                      child: const Icon(
                                        Icons.notifications_off_sharp,
                                        size: 100,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      S.of(context).no_notifications,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  itemCount: widget.notifications.length,
                                  itemBuilder: (context, index) {
                                    final notification =
                                        widget.notifications[index];
                                    return Card(
                                      elevation: 4,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.all(15),
                                        leading: const CircleAvatar(
                                          backgroundColor: AppTheme.primary,
                                          child: Icon(Icons.notifications,
                                              color: Colors.white),
                                        ),
                                        title: Text(
                                          notification['title'] ??
                                              'Notification',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        subtitle: Text(
                                          notification['body'] ?? '',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    );
                                  },
                                ),
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
