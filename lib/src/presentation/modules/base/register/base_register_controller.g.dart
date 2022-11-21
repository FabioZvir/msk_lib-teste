// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_register_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$BaseRegisterController on _BaseRegisterController, Store {
  final _$statusEditionAtom =
      Atom(name: '_BaseRegisterController.statusEdition');

  @override
  int get statusEdition {
    _$statusEditionAtom.reportRead();
    return super.statusEdition;
  }

  @override
  set statusEdition(int value) {
    _$statusEditionAtom.reportWrite(value, super.statusEdition, () {
      super.statusEdition = value;
    });
  }

  final _$typeRegisterAtom = Atom(name: '_BaseRegisterController.typeRegister');

  @override
  int get typeRegister {
    _$typeRegisterAtom.reportRead();
    return super.typeRegister;
  }

  @override
  set typeRegister(int value) {
    _$typeRegisterAtom.reportWrite(value, super.typeRegister, () {
      super.typeRegister = value;
    });
  }

  @override
  String toString() {
    return '''
statusEdition: ${statusEdition},
typeRegister: ${typeRegister}
    ''';
  }
}
