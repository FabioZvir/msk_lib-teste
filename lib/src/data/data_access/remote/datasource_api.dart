import 'package:dio/dio.dart';
import 'package:msk/msk.dart';

class DataSourceAPI extends DataSourceAny {
  String url;
  String? chave;
  bool Function(Map<String, dynamic> item)? removeWhere;

  DataSourceAPI(this.url,
      {this.chave, String? id, bool allowExport = true, this.removeWhere})
      : super(id: id, allowExport: allowExport);

  Future<List<Map<String, dynamic>>?> fetchData(
      int? limit, int offset, SelectModel? selectModel,
      {Map? data}) async {
    Response? response = await API.post(url, data: data, retornarFalhas: true);
    if (response != null) {
      List<Map<String, dynamic>> tempList;
      if (chave != null) {
        tempList = List<Map<String, dynamic>>.from(response.data[chave]);
      } else {
        tempList = List<Map<String, dynamic>>.from(response.data);
      }
      if (removeWhere != null) {
        tempList.removeWhere((element) => removeWhere!(element));
      }
      listAll = tempList;
    }
    return listAll;
  }
}
