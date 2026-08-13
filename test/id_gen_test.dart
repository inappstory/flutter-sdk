import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/src/helpers/id_gen.dart';

void main() {
  group('GIVEN idGenerator', () {
    test('WHEN called THEN returns valid microsecond timestamp string', () {
      final id = idGenerator();
      final parsed = int.tryParse(id);
      expect(parsed, isNotNull);
      expect(parsed!, greaterThan(0));
    });
  });
}
