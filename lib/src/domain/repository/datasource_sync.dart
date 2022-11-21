import 'package:msk/src/domain/entity/table_rows.dart';

abstract class DataSourceSyncSpecifyRows {
  Future<Map<String, dynamic>> getDataSpecifyRows(List<TableRows> tables);

  Future<Map?> getDataFullSync(Map<String, String> versions);
}
