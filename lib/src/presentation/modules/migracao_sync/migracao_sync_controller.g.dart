// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'migracao_sync_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$MigracaoSyncController on _MigracaoSyncControllerBase, Store {
  final _$progressoMigracaoAtom =
      Atom(name: '_MigracaoSyncControllerBase.progressoMigracao');

  @override
  double get progressoMigracao {
    _$progressoMigracaoAtom.reportRead();
    return super.progressoMigracao;
  }

  @override
  set progressoMigracao(double value) {
    _$progressoMigracaoAtom.reportWrite(value, super.progressoMigracao, () {
      super.progressoMigracao = value;
    });
  }

  final _$falhaAtom = Atom(name: '_MigracaoSyncControllerBase.falha');

  @override
  bool get falha {
    _$falhaAtom.reportRead();
    return super.falha;
  }

  @override
  set falha(bool value) {
    _$falhaAtom.reportWrite(value, super.falha, () {
      super.falha = value;
    });
  }

  final _$labelAtom = Atom(name: '_MigracaoSyncControllerBase.label');

  @override
  String get label {
    _$labelAtom.reportRead();
    return super.label;
  }

  @override
  set label(String value) {
    _$labelAtom.reportWrite(value, super.label, () {
      super.label = value;
    });
  }

  final _$tableAtom = Atom(name: '_MigracaoSyncControllerBase.table');

  @override
  String get table {
    _$tableAtom.reportRead();
    return super.table;
  }

  @override
  set table(String value) {
    _$tableAtom.reportWrite(value, super.table, () {
      super.table = value;
    });
  }

  @override
  String toString() {
    return '''
progressoMigracao: ${progressoMigracao},
falha: ${falha},
label: ${label},
table: ${table}
    ''';
  }
}
