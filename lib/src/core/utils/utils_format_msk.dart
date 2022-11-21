import 'package:flutter/services.dart';
import 'package:msk_utils/msk_utils.dart';

class MaxLengthFormatter extends TextInputFormatter {
  final int maxLength;
  MaxLengthFormatter(this.maxLength);
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > maxLength) {
      return oldValue;
    }
    return newValue;
  }
}

class UppCaseFormatter extends TextInputFormatter {
  UppCaseFormatter();
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
        text: newValue.text.toUpperCase(),
        selection: newValue.selection,
        composing: newValue.composing);
  }
}

class PlacaMercosulFormatter extends TextInputFormatter {
  PlacaMercosulFormatter();
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > 4) {
      return oldValue;
    }
    if (newValue.text.isNullOrBlank) return newValue;
    String last = newValue.text[newValue.text.length - 1];
    if (!RegExp(r'[0-9a-zA-Z]').hasMatch(last)) {
      return oldValue;
    }
    if (newValue.text.length == 1) {
      if (newValue.text.toDoubleOrNull() == null) {
        return oldValue;
      } else
        return newValue;
    } else if (newValue.text.length > 2) {
      if (last.toDoubleOrNull() == null) {
        return oldValue;
      } else
        return newValue;
    }

    return TextEditingValue(
        text: newValue.text.toUpperCase(),
        selection: newValue.selection,
        composing: newValue.composing);
  }
}
