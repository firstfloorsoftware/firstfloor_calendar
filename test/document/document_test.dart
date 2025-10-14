import 'dart:io';

import 'package:firstfloor_calendar/firstfloor_calendar.dart';
import 'package:test/test.dart';

void main() {
  group('Parse document', () {
    test('Parse formula 2025 document', () async {
      final file = File('test/resources/calendar-formula-2025.ics');
      final parser = DocumentParser();
      final calendar = parser.parse(await file.readAsString());

      expect(calendar.value('PRODID'), 'RacingNews365 2025');
      expect(calendar.value('VERSION'), '2.0');
      expect(calendar.properties.length, 8);
      expect(calendar.components.length, 121);
    });

    test('Parse calendar document properties', () {
      final parser = DocumentParser();
      final document = parser.parse(
        'BEGIN:VCALENDAR\r\n'
        'VERSION:2.0\r\n'
        'PRODID:-//hacksw/handcal//NONSGML v1.0//EN\r\n'
        'END:VCALENDAR',
      );

      final version = document.value('VERSION');
      final prodid = document.value('PRODID');
      final calscale = document.value('CALSCALE');
      final method = document.value('METHOD');

      expect(version, '2.0');
      expect(prodid, '-//hacksw/handcal//NONSGML v1.0//EN');
      expect(calscale, isNull);
      expect(method, isNull);
    });

    test('Parse calendar prefixed with empty lines', () {
      final parser = DocumentParser();
      final document = parser.parse(
        '\r\n'
        'BEGIN:VCALENDAR\r\n'
        'END:VCALENDAR',
      );

      expect(document.name, 'VCALENDAR');
      expect(document.properties.length, 0);
    });

    test('Parse calendar with trailing empty lines', () {
      final parser = DocumentParser();
      final document = parser.parse(
        '\r\n'
        'BEGIN:VCALENDAR\r\n'
        'END:VCALENDAR\r\n'
        '\r\n',
      );

      expect(document.name, 'VCALENDAR');
      expect(document.properties.length, 0);
    });
  });

  group('Parse document stream', () {
    test('Stream formula 2025 document', () async {
      final file = File('test/resources/calendar-formula-2025.ics');
      final parser = DocumentStreamParser();
      final components = parser.parseComponents(file.openRead());

      // convert to list for easy access
      final componentList = await components.toList();

      final calendar = componentList.first;

      expect(calendar.value('PRODID'), 'RacingNews365 2025');
      expect(calendar.value('VERSION'), '2.0');
      expect(calendar.properties.length, 8);

      // 121 top-level components + 1 calendar component
      expect(componentList.length, 122);
    });
  });

  group('Document parsing errors', () {
    test('Invalid empty string should throw', () {
      final parser = DocumentParser();

      expect(
        () => parser.parse(''),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: No properties found in the source string [Ln 1]',
          ),
        ),
      );
    });

    test('Missing BEGIN:VCALENDAR should throw', () {
      final parser = DocumentParser();

      expect(
        () => parser.parse('END:VCALENDAR'),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Expected "BEGIN:VCALENDAR", found "END:VCALENDAR" [Ln 1]',
          ),
        ),
      );
    });

    test('Missing END:VCALENDAR should throw', () {
      final parser = DocumentParser();

      expect(
        () => parser.parse('BEGIN:VCALENDAR\r\nVERSION:2.0'),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Unexpected end of input while parsing component "VCALENDAR" [Ln 3]',
          ),
        ),
      );
    });

    test('Invalid BEGIN:VEVENT should throw', () {
      final parser = DocumentParser();

      expect(
        () => parser.parse('BEGIN:VEVENT'),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Expected "BEGIN:VCALENDAR", found "BEGIN:VEVENT" [Ln 1]',
          ),
        ),
      );
    });

    test('Invalid trailing data should throw', () {
      final parser = DocumentParser();

      expect(
        () => parser.parse(
          'BEGIN:VCALENDAR\r\n'
          'END:VCALENDAR\r\n'
          'AAA\r\n',
        ),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Expected one of [":", ";"], found "<endOfLine>" [Ln 3, Col 3]',
          ),
        ),
      );
    });

    test('Invalid trailing properties should throw', () {
      final parser = DocumentParser();

      expect(
        () => parser.parse(
          'BEGIN:VCALENDAR\r\n'
          'END:VCALENDAR\r\n'
          'VERSION:2.0\r\n',
        ),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Expected "BEGIN:VCALENDAR", found "VERSION:2.0" [Ln 3]',
          ),
        ),
      );
    });

    test('Exceeding max component nesting should throw', () {
      final parser = DocumentParser(maxDepth: 1);

      expect(
        () => parser.parse(
          'BEGIN:VCALENDAR\r\n'
          'BEGIN:VEVENT\r\n'
          'END:VEVENT\r\n'
          'END:VCALENDAR\r\n',
        ),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Maximum component depth of 1 exceeded [Ln 2]',
          ),
        ),
      );
    });
  });
}
