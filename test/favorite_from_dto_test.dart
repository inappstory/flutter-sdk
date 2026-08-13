import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/src/data/favorite_from_dto.dart';
import 'package:inappstory_plugin/src/generated/pigeon_generated.g.dart';

void main() {
  group('$FavoriteFromDto', () {
    late StoryFavoriteItemAPIDataDto dto;
    late FavoriteFromDto favorite;

    setUp(() {
      dto = StoryFavoriteItemAPIDataDto(
        id: 1,
        backgroundColor: '#FF0000',
      );
      favorite = FavoriteFromDto(dto);
    });

    group('WHEN compared for equality', () {
      test('THEN same dto.id are equal', () {
        final dto2 = StoryFavoriteItemAPIDataDto(
          id: 1,
          backgroundColor: '#00FF00',
        );
        final favorite2 = FavoriteFromDto(dto2);
        expect(favorite, equals(favorite2));
      });

      test('AND different dto.id are not equal', () {
        final dto2 = StoryFavoriteItemAPIDataDto(
          id: 2,
          backgroundColor: '#FF0000',
        );
        final favorite2 = FavoriteFromDto(dto2);
        expect(favorite, isNot(equals(favorite2)));
      });
    });

    group('WHEN getting properties', () {
      test('THEN hashCode returns 1', () {
        expect(favorite.hashCode, 1);
      });

      test('THEN id returns 1', () {
        expect(favorite.id, 1);
      });

      test('THEN backgroundColor delegates via colorFromString', () {
        expect(favorite.backgroundColor, equals(const Color(0xFFFF0000)));
      });
    });
  });
}
