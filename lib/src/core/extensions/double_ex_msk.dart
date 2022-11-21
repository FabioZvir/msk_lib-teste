import 'package:msk/msk.dart';

extension DoubleExMsk on double {
  String toHourMinute() {
    List<String> split = this.toString().split('.');

    String minutes = (split.last.toDouble() * .60)
        .toInt()
        .toString()
        .addRightZerosLengthLessThan(2);
    return '${split.first}h:${minutes}';
  }
}
