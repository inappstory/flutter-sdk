// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:integration_test/integration_test.dart';

import 'banner_place_integration_test.dart' as banner_place_test;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  banner_place_test.main();
}
