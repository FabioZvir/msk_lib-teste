import 'package:flutter_test/flutter_test.dart';
import 'package:msk/msk.dart';

main() {
  test('Teste validação resposta sync', () {
    expect(TesteEstruturaSync.validarColunaBool(0, true), false);
    expect(TesteEstruturaSync.validarColunaBool(0, false), true);
    expect(TesteEstruturaSync.validarColunaBool(1, true), true);
    expect(TesteEstruturaSync.validarColunaBool(1, false), false);
  });

  Tabela tabela = Tabela('Teste',
      fks: [FK('tabela1', 'Tabela1'), FK('tabela2', 'Tabela2')],
      colunasIgnoradas: ['codUsu'],
      arquivos: [ColumnFileFirebase('path', 'url', (_) async => '')]);
  test('Teste Ignoração de coluna', () {
    expect(TesteEstruturaSync.ignorarColuna(tabela, 'id'), true,
        reason: 'Deve ignorar chave primaria');
    expect(TesteEstruturaSync.ignorarColuna(tabela, 'sync'), true,
        reason: 'Deve ignorar chave primaria');

    expect(TesteEstruturaSync.ignorarColuna(tabela, 'codUsu'), true,
        reason: 'Cod usu esta nas colunas ignoradas');
    expect(TesteEstruturaSync.ignorarColuna(tabela, 'tabela1_id'), true,
        reason: 'Deve ignorar os ids das fks');
    expect(TesteEstruturaSync.ignorarColuna(tabela, 'tabela1'), false,
        reason: 'Não deve ignorar a coluna de FK');
    expect(TesteEstruturaSync.ignorarColuna(tabela, 'path'),
        tabela.arquivos.any((element) => element.filePath == 'path') == true,
        reason: 'Deve ignorar a coluna de path do arquivo');
  });

  test('Validação de coluna', () {
    expect(
        TesteEstruturaSync.validarColuna(
            tabela, MapEntry('nome', 'Teste'), {'nome': 'Teste'}),
        null,
        reason: 'Valores retornados são idênticos');
    expect(
        TesteEstruturaSync.validarColuna(
            tabela, MapEntry('nome', 'Teste'), {'nome': 'Outro valor'}),
        isNot(null),
        reason: 'Valores diferentes');
    expect(
        TesteEstruturaSync.validarColuna(
            tabela, MapEntry('id', 1), {'id': null}),
        null,
        reason: 'Coluna é ignorada');
  });
}
