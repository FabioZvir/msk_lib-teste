import 'package:select_any/select_any.dart';

import 'model.dart';

class KeyListLineQuery {
  String key;
  dynamic Function(Map<String, dynamic> obj, List<Map<String, dynamic>> list)
      data;
  KeyListLineQuery(this.key, this.data);
}

class ListLineQuery {
  List<KeyListLineQuery> keys;
  String query;
  ListLineQuery({
    required this.keys,
    required this.query,
  });
}

class DatabaseSource extends DataSourceAny {
  Query query;

  /// Deixa como função para que n fique fixo ao entrar novamente no menu
  List<ListLineQuery> Function()? linesList;

  DatabaseSource(this.query,
      {String? id,
      bool allowExport = true,
      bool supportSingleLineFilter = true,
      this.linesList})
      : super(
            id: id,
            allowExport: allowExport,
            supportSingleLineFilter: supportSingleLineFilter);

  Future<List<Map<String, dynamic>>> fetchData(
      int? limit, int offset, SelectModel? selectModel,
      {Map? data}) async {
    String stringQuery = await query.call(data);
    List<Map<String, Object?>> res =
        await (AppDatabase().execDataTable(stringQuery));

    /// Gera uma lista de mapas editáveis
    res = res.map((e) => Map<String, dynamic>.of(e)).toList();
    if (linesList != null) {
      for (ListLineQuery line in linesList!()) {
        var resItens = await AppDatabase().execDataTable(line.query);
        for (var item in res) {
          for (final key in line.keys) {
            item[key.key] = key.data(item, resItens);
          }
        }
      }
    }
    listAll = res;
    return res;
  }
}

typedef Query = Future<String> Function(dynamic data);
