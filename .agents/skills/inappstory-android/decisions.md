# Android IAS — decision guides

Choices the per-topic docs don't spell out in one place. Fetch the linked page for
the actual API once you've picked.

## Which stories UI do I use?

| Need | Use | Page |
|---|---|---|
| A horizontal/grid feed of stories on a screen | `StoriesList` | stories-list |
| Open one specific story by id (push, banner, deep link) | `showStory(storyId, …)` | single-story |
| Show once on first run, auto-open, no list | `showOnboardingStories(…)` | onboardings |
| Several independent named feeds on one screen | Multi-feed (`feed` param) | multi-feed |
| One collapsed entry point that expands a feed | Stack Feed (`getStackFeed`) | stack-feed |
| Non-story promo carousel with scratch-card | `BannerCarousel` | banners |

## Custom list cell: which interface?

- `IStoriesListItem` — full control of the cell view and bindings.
- `IStoriesListItemWithStoryData` — same, **when you need the `StoryData`** object
  in the bindings (1.18+). Choose this only if you actually read story fields.
- Remember: setting `IStoriesListItem` disables the other appearance params, and
  its `setImage/setVideo` run **off the main thread** (1.19+). See
  [pitfalls](pitfalls.md).

## Grid vs single row

- Single row: default.
- Grid: `csColumnCount(n)` **only together with** `csListItemRatio(...)` (and set
  the font size yourself). `csListItemWidth` is removed.

## Reader as activity or fragment?

- Since 1.18.0 the story/game reader can run as a **fragment** instead of an
  activity — pick per your navigation. → reader-presentation.

## Which callback for link/button taps?

- `CallToActionCallback` (current). **Not** `UrlClickCallback` (deprecated).
- Deep links: `ClickAction.DEEPLINK` (since 1.5.4). → events, link-handling.

## In-App Messaging version

- Method signature changed at **1.24.2** (presentation-container variant) and
  `ShowInAppMessageSlideCallback` at 1.24. Match the app's SDK version before
  writing the call. → in-app-messaging.

_All pages under `https://docs.inappstory.com/sdk-guides/android/<name>`._
