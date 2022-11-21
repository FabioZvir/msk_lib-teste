class ValidationDuplicate {
  final String field;
  final dynamic value;
  final bool applyLowerCase;

  ValidationDuplicate(this.field, this.value, {this.applyLowerCase = true});
}

class ModelValidationDuplicate {
  List<ValidationDuplicate> fields;
  String table;
  String message;
  int? id;
  ModelValidationDuplicate(
      {required this.fields,
      required this.message,
      required this.table,
      this.id})
      : assert(fields.isNotEmpty);
}
