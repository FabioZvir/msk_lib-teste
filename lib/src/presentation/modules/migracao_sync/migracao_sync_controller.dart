import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:mobx/mobx.dart';
import 'package:msk/msk.dart';
import 'package:msk/src/data/data_access/local/sql/model.dart';

part 'migracao_sync_controller.g.dart';

class MigracaoSyncController = _MigracaoSyncControllerBase
    with _$MigracaoSyncController;

abstract class _MigracaoSyncControllerBase with Store {
  @observable
  double progressoMigracao = 0;
  @observable
  bool falha = false;
  @observable
  String label =
      'Estamos trabalhando em algumas mudanças no App para trazer mais estabilidade e segurança com os dados';
  @observable
  String table = "";

  Future<bool> atualizarDados() async {
    try {
      Box box = await hiveService.getBox('update_base');
      await UtilsData.inicializarBD();
      if (!box.containsKey('updated')) {
        int? userId = authService.user?.id;
        List<Tabela> tabelas = GetIt.I.get<App>().estrutura.tabelas;
        int qtdProcessada = 0;
        for (Tabela tabela in tabelas) {
          await AppDatabase().execSQL('UPDATE ${tabela.nome} '
              'SET uniqueKey = idServer '
              'WHERE uniqueKey IS NULL AND IDSERVER > -1');
          int timestamp = DateTime.now().millisecondsSinceEpoch;
          int i = 0;

          List? data = await (AppDatabase().execDataTable(
              'SELECT id FROM ${tabela.nome} WHERE IDSERVER <= -1 AND uniqueKey IS NULL'));
          for (Map map in data) {
            await AppDatabase().execSQL('UPDATE ${tabela.nome} '
                'SET uniqueKey = $timestamp$i$userId '
                'WHERE id = ${map['id']}');
            i++;
          }
          qtdProcessada++;
          progressoMigracao = (qtdProcessada / tabelas.length);
        }
        await box.put('updated', true);
        return true;
      } else {
        await limparDuplicatas();
        return true;
      }
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
    }
    return false;
  }

  /// Limpa todos os registros com uniqueKey duplicada
  Future<bool> limparDuplicatas() async {
    try {
      List<String> querys = [];
      for (Tabela tabela in app.estrutura.tabelas) {
        var res = await (AppDatabase().execDataTable(
            'SELECT * FROM ${tabela.nome} WHERE ID NOT IN (SELECT MIN(ID) FROM ${tabela.nome} GROUP BY UNIQUEKEY) AND UNIQUEKEY IS NOT NULL'));
        if (res.isNotEmpty) {
          await UtilsLog.saveLog(UtilsLog.REGISTRO_ATIVIDADE_FALHA_SALVAR_DADOS,
              'UniqueKeys duplicados: ${res.toString()}', '${tabela.nome}');
        }
        querys.add(
            'DELETE FROM ${tabela.nome} WHERE ID NOT IN (SELECT MIN(ID) FROM ${tabela.nome} GROUP BY UNIQUEKEY) AND UNIQUEKEY IS NOT NULL');
      }
      await AppDatabase().execSQLList(querys);
      return true;
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
    }
    return false;
  }

  Future<bool> verificarDadosIncompletos() async {
    try {
      String logs = '';
      List<String> querysDelecao = [];
      for (Tabela tabela in app.estrutura.tabelas) {
        if (tabela.fks?.isNotEmpty == true &&
            tabela.fks!
                .where((element) => element.obrigatoria == true)
                .isNotEmpty) {
          String query = gerarQueryDadosIncompletos(tabela);
          final res = await (AppDatabase().execDataTable(query));
          if (res.isNotEmpty) {
            logs += 'Dados incompletos tabela ${tabela.nome}: $res\n';

            querysDelecao.add(
                'DELETE FROM ${tabela.nome} WHERE ID IN (${res.map((e) => e['id'] as int?).toList().join(',')})');
            await Sync.zerarVersao(tabela.lista);
          }
        }
      }
      if (logs.isNotEmpty) {
        await UtilsLog.saveLog(
            UtilsLog.REGISTRO_ATIVIDADE_DADOS_INCOMPLETOS, logs, '');
      }
      await AppDatabase().execSQLList(querysDelecao);
      return true;
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
    }
    return false;
  }

  String gerarQueryDadosIncompletos(Tabela tabela, {String? where}) {
    String colunasFk = '';
    String inners = '';
    String wheres = 'where t0.isdeleted = 0 ';

    //percore todas as fks
    List<FK> fksFiltradas =
        tabela.fks!.where((element) => element.obrigatoria == true).toList();
    for (int i = 0; i < fksFiltradas.length; i++) {
      String alias =
          't${i + 1}'; //apelidos comecao sempre no t1 (t0 e a tabela principal)
      colunasFk +=
          '$alias.idServer as ${fksFiltradas[i].coluna}, '; //pega o nome da coluna
      inners +=
          'left join ${fksFiltradas[i].tabela} $alias on t0.${fksFiltradas[i].coluna}_id = $alias.id '; //faz os joins
      if (wheres.isEmpty) {
        wheres = 'where ';
      } else {
        wheres += 'and ';
      }
      wheres += 'ifnull($alias.idServer, 0) = 0 ';
      //aqui ele filtra para nao pegar registros de fks q ainda n foram sincronizados,
      //mas pega as fks nulas (que podem ser opcionais)
    }
    if (colunasFk.isNotEmpty) {
      colunasFk = ', ' + colunasFk.substring(0, colunasFk.length - 2);
    }

    String s =
        'select t0.id, t0.idServer, t0.isDeleted as deletado $colunasFk from ${tabela.nome} t0 $inners '
        '$wheres';
    //orderna pelos ultimos ids, isso garante que caso um registro n possa ser enviado, n trave o resto da fila
    return s;
  }
}
