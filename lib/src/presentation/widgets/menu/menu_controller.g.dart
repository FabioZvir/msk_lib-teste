// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$MenuController on _MenuBase, Store {
  Computed<ObservableSet<Menu>>? _$menusExibidosComputed;

  @override
  ObservableSet<Menu> get menusExibidos => (_$menusExibidosComputed ??=
          Computed<ObservableSet<Menu>>(() => super.menusExibidos,
              name: '_MenuBase.menusExibidos'))
      .value;

  final _$menuBoxAtom = Atom(name: '_MenuBase.menuBox');

  @override
  Box<dynamic>? get menuBox {
    _$menuBoxAtom.reportRead();
    return super.menuBox;
  }

  @override
  set menuBox(Box<dynamic>? value) {
    _$menuBoxAtom.reportWrite(value, super.menuBox, () {
      super.menuBox = value;
    });
  }

  final _$menusAtom = Atom(name: '_MenuBase.menus');

  @override
  ObservableSet<Menu> get menus {
    _$menusAtom.reportRead();
    return super.menus;
  }

  @override
  set menus(ObservableSet<Menu> value) {
    _$menusAtom.reportWrite(value, super.menus, () {
      super.menus = value;
    });
  }

  final _$textAtom = Atom(name: '_MenuBase.text');

  @override
  String get text {
    _$textAtom.reportRead();
    return super.text;
  }

  @override
  set text(String value) {
    _$textAtom.reportWrite(value, super.text, () {
      super.text = value;
    });
  }

  final _$companyIdAtom = Atom(name: '_MenuBase.companyId');

  @override
  int? get companyId {
    _$companyIdAtom.reportRead();
    return super.companyId;
  }

  @override
  set companyId(int? value) {
    _$companyIdAtom.reportWrite(value, super.companyId, () {
      super.companyId = value;
    });
  }

  final _$loadMenusAsyncAction = AsyncAction('_MenuBase.loadMenus');

  @override
  Future loadMenus() {
    return _$loadMenusAsyncAction.run(() => super.loadMenus());
  }

  final _$getMenusAsyncAction = AsyncAction('_MenuBase.getMenus');

  @override
  Future<void> getMenus() {
    return _$getMenusAsyncAction.run(() => super.getMenus());
  }

  @override
  String toString() {
    return '''
menuBox: ${menuBox},
menus: ${menus},
text: ${text},
companyId: ${companyId},
menusExibidos: ${menusExibidos}
    ''';
  }
}
