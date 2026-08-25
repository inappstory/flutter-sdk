---
name: inappstory-flutter
description: "Integrate and use the InAppStory (IAS) SDK on Flutter — FeedStoriesWidget, single stories, onboardings, in-app messaging, games, goods, banners, favorites, appearance, events, and more. Use when adding, configuring, or debugging the InAppStory Flutter/Dart plugin, or answering how the Flutter IAS SDK works."
---

<!--
Vendor-neutral: no `allowed-tools` on purpose. Routes to the public docs and
expects the host agent to fetch a URL (Claude: WebFetch; others: a browser/fetch
tool). Agents without a fetch tool degrade gracefully — the URLs are clickable.
argument-hint: [topic, e.g. feed-stories-widget, in-app-messaging, appearance]
-->

# InAppStory SDK — Flutter

This skill routes to the **official InAppStory Flutter docs**. The docs are the
source of truth and change often, so this skill does not copy them — it points
to the exact page and expects you to **fetch it on demand**.

## How to use

1. Find the relevant topic in the index below.
2. **Fetch that page** (`WebFetch <url>`) and answer from the live content —
   never guess SDK APIs, versions, or pub.dev coordinates from memory.
3. New to the SDK? Start with **How to get started**, then **InAppStoryManager**
   and **Options**.
4. If you have no fetch tool, give the user the exact URL to open.

Base URL: `https://docs.inappstory.com/sdk-guides/flutter/`

## Judgment layer (read these first — what a doc page won't tell you)

- **[playbooks.md](playbooks.md)** — end-to-end recipes (feed, onboardings, single
  story, IAM, switch user, banners) including the mandatory native Android steps.
- **[pitfalls.md](pitfalls.md)** — grounded gotchas: native setup (`initSDK` in
  `Application`, `MainActivity : InAppStoryActivity`), async `initWith`, singleton
  `.instance` migration, HostApi→singleton renames (0.8.0).
- **[decisions.md](decisions.md)** — `MainActivity` base class by version, singleton
  vs old HostApi, which list widget, callback mixins.

## Intake — ask before you write

Two quick checks before any integration work:

1. **Underspecified request? Ask, don't guess.** If the user didn't say *where*
   the UI goes (which screen/widget) or *which* feature they mean, ask before
   writing — a feed on the wrong screen is wasted work.
2. **First integration? Get the integration key.** If the codebase grep (below)
   finds no existing IAS setup, this is a fresh integration: ask the user for their
   **integration key** (`apiKey`) — init fails without it. If a setup already
   exists, reuse its key; don't ask.

## Before you answer or write integration code

1. **Check the plugin version** in `pubspec.yaml` (`inappstory_plugin: X.Y.Z`);
   if absent, ask. The API changed across 0.x (singletons, 0.8.0 renames) — answer
   for that version and fetch **migrations** for deltas.
2. **Verify the native Android setup** — most "doesn't work on Android" reports are
   a missing `InAppStoryPlugin.initSDK` or `MainActivity` not extending
   `InAppStoryActivity`. Check these before debugging Dart.
3. **Match the existing codebase** — reuse the app's Application class, where the
   apiKey lives, its manager wrapper. Extend, don't paste anew.
4. **Then** fetch the topic page and write against the live API.

## Topics

### Getting started & core
| Topic | Page |
|---|---|
| How to get started | https://docs.inappstory.com/sdk-guides/flutter/how-to-get-started |
| InAppStoryManager (init & lifecycle) | https://docs.inappstory.com/sdk-guides/flutter/in-app-story-manager |
| Options | https://docs.inappstory.com/sdk-guides/flutter/options |
| User settings | https://docs.inappstory.com/sdk-guides/flutter/user-settings |
| Anonymous mode | https://docs.inappstory.com/sdk-guides/flutter/anonymous-mode |
| Migrations | https://docs.inappstory.com/sdk-guides/flutter/migrations |
| FAQ | https://docs.inappstory.com/sdk-guides/flutter/faq |

### Stories UI (feeds & lists)
| Topic | Page |
|---|---|
| FeedStoriesWidget | https://docs.inappstory.com/sdk-guides/flutter/feed-stories-widget |
| Single Story | https://docs.inappstory.com/sdk-guides/flutter/single-story |
| List Placeholders | https://docs.inappstory.com/sdk-guides/flutter/list-placeholders |
| Appearance | https://docs.inappstory.com/sdk-guides/flutter/appearance-manager |
| Banners place | https://docs.inappstory.com/sdk-guides/flutter/banners |

### Content types & features
| Topic | Page |
|---|---|
| Onboardings | https://docs.inappstory.com/sdk-guides/flutter/onboardings |
| In-App Messaging | https://docs.inappstory.com/sdk-guides/flutter/in-app-messaging |
| Games | https://docs.inappstory.com/sdk-guides/flutter/games |
| Goods | https://docs.inappstory.com/sdk-guides/flutter/goods |
| Checkout | https://docs.inappstory.com/sdk-guides/flutter/checkout |
| Favorites | https://docs.inappstory.com/sdk-guides/flutter/favorites |
| Call To Action | https://docs.inappstory.com/sdk-guides/flutter/call-to-action |
| Sound control | https://docs.inappstory.com/sdk-guides/flutter/sound-control |

### Targeting, events & handling
| Topic | Page |
|---|---|
| Events | https://docs.inappstory.com/sdk-guides/flutter/events |
| Cancellation of long-running actions | https://docs.inappstory.com/sdk-guides/flutter/cancellation-of-actions |

## Notes

- Full section index (may include topics added after this skill):
  https://docs.inappstory.com/sdk-guides/
- Other platforms have their own skills (`inappstory-android`, `inappstory-ios`,
  `inappstory-react-native`, `inappstory-react`, `inappstory-js`).
- `changelog` is intentionally omitted — fetch the base URL for version history.
