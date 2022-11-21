import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:msk/msk.dart';

class MenuFavoritoWidget extends StatelessWidget {
  final List<MenuItemMsk> menus;
  final BuildContext buildContext;

  MenuFavoritoWidget(this.buildContext, {Key? key, required this.menus})
      : super(key: key) {
    AppBaseModule.to.bloc<MenuController>().loadMenus();
  }

  @override
  Widget build(BuildContext context) {
    if (!menus.any((element) => element.titulo == 'Conta')) {
      menus.addAll(getMenusAuth(context));
    }

    return FutureBuilder<Box>(
        future: hiveService.getBox(Constants.MENU_BOX_NAME),
        builder: (_, AsyncSnapshot<Box> value) {
          if (value.connectionState != ConnectionState.done) {
            return Center();
          }
          return ValueListenableBuilder(
            valueListenable: value.data!.listenable(),
            builder: (context, Box box, widget) {
              List<Widget> itens = [];
              for (MenuItemMsk menu in menus) {
                for (MenuItemMsk subMenu in menu.subMenus) {
                  for (Menu? menuSis in box.values) {
                    if (menuSis!.favorito == true &&
                        (AppBaseModule.to.bloc<MenuController>().companyId ==
                                null ||
                            menuSis.empresas.contains(AppBaseModule.to
                                .bloc<MenuController>()
                                .companyId!)) &&
                        subMenu.codSistema == menuSis.codSistema) {
                      itens.add(itemMenuMain(buildContext, subMenu, menuSis));
                    }
                  }
                }
              }
              if (UtilsPlatform.isMobile) {
                if (itens.isEmpty) {
                  return Container(
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Os seus menus favoritos irão aparecer aqui',
                          )
                        ],
                      ));
                }
                return Scrollbar(
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Row(children: itens)))));
              } else {
                if (itens.isEmpty) {
                  return Container(
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.topCenter,
                      child:
                          Text('Os seus menus favoritos irão aparecer aqui'));
                }
                return Scrollbar(
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(children: itens))));
              }
            },
          );
        });
  }

  Widget itemMenuMain(
      BuildContext context, MenuItemMsk MenuItemMsk, Menu menuSis) {
    Icon _icon = MenuItemMsk.icone as Icon? ??
        MenuItemMsk.acao?.call(menuSis).icon as Icon? ??
        Icon(Icons.star);
    Icon icon = Icon(_icon.icon, color: Colors.white);
    return Card(
      color: MenuItemMsk.cor ?? UtilsColor.getRandomColor(), //Colors.grey[50],
      child: InkWell(
          onTap: () {
            onClickMenuItemMsk(context, MenuItemMsk, menuSis);
          },
          child: Container(
            width: 118,
            height: 118,
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  icon,
                  SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        menuSis.nome ?? MenuItemMsk.titulo ?? '',
                        style: TextStyle(fontSize: 13, color: Colors.white),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                ]),
          )),
    );
  }
}
