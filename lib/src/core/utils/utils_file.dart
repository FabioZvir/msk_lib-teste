import 'dart:io';

import 'package:msk_utils/msk_utils.dart';
import 'dart:io' as io;

import 'package:path_provider/path_provider.dart';

class UtilsFileMSK {
  static String? getFileName(String? path) {
    if (path == null) return path;
    if (UtilsPlatform.isWindows) {
      return path.split('\\').last;
    } else
      return path.split('/').last;
  }

  static Future<File?> downloadFile(String url, {String? fileName}) async {
    try {
      if (UtilsPlatform.isWeb) {
        // Não é necessario oferecer suporte por enquanto
        // html.AnchorElement anchorElement = new html.AnchorElement(href: url);
        // anchorElement.download = url;
        // anchorElement.click();
      } else {
        String diretorio;
        if (UtilsPlatform.isDesktop) {
          diretorio = '${io.Directory.current.path}/Files';
        } else {
          diretorio = (await getExternalStorageDirectory())!.absolute.path;
        }
        io.File file =
            io.File('$diretorio/${DateTime.now().millisecondsSinceEpoch}');
        if ((await file.exists()) == false) {
          // caso o arquivo ainda não exista
          io.HttpClient client = io.HttpClient();
          io.HttpClientRequest request = await client.getUrl(Uri.parse(url));
          io.HttpClientResponse response = await request.close();
          if (response.statusCode < 400) {
            io.Directory dir = io.Directory('$diretorio');
            if ((await dir.exists()) == false) {
              dir = await dir.create(recursive: true);
            }
            file = io.File(
                '${dir.path}/${fileName ?? DateTime.now().millisecondsSinceEpoch}');
            if ((await file.exists()) == false) {
              file = await file.create(recursive: true);
            }
            await response.pipe(file.openWrite());
            if (UtilsPlatform.isWindows) {
              await UtilsPlatform.openProcess('explorer.exe',
                  args: ['${dir.path}']);
            } else if (Platform.isMacOS) {
              await UtilsPlatform.openProcess('open', args: ['${dir.path}']);
            }
            return file;
          }
        } else {
          return file;
        }
      }
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
    }
    return null;
  }

  /// Retorna path do arquivo baixado cuja Url é informada como parâmetro.
  ///
  /// Obs: utilizar função somente para o windows.
  /// Retorna null caso o processo tenha falhado, se não retorna o path literal.
  static Future<String?> downloadFileWithPath(String url,
      {String? fileName}) async {
    try {
      // Apenas para desktop.
      String diretorio;
      diretorio = '${io.Directory.current.path}/Files';

      io.File file = io.File(
          '$diretorio/${fileName ?? DateTime.now().millisecondsSinceEpoch}');

      io.HttpClient client = io.HttpClient();
      io.HttpClientRequest request = await client.getUrl(Uri.parse(url));
      io.HttpClientResponse response = await request.close();
      if (response.statusCode < 400) {
        io.Directory dir = io.Directory('$diretorio');
        if ((await dir.exists()) == false) {
          dir = await dir.create(recursive: true);
        }
        file = io.File(
            '${dir.path}/${fileName ?? DateTime.now().millisecondsSinceEpoch}');
        if ((await file.exists()) == false) {
          file = await file.create(recursive: true);
        }
        await response.pipe(file.openWrite());

        return file.path;
      }
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
    }
    return null;
  }

  static deleteTempFilesAndroid() async {
    try {
      getExternalStorageDirectory().then((value) {
        if (value != null) {
          UtilsFileMSK.checkAndDeleteOldFiles(value.path);
        }
      });
      getTemporaryDirectory().then((value) {
        UtilsFileMSK.checkAndDeleteOldFiles(value.path);
      });
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
    }
  }

  static checkAndDeleteOldFiles(String dir, {bool recursive = true}) async {
    Directory directory = Directory(dir);
    DateTime dateTime = DateTime.now().subtract(Duration(days: 30));
    for (var file in directory.listSync(recursive: recursive)) {
      if (file is File) {
        final stat = FileStat.statSync(file.path);
        if (stat.accessed.isBefore(dateTime)) {
          print('Deletar ${DateTime.now().difference(stat.accessed).inDays}');
          file.delete();
        }
      }
    }
  }
}
