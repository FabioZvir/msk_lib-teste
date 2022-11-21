import 'dart:async';

import 'package:diacritic/diacritic.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mobx/mobx.dart';
import 'package:msk/msk.dart';

part 'menu_controller.g.dart';

class MenuController = _MenuBase with _$MenuController;

abstract class _MenuBase with Store {
  @observable
  Box? menuBox;
  @observable
  ObservableSet<Menu> menus = ObservableSet();
  @computed
  ObservableSet<Menu> get menusExibidos {
    List<Menu> _menus;

    /// Caso a empresa não seja nula, filtra os menus de acordo com a empresa
    if (companyId != null) {
      _menus = menus
          .where((element) =>
              element.empresas.contains(companyId) ||
              isShowAlways(element.codSistema!, menusItem))
          .toList();
    } else {
      _menus = menus.toList();
    }
    if (text.isEmpty) {
      return ObservableSet.of(_menus);
    }
    ObservableSet<Menu> subList = ObservableSet();
    String t = removeDiacritics(text);
    for (Menu menu in _menus) {
      if (removeDiacritics(menu.nome!.toLowerCase()).contains(t)) {
        subList.add(menu);
      }
    }
    return subList;
  }

  @observable
  String text = '';
  List<MenuItemMsk> menusItem = [];

  /// Indica se os menus já foram carregados do servidor ou não
  bool menusCarregados = false;
  final TextEditingController ctlSearch = TextEditingController();
  @observable
  int? companyId;

  @action
  loadMenus() async {
    await _init();
    for (var menu in menuBox!.values) {
      menus.add(menu);
    }
    await getMenus();
  }

  _init() async {
    menuBox = await hiveService.getBox(Constants.MENU_BOX_NAME);
    return menuBox;
  }

  @action
  Future<void> getMenus() async {
    if (!menusCarregados) {
      try {
        Response? response =
            await API.post(app.endPoints.menu, data: {'codMod': 10});
        if (response.sucesso()) {
          await menuBox!.clear();
          for (Map map in response!.data) {
            Menu menu = Menu.fromMap(map as Map<String, dynamic>)!;
            menuBox!.put(menu.codSistema, menu);
          }
          menus.clear();
          for (var menu in menuBox!.values) {
            menus.add(menu);
          }
          menusCarregados = true;
        }
      } catch (error, stackTrace) {
        UtilsSentry.reportError(
          error,
          stackTrace,
        );
      }
    }
  }

  Future<bool> favoritarMenu(Menu menu) async {
    try {
      menu.favorito = !(menu.favorito ?? false);
      if (menu.box != null) {
        await menu.save();
      }
      return true;
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
    }
    return false;
  }

  Future<bool> favoritarMenuServidor(Menu menu) async {
    try {
      Response? response = await API.post(app.endPoints.favoritarMenu,
          data: {'id': menu.codSistema, 'favorito': (menu.favorito ?? false)});
      return response.sucesso();
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
    }
    return false;
  }

  bool isShowAlways(int menuId, List<MenuItemMsk> menus) {
    for (MenuItemMsk menu in menus) {
      if (menu.exibirSempre && menu.codSistema == menuId) {
        return true;
      }
      bool containsInChild = isShowAlways(menuId, menu.subMenus);
      if (containsInChild) {
        return true;
      }
    }
    return false;
  }
}
