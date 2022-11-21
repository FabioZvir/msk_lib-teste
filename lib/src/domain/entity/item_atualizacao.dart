class ItemAtualizacao {
  String nomeVersao;
  int numVersao;
  bool obrigatorio;
  String? windowsUrl;
  ItemAtualizacao({
    required this.nomeVersao,
    required this.numVersao,
    required this.obrigatorio,
    this.windowsUrl,
  });

  factory ItemAtualizacao.fromJson(Map<String, dynamic> map) {
    return ItemAtualizacao(
        nomeVersao: map['nomeVersao'],
        numVersao: map['numVersao'],
        obrigatorio: map['obrigatorio'],
        windowsUrl: map['windowsUrl']);
  }
}
