import 'package:msk/msk.dart';
import 'package:msk/src/data/data_access/local/sql/model.dart';
import 'package:sqfentity_gen/sqfentity_gen.dart';

class GetDataArgsSql implements GetDataArgs {
  String query;
  List args;
  GetDataArgsSql({
    required this.query,
    this.args = const [],
  });
}

class LocalDataStoreSQL implements LocalDataStore {
  Future<int?> saveTo(TableBase t0) {
    return t0.saveOrThrow() as Future<int?>;
  }

  @override
  Future<bool> startTransaction() async {
    return (await AppDatabase().execSQL('BEGIN')).success;
  }

  @override
  Future<bool> commitTransaction() async {
    return (await AppDatabase().execSQL('COMMIT')).success;
  }

  @override
  Future<bool> rollbackTransaction() async {
    return (await AppDatabase().execSQL('ROLLBACK')).success;
  }

  @override
  Future<List<Map<String, dynamic>>> getDataList(GetDataArgs args) async {
    if (args is GetDataArgsSql) {
      return await AppDatabase().execDataTable(args.query, args.args);
    }
    return [];
  }

  @override
  Future<List<T>> getDataListObj<T extends TableBase>(
      GetDataArgs args, T Function(Map<String, dynamic>) convert) async {
    if (args is GetDataArgsSql) {
      return (await AppDatabase().execDataTable(args.query, args.args))
          .map((e) => convert(e))
          .toList();
    }
    return [];
  }

  @override
  Future<T?> getDataObj<T extends TableBase>(
      GetDataArgs args, T Function(Map<String, dynamic> p1) convert) async {
    if (args is GetDataArgsSql) {
      if (!args.query.contains('limit 1') && !args.query.contains('LIMIT 1')) {
        args.query += ' LIMIT 1';
      }
      final res = (await AppDatabase().execDataTable(args.query, args.args))
          .map((e) => convert(e))
          .firstOrNull;
      return res;
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> getDataMap(GetDataArgs agrs) async {
    if (agrs is GetDataArgsSql) {
      return (await AppDatabase().execDataTable(agrs.query, agrs.args))
          .firstOrNull;
    }
    return null;
  }
}
