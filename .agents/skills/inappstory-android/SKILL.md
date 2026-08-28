---
name: inappstory-android
description: "Integrate and use the InAppStory (IAS) SDK on Android — stories feeds, single stories, onboardings, in-app messaging, games, banners, favorites, personalization, appearance, events, and more. Use when adding, configuring, or debugging InAppStory / InAppStoryManager on Android (Kotlin/Java, Jetpack Compose), or answering how the Android IAS SDK works."
---

<!--
Vendor-neutral: no `allowed-tools` on purpose. The skill routes to the public
docs and expects the host agent to fetch a URL (Claude: WebFetch; others: a
browser/fetch tool). Agents without a fetch tool degrade gracefully — the URLs
below are clickable, so a human can open the exact page.
argument-hint: [topic, e.g. onboardings, in-app-messaging, appearance]
-->

# InAppStory SDK — Android

This skill routes to the **official InAppStory Android docs**. The docs are the
source of truth and change often, so this skill does not copy them — it points
to the exact page and expects you to **fetch it on demand**.

## How to use

1. Find the relevant topic in the index below.
2. **Fetch that page** (`WebFetch <url>`) and answer from the live content —
   never guess SDK APIs, versions, or gradle coordinates from memory.
3. New to the SDK? Start with **How to get started**, then **InAppStoryManager**
   and **Options**.
4. If you have no fetch tool, give the user the exact URL to open.

Base URL: `https://docs.inappstory.com/sdk-guides/android/`

## Judgment layer (read these first — they're what a doc page won't tell you)

The docs answer "what's the API for X". These files answer "how do I do the whole
task, what will bite me, and which option to pick" — synthesis across pages:

- **[playbooks.md](playbooks.md)** — end-to-end task recipes (add a feed, onboardings,
  single story, IAM, switch user) with the exact call sequence and pages.
- **[pitfalls.md](pitfalls.md)** — grounded gotchas & **version traps** (init order,
  `DataException`, worker-thread cell binding, memory-leak callbacks, renames).
- **[decisions.md](decisions.md)** — decision guides (which stories UI / cell interface
  / callback / IAM version).

## Intake — ask before you write

Two quick checks before any integration work:

1. **Underspecified request? Ask, don't guess.** If the user didn't say *where*
   the UI goes (which screen/Activity/Composable) or *which* feature they mean,
   ask before writing — a feed on the wrong screen is wasted work.
2. **First integration? Get the integration key.** If the codebase grep (below)
   finds no existing IAS setup, this is a fresh integration: ask the user for their
   **integration key** (`apiKey`, a.k.a. `csApiKey`) — init fails without it. If a
   setup already exists, reuse its key; don't ask.

## Before you answer or write integration code

1. **Check the SDK version.** The Android API changed heavily across releases
   (see pitfalls.md). Grep the app's gradle for
   `com.github.inappstory:android-sdk:X.Y.Z`; if you can't find it, ask. Answer for
   *that* version, and fetch **migrations** for deltas to the latest.
2. **Match the existing codebase (codebase-aware).** Before writing code, grep for
   an existing setup — `InAppStoryManager`, `initSdk`, `csApiKey`, `StoriesList` —
   and reuse the app's patterns: its language (Kotlin/Java), where `apiKey`/`userId`
   live, its wrapper/DI. Extend their integration; don't paste a fresh one beside it.
3. **Then** fetch the relevant topic page and write against the live API.

## Topics

### Getting started & core
| Topic | Page |
|---|---|
| How to get started | https://docs.inappstory.com/sdk-guides/android/how-to-get-started |
| InAppStoryManager (init & lifecycle) | https://docs.inappstory.com/sdk-guides/android/inappstory-manager |
| Options | https://docs.inappstory.com/sdk-guides/android/options |
| User settings | https://docs.inappstory.com/sdk-guides/android/user-settings |
| Anonymous mode | https://docs.inappstory.com/sdk-guides/android/anonymous-mode |
| Jetpack Compose integration | https://docs.inappstory.com/sdk-guides/android/jetpack-compose |
| Migrations | https://docs.inappstory.com/sdk-guides/android/migrations |
| FAQ | https://docs.inappstory.com/sdk-guides/android/FAQ |

### Stories UI (feeds & lists)
| Topic | Page |
|---|---|
| StoriesList | https://docs.inappstory.com/sdk-guides/android/stories-list |
| Single Story | https://docs.inappstory.com/sdk-guides/android/single-story |
| Multi-feed | https://docs.inappstory.com/sdk-guides/android/multi-feed |
| Stack Feed | https://docs.inappstory.com/sdk-guides/android/stack-feed |
| Home Screen Widget | https://docs.inappstory.com/sdk-guides/android/home-screen-widget |
| List Placeholder | https://docs.inappstory.com/sdk-guides/android/list-placeholder |
| Placeholders | https://docs.inappstory.com/sdk-guides/android/placeholders |
| Reader presentation | https://docs.inappstory.com/sdk-guides/android/reader-presentation |
| Appearance | https://docs.inappstory.com/sdk-guides/android/appearance |
| Refresh | https://docs.inappstory.com/sdk-guides/android/refresh |

### Content types & features
| Topic | Page |
|---|---|
| Onboardings | https://docs.inappstory.com/sdk-guides/android/onboardings |
| In-App Messaging | https://docs.inappstory.com/sdk-guides/android/in-app-messaging |
| Games | https://docs.inappstory.com/sdk-guides/android/games |
| Banner Carousel | https://docs.inappstory.com/sdk-guides/android/banners |
| Widget "Goods" | https://docs.inappstory.com/sdk-guides/android/widget-goods |
| Checkout | https://docs.inappstory.com/sdk-guides/android/checkout |
| Likes, Share, Favorites | https://docs.inappstory.com/sdk-guides/android/favorites |
| Lottie animation | https://docs.inappstory.com/sdk-guides/android/lottie-animation |
| Sound control | https://docs.inappstory.com/sdk-guides/android/sound-control |

### Targeting, events & handling
| Topic | Page |
|---|---|
| Tags | https://docs.inappstory.com/sdk-guides/android/tags |
| Events | https://docs.inappstory.com/sdk-guides/android/events |
| Link handling | https://docs.inappstory.com/sdk-guides/android/link-handling |
| Cancellation of long-running actions | https://docs.inappstory.com/sdk-guides/android/cancellation-of-actions |

### Advanced & platform
| Topic | Page |
|---|---|
| Cache | https://docs.inappstory.com/sdk-guides/android/cache |
| SSL Pinning | https://docs.inappstory.com/sdk-guides/android/ssl-pinning |
| FilePicker | https://docs.inappstory.com/sdk-guides/android/file-picker |
| Logger | https://docs.inappstory.com/sdk-guides/android/logger |

## Notes

- Full section index (may include topics added after this skill):
  https://docs.inappstory.com/sdk-guides/
- Other platforms have their own skills (`inappstory-ios`, `inappstory-flutter`,
  `inappstory-react-native`, `inappstory-react`, `inappstory-js`).
- `changelog` and deprecated `events-old` are intentionally omitted — fetch the
  base URL if you need version history.
