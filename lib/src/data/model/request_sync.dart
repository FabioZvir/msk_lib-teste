import 'package:get_it/get_it.dart';
import 'package:msk/src/app.dart';

class RequestSync {
  String app;
  String version;
  Map<String?, String> versions = Map();

  Map<String, bool>? incluirDeletados = Map();

  RequestSync(this.version, this.versions, this.app, {this.incluirDeletados});

  toMap() {
    Map<String, dynamic> map = Map();
    map['version'] = this.version;
    map['versions'] = this.versions;
    map['app'] = this.app;
    return map;
  }

  static getLista(String lista) {
    return RequestSync('0x0000000000000000', {lista: '0x0000000000000000'},
        GetIt.I.get<App>().package,
        incluirDeletados: {lista: false}).toMap();
  }
}
