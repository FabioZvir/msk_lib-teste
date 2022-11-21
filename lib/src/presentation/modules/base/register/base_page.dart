import 'package:flutter/material.dart';
import 'package:msk_utils/msk_utils.dart';

mixin BasePage<T extends StatefulWidget> on State<T> {
  BuildContext? buildContext;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => layoutLoaded(context));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      //desativa a confirmação de saída no modo debug
      onWillPop: !UtilsPlatform.isDebug ? _onWillPop : null,
      child: Scaffold(
        appBar: buildAppBar(),
        body: Builder(builder: (context) {
          this.buildContext = context;
          return Form(
              child: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: buildInterface(context)),
          ));
        }),
      ),
    );
  }

  Widget buildInterface(BuildContext context);

  PreferredSizeWidget buildAppBar();

  void layoutLoaded(BuildContext context, {Map? args}) {}

  Future<bool> _onWillPop() async {
    return (await (showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Você tem certeza?'),
            content: new Text('Deseja sair sem salvar os dados'),
            actions: <Widget>[
              new TextButton(
                onPressed: () => Navigator.maybeOf(context)?.pop(false),
                child: new Text('Cancelar'),
              ),
              new TextButton(
                onPressed: () => Navigator.maybeOf(context)?.pop(true),
                child: new Text('Sim'),
              ),
            ],
          ),
        ))) ??
        false;
  }
}
