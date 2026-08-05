import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/src/data/observable.dart';

void main() {
  group('GIVEN $Observable', () {
    late Observable<String> observable;

    setUp(() {
      observable = Observable<String>();
    });

    group('WHEN an observer is added', () {
      test('THEN observers returns it', () {
        observable.addObserver('observer1');
        expect(observable.observers, contains('observer1'));
      });

      test('AND it is added twice THEN observers has a single entry', () {
        observable.addObserver('observer1');
        observable.addObserver('observer1');
        expect(observable.observers.length, equals(1));
      });
    });

    group('WHEN an observer is removed', () {
      test('THEN observers no longer contains it', () {
        observable.addObserver('observer1');
        observable.removeObserver('observer1');
        expect(observable.observers, isEmpty);
      });

      test('AND it does not exist THEN no error is thrown', () {
        expect(() => observable.removeObserver('non-existent'), returnsNormally);
      });
    });

    group('WHEN observers is accessed', () {
      test('THEN it returns an unmodifiable set', () {
        observable.addObserver('observer1');
        expect(
          () => (observable.observers as Set<String>).add('observer2'),
          throwsUnsupportedError,
        );
      });
    });
  });
}
