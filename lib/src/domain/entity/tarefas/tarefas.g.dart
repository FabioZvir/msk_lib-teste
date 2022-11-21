// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tarefas.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$TarefasDia on _TarefasDiaBase, Store {
  final _$isExpandedAtom = Atom(name: '_TarefasDiaBase.isExpanded');

  @override
  bool get isExpanded {
    _$isExpandedAtom.reportRead();
    return super.isExpanded;
  }

  @override
  set isExpanded(bool value) {
    _$isExpandedAtom.reportWrite(value, super.isExpanded, () {
      super.isExpanded = value;
    });
  }

  @override
  String toString() {
    return '''
isExpanded: ${isExpanded}
    ''';
  }
}

mixin _$TarefaServidor on _TarefaServidorBase, Store {
  final _$statusAtom = Atom(name: '_TarefaServidorBase.status');

  @override
  int? get status {
    _$statusAtom.reportRead();
    return super.status;
  }

  @override
  set status(int? value) {
    _$statusAtom.reportWrite(value, super.status, () {
      super.status = value;
    });
  }

  final _$deletadoAtom = Atom(name: '_TarefaServidorBase.deletado');

  @override
  bool? get deletado {
    _$deletadoAtom.reportRead();
    return super.deletado;
  }

  @override
  set deletado(bool? value) {
    _$deletadoAtom.reportWrite(value, super.deletado, () {
      super.deletado = value;
    });
  }

  final _$teamAtom = Atom(name: '_TarefaServidorBase.team');

  @override
  ObservableList<PeopleTaskServer> get team {
    _$teamAtom.reportRead();
    return super.team;
  }

  @override
  set team(ObservableList<PeopleTaskServer> value) {
    _$teamAtom.reportWrite(value, super.team, () {
      super.team = value;
    });
  }

  final _$showInputObsAtom = Atom(name: '_TarefaServidorBase.showInputObs');

  @override
  bool get showInputObs {
    _$showInputObsAtom.reportRead();
    return super.showInputObs;
  }

  @override
  set showInputObs(bool value) {
    _$showInputObsAtom.reportWrite(value, super.showInputObs, () {
      super.showInputObs = value;
    });
  }

  @override
  String toString() {
    return '''
status: ${status},
deletado: ${deletado},
team: ${team},
showInputObs: ${showInputObs}
    ''';
  }
}

mixin _$ItemTarefaServidor on _ItemTarefaServidorBase, Store {
  final _$concluidoAtom = Atom(name: '_ItemTarefaServidorBase.concluido');

  @override
  bool? get concluido {
    _$concluidoAtom.reportRead();
    return super.concluido;
  }

  @override
  set concluido(bool? value) {
    _$concluidoAtom.reportWrite(value, super.concluido, () {
      super.concluido = value;
    });
  }

  @override
  String toString() {
    return '''
concluido: ${concluido}
    ''';
  }
}
