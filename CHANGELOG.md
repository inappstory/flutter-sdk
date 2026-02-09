## [0.8.0]

### Added

- Cancellation of long-running actions

### Changed

- Onboardings, In-App-Messages and single stories now opens from `InAppStoryManager`
- `IShowStoryCallbackFlutterApi` changed to `IASShowStoryCallback` mixin
- `OnboardingLoadCallbackFlutterApi` changed to `IASOnboardingLoadCallback` mixin
- Updated iOS SDK to 1.27.1

## [0.7.2]

### Fixed

- BannerPlace stability improvements on Android

## [0.7.1]

### Added

- Feature to show multiple/same stories feed in one screen

### Changed

- `IASGameReaderCallback` method `finishGame` is now `Deprecated`, please use `closeGame` callback
- Updated iOS native SDK to 1.26.7
- Updated Android native SDK to 1.22.5

### Fixed

- Issue on android 12 and lower devices, when using back navigation in in-app-messages. Please
  see [migration guide](https://docs.inappstory.com/sdk-guides/flutter/migrations.html)!
- Memory leaks when using BannerPlaces
- After switching between applications or opening the built-in browser, banners may disappear
- Enable audio mixing for video previews in story list

### Removed

- Removed legacy `getStoriesWidgets()` and `getFavoritesStoriesWidgets()` methods from
  `InAppStoryPlugin` class

## [0.7.0]

### Added

- Checkout feature
- BannerPlace now support multiple banner places in one screen

### Fixed

- gestures on banners don't work, if the scrollable view is a parent element
- changing the banner placeId didn't reload the BannerPlace widget
- adding stories to favorites doesn't work on iOS devices in some cases
- fixed a crash when using anonymous mode and banners on iOS devices.

### Changed

- added more info and support multiple banner places in the `IASBannerPlaceCallback` mixin
- `IASGameReaderCallback` instead of old `GameReaderCallbackFlutterApi`
- updated iOS SDK to 1.26.3

## [0.6.1]

### Fixed

- class mismatch in Android part

## [0.6.0]

### Changed

- Updated Android SDK to 1.22.0
- Updated iOS SDK to 1.26.0

## [0.6.0-rc.1]

### Added

- Options feature
- Banners feature

### Changed

- Updated Android SDK to 1.22.0-rc7
- Updated iOS SDK to 1.26.0-rc9

## [0.5.5]

### Fixed

- scrolling to stories in feed in android devices has visual bugs

## [0.5.4]

### Added

- added custom logger

### Changed

- updated Android SDK, that includes internal fixes

## [0.5.2]

### Changed

- the way to scroll to the last viewed story

## [0.5.1]

### Added

- Added various options to `FeedStoryDecorator` to customize the transition to recently opened
  stories

### Fixed

- Visual bug when jumping to last viewed story after closing story reader

## [0.5.0]

### Added

- User sign feature
- User logout method
- Ability to change cache size on Android devices
- Anonymous mode
- Ability to change user settings

### Changed

- User change method, now it has an optional `userSign` parameter

### Fixed

- Issue when user can't close IAM by pressing back button or using back gesture on Android devices

## [0.4.1]

### Fixed

- Refactoring of ios story reader events logic

## [0.4.0]

### Added

- Sound control in story reader
- Custom icon appearance
- Ability to change cover quality in stories list
- Goods v1

### Changed

- AppearanceManager is now singleton class
- CallToAction callback is now mixin class
- Updated Android SDK to 1.21.16, that includes internal fixes
- Updated iOS SDK to 1.25.13, that includes internal fixes, make sure you run `pod install` or
  `pod install --repo update` command before building your app
- Changed 'favorites' logic implementation
- Various internal fixes

### Fixed

- Fixed issue when items not updated in grid favorites widget
- Bug when clearing cache on Android devices
- Issue when can't close in-app-message using system back button on Android devices

## [0.4.0-rc.4]

### Fixed

- changed 'favorites' logic implementation

## [0.4.0-rc.3]

### Fixed

- goods v1 implementation on Android
- fixed issue when items not updated in grid favorites widget

## [0.4.0-rc.2]

### Changed

- Updated Android SDK to 1.21.13
- Updated iOS SDK to 1.25.10

### Fixed

- Goods v1 callbacks
- Bug when clearing cache on Android devices
- Issue when can't close in-app-message using system back button on Android devices

## [0.4.0-rc.1]

### Added

- Sound control in story reader
- Custom icon appearance

### Changed

- AppearanceManager is now singleton class
- CallToAction callback is now mixin class
- Updated Android SDK to 1.21.11, that includes internal fixes
- Updated iOS SDK to 1.25.9, that includes internal fixes, make sure you run `pod install` or
  `pod install --repo update` command before building your app
- Various internal fixes

## [0.3.9]

### Fixed

- issue when game webhooks not working

## [0.3.8]

### Fixed

- issue when onCloseStory callback always returns 0 index in SlideData on android devices

## [0.3.7]

### Changed

- Updated Android SDK to 1.21.13, that includes internal fixes

## [0.3.6]

### Changed

- Updated Android SDK to 1.21.10, that includes internal fixes
- Updated iOS SDK to 1.25.8, that includes internal fixes, make sure you run `pod install` or
  `pod install --repo update` command before building your app

## [0.3.5]

### Changed

- Updated Android SDK to 1.21.7, that includes internal fixes
- Updated iOS SDK to 1.25.6, that includes internal fixes, make sure you run `pod install` or
  `pod install --repo update` command before building your app

## [0.3.4]

### Added

- Added locale parameter to initialization method
- Added method to change locale

### Changed

- Refactor InAppStoryManager, now you need to call `InAppStoryManager.instance` to access methods

## [0.3.3]

### Added

- Added `clearCache()` method in InAppStoryManager

### Changed

- Updated Android SDK to 1.21.6, that includes internal fixes
- Updated iOS SDK to 1.25.5, that includes internal fixes

## [0.3.2]

### Fixed

- internal fixes

## [0.3.1]

### Fixed

- Fixed flickering video covers

## [0.3.0]

### Added

- Added `FeedStoriesWidget`, `FavoritesStoriesWidget`, `StoryContentWidget` widgets
- Added video support for `FeedStoriesWidget` and `FavoritesStoriesWidget`
- Added border around stories in `FeedStoryDecorator`, that indicates the story has been opened
- Added `InAppMessages` feature, see documentation [here](in-app-messaging.md)
- Added `storiesLoaded` callback in `FeedStoriesWidget` and `FavoritesStoriesWidget` to listen when
  stories are loaded'

### Changed

- changed Android initialization to `InAppStoryPlugin.initSDK(this)` in `Application` class.
- `loaderBuilder` and `errorBuilder` parameters are now optional in `FeedStoriesWidget` widget
- `InAppStoryPlugin().getStoriesWidgets()` is deprecated, use `FeedStoriesWidget` instead
- `InAppStoryPlugin().getFavoritesStoriesWidgets()` is deprecated, use `FavoritesStoriesWidget`
  instead

### Fixed

- Fixed build error when android gradle plugin can't find main class path
- Fixed build error in iOS
- Fixed 'flickering' stories when an uploaded image replaced a placeholder

## [0.3.0-rc.5]

### Fixed

- Fixed build error in iOS

## [0.3.0-rc.4]

### Fixed

- Fixed build error when android gradle plugin can't find main class path

## [0.3.0-rc.3]

### Added

- Added border around stories in `FeedStoryDecorator`, that indicates the story has been opened

## [0.3.0-rc.2]

### Added

- Added `InAppMessages` feature, see documentation [here](in-app-messaging.md)

### Changed

- `loaderBuilder` and `errorBuilder` parameters are now optional in `FeedStoriesWidget` widget

## [0.2.3]

### Added

- Updated Android SDK to 1.21.4
- Updated iOS SDK to 1.25.4, make sure you run `pod install --repo-update` in the `ios` folder of
  your Flutter project.

### Fixed

- Like/Dislike buttons are not working in Android devices
- Placeholders in story feed are not working in iOS devices
- Fixed image caching issues in iOS devices

## [0.2.2]

### Added

- Added new callbacks for listening story reader events

### Changed

- Moved `IASCallBacksFlutterApi` code to `IASCallbacks` mixin class

## [0.3.0-rc.1]

### Added

- Added `FeedStoriesWidget`, `FavoritesStoriesWidget`, `StoryContentWidget` widgets
- Added video support for `FeedStoriesWidget` and `FavoritesStoriesWidget`

### Changed

- `InAppStoryPlugin().getStoriesWidgets()` is deprecated, use `FeedStoriesWidget` instead
- `InAppStoryPlugin().getFavoritesStoriesWidgets()` is deprecated, use `FavoritesStoriesWidget`
  instead
- refactor library structure

### Fixed

- Fixed 'flickering' stories when an uploaded image replaced a placeholder

## [0.2.1]

### Added

- Added interface for listening to story reader events

## [0.2.0]

### Added

- Added the ability to set the status bar to transparent for the story reader.
- Updated Android SDK to 1.21.2
- Updated iOS SDK to 1.25.2, make sure you run `pod install --repo-update` in the `ios` folder of
  your Flutter project.
- Added the ability to launch games
- FeedStoriesController to force reload the feed stories

### Changed

- Renamed `IShowStoryOnceCallbackFlutterApi` to `IShowStoryCallbackFlutterApi`
- Initializing Android native SDK, please watch README for details
- OnboardingLoadCallbackFlutterApi now has `onboardingLoadSuccess(int count, String feed)` and
  `onboardingLoadError(String feed, String? reason)` methods
- SingleLoadCallbackFlutterApi now has `singleLoadSuccess(StoryDataDto storyData)` and
  `singleLoadError(String feed, String? reason)` methods

### Removed

- Removed `loadOnboardingError()`, `loadSingleError()`, `readerError()` callbacks from
  ErrorCallbackFlutterApi

### Fixed

- Fixed a crash when calling `AppearanceManagerHostApi().setClosePosition(position)` in iOS devices
- Fixed a issue where cover images were lost after refreshing the story feed.

## [0.2.0-rc.5]

### Fixed

- Fixed a crash when calling `AppearanceManagerHostApi().setClosePosition(position)` in iOS devices

## [0.2.0-rc.4]

### Added

- Added the ability to set the status bar to transparent for the story reader.
- Updated Android SDK to 1.21.2
- Updated iOS SDK to 1.25.2, make sure you run `pod install --repo-update` in the `ios` folder of
  your Flutter project.

### Fixed

- Fixed a issue where cover images were lost after refreshing the story feed.

## [0.2.0-rc.3]

### Fixed

- Fixed crash when calling `InAppStoryManagerHostApi().closeReaders()` in Android device

## [0.2.0-rc.2]

### Changed

- Renamed `IShowStoryOnceCallbackFlutterApi` to `IShowStoryCallbackFlutterApi`

## [0.2.0-rc.1]

### Added

- Added ability to launch games

### Fixed

- error when initializing plugin in Java application class

## [0.1.0-rc.1]

### Changed

- Initializing Android native SDK, please watch README for details

## [0.0.20]

### Added

- Updated Android native sdk to 1.21.0

### Changed

- OnboardingLoadCallbackFlutterApi now has `onboardingLoadSuccess(int count, String feed)` and
  `onboardingLoadError(String feed, String? reason)` methods
- SingleLoadCallbackFlutterApi now has `singleLoadSuccess(StoryDataDto storyData)` and
  `singleLoadError(String feed, String? reason)` methods

### Removed

- Removed `loadOnboardingError()`, `loadSingleError()`, `readerError()` callbacks from
  ErrorCallbackFlutterApi

## [0.0.19]

### Added

- FeedStoriesController to force reload the feed stories

## [0.0.18]

### Added

- InAppStoryManagerHostApi.closeReaders() close all readers

## [0.0.17]

### Changed

- IASSingleStoryHostApi storyId now `String show({required String storyId})`
- IASSingleStoryHostApi storyId now `String showOnce({required String storyId})`
- Android IASSingleStory opened with Activity Context

### Removed

- removed slide argument `IASSingleStoryHostApi.show()`

## [0.0.16]

### Fixed

- open Android story reader with Activity Context (Application Context leads to new Task)
