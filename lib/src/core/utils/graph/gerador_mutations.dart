import 'package:msk_utils/msk_utils.dart';

class GerarMutations {
  static String mesclarQuerys(String queryOriginal, String incremento) {
    return queryOriginal.substring(0, queryOriginal.lastIndexOf('}') - 1) +
        '\n$incremento}';
  }

  static String retornarQuery(String tabela, List<ItemSelect> itens, int id,
      String chaveObjPrincipal, String chaveObjFK,
      {String chaveIdFk = 'idServer'}) {
    String s = '';
    int i = 0;
    for (ItemSelect item in itens) {
      if (item.id != null && item.id != 0) {
        if (item.isDeleted == true) {
          s += gerarMutationDelete(tabela, item.id, i);
        } else {
          s += gerarMutationUpdate(tabela, item.id,
              {chaveObjFK: item.object[chaveIdFk], chaveObjPrincipal: id}, i);
        }
      } else {
        s += gerarMutationInsert(tabela, item.id,
            {chaveObjFK: item.object[chaveIdFk], chaveObjPrincipal: id}, i);
      }
      i++;
    }
    return s;
  }

  static String gerarMutationDelete(String tabela, int? id, int pos) {
    return """  delete_${tabela}_$pos: delete_$tabela(where: {idServer: {_eq: $id}}) {
    affected_rows
  }\n""";
  }

  static String gerarMutationInsert(String tabela, int? id, Map map, int pos) {
    String s = getStringMap(map);
    return """  insert_${tabela}_$pos: insert_$tabela(objects: $s) {
    affected_rows 
  }\n""";
  }

  static String gerarMutationUpdate(String tabela, int? id, Map map, int pos) {
    String s = getStringMap(map);
    return """  update_${tabela}_$pos: update_$tabela(where: {idServer: {_eq: $id}}, _set: $s) {
    affected_rows
  }\n""";
  }

  static String getStringMap(Map? map) {
    String s = '';
    if (map != null && map.isNotEmpty) {
      for (MapEntry e in map.entries) {
        if (e.value.runtimeType == String) {
          s += '${e.key}: "${e.value}", ';
        }
        s += '${e.key}: ${e.value}, ';
      }
      s = s.substring(0, s.length - 2);
    }

    return '{$s}';
  }
}
