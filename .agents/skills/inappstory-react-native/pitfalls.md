# React Native IAS — pitfalls & version traps

Distilled from get-started / migrations. Package
`@inappstory/react-native-sdk` (0.x). Check the version in `package.json` and fetch
[migrations](https://docs.inappstory.com/sdk-guides/react-native/migrations) for deltas.

## Native setup is mandatory — the JS package alone won't run

- **iOS: static frameworks required.** In the `Podfile`:
  `use_frameworks! :linkage => :static` (or `USE_FRAMEWORKS=static`). Without it the
  pod install / build fails.
- **Android `MainApplication.onCreate`:** `InAppStory.initSDK(this as Application)`.
  The `this as Application` form is **0.28.0+**; older versions used
  `InAppStory.initSDK(getApplicationContext())`. Call it before `loadReactNative(this)`.
- **Android `MainActivity` must extend `InAppStoryActivity`** (since 0.27, when IAM
  landed) — not `ReactActivity`. It intercepts the hardware **Back** button so IAM
  closes correctly; wrong base class → Back bypasses the SDK.
- **`AndroidManifest.xml`:** add `android:enableOnBackInvokedCallback="true"` on the
  `MainActivity` (0.27+) for correct predictive-back behavior.
- **Android SDK versions:** `minSdkVersion = 23`, compile/target 34.

## StoryManager config

- Create with `new StoryManager(config: StoryManagerConfig)`; `apiKey` is required.
- **App-version targeting:** by default appVersion/appBundle come from native. For
  **CodePush** users, override via `StoryManagerConfig.appVersion = {version, build}`
  so targeting-by-version keeps working after an OTA update.

## Migrating from the legacy RN SDK

- **Fonts are now separate fields** (`fontSize`, `fontWeight`, `fontFamily`), not a
  single string. Old string font settings won't map.
- **`svgMask` in `appearanceManager` is gone** — achieve the same with
  [custom cells](https://docs.inappstory.com/sdk-guides/react-native/appearance).

## Note

The RN docs are leaner than native — for anything not covered here, fetch the
topic page; several features delegate to native behavior documented on the
Android/iOS guides.
