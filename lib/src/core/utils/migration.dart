import 'package:msk/msk.dart';

class UtilsMigration {
  /// Retorna apps que ja implementam as colunas
  /// UniqueKey, lastUpdate, codUsu
  static const listaAppsMigrados = [
    'br.com.msk.timber_track',
    'br.com.aynova.timber_cargo',
    'br.com.aynova.compras',
    'br.com.msk.msk_ceo',
    'br.com.aynova.aynova_pcm'
  ];

  static bool appMigrado(String package) {
    return app.migratedApp || listaAppsMigrados.contains(package);
  }
}
