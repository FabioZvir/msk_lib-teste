import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:mobx/mobx.dart';

part 'menu.g.dart';

@HiveType(typeId: 2)
class Menu extends _MenuBase with _$Menu {
  Menu({
    int? id,
    String? nome,
    int? codSistema,
    int? codColuna,
    bool? favorito,
    List<int> empresas = const [],
    bool? insereDados,
    bool? alteraDados,
    bool? deletaDados,
  }) : super(
            id: id,
            nome: nome,
            codSistema: codSistema,
            codColuna: codColuna,
            favorito: favorito,
            empresas: empresas,
            insereDados: insereDados,
            alteraDados: alteraDados,
            deletaDados: deletaDados);
  static Menu? fromMap(Map<String, dynamic> map) {
    return _MenuBase.fromMap(map);
  }
}

abstract class _MenuBase extends HiveObject with Store {
  @HiveField(0)
  int? id;
  @HiveField(1)
  String? nome;
  @HiveField(2)
  int? codSistema;
  @HiveField(3)
  int? codColuna;
  @HiveField(10)
  @observable
  bool? favorito;
  @HiveField(11)
  List<int> empresas;
  @HiveField(12)
  bool? insereDados;
  @HiveField(13)
  bool? alteraDados;
  @HiveField(14)
  bool? deletaDados;

  _MenuBase(
      {this.id,
      this.nome,
      this.codSistema,
      this.codColuna,
      this.favorito,
      this.empresas = const [],
      this.insereDados,
      this.alteraDados,
      this.deletaDados});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'codSistema': codSistema,
      'codColuna': codColuna,
      'delete': delete,
      'favorito': favorito,
      'empresas': empresas,
      'insereDados': insereDados,
      'alteraDados': alteraDados,
      'deletaDados': deletaDados
    };
  }

  static Menu? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;

    return Menu(
        id: map['id'],
        nome: map['nome'],
        codSistema: map['codSistema'],
        codColuna: map['codColuna'],
        favorito: map['favorito'],
        empresas: map['empresas'] != null
            ? (map['empresas'] as List).map((e) => e as int).toList()
            : <int>[],
        insereDados: map['insereDados'],
        alteraDados: map['alteraDados'],
        deletaDados: map['deletaDados']);
  }

  String toJson() => json.encode(toMap());
}
