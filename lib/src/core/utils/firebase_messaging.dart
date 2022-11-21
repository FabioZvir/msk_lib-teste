import 'dart:io';

import 'package:auth_interface/auth_interface.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:msk/src/src.dart';
import 'package:msk_utils/msk_utils.dart';

class UtilsFirebaseMessaging {
  static late BackgroundMessageHandler onBackgroundMessageHandler;
  static Function(RemoteMessage)? initialMessage;

  UtilsFirebaseMessaging();

  init() async {
    if (!UtilsPlatform.isWindows) {
      try {
        await Firebase.initializeApp();
        _firebaseCloudMessagingListeners();
        if (UtilsPlatform.isIOS) {
          _iOSPermission();
        }
        app.firebaseIsInitialize = true;
      } catch (_) {
        app.firebaseIsInitialize = false;
      }
    }
  }

  static void _firebaseCloudMessagingListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
      if (app.firebaseFunction != null) {
        app.firebaseFunction!(remoteMessage, false);
      } else {
        TratarNotificacoes.onMessageReceived(remoteMessage);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      if (initialMessage != null) {
        initialMessage!(event);
      }
    });
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessageHandler);
    FirebaseMessaging.instance.getInitialMessage().then((value) {
      if (value != null && initialMessage != null) {
        initialMessage!(value);
      }
    });
    FirebaseMessaging.instance.getToken().then((token) {
      _salvarToken(token);
    });
  }

  void _iOSPermission() {
    FirebaseMessaging.instance.requestPermission();
  }

  static _salvarToken(String? token) {
    hiveService.getBox('token').then((box) async {
      // caso seja um token diferente do que já tem salvo, salva o novo
      if (token != box.get('messaging_token')) {
        await box.put('messaging_token', token);
        // faz o novo token ser registrado no servidor
        await box.put('registrar_token', true);
      }
      if (box.get('registrar_token') == true) {
        // tenta registrar o token, caso tenha sucesso,
        // registra localmente com `registrar_token` = true para que não seja enviado novamente
        registrarToken().then((value) {
          box.put('registrar_token', !value);
        });
      }
    });
  }

  static saveTokenNewUser() async {
    if (app.firebaseIsInitialize!) {
      Box box = await hiveService.getBox('token');
      await box.clear();
      await FirebaseMessaging.instance.deleteToken();
      registrarToken();
    }
  }

  static Future<bool> registrarToken() async {
    Box box = await hiveService.getBox('token');
    UserInterface? usuario = await authService.getUser();

    if (usuario != null) {
      String id = '${DateTime.now().millisecondsSinceEpoch}';
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        id = (await deviceInfo.androidInfo).androidId;
      } else if (Platform.isIOS) {
        id = (await deviceInfo.iosInfo).model;
      }
      if (box.containsKey('messaging_token')) {
        return _syncToken(box.get('messaging_token'), id, usuario.id);
      } else {
        _firebaseCloudMessagingListeners();
        return true;
      }
    }

    return false;
  }

  static Future<bool> _syncToken(String? token, String id, int codUsu) async {
    SincronizarTokenDevice sinc = SincronizarTokenDevice();
    sinc.token = token;
    sinc.idDevice = id;
    sinc.app = GetIt.I.get<App>().package;
    sinc.codUsu = codUsu;
    if (sinc.token != null && sinc.token!.isNotEmpty) {
      Response? res =
          await API.post(app.endPoints.registroToken, data: sinc.toMap());
      return (res.sucesso());
    }
    return false;
  }

  static Future clearToken() async {
    try {
      await (await hiveService.getBox('token')).clear();
      if (app.firebaseIsInitialize!) {
        await FirebaseMessaging.instance.deleteToken();
      }
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
    }
    return true;
  }
}

class SincronizarTokenDevice {
  String? token;
  String? idDevice;
  String app = GetIt.I.get<App>().package;
  int codUsu = 0;

  toMap() {
    Map<String, dynamic> map = Map();
    map['token'] = token;
    map['idDevice'] = idDevice;
    map['app'] = app;
    map['codUsu'] = codUsu;
    return map;
  }
}
//DATA='{"notification": {"body": "this is a body","title": "this is a title"}, "priority": "high", "data": {"click_action": "FLUTTER_NOTIFICATION_CLICK", "id": "1", "status": "done", "tipo": 6}, "to": "enWCmwJKUI0:APA91bG7N8tKg5v0YmdpSHOkjJDcrmGK_eblqkK9olAsja9gEX1Awc5qtwFjZzBlAUiLBhd9T2UHwmWXeRV4GrCzoyehM-mk9UEUELe37lGpyz_MY9tvm1uQ_6WicuNCI31jvSvC4e7n"}'
//curl https://fcm.googleapis.com/fcm/send -H "Content-Type:application/json" -X POST -d "$DATA" -H "Authorization: key=AIzaSyD9bsgr5xxMPNEtAARj9XCL3ixvl0QsHFU"
