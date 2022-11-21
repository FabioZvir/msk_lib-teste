import 'package:flutter_test/flutter_test.dart';
import 'package:msk/msk.dart';

void main() {
  test('Test generate uniqueKey', () {
    Set<int> list = Set();
    for (int i = 0; i < 10; i++) {
      UtilsDB.generateUniqueKey().then((value) {
        if (!list.add(value)) {
          throw Exception('Duplicate key');
        }
      });
    }
  });
}
