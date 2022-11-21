import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:msk/msk.dart';

class SelectProductsPage extends StatefulWidget {
  final String title;
  const SelectProductsPage({Key? key, this.title = "Selecionar Produtos"})
      : super(key: key);

  @override
  _SelectProductsPageState createState() => _SelectProductsPageState();
}

class _SelectProductsPageState extends State<SelectProductsPage> {
  final SelectProductsController controller =
      SelectProductsModule.to.bloc<SelectProductsController>();

  @override
  void initState() {
    super.initState();
    controller.ctlFilter.addListener(() {
      if (controller.textFilter != controller.ctlFilter.text.trim()) {
        controller.textFilter = controller.ctlFilter.text.trim();
      }
    });
    if (controller.executeSync) {
      WidgetsBinding.instance?.addPostFrameCallback((_) async {
        MyPR progress =
            await showProgressDialog(context, 'Sincronizando dados');
        GetIt.I.get<AtualizarDados>().sincronizar(onlyLists: [
          'produtos',
          'unidadesMedidaProduto',
          'unidadesMedida'
        ]).then((value) {
          progress.hide();
          controller.future = controller.getProdutos();
        });
      });
    } else {
      controller.future = controller.getProdutos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF):
              const SearchIntent(),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyL):
              const SearchIntent(),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyI):
              const InsertIntent(),
          LogicalKeySet(LogicalKeyboardKey.insert): const InsertIntent(),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
              const DoneIntent(),
        },
        child: Actions(
            actions: <Type, Action<Intent>>{
              DismissIntent: CallbackAction<DismissIntent>(
                  onInvoke: (DismissIntent intent) {
                Navigator.pop(context);
                return;
              }),
              InsertIntent:
                  CallbackAction<InsertIntent>(onInvoke: (InsertIntent intent) {
                _addProduto();
                return;
              }),
              SearchIntent:
                  CallbackAction<SearchIntent>(onInvoke: (SearchIntent intent) {
                _searchPressed();
                return;
              }),
              DoneIntent:
                  CallbackAction<DoneIntent>(onInvoke: (DoneIntent intent) {
                _doneButton();
                return;
              }),
            },
            child: Focus(
                autofocus: true,
                child: MyScaf(
                    appBar: new AppBar(
                      centerTitle: true,
                      actions: _getMenuButtons(),
                      title: Observer(builder: (_) => controller.appBarTitle!),
                      leading: Observer(
                        builder: (_) => new IconButton(
                          icon: controller.searchIcon,
                          onPressed: _searchPressed,
                        ),
                      ),
                    ),
                    floatingActionButton: FloatingActionButton(
                      child: Icon(Icons.done),
                      onPressed: _doneButton,
                    ),
                    body: Builder(
                        builder: (context) => Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Observer(
                              builder: (_) => controller.loading == true
                                  ? Center(child: CircularProgressIndicator())
                                  : FutureBuilder(
                                      future: controller.future,
                                      builder: (_, snap) {
                                        if (snap.connectionState !=
                                            ConnectionState.done) {
                                          return Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                        if (snap.hasError) {
                                          return FalhaWidget(
                                              'Houve uma falha ao buscar os produtos',
                                              error: snap.error);
                                        }
                                        return Observer(
                                          builder: (_) => ListView.builder(
                                            itemCount:
                                                controller.listaExibida.length,
                                            itemBuilder: (_, pos) {
                                              return _itemProdutoList(pos);
                                            },
                                          ),
                                        );
                                      }),
                            )))))));
  }

  void _doneButton() {
    if (controller.showEstimatedValue) {
      controller.listSelecionados.forEach((item) {
        int index = controller.list
            .indexWhere((element) => element.product!.id == item.product!.id);
        if (index > -1) {
          item.ctlEstimatedValue.text =
              controller.list[index].ctlEstimatedValue.text;
          item.ctlUnitEstimatedValue.text =
              controller.list[index].ctlUnitEstimatedValue.text;
        }
      });
      if (controller.requiredEstimatedValue &&
          controller.listSelecionados.any((element) =>
              element.ctlEstimatedValue.text.isEmpty ||
              element.ctlEstimatedValue.text.toDouble() == 0)) {
        showSnack(context,
            'Você precisa informar o valor estimado de todos os produtos');
        return;
      }
    }
    Navigator.maybeOf(context)?.pop(controller.listSelecionados);
  }

  void _searchPressed() {
    FocusNode focusNode = FocusNode();
    if (controller.searchIcon.icon == Icons.search) {
      controller.searchIcon = new Icon(Icons.close);
      controller.appBarTitle = new TextField(
        autofocus: true,
        focusNode: focusNode,
        controller: controller.ctlFilter,
        decoration: new InputDecoration(
            prefixIcon: new Icon(Icons.search), hintText: 'Pesquise...'),
      );
      focusNode.requestFocus();
    } else {
      controller.searchIcon = new Icon(Icons.search);
      controller.appBarTitle = new Text('Selecione os produtos');
      controller.ctlFilter.clear();
    }
  }

  Widget _itemProdutoList(int pos) {
    return Observer(builder: (_) {
      // if (controller.listaExibida[pos].isDeleted == true) {
      //   return SizedBox();
      // }
      return InkWell(
        onLongPress: controller.onEdit != null
            ? () {
                _editarProduto(pos);
              }
            : null,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(controller.listaExibida[pos].product?.name ?? '',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                    '${controller.listaExibida[pos].product?.structure ?? ''} - ${controller.listaExibida[pos].product?.classification ?? ''}'),
                Text('${controller.listaExibida[pos].product?.ncm}',
                    style: TextStyle(
                        fontSize: 11,
                        color: isDarkMode(context)
                            ? Colors.white70
                            : Colors.black87)),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  runAlignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  direction: Axis.horizontal,
                  children: <Widget>[
                    Row(),
                    SelecionarQuantidadeWidget(
                      controller.listaExibida[pos].quantity,
                      (double? qtd) {
                        controller.listaExibida[pos].quantity = qtd!;
                        controller.listSelecionados
                            .firstWhereOrNull(
                              (element) =>
                                  element.product!.id ==
                                  controller.listaExibida[pos].product!.id,
                            )
                            ?.quantity = qtd;

                        if (qtd == 0) {
                          controller.removerItem(pos);
                        }
                        calcularValorTotal(pos);
                        if (controller.automaticUnSelectChangeProduct) {
                          controller.removerItem(pos);
                        }
                      },
                      nome: controller.name!,
                      ao: controller.ao!,
                      min: 0,
                      casasDecimais: 4,
                      controller: controller.listaExibida[pos].ctlQuantity,
                    ),
                    TextButton(onPressed: () async {
                      if (controller.automaticUnSelectChangeProduct) {
                        controller.removerItem(pos);
                      }

                      /// Em caso de seleção simples, desmarca todos os demais

                      bool b = await _selecionarUnidadeMedida(pos);

                      /// Deve fazer isso para atualizar a unidade de medida na lista de selecionados
                      if (b == true) {
                        controller.listaExibida[pos].isDeleted = false;
                        controller.itemSelecionado(pos);
                      }
                    }, child: Observer(builder: (_) {
                      return Text(
                          '${controller.listaExibida[pos].unitMeasure?.abbreviation ?? '-'}');
                    })),
                    Observer(
                      builder: (_) => Button(
                          controller.listaExibida[pos].isSelected
                              ? 'Remover'
                              : 'Adicionar', () async {
                        if (controller.listaExibida[pos].isSelected) {
                          controller.removerItem(pos);
                        } else {
                          if (controller.listaExibida[pos].quantity > 0) {
                            adicionarProduto(pos);
                          } else {
                            showSnack(context, 'Insira a quantidade antes');
                          }
                        }
                      },
                          minIntervalClick: 0,
                          color: controller.listaExibida[pos].isSelected
                              ? Colors.red
                              : defaultAppColor),
                    ),
                    if (controller.showEstimatedValue)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Valores Estimados/Máximos'),
                          Row(
                            children: [
                              Expanded(
                                  child: InputTextField(
                                decoration:
                                    InputDecoration(labelText: 'Valor Total'),
                                keyboardType: TextInputType.number,
                                controller: controller
                                    .listaExibida[pos].ctlEstimatedValue,
                                onChanged: (text) {
                                  calcularValorUnitario(pos);
                                },
                              )),
                              SizedBox(width: 16),
                              Expanded(
                                  child: InputTextField(
                                decoration: InputDecoration(
                                    labelText: 'Valor Unitário '),
                                keyboardType: TextInputType.number,
                                controller: controller
                                    .listaExibida[pos].ctlUnitEstimatedValue,
                                onChanged: (text) {
                                  calcularValorTotal(pos);
                                },
                              )),
                            ],
                          ),
                        ],
                      )
                  ],
                ),
                if (controller.listaExibida[pos].product!.extra.isNotEmpty)
                  ...controller.listaExibida[pos].product!.extra
                      .map((e) => Text(
                            e.data,
                            style: TextStyle(fontSize: e.fontSize),
                          ))
                      .toList()
              ],
            ),
          ),
        ),
      );
    });
  }

  calcularValorUnitario(int pos) {
    if (controller.listaExibida[pos].ctlEstimatedValue.text.isNotEmpty) {
      if (controller.listaExibida[pos].quantity > 0) {
        controller.listaExibida[pos].ctlUnitEstimatedValue.text =
            (controller.listaExibida[pos].ctlEstimatedValue.text.toDouble() /
                    controller.listaExibida[pos].quantity)
                .toStringAsFixed(2);
      } else if (controller
              .listaExibida[pos].ctlUnitEstimatedValue.text.isNotEmpty &&
          controller.listaExibida[pos].ctlUnitEstimatedValue.text.toDouble() >
              0) {
        controller.listaExibida[pos].quantity = controller
                .listaExibida[pos].ctlEstimatedValue.text
                .toDouble() /
            controller.listaExibida[pos].ctlUnitEstimatedValue.text.toDouble();
        controller.listaExibida[pos].ctlQuantity.cltQuantidade.text =
            '${controller.listaExibida[pos].quantity}';
        controller.listaExibida[pos].ctlQuantity.ctlQuantidadeDesktop.text =
            '${controller.listaExibida[pos].quantity}';
      }
    } else {
      controller.listaExibida[pos].ctlUnitEstimatedValue.text = '';
    }
  }

  calcularValorTotal(int pos) {
    if (controller.listaExibida[pos].ctlUnitEstimatedValue.text.isNotEmpty) {
      controller.listaExibida[pos].ctlEstimatedValue.text =
          (controller.listaExibida[pos].ctlUnitEstimatedValue.text.toDouble() *
                  controller.listaExibida[pos].quantity)
              .toStringAsFixed(2);
    } else {
      controller.listaExibida[pos].ctlEstimatedValue.text = '';
    }
  }

  adicionarProduto(int pos) async {
    if (controller.listaExibida[pos].unitMeasure == null) {
      bool b = await _selecionarUnidadeMedida(pos);
      if (b) {
        controller.listaExibida[pos].isDeleted = false;
        controller.itemSelecionado(pos);
      }
    } else {
      controller.listaExibida[pos].isDeleted = false;
      controller.itemSelecionado(pos);
      controller.verificarRemocaoItensSelecionados(pos);
    }
    return;
  }

  _getMenuButtons() {
    var widgets = [
      IconButton(
        icon: Icon(Icons.add),
        onPressed: controller.onAdd != null ? _addProduto : null,
      ),
      // if (UtilsPlatform.isMobile)
      //   IconButton(
      //     icon: Icon(Icons.qr_code_scanner),
      //     onPressed: () async {
      //       escanearQrCode();
      //     },
      //   )
    ];
    if (!UtilsPlatform.isAndroid) {
      return widgets
        ..add(IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.maybeOf(context)?.pop();
          },
        ));
    } else {
      return widgets;
    }
  }

  void _addProduto() async {
    if (AppBaseModule.to
        .bloc<MenuController>()
        .menus
        .any((element) => element.codSistema == 146)) {
      ItemSelectProduct? res = await controller.onAdd!();
      if (res != null) {
        controller.list.add(res);
        int index = controller.listaExibida
            .indexWhere((element) => element.product?.id == res.product?.id);
        if (index > -1) {
          await adicionarProduto(index);
          setState(() {});
        }
      }
    } else {
      showSnack(context, 'Você não tem permissão de inserir produtos');
    }
  }

  void _editarProduto(int index) async {
    if (AppBaseModule.to
        .bloc<MenuController>()
        .menus
        .any((element) => element.codSistema == 146)) {
      ItemSelectProduct? res =
          await controller.onEdit!(controller.listaExibida[index]);
      if (res != null) {
        controller.loading = true;
        controller.listaExibida[index] = res;

        int index3 = controller.listSelecionados
            .indexWhere((element) => element.product!.id == res.product!.id);
        if (index3 > -1) {
          /// Caso exista na lista de selecionados (index3 > -1)
          /// Chama itemSelecionado passando o index da listaExibida
          controller.listSelecionados[index3] = res;
        }
        adicionarProduto(index);
        controller.loading = false;
      }
    } else {
      showSnack(context, 'Você não tem permissão de editar produtos');
    }
  }

  Future<bool> _selecionarUnidadeMedida(int index) async {
    ItemSelectProduct item = controller.listaExibida[index];
    controller.verificarRemocaoItensSelecionados(index);
    final res1 = await controller.selectProductsRepository
        .getUnitsMeasureByProductId(item.product!);

    if (res1.isEmpty) {
      showSnack(
          context, 'Ops, parece que o produto não possui unidade de medida');
      return false;
    } else if (res1.length == 1) {
      return _updateUnitMeasure(res1.first, item.product!.id, index);
    }

    var res = await Navigation.push(
        context,
        SelectAnyModule(SelectModel(
            'Unidade de Medida',
            'id',
            [
              Line('unitMeasure/name', name: 'Nome'),
              Line('unitMeasure/abbreviation', name: 'Abreviação')
            ],
            FontDataAny((_) async => res1
                .map((e) => {
                      'id': e.id,
                      'idServer': e.idServer,
                      'unitMeasure': {
                        'name': e.unitMeasure.name,
                        'abbreviation': e.unitMeasure.abbreviation,
                      }
                    })
                .toList()),
            TypeSelect.SIMPLE)));
    if (res != null) {
      return _updateUnitMeasure(
          UnitMeasureProduct(
            id: res['id'],
            idServer: res['idServer'],
            unitMeasure: UnitMeasure.fromMap(res['unitMeasure']),
            product: item.product!,
          ),
          item.product!.id,
          index);
    }
    return false;
  }

  /// Atualiza a unidade de medida
  bool _updateUnitMeasure(UnitMeasureProduct unitMeasureProduct, int? productId,
      int indexListDisplayed) {
    int index0 = controller.listSelecionados
        .indexWhere((element) => element.product?.id == productId);
    if (index0 > -1) {
      controller.listSelecionados[index0].unitMeasureProduct =
          unitMeasureProduct;
      controller.listSelecionados[index0].unitMeasure =
          unitMeasureProduct.unitMeasure;
    }
    controller.listaExibida[indexListDisplayed].unitMeasure =
        unitMeasureProduct.unitMeasure;
    controller.listaExibida[indexListDisplayed].unitMeasureProduct =
        unitMeasureProduct;

    if (controller
            .listaExibida[indexListDisplayed].ctlEstimatedValue.text.isEmpty ||
        controller.listaExibida[indexListDisplayed].ctlEstimatedValue.text
                .toDouble() ==
            0) {
      controller.listaExibida[indexListDisplayed].ctlEstimatedValue.text =
          ((unitMeasureProduct.unitMeasure.lastPurchaseValue) *
                  (controller.listaExibida[indexListDisplayed].quantity))
              .toString();
      controller.listaExibida[indexListDisplayed].ctlUnitEstimatedValue.text =
          (unitMeasureProduct.unitMeasure.lastPurchaseValue).toString();
    }

    int index2 = controller.list
        .indexWhere((element) => element.product!.id == productId);
    if (index2 > -1) {
      controller.list[index2].unitMeasure = unitMeasureProduct.unitMeasure;
      controller.list[index2].unitMeasureProduct = unitMeasureProduct;
      if (controller.list[index2].ctlEstimatedValue.text.isEmpty ||
          controller.list[index2].ctlEstimatedValue.text.toDouble() == 0) {
        controller.list[index2].ctlEstimatedValue.text =
            ((unitMeasureProduct.unitMeasure.lastPurchaseValue) *
                    (controller.listaExibida[indexListDisplayed].quantity))
                .toString();
        controller.list[index2].ctlUnitEstimatedValue.text =
            (unitMeasureProduct.unitMeasure.lastPurchaseValue).toString();
      }
      return true;
    } else {
      showSnack(context, 'Ops, algo saiu errado');
      return false;
    }
  }

  // void escanearQrCode() async {
  //   if (UtilsPlatform.isMobile) {
  //     var res = await Navigation.push(context, LeitorQrModule());
  //     if (res != null) {
  //       selecionarProdutoCodBar(res);
  //     }
  //   } else {
  //     TextEditingController ctlCodBar = TextEditingController();
  //     showDialog(
  //         context: context,
  //         builder: (alertDialog) => AlertDialog(
  //               title: Text('Escanear Código de Barras'),
  //               content: InputTextField(
  //                 controller: ctlCodBar,
  //                 decoration: InputDecoration(labelText: 'Código de Barras'),
  //               ),
  //               actions: [
  //                 TextButton(
  //                     onPressed: () {
  //                       Navigator.pop(alertDialog);
  //                     },
  //                     child: Text('Cancelar')),
  //                 TextButton(
  //                     onPressed: () {
  //                       Navigator.pop(alertDialog);
  //                       selecionarProdutoCodBar(ctlCodBar.text.trim());
  //                     },
  //                     child: Text('Procurar produto'))
  //               ],
  //             ));
  //   }
  // }

  Future<bool> selecionarProdutoCodBar(String codBar) async {
    UnitMeasureProduct? unitMeasure = await controller.selectProductsRepository
        .getUnitMeasureByCodBar(codBar);
    if (unitMeasure != null) {
      int index2 = controller.list.indexWhere(
          (element) => element.product!.id == unitMeasure.product.id);

      if (index2 > -1) {
        ItemSelectProduct item = controller.list[index2];
        controller.list.removeAt(index2);

        item.unitMeasure = unitMeasure.unitMeasure;
        if (item.ctlEstimatedValue.text.isEmpty ||
            item.ctlEstimatedValue.text.toDouble() == 0) {
          item.ctlEstimatedValue.text =
              (unitMeasure.unitMeasure.lastPurchaseValue * item.quantity)
                  .toString();
        }
        controller.list.insert(0, item);
      }

      int index = controller.listaExibida.indexWhere(
          (element) => element.product!.id == unitMeasure.product.id);
      if (index > -1) {
        controller.listaExibida[index].unitMeasure = unitMeasure.unitMeasure;
        if (controller.listaExibida[index].ctlEstimatedValue.text.isEmpty ||
            controller.listaExibida[index].ctlEstimatedValue.text.toDouble() ==
                0) {
          controller.listaExibida[index].ctlEstimatedValue.text =
              (((unitMeasure.unitMeasure.lastPurchaseValue) as int) *
                      controller.listaExibida[index].quantity)
                  .toString();
        }
        controller.itemSelecionado(index);
        showSnack(context,
            'Produto ${unitMeasure.product.name} selecionado com sucesso');

        //// FAZ ISSO PARA QUE A LISTA ATUALIZE
        controller.textFilter = controller.textFilter;
        return true;
      }
    } else {
      showSnack(context,
          'Não foi possivel encontrar nenhum produto com o código de barras ${codBar}');
    }
    return false;
  }
}
