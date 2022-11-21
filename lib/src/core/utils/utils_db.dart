import 'dart:async';

import 'package:msk/msk.dart';
import 'package:queue/queue.dart';
import 'package:sqfentity_gen/sqfentity_gen.dart';

class UtilsDB {
  static final Queue queue = Queue();

  static int? lastUnique;
  static Future<TableBase> getPreSaveAction(String tableName, obj) async {
    Map<String, dynamic> data = obj.toMap();
    await UtilsValidate.validateData(tableName, data);
    if (authService.user == null) {
      authService.user = await authService.getUser();
    }

    int millisecondsUpdate = DateTime.now().millisecondsSinceEpoch;
    data.addAll({
      '${UtilsData.codUsuColumn(app.package)}': authService.user?.id,
      'lastUpdate': millisecondsUpdate,
      'sync': 1
    });
    int uniqueKey = await generateUniqueKey(
        millisecondsUpdate: millisecondsUpdate, tableName: tableName);
    if (data['id'] == null || data['id'] == 0) {
      // Inserção
      data['uniqueKey'] = uniqueKey;
    } else {
      if (data['uniqueKey'] == null) {
        // Edição
        if (data['idServer'] != -1) {
          data['uniqueKey'] = data['idServer'];
        } else {
          data['uniqueKey'] = uniqueKey;
        }
      }
    }
    if (app.package == 'br.com.msk.timber_track') {
      obj.codUsuTimber = data['codUsuTimber'];
    } else {
      obj.codUsu = data['codUsu'];
    }
    obj.uniqueKey = data['uniqueKey'];
    obj.lastUpdate = data['lastUpdate'];
    obj.sync = true;

    return obj;
  }

  static Future<int> generateUniqueKey(
      {int? millisecondsUpdate, String tableName = ''}) async {
    Future<void> _completeQueue() async {
      /// Adiciona um future falso para que onComplete seja chamado mesmo que a fila esteja vazia
      unawaited(queue.add(() => Future.value(1)));
      await queue.onComplete;
    }

    /// Necessário usar esse artifício para que a função aguarde o término das demais
    await _completeQueue();

    Future<int> _generateUniqueKey() async {
      if (millisecondsUpdate == null) {
        millisecondsUpdate = DateTime.now().millisecondsSinceEpoch;
      }
      int uniqueKey =
          int.parse('$millisecondsUpdate${authService.user?.id ?? 0}');
      if (UtilsDB.lastUnique == uniqueKey) {
        String log = 'UniqueKey ${uniqueKey} iria duplicar';
        millisecondsUpdate = millisecondsUpdate! + 1;
        uniqueKey =
            int.parse('$millisecondsUpdate${authService.user?.id ?? 0}');
        log += ', usando ${uniqueKey}';
        await UtilsLog.saveLog(
            UtilsLog.REGISTRO_ATIVIDADE_FALHA_SALVAR_DADOS, log, tableName);
      }
      UtilsDB.lastUnique = uniqueKey;
      await Future.delayed(Duration(milliseconds: 1));
      return uniqueKey;
    }

    return queue.add(() => _generateUniqueKey());
  }

  static getLogFunction(Log log) async {
    await UtilsLog.saveLog(
        UtilsLog.REGISTRO_ATIVIDADE_FALHA_SALVAR_DADOS, log.msg, '');
  }

  static const List<SqfEntityField> getDefaultColumnsMSK = [
    SqfEntityField('idServer', DbType.integer, defaultValue: -1),
    SqfEntityField('sync', DbType.bool, defaultValue: true),
    SqfEntityField('lastUpdate', DbType.integer),
    SqfEntityField('uniqueKey', DbType.integer),
    SqfEntityField('codUsu', DbType.integer, defaultValue: -2)
  ];
}
