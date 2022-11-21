import 'package:flutter/material.dart';

class UtilsRegister {
  static Future<bool?> showDialogConfirmRegister(BuildContext buildContext,
      {String? title,
      Widget? content,
      String textConfirm = 'Confirmar',
      String textCancel = 'Cancelar',
      Widget? widgetTitle}) async {
    /// Valores no construtor não funcionam pois a classe de base sempre envia esses parâmetros, mesmo sendo nulos
    assert(title == null || widgetTitle == null);
    if (widgetTitle == null) {
      if (title == null) {
        widgetTitle = Text('Confirma o cadastro dos dados?');
      } else {
        widgetTitle = Text(title);
      }
    }
    if (content == null) {
      content = const Text(
          'Por favor, confirme se os dados cadastrados estão corretos');
    }
    return await showDialog<bool>(
        context: buildContext,
        builder: (alertContext) => AlertDialog(
              title: widgetTitle,
              content: content,
              actions: <Widget>[
                TextButton(
                  child: Text('Cancelar'),
                  onPressed: () {
                    if (Navigator.canPop(alertContext)) {
                      Navigator.pop(alertContext, false);
                    }
                  },
                ),
                TextButton(
                  autofocus: true,
                  child: Text('Confirmar'),
                  onPressed: () async {
                    Navigator.pop(alertContext, true);
                  },
                ),
              ],
            ));
  }
}
