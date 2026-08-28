---
name: inappstory-js
description: "Integrate and use the InAppStory (IAS) SDK on the web with vanilla JavaScript — feeds, single story, Story View, stack feed, onboardings, in-app messaging, games, banners, goods, favorites, share panel, plugins, events, and more. Use when adding, configuring, or debugging the InAppStory JS SDK in a web app, or answering how the JS IAS SDK works."
---

<!--
Vendor-neutral: no `allowed-tools` on purpose. Routes to the public docs and
expects the host agent to fetch a URL (Claude: WebFetch; others: a browser/fetch
tool). Agents without a fetch tool degrade gracefully — the URLs are clickable.
argument-hint: [topic, e.g. feeds, in-app-messaging, story-view]
-->

# InAppStory SDK — JavaScript (web)

This skill routes to the **official InAppStory JS SDK docs**. The docs are the
source of truth and change often, so this skill does not copy them — it points
to the exact page and expects you to **fetch it on demand**.

## How to use

1. Find the relevant topic in the index below.
2. **Fetch that page** (`WebFetch <url>`) and answer from the live content —
   never guess SDK APIs, versions, or npm/CDN coordinates from memory.
3. New to the SDK? Start with **How to get started**, then **Options**.
4. If you have no fetch tool, give the user the exact URL to open.

Base URL: `https://docs.inappstory.com/sdk-guides/js-sdk/`

## Judgment layer (read these first — what a doc page won't tell you)

- **[playbooks.md](playbooks.md)** — end-to-end recipes for both NPM and CDN (list,
  events, features, personalize, CSP deploy) with the construction sequence.
- **[pitfalls.md](pitfalls.md)** — grounded gotchas: the `StoryManager`→
  `InAppStoryManager` rename (JS SDK 3), `window.IAS.*` on CDN, mount-`<div>`
  ordering, `.on()` events, version-gated config flags.
- **[decisions.md](decisions.md)** — NPM vs CDN, the manager rename, anonymous vs
  identified, which entry point, browser support / CSP.

## Intake — ask before you write

Two quick checks before any integration work:

1. **Underspecified request? Ask, don't guess.** If the user didn't say *where*
   the UI goes (which page / mount `<div>`) or *which* feature they mean, ask
   before writing — a feed on the wrong page is wasted work.
2. **First integration? Get the integration key.** If the codebase grep (below)
   finds no existing IAS setup, this is a fresh integration: ask the user for their
   **integration key** (`apiKey`) — init fails without it. If a setup already
   exists, reuse its key; don't ask.

## Before you answer or write integration code

1. **Check the version** in `package.json` (`@inappstory/js-sdk`) or the CDN script
   URL; if absent, ask. **JS SDK 3 renamed `StoryManager`→`InAppStoryManager`** and
   flags are version-gated — answer for that version.
2. **Detect NPM vs CDN** — imports vs `window.IAS.*` change every snippet.
3. **Match the existing codebase** — reuse the app's mount `<div>` id, where the
   apiKey lives, its manager instance. Extend, don't paste anew.
4. **Then** fetch the topic page and write against the live API.

## Topics

### Getting started & core
| Topic | Page |
|---|---|
| How to get started | https://docs.inappstory.com/sdk-guides/js-sdk/how-to-get-started |
| Options | https://docs.inappstory.com/sdk-guides/js-sdk/options |
| User settings | https://docs.inappstory.com/sdk-guides/js-sdk/user-settings |
| Migrations | https://docs.inappstory.com/sdk-guides/js-sdk/migrations |
| External API | https://docs.inappstory.com/sdk-guides/js-sdk/external-api |
| Legacy browser support (ES5) | https://docs.inappstory.com/sdk-guides/js-sdk/es5-compatible |
| Content Security Policy (CSP) | https://docs.inappstory.com/sdk-guides/js-sdk/implement-content-security-policies |

### Stories UI (feeds & lists)
| Topic | Page |
|---|---|
| Feeds | https://docs.inappstory.com/sdk-guides/js-sdk/feeds |
| Single story | https://docs.inappstory.com/sdk-guides/js-sdk/single-story |
| Story View | https://docs.inappstory.com/sdk-guides/js-sdk/story-view |
| Stack Feed | https://docs.inappstory.com/sdk-guides/js-sdk/stack-feed |
| Placeholders | https://docs.inappstory.com/sdk-guides/js-sdk/placeholders |
| Banners | https://docs.inappstory.com/sdk-guides/js-sdk/banners |

### Content types & features
| Topic | Page |
|---|---|
| Onboarding | https://docs.inappstory.com/sdk-guides/js-sdk/onboardings |
| In-App Messaging (IAM) | https://docs.inappstory.com/sdk-guides/js-sdk/in-app-messaging |
| Games | https://docs.inappstory.com/sdk-guides/js-sdk/games |
| Checkout | https://docs.inappstory.com/sdk-guides/js-sdk/checkout |
| Favorite feed | https://docs.inappstory.com/sdk-guides/js-sdk/favorites |
| Widget "Goods" | https://docs.inappstory.com/sdk-guides/js-sdk/widget-goods |
| Share panel | https://docs.inappstory.com/sdk-guides/js-sdk/share-panel |
| Plugins | https://docs.inappstory.com/sdk-guides/js-sdk/plugins |

### Targeting, events & handling
| Topic | Page |
|---|---|
| Events | https://docs.inappstory.com/sdk-guides/js-sdk/events |
| Tags | https://docs.inappstory.com/sdk-guides/js-sdk/tags |
| Link handling | https://docs.inappstory.com/sdk-guides/js-sdk/link-handling |

### Advanced & platform
| Topic | Page |
|---|---|
| LRU cache | https://docs.inappstory.com/sdk-guides/js-sdk/cache |

## Notes

- Full section index (may include topics added after this skill):
  https://docs.inappstory.com/sdk-guides/
- Other platforms have their own skills (`inappstory-android`, `inappstory-ios`,
  `inappstory-flutter`, `inappstory-react-native`, `inappstory-react`).
- `changelog` and the issue-template `bug-report` are intentionally omitted.
