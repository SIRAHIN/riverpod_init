import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'local_notification_service.dart';

/// ---------------------------------------------------------------
/// FcmService
/// ---------------------------------------------------------------
/// This class manages ALL Firebase Cloud Messaging operations:
///   1. Requesting FCM permission (iOS notification permission)
///   2. Getting the FCM device token
///   3. Listening for token refresh
///   4. Handling incoming messages in ALL 3 app states:
///      - Foreground (app is open & visible)
///      - Background (app is minimized but still in memory)
///      - Terminated/Killed (app is completely closed)
///
/// HOW FCM MESSAGES WORK:
/// FCM messages come in two types:
///
/// 1. **Notification messages** (aka "display messages"):
///    - Sent via Firebase Console or your server with a `notification` key.
///    - FCM automatically displays them when the app is in background/killed.
///    - When the app is in foreground, FCM does NOT auto-display them.
///      We must show them manually using LocalNotificationService.
///
/// 2. **Data messages** (aka "silent messages"):
///    - Sent with only a `data` key (no `notification` key).
///    - FCM does NOT auto-display them in ANY state.
///    - We must handle them manually in all three states.
/// ---------------------------------------------------------------

// ---------------------------------------------------------------
// IMPORTANT: TOP-LEVEL BACKGROUND HANDLER
// ---------------------------------------------------------------
// This function MUST be a top-level function (not a class method)
// because it runs in a separate isolate when the app is terminated.
//
// When does it fire?
// - When a message arrives and the app is in BACKGROUND or TERMINATED state.
// - It does NOT fire for foreground messages — that's handled by
//   the onMessage stream inside FcmService.init().
//
// Why top-level?
// - Background/terminated messages are handled outside the main Dart
//   isolate. Class instances don't survive isolate boundaries, so
//   this must be a standalone function.
// ---------------------------------------------------------------
@pragma('vm:entry-point') // Prevents tree-shaking in release builds
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Step 1: Initialize Firebase for the background isolate.
  // Without this, Firebase services won't work in the background isolate.
  // Note: firebase_core must be imported here.
  await Firebase.initializeApp();

  print('📩 Background message received: ${message.messageId}');

  // Step 2: Show a local notification for the background/terminated message.
  // Even though FCM auto-shows "notification" type messages in background,
  // data-only messages need manual handling.
  // This also ensures the notification is shown even if the system
  // doesn't auto-display it.

  // if notification is null, it means it is a data message
  if(message.notification == null){
    await _showBackgroundNotification(message);
  }
}

// Helper: Show notification from background handler.
// We create a local plugin instance here because the main app's
// singleton may not be accessible from the background isolate.
Future<void> _showBackgroundNotification(RemoteMessage message) async {
  final plugin = FlutterLocalNotificationsPlugin();

  // Initialize the plugin in this background isolate
  const androidSettings = AndroidInitializationSettings(
    '@mipmap/ic_launcher',
  );
  const iosSettings = DarwinInitializationSettings();
  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );
  await plugin.initialize(initSettings);

  // Extract title and body from the message.
  // For "notification" messages: data is in message.notification
  // For "data-only" messages: data is in message.data
  final title = message.notification?.title ?? message.data['title'] ?? 'Notification';
  final body = message.notification?.body ?? message.data['body'] ?? '';

  const androidDetails = AndroidNotificationDetails(
    'high_importance_channel',
    'High Importance Notifications',
    channelDescription: 'This channel is used for important notifications.',
    importance: Importance.high,
    priority: Priority.high,
  );
  const iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );
  const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

  await plugin.show(0, title, body, details);
}

// ---------------------------------------------------------------
// FcmService Class
// ---------------------------------------------------------------
class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  // The Firebase Messaging instance — the main entry point for FCM.
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // LocalNotificationService instance for showing foreground notifications.
  final LocalNotificationService _localNotificationService =
      LocalNotificationService();

  // ---------------------------------------------------------------
  // INIT — Call this in main() after Firebase.initializeApp()
  // ---------------------------------------------------------------
  // This sets up ALL message listeners for all app states.
  Future<void> init() async {
    // Step 1: Request notification permission (especially for iOS).
    await _requestPermission();

    // Step 2: Get and print the FCM device token.
    // This token is what your server uses to send push notifications
    // to THIS specific device. You should send this token to your backend.
    await _getToken();

    // Step 3: Listen for token refresh.
    // Tokens can be rotated by FCM. When that happens, you must
    // update the token on your backend server.
    _onTokenRefresh();

    // Step 4: Create the Android notification channel.
    // On Android 8.0+ (API 26+), notifications must be assigned to
    // a channel. Without this, notifications won't appear on Android 8+.
    await _createAndroidNotificationChannel();

    // Step 5: Register the background message handler.
    // This tells FCM which function to call when a message arrives
    // while the app is in background or terminated.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Step 6: Listen for FOREGROUND messages.
    // This stream fires when a message arrives while the app is
    // in the foreground (open & visible to the user).
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 Foreground message: ${message.messageId}');

      // Extract notification data
      final title = message.notification?.title ??
          message.data['title'] ??
          'Notification';
      final body =
          message.notification?.body ?? message.data['body'] ?? '';

      // Show a local notification manually.
      // FCM does NOT auto-display notifications in foreground.
      _localNotificationService.showNotification(
        title: title,
        body: body,
        payload: message.data.toString(),
      );
    });

    // Step 7: Listen for messages that OPENED the app from background.
    // This fires when the user TAPS on a notification that was shown
    // while the app was in the background or killed.
    // It gives you the message data so you can navigate to a specific screen.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📩 Notification opened app from background: ${message.messageId}');
      _handleMessageNavigation(message);
    });

    // Step 8: Check if the app was opened from a notification while terminated.
    // When the app is completely killed and user taps a notification,
    // onMessageOpenedApp does NOT fire. Instead, we check getInitialMessage().
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print('📩 App opened from terminated state via notification');
      _handleMessageNavigation(initialMessage);
    }
  }

  // ---------------------------------------------------------------
  // REQUEST PERMISSION
  // ---------------------------------------------------------------
  // On iOS: Shows the system permission dialog asking the user to
  // allow notifications (alert, badge, sound).
  // On Android: On Android 13+ (API 33), this requests the
  // POST_NOTIFICATIONS runtime permission.
  // On older Android versions, notifications are allowed by default.
  Future<void> _requestPermission() async {
    // iOS-specific settings
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true, // Show notification heads-up in foreground
      badge: true, // Update app badge count
      sound: true, // Play notification sound
    );

    // Request permission (works on both iOS and Android 13+)
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('📱 Notification permission status: ${settings.authorizationStatus}');
  }

  // ---------------------------------------------------------------
  // GET FCM TOKEN
  // ---------------------------------------------------------------
  // The FCM token is a unique string that identifies this device.
  // Your backend server needs this token to send targeted push
  // notifications to this specific device.
  Future<void> _getToken() async {
    final token = await _messaging.getToken();
    print('🔑 FCM Token: $token');
    // TODO: Send this token to your backend server
  }

  // ---------------------------------------------------------------
  // TOKEN REFRESH LISTENER
  // ---------------------------------------------------------------
  // FCM tokens can change when:
  // - The app is restored on a new device
  // - The user uninstalls/reinstalls the app
  // - Firebase invalidates the token for security reasons
  // When this happens, you must update the token on your backend.
  void _onTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) {
      print('🔑 FCM Token refreshed: $newToken');
      // TODO: Send updated token to your backend server
    });
  }

  // ---------------------------------------------------------------
  // CREATE ANDROID NOTIFICATION CHANNEL
  // ---------------------------------------------------------------
  // Android 8.0+ (API 26+) requires notifications to be associated
  // with a channel. The channel ID must match the one used when
  // creating notifications (in LocalNotificationService and the
  // background handler).
  Future<void> _createAndroidNotificationChannel() async {
    if (!Platform.isAndroid) return;

    const channel = AndroidNotificationChannel(
      'high_importance_channel', // Must match the channel ID in notifications
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotificationService
        .resolveAndroidPlugin()
        ?.createNotificationChannel(channel);
  }

  // ---------------------------------------------------------------
  // HANDLE NOTIFICATION NAVIGATION
  // ---------------------------------------------------------------
  // When a user taps a notification, this method extracts the data
  // and navigates to the appropriate screen.
  // Customize this based on your app's navigation needs.
  void _handleMessageNavigation(RemoteMessage message) {
    final data = message.data;
    print('🧭 Handling navigation with data: $data');

    // Example: Navigate to a specific screen based on a "screen" key
    // if (data.containsKey('screen')) {
    //   final screen = data['screen'];
    //   // Use your router (GoRouter, Navigator, etc.) to navigate
    // }
  }
}
