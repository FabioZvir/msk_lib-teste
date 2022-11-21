// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'select_products_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SelectProductsController on _SelectProductsBase, Store {
  Computed<ObservableList<ItemSelectProduct>>? _$listaExibidaComputed;

  @override
  ObservableList<ItemSelectProduct> get listaExibida =>
      (_$listaExibidaComputed ??= Computed<ObservableList<ItemSelectProduct>>(
              () => super.listaExibida,
              name: '_SelectProductsBase.listaExibida'))
          .value;

  final _$listAtom = Atom(name: '_SelectProductsBase.list');

  @override
  ObservableList<ItemSelectProduct> get list {
    _$listAtom.reportRead();
    return super.list;
  }

  @override
  set list(ObservableList<ItemSelectProduct> value) {
    _$listAtom.reportWrite(value, super.list, () {
      super.list = value;
    });
  }

  final _$listSelecionadosAtom =
      Atom(name: '_SelectProductsBase.listSelecionados');

  @override
  ObservableList<ItemSelectProduct> get listSelecionados {
    _$listSelecionadosAtom.reportRead();
    return super.listSelecionados;
  }

  @override
  set listSelecionados(ObservableList<ItemSelectProduct> value) {
    _$listSelecionadosAtom.reportWrite(value, super.listSelecionados, () {
      super.listSelecionados = value;
    });
  }

  final _$textFilterAtom = Atom(name: '_SelectProductsBase.textFilter');

  @override
  String? get textFilter {
    _$textFilterAtom.reportRead();
    return super.textFilter;
  }

  @override
  set textFilter(String? value) {
    _$textFilterAtom.reportWrite(value, super.textFilter, () {
      super.textFilter = value;
    });
  }

  final _$searchIconAtom = Atom(name: '_SelectProductsBase.searchIcon');

  @override
  Icon get searchIcon {
    _$searchIconAtom.reportRead();
    return super.searchIcon;
  }

  @override
  set searchIcon(Icon value) {
    _$searchIconAtom.reportWrite(value, super.searchIcon, () {
      super.searchIcon = value;
    });
  }

  final _$appBarTitleAtom = Atom(name: '_SelectProductsBase.appBarTitle');

  @override
  Widget? get appBarTitle {
    _$appBarTitleAtom.reportRead();
    return super.appBarTitle;
  }

  @override
  set appBarTitle(Widget? value) {
    _$appBarTitleAtom.reportWrite(value, super.appBarTitle, () {
      super.appBarTitle = value;
    });
  }

  final _$futureAtom = Atom(name: '_SelectProductsBase.future');

  @override
  Future<dynamic>? get future {
    _$futureAtom.reportRead();
    return super.future;
  }

  @override
  set future(Future<dynamic>? value) {
    _$futureAtom.reportWrite(value, super.future, () {
      super.future = value;
    });
  }

  final _$loadingAtom = Atom(name: '_SelectProductsBase.loading');

  @override
  bool get loading {
    _$loadingAtom.reportRead();
    return super.loading;
  }

  @override
  set loading(bool value) {
    _$loadingAtom.reportWrite(value, super.loading, () {
      super.loading = value;
    });
  }

  final _$_SelectProductsBaseActionController =
      ActionController(name: '_SelectProductsBase');

  @override
  void removerItem(int pos) {
    final _$actionInfo = _$_SelectProductsBaseActionController.startAction(
        name: '_SelectProductsBase.removerItem');
    try {
      return super.removerItem(pos);
    } finally {
      _$_SelectProductsBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  ItemSelectProduct addItemProduto(Product? produto, {int index = -1}) {
    final _$actionInfo = _$_SelectProductsBaseActionController.startAction(
        name: '_SelectProductsBase.addItemProduto');
    try {
      return super.addItemProduto(produto, index: index);
    } finally {
      _$_SelectProductsBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
list: ${list},
listSelecionados: ${listSelecionados},
textFilter: ${textFilter},
searchIcon: ${searchIcon},
appBarTitle: ${appBarTitle},
future: ${future},
loading: ${loading},
listaExibida: ${listaExibida}
    ''';
  }
}
