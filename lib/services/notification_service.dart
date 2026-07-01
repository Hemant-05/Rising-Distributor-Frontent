import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:raising_india/data/services/user_service.dart';
import 'package:raising_india/data/services/product_service.dart';
import 'package:raising_india/data/services/order_service.dart';
import 'package:raising_india/services/service_locator.dart';

// Top-level function for background handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log('dY"" Background message received: ${message.data}');

  // Show notification for data-only messages in background
  if (message.notification == null) {
    String? title = message.data['title'] ?? message.data['header'];
    String? body = message.data['body'] ?? message.data['message'];

    if (title != null || body != null) {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      await flutterLocalNotificationsPlugin.show(
        message.hashCode,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            icon: '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  }
}

class NotificationBackgroundService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static bool _tokenRefreshListenerRegistered = false;

  // Note: We don't instantiate AuthService in the constructor anymore to avoid startup crashes

  // 1. MAIN INITIALIZATION (Call this in main.dart)
  static Future<void> initialize() async {
    // A. Request Permissions first
    await _requestPermission();

    // B. Setup Local Notifications (for foreground pop-ups)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
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

    // F. Keep backend FCM tokens fresh when Firebase rotates them.
    _setupTokenRefreshListener();

    // G. Subscribe to topic (Fast operation, safe to await)
    await _firebaseMessaging.subscribeToTopic('all_users');
  }

  // 2. Request Permission
  static Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Explicitly request permission for Android 13+ via local notifications plugin
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

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
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  // 4. Foreground Listeners
  static void _setupForegroundListeners() {
    // Foreground Message
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      
      String? type = message.data['type'];
      String? action = message.data['action'];
      String? payloadId = message.data['payloadId'];
      
      if (type == 'SILENT_PUSH') {
        log('SILENT_PUSH received: $action for $payloadId');
        if (action == 'PRODUCT_UPDATE' && payloadId != null) {
          getIt<ProductService>().refreshProduct(payloadId);
        } else if (action == 'PRODUCT_DELETE') {
          getIt<ProductService>().fetchAvailableProducts();
        } else if (action == 'ORDER_UPDATE') {
          getIt<OrderService>().fetchMyOrders();
        }
      } else {
        _showLocalNotification(message);
      }
    });

    // App Opened from Background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('App opened from notification: ${message.data}');
      // Handle navigation here
    });
  }

  static void _setupTokenRefreshListener() {
    if (_tokenRefreshListenerRegistered) return;
    _tokenRefreshListenerRegistered = true;

    _firebaseMessaging.onTokenRefresh.listen(
      syncTokenInBackground,
      onError: (Object error, StackTrace stackTrace) {
        log('FCM token refresh listener failed: $error');
      },
    );
  }

  // 5. Show Local Notification
  static void _showLocalNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;

    // Support for data-only payloads
    String? title =
        notification?.title ?? message.data['title'] ?? message.data['header'];
    String? body =
        notification?.body ?? message.data['body'] ?? message.data['message'];

    if (title != null || body != null) {
      _flutterLocalNotificationsPlugin.show(
        message.hashCode,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            icon: '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
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

  // Call this explicitly after the user logs in
  static Future<void> syncFCMTokenWithServer() async {
    try {
      String? token = await _firebaseMessaging.getToken().timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );
      if (token != null) {
        final userService = getIt<UserService>();
        String? res = await userService.updateFCM(token);
        log("Post-Login Token sync result: $res");
      }
    } catch (e) {
      log("Failed to sync FCM Token: $e");
    }
  }

  static Future<void> clearToken() async {
    await _firebaseMessaging.deleteToken();
  }
}
