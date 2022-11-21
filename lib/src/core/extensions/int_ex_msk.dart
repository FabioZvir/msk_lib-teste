import 'package:msk/msk.dart';

extension IntExMsk on int {
  /// Converte minutos em horas/minutos
  String toHourMinuteFromRawMinute() {
    String minutes = (this % 60).toString().addLeadingZerosLengthLessThan(2);
    return '${this ~/ 60}h:${minutes}';
  }
}
