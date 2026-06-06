import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const int _dailyReminderId = 1;
  static const String _dailyReminderChannelId = 'daily_prayer_reminder';
  static const String _dailyReminderChannelName = 'Daily prayer reminder';
  static const String _dailyReminderChannelDescription =
      'Daily reminder to pray with Sala Katoliki';

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;
  bool _timeZonesInitialized = false;

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

    final scheduledDate = _nextReminderTime(hour: hour, minute: minute);
    return _scheduleDailyReminder(
      title: title,
      body: body,
      scheduledDate: scheduledDate,
    );
  }

  Future<void> cancelDailyReminder() async {
    final initialized = await _initialize();
    if (initialized) {
      await _plugin.cancel(id: _dailyReminderId);
    }
  }

  Future<bool> _initialize() async {
    if (_initialized) {
      return true;
    }

    try {
      _initializeTimeZones();
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_stat_prayer'),
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

  Future<bool> _scheduleDailyReminder({
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    const scheduleModes = [
      AndroidScheduleMode.inexactAllowWhileIdle,
      AndroidScheduleMode.inexact,
    ];

    for (final scheduleMode in scheduleModes) {
      try {
        await _plugin.cancel(id: _dailyReminderId);
        await _plugin.zonedSchedule(
          id: _dailyReminderId,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              _dailyReminderChannelId,
              _dailyReminderChannelName,
              channelDescription: _dailyReminderChannelDescription,
              importance: Importance.high,
              priority: Priority.high,
              category: AndroidNotificationCategory.reminder,
            ),
            iOS: DarwinNotificationDetails(),
            macOS: DarwinNotificationDetails(),
            linux: LinuxNotificationDetails(),
          ),
          androidScheduleMode: scheduleMode,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        return true;
      } catch (_) {
        // Some Android devices reject one alarm mode even after notification
        // permission is granted. Try the next compatible mode before failing.
      }
    }

    return false;
  }

  void _initializeTimeZones() {
    if (_timeZonesInitialized) {
      return;
    }

    tz_data.initializeTimeZones();
    final now = DateTime.now();
    final localZone = tz.Location('device_local', [tz.minTime], [0], [
      tz.TimeZone(
        now.timeZoneOffset,
        isDst: false,
        abbreviation: now.timeZoneName,
      ),
    ]);
    tz.setLocalLocation(localZone);
    _timeZonesInitialized = true;
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
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
