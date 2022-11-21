import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:msk/msk.dart';

class AvaliarAppPage extends StatefulWidget {
  final String title;

  const AvaliarAppPage({Key? key, this.title = "Fale conosco"})
      : super(key: key);

  @override
  _AvaliarAppPageState createState() => _AvaliarAppPageState();
}

class _AvaliarAppPageState extends State<AvaliarAppPage> {
  final controller = AvaliarAppModule.to.bloc<AvaliarAppController>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final bool checkedChanges = await controller.verificarDadosUpdate();
        if (checkedChanges == true) {
          return (await showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                        title: Text("Você realmente deseja voltar?"),
                        content: Text(
                            "Existem dados modificados, deseja cancelar o envio deste Feedback?"),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text("Cancelar")),
                          TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text("Confirmar"))
                        ]);
                  })) ??
              false;
        } else {
          return true;
        }
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            actions: [
              IconButton(
                  onPressed: () async {
                    final bool checkedChanges =
                        await controller.verificarDadosUpdate();
                    if (!checkedChanges) {
                      showSnack(
                          context, 'Insira seu feedback para cadastrarmos!');
                      return;
                    }
                    showDialog(
                        context: context,
                        builder: (alertContext) {
                          return AlertDialog(
                              title: Text("Confirmação do envio de Feedback"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Deseja cadastrar o Feedback?"),
                                ],
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("Cancelar")),
                                TextButton(
                                    onPressed: () async {
                                      MyPR progress = await showProgressDialog(
                                          context, "Enviando dados...");
                                      // bool success = false;
                                      await controller.envioDados();
                                      await progress.hide();
                                      Navigator.pop(alertContext);

                                      showSnack(context,
                                          'Sua participação é muito importante, agradecemos pelo Feedback!',
                                          dismiss: true, delayPop: false);
                                    },
                                    child: Text("Confirmar"))
                              ]);
                        });
                  },
                  icon: Icon(Icons.check))
            ],
          ),
          body: SingleChildScrollView(
            child: Center(
                child: Container(
              constraints: BoxConstraints(maxWidth: 800),
              child: Column(
                children: [
                  _cardAvaliacao(),
                  const SizedBox(height: 40),
                  _relatos()
                ],
              ),
            )),
          )),
    );
  }

  Card _cardAvaliacao() {
    Widget _selectAvaliacao(void Function()? onPressed, String grauAvaliacao,
        GrauSatisfacao avaliacao) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onPressed,
            icon: avaliacao.index <= controller.avaliacao.index
                ? Icon(Icons.star)
                : Icon(Icons.star_border_outlined),
            tooltip: grauAvaliacao,
          ),
          Text(grauAvaliacao)
        ],
      );
    }

    const dividerSpace = SizedBox(width: 16);

    return Card(
      child: Container(
          width: 800,
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 21, horizontal: 16),
              child: Column(children: [
                Text(app.nome, style: TextStyle(fontSize: 16)),
                const SizedBox(height: 40),
                Image.asset('imagens/icon_msk_inicio.png',
                    width: 150, height: 150, package: 'msk'),
                const SizedBox(height: 40),
                Text("Sua avaliação é importante!",
                    style: TextStyle(fontSize: 16)),
                const SizedBox(height: 40),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Observer(
                    builder: (_) {
                      return Row(mainAxisSize: MainAxisSize.min, children: [
                        _selectAvaliacao(() {
                          controller.avaliacao = GrauSatisfacao.muitoRuim;
                        }, "Muito ruim", GrauSatisfacao.muitoRuim),
                        dividerSpace,
                        _selectAvaliacao(() {
                          controller.avaliacao = GrauSatisfacao.ruim;
                        }, "Ruim", GrauSatisfacao.ruim),
                        dividerSpace,
                        _selectAvaliacao(() {
                          controller.avaliacao = GrauSatisfacao.bom;
                        }, "Bom", GrauSatisfacao.bom),
                        dividerSpace,
                        _selectAvaliacao(() {
                          controller.avaliacao = GrauSatisfacao.muitoBom;
                        }, "Muito bom", GrauSatisfacao.muitoBom),
                        dividerSpace,
                        _selectAvaliacao(() {
                          controller.avaliacao = GrauSatisfacao.otimo;
                        }, "Ótimo", GrauSatisfacao.otimo),
                      ]);
                    },
                  ),
                )
              ]))),
    );
  }

  Card _relatos() {
    const _dividerConst = SizedBox(height: 8);
    return Card(
      child: Container(
          width: 800,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 21, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Text(
                        "Informe-nos como está sendo sua experiência com o App (opcional)!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                        ))),
                _dividerConst,
                Text(
                    "Escreva sua sugestão, um problema, uma dúvida ou envie capturas de tela para auxiliar:"),
                const SizedBox(height: 16),
                Observer(
                  builder: (_) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ButtonChip("Sugestão",
                            isSelected: controller.tipoFeedback ==
                                TipoFeedback.sugestao,
                            onTap: () => controller.tipoFeedback =
                                TipoFeedback.sugestao),
                        const SizedBox(width: 16),
                        ButtonChip("Problema",
                            isSelected: controller.tipoFeedback ==
                                TipoFeedback.problema,
                            onTap: () => controller.tipoFeedback =
                                TipoFeedback.problema),
                        const SizedBox(width: 16),
                        ButtonChip("Dúvida",
                            isSelected:
                                controller.tipoFeedback == TipoFeedback.duvida,
                            onTap: () =>
                                controller.tipoFeedback = TipoFeedback.duvida),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                InputTextField(
                    controller: controller.ctlTextoFeedback,
                    keyboardType: TextInputType.multiline,
                    maxLines: 10,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Escreva aqui...',
                        filled: true,
                        fillColor: isDarkMode(context)
                            ? Colors.grey[850]
                            : Colors.grey[50], //para tema branco 50
                        contentPadding: const EdgeInsets.only(
                            left: 16.0, right: 16, bottom: 6.0, top: 24),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0)))),
                SizedBox(height: 16),
                Text("Adicionar imagens (opcional):",
                    style: TextStyle(fontSize: 16, color: Colors.blue)),
                SeletorMidiaWidget(controller.ctlFotos),
              ],
            ),
          )),
    );
  }
}
