import 'dart:io';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:msk/msk.dart';

class AppBaseModule extends ModuleWidget {
  final App app;

  AppBaseModule(this.app) {
    registrarSingletons(app, HiveService(), registrarAppBaseController: true);
    UtilsSync.executarSyncPerioricamente();
    DataSourceAny.decimalSeparatorInCSV = ',';

    /// Executar comando limpar arquivos no windows
    try {
      if (UtilsPlatform.isWindows) {
        UtilsPlatform.openProcess(
            'ForFiles /p "${Directory.current.path}/Files" /s /d -30 /c "cmd /c del @file"');
      } else if (UtilsPlatform.isAndroid) {
        UtilsFileMSK.deleteTempFilesAndroid();
      }
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
    }
  }

  @override
  List<Bloc> get blocs => [
        Bloc((i) => AppBaseController()),
        Bloc((i) => MenuController()),
      ];

  @override
  List<Dependency> get dependencies => [];

  @override
  Widget get view => AppBaseWidget();

  static Inject get to => Inject<AppBaseModule>.of();
}
