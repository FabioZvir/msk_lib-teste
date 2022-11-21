import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:msk/msk.dart';

class AssinaturaWidget extends StatelessWidget {
  final AssinaturaController controller;
  final String title;
  final Function(File) onUpdated;
  final bool allowEditing;

  const AssinaturaWidget(this.controller, this.onUpdated,
      {this.title = "Assinatura", this.allowEditing = true});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      children: <Widget>[
        TextTitle(title),
        Observer(
          builder: (_) => Container(
              height: 80,
              width: size.width - 20,
              child: InkWell(
                  onTap: () {
                    showOptions(context);
                  },
                  child: Card(
                    color: Colors.white,
                    child: controller.file != null
                        ? Image.file(
                            controller.file!,
                            height: 80,
                            width: size.width - 20,
                            fit: BoxFit.scaleDown,
                          )
                        : (controller.url?.isNotEmpty == true)
                            ? Image.network(
                                controller.url!,
                                height: 80,
                                width: size.width - 20,
                                fit: BoxFit.scaleDown,
                              )
                            : Center(
                                child: Text(
                                'Toque para assinar',
                                style: TextStyle(color: Colors.black),
                              )),
                  ))),
        ),
      ],
    );
  }

  showOptions(BuildContext context) async {
    if (controller.assinado()) {
      /// Caso não seja permitida a edição, abre a assinatura diretamente
      if (!allowEditing) {
        _viewSignature(context);
      } else {
        showModalBottomSheet(
            context: context,
            builder: (alertContext) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text('Ver Assinatura'),
                    onTap: () {
                      Navigator.pop(alertContext);
                      _viewSignature(context);
                    },
                  ),
                  ListTile(
                    title: Text('Trocar Assinatura'),
                    onTap: () async {
                      Navigator.pop(alertContext);
                      var res = await Navigator.maybeOf(context)?.push(
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new SignaturesModule()));
                      if (res != null) {
                        controller.file = null;
                        controller.file = res;
                        onUpdated(res);
                      }
                    },
                  ),
                ],
              );
            });
      }
    } else if (allowEditing) {
      var res = await Navigator.maybeOf(context)?.push(new MaterialPageRoute(
          builder: (BuildContext context) => new SignaturesModule()));
      if (res != null) {
        controller.file = null;
        controller.file = res;
      }
    } else {
      showSnack(context, 'A edição não é permitida');
    }
  }

  void _viewSignature(BuildContext context) {
    Navigation.push(
        context,
        VerMidiaModule([
          ItemMidia(
              path: controller.file?.path,
              url: controller.url,
              tipoMidia: TipoMidiaEnum.IMAGEM)
        ], backgroundColor: Colors.white, appBarColor: Colors.black));
  }
}
