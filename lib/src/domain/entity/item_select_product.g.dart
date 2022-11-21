// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_select_product.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ItemSelectProduct on _ItemSelectProductBase, Store {
  final _$quantityAtom = Atom(name: '_ItemSelectProductBase.quantity');

  @override
  double get quantity {
    _$quantityAtom.reportRead();
    return super.quantity;
  }

  @override
  set quantity(double value) {
    _$quantityAtom.reportWrite(value, super.quantity, () {
      super.quantity = value;
    });
  }

  final _$unitMeasureAtom = Atom(name: '_ItemSelectProductBase.unitMeasure');

  @override
  UnitMeasure? get unitMeasure {
    _$unitMeasureAtom.reportRead();
    return super.unitMeasure;
  }

  @override
  set unitMeasure(UnitMeasure? value) {
    _$unitMeasureAtom.reportWrite(value, super.unitMeasure, () {
      super.unitMeasure = value;
    });
  }

  final _$showAtom = Atom(name: '_ItemSelectProductBase.show');

  @override
  bool get show {
    _$showAtom.reportRead();
    return super.show;
  }

  @override
  set show(bool value) {
    _$showAtom.reportWrite(value, super.show, () {
      super.show = value;
    });
  }

  final _$fotoItemReqAtom = Atom(name: '_ItemSelectProductBase.fotoItemReq');

  @override
  ItemMidia? get fotoItemReq {
    _$fotoItemReqAtom.reportRead();
    return super.fotoItemReq;
  }

  @override
  set fotoItemReq(ItemMidia? value) {
    _$fotoItemReqAtom.reportWrite(value, super.fotoItemReq, () {
      super.fotoItemReq = value;
    });
  }

  @override
  String toString() {
    return '''
quantity: ${quantity},
unitMeasure: ${unitMeasure},
show: ${show},
fotoItemReq: ${fotoItemReq}
    ''';
  }
}
