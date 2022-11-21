import 'package:flutter/foundation.dart' as Foundation;
import 'package:get_it/get_it.dart';
import 'package:msk/msk.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UtilsVersionMSK {
  static Future<Map> getDataVersion() async {
    int numVersion = await getNumVersion();
    if (UtilsPlatform.isAndroid) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return {
        'pacote': packageInfo.packageName,
        'numVersao': numVersion,
        'plataforma':
            Foundation.defaultTargetPlatform.toString().split('.').last
      };
    }

    return {
      'pacote': GetIt.I.get<App>().package,
      'numVersao': numVersion,
      'plataforma': Foundation.defaultTargetPlatform.toString().split('.').last
    };
  }

  static Future<int> getNumVersion() async {
    if (UtilsPlatform.isAndroid) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.buildNumber.toInt();
    }
    int numVersion;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (UtilsPlatform.isWindows) {
      numVersion = packageInfo.version.replaceAll('.', '').toDouble() ~/ 10;
    } else {
      numVersion = packageInfo.buildNumber.toInt();
    }
    return numVersion;
  }
}
