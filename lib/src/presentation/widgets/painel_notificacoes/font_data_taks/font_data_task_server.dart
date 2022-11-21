import 'package:dio/dio.dart';
import 'package:msk/msk.dart';

class FontDataTaskServer extends BaseFontDataTask {
  @override
  Future<ResponseNotification?> getTasks(String lastVersion) async {
    Response? response = await API.post('api/compras/busca/tarefa',
        data: {"app": "br.com.aynova.compras", "version": lastVersion});
    if (response.sucesso()) {
      return ResponseNotification.fromMap(response!.data);
    }
    return null;
  }
}
