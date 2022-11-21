import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:msk/msk.dart';

class BotaoTemaWidget extends StatelessWidget {
  const BotaoTemaWidget();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Box>(
        future: hiveService.getBox('settings'),
        builder: (_, AsyncSnapshot<Box> value) {
          if (value.connectionState != ConnectionState.done) {
            return Center();
          }
          return ValueListenableBuilder(
              valueListenable: value.data!.listenable(),
              builder: (context, Box box, widget) {
                bool dark = box.get('dark_mode') ?? isDarkMode(context);
                return IconButton(
                    onPressed: () {
                      box.put('dark_mode', !dark);
                    },
                    icon: dark
                        ? Icon(Icons.wb_sunny)
                        : Icon(
                            Icons.brightness_2,
                            color: Colors.white,
                          ));
              });
        });
  }
}
