import 'package:flutter_test/flutter_test.dart';
import 'package:msk/msk.dart';
import 'package:msk/src/data/data_access/local/sql/model.dart';

main() {
  registrarSingletons(
      App(
          'nome',
          'package',
          Sync([]),
          AppDatabase(),
          AuthServiceBase(
              package: 'br.com.aynova.compras2',
              iAuthNetwork:
                  AuthNetworkDio(() => Constants.BASE_URL + getPorta()),
              iPersistDataStorage: UtilsPlatform.isMobile
                  ? PersistDataStorageSecure()
                  : PersistDataStorageHive(),
              logAuth: (_) {},
              sendConfirmToken: false),
          Portas(Constants.PORTA_DEBUG, Constants.PORTA_DEBUG),
          (_) {},
          ''),
      HiveService());
  //initModule(AppBaseModule(App('Teste', '', Sync([]), )));

  setUp(() {
    //test = TestModule.to.get<TestController>();
  });

  AtualizarDados atualizarDados = AtualizarDados();
  test('Teste chaves duplicadas', () {
    // expect(
    //     atualizarDados.checkAndRemoveDuplicates('tabela', [
    //       {'idServer': 1},
    //       {'idServer': 1},
    //       {'idServer': 3}
    //     ]),

    //     reason: 'Deve remover um registro pois os ids estão duplicados');
    // expect(
    //     atualizarDados.existemChavesDuplicadas('tabela', [
    //       {'idServer': 1},
    //       {'idServer': 2},
    //       {'idServer': 3}
    //     ]),
    //     false,
    //     reason: 'Não deve remover pois todos os ids são distintos');
  });

  test('Busca Binária', () {
    expect(
        atualizarDados.getIndexColumn([
          {'idServer': 1},
          {'idServer': 3},
          {'idServer': 5},
        ], 3, 'idServer'),
        1);
    expect(
        atualizarDados.getIndexColumn([
          {'idServer': 1},
          {'idServer': 2},
          {'idServer': 3},
          {'idServer': 4},
          {'idServer': 5},
        ], 1, 'idServer'),
        0);
    expect(
        atualizarDados.getIndexColumn([
          {'idServer': 1},
          {'idServer': 2},
          {'idServer': 3},
          {'idServer': 4},
          {'idServer': 5},
        ], 5, 'idServer'),
        4);
    expect(
        atualizarDados.getIndexColumn([
          {'idServer': 1},
          {'idServer': 2},
          {'idServer': 3},
          {'idServer': 4},
          {'idServer': 5},
        ], 10, 'idServer'),
        -1,
        reason: 'O número não existe na lista');
  });

  Tabela tabela = Tabela('Teste',
      fks: [FK('tabela1', 'Tabela1')],
      colunasIgnoradas: ['codUsu'],
      arquivos: [ColumnFileFirebase('path', 'url', (_) async => 'path')]);
  Map<String, dynamic> registroSync = {'nome': 'Aaa', 'idade': 12, 'url': ''};
  List<String> colunasBanco = ['nome', 'idade', 'tabela1_id', 'url', 'path'];
  group('Testes validação colunas', () {
    test('Testes colunas Sync', () {
      expect(atualizarDados.colunaFaltandoSync(tabela, registroSync, 'nome'),
          false,
          reason: 'Coluna está presente no Map');
      expect(
          atualizarDados.colunaFaltandoSync(
              tabela, registroSync, 'coluna_ausente'),
          true,
          reason: 'Coluna não está presente no Map');
      expect(atualizarDados.colunaFaltandoSync(tabela, registroSync, 'codUsu'),
          false,
          reason:
              'Coluna deve ser ignorada, pois ela está na lista de ignoradas');
      expect(
          atualizarDados.colunaFaltandoSync(tabela, registroSync, 'tabela1_id'),
          false,
          reason: 'Coluna é uma FK');
      expect(atualizarDados.colunaFaltandoSync(tabela, registroSync, 'tabela1'),
          true,
          reason: 'Coluna é uma FK fora do padrão');
      expect(atualizarDados.colunaFaltandoSync(tabela, registroSync, 'path'),
          false,
          reason: 'Coluna é path de um arquivo');
      expect(
          atualizarDados.colunaFaltandoSync(tabela, registroSync, 'url'), false,
          reason: 'Coluna é url de um arquivo');
    });

    test('Teste Colunas Banco', () {
      expect(atualizarDados.colunaFaltandoBanco(colunasBanco, 'nome', tabela),
          false,
          reason: 'Coluna existe no banco');
      expect(atualizarDados.colunaFaltandoBanco(colunasBanco, 'Testes', tabela),
          true,
          reason: 'Coluna não existe no banco');
      expect(
          atualizarDados.colunaFaltandoBanco(
              colunasBanco, 'codTabela1', tabela),
          false,
          reason: 'Coluna é uma FK');
      expect(
          atualizarDados.colunaFaltandoBanco(colunasBanco, 'tabela1', tabela),
          true,
          reason: 'Coluna é uma FK fora do padrão');
      expect(atualizarDados.colunaFaltandoBanco(colunasBanco, 'codUsu', tabela),
          false,
          reason: 'Coluna deve ser ignorada');
    });
  });

  test('Teste setar FKs', () async {
    Map<String, List<Map<String, dynamic>>> mapList = {
      'Tabela1': [
        {'idServer': 1, 'id': 2},
        {'idServer': 2, 'id': 3},
        {'idServer': 3, 'id': 4},
        {'idServer': 4, 'id': 5},
      ]
    };

    expect(
        atualizarDados
            .setarFks(tabela, {'codTabela1': 3}, mapList, true, '0')
            .map['tabela1_id'],
        4,
        reason: 'Fk setada é diferente da esperada');
    expect(
        atualizarDados
            .setarFks(tabela, {'codTabela1': 1}, mapList, true, '0')
            .map['tabela1_id'],
        2,
        reason: 'Fk setada é diferente da esperada');
    expect(
        atualizarDados
            .setarFks(tabela, {'codTabela1': 5}, mapList, true, '0')
            .map['tabela1_id'],
        null,
        reason: 'Fk não existe na lista');

    var result =
        atualizarDados.setarFks(tabela, {'codTabela1': 5}, mapList, true, '0');
    expect(result.map.containsKey('codTabela1'), false,
        reason: 'Coluna original deve ser removida');

    // Setar a coluna como null FK
    expect(
        atualizarDados
            .setarFks(tabela, {'codTabela1': null}, mapList, true, '0')
            .map
            .containsKey('tabela1_id'),
        true,
        reason: 'Fk não existe na lista');
    expect(
        atualizarDados
            .setarFks(tabela, {'codTabela1': null}, mapList, true, '0')
            .map['tabela1_id'],
        null,
        reason: 'Fk não existe na lista');
  });
}
