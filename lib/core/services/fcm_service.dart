import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kotabi_saudi/main.dart';
import 'package:kotabi_saudi/core/services/local_storage_service.dart';

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Request Permission (iOS/Android 13+)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. iOS Foreground Display Options
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

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

    // 6. Handle notification click
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification clicked! (from background)');
    });
  }
}
