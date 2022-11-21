import 'fk.dart';

class SetarFK {
  late Map<String, dynamic> map;
  bool? atualizarVersion;
  List<FK> fkNaoEncontrada;

  /// Indica que o regitro deve ser removido da lista de sincronização
  bool? removerRegistroLista;
  SetarFK({this.atualizarVersion, this.fkNaoEncontrada = const []});
}
