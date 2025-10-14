import 'package:firstfloor_calendar/firstfloor_calendar.dart';
import 'package:test/test.dart';

void main() {
  void testDuration(String input, CalDuration expected) =>
      test('Parse DURATION: $input', () {
        final property = DocumentParser.parseProperty('DURATION:$input');
        final duration = parseCalDuration(property);
        expect(duration, isA<CalDuration>());
        expect(duration, expected);
      });

  void testDurationError(String input, String errorMessage) =>
      test('Parse DURATION: $input should throw $errorMessage', () {
        final property = DocumentParser.parseProperty('DURATION:$input');

        expect(
          () => parseCalDuration(property),
          throwsA(
            predicate((e) => e.toString() == 'ParseException: $errorMessage'),
          ),
        );
      });

  void testUtcOffset(String input, UtcOffset expected) =>
      test('Parse UTC-OFFSET: $input', () {
        final property = DocumentParser.parseProperty('TZOFFSETTO:$input');
        final offset = parseUtcOffset(property);
        expect(offset, isA<UtcOffset>());
        expect(offset, expected);
      });

  void testUtcOffsetError(String input, String errorMessage) =>
      test('Parse UTC-OFFSET: $input should throw $errorMessage', () {
        final property = DocumentParser.parseProperty('TZOFFSETTO:$input');

        expect(
          () => parseUtcOffset(property),
          throwsA(
            predicate((e) => e.toString() == 'ParseException: $errorMessage'),
          ),
        );
      });

  group('Parse DURATION', () {
    testDuration('PT1H30M', CalDuration(hours: 1, minutes: 30));
    testDuration('-P0DT0H30M0S', CalDuration(sign: Sign.negative, minutes: 30));
    testDuration('P1D', CalDuration(days: 1));
    testDuration('P1W', CalDuration(weeks: 1));
    testDuration('P1W2D', CalDuration(weeks: 1, days: 2));
    testDuration('P1DT', CalDuration(days: 1)); // we allow empty time part
    testDuration('PT2H', CalDuration(hours: 2));
    testDuration('PT1H2M', CalDuration(hours: 1, minutes: 2));
    testDuration('PT1H2M3S', CalDuration(hours: 1, minutes: 2, seconds: 3));
    testDuration(
      'P1W4DT3H4M2S',
      CalDuration(weeks: 1, days: 4, hours: 3, minutes: 4, seconds: 2),
    );

    testDurationError(
      'PT1H2H30M',
      'Expected one of ["M", "S"], found "H" [Ln 0, Col 5]',
    );
    testDurationError('', 'Expected "P", found "<endOfLine>" [Ln 0, Col 0]');
    testDurationError('P', 'No DURATION components found in "P" [Ln 0, Col 2]');
    testDurationError('T', 'Expected "P", found "T" [Ln 0, Col 0]');
    testDurationError('FOO', 'Expected "P", found "F" [Ln 0, Col 0]');
    testDurationError(
      'PT',
      'No DURATION components found in "PT" [Ln 0, Col 3]',
    );
    testDurationError(
      '-PT',
      'No DURATION components found in "-PT" [Ln 0, Col 4]',
    );
    testDurationError(
      'P1D2D',
      'Expected "<endOfLine>", found "2" [Ln 0, Col 3]',
    );
    testDurationError(
      'P1W2W',
      'Expected one of ["D"], found "W" [Ln 0, Col 4]',
    );
    testDurationError(
      'P1W2H',
      'Expected one of ["D"], found "H" [Ln 0, Col 4]',
    );
    testDurationError(
      'P1D2W',
      'Expected "<endOfLine>", found "2" [Ln 0, Col 3]',
    );
    testDurationError(
      'P1D2M',
      'Expected "<endOfLine>", found "2" [Ln 0, Col 3]',
    );
    testDurationError(
      'P1D2Y',
      'Expected "<endOfLine>", found "2" [Ln 0, Col 3]',
    );
    testDurationError(
      'P1Y2M3D4H5M6S',
      'Expected one of ["W", "D"], found "Y" [Ln 0, Col 2]',
    );
  });

  group('Parse UTC-OFFSET', () {
    testUtcOffset(
      '+0000',
      UtcOffset(sign: Sign.positive, hours: 0, minutes: 0),
    );
    testUtcOffset(
      '+000000',
      UtcOffset(sign: Sign.positive, hours: 0, minutes: 0),
    );
    testUtcOffset(
      '+0100',
      UtcOffset(sign: Sign.positive, hours: 1, minutes: 0),
    );
    testUtcOffset(
      '+0201',
      UtcOffset(sign: Sign.positive, hours: 2, minutes: 1),
    );
    testUtcOffset(
      '+030100',
      UtcOffset(sign: Sign.positive, hours: 3, minutes: 1),
    );
    testUtcOffset(
      '+040101',
      UtcOffset(sign: Sign.positive, hours: 4, minutes: 1, seconds: 1),
    );
    testUtcOffset(
      '-0100',
      UtcOffset(sign: Sign.negative, hours: 1, minutes: 0),
    );
    testUtcOffset(
      '-0201',
      UtcOffset(sign: Sign.negative, hours: 2, minutes: 1),
    );
    testUtcOffset(
      '-030100',
      UtcOffset(sign: Sign.negative, hours: 3, minutes: 1),
    );
    testUtcOffset(
      '-040101',
      UtcOffset(sign: Sign.negative, hours: 4, minutes: 1, seconds: 1),
    );

    testUtcOffsetError(
      '',
      'Expected one of ["+", "-"], found "<endOfLine>" [Ln 0, Col 0]',
    );
    testUtcOffsetError(
      '10',
      'Expected one of ["+", "-"], found "1" [Ln 0, Col 0]',
    );
    testUtcOffsetError('+10', 'Expected 2 characters, found 0 [Ln 0, Col 3]');
    testUtcOffsetError('+100', 'Expected 2 characters, found 1 [Ln 0, Col 3]');
    testUtcOffsetError(
      '+10000',
      'Expected 2 characters, found 1 [Ln 0, Col 5]',
    );
    testUtcOffsetError(
      '+1000000',
      'Expected "<endOfLine>", found "0" [Ln 0, Col 7]',
    );
    testUtcOffsetError(
      '-0000',
      'Negative zero UTC offset is not allowed [Ln 0, Col 6]',
    );
    testUtcOffsetError(
      '-000000',
      'Negative zero UTC offset is not allowed [Ln 0, Col 8]',
    );
    testUtcOffsetError(
      '+2400',
      'Integer value 24 is out of bounds [0, 23] [Ln 0, Col 3]',
    );
    testUtcOffsetError(
      '+0060',
      'Integer value 60 is out of bounds [0, 59] [Ln 0, Col 5]',
    );
    testUtcOffsetError(
      '+000060',
      'Integer value 60 is out of bounds [0, 59] [Ln 0, Col 7]',
    );
    testUtcOffsetError('+00A', 'Expected 2 characters, found 0 [Ln 0, Col 3]');
  });

  group('Parse TEXT', () {
    test('Parse TEXT', () {
      final property = DocumentParser.parseProperty('TEXT:Sample text');
      final text = parseString(property);
      expect(text, isA<String>());
      expect(text, 'Sample text');
    });

    test('Parse TEXT with special characters', () {
      final property = DocumentParser.parseProperty('TEXT:Sample \\; text');
      final text = parseString(property);
      expect(text, isA<String>());
      expect(text, 'Sample ; text');
    });

    test('Parse TEXT with escaped characters', () {
      final property = DocumentParser.parseProperty('TEXT:Sample \\n text');
      final text = parseString(property);
      expect(text, isA<String>());
      expect(text, 'Sample \n text');
    });
  });
}
