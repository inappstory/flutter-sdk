# Agent instructions

Single, vendor-agnostic context file for this repo. Every AI agent
(Claude Code, Codex, Cursor, …) reads this. `CLAUDE.md` just imports it.

## Project

`inappstory_plugin` — a Flutter plugin. Melos workspace; native Android/iOS
via Pigeon. Tests live in `test/`; run them with `flutter test`.

## Vendor-agnostic config

- **Source of truth is `.agents/`** (committed). Vendor folders (`.claude/`,
  `.codex/`, …) are **generated and gitignored** — treat them as read-only.
- Want to change a skill, setting, or hook? Edit it under `.agents/`, then run
  `.agents/setup` to mirror it into every vendor folder.
- `.agents/setup` runs automatically on session start (SessionStart hook), so
  config changes propagate to new sessions of every vendor.
- Add a new vendor by appending its dir to `VENDORS` in `.agents/setup`.

## Skills

Repo skills live in `.agents/skills/` (mirrored to `.claude/skills/`):
`diagnosing-bugs`, `test-guidelines`.
