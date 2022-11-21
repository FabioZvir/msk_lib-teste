import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:msk/msk.dart';

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus
      };

/*
  @override
  GestureVelocityTrackerBuilder velocityTrackerBuilder(BuildContext context) {
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return (PointerEvent event) =>
            IOSScrollViewFlingVelocityTracker(event.kind);
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return (PointerEvent event) =>
            IOSScrollViewFlingVelocityTracker(event.kind);
      default:
        return (PointerEvent event) =>
            IOSScrollViewFlingVelocityTracker(event.kind);
    }
  }*/
}

class AppBaseWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UtilsSentry.init(
        'https://227c56fb3051498ab8894851dec2f9ca@o1192381.ingest.sentry.io/6313958',
        GetIt.I.get<App>().package,
        null);
    hiveService.init();
    UtilsFirebaseMessaging().init();
    return FutureBuilder<Box>(
        future: GetIt.I.get<AppBaseController>().future,
        builder: (_, AsyncSnapshot<Box> value) {
          if (value.connectionState != ConnectionState.done) {
            return Center();
          }
          return ValueListenableBuilder(
              valueListenable: value.data!.listenable(),
              builder: (context, Box box, widget) {
                /// Pode ser null
                bool? dark = box.get('dark_mode');
                return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    scrollBehavior: MyCustomScrollBehavior(),
                    navigatorKey: GetIt.I.get<App>().navigatorKey,
                    shortcuts: WidgetsApp.defaultShortcuts,
                    actions: WidgetsApp.defaultActions
                      ..addAll({
                        DismissIntent: CallbackAction<DismissIntent>(
                            onInvoke: (DismissIntent intent) {
                          Navigator.pop(context);
                          return;
                        }),
                      }),
                    title: 'Aynova',
                    theme: GetIt.I.get<App>().theme ?? Tema.getTema(context),
                    darkTheme: GetIt.I.get<App>().theme ??
                        Tema.getTema(context, darkMode: true),
                    themeMode: dark != null
                        ? (dark ? ThemeMode.dark : ThemeMode.light)
                        : ThemeMode.system,
                    home: LoginModule(),
                    localizationsDelegates: [
                      GlobalMaterialLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                    ],
                    supportedLocales: [
                      const Locale('en'),
                      const Locale('pt', 'BR'),
                    ]);
              });
        });
  }
}
