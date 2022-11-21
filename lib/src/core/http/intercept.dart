import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:msk/msk.dart';

class CustomInterceptors extends InterceptorsWrapper {
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      UtilsLog.saveLog(
          UtilsLog.REGISTRO_ATIVIDADE_401,
          '401: token: ${authService.token.toString()} - Momento da requisição: ${DateTime.now().string('yyyy-MM-dd HH:mm:ss:sss')}, EndPoint: ${err.requestOptions.path}',
          '');
    }
    try {
      debugPrint("JSON: ${json.encode(err.requestOptions.data)}");
      debugPrint("RETURN: ${err.response?.data}");
    } catch (_) {}
    super.onError(err, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
        "RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}");
    super.onResponse(response, handler);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint("REQUEST[${options.method}] => PATH: ${options.path}");
    super.onRequest(options, handler);
  }
}
