// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version_screen_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$VersionScreenController on _VersionScreenBase, Store {
  final _$opacityAtom = Atom(name: '_VersionScreenBase.opacity');

  @override
  double get opacity {
    _$opacityAtom.reportRead();
    return super.opacity;
  }

  @override
  set opacity(double value) {
    _$opacityAtom.reportWrite(value, super.opacity, () {
      super.opacity = value;
    });
  }

  final _$statusVersionAtom = Atom(name: '_VersionScreenBase.statusVersion');

  @override
  StatusVersion get statusVersion {
    _$statusVersionAtom.reportRead();
    return super.statusVersion;
  }

  @override
  set statusVersion(StatusVersion value) {
    _$statusVersionAtom.reportWrite(value, super.statusVersion, () {
      super.statusVersion = value;
    });
  }

  final _$verificarVersaoAsyncAction =
      AsyncAction('_VersionScreenBase.verificarVersao');

  @override
  Future<void> verificarVersao() {
    return _$verificarVersaoAsyncAction.run(() => super.verificarVersao());
  }

  @override
  String toString() {
    return '''
opacity: ${opacity},
statusVersion: ${statusVersion}
    ''';
  }
}
