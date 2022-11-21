import 'package:mobx/mobx.dart';
import 'package:msk/src/app.dart';
import 'package:sortedmap/sortedmap.dart';

part 'limpar_versao_sync_controller.g.dart';

class LimparVersaoSyncController = _LimparVersaoSyncControllerBase
    with _$LimparVersaoSyncController;

abstract class _LimparVersaoSyncControllerBase with Store {
  SortedMap<String, dynamic> versions = SortedMap(Ordering.byKey());

  /// Carrega do método resposável por determinar as versões de cada lista
  Future<Map<String, dynamic>> carregarVersoes() async {
    Map<String, dynamic> ver = await app.estrutura.getVersions();
    versions.addAll(ver);
    return versions;
  }
}
