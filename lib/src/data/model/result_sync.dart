class ResultSync {
  bool? sucesso;
  int id;
  int? idServer;
  String? msg;
  List<ResultSync> listaRetorno;

  static ResultSync fromMap(Map<String, dynamic> map) {
    var l = (map.containsKey('listaRetorno') && map['listaRetorno'] != null)
        ? (map['listaRetorno'].map((i) => ResultSync.fromMap(i)).toList())
        : [];
    return ResultSync(map['sucesso'], int.parse(map['id']), map['idServer'],
        map['msg'], List<ResultSync>.from(l));
  }

  ResultSync(this.sucesso, this.id, this.idServer, this.msg, this.listaRetorno);

  @override
  String toString() {
    return 'ResultSync(sucesso: $sucesso, id: $id, idServer: $idServer, msg: $msg, listaRetorno: $listaRetorno)';
  }
}
