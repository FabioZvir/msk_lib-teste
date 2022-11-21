import 'package:msk/msk.dart';
import 'package:sqfentity_gen/sqfentity_gen.dart';

class GetDataArgsMemory implements GetDataArgs {
  Type type;

  GetDataArgsMemory(this.type);
}

class LocalDataStoreMemory implements LocalDataStore {
  final List<TableBase> _data = [];
  @override
  Future<bool> commitTransaction() async {
    return true;
  }

  @override
  Future<bool> rollbackTransaction() async {
    return true;
  }

  @override
  Future<int?> saveTo(TableBase t0) async {
    if ((t0 as dynamic).id == null) {
      (t0 as dynamic).id = _data.length + 1;
    }
    int index = _data
        .indexWhere((element) => (element as dynamic).id == (t0 as dynamic).id);
    if (index > -1) {
      _data[index] = t0;
    } else {
      _data.add(t0);
    }
    return (t0 as dynamic).id;
  }

  @override
  Future<bool> startTransaction() async {
    return true;
  }

  @override
  Future<List<Map<String, dynamic>>> getDataList(GetDataArgs args) async {
    if (args is GetDataArgsMemory) {
      return _data
          .where((element) => element.runtimeType == args.type)
          .map((e) => e.toMap())
          .toList();
    }
    return [];
  }

  @override
  Future<List<T>> getDataListObj<T extends TableBase>(
      GetDataArgs agrs, T Function(Map<String, dynamic>) convert) async {
    return _data.whereType<T>().toList();
  }

  @override
  Future<T?> getDataObj<T extends TableBase>(
      GetDataArgs agrs, T Function(Map<String, dynamic> p1) convert) async {
    return _data.whereType<T>().toList().firstOrNull;
  }

  @override
  Future<Map<String, dynamic>?> getDataMap(GetDataArgs args) async {
    if (args is GetDataArgsMemory) {
      return _data
          .where((element) => element.runtimeType == args.type)
          .map((e) => e.toMap())
          .firstOrNull;
    }
    return null;
  }
}
