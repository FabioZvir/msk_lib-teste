// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MenuAdapter extends TypeAdapter<Menu> {
  @override
  final int typeId = 2;

  @override
  Menu read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Menu(
      id: fields[0] as int?,
      nome: fields[1] as String?,
      codSistema: fields[2] as int?,
      codColuna: fields[3] as int?,
      favorito: fields[10] as bool?,
      empresas: (fields[11] as List).cast<int>(),
      insereDados: fields[12] as bool?,
      alteraDados: fields[13] as bool?,
      deletaDados: fields[14] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, Menu obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.codSistema)
      ..writeByte(3)
      ..write(obj.codColuna)
      ..writeByte(10)
      ..write(obj.favorito)
      ..writeByte(11)
      ..write(obj.empresas)
      ..writeByte(12)
      ..write(obj.insereDados)
      ..writeByte(13)
      ..write(obj.alteraDados)
      ..writeByte(14)
      ..write(obj.deletaDados);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$Menu on _MenuBase, Store {
  final _$favoritoAtom = Atom(name: '_MenuBase.favorito');

  @override
  bool? get favorito {
    _$favoritoAtom.reportRead();
    return super.favorito;
  }

  @override
  set favorito(bool? value) {
    _$favoritoAtom.reportWrite(value, super.favorito, () {
      super.favorito = value;
    });
  }

  @override
  String toString() {
    return '''
favorito: ${favorito}
    ''';
  }
}
