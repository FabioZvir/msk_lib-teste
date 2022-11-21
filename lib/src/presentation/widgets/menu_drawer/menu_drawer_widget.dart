import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:msk/msk.dart';

class MenuDrawerWidget extends StatelessWidget {
  final List<MenuItemMsk> menus;
  final BuildContext baseContext;
  final ScrollController scrollController = ScrollController();

  MenuDrawerWidget(this.baseContext, this.menus);

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.escape): const DismissIntent(),
        },
        child: Actions(
            actions: <Type, Action<Intent>>{
              DismissIntent: CallbackAction<DismissIntent>(
                  onInvoke: (DismissIntent intent) {
                Navigator.pop(context);
                return;
              }),
            },
            child: Focus(
                autofocus: true,
                child: Drawer(
                  semanticLabel: 'Abrir menu',
                  child: Scrollbar(
                    controller: scrollController,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(
                                left: 16,
                                right: 16,
                                bottom: 16,
                                top: UtilsPlatform.isMobile ? 36 : 16),
                            color: Colors.black,
                            height: UtilsPlatform.isMobile ? 170 : 145,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: Image.asset(
                                          'imagens/icon_msk_inicio.png',
                                          package: 'msk',
                                          fit: BoxFit.fill,
                                          width: 80,
                                          height: 80),
                                    ),
                                    Row(
                                      children: [
                                        BotaoTemaWidget(),
                                        IconButton(
                                            onPressed: () async {
                                              await Navigation.push(context,
                                                  VersionScreenModule());
                                              Navigator.pop(context);
                                            },
                                            icon: Icon(Icons.system_update,
                                                color: Colors.white)),
                                        IconButton(
                                            onPressed: () async {
                                              await Navigation.push(
                                                  context, AvaliarAppModule());
                                              Navigator.pop(context);
                                            },
                                            icon: Icon(Icons.rate_review,
                                                color: Colors.white)),
                                      ],
                                    )
                                  ],
                                ),
                                SizedBox(height: 16),
                                Expanded(
                                  child: Text(
                                    authService.user?.nome ?? '',
                                    style: TextStyle(color: Colors.white),
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // new UserAccountsDrawerHeader(
                          //   accountName: new Text(
                          //     authService.user?.nome ?? '',
                          //     style: new TextStyle(color: Colors.white),
                          //   ),
                          //   accountEmail: SizedBox(),
                          //   currentAccountPicture: Hero(
                          //     tag: "imagem_perfil",
                          //     child: Image.asset('imagens/icon_msk_inicio.png',
                          //         package: 'msk', fit: BoxFit.fill),
                          //   ),
                          //   decoration: new BoxDecoration(color: Colors.black),
                          // ),
                          SizedBox(height: 8),
                          MenuWidget(menus, baseContext)
                        ],
                      ),
                    ),
                  ),
                ))));
  }
}

// const ScrollPhysics _bouncingPhysics =
//     BouncingScrollPhysics(parent: CustomScrollPhysics());
// const ScrollPhysics _clampingPhysics =
//     ClampingScrollPhysics(parent: RangeMaintainingScrollPhysics());

// /// The scroll physics to use for the platform given by [getPlatform].
// ///
// /// Defaults to [RangeMaintainingScrollPhysics] mixed with
// /// [BouncingScrollPhysics] on iOS and [ClampingScrollPhysics] on
// /// Android.
// ScrollPhysics getScrollPhysics() {
//   if (UtilsPlatform.isMacos || UtilsPlatform.isIOS) {
//     return _bouncingPhysics; //_bouncingPhysics;
//   } else {
//     return _clampingPhysics;
//   }
// }

// class CustomScrollPhysics extends RangeMaintainingScrollPhysics {
//   @override
//   double get minFlingVelocity => 1000;

//   @override
//   double get maxFlingVelocity => 1000;

//   @override
//   double get minFlingDistance => 100;

//   const CustomScrollPhysics();
// }
