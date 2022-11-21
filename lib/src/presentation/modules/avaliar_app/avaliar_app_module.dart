import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:msk/msk.dart';

class AvaliarAppModule extends ModuleWidget {
  @override
  List<Bloc> get blocs => [
        Bloc((i) => AvaliarAppController()),
      ];

  @override
  List<Dependency> get dependencies => [];

  @override
  Widget get view => AvaliarAppPage();

  static Inject get to => Inject<AvaliarAppModule>.of();
}
