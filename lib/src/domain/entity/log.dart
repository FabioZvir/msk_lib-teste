class Logs {
  List<Log> logs = [];

  void add(Log? log) {
    if (log != null &&
        !logs.any((element) =>
            element.tabela == log.tabela &&
            element.tipo == log.tipo &&
            element.duplicar == false &&
            log.duplicar == false)) {
      logs.add(log);
    }
  }

  @override
  String toString() {
    StringBuffer buffer = StringBuffer();
    logs.forEach((element) {
      buffer.writeln(element.message);
    });
    return buffer.toString();
  }
}

class Log {
  String message;
  String? tabela;
  TiposLog tipo;
  bool duplicar;
  Log(this.message, this.tipo, {this.tabela, this.duplicar = true});
}

enum TiposLog {
  FALTA_COLUNA_SYNC,
  FALTA_COLUNA_BANCO,
  ID_SERVER_DUPLICADO,
  DADOS_DIFERENTE_ESPERADO,
  REGISTRO_AUSENTE,
  FALHA_REDE,
  FALHA_BANCO
}
