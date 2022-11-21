import 'package:msk/src/domain/entity/item_select_product.dart';

abstract class SelectProductsRepository {
  Future<List<Product>> getAllProducts();

  Future<List<UnitMeasureProduct>> getUnitsMeasureByProductId(Product product);

  Future<UnitMeasureProduct?> getUnitMeasureByCodBar(String codBar);
}
