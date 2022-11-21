import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';

import 'limpar_versao_sync_controller.dart';
import 'limpar_versao_sync_page.dart';

class LimparVersaoSyncModule extends ModuleWidget {
  @override
  List<Bloc> get blocs => [
        Bloc((i) => LimparVersaoSyncController()),
      ];

  @override
  List<Dependency> get dependencies => [];

  @override
  Widget get view => LimparVersaoSyncPage();

  static Inject get to => Inject<LimparVersaoSyncModule>.of();
}
