import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:msk/src/data/data_access/local/sql/model.dart';
import 'package:msk/msk.dart';
import 'package:flutter/foundation.dart' as Foundation;

class UtilsLog {
  /// Garante que a mensagem de log não ultrasse esse tamanho, causando problema no cursor
  static const TAMANHO_MAXIMO_LOG = 950;

  static const REGISTRO_ATIVIDADE_ATIVIDADE_ABERTA = 1;
  static const REGISTRO_ATIVIDADE_ATIVIDADE_FECHADA = 2;
  static const REGISTRO_ATIVIDADE_INSERCAO_TABELA = 3;
  static const REGISTRO_ATIVIDADE_SALVAR_TABELA = 4;
  static const REGISTRO_ATIVIDADE_ATUALIZACAO_TABELA = 5;
  static const REGISTRO_ATIVIDADE_DELECAO_TABELA = 6;
  static const REGISTRO_ATIVIDADE_REMOTA_EXECUSSAO_QUERY = 7;
  static const REGISTRO_ATIVIDADE_REMOTA_DELECAO_SHARED = 8;
  static const REGISTRO_ATIVIDADE_REMOTA_ATUALIZACAO_SHARED = 9;
  static const REGISTRO_ATIVIDADE_REMOTA_ATUALIZACAO_BANCO = 10;
  static const REGISTRO_ATIVIDADE_DADOS_ATUALIZADOS = 12;
  static const REGISTRO_LOCALIZACAO_DISPOSITIVO = 20;
  static const REGISTRO_ATIVIDADE_ERRO_RESPOSTA_SERVIDOR = 50;
  static const REGISTRO_ATIVIDADE_ALERTA_ATT_DADOS = 52;
  static const REGISTRO_ATIVIDADE_FALHA_SALVAR_DADOS = 53;
  static const REGISTRO_ATIVIDADE_401 = 54;
  static const REGISTRO_ATIVIDADE_DADOS_INCOMPLETOS = 56;
  static const REGISTRO_ATIVIDADE_LIMPEZA_DADOS_LOGOUT = 57;
  static const REGISTRO_ATIVIDADE_DADOS_NECESSARIOS_AUSENTES = 60;

  static Future<bool?> saveLog(
      int action, String log, String? tableName) async {
    try {
      if (!UtilsPlatform.isDebug) {
        /// Caso o log seja do tipo 401, verifica se já existem logs semelhantes, evitando duplicação
        if (action == REGISTRO_ATIVIDADE_401) {
          var res = await AppDatabase().execDataTable(
              'select 1 from RegistroAtividade where tipo = $REGISTRO_ATIVIDADE_401');
          if (res.isNotEmpty) {
            return true;
          }
        }
        String deviceId = await getIdDevice();
        int versao = await UtilsVersionMSK.getNumVersion();

        /// Aqui o usuário pode não estar inicializado, por isso usa o getUser()
        int? codUsu =
            (authService.user?.id ?? (await authService.getUser())?.id);

        // indica o sucesso da persistencia dos dados
        bool sucesso = true;
        int numeroLogs = log.codeUnits.length ~/ TAMANHO_MAXIMO_LOG;
        for (int i = 0; i <= numeroLogs; i++) {
          int inicioString = i * TAMANHO_MAXIMO_LOG;
          int finalString = (i + 1) * TAMANHO_MAXIMO_LOG;
          if (finalString > log.length) {
            finalString = log.length;
          }
          // trata o caso do inicio seja identico ao final, o que resultaria numa string vazia
          if (inicioString < finalString) {
            String subLog;
            if (numeroLogs > 0) {
              subLog =
                  "Sequência ${i + 1}: ${log.substring(inicioString, finalString)}";
            } else {
              subLog = log;
            }
            try {
              await _saveLog(
                  tableName, subLog, codUsu, action, deviceId, versao);
            } catch (error, stackTrace) {
              UtilsSentry.reportError(error, stackTrace);
            }
          }
        }
        return sucesso;
      } else {
        if (tableName != null && tableName.isNotEmpty) {
          debugPrint('Table: $tableName');
        }
        debugPrint(log);
      }
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
    }
    return null;
  }

  static Future<bool> saveFileLog(
      int action, String log, String tableName, String filePath) async {
    try {
      if (!UtilsPlatform.isDebug) {
        String deviceId = await getIdDevice();
        int versao = await UtilsVersionMSK.getNumVersion();

        /// Aqui o usuário pode não estar inicializado, por isso usa o getUser()
        int? codUsu =
            (authService.user?.id ?? (await authService.getUser())?.id);
        int? id =
            await _saveLog(tableName, log, codUsu, action, deviceId, versao);
        ArquivoRegistroAtividade arquivo = ArquivoRegistroAtividade();
        arquivo.registroAtividade_id = id;
        arquivo.path = filePath;
        await arquivo.saveOrThrow();
        return true;
      } else {
        return true;
      }
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
    }
    return false;
  }

  static Future<int?> _saveLog(String? tableName, String log, int? codUsu,
      int action, String idDevice, int versao) {
    RegistroAtividade registroAtividades = RegistroAtividade();
    registroAtividades.tabela = tableName;
    registroAtividades.log = log;
    registroAtividades.codUsu = codUsu;
    registroAtividades.codUsuTimber = codUsu;
    registroAtividades.tipo = action;
    registroAtividades.data = DateTime.now();
    registroAtividades.app = GetIt.I.get<App>().package;
    registroAtividades.idDevice = idDevice;
    registroAtividades.versao = versao;
    return registroAtividades.saveOrThrow();
  }

  static Future<String> getIdDevice() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      return (await deviceInfo.androidInfo).androidId;
    } else if (Platform.isIOS) {
      return (await deviceInfo.iosInfo).model;
    }
    return '${Foundation.defaultTargetPlatform.toString().split('.').last}';
  }
}
