import 'dart:io';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:msk/msk.dart';

class API {
  /// Indica que o token teve um 401,
  /// Não realiza mais requisições ao servidor até ele ser renovado
  static bool invalidToken = false;

  static Future<Response<T>?> post<T>(String? endPoint,
      {Map? data,
      List<Map?>? dataList,
      UserTokenInterface? userToken,
      String baseUrl = Constants.BASE_URL,
      bool retornarFalhas = false,

      /// Indica que solicitação é uma tentativa nova
      bool isRetrying = false,
      ResponseType responseType = ResponseType.json,
      int? timeout}) async {
    if (invalidToken) {
      return null;
    }
    ConnectivityResult result = await (Connectivity().checkConnectivity());
    try {
      //caso seja null ou tenha conexao, faz a requisicao
      if (result != ConnectivityResult.none || UtilsPlatform.isMacos) {
        return await _post<T>(baseUrl, endPoint!,
            data: data,
            dataList: dataList,
            userToken: userToken,
            isRetrying: isRetrying,
            responseType: responseType,
            timeout: timeout);
      } else
        return null;
    } catch (error, stackTrace) {
      // caso retorne não autorizado, tenta obter um refresh token novo
      if (error is DioError && (error).response?.statusCode == 401) {
        if (!isRetrying) {
          // tenta fazer nova solitação
          return post<T>(endPoint!,
              baseUrl: baseUrl,
              retornarFalhas: retornarFalhas,
              data: data,
              dataList: dataList,
              isRetrying: true,
              responseType: responseType,
              timeout: timeout);
        } else {
          invalidToken = true;
        }
      } else if (error is DioError &&
          error.error is SocketException &&
          result == ConnectivityResult.wifi &&
          baseUrl != Constants.BASE_URL_INTERNO) {
        return await post<T>(endPoint,
            data: data,
            dataList: dataList,
            userToken: userToken,
            baseUrl: Constants.BASE_URL_INTERNO,
            responseType: responseType,
            timeout: timeout);
      } else {
        if ((error is DioError) && error.response?.statusCode == 400) {
          await UtilsLog.saveLog(
              UtilsLog.REGISTRO_ATIVIDADE_ERRO_RESPOSTA_SERVIDOR,
              // ignore: unnecessary_type_check
              'ERROR: ${error.response.toString()} - ${error.response?.data}\nSTACKTRACE: ${stackTrace.toString()}\nDATA: ${data ?? dataList}\nENDPOINT: ${endPoint}',
              '');
          UtilsSentry.reportError(error, stackTrace, data: data ?? dataList);
        }
      }
      if (retornarFalhas == true) {
        rethrow;
      } else {
        return null;
      }
    }
  }

  static Future<Response<T>?> _post<T>(String baseUrl, String endPoint,
      {Map? data,
      List<Map?>? dataList,
      UserTokenInterface? userToken,
      bool isRetrying = false,
      required ResponseType responseType,
      int? timeout}) async {
    final Dio dio = Dio();
    dio.options.baseUrl = baseUrl + getPorta();
    var options = Options();
    options.responseType = responseType;
    options.sendTimeout = timeout;

    dio.interceptors.add(CustomInterceptors());
    if (userToken != null) {
      options.headers = {"Authorization": "Bearer ${userToken.accessToken}"};
    } else {
      String? token = await authService.getToken(forceRefresh: isRetrying);
      if (token == null) {
        /// Não marca o token como inválido, isso é responsabilidade da auth
        /// Que identifica corretamente quando o token retornou null por estar expirado
        /// E sem conexão para renovar ou ele recebeu um 401
        return null;
      }
      options.headers = {"Authorization": 'Bearer $token'};
    }
    return dio.post<T>(endPoint, data: data ?? dataList, options: options);
  }

  static Future<bool> isConnected() async {
    ConnectivityResult result = await Connectivity().checkConnectivity();
    try {
      return result != ConnectivityResult.none || UtilsPlatform.isMacos;
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
    }
    return false;
  }

  static Future<Response?> uploadFileUrl(
    String endPoint, {
    Uint8List? bytes,
    String? fileName,
    MediaType? mediaType,
    List<MapEntry<String, String>> fields = const [],
  }) async {
    try {
      Dio dio = Dio(BaseOptions(
          baseUrl: Constants.BASE_URL + getPorta(),
          headers: {
            'Authorization': 'Bearer ${await authService.getToken()}'
          }));
      FormData formData = bytes != null
          ? FormData.fromMap({
              "file": MultipartFile.fromBytes(bytes,
                  filename: fileName, contentType: mediaType),
            })
          : FormData.fromMap({});
      formData.fields.addAll(fields);
      return dio.post(endPoint, data: formData);
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
    }
    return null;
  }
}

isSucesso(int? code) {
  return code == 200 || code == 204;
}

String getPorta() {
  if (UtilsPlatform.isRelease) {
    return GetIt.I.get<App>().portas.release;
  } else
    return GetIt.I.get<App>().portas.debug;
}

extension Network on Response? {
  bool sucesso() {
    return (this != null && isSucesso(this!.statusCode) && this!.data != null);
  }
}
