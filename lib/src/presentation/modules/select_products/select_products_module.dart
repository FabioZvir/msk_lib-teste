import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:msk/msk.dart';

class SelectProductsModule extends ModuleWidget {
  final List<ItemSelectProduct> items;

  /// Indica a label que deve ser usada
  final String name;

  /// Indica o indicativo que precede a label
  /// Ex A quantidade
  final String ao;

  /// 1 multipla, 2 simples
  final int typeSelection;

  /// Indica se um campo para o valor estimado deve ser exibido
  final bool showEstimatedValue;

  /// Indica se os itens selecionados deve estar no topo da lista
  final bool showSelectedOnTop;

  final Future<ItemSelectProduct?> Function()? onAdd;
  final Future<ItemSelectProduct?> Function(ItemSelectProduct)? onEdit;
  final SelectProductsRepository? selectProductsRepository;
  final bool executeSync;
  final bool requiredEstimatedValue;
  final Future<ItemSelectProduct?> Function(ItemSelectProduct)? selectedProduct;
  // Caso seja true, deseleciona automaticamente quando a quantidade ou unidade medida for alterada
  final bool automaticUnSelectChangeProduct;

  SelectProductsModule(this.items,
      {this.name = "Quantidade",
      this.ao = "A",
      this.typeSelection = 1,
      this.showEstimatedValue = false,
      this.showSelectedOnTop = false,
      this.onEdit,
      this.onAdd,
      this.selectProductsRepository,
      this.executeSync = true,
      this.requiredEstimatedValue = false,
      this.selectedProduct,
      this.automaticUnSelectChangeProduct = false});
  @override
  List<Bloc> get blocs => [
        Bloc((i) => SelectProductsController(items,
            name: this.name,
            ao: this.ao,
            typeSelection: typeSelection,
            showEstimatedValue: showEstimatedValue,
            showSelectedOnTop: showSelectedOnTop,
            onAdd: onAdd,
            onEdit: onEdit,
            selectProductsRepository: selectProductsRepository,
            executeSync: executeSync,
            requiredEstimatedValue: requiredEstimatedValue,
            selectedProduct: selectedProduct,
            automaticUnSelectChangeProduct: automaticUnSelectChangeProduct)),
      ];

  @override
  List<Dependency> get dependencies => [];

  @override
  Widget get view => SelectProductsPage();

  static Inject get to => Inject<SelectProductsModule>.of();
}
