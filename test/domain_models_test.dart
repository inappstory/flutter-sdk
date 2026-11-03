import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import 'package:inappstory_plugin/src/generated/pigeon_generated.g.dart';

void main() {
  group('StoryType', () {
    test('GIVEN StoryTypeDto WHEN fromDto THEN maps correctly', () {
      expect(StoryType.fromDto(StoryTypeDto.common), StoryType.common);
      expect(StoryType.fromDto(StoryTypeDto.ugc), StoryType.ugc);
      expect(StoryType.fromDto(StoryTypeDto.iam), StoryType.iam);
      expect(StoryType.fromDto(StoryTypeDto.banner), StoryType.banner);
    });

    test('GIVEN StoryType WHEN toDto THEN maps correctly', () {
      expect(StoryType.common.toDto(), StoryTypeDto.common);
      expect(StoryType.ugc.toDto(), StoryTypeDto.ugc);
      expect(StoryType.iam.toDto(), StoryTypeDto.iam);
      expect(StoryType.banner.toDto(), StoryTypeDto.banner);
    });
  });

  group('SourceType', () {
    test('GIVEN SourceTypeDto WHEN fromDto THEN maps correctly', () {
      expect(SourceType.fromDto(SourceTypeDto.single), SourceType.single);
      expect(SourceType.fromDto(SourceTypeDto.onboarding), SourceType.onboarding);
      expect(SourceType.fromDto(SourceTypeDto.list), SourceType.list);
      expect(SourceType.fromDto(SourceTypeDto.favorite), SourceType.favorite);
      expect(SourceType.fromDto(SourceTypeDto.stack), SourceType.stack);
      expect(SourceType.fromDto(SourceTypeDto.inAppMessage), SourceType.inAppMessage);
      expect(SourceType.fromDto(SourceTypeDto.banners), SourceType.banners);
    });

    test('GIVEN SourceType WHEN toDto THEN maps correctly', () {
      expect(SourceType.single.toDto(), SourceTypeDto.single);
      expect(SourceType.onboarding.toDto(), SourceTypeDto.onboarding);
      expect(SourceType.list.toDto(), SourceTypeDto.list);
      expect(SourceType.favorite.toDto(), SourceTypeDto.favorite);
      expect(SourceType.stack.toDto(), SourceTypeDto.stack);
      expect(SourceType.inAppMessage.toDto(), SourceTypeDto.inAppMessage);
      expect(SourceType.banners.toDto(), SourceTypeDto.banners);
    });
  });

  group('ClickAction', () {
    test('GIVEN ClickActionDto WHEN fromDto THEN maps correctly', () {
      expect(ClickAction.fromDto(ClickActionDto.button), ClickAction.button);
      expect(ClickAction.fromDto(ClickActionDto.swipe), ClickAction.swipe);
      expect(ClickAction.fromDto(ClickActionDto.game), ClickAction.game);
      expect(ClickAction.fromDto(ClickActionDto.deeplink), ClickAction.deeplink);
    });

    test('GIVEN ClickAction WHEN toDto THEN maps correctly', () {
      expect(ClickAction.button.toDto(), ClickActionDto.button);
      expect(ClickAction.swipe.toDto(), ClickActionDto.swipe);
      expect(ClickAction.game.toDto(), ClickActionDto.game);
      expect(ClickAction.deeplink.toDto(), ClickActionDto.deeplink);
    });
  });

  group('StoryData', () {
    test('GIVEN StoryDataDto WHEN fromDto THEN preserves all fields', () {
      final dto = StoryDataDto(
        id: 42,
        title: 'Title',
        tags: 'tag1,tag2',
        feed: 'default',
        sourceType: SourceTypeDto.list,
        slidesCount: 5,
        storyType: StoryTypeDto.common,
        extraFields: {'key': 'val'},
      );

      final data = StoryData.fromDto(dto);

      expect(data.id, 42);
      expect(data.title, 'Title');
      expect(data.tags, 'tag1,tag2');
      expect(data.feed, 'default');
      expect(data.sourceType, SourceType.list);
      expect(data.slidesCount, 5);
      expect(data.storyType, StoryType.common);
      expect(data.extraFields, {'key': 'val'});

      final backDto = data.toDto();
      expect(backDto.id, dto.id);
      expect(backDto.title, dto.title);
      expect(backDto.feed, dto.feed);
      expect(backDto.sourceType, dto.sourceType);
      expect(backDto.slidesCount, dto.slidesCount);
      expect(backDto.storyType, dto.storyType);
    });

    test('GIVEN two identical StoryData WHEN comparing THEN equal', () {
      const a = StoryData(id: 1, title: 'T', feed: 'F');
      const b = StoryData(id: 1, title: 'T', feed: 'F');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('SlideData', () {
    test('GIVEN SlideDataDto WHEN fromDto THEN maps correctly', () {
      final dto = SlideDataDto(
        story: StoryDataDto(
          id: 1,
          slidesCount: 3,
        ),
        index: 2,
        payload: 'pay',
      );

      final slide = SlideData.fromDto(dto);
      expect(slide.index, 2);
      expect(slide.payload, 'pay');
      expect(slide.story?.id, 1);

      final backDto = slide.toDto();
      expect(backDto.index, 2);
      expect(backDto.payload, 'pay');
      expect(backDto.story?.id, 1);
    });
  });

  group('ContentType & ContentData', () {
    test('GIVEN ContentTypeDto WHEN fromDto THEN maps correctly', () {
      expect(ContentType.fromDto(ContentTypeDto.story), ContentType.story);
      expect(ContentType.fromDto(ContentTypeDto.ugc), ContentType.ugc);
      expect(ContentType.fromDto(ContentTypeDto.inAppMessage), ContentType.inAppMessage);
    });

    test('GIVEN ContentDataDto WHEN fromDto THEN maps correctly', () {
      final dto = ContentDataDto(
        contentType: ContentTypeDto.story,
        sourceType: SourceTypeDto.single,
      );
      final data = ContentData.fromDto(dto);
      expect(data.contentType, ContentType.story);
      expect(data.sourceType, SourceType.single);

      final backDto = data.toDto();
      expect(backDto.contentType, ContentTypeDto.story);
      expect(backDto.sourceType, SourceTypeDto.single);
    });
  });

  group('InAppMessageType & InAppMessageData', () {
    test('GIVEN InAppMessageTypeDto WHEN fromDto THEN maps correctly', () {
      expect(InAppMessageType.fromDto(InAppMessageTypeDto.fullScreen), InAppMessageType.fullScreen);
      expect(InAppMessageType.fromDto(InAppMessageTypeDto.bottomSheet), InAppMessageType.bottomSheet);
      expect(InAppMessageType.fromDto(InAppMessageTypeDto.popUp), InAppMessageType.popUp);
      expect(InAppMessageType.fromDto(InAppMessageTypeDto.toast), InAppMessageType.toast);
      expect(InAppMessageType.fromDto(InAppMessageTypeDto.undefined), InAppMessageType.undefined);
    });

    test('GIVEN InAppMessageDataDto WHEN fromDto THEN maps correctly', () {
      final dto = InAppMessageDataDto(
        id: 10,
        title: 'Notice',
        event: 'onboarding_complete',
        messageType: InAppMessageTypeDto.bottomSheet,
        extraFields: {'promo': 'yes'},
      );

      final data = InAppMessageData.fromDto(dto);
      expect(data.id, 10);
      expect(data.title, 'Notice');
      expect(data.event, 'onboarding_complete');
      expect(data.messageType, InAppMessageType.bottomSheet);
      expect(data.extraFields, {'promo': 'yes'});

      final backDto = data.toDto();
      expect(backDto.id, 10);
      expect(backDto.title, 'Notice');
      expect(backDto.messageType, InAppMessageTypeDto.bottomSheet);
    });
  });
}
