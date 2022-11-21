import 'package:msk/msk.dart';

class SelectProductsRepositoryImpl implements SelectProductsRepository {
  DataSourceProductsSelect dataSource;

  SelectProductsRepositoryImpl({
    required this.dataSource,
  });

  Future<List<Product>> getAllProducts() {
    try {
      return dataSource.getAllProducts();
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
      throw FailExecuteOp(error: error);
    }
  }

  @override
  Future<List<UnitMeasureProduct>> getUnitsMeasureByProductId(Product product) {
    try {
      return dataSource.getUnitsMeasureByProductId(product);
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
      throw FailExecuteOp(error: error);
    }
  }

  @override
  Future<UnitMeasureProduct?> getUnitMeasureByCodBar(String codBar) {
    try {
      return dataSource.getUnitMeasuraByCodBar(codBar);
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
      throw FailExecuteOp(error: error);
    }
  }
}
