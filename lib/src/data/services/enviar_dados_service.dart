import 'dart:convert';
import 'dart:io';

import 'package:bloc_pattern/bloc_pattern.dart' as bp;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:msk/msk.dart';
import 'package:msk/src/data/data_access/local/sql/model.dart';

class EnviarDados extends bp.Disposable {
  @override
  void dispose() {
    checkDeleteRows();
    UtilsSync.notificar('Envio de dados Finalizado', '$logNotificacao\n', true,
        id: 2);
    if (logNotificacao.isNotEmpty) {
      debugPrint(logNotificacao);
    }
    logNotificacao = '';
    log = '';
    _instance!.sincronizando = false;
  }

  bool sincronizando = false;
  String log = '';

// log que não precisa ser salvo, apenas aparecer pro usuário
  String logNotificacao = '';
  static EnviarDados? _instance;

  factory EnviarDados() {
    _instance ??= EnviarDados._internalConstructor();
    return _instance!;
  }

  EnviarDados._internalConstructor();

  Future<bool> sincronizar(
      {Function(double)? onProgress, bool sendInBackground = false}) async {
    if (!_instance!.sincronizando) {
      try {
        if (await API.isConnected()) {
          bool sucesso = true;
          _instance!.sincronizando = true;
          Sync sync = GetIt.I.get<App>().estrutura;
          List<Tabela> tabelas = sync.tabelas
              .where((tabela) =>
                  tabela.endPoint != null &&
                  tabela.endPoint!.isNotEmpty &&
                  // Caso sendInBackground seja true, tenta enviar todas
                  (sendInBackground ||
                      // Caso não seja, envia somente as tabelas que sendInBackground = false
                      tabela.sendInBackground == sendInBackground))
              .toList();
          int i = 0;
          for (Tabela tabela in tabelas) {
            onProgress?.call(((++i / tabelas.length) * 100));
            bool sucessoTabela = await enviarTabela(tabela);
            if (!sucessoTabela) {
              sucesso = sucessoTabela;
            }
          }
          dispose();
          return sucesso;
        } else {
          return false;
        }
      } catch (error, stackTrace) {
        await UtilsLog.saveLog(
            UtilsLog.REGISTRO_ATIVIDADE_ERRO_RESPOSTA_SERVIDOR,
            'Falha ao sincronizar dados: ${error.toString()}',
            '');
        UtilsSentry.reportError(
          error,
          stackTrace,
        );
        dispose();
        return false;
      }
    } else {
      return true;
    }
  }

  Future<List<Map<String?, dynamic>?>> buscarDadosTabela(Tabela tabela) async {
    String query = UtilsSync.gerarQuery(tabela);
    List<Map<String, dynamic>>? list =
        (await AppDatabase().execDataTable(query));
    list = List.of(list);
    if (list.isNotEmpty) {
      list = await buscarItens(list, tabela);
    }
    return list;
  }

  Future<bool> enviarTabela(Tabela tabela) async {
    bool sucesso = true;
    List<Map<String?, dynamic>?> dados = await buscarDadosTabela(tabela);
    dados = await filtrarDadosIncompletos(dados, tabela);
    if (dados.isNotEmpty) {
      try {
        dados = await _enviarArquivos(dados, tabela);
        // verifica novamente se ela não está vazia, pois ela pode ficar no envio de arquivos
        if (dados.isNotEmpty) {
          List<ResultSync>? results = await enviarDados(dados, tabela.endPoint);
          //enviar dados
          if (results != null && results.isNotEmpty) {
            String logs = validarRetornoDados(tabela.nome, dados, results);
            if (logs.isNotEmpty) {
              logNotificacao += logs;
            }
            await atualizarDados(results, tabela);
            //dar o await para esperar setar os idServer, que pod ser usado na proxima lista
            bool s = !results.any((item) => !item.sucesso!);
            if (!s) {
              salvarLogs(
                  'Falha ao sincronizar ${tabela.nome} (500) - JSON: ${json.encode(dados)}\n');

              sucesso = s;
            } else {
              logNotificacao += '${tabela.nome} sincronizada com sucesso\n';
              debugPrint('${tabela.nome} sincronizada com sucesso');
            }
          } else {
            logNotificacao += 'Falha ao sincronizar ${tabela.nome}\n';
            // Não registra log aqui porque o log deve ser registrado numa função a nível mais baixo
            sucesso = false;
          }
        }
      } catch (error, stackTrace) {
        // Trata qualquer erro exceto se for um DioErrr com SocketException (erro de conexão)
        if (!(error is DioError) || !(error.error is SocketException)) {
          UtilsSentry.reportError(error, stackTrace, data: json.encode(dados));
          //evita loop
          if (tabela.nome != "RegistroAtividade" &&
              tabela.nome != "RegistroAtividades") {
            //da um await, para que o log seja enviado ainda na mesma sincronizacao
            await UtilsLog.saveLog(
                UtilsLog.REGISTRO_ATIVIDADE_ERRO_RESPOSTA_SERVIDOR,
                'Falha ao sincronizar ${tabela.nome} - ${tabela.endPoint}: ${error.toString()} - JSON: ${json.encode(dados)}',
                '');
          }
        } else {
          debugPrint('Erro na rede');
        }
        sucesso = false;
      }
    }
    return sucesso;
  }

  Future<List<Map<String?, dynamic>?>> filtrarDadosIncompletos(
      List<Map<String?, dynamic>?> dados, Tabela tabela) async {
    if (tabela.fks == null || tabela.fks!.isEmpty || dados.isEmpty) {
      return dados;
    }
    String log = "";
    List<String> querysDelecao = [];
    for (FK fk in tabela.fks!) {
      if (fk.obrigatoria == true) {
        for (int i = 0; i < dados.length; i++) {
          if (dados[i]![fk.coluna] == null) {
            if (log.isEmpty) {
              log = "Tabela: ${tabela.nome} dados removidos da sync: \n";
            }
            log += '${fk.coluna} - ${dados[i]}\n';

            querysDelecao.add(
                "DELETE FROM ${tabela.nome} WHERE id = ${dados[i]!['id']}");
            dados.removeAt(i);

            /// Decrementa um item, pois a lista ficou menor
            i--;
          }
        }
      }
    }
    if (log.isNotEmpty) {
      await UtilsLog.saveLog(
          UtilsLog.REGISTRO_ATIVIDADE_DADOS_INCOMPLETOS, log, '${tabela.nome}');
      var success = await AppDatabase().execSQLList(querysDelecao);
      debugPrint(success.success.toString());
    }
    return dados;
  }

  salvarLogs(String log) async {
    this.log += log;
    await UtilsLog.saveLog(
        UtilsLog.REGISTRO_ATIVIDADE_ERRO_RESPOSTA_SERVIDOR, log, '');
    debugPrint(log);
  }

  Future<List<Map<String?, dynamic>?>> _enviarArquivos(
      List<Map<String?, dynamic>?> dados, Tabela tabela) async {
    UserInterface? usuario = authService.user;
    if (tabela.arquivos.isNotEmpty) {
      int total = tabela.arquivos.length * dados.length;
      int progresso = 1;
      List<bool> sucesso = [];

      for (int i = 0; i < dados.length; i++) {
        // Caso o registro seja deletado, e ainda não tenha alcançado o servidor
        // Deleta o mesmo, pois causará infinito erro 500
        if (dados[i]!['isDeleted']?.toString() == '1' &&
            dados[i]!['idServer']?.toString() == '-1') {
          _deletarRegistro(tabela, dados[i]!['id']);
          sucesso.add(true);
        }

        for (ColumnFile coluna in tabela.arquivos) {
          if (coluna is ColumnFileFirebase) {
            if ((!dados[i]!.containsKey('isDeleted') ||
                    (dados[i]!['isDeleted'].toString() != "1")) &&
                dados[i]!.containsKey(coluna.filePath) &&
                dados[i]!.containsKey(coluna.url) &&
                dados[i]![coluna.filePath] != null &&
                dados[i]![coluna.filePath] != '' &&
                (dados[i]![coluna.url] == null ||
                    dados[i]![coluna.url] == '')) {
              File file = File(dados[i]![coluna.filePath]);
              if (file.existsSync()) {
                UtilsSync.notificarProgresso(
                    'Enviando arquivos da tabela ${tabela.nome}',
                    ((progresso / total) * 100).toInt(),
                    id: 3);
                dados[i] = Map<String, dynamic>.from(dados[i]!);
                File file = File(dados[i]![coluna.filePath]);
                String path = await coluna.pathFileFirebase({
                  'usuario': usuario,
                  'path': dados[i]![coluna.filePath],
                  'dado': dados[i]
                });
                String? url = await UtilsFirebaseFile.sendFile(file, path);
                if (url != null && url.isNotEmpty) {
                  dados[i]![coluna.url] = url;
                  await _salvarUrl(tabela, coluna.url, dados[i]!);
                  sucesso.add(true);
                } else {
                  dados.removeAt(i);
                  i--;
                  sucesso.add(false);
                }
              } else {
                debugPrint('Deletando registro pq o arquivo não existe');
                _deletarRegistro(tabela, dados[i]!['id']);
                sucesso.add(true);
              }
            }
          } else if (coluna is ColumnFileServer) {
            try {
              File file = File(dados[i]![coluna.filePath]);
              if (file.existsSync()) {
                dados[i] = Map<String, dynamic>.from(dados[i]!);
                dados[i]![coluna.key] = base64Encode(file.readAsBytesSync());
                sucesso.add(true);
              } else {
                sucesso.add(false);
              }
            } catch (_) {}
          }
        }
      }
      // remove todos os que estiverem deletados e com idServer -1
      // remove no final do codigo para não dar problema no for
      dados.removeWhere((dado) =>
          dado!['isDeleted']?.toString() == '1' &&
          dado['idServer']?.toString() == '-1');
      if (sucesso.isNotEmpty) {
        UtilsSync.notificar(
            'Envio de arquivos',
            sucesso.every((element) => false)
                ? 'Ops, o envio dos arquivos para o servidor da tabela ${tabela.nome} falhou, tente novamente apertando o botão de sincronizar'
                : sucesso.any((element) => false)
                    ? 'Ops, o envio de alguns arquivos para o servidor da tabela ${tabela.nome} falhou, tente novamente apertando o botão de sincronizar'
                    : 'Arquivos da tabela ${tabela.nome} enviados com sucesso',
            false,
            id: 3);
      }
    }
    return dados;
  }

  /// Salva o url da tabela especificada
  _salvarUrl(Tabela tabela, String coluna, Map<String?, dynamic> dado) async {
    await AppDatabase().execSQL(
        "UPDATE ${tabela.nome} SET $coluna = '${dado[coluna]}' WHERE ID = ${dado["id"]}");
  }

  /// Deleta o registro da [tabela] conforme o [id] especificado
  _deletarRegistro(Tabela tabela, int? id) async {
    await AppDatabase().execSQL("DELETE FROM ${tabela.nome} WHERE ID = $id");
  }

  Future<bool> atualizarDados(List<ResultSync> results, Tabela tabela) async {
    bool sucesso = true;
    for (ResultSync result in results) {
      if (result.sucesso!) {
        var res = await AppDatabase().execSQL(
            "UPDATE ${tabela.nome} SET idServer = ${result.idServer}, sync = 0 WHERE id = ${result.id}");
        if (tabela.itens != null) {
          for (ResultSync sub in result.listaRetorno) {
            var res = await AppDatabase().execSQL(
                "UPDATE ${tabela.itens![0].nome} SET idServer = ${sub.idServer}, sync = 0 WHERE id = ${sub.id}");
            if (!res.success) sucesso = false;
          }
        }
        if (!res.success) sucesso = false;
      } else {
        sucesso = false;
      }
    }
    return sucesso;
  }

  Future<List<Map<String, dynamic>>> buscarItens(
      List<Map<String, dynamic>> dados, Tabela tabela) async {
    if (tabela.itens != null && tabela.itens!.isNotEmpty) {
      for (int i = 0; i < dados.length; i++) {
        for (TabelaItens lista in tabela.itens!) {
          dados[i] = Map<String, dynamic>.from(dados[i]);
          //necessario criar um novo map, o original é somente leitura
          String query = UtilsSync.gerarQuery(lista,
              where:
                  // ignore: deprecated_member_use_from_same_package
                  'and t0.${lista.fks!.firstWhere((fk) => (fk.paiItem != null && fk.paiItem!)).coluna.toLowerCase()}_id = ${dados[i]['id'].toString()}');
          dados[i][lista.lista!] =
              (await AppDatabase().execDataTable(query)).toList();
          //(await AppDatabase().execDataTable(
          //         lista.query.replaceAll('?', dados[i]['id'].toString())))
          //     .toList();
          //isso n pega as fks
          //as fks já retornam preenchidas da query
        }
      }
    }
    return dados;
  }

  Future<List<ResultSync>?> enviarDados(
      List<Map<String?, dynamic>?> list, String? endPoint) async {
    Response? response =
        await API.post(endPoint, dataList: list, retornarFalhas: true);
    if (response.sucesso()) {
      List<ResultSync> resultado = [];
      for (Map<String, dynamic> map in response!.data) {
        ResultSync s = ResultSync.fromMap(map);
        resultado.add(s);
      }
      return resultado;
    }
    return null;
  }

  String validarRetornoDados(String nomeTabela,
      List<Map<String?, dynamic>?> dados, List<ResultSync> resultado) {
    String logs = '';

    /// Validar retorno do cadastro
    if (dados.length != resultado.length) {
      logs +=
          'Tabela ${nomeTabela} Quantidade de dados enviados difere da quantidade retornada\n';
    }
    for (Map? map in dados) {
      if (!resultado.any((element) => element.id == map!['id'])) {
        logs +=
            'Tabela ${nomeTabela} id ${map!['idServer']} (idServer ${map['idServer']}) cadastrado, porém não retornou do servidor\n';
      }
      if (map!['idServer'] > -1) {
        if (!resultado.any((element) => element.idServer == map['idServer'])) {
          logs +=
              'Tabela ${nomeTabela} idServer ${map['idServer']} cadastrado, porém não retornou do servidor\n';
        }
      }
    }
    return logs;
  }

  Future<void> checkDeleteRows() async {
    Sync estrutura = GetIt.I.get<App>().estrutura;

    // cria duas condicoes separadas, pois a tabela pode chamar tanto registroatividade no singular ou no plural

    /// Só deleta logs que não possuem nenhum arquivo atrelado
    if (estrutura.tabelas
        .any((element) => element.nome.toLowerCase() == 'registroatividade')) {
      AppDatabase().execSQL(
          'delete from registroAtividade where (idServer != -1 or ifnull(lastUpdate, 0) < ${DateTime.now().subtract(Duration(days: 15)).millisecondsSinceEpoch}) AND '
          'not exists (select 1 from arquivoRegistroAtividade a where a.registroAtividade_id = id and a.idServer == -1)');
    }
    if (estrutura.tabelas
        .any((element) => element.nome.toLowerCase() == 'registroatividades')) {
      AppDatabase().execSQL(
          'delete from registroatividades where (idServer != -1 or ifnull(lastUpdate, 0) < ${DateTime.now().subtract(Duration(days: 15)).millisecondsSinceEpoch}) AND '
          'not exists (select 1 from arquivoRegistroAtividade a where a.registroAtividade_id = id and a.idServer == -1)');
    }

    // Limpa os arquivos enviados
    AppDatabase()
        .execSQL('delete from arquivoRegistroAtividade where idServer != -1');

    /// Feedback
    AppDatabase().execSQL(
        'delete from feedbackusuario where idServer != -1 AND '
        'not exists (select 1 from ArquivoFeedback a where a.feedbackUsuario_id = a.id and a.idServer == -1)');
    AppDatabase().execSQL('delete from ArquivoFeedback where idServer != -1');
    return;
  }
}
