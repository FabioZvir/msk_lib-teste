import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:msk/msk.dart';

class SplashPage extends StatefulWidget {
  final String title;

  const SplashPage({Key? key, this.title = "Splash"}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with AfterLayoutMixin<SplashPage> {
  final VersionScreenController controller =
      LoginModule.to.bloc<VersionScreenController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: controller.verificarVersao(),
        builder: (context, snap) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Observer(
                builder: (_) => AnimatedOpacity(
                  duration: Duration(microseconds: 500),
                  opacity: controller.opacity,
                  onEnd: () async {},
                  child: Column(
                    children: <Widget>[
                      Image.asset(
                        'imagens/icon_msk_inicio.png',
                        width: 200,
                        height: 200,
                        package: 'msk',
                      ),
                      Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Text('Aynova',
                            style: TextStyle(
                              fontSize: 22,
                            )),
                      )
                    ],
                  ),
                ),
              ),
              Observer(builder: (_) {
                if (controller.statusVersion == StatusVersion.loadingUpdate) {
                  return Column(
                    children: <Widget>[
                      CircularProgressIndicator(),
                      Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Text('Procurando atualizações'),
                      ),
                    ],
                  );
                } else if (controller.statusVersion == StatusVersion.updated) {
                  controller.navegar(context);
                  return SizedBox();
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Há uma atualização disponível',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text("Versão atual: ${controller.oldVersion}"),
                        Text("Versão disponível: ${controller.newVersion}"),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextButton(
                                    child: Text('Atualizar Depois'),
                                    onPressed: () {
                                      controller.navegar(context);
                                    }),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Button('Atualizar Agora', () {
                                  if (UtilsPlatform.isWindows) {
                                    controller.launchCmd(context);
                                  } else {
                                    controller.launchURL(context);
                                  }
                                }),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              })
            ],
          ),
        ),
      ),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {}
}
