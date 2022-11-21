import 'tipo_coluna.dart';

class Coluna {
  String nome;
  TipoColuna? tipoColuna;
  bool opcional = true;

  Coluna(this.nome, {this.tipoColuna, this.opcional = true});
}
