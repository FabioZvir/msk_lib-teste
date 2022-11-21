import 'package:url_launcher/url_launcher.dart';

class UtilsMaps {
  static Future<bool> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      return launch(googleUrl);
    }  
    return false;
  }
}
