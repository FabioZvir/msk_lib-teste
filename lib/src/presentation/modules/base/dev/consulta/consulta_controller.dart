import 'package:flutter/cupertino.dart';
import 'package:mobx/mobx.dart';

part 'consulta_controller.g.dart';

class ConsultaController = _ConsultaBase with _$ConsultaController;

abstract class _ConsultaBase with Store {
  final TextEditingController ctlQuery = TextEditingController();
  @observable
  ObservableList<Map<String, dynamic>> list = ObservableList();

  void quebrarQuery() {
    if (ctlQuery.text.trim().isEmpty) return;
    String query = ctlQuery.text;
    query = query.toUpperCase();
    query = query.replaceAll(' INNER', '\nINNER');
    query = query.replaceAll(' LEFT JOIN', '\nLEFT JOIN');
    query = query.replaceAll(' WHERE', '\nWHERE');
    query = query.replaceAll(' AND', '\nAND');
    query = query.replaceAll(' ORDER BY', '\nORDER BY');
    query = query.replaceAll(' GROUP BY', '\nGROUP BY');
    var linhas = query.split('\n');
    var newQuery = '';
    for (var linha in linhas) {
      if (linha.startsWith("'") || linha.startsWith('"')) {
        linha = linha.substring(1);
      }
      if (linha.endsWith("'") || linha.endsWith('"')) {
        linha = linha.substring(0, linha.length - 1);
      }
      newQuery += '${linha.trim()}\n';
    }
    ctlQuery.text = newQuery;
  }
}
