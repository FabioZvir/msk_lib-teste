import 'dart:async';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:msk/msk.dart';
import 'package:msk/src/data/data_access/local/sql/model.dart';
import 'package:sqfentity/sqfentity.dart';

class UtilsSync {
  static Future<bool> enviarDados(
      {Function(double)? onProgress,
      bool awaitBackground = false,
      void Function(bool)? onBackgroudSended}) async {
    if (!UtilsPlatform.isWeb) {
      bool sucesso =
          await GetIt.I.get<EnviarDados>().sincronizar(onProgress: onProgress);

      if (awaitBackground) {
        bool sucesso2 = await GetIt.I
            .get<EnviarDados>()
            .sincronizar(sendInBackground: true);

        /// Retorna true se ambos os envios tiverem sucesso
        sucesso = sucesso && sucesso2;
      } else {
        /// Envia os dados de background sem esperar para dar o retorno
        GetIt.I
            .get<EnviarDados>()
            .sincronizar(sendInBackground: true)
            .then((value) => onBackgroudSended?.call(value));
      }
      return sucesso;
    }
    return true;
  }

  static Future<ResultadoSincLocal?> atualizarDados(
      {List<String> onlyLists = const []}) async {
    if (!UtilsPlatform.isWeb) {
      return GetIt.I.get<AtualizarDados>().sincronizar(onlyLists: onlyLists);
    }
    return null;
  }

  static notificarProgresso(String title, int progresso, {int id = 2}) {
    try {
      if (UtilsPlatform.isMobile || UtilsPlatform.isMacos) {
        FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
            inicializarNotificacoes();

        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          '2',
          'sync',
          channelDescription: 'Sincronização',
          importance: Importance.min,
          priority: Priority.min,
          showProgress: true,
          maxProgress: 100,
          progress: progresso,
          playSound: false,
        );
        var iOSPlatformChannelSpecifics = IOSNotificationDetails();
        var platformChannelSpecifics = NotificationDetails(
            android: androidPlatformChannelSpecifics,
            iOS: iOSPlatformChannelSpecifics);
        flutterLocalNotificationsPlugin
            .show(id, title, '', platformChannelSpecifics, payload: '');
      }
    } catch (error, stackTrace) {
      UtilsSentry.reportError(
        error,
        stackTrace,
      );
    }
  }

  static notificar(String title, String body, bool isError, {int id = 2}) {
    try {
      if (UtilsPlatform.isMobile || UtilsPlatform.isMacos) {
        FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
            inicializarNotificacoes();

        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
            '2', 'sync',
            channelDescription: 'Sincronização',
            playSound: false,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority);
        var iOSPlatformChannelSpecifics = IOSNotificationDetails();
        var platformChannelSpecifics = NotificationDetails(
            android: androidPlatformChannelSpecifics,
            iOS: iOSPlatformChannelSpecifics);
        flutterLocalNotificationsPlugin
            .show(id, title, body, platformChannelSpecifics, payload: '');
      }
    } catch (error, stackTrace) {
      UtilsSentry.reportError(
        error,
        stackTrace,
      );
    }
  }

  static executarSyncPerioricamente() {
    if (!UtilsPlatform.isDebug) {
      Timer.periodic(Duration(minutes: 15), (timer) async {
        await enviarDados();
        atualizarDados();
      });
    }
  }

  static Future<bool> checkUpDataLogout() async {
    try {
      /// Tenta enviar os dados
      await UtilsSync.enviarDados();

      /// Busca por dados pendentes nas tabelas
      StringBuffer stringBuffer = StringBuffer();
      for (Tabela tabela in app.estrutura.tabelas) {
        var res = await (AppDatabase().execDataTable(
            gerarQuery(tabela, limit: -1, includeFKsNotSended: true)));
        if (res.isNotEmpty) {
          stringBuffer.write('${tabela.lista ?? tabela.nome}: ');
          stringBuffer.writeln(res);
        }
      }

      if (stringBuffer.isNotEmpty) {
        /// Caso encontre, salva num arquivo, e salva num log
        File file = await UtilsFileSelect.saveFileBytes(
            'Usuário: ${authService.user?.id}, Data: ${DateTime.now().string('dd/MM/yyyy HH:mm:ss')}\n\n${stringBuffer.toString()}'
                .codeUnits,
            extensionFile: '.txt',
            openExplorer: false,
            dirExtra: 'backup');
        bool b = await UtilsLog.saveFileLog(
            UtilsLog.REGISTRO_ATIVIDADE_LIMPEZA_DADOS_LOGOUT,
            'Dados não puderam ser enviados ao realizar logout',
            '',
            file.path);
        if (!b) {
          return false;
        }

        /// Envia os logs
        await UtilsSync.enviarDados();
      }

      await Sync.zerarTodasVersoes();

      // Limpa os dados
      List<String> querys = app.estrutura.tabelas
          .where((element) =>
              element.nome.toLowerCase() != 'registroatividade' &&
              element.nome.toLowerCase() != 'registroatividades' &&
              element.nome.toLowerCase() != 'arquivoregistroatividade')
          .map((e) => 'DELETE FROM ${e.nome}')
          .toList();
      var res = await AppDatabase().execSQLList(querys);
      return res.success;
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
    }
    return false;
  }

  static reloadAllDB() async {
    await reloadDB(app.dataBase);
    await reloadDB(AppDatabase());
    return true;
  }

  static reloadDB(SqfEntityModelProvider database) async {
    database.databaseTables!.forEach((element) {
      element.initialized = false;
    });
    database.sequences!.forEach((element) {
      element.initialized = false;
    });

    return await database.initializeDB();
  }

  static String gerarQuery(Tabela tabela,
      {String? where, int limit = 500, bool includeFKsNotSended = false}) {
    String colunasFk = '';
    String inners = '';
    String wheres =
        'where (t0.idServer = -1 or t0.sync = 1 ${where != null ? where : ''})';
    if (tabela.fks?.isNotEmpty == true) {
      //percore todas as fks
      for (int i = 0; i < tabela.fks!.length; i++) {
        String alias =
            't${i + 1}'; //apelidos comecao sempre no t1 (t0 e a tabela principal)
        colunasFk +=
            '$alias.idServer as ${tabela.fks![i].coluna}, '; //pega o nome da coluna
        inners +=
            'left join ${tabela.fks![i].tabela} $alias on t0.${tabela.fks![i].coluna}_id = $alias.id '; //faz os joins
        if (!includeFKsNotSended) {
          wheres += ' and ifnull($alias.idServer, 0) != -1 ';
          //aqui ele filtra para nao pegar registros de fks q ainda n foram sincronizados,
          //mas pega as fks nulas (que podem ser opcionais)
        }
      }
      if (colunasFk.isNotEmpty) {
        colunasFk = ', ' + colunasFk.substring(0, colunasFk.length - 2);
      }
    }
    String s =
        'select t0.*, t0.isDeleted as deletado $colunasFk from ${tabela.nome} t0 $inners '
        '$wheres order by t0.id ';
    if (tabela.enviarEmOrdem != true) {
      s += 'desc';
    } else {
      s += 'asc';
    }
    if (limit > 0) {
      s += ' limit 500';
    }
    //orderna pelos ultimos ids, isso garante que caso um registro n possa ser enviado, n trave o resto da fila
    return s;
  }
}
