class UtilsCSV {
  static Future<String> generateCSVString(List list) async {
    StringBuffer csv = StringBuffer();
    if (list.isNotEmpty) {
      for (var key in list.first.keys) {
        csv.write(key.toString().trim());
        csv.write(';');
      }
      csv.write('\n');
      for (Map map in list) {
        csv.write(map.values.map((e) {
          if (e is String) {
            return e.replaceAll('\n', '');
          }
          return e;
        }).join(';'));
        csv.write('\n');
      }
    }
    return csv.toString();
  }

  static String replaceNoPrintable(String value, {String replaceWith = ' '}) {
    var charCodes = <int>[];

    for (final codeUnit in value.codeUnits) {
      if (isPrintable(codeUnit)) {
        charCodes.add(codeUnit);
      } else {
        if (replaceWith.isNotEmpty) {
          charCodes.add(replaceWith.codeUnits[0]);
        }
      }
    }

    return String.fromCharCodes(charCodes);
  }

  static bool isPrintable(int codeUnit) {
    return !(codeUnit < 33 || codeUnit >= 127);
  }
}
