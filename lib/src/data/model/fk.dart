class FK {
  String coluna;
  String tabela;
  @deprecated
  bool? paiItem;

  /// Indica se a coluna é obrigatória para continuar a sync
  bool? obrigatoria;

  FK(this.coluna, this.tabela, {this.paiItem, this.obrigatoria})
      : assert(coluna[0] == coluna[0].toLowerCase(),
            'Column $coluna is not starting lowecase');
}
