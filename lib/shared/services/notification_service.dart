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
  /// Fixed-offset time zone for every common UTC offset, in minutes.
  ///
  /// Every zone here was verified to exist and to have **no daylight saving**,
  /// so the mapping stays correct in both hemispheres and all year. Zones with
  /// DST are deliberately avoided: the device only tells us its *current*
  /// offset, so a DST zone would be right for half the year and wrong for the
  /// other half.
  static const Map<int, String> _timeZoneNameByOffsetMinutes = {
    -720: 'Etc/GMT+12',
    -660: 'Pacific/Pago_Pago',
    -600: 'Pacific/Honolulu',
    -570: 'Pacific/Marquesas',
    -540: 'Pacific/Gambier',
    -480: 'Etc/GMT+8',
    -420: 'Etc/GMT+7',
    -360: 'Etc/GMT+6',
    -300: 'Etc/GMT+5',
    -240: 'Etc/GMT+4',
    -180: 'America/Sao_Paulo',
    -120: 'Etc/GMT+2',
    -60: 'Etc/GMT+1',
    0: 'Etc/UTC',
    60: 'Africa/Brazzaville',
    120: 'Africa/Lubumbashi',
    180: 'Africa/Nairobi',
    240: 'Asia/Dubai',
    270: 'Asia/Kabul',
    300: 'Asia/Karachi',
    330: 'Asia/Kolkata',
    345: 'Asia/Kathmandu',
    360: 'Asia/Dhaka',
    390: 'Asia/Yangon',
    420: 'Asia/Bangkok',
    480: 'Asia/Shanghai',
    525: 'Australia/Eucla',
    540: 'Asia/Tokyo',
    570: 'Australia/Darwin',
    600: 'Australia/Brisbane',
    660: 'Pacific/Guadalcanal',
    720: 'Etc/GMT-12',
    780: 'Pacific/Tongatapu',
  };

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
    final scheduleModes = <AndroidScheduleMode>[
      if (await _canUseExactAlarms()) AndroidScheduleMode.exactAllowWhileIdle,
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
        if (await _hasPendingDailyReminder()) {
          return true;
        }
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
    tz.setLocalLocation(_resolveLocalTimeZone());
    _timeZonesInitialized = true;
  }

  /// Resolves the device time zone.
  ///
  /// Android reports an abbreviation such as `EAT` or `GMT+3`, not an IANA
  /// name, so the offset is the reliable signal. Each candidate is validated
  /// against the device's *current* offset before being accepted, so a stale or
  /// mistyped mapping degrades to UTC instead of silently scheduling a reminder
  /// at the wrong hour.
  ///
  /// The abbreviation map that used to live here has been removed. It mapped
  /// `Europe/London` to a UTC+1 device and `Europe/Paris` to a UTC+2 device,
  /// which are wrong for half of every year, and it had no entry at all for
  /// UTC+4, so UAE devices fell through to UTC.
  tz.Location _resolveLocalTimeZone() {
    final now = DateTime.now();
    final deviceOffset = now.timeZoneOffset;

    final candidates = <String>[
      // Some platforms do report a real IANA name, so try it first.
      now.timeZoneName,
      _timeZoneNameByOffsetMinutes[deviceOffset.inMinutes] ?? '',
    ];

    for (final candidate in candidates) {
      if (candidate.isEmpty) {
        continue;
      }
      final location = _tryLocation(candidate);
      if (location != null && _matchesCurrentOffset(location, deviceOffset)) {
        return location;
      }
    }

    return tz.UTC;
  }

  tz.Location? _tryLocation(String name) {
    try {
      return tz.getLocation(name);
    } catch (_) {
      return null;
    }
  }

  bool _matchesCurrentOffset(tz.Location location, Duration deviceOffset) {
    return tz.TZDateTime.now(location).timeZoneOffset == deviceOffset;
  }

  Future<bool> _requestPermissionIfNeeded() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final enabled = await android.areNotificationsEnabled();
      if (enabled == false) {
        final granted = await android.requestNotificationsPermission();
        if (granted != true) {
          return false;
        }
      } else {
        final granted = await android.requestNotificationsPermission();
        if (granted == false) {
          return false;
        }
      }
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

  Future<bool> _canUseExactAlarms() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) {
      return true;
    }

    try {
      final canSchedule = await android.canScheduleExactNotifications();
      if (canSchedule == true) {
        return true;
      }

      final granted = await android.requestExactAlarmsPermission();
      return granted == true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _hasPendingDailyReminder() async {
    try {
      final pending = await _plugin.pendingNotificationRequests();
      return pending.any((request) => request.id == _dailyReminderId);
    } catch (_) {
      return true;
    }
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
