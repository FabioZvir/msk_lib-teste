import 'package:bloc_pattern/bloc_pattern.dart' as bp;
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:msk/msk.dart';

class HiveService extends bp.Disposable {
  HiveService() {
    init();
  }

  init() {
    UtilsHive([MenuAdapter()]);
  }

  Future<Box> getBox(String name) async {
    return await UtilsHive.getInstance()!.getBox(name);
  }

  @override
  Future<void> dispose() async {
    await hiveService.dispose();
  }
}

HiveService hiveService = GetIt.I.get<HiveService>();
