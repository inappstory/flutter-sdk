## [0.3.0-rc.1] - 2025-04-28

* Added `FeedStoriesWidget`, `FavoritesStoriesWidget`, `StoryContentWidget` widgets
* Added video support for `FeedStoriesWidget` and `FavoritesStoriesWidget`

### Changed

* `InAppStoryPlugin().getStoriesWidgets()` is deprecated, use `FeedStoriesWidget` instead
* `InAppStoryPlugin().getFavoritesStoriesWidgets()` is deprecated, use `FavoritesStoriesWidget` instead
* refactor library structure

### Fixed

* Fixed 'flickering' stories when an uploaded image replaced a placeholder

## [0.2.0] - 2025-04-25

### Added

* Added the ability to set the status bar to transparent for the story reader.
* Updated Android SDK to 1.21.2
* Updated iOS SDK to 1.25.2, make sure you run `pod install --repo-update` in the `ios` folder of your Flutter project.
* Added the ability to launch games
* FeedStoriesController to force reload the feed stories

### Changed

* Renamed `IShowStoryOnceCallbackFlutterApi` to `IShowStoryCallbackFlutterApi`
* Initializing Android native SDK, please watch README for details
* OnboardingLoadCallbackFlutterApi now has `onboardingLoadSuccess(int count, String feed)` and
  `onboardingLoadError(String feed, String? reason)` methods
* SingleLoadCallbackFlutterApi now has `singleLoadSuccess(StoryDataDto storyData)` and
  `singleLoadError(String feed, String? reason)` methods

### Removed

* Removed `loadOnboardingError()`, `loadSingleError()`, `readerError()` callbacks from ErrorCallbackFlutterApi

### Fixed

* Fixed a crash when calling `AppearanceManagerHostApi().setClosePosition(position)` in iOS devices
* Fixed a issue where cover images were lost after refreshing the story feed.

## [0.2.0-rc.5] - 2025-04-24

### Fixed

* Fixed a crash when calling `AppearanceManagerHostApi().setClosePosition(position)` in iOS devices

## [0.2.0-rc.4] - 2025-04-23

### Added

* Added the ability to set the status bar to transparent for the story reader.
* Updated Android SDK to 1.21.2
* Updated iOS SDK to 1.25.2, make sure you run `pod install --repo-update` in the `ios` folder of your Flutter project.

### Fixed

* Fixed a issue where cover images were lost after refreshing the story feed.

## [0.2.0-rc.3] - 2025-04-22

### Fixed

* Fixed crash when calling `InAppStoryManagerHostApi().closeReaders()` in Android device

## [0.2.0-rc.2] - 2025-04-15

### Changed

* Renamed `IShowStoryOnceCallbackFlutterApi` to `IShowStoryCallbackFlutterApi`

## [0.2.0-rc.1] - 2025-04-15

### Added

* Added ability to launch games

### Fixed

* error when initializing plugin in Java application class

## [0.1.0-rc.1] - 2025-04-10

### Changed

* Initializing Android native SDK, please watch README for details

## [0.0.20] - 2025-04-09

### Added

* Updated Android native sdk to 1.21.0

### Changed

* OnboardingLoadCallbackFlutterApi now has `onboardingLoadSuccess(int count, String feed)` and
  `onboardingLoadError(String feed, String? reason)` methods
* SingleLoadCallbackFlutterApi now has `singleLoadSuccess(StoryDataDto storyData)` and
  `singleLoadError(String feed, String? reason)` methods

### Removed

* Removed `loadOnboardingError()`, `loadSingleError()`, `readerError()` callbacks from ErrorCallbackFlutterApi

## [0.0.19]

### Added

* FeedStoriesController to force reload the feed stories

## [0.0.18]

### Added

* InAppStoryManagerHostApi.closeReaders() close all readers

## [0.0.17]

### Changed

* IASSingleStoryHostApi storyId now `String show({required String storyId})`
* IASSingleStoryHostApi storyId now `String showOnce({required String storyId})`
* Android IASSingleStory opened with Activity Context

### Removed

* removed slide argument `IASSingleStoryHostApi.show()`

## [0.0.16]

### Fixed

* open Android story reader with Activity Context (Application Context leads to new Task)
