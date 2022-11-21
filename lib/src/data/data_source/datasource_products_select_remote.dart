import 'package:msk/msk.dart';
import 'package:msk/src/data/data_access/local/sql/model.dart';

class DataSourceProductsSelectRemote implements DataSourceProductsSelect {
  final String endpointProducts;
  final String endPointProductUnitMeasure;
  final String endPointUnitMeasureByCodBar;
  final Future<Map<String, dynamic>> Function()? getDataByProducts;

  DataSourceProductsSelectRemote(
      {this.endpointProducts = 'api/servicos/busca/lista/produto',
      this.endPointProductUnitMeasure =
          'api/servicos/busca/lista/produto/unidademedida',
      this.endPointUnitMeasureByCodBar = '',
      this.getDataByProducts});

  @override
  Future<List<Product>> getAllProducts() async {
    var response =
        await API.post(endpointProducts, data: await getDataByProducts?.call());
    return (response!.data as List)
        .map((e) => Product(
            id: e['idServer'],
            idServer: e['idServer'],
            name: e['nome'],
            classification: e['classificacao'],
            structure: e['estrutura'],
            ncm: e['ncm']))
        .toList();
  }

  @override
  Future<List<UnitMeasureProduct>> getUnitsMeasureByProductId(
      Product product) async {
    var response = await API
        .post(endPointProductUnitMeasure, data: {'codProduto': product.id});
    return (response!.data as List)
        .map((e) => UnitMeasureProduct(
            id: e['idServer'],
            idServer: e['idServer'],
            product: product,
            unitMeasure: UnitMeasure(
                id: e['unidadeMedida']['idServer'],
                name: e['unidadeMedida']['nome'],
                abbreviation: e['unidadeMedida']['abreviacao'],
                lastPurchaseValue:
                    e['unidadeMedida']['valorUltimaCompra'] ?? 0)))
        .toList();
  }

  @override
  Future<UnitMeasureProduct?> getUnitMeasuraByCodBar(String codBar) async {
    const query =
        'select p.*, um.*, ump.*, p.nome as produto_nome, ump.idserver as ump.idserver, ump.id as ump_id, p.id as produto_id, p.idserver as produto_idserver, um.id as um_id, um.idserver as um_idserver from produto p '
        'inner join unidademedidaproduto ump on ump.produto_id = p.id '
        'inner join unidademedida um on um.id = ump.unidadeMedida_id '
        "where ump.codBar = \$1 and p.isdeleted = 0 and ump.isdeleted = 0 and um.isdeleted = 0 limit 1";
    final res = await AppDatabase().execDataTable(query, [codBar]);
    return res.isNotEmpty
        ? UnitMeasureProduct(
            id: res.first['idserver'] as int,
            idServer: res.first['idserver'] as int,
            product: Product(
              id: res.first['produto_idserver'] as int,
              idServer: res.first['produto_idserver'] as int,
              name: res.first['produto_nome'] as String,
              structure: res.first['estruturaProduto'] as String? ?? '',
              classification: res.first['classificacao'] as String? ?? '',
              ncm: res.first['ncm'] as int? ?? 0,
            ),
            unitMeasure: UnitMeasure(
              id: res.first['um_idserver'] as int? ?? 0,
              abbreviation: res.first['abreviacao'] as String? ?? '',
              name: res.first['nome'] as String? ?? '',
              lastPurchaseValue: res.first['valorUltimaCompra'] as double? ?? 0,
            ))
        : null;
  }
}
