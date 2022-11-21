import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:msk/src/data/data_access/local/sql/model.dart';
import 'package:msk/msk.dart';

class LimparVersaoSyncPage extends StatefulWidget {
  final String title;
  const LimparVersaoSyncPage({Key? key, this.title = "Limpar Versões Sync"})
      : super(key: key);

  @override
  _LimparVersaoSyncPageState createState() => _LimparVersaoSyncPageState();
}

class _LimparVersaoSyncPageState extends State<LimparVersaoSyncPage> {
  LimparVersaoSyncController _controller =
      LimparVersaoSyncModule.to.bloc<LimparVersaoSyncController>();
  late BuildContext context;

  @override
  Widget build(BuildContext _) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (UtilsPlatform.isDebug)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FloatingActionButton(
                  mini: true,
                  heroTag: 'deletar',
                  child: Icon(Icons.delete),
                  onPressed: () async {
                    showDialog(
                        context: context,
                        builder: (alertContext) => AlertDialog(
                              title:
                                  Text('Tem certeza que deseja limpar a base?'),
                              content:
                                  Text('Isso vai destruir todas as tabelas'),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(alertContext);
                                    },
                                    child: Text('Cancelar')),
                                TextButton(
                                    onPressed: () async {
                                      for (var element
                                          in app.estrutura.tabelas) {
                                        try {
                                          await AppDatabase().execDataTable(
                                              'DROP TABLE ${element.nome}');
                                        } catch (error, stackTrace) {
                                          UtilsSentry.reportError(
                                              error, stackTrace);
                                        }
                                      }
                                      Navigator.pop(alertContext);
                                      showSnack(context,
                                          'Tabelas limpas com sucesso, reinicie o app');
                                    },
                                    child: Text('Sim')),
                              ],
                            ));
                  },
                ),
              ),
            FloatingActionButton(
              child: Icon(Icons.close),
              onPressed: () async {
                for (MapEntry map in _controller.versions.entries) {
                  await Sync.zerarVersao(map.key);
                }
                Box box = await hiveService.getBox('sync');
                await box.put('sync_concluida', false);
                showSnack(context, 'Versões limpas com sucesso');
              },
            ),
          ],
        ),
        body: Builder(builder: (context) {
          this.context = context;
          return FutureBuilder(
            future: _controller.carregarVersoes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return FalhaWidget(
                  'Problema ao carregar as versões',
                  error: snapshot.error,
                );
              }
              return ListView.builder(
                itemCount: _controller.versions.entries.length,
                itemBuilder: (_, index) => ListTile(
                    onTap: () async {
                      bool sucesso = await Sync.zerarVersao(
                          _controller.versions.keys.toList()[index]);
                      if (sucesso) {
                        showSnack(context, 'Versão limpa com sucesso');
                        setState(() {});
                      } else {
                        showSnack(context,
                            'Ops, houve uma falha ao limpar a versão da lista');
                      }
                    },
                    title: Text(
                        'Lista: ${_controller.versions.keys.toList()[index]}'),
                    subtitle: Text(
                        'Versão: ${_controller.versions.values.toList()[index]}')),
              );
            },
          );
        }));
  }
}
