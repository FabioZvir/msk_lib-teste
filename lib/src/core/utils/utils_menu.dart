import 'package:flutter/material.dart';
import 'package:msk/msk.dart';

class UtilsMenu {
  static Future<bool> openScreenRegister(
      BuildContext context, Menu menu, Widget page) async {
    if (menu.insereDados == true) {
      return (await Navigation.push(context, page)) != null;
    } else {
      showSnack(context, 'Você não tem permissão para acessar esta tela!');
      return false;
    }
  }

  static Future<bool> openScreenUpdate(
      BuildContext context, Menu menu, Widget page, ItemSelect item) async {
    if (menu.alteraDados == true) {
      return (await Navigation.push(context, page,
              args: {'obj': item.object, 'cod_obj': item.id})) !=
          null;
    } else {
      showSnack(context, 'Você não tem permissão para acessar esta tela!');
      return false;
    }
  }
}
