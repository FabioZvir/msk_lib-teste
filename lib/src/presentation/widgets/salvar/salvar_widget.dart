// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import 'package:msk/msk.dart';

typedef SaveFunction = Future<bool> Function();

typedef ValidateFunction = Future<ResultValidate?> Function();

typedef AddFunction = Future<Map<String, dynamic>?> Function();

typedef DataReturn = Future? Function();

class ResultValidateDialog extends ResultValidate {
  String? title;
  String messageCancel;
  String messageConfirm;

  ResultValidateDialog(
      {String? msg,
      bool showMessage = true,
      bool allowRegister = true,
      this.title,
      this.messageCancel = 'Cancelar',
      this.messageConfirm = 'Confirmar'})
      : super(msg: msg, showMessage: showMessage, allowRegister: allowRegister);
}

class ResultValidate {
  String? msg;
  bool showMessage;
  bool allowRegister;

  ResultValidate({
    this.msg,
    this.showMessage = true,
    this.allowRegister = true,
  });
}

Future<ResultValidate> convertValidate(Function fun) async {
  return ResultValidate(msg: await fun());
}

Future<ResultValidate> mergeValidate(
    ResultValidate res1, ResultValidate res2) async {
  if (res1.msg != null) {
    return res1;
  }
  return res2;
}

class SaveActions {
  SaveFunction? onSave;
  SaveFunction? onDelete;

  /// Acao executada caso o cadastro seja do tipo 3
  SaveFunction? onAction;
  ValidateFunction? verifyData;

  /// Dados a serem retornados a tela anterior (sem salvar nada)
  AddFunction? addDataFuncion;

  /// Indica os dados que devem ser retornados
  DataReturn? dataReturn;

  /// Indica se a tela deve ser fechada
  bool dismiss;
  int? acaoSalvar;
  String? customErrorSaveMessage;

  /// Retorna após o envio dos dados ao servidor
  Function(ResultSendData)? sendSuccess;

  Future<String> Function()? customTitleSaveMessage;
  Future<Widget> Function()? customContentSaveMessage;

  /// Indica se uma janela de progresso deve ser exibida durante o cadastro ou não
  bool? showDialogDuringSave;

  /// Mensagem de erro personalizada
  String? messageErrorOnDelete;

  bool showProgressWhenCheckData;

  SaveActions(
      {this.onSave,
      this.onDelete,
      this.verifyData,
      this.addDataFuncion,
      this.dataReturn,
      this.dismiss = true,
      this.acaoSalvar,
      this.onAction,
      this.customErrorSaveMessage,
      this.sendSuccess,
      this.showDialogDuringSave,
      this.customTitleSaveMessage,
      this.customContentSaveMessage,
      this.messageErrorOnDelete = 'Ops, houve uma falha ao excluir os dados',
      this.showProgressWhenCheckData = false});
}

class SalvarWidget extends StatelessWidget {
  @Deprecated('Você deve usar saveActions no lugar')
  final VoidCallback? onDelete;
  @Deprecated('Você deve usar saveActions no lugar')
  final VoidCallback? onSave;
  final SaveActions? saveActions;

  /// 1 Salvar Dados, 2 Retornar Dados, 3 salvar dados servidor, 4 onAction
  final int? tipoCadastro;
  final SalvarController controller = SalvarController();

  String keyBtSave;

  SalvarWidget(
      {int? statusEdicao,
      this.onDelete,
      this.onSave,
      this.tipoCadastro = 1,
      this.saveActions,
      this.keyBtSave = ''}) {
    // ignore: deprecated_member_use_from_same_package
    assert(saveActions != null || (onDelete != null || onSave != null));

    /// Valida para que não tenham saveActions e onSave != null
    // ignore: deprecated_member_use_from_same_package
    assert(saveActions == null || (onDelete == null && onSave == null));
    controller.statusEdicao = statusEdicao ??
        // ignore: deprecated_member_use_from_same_package
        ((onDelete != null || saveActions?.onDelete != null)
            ? BaseCadastroConst.REGISTRO_DELETAR_ALTERAR
            : BaseCadastroConst.REGISTRO_SALVAR);
    if (tipoCadastro == 3 &&
        saveActions != null &&
        saveActions!.showDialogDuringSave == null) {
      saveActions!.showDialogDuringSave = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 25, bottom: 15),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _getButtons(context)),
    );
  }

  List<Widget> _getButtons(BuildContext context) {
    List<Widget> list = [];
    if (BaseRegisterPage.deletable(controller.statusEdicao)) {
      // ignore: deprecated_member_use_from_same_package
      list.add(Observer(builder: (_) {
        return TextButton(
            child: Text('APAGAR'),
            onPressed: controller.permitirClique
                ? () {
                    exibirDialogoDeletarRegistro(context);
                  }
                : null);
      }));
    }
    if (BaseRegisterPage.generateable(controller.statusEdicao)) {
      list.add(Observer(
        builder: (_) => Button(
          tipoCadastro == 2 ? 'ADICIONAR' : 'SALVAR',
          controller.permitirClique
              ? () async {
                  int timeNow = DateTime.now().millisecondsSinceEpoch;
                  // só deixa clicar dois segundos após o último clique
                  if (controller.timeLastClick < (timeNow - 2000)) {
                    controller.timeLastClick = timeNow;
                    salvarFun(context);
                  }
                }
              : null,
          keyButton: Key('bt_save_${keyBtSave}'),
        ),
      ));
    } else if (BaseRegisterPage.changeable(controller.statusEdicao)) {
      list.add(Observer(
        builder: (_) => Button(
            'ALTERAR',
            controller.permitirClique
                ? () {
                    int timeNow = DateTime.now().millisecondsSinceEpoch;
                    // só deixa clicar dois segundos após o último clique
                    if (controller.timeLastClick < (timeNow - 2000)) {
                      controller.timeLastClick = timeNow;
                      salvarFun(context);
                    }
                  }
                : null),
      ));
    }
    if (list.isEmpty) {
      list.add(Text('Não é possível editar esse registro'));
    }
    return list;
  }

  salvarFun(BuildContext context) async {
    if (saveActions != null &&
        saveActions!.onSave != null &&
        tipoCadastro != 4) {
      controller.permitirClique = false;
      MyPR? progress;
      if (saveActions!.showProgressWhenCheckData) {
        progress = await showProgressDialog(context, 'Verificando dados');
      }
      ResultValidate? resultValidate = (await saveActions!.verifyData?.call());
      await progress?.hide();
      if (resultValidate == null) {
        /// Permite o clique novamente
        controller.permitirClique = true;
        showSnack(context, 'Ops, houve uma falha ao validar os dados');
      } else {
        if (resultValidate.msg != null) {
          if (!(resultValidate is ResultValidateDialog)) {
            /// Permite o clique novamente
            controller.permitirClique = true;
            if (resultValidate.showMessage) {
              showSnack(context, resultValidate.msg!);
            }
          } else {
            if (resultValidate.showMessage) {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (alertContext) => AlertDialog(
                        title: resultValidate.title != null
                            ? Text(resultValidate.title!)
                            : null,
                        content: Text(resultValidate.msg!),
                        actions: [
                          TextButton(
                              onPressed: () {
                                controller.permitirClique = true;
                                Navigator.pop(alertContext);
                              },
                              child: Text(resultValidate.messageCancel)),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(alertContext);
                                _saveData(context);
                              },
                              child: Text(resultValidate.messageConfirm)),
                        ],
                      ));
            } else {
              controller.permitirClique = true;
            }
          }
        } else {
          _saveData(context);
        }
      }
    } else if (saveActions != null &&
        saveActions!.onAction != null &&
        (tipoCadastro == 4 || tipoCadastro == 3)) {
      controller.permitirClique = false;
      await saveActions!.onAction!();
      controller.permitirClique = true;
    } else {
      // ignore: deprecated_member_use_from_same_package
      onSave!();
    }
  }

  deleteFun(BuildContext context) async {
    if (saveActions != null && saveActions!.onDelete != null) {
      controller.permitirClique = false;
      bool success = await saveActions!.onDelete!();
      if (success) {
        if (tipoCadastro == 1) {
          await BaseRegisterPage.sendData(context,
              dismiss: saveActions!.dismiss,
              success: saveActions!.sendSuccess,
              action: BaseCadastroConst.REGISTRO_DELETADO);
        }
      } else {
        controller.permitirClique = true;
        if (saveActions!.messageErrorOnDelete != null) {
          showSnack(context, saveActions!.messageErrorOnDelete!);
        }
      }
    } else {
      // ignore: deprecated_member_use_from_same_package
      onDelete!();
    }
  }

  void exibirDialogoDeletarRegistro(BuildContext buildContext) {
    showDialog(
        context: buildContext,
        barrierDismissible: false,
        builder: (alertContext) => AlertDialog(
              title: Text('Deseja apagar o registro?'),
              content: Text('Esta ação não pode ser desfeita'),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancelar'),
                  onPressed: () {
                    if (Navigator.canPop(alertContext)) {
                      Navigator.pop(alertContext);
                    }
                  },
                ),
                TextButton(
                  child: Text('Confirmar'),
                  onPressed: () async {
                    if (Navigator.canPop(alertContext)) {
                      Navigator.pop(alertContext);
                    }
                    deleteFun(buildContext);
                  },
                ),
              ],
            ));
  }

  Future<void> _saveData(BuildContext context) async {
    if (tipoCadastro == 1) {
      var res = await UtilsRegister.showDialogConfirmRegister(context,
          title: await saveActions!.customTitleSaveMessage?.call(),
          content: await saveActions!.customContentSaveMessage?.call());
      if (res == true) {
        MyPR? progressDialog;
        if (saveActions!.showDialogDuringSave == true) {
          progressDialog = await showProgressDialog(context, 'Salvando dados');
        }
        try {
          /// Usa o try catch pra tratar erros não tratados no save do controller
          bool success = await saveActions!.onSave!();
          if (progressDialog != null && (await progressDialog.isShowing())) {
            await progressDialog.hide();
          }
          if (success) {
            await BaseRegisterPage.sendData(context,
                data: await saveActions!.dataReturn?.call(),
                dismiss: saveActions!.dismiss,
                success: saveActions!.sendSuccess,
                action: saveActions!.acaoSalvar);
            controller.permitirClique = true;
          } else {
            controller.permitirClique = true;
            showSnack(
                context,
                saveActions!.customErrorSaveMessage ??
                    'Ops, houve uma falha ao salvar os dados');
          }
        } catch (error, stackTrace) {
          UtilsSentry.reportError(error, stackTrace);
          await progressDialog?.hide();
          controller.permitirClique = true;
          showSnack(
              context,
              saveActions!.customErrorSaveMessage ??
                  'Ops, houve uma falha ao salvar os dados');
        }
      } else {
        controller.permitirClique = true;
      }
    } else if (tipoCadastro == 3) {
      MyPR? progressDialog;
      if (saveActions!.showDialogDuringSave == true) {
        progressDialog = await showProgressDialog(context, 'Salvando dados');
      }
      try {
        /// Usa o try catch pra tratar erros não tratados no save do controller
        bool success = await saveActions!.onSave!();
        if (progressDialog != null && (await progressDialog.isShowing())) {
          await progressDialog.hide();
        }
        if (success) {
          saveActions!.sendSuccess?.call(ResultSendData(success: true));
          showSnack(
            context,
            'Dados salvos com sucesso',
            delayPop: false,
            dismiss: saveActions!.dismiss,
            data: ReturnRegister(
                    data: await saveActions!.dataReturn?.call(),
                    action: saveActions!.acaoSalvar)
                .toMap(),
          );
        } else {
          controller.permitirClique = true;
          showSnack(
              context,
              saveActions!.customErrorSaveMessage ??
                  'Ops, houve uma falha ao salvar os dados');
        }
      } catch (error, stackTrace) {
        UtilsSentry.reportError(error, stackTrace);
      }
    } else {
      Navigator.pop(
          context,
          ReturnRegister(
                  data: await saveActions!.addDataFuncion?.call(),
                  action: BaseCadastroConst.REGISTRO_SALVAR_ALTERAR)
              .toMap());
    }
  }
}
