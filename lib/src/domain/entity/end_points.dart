import 'package:msk/msk.dart';

class EndPoints {
  final String sincronizacao;
  final String menu;
  final String controleVersao;
  final String registroToken;
  final String favoritarMenu;

  const EndPoints(this.sincronizacao, this.menu, this.registroToken,
      {this.controleVersao = Constants.END_POINT_VERSAO,
      this.favoritarMenu = Constants.END_POINT_FAVORITAR_MENU});
}
