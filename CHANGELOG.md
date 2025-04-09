## [0.0.20] - 2025-04-09

### Added

* Updated Android native sdk to 1.21.0 

### Changed

* OnboardingLoadCallbackFlutterApi now has `onboardingLoadSuccess(int count, String feed)` and `onboardingLoadError(String feed, String? reason)` methods
* SingleLoadCallbackFlutterApi now has `singleLoadSuccess(StoryDataDto storyData)` and `singleLoadError(String feed, String? reason)` methods

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
