import 'dart:io';

import 'package:mobx/mobx.dart';

part 'assinatura_controller.g.dart';

class AssinaturaController = _AssinaturaBase with _$AssinaturaController;

abstract class _AssinaturaBase with Store {
  @observable
  File? file;
  @observable
  String? url;

  bool assinado() {
    return file != null || (url != null && url!.isNotEmpty);
  }
}
