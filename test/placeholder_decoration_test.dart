import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/src/data/placeholder_decoration.dart';

void main() {
  group('$PlaceholderDecoration', () {
    group('WHEN toDto called with null values', () {
      test('THEN color and image stay null', () {
        const decoration = PlaceholderDecoration();
        final dto = decoration.toDto();

        expect(dto.color, isNull);
        expect(dto.image, isNull);
      });
    });

    group('WHEN toDto called with color and image', () {
      test('THEN color is converted to ARGB32 and image is preserved', () {
        const decoration = PlaceholderDecoration(
          color: Color(0xFFFF0000),
          image: 'assets/loader.png',
        );
        final dto = decoration.toDto();

        expect(dto.color, 0xFFFF0000);
        expect(dto.image, 'assets/loader.png');
      });
    });

    group('WHEN comparing two instances', () {
      test('THEN equality and hashCode match by values', () {
        const dec1 = PlaceholderDecoration(
          color: Color(0xFF112233),
          image: 'assets/test.png',
        );
        const dec2 = PlaceholderDecoration(
          color: Color(0xFF112233),
          image: 'assets/test.png',
        );
        const dec3 = PlaceholderDecoration(
          color: Color(0xFF445566),
          image: 'assets/test.png',
        );

        expect(dec1, equals(dec2));
        expect(dec1.hashCode, equals(dec2.hashCode));
        expect(dec1, isNot(equals(dec3)));
      });
    });
  });
}
