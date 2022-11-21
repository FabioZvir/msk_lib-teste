import 'package:hive/hive.dart';
import 'package:mobx/mobx.dart';
import 'package:msk/msk.dart';

part 'app_base_controller.g.dart';

class AppBaseController = _AppBaseBase with _$AppBaseController;

abstract class _AppBaseBase with Store {
  final Future<Box> future = hiveService.getBox('settings');
}
