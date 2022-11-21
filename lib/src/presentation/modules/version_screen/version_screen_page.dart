import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:msk/msk.dart';

class VersionScreenPage extends StatefulWidget {
  final String title;

  const VersionScreenPage({Key? key, this.title = "Sobre"}) : super(key: key);

  @override
  _VersionScreenPageState createState() => _VersionScreenPageState();
}

class _VersionScreenPageState extends State<VersionScreenPage> {
  final VersionScreenController controller =
      VersionScreenModule.to.bloc<VersionScreenController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
              onPressed: () async {
                if (UtilsPlatform.isDebug) {
                  Navigator.maybeOf(context)?.push(new MaterialPageRoute(
                      builder: (BuildContext context) => new ConsultaModule()));
                } else {
                  bool? autorizado = await _showDialogPasswordDev(context);

                  /// Ele pode retornar null tmb caso o usuário feche a janela
                  if (autorizado == true) {
                    Navigator.maybeOf(context)?.push(new MaterialPageRoute(
                        builder: (BuildContext context) =>
                            new ConsultaModule()));
                  } else if (autorizado == false) {
                    showSnack(context, 'Acesso negado');
                    Navigator.pop(context);
                  }
                }
              },
              icon: Icon(Icons.developer_mode))
        ],
      ),
      body: FutureBuilder(
          future: controller.verificarVersao(),
          builder: (context, snap) => Center(
                  child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Observer(
                          builder: (_) => AnimatedOpacity(
                              duration: Duration(microseconds: 500),
                              opacity: controller.opacity,
                              child: Column(children: <Widget>[
                                Text(app.nome, style: TextStyle(fontSize: 20)),
                                const SizedBox(height: 40),
                                Image.asset('imagens/icon_msk_inicio.png',
                                    width: 200, height: 200, package: 'msk'),
                                Padding(
                                    padding: const EdgeInsets.all(25.0),
                                    child: Text('Aynova',
                                        style: TextStyle(fontSize: 22)))
                              ]))),
                      Observer(builder: (_) => _statusAtualizacao())
                    ]),
              ))),
    );
  }

  Widget _statusAtualizacao() {
    if (controller.statusVersion == StatusVersion.loadingUpdate) {
      return Column(children: <Widget>[
        CircularProgressIndicator(),
        Padding(
            padding: const EdgeInsets.all(25.0),
            child: Text('Procurando atualizações'))
      ]);
    } else if (controller.statusVersion == StatusVersion.updated) {
      return Column(children: [
        Text('Nenhuma atualização disponível', style: TextStyle(fontSize: 16)),
        Text("Versão atual: ${controller.oldVersion}"),
      ]);
    } else {
      return Column(
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(children: <Widget>[
                Text(
                    controller.statusVersion == StatusVersion.avaibleUpdate
                        ? 'Há uma atualização disponível'
                        : 'Há uma atualização obrigatória',
                    style: TextStyle(fontSize: 16)),
                Text("Versão atual: ${controller.oldVersion}"),
                Text("Versão disponível: ${controller.newVersion}")
              ])),
          (controller.statusVersion == StatusVersion.avaibleUpdate ||
                      controller.statusVersion ==
                          StatusVersion.requiredUpdate) &&
                  !UtilsPlatform.isMacos &&
                  (!UtilsPlatform.isIOS || app.appId.isNullOrEmpty) &&
                  (!UtilsPlatform.isWindows ||
                      !controller.item!.windowsUrl.isNullOrBlank)
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextButton(
                              child: Text('Atualizar Depois'),
                              onPressed: () {
                                Navigator.pop(context);
                              })),
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Button('Atualizar Agora', () async {
                            if (UtilsPlatform.isWindows) {
                              controller.launchCmd(context);
                            } else {
                              controller.launchURL(context);
                            }
                          }))
                    ])
              : SizedBox()
        ],
      );
    }
  }

  Future<bool?> _showDialogPasswordDev(BuildContext context) async {
    final TextEditingController ctlPassword = TextEditingController();
    return showDialog(
        context: context,
        builder: (alertContext) => AlertDialog(
              title: Text('Acesso Restrito'),
              content: InputTextField(
                  controller: ctlPassword,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Senha')),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(alertContext);
                    },
                    child: Text('Cancelar')),
                TextButton(
                    onPressed: () {
                      if (generateMd5(ctlPassword.text.trim()) ==
                          '4a49722c3a0cbcfa14f262c8078e59bd') {
                        Navigator.pop(alertContext, true);
                      } else {
                        Navigator.pop(context, false);
                      }
                    },
                    child: Text('Entrar'))
              ],
            ));
  }
}
