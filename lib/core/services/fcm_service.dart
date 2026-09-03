import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kotabi_saudi/main.dart';
import 'package:kotabi_saudi/core/services/local_storage_service.dart';
import 'package:kotabi_saudi/features/home/presentation/screens/notifications/notifications_page.dart';

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Permission request moved to sequenced flow in main.dart
    
    // 2. iOS Foreground Display Options
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    NotificationSettings settings = await _messaging.getNotificationSettings();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permission');
      
      // 3. Get Device Token
      String? token = await _messaging.getToken();
      debugPrint('FCM Token: $token');
      
      // 4. Subscribe to Broadcast Topic
      await _messaging.subscribeToTopic('all_users');
      debugPrint('Subscribed to all_users topic');
    }

    // 5. Handle Foreground Messages (Manual Popup + History Log)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('Received foreground message: ${message.notification?.title}');
      
      RemoteNotification? notification = message.notification;
      
      if (notification != null && !kIsWeb) {
        final title = notification.title ?? '';
        final body = notification.body ?? '';

        // Log to history
        await sl<LocalStorageService>().saveNotification(title, body);

        try {
          await _localNotifications.show(
            id: notification.hashCode,
            title: title,
            body: body,
            notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                'high_importance_channel',
                'High Importance Notifications',
                importance: Importance.max,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
              ),
            ),
          );
        } catch (e) {
          debugPrint("Error showing local notification: $e");
        }
      }
    });

    // 6. Handle notification click (Background/Suspended state)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification clicked! (from background)');
      _navigateToNotifications();
    });

    // 7. Check if app was opened via notification (Terminated state)
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('App opened from terminated state via notification');
        // Small delay to ensure navigator is ready
        Future.delayed(const Duration(seconds: 1), () {
          _navigateToNotifications();
        });
      }
    });
  }

  void _navigateToNotifications() {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(builder: (_) => const NotificationsPage()),
      );
    }
  }

  Future<void> requestPermissions() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    // Re-check token and subscription after permission might have changed
    String? token = await _messaging.getToken();
    if (token != null) {
      debugPrint('FCM Token after permission request: $token');
      await _messaging.subscribeToTopic('all_users');
    }
  }
}
