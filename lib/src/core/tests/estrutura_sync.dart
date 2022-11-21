import 'dart:io';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:get_it/get_it.dart';
import 'package:msk/msk.dart';
import 'package:msk/src/data/data_access/local/sql/model.dart';
import 'package:msk/src/domain/entity/log.dart';
import 'package:path_provider/path_provider.dart';

class TesteEstruturaSync {
  static List<String> validarEstrutura(List<Tabela> tabelas) {
    List<String> list = [];
    List<String> errado = [];
    for (Tabela tabela in tabelas) {
      if (list.contains(tabela.nome)) {
        errado.add('Tabela ${tabela.nome} duplicada');
      }
      if (tabela.fks != null && tabela.fks!.isNotEmpty) {
        for (FK fk in tabela.fks!) {
          if (!list.any((it) => it == fk.tabela)) {
            errado.add("Tabela: ${tabela.nome} - FK: ${fk.tabela}");
          }
        }
      }
      list.add(tabela.nome);
    }

    return errado;
  }

  static Future<bool?> testeEstresse(List<Tabela> tabelas) async {
    if (!UtilsPlatform.isRelease) {
      for (Tabela tabela in tabelas) {
        await AppDatabase().execSQL('update ${tabela.nome} set sync = 1');
      }
      return await EnviarDados().sincronizar();
    }
    return null;
  }

  /// Testes sincronização dados
  static atualizarRegistros(Tabela tabela, {int limit = 10}) async {
    DateTime date = DateTime.now();
    int d = date.millisecondsSinceEpoch;
    d = d - d % 10;
    //// Deixa sempre o numero terminando com 0, para evitar problemas do servidor não guardar não guardar com tanta precisão os dados
    String codUsu = 'codUsu = ${authService.user?.id}';
    if (app.package == 'br.com.msk.timber_track') {
      codUsu = 'codUsuTimber = ${authService.user?.id}';
    }
    return await AppDatabase().execSQL('UPDATE ${tabela.nome} '
        'SET sync = 1, LASTUPDATE = ${d}, $codUsu '
        'WHERE id IN (SELECT id '
        'FROM ${tabela.nome} '
        'ORDER BY IDSERVER DESC '
        'LIMIT $limit)');
  }

  static testeDadosSync(List<Tabela> tabelas) async {
    Logs logs = Logs();

    EnviarDados enviarDados = EnviarDados();
    AtualizarDados atualizarDados = AtualizarDados();
    Map<String, Map<String, List>> resultadosGerais = Map();
    for (Tabela tabela
        in tabelas.where((element) => element.endPoint?.isNotEmpty == true)) {
      await atualizarRegistros(tabela, limit: 10);
      List<Map<String?, dynamic>?> dados =
          await enviarDados.buscarDadosTabela(tabela);
      if (dados.isNotEmpty) {
        List<ResultSync>? resultado =
            await enviarDados.enviarDados(dados, tabela.endPoint);
        if (resultado != null) {
          String logResultado =
              enviarDados.validarRetornoDados(tabela.nome, dados, resultado);
          if (logResultado.isNotEmpty) {
            logs.add(Log(logResultado.trimRight(), TiposLog.FALHA_REDE,
                duplicar: true));
            logs.add(Log(
                'Dados enviados: ${dados.toString()}', TiposLog.FALHA_REDE,
                duplicar: true));
            logs.add(Log(
                'Retorno: ${resultado.toString()}', TiposLog.FALHA_REDE,
                duplicar: true));
          }
          bool s = await enviarDados.atualizarDados(resultado, tabela);
          resultadosGerais.addAll({
            tabela.nome: {'dados': dados, 'resultado': resultado}
          });
          if (s != true) {
            logs.add(Log('Tabela ${tabela.nome} falha ao cadastrar (500)',
                TiposLog.FALHA_REDE,
                duplicar: true));
          }
        } else {
          logs.add(Log(
              'Tabela ${tabela.nome} falha ao cadastrar', TiposLog.FALHA_REDE,
              duplicar: true));
        }
      }
    }
    Map? map = await atualizarDados.repository
        .getDataFullSync(await GetIt.I.get<App>().estrutura.getVersions());
    if (map != null) {
      for (Tabela tabela
          in tabelas.where((element) => element.endPoint?.isNotEmpty == true)) {
        if (resultadosGerais.containsKey(tabela.nome) &&
            resultadosGerais[tabela.nome]!['dados']!.isNotEmpty) {
          for (Map<String, dynamic>? dado
              in resultadosGerais[tabela.nome]!['dados']
                  as Iterable<Map<String, dynamic>?>) {
            dado = Map.of(dado!);
            dado['idServer'] = resultadosGerais[tabela.nome]!['resultado']!
                .firstWhereOrNull((element) => element.id == dado!['id'])
                ?.idServer;
            if (map[tabela.lista] == null) {
              Log('Tabela ${tabela.nome} não retornou na sync',
                  TiposLog.REGISTRO_AUSENTE,
                  duplicar: true);
            } else {
              if (dado['idServer'] != null) {
                Map? dadoSync = (map[tabela.lista] as List).firstWhereOrNull(
                    (d) => d['idServer'] == dado!['idServer']);
                if (dadoSync == null) {
                  Log log = Log(
                      "Tabela ${tabela.nome} não retornou linha com idServer ${dado['idServer']} na sync",
                      TiposLog.REGISTRO_AUSENTE,
                      tabela: tabela.nome,
                      duplicar: true);

                  logs.add(log);
                } else {
                  for (MapEntry entry in dado.entries) {
                    logs.add(validarColuna(tabela, entry, dadoSync));
                  }
                }
              } else {
                Log('Tabela ${tabela.nome} não foi possível localizar idServer no retorno do cadastro do registro ${dado['id']}',
                    TiposLog.REGISTRO_AUSENTE,
                    duplicar: true);
              }
            }
          }
        }
      }
    } else {
      logs.add(Log("Houve uma falha ao buscar os dados", TiposLog.FALHA_REDE));
    }
    String stringLog = logs.toString();
    print(stringLog);
  }

  static Log? validarColuna(Tabela tabela, MapEntry entry, Map dadoSync) {
    if (!ignorarColuna(tabela, entry.key)) {
      FK? fk = tabela.fks
          ?.firstWhereOrNull((element) => element.coluna == (entry.key));

      if (fk != null) {
        String nomeColunaFK = 'cod${fk.coluna.upperCaseFirst()}';
        if (dadoSync.containsKey(nomeColunaFK)) {
          if (entry.value != dadoSync[nomeColunaFK] &&
              !(entry.value == null && dadoSync[nomeColunaFK] == 0)) {
            return Log(
                'Tabela ${tabela.nome} coluna ${entry.key} idServer ${dadoSync['idServer']} retornada na sync ${dadoSync['cod${(fk.coluna.upperCaseFirst())}']} não corresponde ao esperado ${entry.value}',
                TiposLog.DADOS_DIFERENTE_ESPERADO,
                tabela: tabela.nome);
          }
        } else {
          return Log('Tabela ${tabela.nome} falta coluna ${entry.key} na sync',
              TiposLog.FALTA_COLUNA_SYNC,
              duplicar: true, tabela: tabela.nome);
        }
      } else {
        if (dadoSync.containsKey(entry.key)) {
          if (entry.value != dadoSync[entry.key] &&
              !validarColunaBool(entry.value, dadoSync[entry.key]) &&
              entry.key != 'codUsu') {
            return Log(
                'Tabela ${tabela.nome} coluna ${entry.key} idServer ${dadoSync['idServer']} retornada na sync ${dadoSync[entry.key]} não corresponde ao esperado ${entry.value}'
                '${entry.value?.toString() == dadoSync[entry.key]?.toString() ? ' (Tipos errados (${entry.value?.runtimeType} x ${dadoSync[entry.key]?.runtimeType}))' : ''} ',
                TiposLog.DADOS_DIFERENTE_ESPERADO,
                duplicar: true,
                tabela: tabela.nome);
          }
        } else {
          return Log('Tabela ${tabela.nome} falta coluna ${entry.key} na sync',
              TiposLog.FALTA_COLUNA_SYNC,
              tabela: tabela.nome);
        }
      }
    }
    return null;
  }

  /// Valida as diferentes formas de representação de um valor bool
  static bool validarColunaBool(dynamic intValue, dynamic boolValue) {
    return ((boolValue?.toString() == 'true' && intValue == 1) ||
        (boolValue?.toString() == 'false' && intValue == 0));
  }

  /// Retorna um bool indicando se a [coluna] deve ser ignorada ou não
  static bool ignorarColuna(Tabela tabela, String coluna) {
    return coluna == 'id' ||
        coluna == 'sync' ||
        coluna == 'isDeleted' ||
        _ignorarColunaCaminhoArquivo(tabela, coluna) ||
        _ignorarColunaFK(tabela, coluna) ||
        _ignorarColunaLista(tabela, coluna);
  }

  /// Caso a [coluna] seja um id de uma fk, ignora ela da validação
  static bool _ignorarColunaFK(Tabela tabela, String coluna) {
    return (tabela.fks != null &&
        tabela.fks!.any((element) => element.coluna + '_id' == coluna));
  }

  /// Caso a [coluna] esteja na lista de ignoradas, ignora ela
  static bool _ignorarColunaLista(Tabela tabela, String coluna) {
    return tabela.colunasIgnoradas != null &&
        tabela.colunasIgnoradas!.any((element) => element == coluna);
  }

  /// Caso a [coluna] seja o path de um arquivo, ignora ela
  static bool _ignorarColunaCaminhoArquivo(Tabela tabela, String coluna) {
    return tabela.arquivos.any((element) => element.filePath == coluna);
  }

  static testSyncMultipleUsers(List<int> users, List<Tabela> tables,
      Map<String, dynamic> versions) async {
    for (int userId in users) {
      await _clearDataBase(tables);
      await _clearVersionsSync(versions);
      await AtualizarDados().sincronizar(
          userId: userId,
          logFuncion: (String log) async {
            if (log.isNotEmpty) {
              await writeLog(
                  'Relatorio sincronizacao usuario $userId:\n\n$log', userId);
            }
          });
    }
  }

  /// Clear all data for specified [tables]
  static _clearDataBase(List<Tabela> tables) async {
    for (Tabela table in tables) {
      await AppDatabase().execSQL('DELETE FROM ${table.nome}');
    }
  }

  static Future<bool> _clearVersionsSync(Map<String, dynamic> versions) async {
    for (MapEntry map in versions.entries) {
      await Sync.zerarVersao(map.key);
    }
    return true;
  }

  static Future<String?> get _localPath async {
    final directory = await (getExternalStorageDirectory());
    return directory?.path;
  }

  static Future<File> _localFile(String name) async {
    final path = await _localPath;
    return File('$path/relatorio_sincronizacao_usuario_$name.txt');
  }

  static Future<File> writeLog(String log, int userId) async {
    final file = await _localFile('$userId');
    return file.writeAsString(log);
  }
}
