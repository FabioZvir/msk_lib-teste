import 'package:msk/msk.dart';
import 'package:msk/src/domain/repository/datasource_sync.dart';
import 'package:msk/src/domain/repository/repository_sync.dart';

class RepositorySyncSpecifyRowsImpl extends RepositorySync {
  RepositorySyncSpecifyRowsImpl({
    required DataSourceSyncSpecifyRows dataSource,
  }) : super(dataSource: dataSource);

  @override
  Future<Map<String, dynamic>> getDataSpecifyRows(List<TableRows> tables) {
    try {
      return dataSource.getDataSpecifyRows(tables);
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
      rethrow;
    }
  }

  @override
  Future<Map?> getDataFullSync(Map<String, String> versions) async {
    try {
      return dataSource.getDataFullSync(versions);
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
      rethrow;
    }
  }
}
