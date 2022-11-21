import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:msk/msk.dart';
part 'select_products_controller.g.dart';

class SelectProductsController = _SelectProductsBase
    with _$SelectProductsController;

abstract class _SelectProductsBase with Store {
  final Future<ItemSelectProduct?> Function()? onAdd;
  final Future<ItemSelectProduct?> Function(ItemSelectProduct)? onEdit;
  final bool executeSync;
  final Future<ItemSelectProduct?> Function(ItemSelectProduct)? selectedProduct;

  late final SelectProductsRepository selectProductsRepository;
  @observable
  ObservableList<ItemSelectProduct> list = ObservableList();
  @observable
  ObservableList<ItemSelectProduct> listSelecionados = ObservableList();
  @computed
  ObservableList<ItemSelectProduct> get listaExibida {
    ObservableList<ItemSelectProduct> subList = ObservableList();
    if (textFilter?.isEmpty == false) {
      /// Precisa guardar em variavel local pq a global é sempre sobreescrita
      String? text = textFilter;
      Future.delayed(Duration(milliseconds: 300), () {
        /// Só executa a pesquisa se o input não tiver mudado
        if (text == ctlFilter.text.trim()) {
          text = textFilter!.toLowerCase();
          for (int i = 0; i < list.length; i++) {
            if (list[i].product!.name.toLowerCase().contains(text!) == true ||
                list[i].product!.classification.toLowerCase().contains(text!) ==
                    true ||
                list[i].product!.structure.toLowerCase().contains(text!) ==
                    true ||
                list[i].product!.ncm.toString().toLowerCase().contains(text!) ==
                    true) {
              subList.add(list[i]);
            }
          }
        }

        return subList;
      });
    } else {
      subList.addAll(list);
    }

    return subList;
  }

  @observable
  String? textFilter;

  final TextEditingController ctlFilter = new TextEditingController();

  @observable
  Icon searchIcon = new Icon(Icons.search);
  @observable
  Widget? appBarTitle;

  /// Indica a label que deve ser usada
  final String? name;

  /// Indica o indicativo que precede a label
  /// Ex A quantidade
  final String? ao;

  /// 1 multipla, 2 simples
  final int typeSelection;

  /// Indica se um campo para o valor estimado deve ser exibido
  final bool showEstimatedValue;

  /// Indica se os itens selecionados deve estar no topo da lista
  final bool showSelectedOnTop;
  @observable
  Future? future;
  @observable
  bool loading = false;
  final bool requiredEstimatedValue;
  final bool automaticUnSelectChangeProduct;

  _SelectProductsBase(List<ItemSelectProduct> itens,
      {this.name,
      this.ao,
      this.typeSelection = 1,
      this.showEstimatedValue = false,
      this.showSelectedOnTop = false,
      this.onEdit,
      this.onAdd,
      SelectProductsRepository? selectProductsRepository,
      this.executeSync = true,
      this.requiredEstimatedValue = false,
      this.selectedProduct,
      this.automaticUnSelectChangeProduct = false}) {
    assert(!requiredEstimatedValue || showEstimatedValue);
    listSelecionados.addAll(itens);
    appBarTitle = Text('Selecione os produtos');
    this.selectProductsRepository = selectProductsRepository ?? GetIt.I.get();
  }

  Future<void> getProdutos({bool precisaDistinct = true}) async {
    list.clear();
    List<Product> produtos = [];

    //if (query == null) {
    //  produtos = await Produto().select().orderBy('nome').toList();
    //} else {
    // List<Map<String, dynamic>> produtosMap =
    //     await AppDatabase().execDataTable(query!);

    // for (Map<String, dynamic> map in produtosMap) {
    //   Product produto = Product.fromMap(map);
    //   if (precisaDistinct &&
    //       !produtos.any((element) => element.id == produto.id)) {
    //     produtos.add(produto);
    //   } else {
    //     produtos.add(produto);
    //   }
    // }
    // }
    produtos = await selectProductsRepository.getAllProducts();
    if (showSelectedOnTop) {
      var tempList = [];

      /// Usa uma sublist para os produtos selecionados para manter a ordem da lista idêntica ao que vem da outra tela
      /// Pois usar insert(0, element) diretamente na tempList causa uma inversão da ordem da lista de elementos selecionados
      var subList = [];

      produtos.forEach((element) {
        if (listSelecionados
            .where((element) => element.isDeleted != true)
            .any((item) => element.id == item.product!.id)) {
          subList.add(element);
        } else {
          tempList.add(element);
        }
      });
      tempList.insertAll(0, subList);
      for (var produto in tempList) {
        await addItemProduto(produto);
      }
    } else {
      for (var produto in produtos) {
        await addItemProduto(produto);
      }
    }
    loading = false;
  }

  @action
  void removerItem(int pos) {
    ItemSelectProduct item = listaExibida[pos];
    listSelecionados
        .where((p) => p.product!.id == item.product!.id)
        .forEach((p) => p.isDeleted = true);
    listaExibida[pos].isSelected = false;
  }

  Future<void> itemSelecionado(int pos) async {
    Future<ItemSelectProduct?> _getFinalProduct(ItemSelectProduct item) async {
      if (selectedProduct != null) {
        return await selectedProduct!(item);
      }
      return item;
    }

    ItemSelectProduct item = listaExibida[pos].copy();
    int i =
        listSelecionados.indexWhere((p) => p.product!.id == item.product!.id);
    if (i > -1) {
      //caso ja exista

      item.product = listSelecionados[i].product;
      item.unitMeasure = listSelecionados[i].unitMeasure;
      item.unitMeasureProduct = listSelecionados[i].unitMeasureProduct;
      item.object = listSelecionados[i].object;
      ItemSelectProduct? newItem = await _getFinalProduct(item);
      if (newItem != null) {
        newItem.isDeleted = false;
        listSelecionados[i] = newItem;
        listaExibida[pos].isSelected = true;
      }
    } else {
      ItemSelectProduct? newItem = await _getFinalProduct(item);
      if (newItem != null) {
        listSelecionados.add(newItem);
        listaExibida[pos].isSelected = true;
      }
    }
  }

  @action
  ItemSelectProduct addItemProduto(Product? produto, {int index = -1}) {
    ItemSelectProduct item = ItemSelectProduct();
    try {
      ItemSelectProduct? s = listSelecionados
          .firstWhereOrNull((p) => p.product!.id == produto!.id);

      item.product = produto;
      item.quantity = s?.quantity ?? 1;
      item.isSelected = (s != null && !s.isDeleted);
      item.unitMeasure = s?.unitMeasure;
      item.ctlEstimatedValue.text = s?.ctlEstimatedValue.text ?? '';
      item.object = s?.object;
      if (index == -1) {
        list.add(item);
      } else {
        list[index] = item;
      }
    } catch (error, stackTrace) {
      UtilsSentry.reportError(
        error,
        stackTrace,
      );
    }
    return item;
  }

  /// Em caso de seleção simples, remove os itens pré selecionados
  verificarRemocaoItensSelecionados(int index) {
    ItemSelectProduct item = listaExibida[index];
    if (typeSelection == 2) {
      listSelecionados
          .removeWhere((element) => element.product!.id != item.product!.id);

      int index0 = list.indexWhere((element) {
        return element.isSelected && element.product!.id != item.product!.id;
      });
      if (index0 > -1) {
        list[index0].isSelected = false;
      }
    }
  }
}
