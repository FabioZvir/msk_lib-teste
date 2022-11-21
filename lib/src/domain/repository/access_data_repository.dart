import 'package:msk/msk.dart';
import 'package:sqfentity_gen/sqfentity_gen.dart';

abstract class AccessDataRepository {
  Future<bool> startTransaction();

  Future<bool> commitTransaction();

  Future<bool> rollbackTransaction();

  Future<int?> saveTo(TableEntityBase t0);

  void rollbakEntity(TableEntityBase? t0);

  Future<List<Map<String, dynamic>>> getDataList(GetDataArgs agrs);

  Future<Map<String, dynamic>?> getDataMap(GetDataArgs agrs);

  Future<List<TableEntityBase<T>>> getDataListObj<T extends TableBase>(
      GetDataArgs agrs, T Function(Map<String, dynamic>) convert);

  Future<TableEntityBase<T>?> getDataObj<T extends TableBase>(
      GetDataArgs agrs, T Function(Map<String, dynamic>) convert);
}
