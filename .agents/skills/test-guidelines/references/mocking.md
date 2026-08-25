# Mocking and Designing for Mockability

The full guidance behind the one-line summary in [SKILL.md](../SKILL.md). This project uses `mocktail`.

## Prefer fakes over mocks

- **Prefer hand-written fakes** that capture state — they're resilient to refactoring and read as documentation. The controller/stream tests use the simplest fake there is: a `List` the SUT appends to (`reloaded`, `loadErrors`).
- Reach for a `mocktail` mock only when faking a large interface isn't worth it — a real boundary like the pigeon `IASStoryListHostApi`, an `Observable`, or a `StoryWidgetBuilder`.
- Use doubles already defined in [test/mocks.dart](../../../../test/mocks.dart) rather than re-declaring them.

```dart
// GOOD: capturing fake — no verification ceremony, reads as documentation
final loadErrors = <String?>[];
final stream = FeedStoriesStream(feed: 'feedA', onStoriesLoadError: loadErrors.add, /* ... */);
stream.storiesUpdateFailure('feedA', 'boom');
expect(loadErrors, ['boom']);

// mocktail — only at a real boundary
class MockIASStoryListHostApi extends Mock implements IASStoryListHostApi {}
```

## mocktail specifics

- `mocktail` needs no code generation (unlike mockito) — just `extends Mock implements X`.
- Stub with `when(() => mock.foo()).thenAnswer((_) async => …)`; verify with `verify(() => mock.foo()).called(1)`. Note the `() =>` closure — mocktail wraps calls in a thunk.
- For any non-primitive argument used with an `any()` matcher, register a fallback once in `setUpAll`: `registerFallbackValue(FakeStory());`.
- Prefer asserting on captured state over `verify(...)` counts where a fake makes it possible — verification-heavy tests couple to call shape and break on refactors.

## Designing for mockability

A double can only be substituted at a seam the code exposes. If a test is hard to fake, the code under test is usually the problem — fix the design, not the test.

- **The code must accept its dependencies.** A class that receives its host API / builder / callback can be faked; one that constructs them internally cannot.

  ```dart
  // GOOD: injected → fake it
  FeedStoriesStream({required this.storyWidgetBuilder, required this.onStoriesLoadError});

  // HARD TO TEST: constructed internally
  FeedStoriesStream() : _host = IASStoryListHostApi(); // test can't replace it
  ```

- **Prefer specific per-operation methods over one generic call.** A double for `subscribe()` / `updateStoriesData()` returns one known shape; a double for a single generic `request(endpoint, args)` needs branching inside the fake to decide what to return.

- **Mock only at real boundaries** — the pigeon native interop, the clock (`DateTime.now()` in `id_gen.dart`), randomness, the filesystem. Don't fake your own in-process collaborators (`FeedStoriesController`, `FeedStoriesStream`) — test through them.
