# React Native IAS — task playbooks

Recipes across pages. Package `@inappstory/react-native-sdk` (0.x). Verify the
version in `package.json`; read [pitfalls](pitfalls.md) — native host setup is the
usual failure point.

Before any recipe, run the **Intake** (SKILL.md): clarify an underspecified
request (*where* / *which* feature), and on a first integration ask the user for
their integration key (`apiKey`).

## Add stories (first-time integration)

1. **Install:** `npm install @inappstory/react-native-sdk` (or yarn).
2. **iOS:** Podfile `use_frameworks! :linkage => :static`, then `pod install`.
3. **Android native:**
   - `build.gradle`: `minSdkVersion = 23`, compile/target 34.
   - `MainApplication.onCreate`: `InAppStory.initSDK(this as Application)` before
     `loadReactNative(this)`.
   - `MainActivity` extends `InAppStoryActivity`.
   - `AndroidManifest.xml`: `android:enableOnBackInvokedCallback="true"`.
4. **JS side:** `const storyManager = new StoryManager({ apiKey })` and render the
   stories list component.
   → [how-to-get-started](https://docs.inappstory.com/sdk-guides/react-native/how-to-get-started),
   [stories-list](https://docs.inappstory.com/sdk-guides/react-native/stories-list)

## Feature entry points

- In-App Messaging — needs the `InAppStoryActivity` + manifest back-button setup.
  → [in-app-messaging](https://docs.inappstory.com/sdk-guides/react-native/in-app-messaging)
- Games → [games](https://docs.inappstory.com/sdk-guides/react-native/games),
  Goods / product cart → [goods](https://docs.inappstory.com/sdk-guides/react-native/goods)
- Banners → [banners](https://docs.inappstory.com/sdk-guides/react-native/banners),
  Call To Action → [call-to-action](https://docs.inappstory.com/sdk-guides/react-native/call-to-action)

## CodePush / OTA: keep version targeting working

Override native app version in the config so story targeting-by-version survives OTA:
```ts
const config: StoryManagerConfig = { apiKey, appVersion: { version: '3.0.0', build: 777 } };
```

## Personalize & switch user

Tags / user via `StoryManagerConfig` and the manager API.
→ [tags](https://docs.inappstory.com/sdk-guides/react-native/tags),
[user-settings](https://docs.inappstory.com/sdk-guides/react-native/user-settings)
