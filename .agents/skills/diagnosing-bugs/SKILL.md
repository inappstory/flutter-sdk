---
name: diagnosing-bugs
description: A discipline for hard bugs, flaky tests, and timing regressions in the inappstory_plugin Flutter plugin. Use when the user says "diagnose" or "debug this", reports something broken/throwing/failing/hanging/slow, or a test is flaky. Builds a tight, red-capable feedback loop before hypothesizing.
---

A discipline for hard bugs. Skip a phase only when you can say why.

**The whole skill is Phase 1: get a loop that goes red on this bug.** Everything after is mechanical once you have it. If you catch yourself reading code to form a theory before that loop exists, stop — jumping to a hypothesis without a red-capable loop is the exact failure this prevents.

For trivial bugs with an obvious fix and an obvious test, skip this and just write the failing test — this skill is for the bugs that resist.

## Phase 1 — Build a feedback loop

A **tight** loop is fast, deterministic, and goes **red** on *this* bug. Build one and the bug is 90% solved; bisection, hypothesis-testing, and instrumentation all just consume it. Be aggressive and creative here — spend disproportionate effort.

### Ways to construct one — try roughly in this order

1. **Failing test at the seam** — `flutter test test/foo_test.dart` (add `--plain-name 'THEN …'` to run one case), unit or widget, at whatever seam reaches the bug. Tightest loop there is. Follow **test-guidelines** for structure.
2. **`fake_async` harness** — for timer, microtask, and timeout bugs (most flakes) — e.g. the stream's load-timeout grace period. Elapse time deterministically instead of waiting.
3. **`testWidgets` harness** — for widget-tree bugs: `pumpWidget`, drive the gesture, assert on the tree (visibility, story-list rebuild, navigation).
4. **Fake the pigeon boundary** — replace the generated `*HostApi` (`lib/src/generated/*.g.dart`) with a `mocktail` double and drive replies/failures by hand; the real native side can't be exercised from a unit test.
5. **Integration test** — `example/integration_test` (or `example_extended`) when the bug genuinely crosses into the native platform and the pigeon fake can't reproduce it.
6. **Replay a captured payload** — save a real DTO / story-API response and replay it through the code path in isolation.
7. **Throwaway harness** — a minimal `void main()` that exercises the bug path with one call and mocked deps.
8. **Stress/repetition loop** — for non-deterministic bugs: run the trigger 100×, parallelise, narrow timing windows, inject delays. Goal is a higher reproduction rate, not a clean repro.
9. **Differential loop** — same input through two versions/configs (e.g. before/after a dependency bump) and diff the output. For regressions that "appeared after X".
10. **Bisection harness** — if it appeared between two commits, script the red/green check and `git bisect run` it.

### Tighten the loop

Once you have *a* loop, treat it as a product and tighten it:

- **Faster** — narrow the test scope (`--plain-name`), skip unrelated init.
- **Sharper** — assert the exact symptom the user described, not "didn't crash".
- **More deterministic** — use `fake_async`, control `DateTime.now()` seams (`id_gen.dart`, `logger.dart`), seed randomness, avoid real network/filesystem (per test-guidelines). A 2-second deterministic loop beats a 30-second flaky one.

For **non-deterministic** bugs the goal is a *high enough* reproduction rate to debug against — a 50% flake is debuggable, 1% is not. Keep raising the rate.

### Completion criterion

Phase 1 is done when you can name **one command** — a test invocation or script path — that you have **already run at least once** (paste the invocation and its output), and that is:

- [ ] **Red-capable** — drives the actual bug path and asserts the user's exact symptom, so it goes red now and green once fixed
- [ ] **Deterministic** — same verdict every run (flaky bugs: a pinned, high reproduction rate)
- [ ] **Fast** — seconds, not minutes

No red-capable command, no Phase 2.

### When you genuinely cannot build a loop

Say so explicitly, list what you tried, and ask the user for: access to an environment that reproduces it, a captured artifact (payload dump, log, CI run, screen recording with timestamps), or permission for temporary instrumentation. Do **not** hypothesise without a loop.

## Phase 2 — Reproduce and minimise

Run the loop, watch it go red. Confirm it produces the failure the **user** described — not a nearby one (wrong bug = wrong fix). Then shrink the repro to the smallest scenario that still goes red: cut inputs, callers, config, and steps **one at a time**, re-running after each cut. Done when every remaining element is load-bearing. The minimal repro shrinks the hypothesis space and becomes the regression test.

## Phase 3 — Hypothesise

Generate **3–5 ranked, falsifiable hypotheses** before testing any — a single hypothesis anchors you on the first plausible idea. Each states its prediction: "If X is the cause, then changing Y makes the bug vanish." If you can't state the prediction, it's a vibe — sharpen or discard it. Show the ranked list to the user before testing; they often re-rank it instantly ("we just changed #3").

## Phase 4 — Instrument

Each probe maps to one prediction from Phase 3. **Change one variable at a time.**

- Prefer a debugger / breakpoint (VS Code / IntelliJ Dart) over logs where the env supports it. One breakpoint beats ten logs.
- Otherwise add targeted logs at the boundaries that distinguish hypotheses — never "log everything and grep".
- **Tag every debug log** with a unique prefix like `[DEBUG-a4f2]` so cleanup is one grep. (Don't leave them in the project's `IASLogger`.)
- **Performance regressions**: logs are the wrong tool. Establish a baseline (`Stopwatch`, DevTools timeline), then bisect. Measure first, fix second.

## Phase 5 — Fix and regression test

Write the regression test **before** the fix — but only at a **correct seam**, one that exercises the real bug pattern as it occurs at the call site (per test-guidelines). A too-shallow unit test that can't replicate the chain that triggered it gives false confidence. If no correct seam exists, **that is itself the finding** — the architecture is preventing the bug from being locked down; note it.

With a correct seam: turn the minimised repro into a failing test, watch it fail, apply the fix, watch it pass, then re-run the Phase 1 loop against the original un-minimised scenario.

## Phase 6 — Cleanup and post-mortem

Before declaring done:

- [ ] Original repro no longer reproduces (re-run the Phase 1 loop)
- [ ] Regression test passes (or the absence of a seam is documented)
- [ ] All `[DEBUG-…]` instrumentation removed (grep the prefix)
- [ ] Throwaway harnesses deleted
- [ ] The correct hypothesis is stated in the commit / PR message, so the next debugger learns

Then ask: **what would have prevented this bug?** If the answer is architectural — no good test seam, tangled callers, a shallow module hiding the real bug — that's a design finding worth raising, not just a fix to ship.
