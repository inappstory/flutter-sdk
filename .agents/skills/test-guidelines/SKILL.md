---
name: test-guidelines
description: Test conventions for the inappstory_plugin Flutter plugin — GIVEN/WHEN/THEN naming, structure, mocktail doubles, fake_async. Use when writing, adding, modifying, or reviewing tests, fixing failing tests, adding coverage, TDD / red-green, reproducing bugs with tests, regression tests, or test refactoring.
---

Apply these conventions to new and modified tests. Existing tests may not follow them — do not refactor unless asked.

Dart `>=3.0.0`, Flutter `>=3.3.0`. Use `flutter test` to run. Doubles use `mocktail`; timing tests use `fake_async`. This is a single-package plugin with pigeon-generated native interop (`lib/src/generated/*.g.dart`).

## Test-First Loop

Work in **vertical slices**, not horizontal ones. One failing test → the minimal code that makes it pass → repeat. Each test is a **tracer bullet**: it proves one thin path end-to-end, and what you learn shapes the next.

Do **not** write all the tests first and then all the implementation. That produces tests of *imagined* behavior — they assert the shape you guessed at and commit you to a structure before you understand it.

Fixing a bug? Reproduce it with a failing test first — see **diagnosing-bugs**.

## File Structure

- One test file per source file. Mirror the path: `lib/src/controllers/feed_stories_controller.dart` → `test/feed_stories_controller_test.dart`.
- Every test file has a single `void main() { ... }`.
- A single top-level `group()` naming the unit under test. When it's a class or enum, use `$` interpolation (`'$FeedStoriesStream'`) so the name tracks renames; for a plain scenario root, a descriptive `GIVEN …` string is fine.

## Test Naming — GIVEN / WHEN / THEN

Nested `group()` + `test()` names MUST read as a sentence when concatenated, in this project's BDD style:

- **GIVEN** `<subject / starting state>` — the outermost group.
- **WHEN** `<action / event>` / **AND** `<extra condition>` — inner groups.
- **THEN** `<observable behavior>` — the `test()`.

```dart
// GOOD: reads as "GIVEN a stream showing feedA WHEN the widget switches it
// to feedB THEN failures of the abandoned feed are ignored"
group('GIVEN a stream showing feedA', () {
  group('WHEN the widget switches it to feedB', () {
    test('THEN failures of the abandoned feed are ignored', () { });
  });
});
```

Rules:
- Verb phrases, not `should`: `THEN the live binding survives`, not `THEN it should survive`.
- A short WHEN+THEN may fold into the test name: `test('WHEN fetching THEN the bound list reloads', …)`.
- Use `$` interpolation for a class/enum subject so a rename updates the name; never a bare `Type` literal (`group(Hub, …)` is invalid). Interpolation works only for classes and enums — extensions and top-level functions must use a plain string.

## Depth Rules

- **Max 3 group levels.** Deeper nesting is a smell — fold a simple variant into the `THEN` name instead of adding a group.
- Drop a group whose context is true of *every* sibling test — it adds depth without discriminating. Move it into the parent name.

## Negative Tests

Clear verb phrases for absence/failure:

| Pattern | When |
|---------|------|
| `THEN … does not <verb>` | behavior intentionally skipped |
| `THEN throws <ExceptionType>` | expecting an exception |
| `THEN returns null` | null result expected |
| `THEN ignores <thing>` | input deliberately ignored |

Avoid vague negations (`THEN it fails`, `THEN no events`).

## Fixtures and Setup

This project sets up SUTs directly with `late` variables in `setUp()` inside the narrowest group that needs them — see [references/fixtures.md](references/fixtures.md) for the placement/scoping rules and when a `Fixture` class pays off (multiple tests sharing a configurable SUT builder).

```dart
group('GIVEN a controller bound to a list', () {
  late FeedStoriesController controller;
  late List<String> reloaded;

  setUp(() {
    reloaded = <String>[];
    controller = FeedStoriesController()..attach(() async => reloaded.add('first'));
  });
  // ...
});
```

## What to Test

Test the behavior owned by your change: user-visible behavior, public API, meaningful branching, data transformations, integration wiring, precedence, error handling, and regressions your change could realistically introduce.

Avoid re-proving guarantees owned elsewhere — a pigeon-generated DTO, a collection type, a framework. A caller test should not exist just to show its dependencies still work. Before adding a test ask: *what behavior would fail if my change were wrong, and does this code own that contract?*

## Assertions

- `expect()` with matchers from `package:flutter_test`.
- Prefer specific matchers (`throwsArgumentError`, `isA<StoryWidget>()`) over generic (`throwsException`, `isA<Object>()`).
- One logical assertion per test (multiple `expect()` verifying one behavior is fine).
- **Avoid the tautological test** — pin the expected literal, don't assert against the same constant the production code used to produce it. Using a constant as a lookup *key* is fine; the expected *value* is a literal.

## Mocking

**Prefer hand-written fakes** that capture state (a `List` the SUT appends to, as in the controller/stream tests) — resilient to refactoring, readable as documentation. Reach for `mocktail` only at real boundaries (the pigeon host API, an `Observable`) where faking a large interface isn't worth it; shared doubles live in [test/mocks.dart](../../../test/mocks.dart).

A test that's hard to fake usually means the code should *accept* its dependencies instead of constructing them. Full guidance — mocktail patterns, `registerFallbackValue`, mocking only at real boundaries — in [references/mocking.md](references/mocking.md).

## Async

Never fire-and-forget: return the `Future` or mark the callback `async`. Use `fake_async` for timer/microtask/timeout-dependent code (e.g. the stream's load-timeout grace period) and pin time deterministically. Examples in [references/async.md](references/async.md).

## General

- Keep tests deterministic. No real clock, network, or filesystem in unit tests. `DateTime.now()` in `id_gen.dart`/`logger.dart` is a seam to control from tests, not to read live.
- Don't duplicate test utilities — put shared doubles in `test/mocks.dart`.

## Integration / Native Interop

- Pigeon-generated host/flutter APIs (`lib/src/generated/*.g.dart`) cross the platform boundary and cannot be exercised by unit tests alone. Fake the generated `*HostApi` at its seam for unit tests; use `example/integration_test` (or `example_extended`) for behavior that depends on the real native side.
