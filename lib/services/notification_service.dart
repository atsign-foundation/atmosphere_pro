import 'dart:convert';
import 'dart:io';
import 'package:atsign_atmosphere_pro/data_models/notification_payload.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:local_notifier/local_notifier.dart';

class LocalNotificationService {
  LocalNotificationService._() {
    init();
  }
  static LocalNotificationService _instace = LocalNotificationService._();
  factory LocalNotificationService() => _instace;
  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  late InitializationSettings initializationSettings;
  final BehaviorSubject<ReceivedNotification>
      didReceivedLocalNotificationSubject =
      BehaviorSubject<ReceivedNotification>();

  init() async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    if (Platform.isIOS) {
      _requestIOSPermission();
    }

    if (Platform.isIOS || Platform.isAndroid || Platform.isMacOS) {
      initializePlatformSpecifics();
    }
  }

  initializePlatformSpecifics() {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('notification_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        ReceivedNotification receivedNotification = ReceivedNotification(
            id: id, title: title, body: body, payload: payload);
        didReceivedLocalNotificationSubject.add(receivedNotification);
      },
    );

    var initializationSettingsMacos = MacOSInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true);

    initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
        macOS: initializationSettingsMacos);
  }

  _requestIOSPermission() {
    _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()!
        .requestPermissions(
          alert: false,
          badge: true,
          sound: true,
        );
  }

  setOnNotificationClick(Function onNotificationClick) async {
    if (Platform.isIOS || Platform.isAndroid || Platform.isMacOS) {
      await _notificationsPlugin.initialize(initializationSettings,
          onSelectNotification: (String? payload) async {
        onNotificationClick(payload);
      });
    }
  }

  Future<void> showNotification(String from, String message) async {
    if (Platform.isIOS || Platform.isAndroid || Platform.isMacOS) {
      var androidChannelSpecifics = AndroidNotificationDetails(
        'CHANNEL_ID',
        'CHANNEL_NAME',
        channelDescription: "CHANNEL_DESCRIPTION",
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        timeoutAfter: 50000,
        styleInformation: DefaultStyleInformation(true, true),
      );
      var iosChannelSpecifics = IOSNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(
          android: androidChannelSpecifics, iOS: iosChannelSpecifics);
      NotificationPayload payload = NotificationPayload(
        name: from,
        // id: int.parse(id)
      );
      await _notificationsPlugin.show(
          0, '$from sent you a file', message, platformChannelSpecifics,
          payload: jsonEncode(payload));
    } else if (Platform.isWindows) {
      final localNotifier = LocalNotifier.instance;
      LocalNotification notification = LocalNotification(
        identifier: 'identifier',
        title: '$from sent you a file',
        subtitle: message,
      );
      await localNotifier.notify(notification);
    }
  }

  cancelNotifications() async {
    if (Platform.isIOS || Platform.isAndroid || Platform.isMacOS) {
      await _notificationsPlugin.cancelAll();
    }
  }
}

class ReceivedNotification {
  final int id;
  final String? title;
  final String? body;
  final String? payload;

  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });
}
