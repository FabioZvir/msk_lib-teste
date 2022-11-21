import 'package:msk/src/domain/entity/table_rows.dart';

import 'datasource_sync.dart';

abstract class RepositorySync {
  DataSourceSyncSpecifyRows dataSource;
  RepositorySync({
    required this.dataSource,
  });

  Future<Map<String, dynamic>> getDataSpecifyRows(List<TableRows> tables);

  Future getDataFullSync(Map<String, String> versions);
}
