import 'dart:convert';

class ReturnRegister {
  int? action;
  dynamic data;
  ReturnRegister({
    this.action,
    this.data,
  });

  ReturnRegister copyWith({
    int? acao,
    dynamic dados,
  }) {
    return ReturnRegister(
      action: acao ?? this.action,
      data: dados ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'acao': action,
      'dados': data,
      'action': action,
      'data': data,
    };
  }

  static ReturnRegister? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;

    return ReturnRegister(
      action: map['acao'] ?? map['action'],
      data: map['dados'] ?? map['data'],
    );
  }

  String toJson() => json.encode(toMap());

  static ReturnRegister? fromJson(String source) =>
      fromMap(json.decode(source));

  @override
  String toString() => 'RetornoCadastro(acao: $action, dados: $data)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ReturnRegister && o.action == action && o.data == data;
  }

  @override
  int get hashCode => action.hashCode ^ data.hashCode;
}
