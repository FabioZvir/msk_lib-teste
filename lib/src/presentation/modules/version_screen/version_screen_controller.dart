import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:msk/msk.dart';

part 'version_screen_controller.g.dart';

class VersionScreenController = _VersionScreenBase
    with _$VersionScreenController;

abstract class _VersionScreenBase with Store {
  /// Este double definirá a opacidade da imagem central.
  @observable
  double opacity = 0;

  /// Este enum determinará, para o gerenciamento de estado, se o status da atualização está em carregamento(loadingUpdate);
  ///atualizado(updated); com disponibilidade de atualização(avaibleUpdate); ou, requer uma atualização obrigatória(requiredUpdate).
  @observable
  StatusVersion statusVersion = StatusVersion.loadingUpdate;
  int newVersion = 0;
  int oldVersion = 0;
  ItemAtualizacao? item;

  /// Evita que a nova página seja chamada mais de uma vez
  bool navegarChamado = false;

  _VersionScreenBase() {
    Future.delayed(Duration(milliseconds: 1), () {
      opacity = 1;
    });
  }

  /// Verifica a versão do App, atribuindo às variáveis [oldVersion] e [newVersion] suas respectivas versões, bem como muda o estado da tela.
  @action
  Future<void> verificarVersao() async {
    try {
      if ((UtilsPlatform.isMobile || UtilsPlatform.isWindows) &&
          await API.isConnected()) {
        var versao = await UtilsVersionMSK.getDataVersion();
        oldVersion = versao['numVersao'];
        Response res = await Dio().post(
            Constants.BASE_URL + getPorta() + app.endPoints.controleVersao,
            data: versao);
        if (res.sucesso() && res.data != "") {
          item = ItemAtualizacao.fromJson(res.data);
          newVersion = item!.numVersao;
          if (oldVersion < newVersion &&
              (!UtilsPlatform.isWindows || !item!.windowsUrl.isNullOrBlank)) {
            if (item!.obrigatorio) {
              statusVersion = StatusVersion.requiredUpdate;
            } else {
              statusVersion = StatusVersion.avaibleUpdate;
            }
          } else {
            statusVersion = StatusVersion.updated;
          }
        } else {
          statusVersion = StatusVersion.updated;
        }
      } else {
        statusVersion = StatusVersion.updated;
      }
    } catch (error, stackTrace) {
      statusVersion = StatusVersion.updated;
      UtilsSentry.reportError(error, stackTrace);
    }
  }

  void navegar(BuildContext context) async {
    if (!navegarChamado) {
      navegarChamado = true;
      if (statusVersion != StatusVersion.requiredUpdate) {
        authService.getUser().then((usuario) async {
          if (usuario == null) {
            Navigator.maybeOf(context)?.pushReplacement(new MaterialPageRoute(
                builder: (BuildContext context) => new LoginPage(height: 550,
                width: 500,
                sizeImage: 90,
                widthButton: 180,
                heightButton: 45,
                fontSize: 26,
                padding: 20,
                title: 'Gestão Florestal',
                image: 'images/gestao_icon.png',)));
          } else {
            if ((UtilsMigration.appMigrado(GetIt.I.get<App>().package))) {
              Navigator.maybeOf(context)?.pushReplacement(new MaterialPageRoute(
                  builder: (BuildContext context) => new MigracaoSyncModule()));
            } else {
              /// Só inicializa se o app não for migrado, a MigracaoModule ja faz isso
              await UtilsData.inicializarBD();
              GetIt.I.get<App>().loginFinalizado(context);
              try {
                UtilsSync.atualizarDados();
              } catch (error, stackTrace) {
                UtilsSentry.reportError(error, stackTrace);
              }
            }
          }
        }).catchError((error, stackTrace) {
          UtilsSentry.reportError(error, stackTrace);
          Navigator.maybeOf(context)?.pushReplacement(new MaterialPageRoute(
              builder: (BuildContext context) => new LoginPage(height: 550,
                width: 500,
                sizeImage: 90,
                widthButton: 180,
                heightButton: 45,
                fontSize: 26,
                padding: 20,
                title: 'Gestão Florestal',
                image: 'images/gestao_icon.png',)));
        });
      }
    }
  }

  Future<void> launchURL(BuildContext context) async {
    final String url = UtilsPlatform.isAndroid
        ? 'https://play.google.com/store/apps/details?id=${app.package}'
        : 'market://details?id=${app.appId}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showSnack(
          context, 'Ops, não foi possível abrir a loja de aplicativos...');
    }
  }

  Future<void> launchCmd(BuildContext context) async {
    if (item!.windowsUrl.isNullOrBlank) {
      showSnack(context, 'URL retornado inválido');
      return;
    }
    MyPR progress1 =
        await showProgressDialog(context, "Baixando arquivos necessários...");
    final String appNameExe = app.nameExe;
    final String? literalPath = await UtilsFileMSK.downloadFileWithPath(
        item!.windowsUrl!,
        fileName: "${appNameExe}.zip");
    progress1.hide();

    if (literalPath != null) {
      MyPR progress2 = await showProgressDialog(
          context, "Atualizando, por favor aguarde o processo...");
      String command =
          "tskill $pid && powershell.exe -NoP -NonI -Command Expand-Archive -LiteralPath '${literalPath.replaceAll('/', r'\')}' -DestinationPath '${Directory.current.path}' -Force && powershell.exe -NoP -NonI -Command start '${Directory.current.path}\\${appNameExe}.exe' ";
      ProcessResult? result = await UtilsPlatform.openProcess(command);
      progress2.hide();

      if (result!.exitCode != 0) {
        showSnack(context, 'Ops, não foi possível atualizar o aplicativo...');
      }
    }
  }
}

/// Determina valores enumerados [loadingUpdate],[updated], [avaibleUpdate] e [requiredUpdate]
/// Para serem utilizados como gerenciadores de estado na conferência da disponibilidade de atualização do App.
enum StatusVersion { loadingUpdate, updated, avaibleUpdate, requiredUpdate }
