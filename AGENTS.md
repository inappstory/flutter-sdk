# Agent instructions

Single, vendor-agnostic context file for this repo. Every AI agent
(Claude Code, Codex, Cursor, …) reads this. `CLAUDE.md` just imports it.

## Project

`inappstory_plugin` — a Flutter plugin. Melos workspace; native Android/iOS
via Pigeon. Tests live in `test/`; run them with `flutter test`.

## Vendor-agnostic config

- **Source of truth is `.agents/`** (committed). Vendor folders (`.claude/`,
  `.codex/`, `.cursor/`, `.gemini/`, `.github/`) are **generated and
  gitignored** — treat them as read-only.
- Edit skills in `.agents/skills/` and vendor-specific hooks in
  `.agents/vendor-configs/`, then run `.agents/setup` to generate their native
  config files.
- Claude, Gemini CLI, Codex, Cursor, and Copilot run `.agents/setup` at session
  start through their native hook configuration. Codex discovers skills
  directly from `.agents/skills/`.

## Skills

Repo skills live in `.agents/skills/` (mirrored to vendor discovery folders):
`diagnosing-bugs`, `test-guidelines`.
