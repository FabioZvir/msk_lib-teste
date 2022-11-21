import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:msk/msk.dart';
import 'package:msk/src/domain/repository/datasource_sync.dart';

class DataSourceSyncSpecifyRowsImpl implements DataSourceSyncSpecifyRows {
  @override
  Future<Map<String, dynamic>> getDataSpecifyRows(
      List<TableRows> tables) async {
    try {
      Response? response = await API.post('api/servicos/busca/dados',
          data: {
            "listas": tables.map((e) => e.toMap()).toList(),
            "package": app.package
          },
          retornarFalhas: true);
      if (response == null) {
        throw Exception('Falha ao recuperar dados');
      }
      return response.data;
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
      rethrow;
    }
  }

  @override
  Future<Map?> getDataFullSync(Map<String, String> versions) async {
    RequestSync requestSync =
        RequestSync('0x0000000000000000', versions, GetIt.I.get<App>().package);
    Response? response =
        await API.post(app.endPoints.sincronizacao, data: requestSync.toMap());
    if (response.sucesso() && response!.data is Map) {
      return response.data;
    }
    return null;
  }
}
