import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class LocalNotifService {
  static final plugin = FlutterLocalNotificationsPlugin();
  static bool isInit = false;

  static Future<void> init() async {
    if (isInit) return;

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    await plugin.initialize(settings);
    tz.initializeDatabase([]);
    isInit = true;
  }

  static NotificationDetails details = const NotificationDetails(
    android: AndroidNotificationDetails(
      'ID',
      'Name',
      channelDescription: 'Description',
      importance: Importance.max,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  static Future<void> showNotification({int id = 0, String? title, String? body}) async =>
      plugin.show(id, title, body, details);

  static Future<void> showTestNotification() async =>
      showNotification(title: 'Test Notification', body: 'This is a test Notification');

  static Future<void> scheduleNotification({
    int id = 0,
    String? title,
    String? body,
    required DateTime scheduledTime,
  }) =>
      plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(
          scheduledTime,
          tz.local,
        ),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
}
