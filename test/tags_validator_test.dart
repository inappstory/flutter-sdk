import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/src/helpers/tags_validator.dart';

void main() {
  group('GIVEN tagsValidationError', () {
    group('WHEN the tags are valid', () {
      test('THEN an empty list returns null', () {
        expect(tagsValidationError(<String>[]), isNull);
      });

      test('THEN latin, digits, hyphen and underscore return null', () {
        expect(
          tagsValidationError(['tag1', 'my-tag', 'my_tag', '2024']),
          isNull,
        );
      });

      test('THEN non-latin letters return null', () {
        expect(tagsValidationError(['тег', '标签', 'ταμπέλα', 'タグ_1']), isNull);
      });

      test('THEN a decomposed (NFD) accented letter returns null', () {
        // 'e' + U+0301 combining acute accent — the NFD form of 'é'.
        expect(tagsValidationError(['café']), isNull);
      });
    });

    group('WHEN the total UTF-8 size is checked', () {
      test('THEN exactly $maxTagsSizeInBytes bytes (commas included) is valid',
          () {
        // Tags are joined by ',' before sizing: 17 cyrillic tags of 120 chars
        // = 17 * 120 * 2 = 4080 bytes, plus 16 separating commas = 4096.
        final tags = List.filled(17, 'я' * 120);

        expect(utf8.encode(tags.join(',')).length, maxTagsSizeInBytes);
        expect(tagsValidationError(tags), isNull);
      });

      test('THEN the separating commas count towards the limit', () {
        // 8 tags of 256 cyrillic chars = 4096 bytes on their own, but the 7
        // joining commas push the sent string to 4103 bytes.
        final tags = List.filled(8, 'я' * 256);

        expect(
          tags.fold<int>(0, (sum, t) => sum + utf8.encode(t).length),
          maxTagsSizeInBytes,
        );
        expect(tagsValidationError(tags), isNotNull);
      });

      test('THEN cyrillic over the limit reports the byte count', () {
        // 2049 cyrillic chars = 4098 bytes, but only 2049 code units.
        final tags = ['я' * (maxTagsSizeInBytes ~/ 2 + 1)];

        expect(tagsValidationError(tags), contains('4098 bytes'));
      });

      test('THEN the limit is summed across all tags', () {
        // Each tag is 3 bytes per char (CJK); 4 x 342 chars = 4104 bytes.
        final tags = List.filled(4, '标' * 342);

        expect(tagsValidationError(tags), isNotNull);
      });

      test(
          'THEN a tag under the limit by character count but over by bytes '
          'is invalid', () {
        // 1500 chars, 4 bytes each = 6000 bytes.
        final tags = ['𝕒' * 1500];

        expect(tagsValidationError(tags), isNotNull);
      });
    });

    group('WHEN a tag contains a forbidden character', () {
      test('THEN a space names the tag and the character', () {
        final error = tagsValidationError(['good', 'bad tag']);

        expect(error, contains('"bad tag"'));
        expect(error, contains('U+0020'));
      });

      test('THEN punctuation is invalid', () {
        for (final tag in ['a.b', 'a,b', 'a!b', 'a:b', 'a/b', 'тег?']) {
          expect(tagsValidationError([tag]), isNotNull, reason: tag);
        }
      });

      test('THEN an emoji is invalid', () {
        expect(tagsValidationError(['tag🎉']), isNotNull);
      });

      test('THEN an empty tag reports it', () {
        expect(tagsValidationError(['ok', '']), contains('empty'));
      });
    });
  });

  group('GIVEN sanitizeTags', () {
    test('WHEN the tags are valid THEN it returns them unchanged', () {
      expect(sanitizeTags(['sport', 'news']), ['sport', 'news']);
    });

    test('WHEN a tag is invalid THEN it returns an empty list', () {
      expect(sanitizeTags(['good', 'bad tag']), isEmpty);
    });

    test('WHEN the total size is over the limit THEN it returns an empty list',
        () {
      expect(sanitizeTags(['я' * (maxTagsSizeInBytes ~/ 2 + 1)]), isEmpty);
    });
  });

  group('GIVEN checkTags', () {
    test('WHEN the tags are valid THEN it returns true', () {
      expect(checkTags(['sport', 'news']), isTrue);
    });

    test('WHEN a tag is invalid THEN it returns false', () {
      expect(checkTags(['good', 'bad tag']), isFalse);
    });
  });
}
