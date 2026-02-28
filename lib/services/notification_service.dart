import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:raising_india/data/services/auth_service.dart';
import 'package:raising_india/data/services/user_service.dart';
import 'package:raising_india/services/service_locator.dart';

// Top-level function for background handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log('🔔 Background message received: ${message.notification?.title}');
}

class NotificationBackgroundService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Note: We don't instantiate AuthService in the constructor anymore to avoid startup crashes

  // 1. MAIN INITIALIZATION (Call this in main.dart)
  static Future<void> initialize() async {
    // A. Request Permissions first
    await _requestPermission();

    // B. Setup Local Notifications (for foreground pop-ups)
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Handle foreground notification click
        log("Foreground notification clicked: ${details.payload}");
      },
    );

    // C. Create the Notification Channel (REQUIRED for Android 8+)
    await _createNotificationChannel();

    // D. Setup Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // E. Setup Foreground Listeners
    _setupForegroundListeners();

    // F. Subscribe to topic (Fast operation, safe to await)
    await _firebaseMessaging.subscribeToTopic('all_users');

    // NOTE: We do NOT update the database token here.
    // We simply print the token. The actual update happens silently.
    String? token = await _firebaseMessaging.getToken();

    // Trigger token sync in background (fire and forget)
    syncTokenInBackground(token!);
    }

  // 2. Request Permission
  static Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    log('User granted permission: ${settings.authorizationStatus}');
  }

  // 3. Create Channel (Android Only)
  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // 4. Foreground Listeners
  static void _setupForegroundListeners() {
    // Foreground Message
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });

    // App Opened from Background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('App opened from notification: ${message.data}');
      // Handle navigation here
    });
  }

  // 5. Show Local Notification
  static void _showLocalNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            icon: '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: message.data.toString(),
      );
    }
  }

  // 6. Sync Token (Safe Background Method)
  static Future<void> syncTokenInBackground(String token) async {
    try {
      // Use getIt inside the method to ensure ServiceLocator is ready
      final userService = getIt<UserService>();
      String? res = await userService.updateFCM(token);
      log("Token sync result: $res");
    } catch (e) {
      log("Skipping token sync (User might be logged out or server error): $e");
    }
  }

  static Future<void> clearToken() async {
    await _firebaseMessaging.deleteToken();
  }
}