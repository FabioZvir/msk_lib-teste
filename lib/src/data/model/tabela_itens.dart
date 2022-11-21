import 'fk.dart';
import 'tabela.dart';

class TabelaItens extends Tabela {
  String query;

  TabelaItens(this.query, String nome,
      {List<FK>? fks, List<TabelaItens>? itens, String? lista})
      : super(nome, fks: fks, itens: itens, lista: lista);
}
