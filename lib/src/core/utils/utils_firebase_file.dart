import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:msk/msk.dart';
import 'package:dio/dio.dart';

class UtilsFirebaseFile {
  static Future<String?> sendFile(File file, String serverPath) async {
    if (!app.firebaseIsInitialize!) {
      int sizeInBytes = file.lengthSync();
      double sizeInMb = sizeInBytes / (1024 * 1024);
      // Caso o arquivo seja menor que 10 MB, envia pela função do firebase
      // Caso contrário, envia pelo servidor
      if (sizeInMb < 10) {
        return uploadFileRaw(file, serverPath);
      }
      return uploadFileRawServer(file, serverPath);
    } else {
      return await _getUrlTask(file, serverPath);
    }
  }

  static Future<String?> uploadFileRawServer(
      File file, String serverPath) async {
    try {
      Response? response = await API.uploadFileUrl(
          'api/servicos/upload/arquivo',
          bytes: file.readAsBytesSync(),
          fileName: UtilsFileMSK.getFileName(file.path),
          fields: [MapEntry('storagePath', 'uploads/$serverPath')]);
      if (response.sucesso()) {
        return response!.data['urlFile'];
      }
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
    }
    return null;
  }

  static Future<String?> uploadFileRaw(File file, String storagePath) async {
    try {
      Dio dio = Dio(BaseOptions(
        baseUrl: 'https://us-central1-msk-01.cloudfunctions.net/',
      ));
      FormData formData =
          FormData.fromMap({"file": await MultipartFile.fromFile(file.path)});
      formData.fields.add(MapEntry('storagePath',
          '${!UtilsPlatform.isRelease ? 'Debug/' : ''}$storagePath'));
      Response response = await dio.post("uploadFile", data: formData);
      if (response.statusCode == 200) {
        return response.data['url'];
      }
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
    }
    return null;
  }

  static Future<String?> _getUrlTask(File file, String serverPath) async {
    UploadTask task =
        FirebaseStorage.instance.ref('uploads/$serverPath').putFile(file);

    task.snapshotEvents.listen((TaskSnapshot snapshot) {
      print('Task state: ${snapshot.state}');
      print(
          'Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
    }, onError: (error, stackTrace) {
      print(task.snapshot);
      if (error.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
      }
      UtilsSentry.reportError(error, stackTrace);
    });

    // We can still optionally use the Future alongside the stream.
    try {
      var res = await task;
      print('Upload complete.');
      return res.ref.getDownloadURL();
    } on FirebaseException catch (error, stackTrace) {
      if (error.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
      }
      UtilsSentry.reportError(error, stackTrace);
    }
    return null;
  }

  // static Future<String> sendFile(File file, String path) async {
  //   ConnectivityResult result;
  //   if (!UtilsPlatform.isWindows && !UtilsPlatform.isWeb) {
  //     result = await (Connectivity().checkConnectivity());
  //   }
  //   //caso seja null ou tenha conexao, faz a requisicao
  //   if (result != ConnectivityResult.none) {
  //     if (await file.exists()) {
  //       try {
  //         StorageUploadTask uploadTask = FirebaseStorage.instance
  //             .ref()
  //             .child('${UtilsPlatform.isDebug ? 'Debug/' : ''}$path')
  //             .putFile(file);
  //         var a = await uploadTask.onComplete;
  //         String url = await a.ref.getDownloadURL();
  //         return url;
  //       } catch (error, stackTrace) {
  //         UtilsSentry.reportError(error, stackTrace);
  //       }
  //     }
  //   }
  //   return null;
  // }

}
