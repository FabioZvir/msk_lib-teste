import 'package:sqfentity_gen/sqfentity_gen.dart';

class TableEntityBase<T extends TableBase> {
  final T model;

  const TableEntityBase({
    required this.model,
  });
}
