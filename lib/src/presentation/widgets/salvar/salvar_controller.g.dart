// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'salvar_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SalvarController on _SalvarBase, Store {
  final _$statusEdicaoAtom = Atom(name: '_SalvarBase.statusEdicao');

  @override
  int get statusEdicao {
    _$statusEdicaoAtom.reportRead();
    return super.statusEdicao;
  }

  @override
  set statusEdicao(int value) {
    _$statusEdicaoAtom.reportWrite(value, super.statusEdicao, () {
      super.statusEdicao = value;
    });
  }

  final _$permitirCliqueAtom = Atom(name: '_SalvarBase.permitirClique');

  @override
  bool get permitirClique {
    _$permitirCliqueAtom.reportRead();
    return super.permitirClique;
  }

  @override
  set permitirClique(bool value) {
    _$permitirCliqueAtom.reportWrite(value, super.permitirClique, () {
      super.permitirClique = value;
    });
  }

  @override
  String toString() {
    return '''
statusEdicao: ${statusEdicao},
permitirClique: ${permitirClique}
    ''';
  }
}
