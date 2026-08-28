# Flutter IAS — task playbooks

Recipes across pages. Plugin `inappstory_plugin` (0.x). Verify the version in
`pubspec.yaml`; read [pitfalls](pitfalls.md) alongside — the native Android setup
is the usual failure point.

Before any recipe, run the **Intake** (SKILL.md): clarify an underspecified
request (*where* / *which* feature), and on a first integration ask the user for
their integration key (`apiKey`).

## Add a stories feed (first-time integration)

1. **Add the dep:** `flutter pub add inappstory_plugin` (or pin in `pubspec.yaml`).
2. **Android native (mandatory):**
   - `app/build.gradle`: `minSdkVersion = 23`, compile/target 34, and
     `manifestPlaceholders['applicationName'] = '<your Application class>'`.
   - In your `Application.onCreate()`: `InAppStoryPlugin.initSDK(this)`.
   - `MainActivity` extends `InAppStoryActivity` (not `FlutterActivity`).
3. **iOS native:** `pod install` in `ios/`.
4. **Init (Dart, async):** `await InAppStoryPlugin().initWith('<apiKey>', '<userId>',
   locale:, cacheSize: CacheSize.medium)`.
5. **Show the feed:** put `FeedStoriesWidget(feed: '<feedId>')` in the tree, gated
   behind the init `Future` (e.g. `FutureBuilder`).
   → [how-to-get-started](https://docs.inappstory.com/sdk-guides/flutter/how-to-get-started),
   [feed-stories-widget](https://docs.inappstory.com/sdk-guides/flutter/feed-stories-widget)

## Show onboardings / single story / IAM (0.8.0+ API)

All go through the `InAppStoryManager.instance` singleton:
- Onboardings: `InAppStoryManager.instance.showOnboardings(limit)`.
  → [onboardings](https://docs.inappstory.com/sdk-guides/flutter/onboardings)
- Single story: `showStory(storyId)` / `showStoryOnce(storyId)`.
  → [single-story](https://docs.inappstory.com/sdk-guides/flutter/single-story)
- In-App Messaging: `showIAMById(id)` / `showIAMByEvent(event)` /
  `preloadInAppMessages()`. Requires the `InAppStoryActivity` back-button setup.
  → [in-app-messaging](https://docs.inappstory.com/sdk-guides/flutter/in-app-messaging)

## Change user / appearance

- Switch user: `InAppStoryManager.instance.changeUser('<newUserId>')`.
  → [in-app-story-manager](https://docs.inappstory.com/sdk-guides/flutter/in-app-story-manager),
  [user-settings](https://docs.inappstory.com/sdk-guides/flutter/user-settings)
- Appearance: `AppearanceManager.instance.…` (singleton since 0.4.0).
  → [appearance-manager](https://docs.inappstory.com/sdk-guides/flutter/appearance-manager)

## Add banners

`BannerPlace(placeId:, height:, onBannerScroll: (i){…})` — listen via widget
callbacks (the old `IASBannerPlaceCallback` mixin was removed in 0.7.6).
→ [banners](https://docs.inappstory.com/sdk-guides/flutter/banners)
