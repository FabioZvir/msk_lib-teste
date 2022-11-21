abstract class ColumnFile {
  String filePath;

  ColumnFile(this.filePath);
}

class ColumnFileFirebase extends ColumnFile {
  String url;
  PathFileFirebase pathFileFirebase;

  ColumnFileFirebase(String filePath, this.url, this.pathFileFirebase)
      : super(filePath);
}

class ColumnFileServer extends ColumnFile {
  String key;
  ColumnFileServer(String filePath, this.key) : super(filePath);
}

typedef PathFileFirebase = Future<String> Function(Map<String, dynamic>);
