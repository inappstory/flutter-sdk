# Flutter IAS — decision guides

Choices the per-topic docs don't collect. Plugin `inappstory_plugin` (0.x).

## `MainActivity` base class — by plugin version

| Plugin version | Extend | Why |
|---|---|---|
| ≥ 0.7.1 | `InAppStoryActivity` | Back-button interception for IAM |
| 0.3.x–0.7.0 | `FlutterFragmentActivity` | required for IAM |
| < 0.3 | `FlutterActivity` | default |

On a modern version always use `InAppStoryActivity` — anything else breaks IAM
back-button handling.

## Calling the API — singleton vs old HostApi

- **Current (0.8.0+):** everything via `InAppStoryManager.instance.…` /
  `AppearanceManager.instance.…`.
- If you see `IASSingleStoryHostApi()`, `IASInAppMessagesHostApi()`,
  `AppearanceManagerHostApi()`, or `InAppStoryManagerHostApi()` in a project, it's
  pre-migration code — rewrite to the singletons. See [pitfalls](pitfalls.md).

## Which list widget

- **`FeedStoriesWidget(feed:)`** — current, customizable.
- `getStoriesWidgets()` / `getFavoritesStoriesWidgets()` — deprecated, being
  removed. Don't add new code on them.

## Callbacks — mixins

Implement the mixin, don't look for a delegate/HostApi callback:
`IASShowStoryCallback`, `IASOnboardingLoadCallback`, `IASGameReaderCallback`,
`IASCallToActionCallback`. Banner events → callbacks on the `BannerPlace` widget.

## cacheSize

Android-only (`CacheSize.small/medium/large`). No effect on iOS — don't rely on it
for cross-platform storage tuning.

_All pages under `https://docs.inappstory.com/sdk-guides/flutter/<name>`._
