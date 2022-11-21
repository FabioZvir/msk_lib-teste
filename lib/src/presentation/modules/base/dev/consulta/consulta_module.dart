import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';

import 'consulta_controller.dart';
import 'consulta_page.dart';

class ConsultaModule extends ModuleWidget {
  @override
  List<Bloc> get blocs => [
        Bloc((i) => ConsultaController()),
      ];

  @override
  List<Dependency> get dependencies => [];

  @override
  Widget get view => ConsultaPage();

  static Inject get to => Inject<ConsultaModule>.of();
}
