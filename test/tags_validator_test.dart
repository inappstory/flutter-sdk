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
        expect(tagsValidationError(['тег', '标签', 'ταμπέла', 'タグ_1']), isNull);
      });

      test('THEN a decomposed (NFD) accented letter returns null', () {
        // 'e' + U+0301 combining acute accent — the NFD form of 'é'.
        expect(tagsValidationError(['café']), isNull);
      });
    });

    group('WHEN the tag count is checked', () {
      test('THEN exactly $maxTagsCount tags is valid', () {
        final tags = List.generate(100, (i) => 'tag_$i');
        expect(tagsValidationError(tags), isNull);
      });

      test('THEN more than $maxTagsCount tags reports it', () {
        final tags = List.generate(101, (i) => 'tag_$i');
        expect(
          tagsValidationError(tags),
          'The list must not contain more than 100 tags.',
        );
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

    test('WHEN the tag count is over the limit THEN it returns an empty list',
        () {
      expect(sanitizeTags(List.generate(101, (i) => 'tag_$i')), isEmpty);
    });
  });

  group('GIVEN checkTags', () {
    test('WHEN the tags are valid THEN it returns true', () {
      expect(checkTags(['sport', 'news']), isTrue);
    });

    test('WHEN a tag is invalid THEN it returns false', () {
      expect(checkTags(['good', 'bad tag']), isFalse);
    });

    test('WHEN the tag count is over the limit THEN it returns false', () {
      expect(checkTags(List.generate(101, (i) => 'tag_$i')), isFalse);
    });
  });
}
