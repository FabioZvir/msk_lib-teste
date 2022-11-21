import 'package:flutter/material.dart';
import 'package:msk/msk.dart';

class StrategySyncRegistration {
  final List<String> onlyLists;
  final bool exitIfFail;
  final bool awaitFinish;

  StrategySyncRegistration(
      {this.onlyLists = const [],
      this.exitIfFail = false,
      this.awaitFinish = true});
}

abstract class BaseSyncStrategyPage<T extends StatefulWidget> extends State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      applyStrategySync(context);
    });
  }

  /// Sobreecrever para informar uma lista de dados obrigatórios para a tela de cadastro funcionar corretamente
  @protected
  Future<List<RequiredData>> listRequiredData(
      Map<String, dynamic>? args) async {
    return [];
  }

  Future<bool> validationRequiredData(Map<String, dynamic>? args) async {
    List<RequiredData> querys = await listRequiredData(args);
    if (querys.isNotEmpty) {
      for (RequiredData data in querys) {
        if (!(await data.validate())) {
          showSnack(context, data.messageError,
              dismiss: data.dismiss, delayPop: false);
          return false;
        }
      }
    }
    return true;
  }

  void applyStrategySync(BuildContext context) async {
    StrategySyncRegistration? strategy = await getStrategySync();
    if (strategy != null) {
      if (strategy.awaitFinish) {
        var progress = await showProgressDialog(context, 'Sincronizando dados');
        ResultadoSincLocal? resultSync =
            await UtilsSync.atualizarDados(onlyLists: strategy.onlyLists);
        await progress.hide();
        if (resultSync == ResultadoSincLocal.FALHA && strategy.exitIfFail) {
          showSnack(context,
              'Ops, houve uma falha ao sincronizar os dados com o servidor');
          Navigator.pop(context);
        }
        syncFinished(context);
      } else {
        UtilsSync.atualizarDados(onlyLists: strategy.onlyLists).then((value) {
          if (value == ResultadoSincLocal.FALHA && strategy.exitIfFail) {
            showSnack(context,
                'Ops, houve uma falha ao sincronizar os dados com o servidor');
            Navigator.pop(context);
          }
        });
        syncFinished(context);
      }
    } else {
      syncFinished(context);
    }
  }

  void syncFinished(BuildContext context) {}

  Future<StrategySyncRegistration?> getStrategySync() async {
    return null;
  }
}
