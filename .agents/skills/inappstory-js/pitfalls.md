# JS SDK IAS — pitfalls & version traps

Distilled from get-started / migrations / config. Package `@inappstory/js-sdk`
(3.x). Check the version in `package.json` (or the CDN script URL) and fetch
[migrations](https://docs.inappstory.com/sdk-guides/js-sdk/migrations) for deltas.

## The big rename (JS SDK 3)

- **`StoryManager` was renamed to `InAppStoryManager`.** Code written for JS SDK 2
  that constructs `new StoryManager(...)` must switch to `new InAppStoryManager(...)`.
- **CDN builds expose everything under `window.IAS`** — use
  `window.IAS.InAppStoryManager` and `window.IAS.AppearanceManager`, not bare globals.

## Setup order (imperative — easy to get wrong)

- **The mount `<div>` must exist before you construct the list.** Place
  `<div id="stories_widget"></div>` in the DOM, and for CDN run construction inside
  `DOMContentLoaded` — constructing against a missing selector fails.
- Construction sequence: `new InAppStoryManager(config)` → `new AppearanceManager()`
  → `new inAppStoryManager.StoriesList("#stories_widget", appearanceManager,
  { feed: "default" })`. Note `StoriesList` is created **off the manager instance**,
  not imported standalone.
- `apiKey` is required in the config.

## Events

Subscribe with `inAppStoryManager.on(eventName, payload => …)`. Names include
`clickOnStory`, `showStory`, `closeStory`, `clickOnButton`, `likeStory`,
`favoriteStory`, `shareStory`, `feedLoad`, `feedImpression`, etc. There's no
NotificationCenter/delegate here — it's all `.on(...)`.

## Config flags with version gates

Match the app's version — several fields are gated:
- `options` / `options.pos` — **since v3.6.6**.
- `anonymous` (*not all features available*) — **since v3.6.6**.
- `hybridApp` (webview/game-reader viewport for hybrid apps) — **since v3.13.0**.
- `disableDeviceId`, `userIdSign` (required when the console enforces signed users).

## CSP & legacy browsers

- Host CSP → apply the SDK's directives first (see
  [implement-content-security-policies](https://docs.inappstory.com/sdk-guides/js-sdk/implement-content-security-policies))
  before debugging blank widgets.
- ES5 / old browsers → the
  [es5-compatible](https://docs.inappstory.com/sdk-guides/js-sdk/es5-compatible) build.
