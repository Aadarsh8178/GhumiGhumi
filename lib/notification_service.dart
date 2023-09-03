import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('ghumighumi');

    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {
      String payload = notificationResponse.payload ?? "";

      final queryParams = Uri.splitQueryString(payload);
      final lat = queryParams['lat'];
      final lon = queryParams['lon'];
      final title = queryParams['title'] ?? "";

      if (lat == null || lon == null) return;

      var isGoogleMapAvailable =
          await MapLauncher.isMapAvailable(MapType.google);
      if (isGoogleMapAvailable == true) {
        await MapLauncher.showMarker(
          mapType: MapType.google,
          coords: Coords(double.parse(lat), double.parse(lon)),
          title: title,
        );
      } else {
        final availableMaps = await MapLauncher.installedMaps;
        await availableMaps.first.showMarker(
          coords: Coords(double.parse(lat), double.parse(lon)),
          title: title,
        );
      }
    });
  }

  notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails('channelId', 'channelName',
          importance: Importance.max),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future showNotification(
      {int id = 0, String? title, String? body, String? payload}) async {
    return notificationsPlugin
        .show(id, title, body, await notificationDetails(), payload: payload);
  }

  Future scheduleNotification(
      {int id = 0,
      String? title,
      String? body,
      String? payload,
      required DateTime scheduledNotificationDateTime}) async {
    return notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(
          scheduledNotificationDateTime,
          tz.local,
        ),
        await notificationDetails(),
        payload: payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }
}
