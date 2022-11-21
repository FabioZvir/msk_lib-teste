import 'database_source.dart';

class FontDataDatabase extends DatabaseSource {
  FontDataDatabase(Query query,
      {String? id,
      bool allowExport = true,
      bool supportSingleLineFilter = true})
      : super(query,
            id: id,
            allowExport: allowExport,
            supportSingleLineFilter: supportSingleLineFilter);
}
