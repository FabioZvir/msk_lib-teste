class RequestLogin {
  String? acessoUsu;
  String? senhaUsu;
  String? idDevice;
  String? token;
  int? propriedade;
  String? app;

  Map<String, dynamic> toMap(RequestLogin request) {
    Map<String, dynamic> map = Map();
    map['acessoUsu'] = request.acessoUsu;
    map['senhaUsu'] = request.senhaUsu;
    map['idDevice'] = request.idDevice;
    map['token'] = request.token;
    map['propriedade'] = request.propriedade;
    map['app'] = request.app;

    return map;
  }
}
