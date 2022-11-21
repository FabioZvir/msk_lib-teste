class UtilsSelect {
  static Future<Map<String, dynamic>> convertValueCrud(obj, String key) async {
    if (obj is Map && obj[key] != null) {
      return obj[key]?.toMap();
    }
    return obj;
  }
}
