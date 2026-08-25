# React Native IAS — decision guides

Package `@inappstory/react-native-sdk` (0.x). Choices the per-topic docs scatter.

## Android `MainActivity` base class — by version

- **≥ 0.27** → `InAppStoryActivity` + manifest `android:enableOnBackInvokedCallback="true"`
  (IAM back-button). On any current version, use this.
- **< 0.27** → `ReactActivity` (no IAM yet).

## `initSDK` call form — by version

- **≥ 0.28.0** → `InAppStory.initSDK(this as Application)`.
- **< 0.28.0** → `InAppStory.initSDK(getApplicationContext())`.
Using the wrong form for the version is a common Android init break.

## App version source

- Default: native `appVersion`/`appBundle`.
- **CodePush / OTA:** override via `StoryManagerConfig.appVersion` so version
  targeting isn't stuck at the store build. Pick this if you ship JS OTA.

## Coming from the legacy RN SDK?

Expect two breaks: font settings became separate fields (`fontSize`/`fontWeight`/
`fontFamily`), and `svgMask` is replaced by custom cells. See [pitfalls](pitfalls.md).

## Where the docs are thin

The RN guide is smaller than Android/iOS. For behavior it doesn't cover, the SDK
often mirrors native — fetch the matching Android or iOS page for the concept, then
map to the RN API.

_All pages under `https://docs.inappstory.com/sdk-guides/react-native/<name>`._
