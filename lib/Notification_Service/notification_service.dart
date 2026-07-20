import 'package:Lisofy/Warehouse/Partner/notification_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// **1. Request Notification Permission**
  Future<void> requestNotificationPermission() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) print("Notification permission granted.");
      } else {
        if (kDebugMode) print("Notification permission denied.");
      }
    } catch (e) {
      if (kDebugMode) print("Error requesting permission: $e");
    }
  }

  /// **2. Initialize Local Notifications**
  Future<void> initLocalNotifications() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@drawable/ic_stat_push_notification');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _handleNotificationClick(response.payload);
      },
    );
  }

  /// **3. Firebase Initialization**
  void firebaseInit() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print("Foreground message received: ${message.notification?.title}");
      }
      _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) print("Notification clicked: ${message.data}");
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => NotificationScreen(
            payload: message.data['redirect'],
            notifications: [
              {
                'title': message.notification?.title ?? 'No Title',
                'body': message.notification?.body ?? 'No Body',
              }
            ],
          ),
        ),
      );
    });
  }

  /// **4. Show Local Notification**
  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      "High Importance Notifications",
      importance: Importance.max,
    );

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: "Channel for important notifications",
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotificationsPlugin.show(
      0,
      message.notification?.title ?? "Notification",
      message.notification?.body ?? "Tap to view",
      details,
      payload: message.data['redirect'],
    );
  }

  /// **5. Handle Notification Clicks**
  void _handleNotificationClick(String? redirect) {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    if (redirect != null && redirect.isNotEmpty) {
      Navigator.pushNamed(context, redirect);
    }
  }

  /// **6. Get Device FCM Token**
  Future<String?> getDeviceToken() async {
    try {
      String? token = await _messaging.getToken();
      if (kDebugMode) print("FCM Token: $token");
      return token;
    } catch (e) {
      if (kDebugMode) print("Error getting FCM token: $e");
      return null;
    }
  }

  /// **7. Listen for Token Refresh**
  void listenForTokenRefresh() {
    _messaging.onTokenRefresh.listen((String token) {
      if (kDebugMode) print("Token refreshed: $token");
    }).onError((err) {
      if (kDebugMode) print("Token refresh error: $err");
    });
  }
}
