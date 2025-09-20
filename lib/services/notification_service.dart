import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // This could navigate to the mood tracking screen
    print('Notification tapped: ${response.payload}');
  }

  static Future<bool> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final bool? granted = await androidImplementation.requestNotificationsPermission();
      return granted ?? false;
    }

    // For iOS, permissions are requested during initialization
    return true;
  }

  static Future<void> scheduleMoodReminder({
    required String time,
    required bool enabled,
  }) async {
    await initialize();

    // Cancel existing notifications
    await cancelMoodReminder();

    if (!enabled) return;

    // Parse time (format: "HH:mm")
    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // Create notification details
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'mood_reminder',
      'Mood Reminders',
      channelDescription: 'Daily reminders to log your mood',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule daily notification
    await _notifications.zonedSchedule(
      0, // notification ID
      'Time to log your mood! 😊',
      'How are you feeling today? Take a moment to track your mood.',
      _nextInstanceOfTime(hour, minute),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'mood_reminder',
    );

    // Save settings
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reminder_time', time);
    await prefs.setBool('reminder_enabled', enabled);
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  static Future<void> cancelMoodReminder() async {
    await _notifications.cancel(0);
  }

  static Future<void> showInstantMoodReminder() async {
    await initialize();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'instant_mood_reminder',
      'Mood Reminders',
      channelDescription: 'Instant mood logging reminder',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1, // notification ID
      'Quick Mood Check-in 🧠',
      'Take a moment to log how you\'re feeling right now.',
      notificationDetails,
      payload: 'instant_mood_reminder',
    );
  }

  static Future<Map<String, dynamic>> getReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'enabled': prefs.getBool('reminder_enabled') ?? false,
      'time': prefs.getString('reminder_time') ?? '20:00',
    };
  }

  static Future<void> updateReminderSettings({
    required bool enabled,
    required String time,
  }) async {
    await scheduleMoodReminder(time: time, enabled: enabled);
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
