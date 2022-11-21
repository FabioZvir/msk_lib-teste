import 'package:msk/src/data/data_access/local/sql/model.dart';
import 'package:msk/src/domain/entity/item_select_product.dart';

import 'data_source_products_select.dart';

class DataSourceProductsSelectSql implements DataSourceProductsSelect {
  @override
  Future<List<Product>> getAllProducts() async {
    String query = 'select p.* from produto p '
        'where p.isDeleted = 0  '
        'order by p.nome asc';
    final res = await AppDatabase().execDataTable(query);
    return res.map((e) => Product.fromMap(e)).toList();
  }

  @override
  Future<List<UnitMeasureProduct>> getUnitsMeasureByProductId(
      Product product) async {
    final res1 = await AppDatabase().execDataTable(
        'select um.*, ump.id as ump_id, ump.idServer as ump_idserver from unidadeMedida um '
        'inner join unidademedidaproduto ump on ump.unidademedida_id = um.id '
        'where um.isdeleted = 0 and ump.isdeleted = 0 and ump.produto_id = ${product.id}');
    return res1
        .map((e) => UnitMeasureProduct(
              id: e['ump_id'] as int,
              product: product,
              idServer: e['ump_idserver'] as int,
              unitMeasure: UnitMeasure(
                  id: e['id'] as int,
                  name: e['nome'] as String,
                  abbreviation: e['abreviacao'] as String,
                  lastPurchaseValue:
                      (e['valorUltimaCompra'] as double?) ?? 0.0),
            ))
        .toList();
  }

  @override
  Future<UnitMeasureProduct?> getUnitMeasuraByCodBar(String codBar) async {
    const query =
        'select p.*, ump.*, p.nome as produto_nome, ump.id as ump_id, ump.idserver as ump_idserver, p.id as produto_id, um.id as um_id, p.idserver as p_idserver from produto p '
        'inner join unidademedidaproduto ump on ump.produto_id = p.id '
        'inner join unidademedida um on um.id = ump.unidadeMedida_id '
        "where ump.codBar = \$1 and p.isdeleted = 0 and ump.isdeleted = 0 and um.isdeleted = 0 limit 1";
    final res = await AppDatabase().execDataTable(query, [codBar]);
    return res.isNotEmpty
        ? UnitMeasureProduct(
            id: res.first['ump_id'] as int,
            idServer: res.first['ump_idserver'] as int,
            product: Product(
              id: res.first['produto_id'] as int,
              idServer: res.first['p_idserver'] as int,
              name: res.first['produto_nome'] as String,
              structure: res.first['estruturaProduto'] as String? ?? '',
              classification: res.first['classificacao'] as String? ?? '',
              ncm: res.first['ncm'] as int? ?? 0,
            ),
            unitMeasure: UnitMeasure(
              id: res.first['um_id'] as int? ?? 0,
              abbreviation: res.first['abreviacao'] as String? ?? '',
              name: res.first['nome'] as String? ?? '',
              lastPurchaseValue: res.first['valorUltimaCompra'] as double? ?? 0,
            ))
        : null;
  }
}
