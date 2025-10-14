import 'dart:io';

import 'package:firstfloor_calendar/firstfloor_calendar.dart';
import 'package:test/test.dart';

void main() {
  group('Calendar component parsing', () {
    test('Parse calendar component properties', () {
      final parser = DocumentParser();
      final component = parser.parseComponent(
        'BEGIN:VCALENDAR\r\n'
        'VERSION:2.0\r\n'
        'PRODID:-//hacksw/handcal//NONSGML v1.0//EN\r\n'
        'END:VCALENDAR',
      );

      expect(component.name, 'VCALENDAR');
      expect(component.value('VERSION'), '2.0');
      expect(component.value('PRODID'), '-//hacksw/handcal//NONSGML v1.0//EN');
      expect(component.value('CALSCALE'), isNull);
      expect(component.value('METHOD'), isNull);
    });

    test('Parse VEVENT with unicode characters', () {
      final parser = DocumentParser();
      final component = parser.parseComponent(
        'BEGIN:VEVENT\r\n'
        'UID:12345\r\n'
        'SUMMARY:Test Event with Unicode 🚀\r\n'
        'DTSTART:20231001T120000Z\r\n'
        'DTEND:20231001T130000Z\r\n'
        'END:VEVENT',
      );

      expect(component.name, 'VEVENT');
      expect(component.value('UID'), '12345');
      expect(component.value('SUMMARY'), 'Test Event with Unicode 🚀');
      expect(component.value('DTSTART'), '20231001T120000Z');
      expect(component.value('DTEND'), '20231001T130000Z');
    });

    test(
      'Parse VEVENT with long DESCRIPTION containing extended characters',
      () async {
        final file = File('test/resources/event-long-description.ics');
        final parser = DocumentParser();
        final component = parser.parseComponent(await file.readAsString());

        expect(component.name, 'VEVENT');
        expect(component.value('DTSTART'), '20101112T140000Z');
        expect(component.value('DTEND'), '20101112T143000Z');
        expect(component.value('ORGANIZER'), 'mailto:john@example.com');
        expect(component.value('UID'), '123456');
        expect(component.values('ATTENDEE'), [
          'mailto:john@example.com',
          'mailto:alexander@example.com',
        ]);
        expect(component.value('CREATED'), '20101111T142829Z');

        // value is still raw, not decoded
        expect(
          component.value('DESCRIPTION'),
          'When: Friday\\, November 12\\, 2010 9:00 AM-9:30 AM (UTC-05:00) Eastern Time (US & Canada).\\nWhere: Repective offices\\n\\nNote: The GMT offset above does not reflect daylight saving time adjustments.\\n\\n*~*~*~*~*~*~*~*~*~*\\n\\nTentatively rescheduling our call for Friday at 9am EST:\\n\\n1.  Please join my meeting\\, Friday\\, November 12 at 9:00 AM Eastern Standard Time.\\nhttps://www1.gotomeeting.com/join/000111222\\n\\n2.  Join the conference call:\\n\\nMeeting ID: 000-111-222\\n\\nGoToMeeting®\\nOnline Meetings Made Easy™',
        );
        expect(component.value('LAST-MODIFIED'), '20221221T163048Z');
        expect(component.value('LOCATION'), 'Repective offices');
        expect(component.value('SEQUENCE'), '1');
        expect(component.value('STATUS'), 'TENTATIVE');
        expect(
          component.value('SUMMARY'),
          'Example marketing partnership call',
        );
        expect(component.value('TRANSP'), 'OPAQUE');
        expect(
          component.value('CATEGORIES'),
          'http://schemas.google.com/g/2005#event',
        );
      },
    );
  });

  group('Calendar component parse errors', () {
    test('Invalid empty string should throw', () {
      final parser = DocumentParser();

      expect(
        () => parser.parseComponent(''),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: No properties found in the source string [Ln 1]',
          ),
        ),
      );
    });

    test('Missing BEGIN:VTODO should throw', () {
      final parser = DocumentParser();

      expect(
        () => parser.parseComponent('END:VTODO'),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Expected "BEGIN:[NAME]", found "END:VTODO" [Ln 1]',
          ),
        ),
      );
    });

    test('Missing END:VEVENT should throw', () {
      final parser = DocumentParser();

      expect(
        () => parser.parseComponent('BEGIN:VEVENT\r\nVERSION:2.0'),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Unexpected end of input while parsing component "VEVENT" [Ln 3]',
          ),
        ),
      );
    });

    test('Invalid trailing data should throw', () {
      final parser = DocumentParser();

      expect(
        () => parser.parseComponent(
          'BEGIN:VEVENT\r\n'
          'END:VEVENT\r\n'
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
        () => parser.parseComponent(
          'BEGIN:VJOURNAL\r\n'
          'END:VJOURNAL\r\n'
          'VERSION:2.0\r\n',
        ),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Expected "BEGIN:[NAME]", found "VERSION:2.0" [Ln 3]',
          ),
        ),
      );
    });

    test('Exceeding max component nesting should throw', () {
      final parser = DocumentParser(maxDepth: 1);

      expect(
        () => parser.parseComponent(
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
