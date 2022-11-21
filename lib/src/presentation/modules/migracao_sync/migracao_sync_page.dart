import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:msk/msk.dart';

class MigracaoSyncPage extends StatefulWidget {
  final String title;
  const MigracaoSyncPage({Key? key, this.title = "MigracaoSync"})
      : super(key: key);

  @override
  _MigracaoSyncPageState createState() => _MigracaoSyncPageState();
}

class _MigracaoSyncPageState extends State<MigracaoSyncPage> {
  final MigracaoSyncController _controller =
      MigracaoSyncModule.to.bloc<MigracaoSyncController>();

  @override
  void initState() {
    super.initState();
    _controller.atualizarDados().then((value) => _fimMigracao(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 50,
            ),
            Observer(
              builder: (_) => Text(
                _controller.label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                'imagens/update.png',
                height: 100,
                package: 'msk',
              ),
            ),
            SizedBox(height: 16),
            Text('Isso pode levar alguns segundos'),
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Observer(
                builder: (_) => LinearProgressIndicator(
                  value: _controller.progressoMigracao,
                  valueColor: AlwaysStoppedAnimation<Color>(defaultAppColor),
                ),
              ),
            ),
            Observer(
                builder: (_) => _controller.falha
                    ? Padding(
                        padding: const EdgeInsets.only(top: 35),
                        child: Button('Iniciar', () {
                          _controller
                              .atualizarDados()
                              .then((value) => _fimMigracao(value));
                        }),
                      )
                    : SizedBox()),
            SizedBox(height: 16),
            Observer(
              builder: (_) => Text(_controller.table),
            )
          ],
        ),
      ),
    );
  }

  _fimMigracao(bool sucesso) async {
    if (sucesso) {
      try {
        if (!UtilsPlatform.isWeb) {
          _controller.progressoMigracao = 0;
          _controller.verificarDadosIncompletos();

          _controller.progressoMigracao = 0;
          _controller.label = 'Enviando dados para o servidor';
          await UtilsSync.enviarDados(onProgress: (double progress) {
            _controller.progressoMigracao = progress / 100;
          });
          _controller.progressoMigracao = 0;
          _controller.label = 'Sincronizando dados com nossos servidores';
          _controller.table = 'Recuperando dados do servidor';
          await GetIt.I.get<AtualizarDados>().sincronizar(
              funProgress: (double progress, String tabela) {
            _controller.progressoMigracao = progress / 100;
            _controller.table = tabela;
          });
        }
        GetIt.I.get<App>().loginFinalizado(context);
      } catch (error, stackTrace) {
        UtilsSentry.reportError(error, stackTrace);
        GetIt.I.get<App>().loginFinalizado(context);
      }
    } else {
      _controller.falha = true;
    }
  }
}
