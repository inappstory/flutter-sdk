# React IAS — decision guides

Package `@inappstory/react-sdk`. Choices the per-topic docs scatter.

## Where does a config field go?

- **`StoryManagerConfig`** (on `<IASContainer config={…}>`): identity & data —
  `apiKey`, `userId`, `userIdSign`, `tags`, `placeholders`, `imagePlaceholders`,
  `lang`, `dir`, `anonymous`, `cache`, `hybridApp`.
- **`commonOptions`**: shared UI toggles (`hasShare/hasLike/hasFavorite`).
- **`storiesListOptions`** / **`storyReaderOptions`**: list- vs reader-specific UI.

Putting data config into the options objects (or vice-versa) is the usual mix-up.

## Which feed?

- Default feed: `feedSlug="default"`.
- Favorites: `hasFavorite={true}` on `<StoryList>`.
- Multiple feeds: separate `<StoryList feedSlug="…">` instances.

## Anonymous vs identified session

- `anonymous: true` (v3.6.6+) — quick start, **but not all functionality is
  available**. Use only for previews / logged-out states; switch to a real `userId`
  (+ `userIdSign` if the console enforces signing) for full features.

## Events: container props vs manager instance

- Simple: `on…` props on `<IASContainer>`.
- Advanced (subscribe/unsubscribe dynamically, multiple handlers): a `storyManager`
  instance. Don't mix both for the same event.

## Browser support / CSP

- Old browsers → the `es5-compatible` build.
- App enforces CSP → apply the SDK's directives (see the CSP page) before assuming
  a bug.

_All pages under `https://docs.inappstory.com/sdk-guides/react-sdk/<name>`._
