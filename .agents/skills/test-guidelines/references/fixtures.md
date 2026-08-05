# Setup, Teardown & the Fixture Pattern

The full rules behind the one-line summary in [SKILL.md](../SKILL.md). These concern how a test assembles and resets its System Under Test (SUT).

## Default: `late` + `setUp` in the narrowest group

This project's tests build the SUT directly with `late` variables initialized in `setUp()`, inside the narrowest group that needs them. Fakes are plain capturing lists.

```dart
// GOOD: the current project style — late vars, setUp per scope
group('GIVEN a controller bound to a list', () {
  late FeedStoriesController controller;
  late List<String> reloaded;

  setUp(() {
    reloaded = <String>[];
    controller = FeedStoriesController()..attach(() async => reloaded.add('first'));
  });

  group('WHEN the widget is disposed', () {
    setUp(() => controller.detach(firstBinding)); // narrowest scope owns its setup
    test('THEN fetching reloads nothing', () async { /* ... */ });
  });
});
```

Rules:
- Place `setUp()` / `tearDown()` inside the narrowest group they apply to.
- Prefer `late` + `setUp()` over inline construction in each test.
- Use `setUpAll()` / `tearDownAll()` only for genuinely expensive shared resources — not for cheap objects (they leak state across tests).
- A nested `setUp()` runs *after* the enclosing one, so build on the parent's state rather than rebuilding it.

## When a `Fixture` class pays off

Reach for a `Fixture` class only when several tests need the **same SUT built with different knobs** — it removes duplicated wiring. Put it at the bottom of the file with a `getSut()` that takes the varying options as parameters.

```dart
// Worth it when getSut() is called with different args across many tests
class Fixture {
  final hostApi = MockIASStoryListHostApi();
  final loadErrors = <String?>[];

  FeedStoriesStream getSut({String feed = 'feedA'}) {
    return FeedStoriesStream(
      feed: feed,
      uniqueId: idGenerator(),
      storyWidgetBuilder: MockStoryWidgetBuilder(),
      onStoriesLoadError: loadErrors.add,
    );
  }
}

late Fixture fixture;
setUp(() => fixture = Fixture());
test('THEN failures of the abandoned feed are ignored', () {
  final sut = fixture.getSut(feed: 'feedA');
  // ...
});
```

Don't introduce a `Fixture` for a group whose SUT never varies — the plain `late` + `setUp` above is less ceremony. Match what neighboring test files already do.
