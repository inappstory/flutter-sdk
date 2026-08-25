---
name: inappstory-react
description: "Integrate and use the InAppStory (IAS) SDK on the web with React — feeds, single story, Story View, onboardings, in-app messaging, games, banners, favorites, share panel, plugins, events, and more. Use when adding, configuring, or debugging the InAppStory React SDK in a web app, or answering how the React IAS SDK works."
---

<!--
Vendor-neutral: no `allowed-tools` on purpose. Routes to the public docs and
expects the host agent to fetch a URL (Claude: WebFetch; others: a browser/fetch
tool). Agents without a fetch tool degrade gracefully — the URLs are clickable.
Note: skill name is `inappstory-react`, docs path is `react-sdk`.
argument-hint: [topic, e.g. feeds, in-app-messaging, story-view]
-->

# InAppStory SDK — React (web)

This skill routes to the **official InAppStory React SDK docs**. The docs are the
source of truth and change often, so this skill does not copy them — it points
to the exact page and expects you to **fetch it on demand**.

## How to use

1. Find the relevant topic in the index below.
2. **Fetch that page** (`WebFetch <url>`) and answer from the live content —
   never guess SDK APIs, versions, or npm coordinates from memory.
3. New to the SDK? Start with **How to get started**, then **Options**.
4. If you have no fetch tool, give the user the exact URL to open.

Base URL: `https://docs.inappstory.com/sdk-guides/react-sdk/`

## Judgment layer (read these first — what a doc page won't tell you)

- **[playbooks.md](playbooks.md)** — end-to-end recipes (list, onboardings, single
  story, IAM, personalize, CSP deploy) with the `IASContainer`/`StoryList` nesting.
- **[pitfalls.md](pitfalls.md)** — grounded gotchas: `<StoryList>` must nest in
  `<IASContainer>`, `feedSlug` (not `feed`), options split (common/list/reader),
  version-gated config flags, CSP & ES5 builds.
- **[decisions.md](decisions.md)** — where each config field goes, which feed,
  anonymous vs identified, events via container props vs manager instance.

## Intake — ask before you write

Two quick checks before any integration work:

1. **Underspecified request? Ask, don't guess.** If the user didn't say *where*
   the UI goes (which page/component) or *which* feature they mean, ask before
   writing — a feed on the wrong screen is wasted work.
2. **First integration? Get the integration key.** If the codebase grep (below)
   finds no existing IAS setup, this is a fresh integration: ask the user for their
   **integration key** (`apiKey`) — init fails without it. If a setup already
   exists, reuse its key; don't ask.

## Before you answer or write integration code

1. **Check the package version** in `package.json` (`@inappstory/react-sdk`);
   if absent, ask. Config flags are version-gated (`options` v1.7.6, `anonymous`
   v3.6.6, `hybridApp` v1.14.0) — answer for that version.
2. **Match the existing codebase** — reuse the app's options module, where the
   apiKey/`StoryManagerConfig` lives, its `IASContainer` placement. Extend, don't
   paste a second container.
3. **Then** fetch the topic page and write against the live API.

## Topics

### Getting started & core
| Topic | Page |
|---|---|
| How to get started | https://docs.inappstory.com/sdk-guides/react-sdk/how-to-get-started |
| Options | https://docs.inappstory.com/sdk-guides/react-sdk/options |
| User settings | https://docs.inappstory.com/sdk-guides/react-sdk/user-settings |
| Migrations | https://docs.inappstory.com/sdk-guides/react-sdk/migrations |
| External API | https://docs.inappstory.com/sdk-guides/react-sdk/external-api |
| Legacy browser support (ES5) | https://docs.inappstory.com/sdk-guides/react-sdk/es5-compatible |
| Content Security Policy (CSP) | https://docs.inappstory.com/sdk-guides/react-sdk/implement-content-security-policies |

### Stories UI (feeds & lists)
| Topic | Page |
|---|---|
| Feeds | https://docs.inappstory.com/sdk-guides/react-sdk/feeds |
| Single story | https://docs.inappstory.com/sdk-guides/react-sdk/single-story |
| Story View | https://docs.inappstory.com/sdk-guides/react-sdk/story-view |
| Placeholders | https://docs.inappstory.com/sdk-guides/react-sdk/placeholders |
| Banners | https://docs.inappstory.com/sdk-guides/react-sdk/banners |

### Content types & features
| Topic | Page |
|---|---|
| Onboarding | https://docs.inappstory.com/sdk-guides/react-sdk/onboardings |
| In-App Messaging (IAM) | https://docs.inappstory.com/sdk-guides/react-sdk/in-app-messaging |
| Games | https://docs.inappstory.com/sdk-guides/react-sdk/games |
| Checkout | https://docs.inappstory.com/sdk-guides/react-sdk/checkout |
| Favorite feed | https://docs.inappstory.com/sdk-guides/react-sdk/favorites |
| Share panel | https://docs.inappstory.com/sdk-guides/react-sdk/share-panel |
| Plugins | https://docs.inappstory.com/sdk-guides/react-sdk/plugins |

### Targeting, events & handling
| Topic | Page |
|---|---|
| Events | https://docs.inappstory.com/sdk-guides/react-sdk/events |
| Tags | https://docs.inappstory.com/sdk-guides/react-sdk/tags |
| Link handling | https://docs.inappstory.com/sdk-guides/react-sdk/link-handling |

### Advanced & platform
| Topic | Page |
|---|---|
| LRU cache | https://docs.inappstory.com/sdk-guides/react-sdk/cache |

## Notes

- Full section index (may include topics added after this skill):
  https://docs.inappstory.com/sdk-guides/
- Other platforms have their own skills (`inappstory-android`, `inappstory-ios`,
  `inappstory-flutter`, `inappstory-react-native`, `inappstory-js`).
- `changelog` and the issue-template `bug-report` are intentionally omitted.
