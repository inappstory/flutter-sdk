# iOS IAS — decision guides

Choices the per-topic docs don't collect in one place. Fetch the linked page for
the API once you've chosen.

## UIKit or SwiftUI? (decide before installing)

The two are **separate SDKs** — you cannot switch cheaply later.

| | UIKit | SwiftUI |
|---|---|---|
| Dependency | `InAppStory` | `InAppStory_SwiftUI` (tag `…-SwiftUI`) |
| Import | `InAppStorySDK` | `InAppStorySDK_SwiftUI` |
| Min iOS | 11 | 13 |
| List | `StoryView` (frame + `.create()`) | `StoryListView` |
| Actions | delegate (≤1.21) / closures (≥1.22) | `.onAction/.onUpdate/.onDismiss` modifiers |

Pick SwiftUI only if the app's UI is SwiftUI-native; otherwise UIKit.

## Which action-handling API? (by SDK version — the key fork)

- **≤ 1.21.x** → `InAppStoryDelegate` (`storiesDelegate`).
- **1.22.x** → closures (`InAppStory.shared.onActionWith` / per-list); delegate deprecated.
- **≥ 1.23.0** → closures **only**; delegates removed. Lifecycle events via
  `storiesEvent`/`gameEvent`/`failureEvent`, **not** NotificationCenter.

Always confirm the version before writing action code — see [pitfalls](pitfalls.md).

## Which content entry point?

| Need | Use | Page |
|---|---|---|
| Feed/list on a screen | `StoryView`/`StoryListView` | story-view / story-list-view |
| One story by id (push/deep link/banner) | `showSingle(...)` | single-story |
| Auto-show once per user | `showOnboardings(...)` | onboardings |
| Several feeds separated by screen/user | Multi-feed (`feed:` param) | multi-feed |
| Collapsed single entry point | Stack Feed | stack-feed |
| Promo carousel (non-story) | Banners place | banners |

## In-App Messaging version

- **≥ 1.28**: `inAppMessageWillShow` is `(id, event, presentType) -> UIView?`;
  `showInAppMessageWith` takes `targetView`; SwiftUI container registry via
  `.inAppMessageContainer()`. Use in-app-messaging-v2.
- **< 1.28**: zero-arg `inAppMessageWillShow`, no `targetView`. Use the older
  in-app-messaging page. Match the app's version before writing the callback.

## Reader as presented controller

- Show a modal over the reader with the merged `present(controller:for:with:)`
  (1.22+). → screen-presenting.

_All pages under `https://docs.inappstory.com/sdk-guides/ios/<name>`._
