import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:msk/msk.dart';

// ignore: must_be_immutable
class MenuWidget extends StatelessWidget {
  final MenuController menuController = AppBaseModule.to.bloc<MenuController>();

  final BuildContext context;
  final FocusNode focusNode = FocusNode();

  MenuWidget(List<MenuItemMsk> menus, this.context) {
    menuController.menusItem = menus;
    menuController.loadMenus();
  }

  @override
  Widget build(BuildContext context) {
    return _getMenu();
  }

  Widget _getMenu() {
    if (!menuController.menusItem.any((element) => element.titulo == 'Conta')) {
      menuController.menusItem.addAll(getMenusAuth(context));
    }
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: Container(
            height: 40,
            constraints: BoxConstraints(
                minWidth: 45, maxWidth: 500, minHeight: 45, maxHeight: 60),
            decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).cardColor
                    : Color(0xFFf5f5f5),
                borderRadius: BorderRadius.circular(20)),
            child: Container(
                padding:
                    EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 8),
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Tooltip(child: Icon(Icons.search), message: 'Pesquisar'),
                    SizedBox(width: 16),
                    Expanded(
                        child: TextField(
                      onChanged: (text) {
                        if (text.trim().toLowerCase() != menuController.text)
                          menuController.text = text.trim().toLowerCase();
                      },
                      controller: menuController.ctlSearch,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                          contentPadding: UtilsPlatform.isDesktop
                              ? EdgeInsets.symmetric(vertical: 13)
                              : EdgeInsets.symmetric(vertical: 10),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          hintText: 'Pesquise aqui'),
                      style: TextStyle(),
                    )),
                  ],
                )),
          ),
        ),
        Observer(
            builder: (_) => Column(
                children: _filtrarMenus(menuController.menusExibidos,
                    menuController.menusItem, context)))
      ],
    );
  }

  Widget _getHeader(String? title) {
    if (title == null) return Container();
    return Container(
        padding: EdgeInsets.only(left: 15, top: 10, bottom: 5),
        alignment: Alignment.centerLeft,
        child: Text(title.toUpperCase(),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)));
  }

  List<Widget> _filtrarMenus(
      Set<Menu> listMenus, List<MenuItemMsk> menusItem, BuildContext context) {
    List<Widget> menus = [];
    List<MenuItemMsk> _menusAdicionados = [];

    void _addMenu(MenuItemMsk menu, Menu menuSis, {bool allowFavorite = true}) {
      if (!_menusAdicionados
          .any((element) => element.codSistema == menu.codSistema)) {
        menus.add(
            _addItem(menu, menuSis, context, allowFavorite: allowFavorite));
        _menusAdicionados.add(menu);
      }
    }

    for (MenuItemMsk menu in menusItem) {
      if (menu.subMenus.isNotEmpty) {
        if (menu.subMenus.any((k) => listMenus
            .any((m) => k.exibirSempre || m.codSistema == k.codSistema))) {
          //existe pelo menos um item, entao retorna o cabeçalho
          menus.add(_getHeader(menu.titulo));
          for (MenuItemMsk subMenu in menu.subMenus) {
            if (subMenu.exibirSempre) {
              _addMenu(
                  subMenu,
                  Menu(
                      codSistema: subMenu.codSistema,
                      nome: subMenu.titulo,
                      favorito: false),
                  allowFavorite: false);
            } else {
              for (Menu menuSis in listMenus) {
                if (subMenu.codSistema == menuSis.codSistema) {
                  _addMenu(subMenu, menuSis);
                }
              }
            }
          }
          menus.add(Divider());
        }
      }
    }

    return menus;
  }

  Widget _addItem(MenuItemMsk subMenu, Menu menuSis, BuildContext context,
      {bool allowFavorite = true}) {
    Icon? _icon =
        subMenu.icone as Icon? ?? subMenu.acao?.call(menuSis).icon as Icon?;
    Icon? icon = _icon != null ? Icon(_icon.icon, color: Colors.grey) : null;
    return ListTile(
      leading: icon,
      title: Text(menuSis.nome ?? subMenu.titulo ?? ''),
      trailing: allowFavorite && UtilsPlatform.isDesktop
          ? IconButton(
              onPressed: () {
                favoritarMenu(context, menuSis);
              },
              icon: Observer(
                  builder: (_) => menuSis.favorito == true
                      ? Icon(Icons.star, size: 18)
                      : Icon(Icons.star_border, size: 18)))
          : menuSis.favorito == true
              ? Icon(Icons.star, size: 18)
              : null,
      onTap: () async {
        menuController.ctlSearch.clear();
        menuController.text = '';
        focusNode.unfocus();
        onClickMenuItemMsk(context, subMenu, menuSis);
      },
      onLongPress: allowFavorite
          ? () async {
              favoritarMenu(context, menuSis);
            }
          : null,
    );
  }

  void favoritarMenu(BuildContext context, Menu menuSis) async {
    Navigator.pop(context);
    bool success = await menuController.favoritarMenu(menuSis);
    if (!success) {
      showSnack(context,
          'Ops, houve uma falha ao ${menuSis.favorito == true ? '' : 'des'}favoritar o menu');
    } else {
      bool success2 = await menuController.favoritarMenuServidor(menuSis);
      if (!success2) {
        showSnack(context,
            'Ops, houve uma falha ao salvar a mudança de favorito do menu no servidor');
      } else {
        showSnack(context,
            'Menu ${menuSis.favorito == true ? '' : 'des'}favoritado com sucesso');
      }
    }
  }
}

Future<void> onClickMenuItemMsk(
    BuildContext context, MenuItemMsk MenuItemMsk, Menu menuSis) async {
  if (MenuItemMsk.acao != null) {
    ActionSelect action = MenuItemMsk.acao!(menuSis);

    if (action.route != null || action.page != null) {
      /// Verifica se não precisa fazer login
      if (authService.user != null) {
        /// Não deixa usar caso não tenha feito nenhuma sync completa ainda
        bool jaSincronizou = await Sync.jaSincronizou();
        if (MenuItemMsk.precisaSync == true && jaSincronizou == false) {
          Navigator.pop(context);
          showSnack(context,
              'Você precisa esperar a sync finalizar para poder acessar algum cadastro. Você pode acompanhar o progresso dela na barra de notificações',
              duration: Duration(seconds: 5));
        } else {
          //FocusScope.of(this.context).unfocus();

          if (MenuItemMsk.executeSync == true) {
            MyPR dialog =
                await showProgressDialog(context, 'Sincronizando dados');
            await AtualizarDados().sincronizar();
            await dialog.hide();
          }
          Navigator.maybeOf(context)?.push(new MaterialPageRoute(
              builder: (action.route != null
                  ? action.route!
                  : (_) => action.page!()) as Widget Function(BuildContext)));
        }
      } else {
        Navigator.maybeOf(context)?.pushReplacement(new MaterialPageRoute(
            builder: (BuildContext context) => new LoginModule()));
      }
    }
    if (action.function != null) {
      action.function!(DataFunction(context: context));
    }
    if (action.functionUpd != null) {
      action.functionUpd!(DataFunction(context: context));
    }
  }
}

List<MenuItemMsk> getMenusAuth(BuildContext context) {
  List<MenuItemMsk> menus = [];
  if (app.menusDefault
      .any((element) => element.menu == MenusDefaultEnum.SAIR)) {
    MenusDefault menu = app.menusDefault
        .firstWhere((element) => element.menu == MenusDefaultEnum.SAIR);
    menus.add(MenuItemMsk(
        codSistema: menu.codMenu,
        icone: Icon(Icons.power_settings_new),
        titulo: 'Sair',
        exibirSempre: true,
        acao: (_) => ActionSelect(
            description: 'Sair',
            function: (DataFunction dataFunction) async {
              MyPR progressDialog =
                  await showProgressDialog(context, 'Saindo...');

              bool b = await authService.logOut();
              if (b) {
                await progressDialog.hide();
                Navigator.maybeOf(dataFunction.context!)?.pushReplacement(
                    new MaterialPageRoute(
                        builder: (BuildContext context) => new LoginModule()));
              } else {
                await progressDialog.hide();
                showSnack(context,
                    'Não foi possível sair da sua conta pois existem dados pendentes que não puderam ser exportados');
              }
            })));
  }
  return [MenuItemMsk(titulo: 'Conta', subMenus: menus)];
}
