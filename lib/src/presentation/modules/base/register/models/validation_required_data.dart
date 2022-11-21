import 'package:hive/hive.dart';
import 'package:msk/msk.dart';
import 'package:msk/src/data/data_access/local/sql/model.dart';

abstract class RequiredData {
  String messageError;
  bool dismiss;

  /// 1 = Insert, 2 = Update
  int type;
  RequiredData(
      {required this.messageError, this.dismiss = true, this.type = 1});
  Future<bool> validate();
}

class RequiredDataSQL extends RequiredData {
  String query;

  RequiredDataSQL(this.query, String messageError, {bool dismiss = true})
      : super(messageError: messageError, dismiss: dismiss);
  @override
  Future<bool> validate() async {
    try {
      return (await AppDatabase().execDataTable(query)).isNotEmpty;
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
      return false;
    }
  }
}

class RequiredDataAccessMenu extends RequiredData {
  int menuId;
  RequiredDataAccessMenu(
      {required this.menuId,
      required String messageError,
      bool dismiss = true,
      required int type})
      : super(messageError: messageError, dismiss: dismiss, type: type);

  @override
  Future<bool> validate() async {
    Box menuBox = await hiveService.getBox(Constants.MENU_BOX_NAME);
    for (final menu in menuBox.values) {
      if ((menu as Menu).codSistema == menuId) {
        if ((type == 1 && menu.insereDados == true) ||
            (type == 2 && menu.alteraDados == true)) {
          return true;
        }
      }
    }
    return false;
  }
}
