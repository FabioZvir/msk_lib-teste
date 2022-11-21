import 'package:intl/intl.dart';
import 'package:msk/src/core/configs/constants.dart';

class ReturnFirebaseRequest {
  int id = 0;
  List<Map<String, dynamic>?>? object;
  int codUsu = 0;
  String? idDevice;
  late DateTime date;
  String? query;

  ReturnFirebaseRequest();

  toJson() {
    Map<String, dynamic> map = Map();
    map['id'] = id;
    map['query'] = query;
    map['object'] = object;
    map['codUsu'] = codUsu;
    map['idDevice'] = idDevice;
    map['date'] = DateFormat(Constants.DEFAULT_PATTERN_DATE).format(date);
    return map;
  }
}
