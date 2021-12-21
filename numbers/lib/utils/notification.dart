import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:numbers/utils/localization.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Notifier {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  static void init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    final MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: initializationSettingsMacOS);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    _reminder();
  }

  static Future<void> _reminder({bool record = false}) async {
    tz.initializeTimeZones();
    // Set localation
    var now = DateTime.now();
    var locations = tz.timeZoneDatabase.locations.values;
    var tzo = now.timeZoneOffset.inMilliseconds;
    for (var l in locations)
      if (l.currentTimeZone.offset == tzo) tz.setLocalLocation(l);

    // Sleep message
    var sleep = tz.TZDateTime.from(
        DateTime(now.year, now.month, now.day, 23), tz.local);

    // Weekend message
    var date = DateTime(now.year, now.month, now.day, 10);
    while (date.weekday != 6) date = date.add(Duration(days: 1));
    var weekend = tz.TZDateTime.from(date, tz.local);

    // Message map
    var messages = {
      record ? "record" : "default1": _getTime(24 * 3600),
      "default2": _getTime(72 * 3600),
      "default3": _getTime(168 * 3600),
      "sleep": sleep,
      "weekend": weekend
    };

    // Schedule
    const details = AndroidNotificationDetails('reminder', 'Reminder');
    await _flutterLocalNotificationsPlugin.cancelAll();
    var index = 0;
    messages.forEach((key, value) async {
      var title = "notif_${key}_t".l();
      var body = "notif_${key}_b".l();
      await _flutterLocalNotificationsPlugin.zonedSchedule(index, title, body,
          value, const NotificationDetails(android: details),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
      debugPrint(
          "Noti: $key index $index title $title body: $body time $value");
      ++index;
    });
  }

  static tz.TZDateTime _getTime(int seconds) {
    return tz.TZDateTime.from(DateTime.now(), tz.local)
        .add(Duration(seconds: seconds));
  }

  static Future<dynamic> onDidReceiveLocalNotification(
      int? id, String? title, String? body, String? payload) async {
    debugPrint("Noti: title $title body $body payload: $payload");
  }

  static Future<dynamic> onSelectNotification(String? payload) async {
    if (payload != null) {
      debugPrint('Noti: notification payload: $payload');
    }
  }
}
