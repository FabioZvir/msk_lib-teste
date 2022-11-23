import 'dart:collection';

import 'package:bloc_pattern/bloc_pattern.dart' as bp;
import 'package:collection/collection.dart' show IterableExtension;
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:msk/src/data/data_access/local/sql/model.dart';
import 'package:msk/msk.dart';
import 'package:msk/src/domain/repository/repository_sync.dart';
import 'package:sqfentity/sqfentity.dart';

class AtualizarDados extends bp.Disposable {
  final RepositorySync repository = GetIt.I.get();
  static bool sincronizando =
      false; //usado para n sincronizar 2x ao mesmo tempo
  List<Tabela> tabelasSincronizadas = [];

  String logAlerta = '';
  SqfEntityModelProvider? dataBase;
  bool useUniqueKey = false;
  List<String> fksListaVazia = [];
  final List<TableRows> _syncNotFound = [];
  static AtualizarDados? _instance;

  factory AtualizarDados() {
    _instance ??= AtualizarDados._internalConstructor();
    return _instance!;
  }

  AtualizarDados._internalConstructor() {
    if (dataBase == null) {
      dataBase = GetIt.I.get<App>().dataBase;
    }
    if ((UtilsMigration.appMigrado(GetIt.I.get<App>().package))) {
      useUniqueKey = true;
    }
  }

  void _addItemNotFound(String syncName, int idServer, String? version) {
    TableRows? tableRow = _syncNotFound
        .firstWhereOrNull((element) => element.listName == syncName);
    if (tableRow != null) {
      if (!tableRow.ids.contains(idServer)) {
        tableRow.ids.add(idServer);
      }
    } else {
      _syncNotFound.add(
          TableRows(ids: {idServer}, listName: syncName, version: version));
    }
  }

  Future<ResultadoSincLocal> sincronizar(
      {int? userId,
      Function? logFuncion,
      Function(double, String)? funProgress,
      List<String> onlyLists = const []}) async {
    if (authService.user != null) {
      Box box = await hiveService.getBox('sync');
      int? ultimaSynx = box.get('ultima_sync', defaultValue: 0);

      /// Só sincroniza caso a ultima sync tenha iniciado e não tenha chegado ao fim (método dispose)
      /// Nos ultimos 10 minutos
      if (!sincronizando &&
          ultimaSynx! <
              DateTime.now()
                  .subtract(Duration(minutes: 5))
                  .millisecondsSinceEpoch) {
        await box.put('ultima_sync', DateTime.now().millisecondsSinceEpoch);
        sincronizando = true;
        fksListaVazia.clear();

        Sync sync = GetIt.I.get<App>().estrutura;
        try {
          if (!UtilsPlatform.isRelease) {
            var erros =
                TesteEstruturaSync.validarEstrutura(app.estrutura.tabelas);
            if (erros.isNotEmpty) {
              logAlerta += 'Tabelas com problemas: ${erros.join(',')}\n';
            }
          }

          Map<String, String> versions =
              await sync.getVersions(onlyLists: onlyLists);
          var data = await repository.getDataFullSync(versions);

          if (data != null) {
            await updateDataByMap(data, sync,
                logFuncion: logFuncion,
                funProgress: funProgress,
                logVersions: 'Versões solicitadas: ${versions.toString()}\n');
          } else {
            dispose();
            return ResultadoSincLocal.FALHA;
          }
        } catch (error, stackTrace) {
          UtilsSync.notificar(
              'Ops, houve uma falha na tentativa de sincronizar os dados',
              '$error',
              true);
          dispose();
          _instance = null;
          UtilsSentry.reportError(
            error,
            stackTrace,
          );
          return ResultadoSincLocal.FALHA;
        }
        dispose();
        _instance = null;
        return ResultadoSincLocal.SUCESSO;
      } else {
        _instance = null;
        return ResultadoSincLocal.EXECUTANDO;
      }
    } else {
      return ResultadoSincLocal.FALHA;
    }
  }

  Future startSyncSpecifyRows(List<TableRows> tables,
      {bool executeCloseSync = true}) async {
    try {
      if (tables.isNotEmpty) {
        if (!app.enableSpecifySync) {
          return;
        }
        var data = await repository.getDataSpecifyRows(tables);
        await updateDataByMap(data, GetIt.I.get<App>().estrutura,
            partialSync: true, executeCloseSync: executeCloseSync);
        for (TableRows table in tables) {
          if (!table.version.isNullOrBlank) {
            bool update = true;
            if (data.containsKey(table.listName) &&
                data[table.listName] != null) {
              List<int> returnedIds = (data[table.listName] as List)
                  .map((e) => e['idServer'] as int)
                  .toList();
              for (int id in table.ids) {
                if (!returnedIds.contains(id)) {
                  logAlerta +=
                      'Não foi possível localizar o registro de id $id\n';
                  update = false;
                  break;
                }
              }
              if (update) {
                await updateVersionList(table.listName, table.version!);
              }
            } else {
              logAlerta +=
                  'Não está retornando ${table.listName} na sync por ids\n';
            }
          }
        }
      }
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
    } finally {
      if (executeCloseSync) {
        dispose();
      }
    }
    return;
  }

  Future updateDataByMap(Map data, Sync sync,
      {Function? logFuncion,
      Function(double, String)? funProgress,
      String logVersions = '',
      bool partialSync = false,
      bool executeCloseSync = true}) async {
    DateTime date = DateTime.now();
    Map<String, List<dynamic>> listas = Map();
    int pos = 0;
    int registrados = 0;
    List<Tabela> tabelas = sync.tabelas
        .where(
            (element) => (element.lista != null && element.lista!.isNotEmpty))
        .toList();
    for (Tabela tabela in tabelas) {
      int registradosTabela = await processarLista(
          tabela, data as Map<String, dynamic>, listas,
          partialSync: partialSync);
      registrados += registradosTabela;
      //qtdRegistros[tabela.nome] = registradosTabela;

      if (registradosTabela > 0) {
        double progresso = ((++pos / tabelas.length) * 100);
        UtilsSync.notificarProgresso(
            'Sincronizando ${tabela.nome}', progresso.toInt());
        if (funProgress != null) {
          funProgress.call(progresso, 'Sincronizando ${tabela.nome}');
        }
      }
      listas = limparMemoria(pos, tabelas, listas);
    }

    if (!partialSync) {
      await startSyncSpecifyRows(_syncNotFound, executeCloseSync: false);
    }
    if (executeCloseSync) {
      UtilsSync.notificar(
          'Sincronização Concluída ${DateTime.now().difference(date).inSeconds}s',
          '$registrados registros',
          false);
      Box box = await hiveService.getBox('sync');
      await box.put('sync_concluida', true);
      verificarInconsistencias(sync);
    }
    if (logAlerta.trim().isNotEmpty) {
      if (logFuncion != null) {
        logFuncion(logAlerta);
      }
      logAlerta += logVersions;
      if (!partialSync) {
        logAlerta += 'Versão da resposta: ${data['version']}';
      }
      await UtilsLog.saveLog(
          UtilsLog.REGISTRO_ATIVIDADE_ALERTA_ATT_DADOS, logAlerta, '');
    }
    return true;
  }

  /// Limpa a lista com dados que não serão mais utilizados
  Map<String, List<dynamic>> limparMemoria(
      int pos, List<Tabela> tabelas, Map<String, List<dynamic>> dados) {
    //com base na tabela atual da sync, verifica quais dados podem ser limpos da memoria
    dados.removeWhere((key, value) => !tabelas
        .sublist(pos, tabelas.length)
        .any((it) => it.fks?.any((it2) => it2.tabela == key) == true));
    return dados;
  }

  Future<int> processarLista(Tabela tabela, Map<String, dynamic> data,
      Map<String, List<dynamic>> listas,
      {bool partialSync = false}) async {
    if (data.containsKey(tabela.lista) && data[tabela.lista!] != null) {
      List<dynamic>? list = data[tabela.lista!];
      bool a = await verificarBase(tabela, list);

      if (a) {
        bool atualizarVersion = true;
        List<String> querys = [];
        int subTotal = 0;
        if (list!.isNotEmpty) {
          if (tabela.fks != null && tabela.fks!.isNotEmpty) {
            for (FK fk in tabela.fks!) {
              listas[fk.tabela] = await getList(fk.tabela);
            }
          }
          if (tabela.itens != null && tabela.itens!.isNotEmpty) {
            for (TabelaItens item in tabela.itens!) {
              listas[item.nome] = await getList(item.nome);
              for (FK fk in item.fks!) {
                listas[fk.tabela] = await getList(fk.tabela);
              }
            }
          }
          if (useUniqueKey) {
            listas[tabela.nome] = await getListUniqueKey(tabela.nome);
          } else {
            listas[tabela.nome] = await getList(tabela.nome);
          }

          List<FK> fksNaoEncontradas = [];
          for (int i = 0; i < list.length; i++) {
            Map<String, dynamic>? registroMap = Map.of(list[i]);
            if (!useUniqueKey || registroMap['uniqueKey'] != null) {
              SetarFK setarFK = setarFks(
                  tabela, registroMap, listas, partialSync, data['version']);
              if (setarFK.atualizarVersion == false) {
                for (FK fk in setarFK.fkNaoEncontrada) {
                  if (!fksNaoEncontradas
                      .any((element) => element.tabela == fk.tabela)) {
                    fksNaoEncontradas.add(fk);
                  }
                }
                atualizarVersion = false;
                if (setarFK.removerRegistroLista == true) {
                  /// Faz o -- no i pq removendo um item da lista e n fazer isso ele vai pular o proximo
                  list.removeAt(i--);
                  continue;
                }
              }
              registroMap = setarFK.map;
              String query = salvarDados(registroMap, tabela, listas);
              if (query.isNotEmpty) {
                querys.add(query);
              }
            } else {
              atualizarVersion = false;
              logAlerta +=
                  "Tabela ${tabela.nome} registro ${registroMap['idServer']} com coluna uniqueKey null\n";
            }
          }
          await dataBase!.execSQLList(querys);
          subTotal = querys.length;
          querys.clear();
          if (tabela.itens != null && tabela.itens!.isNotEmpty) {
            for (var amap in list) {
              for (TabelaItens tabela in tabela.itens!) {
                if (amap.containsKey(tabela.lista)) {
                  await processarLista(tabela, amap, listas,
                      partialSync: partialSync);
                }
              }
            }
          }

          /// Caso partialSync seja true, não atualiza a version
          if (!partialSync) {
            if (atualizarVersion) {
              updateVersionList(tabela.lista!, data['version']);
            }
          } else if (!atualizarVersion) {
            logAlerta +=
                "Tabela ${tabela.nome}: Versão não atualizada, pois foram encontrados problemas durante  a sincronização\n";
          }
        }
        return subTotal + querys.length;
      }
    } else if (!partialSync) {
      logAlerta += 'Não está voltando tabela ${tabela.nome}\n';
    }
    return 0;
  }

  Future<void> updateVersionList(String listName, String version) async {
    Box box = Hive.isBoxOpen('sync')
        ? Hive.box('sync')
        : (await Hive.openBox('sync'));
    return box.put(listName, version);
  }

  Future<List> getList(String tabela) async {
    return (await dataBase!.execDataTable(
            'SELECT id, idServer, sync from $tabela order by idServer'))
        .map((item) => Map.of(item))
        .toList();
  }

  Future<List> getListUniqueKey(String tabela) async {
    return (await dataBase!.execDataTable(
            'SELECT id, ifnull(uniqueKey, idServer) AS uniqueKey, sync from $tabela order by uniqueKey'))
        .map((item) => Map.of(item))
        .toList();
  }

  String salvarDados(Map<String, dynamic> map, Tabela tabela,
      Map<String, List<dynamic>> listas) {
    if (map.isNotEmpty) {
      // Filtra colunas que n sao lista (fk ja sao removidas antes)
      var subList = map.entries
          .where((item) =>
              tabela.itens == null ||
              (!tabela.itens!.any((i) => i.lista == item.key)))
          .toList();
      int pos = -1;

      if (useUniqueKey) {
        pos = getIndexColumn(listas[tabela.nome] as List<Map<dynamic, dynamic>>,
            map["uniqueKey"], 'uniqueKey');
      } else {
        pos = getIndexColumn(listas[tabela.nome] as List<Map<dynamic, dynamic>>,
            map["idServer"], 'idServer');
      }

      if (pos == -1) {
        return getInsertQuery(subList, tabela);
      } else if (listas[tabela.nome]![pos]["sync"] != 1) {
        // Caso conste na lista mas sync esteja 1, n atualiza
        return getUpdateQuery(subList, tabela, listas[tabela.nome]![pos]["id"]);
      }
    }
    return "";
  }

  String getInsertQuery(
      List<MapEntry<String, dynamic>> subList, Tabela tabela) {
    StringBuffer keysBuffer = StringBuffer(), valuesBuffer = StringBuffer();
    subList.forEach((item) {
      if (tabela.colunasBanco == null ||
          tabela.colunasBanco!.any((c) =>
              item.key == c ||
              (tabela.allowIgnoreCase &&
                  item.key.toLowerCase() == c.toLowerCase()))) {
        if (item.value.runtimeType == String) {
          valuesBuffer.write('\'${item.value?.replaceAll("'", "''")}\', ');
        } else {
          valuesBuffer.write("${item.value}, ");
        }
        keysBuffer.write("${item.key}, ");
      }
    });
    String values = valuesBuffer
        .toString()
        .replaceAll('false', '0')
        .replaceAll('true', '1'); //pega os valores
    String keys = keysBuffer.toString().replaceAll('deletado', 'isDeleted');
    try {
      values = values.substring(0, values.length - 2);
      keys = keys.substring(0, keys.length - 2);
    } catch (e, stackTrace) {
      UtilsSentry.reportError(e, stackTrace);
      logAlerta +=
          'Erro ao criar a query da tabela ${tabela.nome}: ${e.toString()}\n';
      return '';
    }

    return "INSERT INTO ${tabela.nome} (SYNC, $keys) VALUES (0, $values)";
  }

  String getUpdateQuery(
      List<MapEntry<String, dynamic>> subList, Tabela tabela, int? id) {
    StringBuffer valuesBuffer = StringBuffer();

    subList.forEach((item) {
      if (tabela.colunasBanco == null ||
          tabela.colunasBanco!.any((c) =>
              item.key == c ||
              (tabela.allowIgnoreCase &&
                  item.key.toLowerCase() == c.toLowerCase()))) {
        var val;
        if (item.value.runtimeType == String) {
          val = '\'${item.value?.replaceAll("'", "''")}\'';
        } else {
          val = item.value;
        }
        valuesBuffer.write('${item.key} = $val, ');
      }
    });
    String values = valuesBuffer
        .toString()
        .replaceAll('deletado', 'isDeleted')
        .replaceAll('false', '0')
        .replaceAll('true', '1');
    try {
      values = values.substring(0, values.length - 2);
    } catch (e) {
      print(e);
    }
    return "UPDATE ${tabela.nome} SET SYNC = 0, $values WHERE ID = $id";
  }

  String toUpperCaseFirstWord(String s) {
    if (s.length > 1) {
      return s[0].toUpperCase() + s.substring(1);
    } else
      return s.toUpperCase();
  }

  SetarFK setarFks(Tabela tabela, Map<String, dynamic> map,
      Map<String, List<dynamic>> mapList, bool partialSync, String? version) {
    SetarFK setarFK = SetarFK(fkNaoEncontrada: []);
    bool atualizarVersion = true;
    if (tabela.fks != null && tabela.fks!.isNotEmpty) {
      for (FK fk in tabela.fks!) {
        final String coluna = 'cod' + toUpperCaseFirstWord(fk.coluna);
        if (map[coluna] != null && map[coluna] != 0) {
          if (mapList[fk.tabela]?.isNotEmpty == true) {
            int index = getIndexColumn(
                mapList[fk.tabela] as List<Map<dynamic, dynamic>>,
                map[coluna],
                'idServer');

            if (index > -1 && mapList[fk.tabela]![index]["id"] != null) {
              map[fk.coluna + "_id"] = mapList[fk.tabela]![index]["id"];
            } else {
              if (partialSync || !app.enableSpecifySync) {
                logAlerta +=
                    "(2) Tabela: ${tabela.nome} idServer: ${map["idServer"]} - ${fk.coluna} = ${map[coluna]} Não encontrado\n";
              } else {
                if (!UtilsPlatform.isRelease) {
                  logAlerta +=
                      "LANCADO PARA SYNC POR ID Tabela: ${tabela.nome} idServer: ${map["idServer"]} - ${fk.coluna} = ${map[coluna]} Não encontrado\n";
                }
                _addItemNotFound(tabela.lista!, map["idServer"], version);
              }
              atualizarVersion = false;
              setarFK.fkNaoEncontrada.add(fk);
              setarFK.removerRegistroLista = true;
            }
          } else {
            atualizarVersion = false;
            setarFK.fkNaoEncontrada.add(fk);
            setarFK.removerRegistroLista = true;
            if (!fksListaVazia.any((element) => element == fk.tabela)) {
              logAlerta +=
                  "Tabela ${tabela.nome}: Lista da FK ${fk.tabela} não retornou nenhum registro. Zerando version ${fk.tabela}\n";
              fksListaVazia.add(fk.tabela);
              String? lista = GetIt.I
                  .get<App>()
                  .estrutura
                  .tabelas
                  .firstWhereOrNull((element) => element.nome == fk.tabela)
                  ?.lista;
              Sync.zerarVersao(lista);
            }
          }
        } else if (fk.obrigatoria == true) {
          logAlerta +=
              "Tabela:${tabela.nome} idServer: ${map["idServer"]} FK:${fk.coluna} retornou ${map[coluna]}\n";
          setarFK.removerRegistroLista = true;
          atualizarVersion = false;
        } else {
          map[fk.coluna + "_id"] = null;
        }
        map.remove(coluna); //remove o que voltou do servidor
      }
    }
    setarFK.map = map;
    setarFK.atualizarVersion = atualizarVersion;
    return setarFK;
  }

  /// Retorna a posição do [column] na lista enviada
  int getIndexColumn(
      List<Map<dynamic, dynamic>> map, int? value, String column) {
    int meio;
    int inicio = 0;
    int fim = (map.length) - 1;
    if (value != null) {
      while (inicio <= fim) {
        meio = (inicio + fim) ~/ 2;
        if (value == (map[meio][column] as int)) return meio;
        if (value < (map[meio][column] as int))
          fim = meio - 1;
        else
          inicio = meio + 1;
      }
    }
    return -1;
  }

  @override
  Future<void> dispose() async {
    tabelasSincronizadas.clear();
    sincronizando = false;
    logAlerta = "";
    Box box = await hiveService.getBox('sync');
    await box.put('ultima_sync', 0);
    fksListaVazia.clear();
    _syncNotFound.clear();
    try {
      dataBase!.batchCommit();
    } catch (e) {
      dataBase!.batchRollback();
    }
  }

  /// Remove os idServers e uniqueKeys duplicados da [lista]
  void checkAndRemoveDuplicates(String tabela, List<dynamic> lista) {
    HashSet idServers = new HashSet();
    HashSet uniqueKeys = HashSet();
    List<int> idServersDup = [];
    List<int> uniqueKeysDup = [];

    for (int i = 0; i < lista.length; i++) {
      int idServer = lista[i]['idServer'];
      if (!idServers.contains(idServer)) {
        idServers.add(idServer);
      } else {
        idServersDup.add(idServer);

        /// Faz o -- no i pq removendo um item da lista e n fazer isso ele vai pular o proximo
        lista.removeAt(i--);

        /// Evita problemas na verificação da uniqueKey
        continue;
      }
      if (useUniqueKey) {
        int uniqueKey = lista[i]['uniqueKey'];
        if (!uniqueKeys.contains(uniqueKey)) {
          uniqueKeys.add(uniqueKey);
        } else {
          uniqueKeysDup.add(uniqueKey);

          /// Faz o -- no i pq removendo um item da lista e n fazer isso ele vai pular o proximo
          lista.removeAt(i--);
        }
      }
    }
    if (idServersDup.isNotEmpty) {
      logAlerta += 'Tabela $tabela idServer: $idServersDup duplicados\n';
    }
    if (uniqueKeysDup.isNotEmpty) {
      logAlerta += 'Tabela $tabela uniqueKeys: $uniqueKeysDup duplicados\n';
    }
  }

  /// Faz uma comparação entre as colunas da base e os dados retornados
  Future<bool> verificarBase(Tabela tabela, List<dynamic>? data) async {
    if (data != null && data.isNotEmpty) {
      if (UtilsPlatform.isDebug) {
        String column = 'idServer';
        if (useUniqueKey) {
          column = 'uniqueKey';
        }
        if (!isSorted<Map<String, dynamic>>(
            List<Map<String, dynamic>>.from(data), (a, b) {
          return (a[column] as int).compareTo(b[column]);
        })) {
          logAlerta += 'Tabela ${tabela.nome} Lista não retornou ordenada\n';
          return false;
        }
        checkAndRemoveDuplicates(tabela.nome, data);
      }

      if (data.isNotEmpty) {
        //consulta o schema atual da tabela
        var tabelaAtual = (await AppDatabase()
                .execDataTable('pragma table_info(${tabela.nome})'))
            .toList();

        List<String> colunasAtuais = tabelaAtual.map((item) {
          if (item['name'] == 'isDeleted') {
            return 'deletado';
          } else if (item['name'] == 'sync' ||
              item['name'] == 'id' ||
              item['name'] == 'imagePath') {
            return '';
          } else
            return item['name'].toString();
        }).toList();
        tabela.colunasBanco = colunasAtuais;
        if (tabela.allowIgnoreCase) {
          tabela.colunasBanco =
              tabela.colunasBanco!.map((e) => e.toLowerCase()).toList();
        }

        Map<String, dynamic> registro = Map.of(data.first);
        for (String coluna in colunasAtuais) {
          if (colunaFaltandoSync(tabela, registro, coluna)) {
            //caso n esteja retornando alguma coluna, cria um log e envia pro servidor
            logAlerta +=
                'Falta coluna na sync na tabela ${tabela.nome}, coluna: $coluna\n';
          }
        }
        for (MapEntry mapEntry in registro.entries) {
          if (colunaFaltandoBanco(colunasAtuais, mapEntry.key, tabela)) {
            logAlerta +=
                'Falta coluna no banco na tabela ${tabela.nome}, coluna: ${mapEntry.key}\n';
          }
        }
      }
    }
    return true;
  }

  /// Verifica se a [coluna] está presente no banco
  /// Levando em consideração fks e colunas ignoradas da [tabela]
  bool colunaFaltandoBanco(
      List<String> colunasAtuais, String coluna, Tabela tabela) {
    return !colunasAtuais.any((c) => c.toLowerCase() == coluna.toLowerCase()) &&
        tabela.fks
                ?.any((fk) => 'cod${(fk.coluna.upperCaseFirst())}' == coluna) !=
            true &&
        tabela.colunasIgnoradas?.any((element) => element == coluna) != true &&
        tabela.itens?.any((item) => item.lista == coluna) != true;
  }

  /// Verifica se a [coluna] está presente na sync
  /// Levando em consideração fks, colunas ignoradas e colunas de arquivos da [tabela]
  bool colunaFaltandoSync(
      Tabela tabela, Map<String, dynamic> registro, String coluna) {
    /// Caso a coluna seja vazia, ignora
    if (coluna.isEmpty) {
      return false;
    }

    /// Caso o registro contenha a coluna
    if (registro.containsKey(coluna)) {
      return false;
    }
    // Caso allowIgnoreCase seja true, verifica se a coluna não existe com um case diferente
    if (tabela.allowIgnoreCase &&
        registro.keys
            .any((element) => element.toLowerCase() == coluna.toLowerCase())) {
      return false;
    }
    // Verifica se não é uma FK
    if (tabela.fks != null &&
        tabela.fks!.any(
            (fk) => '${fk.coluna}_id'.toLowerCase() == coluna.toLowerCase())) {
      return false;
    }
    // Ignora path de arquivos
    if (_isFilePath(coluna, tabela.arquivos)) {
      return false;
    }
    // Caso seja uma coluna marcada como ignorada explicitamente
    if (_colunaIgnorada(coluna, tabela.colunasIgnoradas)) {
      return false;
    }
    return true;
  }

  /// Verifica se a [coluna] é destinada a armazenar o caminho do arquivo
  /// Caso sim, ela não precisa voltar na sync
  bool _isFilePath(String coluna, List<ColumnFile>? colunasArquivos) {
    if (colunasArquivos != null) {
      for (ColumnFile colunaArquivo in colunasArquivos) {
        if (colunaArquivo.filePath == coluna) {
          return true;
        }
      }
    }
    return false;
  }

  /// Retorna true caso a [coluna] esteja na lista de [colunasIgnoradas]
  bool _colunaIgnorada(String coluna, List<String>? colunasIgnoradas) {
    if (colunasIgnoradas != null) {
      return colunasIgnoradas.any((element) => element == coluna);
    }
    return false;
  }

  /// Apaga quaisquer registros que tenham idServer duplicados != -1
  Future<void> verificarInconsistencias(Sync sync) async {
    List<String> querys = [];
    for (Tabela tabela in sync.tabelas) {
      var res = await (AppDatabase().execDataTable(
          'SELECT * FROM ${tabela.nome} WHERE ID NOT IN (SELECT MIN(ID) FROM ${tabela.nome} GROUP BY IDSERVER) AND IDSERVER != -1'));
      if (res.isNotEmpty) {
        await UtilsLog.saveLog(UtilsLog.REGISTRO_ATIVIDADE_FALHA_SALVAR_DADOS,
            'IdServers duplicados: ${res.toString()}', '${tabela.nome}');
        querys.add(
            'DELETE FROM ${tabela.nome} WHERE ID NOT IN (SELECT MIN(ID) FROM ${tabela.nome} GROUP BY IDSERVER) AND IDSERVER != -1');
      }
    }
    AppDatabase().execSQLList(querys);
  }

  bool isSorted<T>(List<T> list, [int Function(T, T)? compare]) {
    if (list.length < 2) return true;
    compare ??= (T a, T b) => (a as Comparable<T>).compareTo(b);
    T prev = list.first;
    for (var i = 1; i < list.length; i++) {
      T next = list[i];
      if (compare(prev, next) > 0) {
        return false;
      }
      prev = next;
    }
    return true;
  }
}
