# JS SDK IAS — decision guides

Package `@inappstory/js-sdk` (3.x). Choices the per-topic docs scatter.

## NPM or CDN?

| | NPM | CDN |
|---|---|---|
| Import | `import { InAppStoryManager, AppearanceManager }` | `window.IAS.InAppStoryManager` etc. |
| Timing | bundler handles it | construct inside `DOMContentLoaded` |
| Use when | you have a build step | plain HTML / no bundler |

Either way the mount `<div id="stories_widget">` must exist before construction.

## `StoryManager` or `InAppStoryManager`?

- **JS SDK 3+** → `InAppStoryManager`. `StoryManager` is the old (v2) name.
- If a project still says `new StoryManager(...)`, it's pre-3 code — rename when
  upgrading. See [pitfalls](pitfalls.md).

## Anonymous vs identified

- `anonymous: true` (v3.6.6+): quick start but **limited functionality**. For full
  features pass a real `userId` (+ `userIdSign` if the console enforces signing).

## Which entry point?

| Need | Use | Page |
|---|---|---|
| Feed list on the page | `StoriesList` | feeds |
| One story by id | single-story API | single-story |
| Auto-show once | onboardings API | onboardings |
| Collapsed single entry | Stack Feed | stack-feed |
| In-app message | IAM API | in-app-messaging |

## Browser support / CSP

- Old browsers → the `es5-compatible` build.
- Host CSP → apply the SDK's directives (CSP page) before debugging blank widgets.

_All pages under `https://docs.inappstory.com/sdk-guides/js-sdk/<name>`._
