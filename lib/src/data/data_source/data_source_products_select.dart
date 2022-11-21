import 'package:msk/msk.dart';

abstract class DataSourceProductsSelect {
  Future<List<Product>> getAllProducts();

  Future<List<UnitMeasureProduct>> getUnitsMeasureByProductId(Product product);

  Future<UnitMeasureProduct?> getUnitMeasuraByCodBar(String codBar);
}
