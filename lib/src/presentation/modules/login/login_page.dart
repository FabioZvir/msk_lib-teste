import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msk/msk.dart';
import 'package:msk/src/presentation/modules/login/login_model.dart';

class LoginPage extends StatefulWidget {
  final String title;
  final String image;
  const LoginPage({
    Key? key,
    required this.title,
    required this.image,
  }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (((context, constraints) {
        final bool isMobile = constraints.maxWidth > 700;
        return isMobile
            ? LoginModel(
                height: 550,
                width: 500,
                sizeImage: 90,
                widthButton: 180,
                heightButton: 45,
                fontSize: 26,
                padding: 20,
                title: widget.title,
                image: widget.image,
              )
            : LoginModel(
                height: 400,
                width: 350,
                sizeImage: 65,
                widthButton: 130,
                heightButton: 35,
                fontSize: 18,
                padding: 13,
                title: widget.title,
                image: widget.image,
              );
      })),
    );
  }
}
