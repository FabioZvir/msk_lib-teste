import 'colunas_imagens.dart';
import 'fk.dart';
import 'tabela_itens.dart';

class Tabela {
  String? endPoint;
  String nome;
  String? lista;

  /// Indica colunas que possuem caminhos de arquivos que devem ser enviados para o servidor
  List<ColumnFile> arquivos = [];
  List<FK>? fks = [];
  List<TabelaItens>? itens = [];

  /// Colunas que realmente estao na base
  List<String>? colunasBanco = [];

  /// Colunas que devem ser ignoradas na validação
  List<String>? colunasIgnoradas = [];

  /// Indica se os dados devem ser enviados na ordem (id ASC) ou em ordem reversa (id DESC)
  bool enviarEmOrdem;

  /// Indica que a tabela deve ser enviada para o servidor em background
  late bool sendInBackground;

  bool allowIgnoreCase;

  Tabela(this.nome,
      {this.endPoint,
      this.fks,
      this.itens,
      this.lista,
      this.arquivos = const [],
      this.colunasIgnoradas,
      this.enviarEmOrdem = false,
      this.allowIgnoreCase = false,
      bool? sendInBackground}) {
    this.sendInBackground = sendInBackground ?? arquivos.isNotEmpty;
  }
}
