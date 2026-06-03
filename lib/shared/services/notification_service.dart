import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<bool> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final initialized = await _initialize();
    if (!initialized) {
      return false;
    }

    final allowed = await _requestPermissionIfNeeded();
    if (!allowed) {
      return false;
    }

    await _plugin.zonedSchedule(
      id: 1,
      title: title,
      body: body,
      scheduledDate: _nextReminderTime(hour: hour, minute: minute),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_prayer_reminder',
          'Daily prayer reminder',
          channelDescription: 'Daily reminder to pray with Sala Katoliki',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
        linux: LinuxNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    return true;
  }

  Future<void> cancelDailyReminder() async {
    final initialized = await _initialize();
    if (initialized) {
      await _plugin.cancel(id: 1);
    }
  }

  Future<bool> _initialize() async {
    if (_initialized) {
      return true;
    }

    try {
      tz_data.initializeTimeZones();
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
        macOS: DarwinInitializationSettings(),
        linux: LinuxInitializationSettings(defaultActionName: 'Open'),
      );
      _initialized = await _plugin.initialize(settings: settings) ?? false;
      return _initialized;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _requestPermissionIfNeeded() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final androidAllowed = await android?.requestNotificationsPermission();
    if (androidAllowed == false) {
      return false;
    }

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final iosAllowed = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    if (iosAllowed == false) {
      return false;
    }

    final mac = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    final macAllowed = await mac?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    return macAllowed != false;
  }

  tz.TZDateTime _nextReminderTime({required int hour, required int minute}) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
