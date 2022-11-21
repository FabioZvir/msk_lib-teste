import 'package:hive/hive.dart';
import 'package:msk/msk.dart';
import 'package:msk/src/data/data_access/local/sql/model.dart';
import 'package:sqfentity_gen/sqfentity_gen.dart';

class UtilsData {
  static Future executarQuery(List<RunQueryNextVersion>? querys) async {
    if (querys != null && querys.isNotEmpty) {
      Box box2 = await hiveService.getBox('utils_querys');
      for (RunQueryNextVersion model in querys) {
        if (!box2.containsKey('querys${model.version}')) {
          var a = await AppDatabase().execSQL(model.query);
          if (a.success == true) {
            await box2.put('querys${model.version}', true);
          }
        }
      }
    }
  }

  static void roolBackListItem(List<ItemSelect>? itens) {
    itens?.forEach((element) {
      if (element is ItemSelectFk) {
        (element.fkObj as TableBase?)?.rollbackPk();
      } else if (element.object != null && element.object is TableBase) {
        (element.object as TableBase?)?.rollbackPk();
      }
    });
  }

  static String codUsuColumn(String app) {
    if (app == 'br.com.msk.timber_track') {
      return 'codUsuTimber';
    } else
      return 'codUsu';
  }

  static Future<bool> inicializarBD() async {
    try {
      await app.dataBase.initializeDB();
      await AppDatabase().initializeDB();
      await UtilsData.executarQuery(app.querys);
      return true;
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
    }
    return false;
  }

  /// Retorna o idServer da [table] e [id] especificados
  static Future<int?> getIdServerFromId(String table, int id) async {
    var list = await (AppDatabase()
        .execDataTable('select idServer from $table where id = $id'));
    if (list.isNotEmpty) {
      return list.first['idServer'] as int?;
    }
    return null;
  }

  static Future<int?> getIdDadoGeral(String tabela) async {
    return getIdFromIdServer(tabela, -2);
  }

  static Future<int?> getIdFromIdServer(String tabela, int idServer) async {
    var data = await (AppDatabase().execDataTable(
        'select id from ${tabela} where idserver = $idServer limit 1'));
    if (data.isNotEmpty) {
      return data.first['id'] as int?;
    }
    return null;
  }
}

class RunQueryNextVersion {
  String query;
  int version;
  RunQueryNextVersion(this.query, this.version);
}
