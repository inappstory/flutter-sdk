## 0.0.17

### Changed

* IASSingleStoryHostApi storyId now `String show({required String storyId})`
* IASSingleStoryHostApi storyId now `String showOnce({required String storyId})`
* Android IASSingleStory opened with Activity Context

### Removed

* removed slide argument `IASSingleStoryHostApi.show()`

## 0.0.16

### Fixed

* open Android story reader with Activity Context (Application Context leads to new Task)
