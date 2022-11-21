import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:msk/msk.dart';

class LoginModule extends ModuleWidget {
  @override
  List<Bloc> get blocs => [
        Bloc((i) => LoginController()),
        Bloc((i) => VersionScreenController()),
      ];

  @override
  List<Dependency> get dependencies => [];

  @override
  Widget get view => SplashPage();

  static Inject get to => Inject<LoginModule>.of();
}
