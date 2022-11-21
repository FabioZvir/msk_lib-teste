import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart' as mb;
import 'package:msk/src/data/data_access/local/sql/model.dart';
import 'package:msk/msk.dart';

class ConsultaPage extends StatefulWidget {
  final String title;

  const ConsultaPage({Key? key, this.title = "Consulta"}) : super(key: key);

  @override
  _ConsultaPageState createState() => _ConsultaPageState();
}

class RunIntent extends Intent {
  const RunIntent();
}

class BeautifulIntent extends Intent {
  const BeautifulIntent();
}

class _ConsultaPageState extends State<ConsultaPage> {
  final ConsultaController controller =
      ConsultaModule.to.bloc<ConsultaController>();
  final _formKey = GlobalKey<FormState>();
  late BuildContext buildContext;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          TextButton(
            child: Text('Limpar Versões sync'),
            onPressed: () async {
              Navigation.push(context, LimparVersaoSyncModule());
            },
          ),
          /*
          TextButton(
            child: Text('Teste de Estresse'),
            onPressed: () async {
              var resultado = await TesteEstruturaSync.testeEstresse(
                  app.estrutura?.tabelas);
              if (resultado == true) {
                showSnack(buildContext, 'O teste passou com sucesso');
              } else {
                showSnack(buildContext,
                    'O teste falhou, por favor, consulte a tabela de logs');
              }
            },
          )*/
        ],
      ),
      floatingActionButton: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'beautiful',
            tooltip: 'Beautiful',
            onPressed: () async {
              controller.quebrarQuery();
            },
            mini: true,
            child: Icon(Icons.reorder_rounded),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              heroTag: 'export',
              tooltip: 'Exportar',
              onPressed: () async {
                if (controller.list.isEmpty) {
                  showSnack(buildContext,
                      'Nenhum dado para exportar, você precisa executar a query antes de exportar');
                } else {
                  String sJson = json.encode(controller.list);
                  File file = await UtilsFileSelect.saveFileBytes(
                    sJson.codeUnits,
                    extensionFile: '.json',
                    contentExport: 'Exportação de dados ' + app.package,
                  );
                  showSnack(buildContext,
                      'Arquivo exportado com sucesso em: ${file.path}');
                }
              },
              mini: true,
              child: Icon(Icons.share),
            ),
          ),
          FloatingActionButton(
              tooltip: 'Executar', child: Icon(Icons.search), onPressed: _run),
        ],
      ),
      body: Builder(
        builder: (context) {
          buildContext = context;
          return Shortcuts(
              shortcuts: <LogicalKeySet, Intent>{
                LogicalKeySet(LogicalKeyboardKey.escape): const DismissIntent(),
                LogicalKeySet(
                        LogicalKeyboardKey.control, LogicalKeyboardKey.keyR):
                    const RunIntent(),
                LogicalKeySet(
                        LogicalKeyboardKey.control, LogicalKeyboardKey.keyD):
                    BeautifulIntent()
              },
              child: Actions(
                  actions: <Type, Action<Intent>>{
                    DismissIntent: CallbackAction<DismissIntent>(
                        onInvoke: (DismissIntent intent) {
                      Navigator.pop(context);
                      return;
                    }),
                    RunIntent:
                        CallbackAction<RunIntent>(onInvoke: (RunIntent intent) {
                      _run();
                      return;
                    }),
                    BeautifulIntent: CallbackAction<BeautifulIntent>(
                        onInvoke: (BeautifulIntent intent) {
                      controller.quebrarQuery();
                      return;
                    })
                  },
                  child: Focus(
                      autofocus: true,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 16.0, right: 16),
                            child: Form(
                              key: _formKey,
                              child: InputTextField(
                                keyboardType: TextInputType.multiline,
                                maxLines: 15,
                                minLines: 5,
                                autocorrect: false,
                                autofocus: false,
                                enableSuggestions: false,
                                decoration: InputDecoration(
                                    labelText: 'Insira a consulta'),
                                controller: controller.ctlQuery,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Você precisa inserir a consulta';
                                  } else
                                    return null;
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Observer(
                              builder: (_) => ListView.builder(
                                  itemCount: controller.list.length,
                                  shrinkWrap: true,
                                  itemBuilder: (_, pos) {
                                    return Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: _getItem(pos),
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          )
                        ],
                      ))));
        },
      ),
    );
  }

  _run() async {
    if (controller.ctlQuery.text.trim().isEmpty) {
      showSnack(context, 'Insira uma query');
      return;
    }
    try {
      controller.list.clear();
      if (controller.ctlQuery.text.toLowerCase().startsWith('insert') ||
          controller.ctlQuery.text.toLowerCase().startsWith('update') ||
          controller.ctlQuery.text.toLowerCase().startsWith('delete')) {
        List<String> querys = controller.ctlQuery.text.split(';');
        querys.removeWhere((q) => q.isEmpty);
        for (String query in querys) {
          query.replaceAll('\n', ' ');
        }
        try {
          var res = await AppDatabase().execSQLList(querys);
          if (res.success) {
            showSnack(buildContext,
                'Query${querys.length > 1 ? 's' : ''} executada com sucesso');
          } else {
            showSnack(buildContext,
                'Ops, houve uma falha ao executar a${querys.length > 1 ? 's' : ''} query${querys.length > 1 ? 's' : ''}: ${res.errorMessage}',
                duration: Duration(seconds: 7));
          }
        } catch (e) {
          showSnack(buildContext, e.toString());
        }
      } else {
        var res =
            (await (AppDatabase().execDataTable(controller.ctlQuery.text)));
        if (res.isNotEmpty) {
          controller.list = mb.ObservableList<Map<String, dynamic>>.of(
              List<Map<String, dynamic>>.from(res));
          FocusScope.of(context).requestFocus(FocusNode());
          if (controller.list.isEmpty) {
            showSnack(buildContext, 'A query não retornou nenhum resultado');
          }
        } else {
          showSnack(buildContext, 'A query não retornou nenhum resultado');
        }
      }
    } catch (error) {
      showSnack(context, '${error.toString()}',
          duration: Duration(seconds: 10));
    }
  }

  List<Widget> _getItem(int pos) {
    return controller.list[pos].entries
        .map((coluna) =>
            SelectableText('${coluna.key}: ${coluna.value.toString()}'))
        .toList();
  }
}
