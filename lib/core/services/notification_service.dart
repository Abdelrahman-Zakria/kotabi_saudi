import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alarm/alarm.dart';
import 'package:kotabi_saudi/main.dart';
import 'package:kotabi_saudi/core/services/local_storage_service.dart';
import 'package:kotabi_saudi/features/home/presentation/screens/notifications/notifications_page.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    final String timeZoneName = (await FlutterTimezone.getLocalTimezone()).identifier;
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    final initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _navigateToNotifications();
      },
    );

    final prefs = await SharedPreferences.getInstance();
    final bool enabled = prefs.getBool('notifications_enabled') ?? true;
    
    if (enabled) {
      final bool granted = await _requestPermissions();
      if (granted) {
        await _sendWelcomeNotificationIfNeeded(prefs);
        await _scheduleDailyStudyReminder();
      }
    }
  }

  void _navigateToNotifications() {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(builder: (_) => const NotificationsPage()),
      );
    }
  }

  Future<bool> _requestPermissions() async {
    try {
      if (kIsWeb) return false;
      
      final androidImplementation = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
        return true;
      }
      
      final iosImplementation = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iosImplementation != null) {
        return await iosImplementation.requestPermissions(alert: true, badge: true, sound: true) ?? false;
      }
      return false;
    } catch (e) {
      debugPrint("Error requesting permissions: $e");
      return false;
    }
  }

  Future<void> _sendWelcomeNotificationIfNeeded(SharedPreferences prefs) async {
    final bool isFirstTime = prefs.getBool('first_time_notification') ?? true;

    if (isFirstTime) {
      const String title = 'مرحباً بك في كتبي السعودية';
      const String body = 'نتمنى لك رحلة تعليمية ممتعة وناجحة!';
      
      await _notifications.show(
        id: 0,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'welcome_channel',
            'التنبيهات العامة',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
      
      // Log to history
      await sl<LocalStorageService>().saveNotification(title, body);
      await prefs.setBool('first_time_notification', false);
    }
  }

  Future<void> _scheduleDailyStudyReminder() async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 16); // 4 PM

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id: 999,
      title: 'هل أنت مستعد للمذاكرة؟ 📚',
      body: 'حان وقت التقدم في دروسك! افتح التطبيق الآن وتابع رحلتك التعليمية الممتعة.',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'تذكير المذاكرة اليومي',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleSystemAlarm({
    required int id,
    required DateTime time,
    required String title,
    required String body,
  }) async {
    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: time,
      assetAudioPath: 'assets/alarm.mp3',
      loopAudio: false,
      vibrate: true,
      volumeSettings: VolumeSettings.fixed(
        volume: 0.8,
      ),
      notificationSettings: NotificationSettings(
        title: title,
        body: body,
        stopButton: 'إيقاف',
      ),
    );

    await Alarm.set(alarmSettings: alarmSettings);
    
    // Log to history
    await sl<LocalStorageService>().saveNotification(title, body);
  }

  Future<void> cancelAlarm(int id) async {
    await Alarm.stop(id);
    await _notifications.cancel(id: id);
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
