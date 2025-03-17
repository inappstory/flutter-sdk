# inappstory_plugin_example

Demonstrates how to use the inappstory_plugin plugin.

## Getting Started

Change your api key & user

```
_MyAppState.initSdk() {
    await _inAppStoryPlugin.initWith('<your key>', '<some user id>', false);
    ...
}
```

Then paste yout feed identifier

```
_SimpleFeedExampleState {
    static const feed = '<your feed id>';
}
```
