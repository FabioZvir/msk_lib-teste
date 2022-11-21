import 'package:collection/collection.dart' show IterableExtension;
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:msk/msk.dart';
import 'package:msk/src/data/data_access/local/sql/model.dart';

import 'package:collection/collection.dart';

class Sync {
  static const VERSAO_INICIAL_SYNC = '0x0000000000000000';
  List<Tabela> tabelas;

  Sync(this.tabelas)
      : assert(tabelas.distinctBy((e) => e.nome).length == tabelas.length);

  Future<Map<String, String>> getVersions(
      {String? path, List<String> onlyLists = const []}) async {
    await zerarVersoes(GetIt.I.get<App>().zerarVersoesSync);
    List<String?> completeList = checkAndCompleteList(onlyLists);
    Box box = await hiveService.getBox('sync');
    Map<String, String> map = Map();
    for (Tabela tab in tabelas) {
      if (tab.lista != null && tab.lista!.isNotEmpty) {
        /// Caso seja passada uma lista específica, verifica se a tabela está nela
        if (completeList.isEmpty || completeList.contains(tab.lista)) {
          map[tab.lista!] = box.get(tab.lista) ?? VERSAO_INICIAL_SYNC;
        }
      }
    }
    return map;
  }

  /// Obtém todas as tabelas dependentes e garante que toda a cascata sincronize
  List<String?> checkAndCompleteList(List<String> onlyLists) {
    if (onlyLists.isEmpty) return onlyLists;
    Set<String?> newList = Set.from(onlyLists);
    for (String item in onlyLists) {
      newList.addAll(getListSync(item));
    }
    return newList.toList();
  }

  Set<String?> getListSync(String? syncListName) {
    Set<String?> newList = Set();
    Tabela? tabela = getTableBySyncName(syncListName);
    if (tabela != null) {
      if (tabela.fks?.isNotEmpty == true) {
        for (FK fk in tabela.fks!) {
          Tabela tabela = getTableByName(fk.tabela)!;
          newList.add(tabela.lista);
          var subList = getListSync(tabela.lista);
          newList.addAll(subList);
        }
      }
    }
    return newList;
  }

  Tabela? getTableBySyncName(String? syncName) {
    return tabelas.firstWhereOrNull((element) => element.lista == syncName);
  }

  Tabela? getTableByName(String table) {
    return tabelas.firstWhereOrNull((element) => element.nome == table);
  }

  Future<String> getHasuraVersions() async {
    String query = "";
    for (Tabela tabela in tabelas) {
      var tabelaAtual = (await AppDatabase()
              .execDataTable('pragma table_info(${tabela.nome})'))
          .toList();

      //diminui o processamento
      String colunasAtuais = "";
      tabelaAtual.forEach((item) {
        if (item['name'] == 'isDeleted') {
          //colunasAtuais += 'deletado\n';
        } else if (item['name'] != 'sync' &&
            item['name'] != 'id' &&
            item['name'] != 'imagePath') {
          colunasAtuais += '${item['name'].toString()}\n';
        }
      });

      if (tabela.lista != null && tabela.lista!.isNotEmpty) {
        query += """${tabela.lista} {
          $colunasAtuais
        }\n""";
      }
    }
    return query;
  }

  static Future zerarVersoes(List<ZerarVersaoSync>? versions) async {
    if (versions != null && versions.isNotEmpty) {
      Box box = await hiveService.getBox('sync');
      Box box2 = await hiveService.getBox('utils_sync');
      for (ZerarVersaoSync model in versions) {
        if (!box2.containsKey('version${model.versao}')) {
          if (model is ZerarVersaoSyncModel) {
            await box.put(model.lista, VERSAO_INICIAL_SYNC);
          } else if (model is ZerarTodasVersoes) {
            for (Tabela tabela in app.estrutura.tabelas) {
              if (tabela.lista != null && tabela.lista!.isNotEmpty) {
                await box.put(tabela.lista, VERSAO_INICIAL_SYNC);
              }
            }
          }
          await box2.put('version${model.versao}', true);
        }
      }
    }
  }

  /// Zera a versão da [lista] especificada
  static Future<bool> zerarVersao(String? lista) async {
    try {
      if (lista != null) {
        Box box = await hiveService.getBox('sync');
        await box.put(lista, VERSAO_INICIAL_SYNC);
        return true;
      }
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
    }
    return false;
  }

  /// Zera a versão de todas as listas
  static Future<bool> zerarTodasVersoes() async {
    try {
      for (Tabela tabela in app.estrutura.tabelas) {
        if (tabela.lista != null && tabela.lista!.isNotEmpty) {
          Box box = await hiveService.getBox('sync');
          await box.put(tabela.lista, VERSAO_INICIAL_SYNC);
        }
      }
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
    }
    return false;
  }

  static Future<bool> jaSincronizou() async {
    try {
      return (await hiveService.getBox('sync')).get('sync_concluida') ?? false;
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
    }
    return false;
  }
}

abstract class ZerarVersaoSync {
  int versao; //1, 2
  ZerarVersaoSync(this.versao);
}

class ZerarTodasVersoes extends ZerarVersaoSync {
  ZerarTodasVersoes(int versao) : super(versao);
}

class ZerarVersaoSyncModel extends ZerarVersaoSync {
  String lista;
  ZerarVersaoSyncModel(
    this.lista,
    int versao,
  ) : super(versao);
}
