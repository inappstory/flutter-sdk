# Flutter IAS — pitfalls & version traps

Distilled from get-started / migrations. Plugin: `inappstory_plugin` (0.x
versions). Check the version in `pubspec.yaml` and fetch
[migrations](https://docs.inappstory.com/sdk-guides/flutter/migrations) for deltas.

## Native setup is mandatory (this is where it silently fails)

The Dart package alone is **not enough** — you must touch the native Android host:
- **`InAppStoryPlugin.initSDK(this)` in your `Application` class.** The docs warn:
  *without this the library will not work on Android at all.* Register the custom
  Application via `manifestPlaceholders['applicationName']` in `app/build.gradle`.
- **`MainActivity` must extend `InAppStoryActivity`** (since 0.7.1), not
  `FlutterActivity`/`FlutterFragmentActivity`. It intercepts the hardware **Back**
  button so IAM closes correctly. Wrong base class → Back bypasses the SDK and the
  reader won't close. (History: `FlutterActivity` → `FlutterFragmentActivity` for
  IAM in 0.3 → `InAppStoryActivity` in 0.7.1.)
- **Android** `minSdkVersion = 23`, compile/target 34.
- **iOS**: run `pod install` (or `--repo-update`) in the `ios/` folder.

## Init is async — await it

- `await InAppStoryPlugin().initWith('<apiKey>', '<userId>', locale:, cacheSize:)`
  **before any other API call.** In UI, gate the widget behind the init `Future`
  (e.g. `FutureBuilder`) — using `FeedStoriesWidget` before init resolves fails.
- `userId` can be empty. `locale` needs a region subtag (`Locale('en','US')`) or
  it defaults to en-US. `cacheSize` is **Android-only** (small 15 / medium 110 /
  large 210 MB; medium default).

## Singletons — use `.instance` (post-migration)

- `InAppStoryManager` is a singleton since **0.3.4** → `InAppStoryManager.instance.…`
  (not `InAppStoryManagerHostApi()`).
- `AppearanceManager` is a singleton since **0.4.0** → `AppearanceManager.instance.…`.
- **0.8.0 rename:** call `InAppStoryManager.instance.showStory/showStoryOnce/
  showIAMById/showIAMByEvent/preloadInAppMessages/showOnboardings(...)` — the old
  `IASSingleStoryHostApi()/IASInAppMessagesHostApi()/IASOnboardingsHostApi()` forms
  are gone. Also brought cancellation of long-running ops.

## Widgets & callbacks

- **`FeedStoriesWidget` is the current list widget** (since 0.3.x). The old
  `InAppStoryPlugin().getStoriesWidgets()` / `getFavoritesStoriesWidgets()` are
  deprecated and being removed.
- Callbacks moved to **mixins**: `IASShowStoryCallback`, `IASOnboardingLoadCallback`
  (0.8.0), `IASGameReaderCallback` (0.7.0), `IASCallToActionCallback` (0.4.0).
- **Banner events**: the `IASBannerPlaceCallback` mixin was **removed in 0.7.6** —
  listen via callbacks on the `BannerPlace` widget itself (`onBannerScroll`).
