import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  final double height;
  final double width;
  final double sizeImage;
  final double widthButton;
  final double heightButton;
  final double fontSize;
  final double padding;
  final String title;
  final String image;
  const LoginPage(
      {Key? key,
      required this.height,
      required this.width,
      required this.sizeImage,
      required this.widthButton,
      required this.heightButton,
      required this.fontSize,
      required this.padding,
      required this.title,
      required this.image})
      : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) => Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  'images/gestao.png',
                ),
                fit: BoxFit.cover),
          ),
          child: SizedBox(
              height: widget.height,
              width: widget.width,
              child: Card(
                color: const Color.fromRGBO(255, 255, 255, 0.9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(widget.padding) * 0.5,
                ),
                child: Padding(
                  padding: EdgeInsets.all(widget.padding * 1.25),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: widget.padding * 1.5,
                        ),
                        child: SizedBox(
                          width: widget.sizeImage,
                          height: widget.sizeImage,
                          child: Image.asset(widget.image),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: widget.padding,
                        ),
                        child: Text(
                          widget.title,
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                                fontSize: widget.fontSize,
                                color: const Color.fromRGBO(31, 111, 150, 1),
                                letterSpacing: 1.5),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: widget.padding * 1.5,
                          vertical: widget.padding,
                        ),
                        child: TextFormField(
                          // focusNode: _userFocus,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color.fromRGBO(255, 255, 255, 0.8),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            labelText: 'Insira seu usuário',
                          ),
                          // controller: _controller.controllerUser,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (text) {
                            // _fieldFocusChange(context, _userFocus, _passFocus);
                          },
                        ),
                      ),
                      Observer(
                        builder: (_) => Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: widget.padding * 1.5,
                          ),
                          child: TextFormField(
                              // focusNode: _passFocus,
                              // obscureText: !_controller.exibirSenha,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor:
                                    const Color.fromRGBO(255, 255, 255, 0.8),
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                labelText: 'Insira sua senha',
                                focusColor: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    // _controller.exibirSenha =
                                    // !_controller.exibirSenha;
                                  },
                                  child: const Icon(
                                      // _controller.exibirSenha
                                      Icons.visibility
                                      // : Icons.visibility_off,
                                      ),
                                ),
                              ),
                              // controller: _controller.controllerPassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (term) {
                                // _passFocus.unfocus();
                                // _login(context);
                              }),
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(widget.padding * 0.75)),
                      Observer(builder: (_) => _botaoLogin(context)),
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }

  _botaoLogin(BuildContext context) {
    // if (!_controller.logando) {
    return ElevatedButton(
        style: ButtonStyle(
            minimumSize:
                MaterialStateProperty.all(Size(widget.widthButton, widget.heightButton)),
            backgroundColor: MaterialStateProperty.all(
              const Color.fromRGBO(31, 111, 150, 1),
            ),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.padding * 0.3)))),
        onPressed: () async {},
        child: Text(
          "ENTRAR",
          style: GoogleFonts.montserrat(
            textStyle: TextStyle(
              color: Colors.white,
              letterSpacing: 1,
              fontSize: widget.fontSize * 0.7,
            ),
          ),
        ));
    // } else {
    //   return CircularProgressIndicator();
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}
