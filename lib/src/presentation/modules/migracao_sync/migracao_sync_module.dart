import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';

import 'migracao_sync_controller.dart';
import 'migracao_sync_page.dart';

class MigracaoSyncModule extends ModuleWidget {
  @override
  List<Bloc> get blocs => [
        Bloc((i) => MigracaoSyncController()),
      ];

  @override
  List<Dependency> get dependencies => [];

  @override
  Widget get view => MigracaoSyncPage();

  static Inject get to => Inject<MigracaoSyncModule>.of();
}
