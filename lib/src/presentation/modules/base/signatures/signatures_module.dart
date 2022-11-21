import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';

import 'signatures_controller.dart';
import 'signatures_page.dart';

class SignaturesModule extends ModuleWidget {
  @override
  List<Bloc> get blocs => [
        Bloc((i) => SignaturesController()),
      ];

  @override
  List<Dependency> get dependencies => [];

  @override
  Widget get view => SignaturesPage();

  static Inject get to => Inject<SignaturesModule>.of();
}
