import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

import 'package:msk/msk.dart';

part 'item_select_product.g.dart';

class DataExtraProduct {
  String data;
  double? fontSize;
  DataExtraProduct({
    required this.data,
    this.fontSize,
  });

  DataExtraProduct copyWith({
    String? data,
    double? fontSize,
  }) {
    return DataExtraProduct(
      data: data ?? this.data,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'data': data,
      'fontSize': fontSize,
    };
  }

  factory DataExtraProduct.fromMap(Map<String, dynamic> map) {
    return DataExtraProduct(
      data: map['data'] ?? '',
      fontSize: map['fontSize']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory DataExtraProduct.fromJson(String source) =>
      DataExtraProduct.fromMap(json.decode(source));

  @override
  String toString() => 'DataExtraProduct(data: $data, fontSize: $fontSize)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DataExtraProduct &&
        other.data == data &&
        other.fontSize == fontSize;
  }

  @override
  int get hashCode => data.hashCode ^ fontSize.hashCode;
}

class Product {
  int id;
  int idServer;
  String name;
  String classification;
  String structure;
  int ncm;
  List<DataExtraProduct> extra;
  Product(
      {required this.id,
      required this.idServer,
      required this.name,
      required this.classification,
      required this.structure,
      required this.ncm,
      this.extra = const []});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'classification': classification,
      'structure': structure,
      'ncm': ncm,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
        id: map['id']?.toInt() ?? 0,
        idServer: map['idServer'] ?? 0,
        name: map['name'] ?? map['nome'] ?? '',
        classification: map['classification'] ?? map['classificacao'] ?? '',
        structure: map['structure'] ?? map['estruturaProduto'] ?? '',
        ncm: map['ncm'] ?? 0,
        extra: map['infoExtra'] != null && map['infoExtra'] is List
            ? (map['infoExtra'] as List)
                .map((e) =>
                    DataExtraProduct(data: e['data'], fontSize: e['fontSize']))
                .toList()
            : []);
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source));
}

class UnitMeasure {
  int id;
  String abbreviation;
  String name;
  double lastPurchaseValue;

  UnitMeasure(
      {required this.id,
      required this.abbreviation,
      required this.name,
      this.lastPurchaseValue = 0});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'abbreviation': abbreviation,
      'lastPurchaseValue': lastPurchaseValue
    };
  }

  factory UnitMeasure.fromMap(Map<String, dynamic> map) {
    return UnitMeasure(
      id: map['id']?.toInt() ?? 0,
      abbreviation: map['abbreviation'] ?? map['abreviacao'] ?? '',
      name: map['name'] ?? '',
      lastPurchaseValue: map['lastPurchaseValue']?.toDouble() ??
          map['valorUltimaCompra']?.toDouble() ??
          0,
    );
  }

  String toJson() => json.encode(toMap());

  factory UnitMeasure.fromJson(String source) =>
      UnitMeasure.fromMap(json.decode(source));
}

class UnitMeasureProduct {
  int id;
  Product product;
  UnitMeasure unitMeasure;
  int idServer;
  UnitMeasureProduct(
      {required this.id,
      required this.product,
      required this.unitMeasure,
      required this.idServer});
}

class ItemSelectProduct = _ItemSelectProductBase with _$ItemSelectProduct;

abstract class _ItemSelectProductBase extends ItemSelect with Store {
  Product? product;
  @observable
  double quantity;
  @observable
  UnitMeasure? unitMeasure;
  UnitMeasureProduct? unitMeasureProduct;

  @observable //usado para filtrar
  bool show = true;

  final TextEditingController ctlEstimatedValue = TextEditingController();
  final TextEditingController ctlUnitEstimatedValue = TextEditingController();
  final SelecionarQuantidadeController ctlQuantity =
      SelecionarQuantidadeController();

  final TextEditingController ctlObs = TextEditingController();
  @observable
  ItemMidia? fotoItemReq;

  _ItemSelectProductBase({this.quantity = 1});

  ItemSelectProduct copy() {
    ItemSelectProduct item = ItemSelectProduct();
    item.product = product;
    item.quantity = quantity;
    item.unitMeasure = unitMeasure;
    item.unitMeasureProduct = unitMeasureProduct;
    item.show = show;
    item.ctlEstimatedValue.text = ctlEstimatedValue.text;
    item.ctlUnitEstimatedValue.text = ctlUnitEstimatedValue.text;
    item.ctlQuantity.quantidade = ctlQuantity.quantidade;
    item.ctlObs.text = ctlObs.text;
    item.fotoItemReq = fotoItemReq;
    return item;
  }
}
