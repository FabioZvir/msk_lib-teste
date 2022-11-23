import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:msk/src/data/data_access/local/sql/model.dart';
import 'package:hive/hive.dart';
import 'package:msk/msk.dart';

class TratarNotificacoes {
  static const varTAG = "FMCService";
  static const EXECUTAR_QUERY_UPDATE = 1;
  static const EXECUTAR_QUERY_ENVIAR_RESPOSTA = 2;
  static const DELETAR_SHARED_PREFERENCES = 3;
  static const SETAR_SHARED_PREFERENCES = 4;
  static const OBTER_SHARED_PREFERENCES = 5;
  static const SINCRONIZAR_DADOS = 6;
  static const NOTIFICAR_E_SINCRONIZAR = 7;
  static const ATUALIZAR_DADOS_DISPOSITIVO = 8;
  static const OBTER_LOCALIZACAO_USUARIO = 10;

  static const SHARED_PREFERENCES_TYPE_STRING = 1;
  static const SHARED_PREFERENCES_TYPE_INT = 2;
  static const SHARED_PREFERENCES_TYPE_BOOLEAN = 3;
  static const SHARED_PREFERENCES_TYPE_FLOAT = 4;
  static const SHARED_PREFERENCES_TYPE_LONG = 5;

  static onMessageReceived(RemoteMessage remoteMessage,
      {Function? inicializar,
      DarwinNotificationCategory? notificacaoSelecionada}) async {
    if (remoteMessage.data.containsKey("tipo")) {
      switch (remoteMessage.data["tipo"].toString().toInt()) {
        case EXECUTAR_QUERY_UPDATE:
          if (remoteMessage.data.containsKey("rawQuery")) {
            try {
              inicializar?.call();
              if (((await authService.getUser()) != null)) {
                var result = await GetIt.I
                    .get<App>()
                    .dataBase
                    .execSQL(remoteMessage.data["rawQuery"] ?? '');
                await UtilsLog.saveLog(
                    UtilsLog.REGISTRO_ATIVIDADE_REMOTA_EXECUSSAO_QUERY,
                    "QUERY: " + remoteMessage.data["rawQuery"],
                    "Sucesso: ${result.success}");
              }
            } catch (error, stackTrace) {
              UtilsSentry.reportError(
                error,
                stackTrace,
              );
            }
          }
          break;
        case EXECUTAR_QUERY_ENVIAR_RESPOSTA:
          inicializar?.call();
          if (((await authService.getUser()) != null)) {
            getValoresTabela(
                remoteMessage.data["rawQuery"] ?? "",
                (remoteMessage.data["idRequest"].toString().toInt(
                    defaultValue:
                        DateTime.now().millisecondsSinceEpoch ~/ 1000)));
          }
          break;

        case DELETAR_SHARED_PREFERENCES:
          if (remoteMessage.data.containsKey("sharedKey")) {
            try {
              inicializar?.call();
              if (((await authService.getUser()) != null)) {
                // Caso não seja especificado nenhum box, pega o box da sync por padrão
                Box box = await hiveService
                    .getBox(remoteMessage.data['box'] ?? 'sync');
                await box.delete(remoteMessage.data["sharedKey"]);
                await UtilsLog.saveLog(
                    UtilsLog.REGISTRO_ATIVIDADE_REMOTA_DELECAO_SHARED,
                    "KEY: " + remoteMessage.data["sharedKey"],
                    "");

                /// Envia pro servidor
                await UtilsSync.enviarDados();
              }
            } catch (error, stackTrace) {
              UtilsSentry.reportError(
                error,
                stackTrace,
              );
            }
          }
          break;
        case SETAR_SHARED_PREFERENCES:
          {
            if (remoteMessage.data.containsKey("sharedKey")) {
              inicializar?.call();
              if (((await authService.getUser()) != null)) {
                // Caso não seja especificado nenhum box, pega o box da sync por padrão
                Box box = await hiveService
                    .getBox(remoteMessage.data['box'] ?? 'sync');
                await box.put(remoteMessage.data["sharedKey"],
                    remoteMessage.data["sharedValue"]);
                await UtilsLog.saveLog(
                    UtilsLog.REGISTRO_ATIVIDADE_REMOTA_ATUALIZACAO_SHARED,
                    "KEY: " +
                        remoteMessage.data["sharedKey"] +
                        " VALUE: " +
                        remoteMessage.data["sharedValue"],
                    "");

                /// Envia os logs pro servidor
                await UtilsSync.enviarDados();
              }
            }
          }
          break;
        case OBTER_SHARED_PREFERENCES:
          {
            inicializar?.call();
            if (((await authService.getUser()) != null)) {
              Box box =
                  await hiveService.getBox(remoteMessage.data['box'] ?? 'sync');
              String valor = "O valor de " +
                  remoteMessage.data["sharedKey"] +
                  " é: ${box.get(remoteMessage.data["sharedKey"])}";

              ReturnFirebaseRequest request = ReturnFirebaseRequest();
              request = ReturnFirebaseRequest();
              request.codUsu =
                  (authService.user?.id ?? (await authService.getUser())?.id) ??
                      -1;
              request.idDevice = await UtilsLog.getIdDevice();
              request.object = [
                {'result': valor}
              ];
              request.id = remoteMessage.data["idRequest"]
                  .toString()
                  .toInt(defaultValue: DateTime.now().millisecondsSinceEpoch);
              request.date = DateTime.now();
              enviarResponstaServidor(request);
            }
          }
          break;
        case NOTIFICAR_E_SINCRONIZAR:
          {
            inicializar?.call();
            if (((await authService.getUser()) != null)) {
              await UtilsSync.enviarDados();
            }
          }
          break;
        // case SINCRONIZAR_DADOS:
        //   {
        //inicializar?.call();
        //if (((await authService.getUser()) != null)) {
        //     UtilsSync.atualizarDados();
        //}
        //   }
        //   break;
        // case ATUALIZAR_DADOS_DISPOSITIVO:
        //   {
        //inicializar?.call();
        // if (((await authService.getUser()) != null)) {
        //     bool envio = await EnviarDados().sincronizar();
        //     if (envio) {
        //       await AtualizarDados().sincronizar();
        //     }
        //}
        //   }
        //   break;
        case OBTER_LOCALIZACAO_USUARIO:
          {}
          break;
      }
    } else {
      if (remoteMessage.notification != null) {
        showNotification(
            remoteMessage.notification!.title,
            remoteMessage.notification!.body,
            remoteMessage.data['action'] ?? '1',
            notificacaoSelecionada: notificacaoSelecionada);
      }
    }
  }

  static getValoresTabela(String query, int idRequest) async {
    var res = await AppDatabase().execDataTable(query);

    var request = ReturnFirebaseRequest();
    request.codUsu =
        (authService.user?.id ?? (await authService.getUser())?.id) ?? -1;
    request.idDevice = await UtilsLog.getIdDevice();
    request.query = query;
    request.id = idRequest;
    request.date = DateTime.now();
    request.object = res;

    enviarResponstaServidor(request);
  }

  static enviarResponstaServidor(ReturnFirebaseRequest returnFirebaseRequest) {
    try {
      API
          .post('api/timbertrack/registro/debug',
              data: returnFirebaseRequest.toJson())
          .then((value) async {
        if (value.sucesso()) {
          print('Sucesso');
        } else {
          await UtilsLog.saveLog(
              UtilsLog.REGISTRO_ATIVIDADE_REMOTA_EXECUSSAO_QUERY,
              'Dados enviados com sucesso',
              '');
        }
      });
    } catch (error, stackTrace) {
      UtilsSentry.reportError(
        error,
        stackTrace,
      );
    }
  }
}
