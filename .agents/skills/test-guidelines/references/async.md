# Async Tests

The full guidance behind the one-line summary in [SKILL.md](../SKILL.md).

- Return the `Future` or mark the test callback `async`. Never fire-and-forget.
- Use `expectLater` with stream matchers (`emitsInOrder`, `emitsError`) for `Stream` assertions.
- Use `fake_async` for timer, microtask, and timeout-dependent code — the load-timeout grace period in `FeedStoriesStream` is the canonical case here.

```dart
// GOOD: async test, awaited future
test('THEN the bound list reloads', () async {
  await controller.fetchFeedStories();
  expect(reloaded, ['first']);
});

// GOOD: fake_async for a timeout that must fire without a real wait
test('THEN a timeout failure surfaces once the grace period passes', () {
  fakeAsync((async) {
    stream.startLoad();            // arms the grace-period timer
    async.elapse(const Duration(seconds: 5));
    expect(loadErrors, isNotEmpty);
  });
});

// GOOD: a reply before the deadline cancels the timeout
test('THEN a reply before the grace period cancels the timeout', () {
  fakeAsync((async) {
    stream.startLoad();
    stream.updateStoriesData([_storyDto(1)]);  // reply arrives
    async.elapse(const Duration(seconds: 5));
    expect(loadErrors, isEmpty);
  });
});

// AVOID: fire-and-forget future
test('THEN the list reloads', () {
  controller.fetchFeedStories(); // missing await!
  expect(reloaded, ['first']);
});
```

Notes:
- Inside `fakeAsync`, drain pending microtasks with `async.flushMicrotasks()` before asserting if the code under test chains `Future`s.
- Don't mix a real `await` with `fakeAsync` in the same test — pick one clock.
