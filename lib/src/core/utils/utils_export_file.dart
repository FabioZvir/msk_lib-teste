import 'dart:io';
import 'package:msk_utils/msk_utils.dart';
import 'package:path_provider/path_provider.dart';

class UtilsExportFile {
  static Future<String?> export(String content,
      {String? path, String? name}) async {
    if (UtilsPlatform.isWindows) {
      Directory dir = Directory('${Directory.current.path}\\${path ?? ''}');
      final File file = File(
          '${dir.absolute.path}\\${name ?? DateTime.now().string('yyyy-MM-dd_HH-mm')}.txt');
      if (!(await file.exists())) {
        await file.create(recursive: true);
      }
      await file.writeAsBytes(content.codeUnits);
      return file.absolute.path;
    } else {
      Directory? dir = Platform.isAndroid
          ? (await (getExternalStorageDirectory()))
          : (await getApplicationDocumentsDirectory());
      if (dir == null) {
        return null;
      }
      if (!(await dir.exists())) {
        await dir.create();
      }
      final File file = File(
          '${dir.absolute.path}/${name ?? DateTime.now().string('yyyy-MM-dd_HH-mm')}.txt');
      if (!(await file.exists())) {
        await file.create();
      }
      await file.writeAsBytes(content.codeUnits);
      return file.absolute.path;
    }
  }
}
