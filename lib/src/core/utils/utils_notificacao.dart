import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void showNotification(String? title, String? body, String action,
    {BuildContext? buildContext,
    SelectNotificationCallback? notificacaoSelecionada}) {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      inicializarNotificacoes(notificacaoSelecionada: notificacaoSelecionada);

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '1', 'CHANNEL',
      channelDescription: 'notify',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker');

  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
  flutterLocalNotificationsPlugin.show(0, title, body, platformChannelSpecifics,
      payload: action);
}

FlutterLocalNotificationsPlugin inicializarNotificacoes(
    {SelectNotificationCallback? notificacaoSelecionada}) {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid =
      new AndroidInitializationSettings('icon_msk_notification');

  var initializationSettingsIOS = new IOSInitializationSettings(
      onDidReceiveLocalNotification: onDidReceiveLocalNotification);

  var initializationSettingsMacos = new MacOSInitializationSettings();

  var initializationSettings = new InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacos);
  flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (notificacaoSelecionada ?? onSelectNotification));
  return flutterLocalNotificationsPlugin;
}

Future onSelectNotification(String? payload) async {
  setActionNotification(payload);
}

Future onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) async {
  if (getAction(payload)!.isNotEmpty) {
    setActionNotification(payload);
  }
}

String? getAction(var message) {
  if (message.containsKey('data')) {
    return message['data']['action'];
  }
  return '';
}

Future setActionNotification(String? payload) async {
  print('Notif aberta $payload');
  //var j = json.decode(payload);
  //String action = getAction(j);
  //if (action == '101') {}
}
