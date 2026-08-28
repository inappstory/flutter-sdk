# React IAS — pitfalls & version traps

Distilled from get-started / migrations / config. Package `@inappstory/react-sdk`.
Check the version in `package.json` and fetch
[migrations](https://docs.inappstory.com/sdk-guides/react-sdk/migrations) for deltas.

## Component model — the pieces must nest correctly

- **`<StoryList>` must live inside `<IASContainer config={…}>`.** The container
  holds the `StoryManagerConfig` (with `apiKey`) and provides the SDK context;
  a bare `<StoryList>` outside it won't work.
- **`apiKey` is required** in `StoryManagerConfig`. Without a valid key nothing loads.
- **Feed is `feedSlug`** on `<StoryList feedSlug="default">` (not `feed`).
- Favorites list: `hasFavorite={true}` on `<StoryList>`.
- Options are split: `commonOptions` (shared, e.g. `hasShare/hasLike/hasFavorite`),
  `storiesListOptions`, `storyReaderOptions` — keep them in one options module and
  pass to the right prop, don't cram everything into one object.

## Events

Subscribe **either** via `<IASContainer>` props that start with `on…`
(`onClickOnStory`, …) **or** via a `storyManager` instance — not by guessing global
listeners. Same set of events as the JS SDK.

## Config flags with version gates

From the config table — several fields are version-gated, so match the app's version:
- `options` / `options.pos` (user & slide-widget variables) — **since v1.7.6**.
- `anonymous` (anonymous session; *not all features available*) — **since v3.6.6**.
- `hybridApp` (webview/game-reader viewport for hybrid apps) — **since v1.14.0**.
- `disableDeviceId` — turns off automatic `deviceId`; if you set it, `userId`
  handling matters (see user-settings).
- `userIdSign` — required when the console enforces signed users.

## CSP

If the host app enforces a Content-Security-Policy, the SDK needs specific
allowances — fetch
[implement-content-security-policies](https://docs.inappstory.com/sdk-guides/react-sdk/implement-content-security-policies)
before debugging "nothing renders / blocked" issues.

## Legacy browsers

For ES5 / old-browser targets use the
[es5-compatible](https://docs.inappstory.com/sdk-guides/react-sdk/es5-compatible)
build — the default build assumes modern browsers.
