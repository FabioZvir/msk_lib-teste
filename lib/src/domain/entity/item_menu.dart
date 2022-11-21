import 'package:flutter/widgets.dart';
import 'package:msk/msk.dart';

class MenuItemMsk {
  int? codSistema;
  String? titulo;
  ActionSelect Function(Menu)? acao;
  List<MenuItemMsk> subMenus;
  Widget? icone;
  bool exibirSempre;

  /// Caso seja verdadeira, só abre o menu se pelo menos uma das versões da sync não estiverem 0
  bool precisaSync;

  /// Define a cor dos menus favoritos
  Color? cor;

  /// Define se o acionamento do menu irá acionar a sync antes de abrir a tela
  bool executeSync;
  MenuItemMsk(
      {this.codSistema,
      this.titulo,
      this.acao,
      this.subMenus = const [],
      this.icone,
      this.exibirSempre = false,
      this.precisaSync = true,
      this.cor,
      this.executeSync = false});
}
