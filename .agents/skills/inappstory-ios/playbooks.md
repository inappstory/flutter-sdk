# iOS IAS — task playbooks

End-to-end recipes across doc pages. **Every recipe forks on UIKit vs SwiftUI** —
confirm which the app uses first (see [pitfalls](pitfalls.md)). Versions reflect
~1.29.x; verify against the app's actual tag. Fetch the linked page for exact,
current signatures before writing the call.

Before any recipe, run the **Intake** (SKILL.md): clarify an underspecified
request (*where* / *which* feature), and on a first integration ask the user for
their integration key (`serviceKey`).

## Add a stories list

1. **Pick framework & install the matching dependency.**
   - UIKit: pod `InAppStory` (tag `X.Y.Z`), `import InAppStorySDK`, iOS ≥ 11.
   - SwiftUI: pod `InAppStory_SwiftUI` (tag `X.Y.Z-SwiftUI`),
     `import InAppStorySDK_SwiftUI`, iOS ≥ 13.
   → [how-to-get-started](https://docs.inappstory.com/sdk-guides/ios/how-to-get-started)
2. **Init in `AppDelegate`:** `InAppStory.shared.initWith(serviceKey: <api-key>,
   settings: Settings(userID: <id>, tags: <[String]>))`. userID/tags may be set
   later via `InAppStory.shared.settings` before creating the list. Optional
   appearance (`isLoggingEnabled`, `cellGradientEnabled`, `panelSettings`,
   `presentationStyle`) also goes here. → [inappstory](https://docs.inappstory.com/sdk-guides/ios/inappstory)
3. **Create the list:**
   - UIKit: `storyView = StoryView(frame:)`; set params + closures/delegate;
     `view.addSubview(storyView)`; **`storyView.create()`**.
     → [story-view](https://docs.inappstory.com/sdk-guides/ios/story-view)
   - SwiftUI: place `StoryListView(...)` with settings in the init.
     → [story-list-view](https://docs.inappstory.com/sdk-guides/ios/story-list-view)
4. **Handle actions — pick by version** (see pitfalls "Action handling"):
   - ≤1.21: `InAppStoryDelegate` on `storiesDelegate`.
   - 1.22: `InAppStory.shared.onActionWith` / `.storiesDidUpdated` (or per-list).
   - ≥1.23: closures only; events via `InAppStory.shared.storiesEvent`.

## Show onboardings

1. Init as above.
2. `InAppStory.shared.showOnboardings(feed:limit:from:with:delegate:with:complete:)`
   — `feed:""` uses the default `Onboarding` feed; `tags` override targeting;
   returns a `CancellationToken?`. **Onboardings show once per user.** The exact
   handler param (delegate vs closure) is version-sensitive — fetch the page.
   → [onboardings](https://docs.inappstory.com/sdk-guides/ios/onboardings)

## Open a single story (deep link / push / banner)

1. Init as above.
2. `showSingle(...)` (renamed from `showSingleStory` in older SDKs).
   → [single-story](https://docs.inappstory.com/sdk-guides/ios/single-story)

## Add In-App Messaging (≥1.28 API)

1. Init as above; optionally set `InAppStory.shared.inAppMessageWillShow =
   { id, event, presentType in … return nil }` (new 3-arg signature — see pitfalls).
2. Show: `showInAppMessageWith(id:targetView:onlyPreloaded:completion:)` or
   `showInAppMessageWith(event:targetView:onlyPreloaded:tags:completion:)`.
   SwiftUI: register a container with `.inAppMessageContainer()` and show via
   `showIAMWith(id:inContainer:...)`.
   → [in-app-messaging-v2](https://docs.inappstory.com/sdk-guides/ios/in-app-messaging-v2),
   examples: [SwiftUI](https://docs.inappstory.com/sdk-guides/ios/in-app-messaging-examples-swiftui) /
   [UIKit](https://docs.inappstory.com/sdk-guides/ios/in-app-messaging-examples-uikit)

## Subscribe to events (≥1.23)

Closures, not NotificationCenter:
```swift
InAppStory.shared.storiesEvent = { event in /* IASEvent.Story.* */ }
InAppStory.shared.gameEvent    = { event in /* IASEvent.Game.* */ }
InAppStory.shared.failureEvent = { event in /* IASEvent.Failure.* */ }
```
→ [events](https://docs.inappstory.com/sdk-guides/ios/events),
[reference](https://docs.inappstory.com/sdk-guides/ios/reference)

## Switch user / change settings

Reassign `InAppStory.shared.settings = Settings(userID:tags:)` (respect the 255B /
4000B limits) **before** re-creating lists; readers refresh accordingly.
→ [user-settings](https://docs.inappstory.com/sdk-guides/ios/user-settings)
