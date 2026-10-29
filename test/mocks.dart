import 'package:inappstory_plugin/inappstory_plugin.dart';
import 'package:inappstory_plugin/src/data/observable.dart';
import 'package:inappstory_plugin/src/generated/pigeon_generated.g.dart'
    show IASStoryListHostApi;
import 'package:mocktail/mocktail.dart';

class MockObservable<T> extends Mock implements Observable<T> {}

class MockStoryWidgetBuilder extends Mock {
  StoryWidget call(Story story, FeedStoryDecorator? decorator);
}

class MockIASStoryListHostApi extends Mock implements IASStoryListHostApi {}

class MockStoryDecorator extends Mock implements FeedStoryDecorator {}
