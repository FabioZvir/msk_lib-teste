import 'package:msk/msk.dart';
import 'package:sqfentity_gen/sqfentity_gen.dart';

abstract class LocalDataStore extends DataStoreBase {
  Future<bool> startTransaction();

  Future<bool> commitTransaction();

  Future<bool> rollbackTransaction();

  Future<int?> saveTo(TableBase t0);

  Future<List<Map<String, dynamic>>> getDataList(GetDataArgs agrs);

  Future<Map<String, dynamic>?> getDataMap(GetDataArgs agrs);

  Future<List<T>> getDataListObj<T extends TableBase>(
      GetDataArgs agrs, T Function(Map<String, dynamic>) convert);

  Future<T?> getDataObj<T extends TableBase>(
      GetDataArgs agrs, T Function(Map<String, dynamic>) convert);
}
