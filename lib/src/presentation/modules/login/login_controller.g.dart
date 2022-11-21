// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$LoginController on _LoginBase, Store {
  final _$errorMessageAtom = Atom(name: '_LoginBase.errorMessage');

  @override
  String get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  final _$logandoAtom = Atom(name: '_LoginBase.logando');

  @override
  bool get logando {
    _$logandoAtom.reportRead();
    return super.logando;
  }

  @override
  set logando(bool value) {
    _$logandoAtom.reportWrite(value, super.logando, () {
      super.logando = value;
    });
  }

  final _$exibirSenhaAtom = Atom(name: '_LoginBase.exibirSenha');

  @override
  bool get exibirSenha {
    _$exibirSenhaAtom.reportRead();
    return super.exibirSenha;
  }

  @override
  set exibirSenha(bool value) {
    _$exibirSenhaAtom.reportWrite(value, super.exibirSenha, () {
      super.exibirSenha = value;
    });
  }

  final _$logarAsyncAction = AsyncAction('_LoginBase.logar');

  @override
  Future<UserInterface?> logar() {
    return _$logarAsyncAction.run(() => super.logar());
  }

  final _$_LoginBaseActionController = ActionController(name: '_LoginBase');

  @override
  void setLogando(bool value) {
    final _$actionInfo =
        _$_LoginBaseActionController.startAction(name: '_LoginBase.setLogando');
    try {
      return super.setLogando(value);
    } finally {
      _$_LoginBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  bool verificarDados() {
    final _$actionInfo = _$_LoginBaseActionController.startAction(
        name: '_LoginBase.verificarDados');
    try {
      return super.verificarDados();
    } finally {
      _$_LoginBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
errorMessage: ${errorMessage},
logando: ${logando},
exibirSenha: ${exibirSenha}
    ''';
  }
}
