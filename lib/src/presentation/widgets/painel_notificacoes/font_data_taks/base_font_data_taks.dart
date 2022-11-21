import 'package:msk/msk.dart';

abstract class BaseFontDataTask {
  Future<ResponseNotification?> getTasks(String lastVersion);

  Future<TarefaServidor?> getTaskById(int uniqueKey) async {
    ResponseNotification? response = await getTasks('0x0000000000000000');
    if (response != null) {
      return response.tarefas
          ?.firstWhereOrNull((e) => e.uniqueKey == uniqueKey);
    }
    return null;
  }
}
