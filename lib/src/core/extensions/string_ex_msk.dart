extension StringExMsk on String {
  String addZerosRight(int quantity) {
    String string = '';
    for (int i = 0; i < quantity; i++) {
      string += "0";
    }
    return this + string;
  }

  /// Add leading zeros if the string length is less than the indicated [length]
  String addRightZerosLengthLessThan(int length) {
    if (this.length >= length) {
      return this;
    }
    return this.addZerosRight(length - this.length);
  }
}
