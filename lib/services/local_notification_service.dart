import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// ---------------------------------------------------------------
/// LocalNotificationService
/// ---------------------------------------------------------------
/// This class is responsible for SHOWING notifications on the device.
/// It uses the `flutter_local_notifications` package to display
/// notifications when the app receives a push message — especially
/// in the **foreground** state, because FCM does NOT automatically
/// show a visible notification when the app is in the foreground.
///
/// WHY do we need this?
/// - When the app is in the BACKGROUND or KILLED, the OS (Android/iOS)
///   automatically shows the notification from the FCM "notification" payload.
/// - When the app is in the FOREGROUND, FCM delivers the message but
///   does NOT show any visible notification. We must manually create one
///   using `flutter_local_notifications`.
/// ---------------------------------------------------------------
class LocalNotificationService {
  // Step 1: Create a singleton instance so we reuse the same object
  // throughout the app lifecycle.
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  // Step 2: The plugin instance from flutter_local_notifications.
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Step 3: Initialize the plugin. This must be called in main()
  // before any notifications are shown.
  //
  // Parameters:
  // - androidDefaultIcon: The app icon shown in the notification
  //   status bar for Android (uses @mipmap/ic_launcher).
  // - darwinDefaultIcon: The app icon for iOS notifications.
  //
  // We also set up platform-specific initialization settings:
  // - Android: Uses the default app icon.
  // - iOS: Requests alert, badge, and sound permissions automatically.
  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // We'll request permission separately
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // Combine both platform settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Step 3a: Initialize the plugin.
    // The `onDidReceiveNotificationResponse` callback fires when the user
    // TAPS on a notification (not when it arrives). This is useful for
    // navigating to a specific screen when the notification is tapped.
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Step 4: Callback when user taps a notification.
  // You can navigate to a specific screen based on the notification payload.
  void _onNotificationTapped(NotificationResponse response) {
    // response.payload contains custom data you passed when showing
    // the notification. Use this to deep-link to a specific screen.
    print('📱 Notification tapped! Payload: ${response.payload}');
    // TODO: Add navigation logic here based on payload
  }

  // Step 5: Request notification permissions from the user.
  // On Android 13+ (API 33+), this is REQUIRED — without it the app
  // cannot post notifications. On iOS, this shows the permission dialog.
  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      // iOS: Request alert, badge, and sound permissions
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    } else if (Platform.isAndroid) {
      // Android 13+: Request notification permission
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return result ?? false;
    }
    return false;
  }

  // Step 5b: Access the Android-specific plugin implementation.
  // This is needed by FcmService to create the notification channel.
  AndroidFlutterLocalNotificationsPlugin? resolveAndroidPlugin() {
    return _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
  }

  // Step 6: Display a local notification.
  // This is the core method called from FCM service when a message
  // arrives in the foreground.
  //
  // Parameters:
  // - title: The notification title (e.g., "New Message")
  // - body: The notification body text
  // - payload: Optional data string to pass when user taps notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // Step 6a: Configure Android notification details.
    // - channelId: Unique ID for the notification channel (Android 8+).
    // - channelName: Human-readable name visible in app settings.
    // - importance: Determines how the notification appears (sound, heads-up).
    // - priority: High priority ensures heads-up notification display.
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel', // Must match the channel created in FCM
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    // Step 6b: Configure iOS notification details.
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true, // Show alert banner
      presentBadge: true, // Update badge count
      presentSound: true, // Play notification sound
    );

    // Step 6c: Combine platform details
    const platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Step 6d: Show the notification with a unique ID (0).
    // Using 0 means each new notification replaces the previous one.
    // Use different IDs if you want to stack multiple notifications.
    await _plugin.show(0, title, body, platformDetails, payload: payload);
  }
}
