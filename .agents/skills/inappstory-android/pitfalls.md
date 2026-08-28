# Android IAS — pitfalls & version traps

Distilled from the docs' FAQ / migrations / manager pages. **The API changed a
lot across versions** — every item is version-gated. Check the app's SDK version
first (grep gradle for `com.github.inappstory:android-sdk:X.Y.Z`) and fetch
[migrations](https://docs.inappstory.com/sdk-guides/android/migrations) for the
exact deltas between that version and the latest.

## Initialization & lifecycle

- **`initSdk` in `Application` is mandatory since 1.18.0.** Call
  `InAppStoryManager.initSdk(context)` in your `Application` class, *then*
  `InAppStoryManager.Builder()…​.create()` from anywhere. Before 1.18.0 there is
  no `initSdk`, but you must pass `.context(context)` into the Builder.
- **`loadStories()` can throw `DataException` if the SDK isn't initialized.**
  The get-started page still warns this for current versions — wrap it and log.
  (Historically `create()`/`userId()` also threw `DataException` on ≤1.13.2; that
  was removed in 1.14.0, errors now go to logs.)
- **`userId` is required and non-null.** Since 1.6.x you cannot init without it;
  an empty string is allowed only when `isDeviceIdEnabled=true` (the default). If
  you set `isDeviceIdEnabled=false`, `userId` must be a non-empty string. Max 255
  chars. Change later with `setUserId()` (auto-refreshes all `StoriesList`s).
- **`userSign` is required when console "signed user" security is on** — pass it
  together with `userId`: `.userId(userId, userSign)` (2-arg form is 1.20.8+).
- **Logout: `userLogout()` (1.21+).** `destroy()` was deprecated in 1.15 and
  **removed in 1.24** — don't call it. Use `userLogout()` / `userSettings()`.

## Callbacks & threading (memory leaks)

- **Don't use anonymous callback classes** — they capture the enclosing class and
  leak it. Implement callback interfaces as separate classes, hold the parent via
  a `WeakReference` if needed. Never keep `Context`/`View` as strong refs in a
  callback.
- **`IStoriesListItem.setImage()/setVideo()` run on a worker thread since 1.19.0.**
  Marshal any UI work back to the main thread yourself.
- **`setImage`/`setVideo` give a cached *file path*, not a URL, and fire only
  after caching** (since 1.6.x). Load from the local file, don't expect a network
  URL. `setVideo` no longer gets poster url / background color.
- **`CallToActionCallback`, not `UrlClickCallback`.** `UrlClickCallback` /
  `setUrlClickCallback` are deprecated (1.16/1.20). Same story: `GameReaderCallback`
  replaces removed `GameCallback`.

## UI & scrolling

- **Lock parent scroll while the list scrolls.** Inside a `SwipeRefreshLayout` or
  scrollable parent, use `StoriesList.setScrollCallback(ListScrollCallback)` and
  call `requestDisallowInterceptTouchEvent(true/false)` on scroll start/end
  (disable the `SwipeRefreshLayout` during scroll). See FAQ.
- **Banner scratch-card (1.25.0+) also needs parent-scroll locking** — use the new
  `BannerCarousel` vertical-gestures callback if banners sit in a scroll view.
- **`AppearanceManager` is set via setter only since 1.21.0** (not as a property).
  Global: `AppearanceManager.setCommonInstance(am)` (the old `setInstance` is
  deprecated since 1.6). Per-list: `storiesList.setAppearanceManager(am)`.
- **Grid needs `csColumnCount` *with* `csListItemRatio`** (and set font size
  yourself). `csListItemWidth` was removed — use `csListItemRatio` (+`csListItemHeight`).

## Build / Gradle

- **Add the extra deps**, not just the SDK: `androidx.recyclerview:recyclerview`
  and `androidx.webkit:webkit`, plus the jitpack maven repo in root `build.gradle`.
- **AGP 8.0.0 + Java 17 required since 1.22.0.**
- **ProGuard rules are needed only up to 1.17.x.** From 1.18.0 they ship via
  `consumer-rules.pro` — don't re-add the old `-keep class com.inappstory.sdk.**`.
- **minSdk 21 since 1.17.0** (Phone/Tablet only — not TV/Wear). minSdk 19 needs
  an older SDK.

## Renames that break older integration code

Fetch [migrations](https://docs.inappstory.com/sdk-guides/android/migrations) for
full context, but the common ones:
- 1.22: `BannerPlace`→`BannerCarousel`, `csBannerPlaceInterface`→`csBannerCarouselInterface`.
- 1.24: `finishGame` removed from `GameReaderCallback`; `ShowInAppMessageSlideCallback` signature changed.
- 1.23: `showOnboardingStories`/`showStory`/`showStoryOnce`/`showInAppMessage` now return a `CancellationToken`.
- 1.21: `GameStoryData`→`ContentData`; `clearCachedList`→`clearCachedListBy{Id,Feed,IdAndFeed}`; `tags` removed from `StoryData`.
