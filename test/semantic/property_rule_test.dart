import 'package:firstfloor_calendar/firstfloor_calendar.dart';
import 'package:test/test.dart';

void main() {
  group('PropertyRule tests', () {
    test('PropertyRule with default values', () {
      final rule = PropertyRule(
        parser: (line) => null, // Dummy parser for testing
      );

      expect(rule.minOccurs, 0);
      expect(rule.maxOccurs, 1);
      expect(rule.parser, isNotNull);
    });

    test('PropertyRule with custom minOccurs and maxOccurs', () {
      final rule = PropertyRule(
        minOccurs: 1,
        maxOccurs: 5,
        parser: (line) => null,
      );

      expect(rule.minOccurs, 1);
      expect(rule.maxOccurs, 5);
      expect(rule.parser, isNotNull);
    });

    test('PropertyRule assertions', () {
      expect(
        () => PropertyRule(minOccurs: -1, parser: (line) => null),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => PropertyRule(minOccurs: 2, maxOccurs: 1, parser: (line) => null),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
