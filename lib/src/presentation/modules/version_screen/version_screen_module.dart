import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:msk/msk.dart';

class VersionScreenModule extends ModuleWidget {
  @override
  List<Bloc> get blocs => [
        Bloc((i) => VersionScreenController()),
      ];

  @override
  List<Dependency> get dependencies => [];

  @override
  Widget get view => VersionScreenPage();

  static Inject get to => Inject<VersionScreenModule>.of();
}
