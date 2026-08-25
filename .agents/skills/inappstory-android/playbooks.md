# Android IAS — task playbooks

End-to-end recipes that span several doc pages. Each step lists the **exact call**
and the page to fetch for detail. Version notes reflect ~1.25.x — verify against
the app's actual SDK version. Always read [pitfalls](pitfalls.md) alongside.

Before any recipe, run the **Intake** (SKILL.md): clarify an underspecified
request (*where* / *which* feature), and on a first integration ask the user for
their integration key (`apiKey` / `csApiKey`).

## Add a stories feed (the list on a screen)

1. **Gradle** — jitpack repo + `com.github.inappstory:android-sdk`, plus
   `androidx.recyclerview:recyclerview` and `androidx.webkit:webkit`.
   → [how-to-get-started](https://docs.inappstory.com/sdk-guides/android/how-to-get-started)
2. **Init once** in `Application`: `InAppStoryManager.initSdk(context)` (1.18+).
3. **Create the manager** (anywhere with context): `InAppStoryManager.Builder()
   .apiKey(key).userId(id[, userSign]).tags(...).create()`. apiKey may instead live
   in `values/constants.xml` as `csApiKey`.
   → [inappstory-manager](https://docs.inappstory.com/sdk-guides/android/inappstory-manager)
4. **Add the view**: `<com.inappstory.sdk.stories.ui.list.StoriesList …/>` in XML.
5. **(Optional) appearance**: build an `AppearanceManager`, set via
   `storiesList.setAppearanceManager(am)` or `AppearanceManager.setCommonInstance(am)`.
   → [appearance](https://docs.inappstory.com/sdk-guides/android/appearance)
6. **Load**: `storiesList.loadStories()` (also used to reload / pull-to-refresh).
   Wrap it — it can throw `DataException` if init hasn't completed.
   → [stories-list](https://docs.inappstory.com/sdk-guides/android/stories-list)

## Show onboarding stories (auto-show, no list)

1. Init as above.
2. `InAppStoryManager.getInstance().showOnboardingStories(context, appearanceManager)`
   — `appearanceManager` may be null (common one is used). Tag-targeted overload:
   `showOnboardingStories(tags, context, appearanceManager)`.
3. Handle load result via `OnboardingLoadCallback`; returns a `CancellationToken`
   (1.23+) if you need to cancel.
   → [onboardings](https://docs.inappstory.com/sdk-guides/android/onboardings)

## Open a single story (e.g. from a push notification)

1. Init as above.
2. In the push handler: `InAppStoryManager.getInstance().showStory(storyId, context,
   appearanceManager, IShowStoryCallback)`.
   → [single-story](https://docs.inappstory.com/sdk-guides/android/single-story),
   FAQ "Opening stories from push notifications".

## Add In-App Messaging

1. Init as above.
2. `showInAppMessage(...)` — **the method signature changed in 1.24.2** (new version
   takes a presentation container) and `ShowInAppMessageSlideCallback` changed in
   1.24. Fetch the page and match the app's SDK version before writing the call.
   → [in-app-messaging](https://docs.inappstory.com/sdk-guides/android/in-app-messaging)

## Switch user / logout

- Logout (clears cached lists + session): `InAppStoryManager.getInstance().userLogout()`
  (1.21+). Optionally pass `InAppStoryUserSettings().tags(...).placeholders(...)`.
- Change everything at once: `userSettings(InAppStoryUserSettings().userId(id, sign)
  .lang(...).tags(...).placeholders(...))`.
- Just the id: `setUserId(userId[, userSign])` — auto-refreshes all `StoriesList`s.
  → [user-settings](https://docs.inappstory.com/sdk-guides/android/user-settings)

## Personalize content (tags & placeholders)

- **Tags** target which stories/onboardings appear: `.tags(...)` at init, or
  `setTags/addTags/removeTags` later.
- **Placeholders** replace `%variables%` in story content: `.placeholders(map)` /
  `setPlaceholder(key, value)`; image variants via `imagePlaceholders` /
  `ImagePlaceholderValue`.
  → [inappstory-manager](https://docs.inappstory.com/sdk-guides/android/inappstory-manager),
  [placeholders](https://docs.inappstory.com/sdk-guides/android/placeholders),
  [tags](https://docs.inappstory.com/sdk-guides/android/tags)
