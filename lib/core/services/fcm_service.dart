import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kotabi_saudi/main.dart';
import 'package:kotabi_saudi/core/services/local_storage_service.dart';
import '../../features/home/presentation/screens/notifications/notification_details_page.dart';

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

        final payload = json.encode({
          'title': title,
          'body': body,
          'timestamp': DateTime.now().toIso8601String(),
        });

        try {
          await _localNotifications.show(
            id: notification.hashCode,
            title: title,
            body: body,
            payload: payload,
            notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                'high_importance_channel',
                'High Importance Notifications',
                importance: Importance.max,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
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
      _handleMessageNavigation(message);
    });

    // 7. Check if app was opened via notification (Terminated state)
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('App opened from terminated state via notification');
        // Small delay to ensure navigator is ready
        Future.delayed(const Duration(seconds: 1), () {
          _handleMessageNavigation(message);
        });
      }
    });
  }

  void _handleMessageNavigation(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final data = {
      'title': notification.title ?? '',
      'body': notification.body ?? '',
      'timestamp': DateTime.now().toIso8601String(),
    };

    _navigateToNotificationDetails(data);
  }

  void _navigateToNotificationDetails(Map<String, dynamic> notificationData) {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (_) => NotificationDetailsPage(notification: notificationData),
        ),
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
