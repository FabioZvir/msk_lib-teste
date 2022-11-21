import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:msk/msk.dart';
import 'package:msk/src/data/data_access/local/sql/model.dart';

import 'package:sqfentity_gen/sqfentity_gen.dart';

class IntentSave extends Intent {
  const IntentSave();
}

class IntentDelete extends Intent {
  const IntentDelete();
}

abstract class BaseRegisterPage<T extends StatefulWidget>
    extends BaseRequiredDataPage<T> {
  BaseRegisterController? controller;
  String? table;
  String? title;
  BuildContext? buildContext;
  Future<String> Function()? customTitleSaveMessage;
  Future<Widget> Function()? customContentSaveMessage;
  String? messageErrorOnDelete = 'Ops, houve uma falha ao excluir os dados';
  bool? showProgressWhenCheckData;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      //desativa a confirmação de saída no modo debug
      onWillPop: !UtilsPlatform.isDebug ? _onWillPop : null,
      child: MyScaf(
        appBar: AppBar(
          title: Text(title ?? 'Cadastrar $table'),
          /*actions: <Widget>[
              TextButton(
                  child: Icon(Icons.bug_report),
                  onPressed: () {
                    controller.screenshotController
                        .capture()
                        .then((File image) {})
                        .catchError((error, stackTrace) {
                      UtilsSentry.reportError(error, stackTrace);
                    });
                  })
            ]*/
        ),
        body: Builder(builder: (context) {
          this.buildContext = context;
          return Shortcuts(
              shortcuts: <LogicalKeySet, Intent>{
                LogicalKeySet(LogicalKeyboardKey.escape): const DismissIntent(),
                LogicalKeySet(
                        LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
                    const IntentSave(),
                LogicalKeySet(LogicalKeyboardKey.delete): const IntentDelete(),
              },
              child: Actions(
                  actions: <Type, Action<Intent>>{
                    DismissIntent: CallbackAction<DismissIntent>(
                        onInvoke: (DismissIntent intent) {
                      Navigator.pop(context);
                      return;
                    }),
                    IntentSave: CallbackAction<IntentSave>(
                        onInvoke: (IntentSave intent) {
                      //onSave();
                      return;
                    }),
                    IntentDelete: CallbackAction<IntentDelete>(
                        onInvoke: (IntentDelete intent) {
                      //onDelete();
                      return;
                    }),
                  },
                  child: Focus(
                      autofocus: true,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          constraints: app.enableExperimentalSizeScreen
                              ? BoxConstraints(maxWidth: 820)
                              : null,
                          child: Form(
                              key: controller?.formKey,
                              child: Column(
                                children: [
                                  topWidget(),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      //child: Screenshot(
                                      // controller: controller.screenshotController,
                                      child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 16, right: 16),
                                          child: Column(
                                            children: <Widget>[
                                              buildInterface(context),
                                              saveButton()
                                            ],
                                          )),
                                      //),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ))));
        }),
      ),
    );
  }

  Widget saveButton() {
    return Observer(
      builder: (_) => SalvarWidget(
        statusEdicao: controller?.statusEdition,
        saveActions: SaveActions(
            onSave: saveData,
            acaoSalvar: BaseCadastroConst.REGISTRO_CADASTRADO,
            verifyData: () async {
              var res = await convertValidate(controller!.validateDataForm);
              if (res.msg != null) {
                return res;
              }
              return controller!.advancedValidateData();
            },
            dataReturn: () async {
              await controller?.setValuesObj();
              return controller?.getMapObjs();
            },
            onAction: onAction,
            onDelete: onDelete,
            addDataFuncion: () async {
              await controller?.setValuesObj();
              return controller?.getMapObjs();
            },
            sendSuccess: sendSuccess,
            customTitleSaveMessage: customTitleSaveMessage,
            customContentSaveMessage: customContentSaveMessage,
            messageErrorOnDelete: messageErrorOnDelete,
            showProgressWhenCheckData: showProgressWhenCheckData ?? false,
            showDialogDuringSave: !(controller?.saveLocalBase ?? true)),
        tipoCadastro: controller?.typeRegister,
      ),
    );
  }

  Future<bool> onAction() async {
    return false;
  }

  Future<bool> saveData() async {
    if (controller!.saveLocalBase) {
      return controller!.saveData();
    } else {
      return controller!.saveDataServer();
    }
  }

  Future<bool> onDelete() async {
    if (controller!.saveLocalBase) {
      return deleteRows(await controller!.getIdObjs());
    } else {
      return await deleteServerData();
    }
  }

  Future sendSuccess(ResultSendData resultSendData) async {}

  static Future<bool> deleteRows(Map<String, List<int?>?> map) async {
    try {
      List<String> querys = [];
      String lastUpdateS = '';
      if ((UtilsMigration.appMigrado(GetIt.I.get<App>().package))) {
        lastUpdateS = ', LASTUPDATE = ${DateTime.now().millisecondsSinceEpoch}';
      }
      for (MapEntry<String, List<int?>?> entry in map.entries) {
        if (entry.value != null &&
            entry.value!
                .where((element) => element != null && element != 0)
                .isNotEmpty) {
          String query =
              "UPDATE ${entry.key} SET ISDELETED = 1, SYNC = 1, ${UtilsData.codUsuColumn(GetIt.I.get<App>().package)} = ${GetIt.I.get<App>().authService.user?.id} $lastUpdateS WHERE ";
          for (int? id in entry.value!) {
            if (id != null && id != 0) {
              query += "ID = $id OR ";
            }
          }
          query = query.substring(0, query.length - 3); //remove o ultimo or
          querys.add(query);
        }
      }
      BoolCommitResult res = await AppDatabase().execSQLList(querys);
      return res.success;
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
    }
    return false;
  }

  static Future<bool> updateRows(
      Map<String, List<int?>?> tables, Map<String, dynamic> data,
      {String whereColumn = 'ID'}) async {
    try {
      List<String> querys = [];
      String lastUpdateS = '';
      if ((UtilsMigration.appMigrado(GetIt.I.get<App>().package))) {
        lastUpdateS = ', LASTUPDATE = ${DateTime.now().millisecondsSinceEpoch}';
      }
      for (MapEntry<String, List<int?>?> entry in tables.entries) {
        if (entry.value != null &&
            entry.value!
                .where((element) => element != null && element != 0)
                .isNotEmpty) {
          String s = '';
          data.entries.forEach((element) {
            s += '${element.key} = ${element.value}, ';
          });
          if (s.isNotEmpty) {
            s = s.substring(0, s.length - 2);
          }
          String query =
              "UPDATE ${entry.key} SET $s, SYNC = 1, ${UtilsData.codUsuColumn(GetIt.I.get<App>().package)} = ${GetIt.I.get<App>().authService.user?.id} $lastUpdateS WHERE ";
          for (int? id in entry.value!) {
            if (id != null && id != 0) {
              query += "$whereColumn = $id OR ";
            }
          }
          query = query.substring(0, query.length - 3); //remove o ultimo or
          querys.add(query);
        }
      }
      BoolCommitResult res = await AppDatabase().execSQLList(querys);
      return res.success;
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
    }
    return false;
  }

  Widget buildInterface(BuildContext context) {
    return Container();
  }

  void layoutLoaded(BuildContext context, {Map<String, dynamic>? args}) {}

  Future<bool> deleteServerData() async {
    return false;
  }

  @override
  void dataRequiredChecked(bool sucess, Map<String, dynamic>? args) async {
    if (sucess) {
      final progress = await showProgressDialog(context, 'Carregando dados',
          isDismissible: false);
      await controller?.initData(args, table);
      await progress.hide();
    }
    layoutLoaded(context, args: args);
  }

  static Future<dynamic> sendData(BuildContext context,
      {int? action,
      bool dismiss = true,
      dynamic data,
      Function(ResultSendData)? success,
      bool awaitBackground = false,
      void Function(bool)? onBackgroudSended,
      String messageSuccess = 'Dados enviados com sucesso'}) async {
    FocusScope.of(context).requestFocus(FocusNode());
    MyPR pr = await showProgressDialog(
        context, 'Enviando dados para o servidor',
        isDismissible: false);
    bool res = await UtilsSync.enviarDados(
        awaitBackground: awaitBackground, onBackgroudSended: onBackgroudSended);
    if (await pr.isShowing()) {
      await pr.hide();
    }
    success?.call(ResultSendData(success: res, action: action));
    if (res) {
      return await showSnack(context, messageSuccess,
          dismiss: dismiss,
          data: ReturnRegister(data: data, action: action).toMap(),
          delayPop: false);
    } else {
      return await showSnack(context,
          'Os dados foram salvos, mas a sincronização será feita mais tarde',
          dismiss: dismiss,
          data: ReturnRegister(data: data, action: action).toMap(),
          delayPop: false);
    }
  }

  static bool deletable(int status) {
    return (status == BaseCadastroConst.REGISTRO_DELETAR_ALTERAR ||
        status == BaseCadastroConst.REGISTRO_DELETAR);
  }

  static bool changeable(int status) {
    return status == BaseCadastroConst.REGISTRO_SALVAR_ALTERAR ||
        status == BaseCadastroConst.REGISTRO_DELETAR_ALTERAR ||
        BaseCadastroConst.REGISTRO_ALTERAR == status;
  }

  static bool generateable(int status) {
    return status == BaseCadastroConst.REGISTRO_SALVAR ||
        status == BaseCadastroConst.REGISTRO_SALVAR_ALTERAR;
  }

  Future<bool> _onWillPop() async {
    return (await (showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: Text('Deseja sair sem salvar os dados?'),
            content: Text(
                'Ao tocar em sim, as alterações da tela atual serão descartadas'),
            actions: <Widget>[
              new TextButton(
                onPressed: () => Navigator.maybeOf(context)?.pop(false),
                child: new Text('Cancelar'),
              ),
              new TextButton(
                onPressed: () => Navigator.maybeOf(context)?.pop(true),
                child: new Text('Sim'),
              ),
            ],
          ),
        ))) ??
        false;
  }

  Widget topWidget() {
    return SizedBox();
  }
}

class ResultSendData {
  bool? success;
  int? action;
  ResultSendData({this.success, this.action});
}
