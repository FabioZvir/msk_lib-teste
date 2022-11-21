import 'package:mobx/mobx.dart';
import 'package:msk_widgets/msk_widgets.dart';

part 'salvar_controller.g.dart';

class SalvarController = _SalvarBase with _$SalvarController;

abstract class _SalvarBase with Store {
  int timeLastClick = 0;
  @observable
  int statusEdicao = BaseCadastroConst.REGISTRO_NAO_DEFINIDO;
  @observable
  bool permitirClique = true;
}
