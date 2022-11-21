import 'dart:convert';

class TableRows {
  String listName;
  Set<int> ids;

  /// Caso não seja null, caso retorne todos os dados solicitados, atualiza a version
  String? version;
  TableRows({required this.listName, required this.ids, this.version});

  TableRows copyWith({
    String? name,
    Set<int>? ids,
  }) {
    return TableRows(
      listName: name ?? this.listName,
      ids: ids ?? this.ids,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': listName,
      'ids': ids.toList(),
    };
  }

  factory TableRows.fromMap(Map<String, dynamic> map) {
    return TableRows(
      listName: map['nome'] ?? '',
      ids: Set<int>.from(map['ids']),
    );
  }

  String toJson() => json.encode(toMap());

  factory TableRows.fromJson(String source) =>
      TableRows.fromMap(json.decode(source));

  @override
  String toString() => 'RowVersion(name: $listName, ids: $ids)';

  @override
  int get hashCode => listName.hashCode ^ ids.hashCode;
}
