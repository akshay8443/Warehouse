import 'package:Lisofy/Connectivity/network_service.dart';
import 'package:Lisofy/Localization/languages.dart';
import 'package:Lisofy/Notification_Service/notification_service.dart';
import 'package:Lisofy/Transportation/User/provider/booking_provider.dart';
import 'package:Lisofy/Transportation/User/provider/transport_page_home_provider.dart';
import 'package:Lisofy/Transportation/common/provider/loader_notifier.dart';
import 'package:Lisofy/Warehouse/Partner/Provider/auth_provider.dart';
import 'package:Lisofy/Warehouse/Partner/Provider/location_provider.dart';
import 'package:Lisofy/Warehouse/Partner/Provider/warehouse_provider.dart';
import 'package:Lisofy/Warehouse/User/UserProvider/notification_setting.dart';
import 'package:Lisofy/Warehouse/User/UserProvider/document_provider.dart';
import 'package:Lisofy/Warehouse/User/UserProvider/filter_provider.dart';
import 'package:Lisofy/Warehouse/User/UserProvider/interest_provider.dart';
import 'package:Lisofy/Warehouse/User/UserProvider/auth_user_provider.dart';
import 'package:Lisofy/Warehouse/User/UserProvider/photo_provider.dart';
import 'package:Lisofy/Warehouse/User/UserProvider/rating_provider.dart';
import 'package:Lisofy/Warehouse/User/UserProvider/sorting_provider.dart';
import 'package:Lisofy/Warehouse/User/userlogin.dart';
import 'package:Lisofy/generated/l10n.dart';
import 'package:Lisofy/new_home_page.dart';
import 'package:Lisofy/resources/ImageAssets/ImagesAssets.dart';
import 'package:Lisofy/resources/app_theme.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final NotificationServices _notificationServices = NotificationServices();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kReleaseMode) {
      FirebaseCrashlytics.instance.recordFlutterError(details);
    } else {
      FirebaseCrashlytics.instance.recordFlutterError(details);
      FlutterError.presentError(details);
    }
  };
  try {
    await Firebase.initializeApp();
  } catch (e) {
    if (kDebugMode) {
      print("Firebase Initialization Error: $e");
      FirebaseCrashlytics.instance.recordError(e, null);
    }
    runApp(const MaterialApp(
      home: Scaffold(
        body:
            Center(child: Text('Failed to initialize app. Please restart...')),
      ),
    ));
    return;
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppTheme.primary,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  SharedPreferences prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (e) {
    if (kDebugMode) {
      print("SharedPreferences Error: $e");
      FirebaseCrashlytics.instance.recordError(e, null);
    }
    runApp(
      const MaterialApp(
        home: Scaffold(
          body:
              Center(child: Text('Failed to load app data. Please restart...')),
        ),
      ),
    );
    return;
  }

  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  bool isUserLoggedIn = prefs.getBool('isUserLoggedIn') ?? false;
  final hasFirebaseSession = FirebaseAuth.instance.currentUser != null;
  if (hasFirebaseSession && !isLoggedIn && !isUserLoggedIn) {
    isUserLoggedIn = true;
    await prefs.setBool('isUserLoggedIn', true);
  }
  String name = prefs.getString('name') ?? '';
  double latitude = prefs.getDouble('latitude') ?? 0.00;
  double longitude = prefs.getDouble('longitude') ?? 0.00;

  runApp(
    MultiProvider(
      providers: [
        /// Warehouse Providers
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<AuthUserProvider>(
            create: (_) => AuthUserProvider()),
        ChangeNotifierProvider<NetworkConnectionService>(
            create: (_) => NetworkConnectionService()),
        ChangeNotifierProvider<LocationProvider>(
            create: (_) => LocationProvider()),
        ChangeNotifierProvider<WarehouseProvider>(
            create: (_) => WarehouseProvider()),
        ChangeNotifierProvider<LanguageProvider>(
            create: (_) => LanguageProvider()),
        ChangeNotifierProvider<SortingProvider>(
            create: (_) => SortingProvider()),
        ChangeNotifierProvider<FilterProvider>(create: (_) => FilterProvider()),
        ChangeNotifierProvider<ProfileProvider>(
            create: (_) => ProfileProvider()),
        ChangeNotifierProvider<NotificationSettingsProvider>(
            create: (_) => NotificationSettingsProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => PhotoProvider()),
        ChangeNotifierProvider(create: (_) => RatingProvider()),
        ChangeNotifierProvider(create: (_) => LoaderNotifier()),

        /// Transportation Providers
        ChangeNotifierProvider(create: (_) => BookingScreenProvider()),
        ChangeNotifierProvider(create: (_) => TransportPageHomeProvider()),
      ],
      child: MyApp(
        isLoggedIn: isLoggedIn,
        name: name,
        isUserLoggedIn: isUserLoggedIn,
        latitude: latitude,
        longitude: longitude,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  final bool isUserLoggedIn;
  final String name;
  final double longitude;
  final double latitude;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    required this.name,
    required this.isUserLoggedIn,
    required this.longitude,
    required this.latitude,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance);
  bool _didRequestLaunchPermissions = false;

  @override
  void initState() {
    super.initState();

    /// **Initialize Notification Services**
    _notificationServices.firebaseInit();
    _notificationServices.initLocalNotifications();
    _notificationServices.listenForTokenRefresh();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestPermissions();
    });
    FirebaseMessaging.instance.getToken().then((token) {
      if (kDebugMode) {
        print("FCM Token:  $token");
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print("Notification clicked: ${message.messageId}");
      }
    });
  }

  Future<void> requestPermissions() async {
    if (_didRequestLaunchPermissions) return;
    _didRequestLaunchPermissions = true;

    final notificationPermission =
        await _requestPermissionIfNeeded(Permission.notification);
    if (notificationPermission.isPermanentlyDenied) {
      _showNotificationPermissionDialog();
    }

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    if (androidInfo.version.sdkInt >= 33) {
      final mediaImagesPermission =
          await _requestPermissionIfNeeded(Permission.photos);
      final mediaVideosPermission =
          await _requestPermissionIfNeeded(Permission.videos);
      final cameraPermission =
          await _requestPermissionIfNeeded(Permission.camera);
      if (mediaImagesPermission.isPermanentlyDenied ||
          mediaVideosPermission.isPermanentlyDenied ||
          cameraPermission.isPermanentlyDenied) {
        _showPermissionDeniedDialog();
      }
    } else {
      final storagePermission =
          await _requestPermissionIfNeeded(Permission.storage);
      final cameraPermission =
          await _requestPermissionIfNeeded(Permission.camera);
      if (storagePermission.isPermanentlyDenied ||
          cameraPermission.isPermanentlyDenied) {
        _showPermissionDeniedDialog();
      }
    }
  }

  Future<PermissionStatus> _requestPermissionIfNeeded(
      Permission permission) async {
    final status = await permission.status;
    if (status.isGranted || status.isLimited) return status;
    if (status.isPermanentlyDenied || status.isRestricted) return status;
    return permission.request();
  }

  BuildContext? get _navigatorContext =>
      _notificationServices.navigatorKey.currentContext;

  void _showNotificationPermissionDialog() {
    final dialogContext = _navigatorContext;
    if (dialogContext == null) return;
    showDialog(
      context: dialogContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Notification Permission Required"),
          content: const Text(
              "This app requires notification permissions to send you updates. Please enable notifications in the app settings."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(S.of(context).cancel),
            ),
            TextButton(
              onPressed: () {
                openAppSettings();
              },
              child: Text(S.of(context).open_settings),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDeniedDialog() {
    final dialogContext = _navigatorContext;
    if (dialogContext == null) return;
    showDialog(
      context: dialogContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Permission Denied"),
          content: const Text(
              "To upload photos and videos, please grant permission to access photos and the camera."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(S.of(context).ok),
            ),
            TextButton(
              onPressed: () {
                openAppSettings();
              },
              child: Text(S.of(context).open_settings),
            ),
          ],
        );
      },
    );
  }

  // Future<void> requestPermissions() async {
  //   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //   AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //
  //   // ✅ Notification Permission (Android 13+ Required)
  //   PermissionStatus notificationPermission = await Permission.notification.request();
  //   if (notificationPermission.isDenied || notificationPermission.isPermanentlyDenied) {
  //     _showNotificationPermissionDialog();
  //   }
  //
  //   if (androidInfo.version.sdkInt >= 33) {
  //     // ✅ Android 13+ specific permissions for media & camera
  //     PermissionStatus mediaImagesPermission = await Permission.photos.request();
  //     PermissionStatus mediaVideosPermission = await Permission.videos.request();
  //     PermissionStatus cameraPermission = await Permission.camera.request();
  //
  //     if (mediaImagesPermission.isDenied || mediaVideosPermission.isDenied || cameraPermission.isDenied) {
  //       _showPermissionDeniedDialog();
  //     } else if (mediaImagesPermission.isPermanentlyDenied ||
  //         mediaVideosPermission.isPermanentlyDenied ||
  //         cameraPermission.isPermanentlyDenied) {
  //       openAppSettings();
  //     }
  //   } else {
  //     // ✅ Android 12 and below
  //     PermissionStatus storagePermission = await Permission.storage.request();
  //     PermissionStatus cameraPermission = await Permission.camera.request();
  //
  //     if (storagePermission.isDenied || cameraPermission.isDenied) {
  //       _showPermissionDeniedDialog();
  //     } else if (storagePermission.isPermanentlyDenied || cameraPermission.isPermanentlyDenied) {
  //       openAppSettings();
  //     }
  //   }
  // }
  //
  // void _showNotificationPermissionDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text("Notification Permission Required"),
  //         content: const Text(
  //             "This app requires notification permissions to send you updates. Please enable notifications in the app settings."),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: Text(S.of(context).cancel),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               openAppSettings();
  //             },
  //             child: Text(S.of(context).open_settings),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  //
  // void _showPermissionDeniedDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text("Permission Denied"),
  //         content: const Text(
  //             "To upload photos and videos, please grant permission to access storage, media, and camera."),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: Text(S.of(context).ok),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               openAppSettings();
  //             },
  //             child: Text(S.of(context).open_settings),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          final hasActiveSession = widget.isLoggedIn || widget.isUserLoggedIn;
          if (hasActiveSession) {
            _updateCurrentLocation();
          }
          return MaterialApp(
            navigatorKey: _notificationServices.navigatorKey,
            navigatorObservers: [observer],
            theme: AppTheme.light,
            debugShowCheckedModeBanner: false,
            locale: languageProvider.locale,
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('hi', ''),
              Locale('bn', ''),
              Locale('kn', ''),
              Locale('mr', ''),
              Locale('ml', ''),
              Locale('te', ''),
              Locale('ta', ''),
              Locale('pa', ''),
            ],
            home: Scaffold(
              body: StreamBuilder<bool>(
                stream: Provider.of<NetworkConnectionService>(context)
                    .connectionStatusStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(S.of(context).network_error_try_again),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: Text(S.of(context).retry),
                        )
                      ],
                    );
                  }
                  if (snapshot.data == false) {
                    return Center(
                        child: Image.asset(
                      ImageAssets.noInternet,
                      fit: BoxFit.fitHeight,
                    ));
                  }
                  return hasActiveSession
                      ? NewHomePage(
                          latitude: widget.latitude,
                          longitude: widget.longitude)
                      : const UserLogin();
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _updateCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (kDebugMode) {
          print('Location services are disabled.');
        }
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (kDebugMode) {
            print('Location permissions are denied.');
          }
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (kDebugMode) {
          print('Location permissions are permanently denied.');
        }
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('latitude', position.latitude);
      await prefs.setDouble('longitude', position.longitude);
      if (kDebugMode) {
        print('Updated location: ${position.latitude}, ${position.longitude}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get location: $e');
      }
    }
  }
}
