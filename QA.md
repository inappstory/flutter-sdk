# QA Procedures — inappstory_plugin

## 1. PR Checklist
- All tests pass (`melos run test` or `flutter test`)
- Coverage threshold verified (`melos run coverage` or `scripts/coverage_check.sh`)
- Quality report generated (`melos run quality-report` or `scripts/quality_report.sh`)
- New code has corresponding tests
- No lint warnings (`flutter analyze`)
- Public API has dartdoc comments
- CHANGELOG.md updated for user-facing changes

## 2. Testing Pyramid
| Level | Tool | Scope | Speed | Example |
|---|---|---|---|---|
| Unit | `flutter test` / `melos run test` | Pure logic, data, callbacks | Fast (seconds) | observable_test.dart |
| Widget | `testWidgets` | Widget lifecycle, rendering | Fast (seconds) | feed_stories_widget_test.dart |
| Integration | `flutter test integration_test/` | Plugin ↔ native SDK via pigeon | Slow (minutes) | example/integration_test/ |
| E2E | Manual / Appium | Full app on device | Very slow | example app on device |

## 3. Quality Gates
- Minimum line coverage: 30% (target: 50%)
- Zero failing tests
- Zero lint errors
- Mutation score > 80% on business logic files

## 4. Running Tests & Quality Commands
```bash
# All unit tests
melos run test

# Single test file
flutter test test/observable_test.dart

# Single test by name
flutter test --plain-name 'THEN observers returns it'

# Run coverage check (with 30% threshold enforcement)
melos run coverage       # or ./scripts/coverage_check.sh

# Generate quality & test density report
melos run quality-report # or ./scripts/quality_report.sh

# Run mutation testing
melos run mutation-test  # or ./scripts/mutation_test.sh
```

## 5. Regression Testing
- When fixing a bug: write a failing test FIRST (see .agents/skills/diagnosing-bugs)
- Before release: run full test suite + mutation testing
- After dependency update: run full test suite

## 6. Manual QA Checklist (UI changes)
- [ ] Feed stories load and display correctly on Android
- [ ] Feed stories load and display correctly on iOS
- [ ] Story reader opens and navigates slides
- [ ] Favorites display and toggle
- [ ] Banner places load and rotate
- [ ] Onboarding stories show correctly
- [ ] In-app messages display and dismiss
- [ ] Error states handled gracefully (no connection, timeout)
- [ ] Deep links work correctly
- [ ] Video stories play with sound control
