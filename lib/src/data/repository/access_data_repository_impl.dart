import 'package:msk/msk.dart';
import 'package:sqfentity_gen/sqfentity_gen.dart';

class AccessDataRepositoryImpl implements AccessDataRepository {
  final LocalDataStore localDataStore;

  AccessDataRepositoryImpl({required this.localDataStore});

  @override
  Future<int?> saveTo(TableEntityBase t0) async {
    try {
      return await localDataStore.saveTo(t0.model);
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
      throw FailExecuteOp(error: error);
    }
  }

  @override
  Future<bool> commitTransaction() async {
    try {
      return await localDataStore.commitTransaction();
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
      throw FailExecuteOp(error: error);
    }
  }

  @override
  Future<bool> rollbackTransaction() async {
    try {
      return await localDataStore.rollbackTransaction();
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
      throw FailExecuteOp(error: error);
    }
  }

  @override
  Future<bool> startTransaction() async {
    try {
      /// Deixa o await para tratar o erro aqui
      return await localDataStore.startTransaction();
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
      throw FailExecuteOp(error: error);
    }
  }

  @override
  void rollbakEntity(TableEntityBase<TableBase>? t0) {
    t0?.model.rollbackPk();
  }

  @override
  Future<List<Map<String, dynamic>>> getDataList(GetDataArgs agrs) async {
    try {
      return await localDataStore.getDataList(agrs);
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
      throw FailExecuteOp(error: error);
    }
  }

  @override
  Future<List<TableEntityBase<T>>> getDataListObj<T extends TableBase>(
      GetDataArgs agrs, T Function(Map<String, dynamic>) convert) async {
    try {
      return (await localDataStore.getDataListObj<T>(agrs, convert))
          .map((e) => TableEntityBase(model: e))
          .toList();
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
      throw FailExecuteOp(error: error);
    }
  }

  @override
  Future<TableEntityBase<T>?> getDataObj<T extends TableBase>(
      GetDataArgs agrs, T Function(Map<String, dynamic> p1) convert) async {
    try {
      final res = await localDataStore.getDataObj<T>(agrs, convert);
      if (res != null) {
        return TableEntityBase<T>(model: res);
      }
      return null;
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
      throw FailExecuteOp(error: error);
    }
  }

  @override
  Future<Map<String, dynamic>?> getDataMap(GetDataArgs agrs) async {
    try {
      return await localDataStore.getDataMap(agrs);
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
      throw FailExecuteOp(error: error);
    }
  }
}
