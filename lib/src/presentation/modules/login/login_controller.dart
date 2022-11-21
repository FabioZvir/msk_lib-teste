import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:msk/msk.dart';

part 'login_controller.g.dart';

class LoginController = _LoginBase with _$LoginController;

abstract class _LoginBase with Store {
  //final AuthService authService = AuthService();
  final TextEditingController controllerUser = TextEditingController();
  final TextEditingController controllerPassword = TextEditingController();
  @observable
  String errorMessage = "";
  @observable
  bool logando = false;
  @observable
  bool exibirSenha = false;

  @action
  Future<UserInterface?> logar() async {
    try {
      setLogando(true);
      UserInterface? userToken = await authService.loginUserPassword(
          controllerUser.text, controllerPassword.text);
      if (userToken != null) {
        setLogando(false);
        return userToken;
      }
    } catch (error, stackTrace) {
      setLogando(false);
      UtilsSentry.reportError(
        error,
        stackTrace,
      );
      return null;
    }
    setLogando(false);
    return null;
  }

  @action
  void setLogando(bool value) {
    logando = value;
  }

  @action
  bool verificarDados() {
    if (controllerUser.text.isEmpty) {
      errorMessage = 'Você precisa informar seu login';
      return false;
    } else if (controllerPassword.text.isEmpty) {
      errorMessage = 'Você precisa informar sua senha';
      return false;
    } else
      return true;
  }
}
