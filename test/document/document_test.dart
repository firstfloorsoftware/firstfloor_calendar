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

  group('CalendarDocument data model', () {
    test('Can be created with properties and components', () {
      final doc = CalendarDocument(
        properties: [
          CalendarProperty(name: 'VERSION', value: '2.0'),
          CalendarProperty(name: 'PRODID', value: 'test'),
        ],
        components: [CalendarDocumentComponent(name: 'VEVENT', properties: [])],
      );

      expect(doc.name, 'VCALENDAR');
      expect(doc.properties.length, 2);
      expect(doc.components.length, 1);
    });

    test('Can be created empty', () {
      const doc = CalendarDocument();

      expect(doc.name, 'VCALENDAR');
      expect(doc.properties, isEmpty);
      expect(doc.components, isEmpty);
      expect(doc.lineNumber, 0);
    });

    test('Has correct line number', () {
      const doc = CalendarDocument(lineNumber: 42);

      expect(doc.lineNumber, 42);
    });
  });

  group('CalendarDocumentComponent data model', () {
    test('Can be created with name only', () {
      const component = CalendarDocumentComponent(name: 'VEVENT');

      expect(component.name, 'VEVENT');
      expect(component.properties, isEmpty);
      expect(component.components, isEmpty);
      expect(component.lineNumber, 0);
    });

    test('Can be created with all parameters', () {
      final component = CalendarDocumentComponent(
        name: 'VEVENT',
        properties: [CalendarProperty(name: 'SUMMARY', value: 'Test Event')],
        components: [CalendarDocumentComponent(name: 'VALARM')],
        lineNumber: 10,
      );

      expect(component.name, 'VEVENT');
      expect(component.properties.length, 1);
      expect(component.components.length, 1);
      expect(component.lineNumber, 10);
    });

    test('propertiesNamed returns properties with matching name', () {
      final component = CalendarDocumentComponent(
        name: 'VEVENT',
        properties: [
          CalendarProperty(name: 'SUMMARY', value: 'Test 1'),
          CalendarProperty(name: 'DESCRIPTION', value: 'Desc'),
          CalendarProperty(name: 'SUMMARY', value: 'Test 2'),
        ],
      );

      final summaries = component.propertiesNamed('SUMMARY').toList();
      expect(summaries.length, 2);
      expect(summaries[0].value, 'Test 1');
      expect(summaries[1].value, 'Test 2');
    });

    test('propertiesNamed returns empty when no match', () {
      final component = CalendarDocumentComponent(
        name: 'VEVENT',
        properties: [CalendarProperty(name: 'SUMMARY', value: 'Test')],
      );

      final results = component.propertiesNamed('NONEXISTENT').toList();
      expect(results, isEmpty);
    });

    test('values returns property values with matching name', () {
      final component = CalendarDocumentComponent(
        name: 'VEVENT',
        properties: [
          CalendarProperty(name: 'CATEGORIES', value: 'Work'),
          CalendarProperty(name: 'SUMMARY', value: 'Meeting'),
          CalendarProperty(name: 'CATEGORIES', value: 'Important'),
        ],
      );

      final categories = component.values('CATEGORIES').toList();
      expect(categories.length, 2);
      expect(categories, ['Work', 'Important']);
    });

    test('values returns empty when no match', () {
      final component = CalendarDocumentComponent(
        name: 'VEVENT',
        properties: [CalendarProperty(name: 'SUMMARY', value: 'Test')],
      );

      final results = component.values('NONEXISTENT').toList();
      expect(results, isEmpty);
    });

    test('value returns first matching property value', () {
      final component = CalendarDocumentComponent(
        name: 'VEVENT',
        properties: [
          CalendarProperty(name: 'SUMMARY', value: 'First'),
          CalendarProperty(name: 'SUMMARY', value: 'Second'),
        ],
      );

      final value = component.value('SUMMARY');
      expect(value, 'First');
    });

    test('value returns null when property not found', () {
      const component = CalendarDocumentComponent(
        name: 'VEVENT',
        properties: [],
      );

      final value = component.value('NONEXISTENT');
      expect(value, isNull);
    });

    test('componentsNamed returns components with matching name', () {
      final component = CalendarDocumentComponent(
        name: 'VEVENT',
        components: [
          CalendarDocumentComponent(name: 'VALARM'),
          CalendarDocumentComponent(name: 'VTIMEZONE'),
          CalendarDocumentComponent(name: 'VALARM'),
        ],
      );

      final alarms = component.componentsNamed('VALARM').toList();
      expect(alarms.length, 2);
      expect(alarms[0].name, 'VALARM');
      expect(alarms[1].name, 'VALARM');
    });

    test('componentsNamed returns empty when no match', () {
      final component = CalendarDocumentComponent(
        name: 'VEVENT',
        components: [CalendarDocumentComponent(name: 'VALARM')],
      );

      final results = component.componentsNamed('NONEXISTENT').toList();
      expect(results, isEmpty);
    });

    test('Component returns first matching component', () {
      final component = CalendarDocumentComponent(
        name: 'VCALENDAR',
        components: [
          CalendarDocumentComponent(name: 'VEVENT'),
          CalendarDocumentComponent(name: 'VTODO'),
          CalendarDocumentComponent(name: 'VEVENT'),
        ],
      );

      final event = component.component('VEVENT');
      expect(event, isNotNull);
      expect(event!.name, 'VEVENT');
    });

    test('Component returns null when not found', () {
      const component = CalendarDocumentComponent(
        name: 'VCALENDAR',
        components: [],
      );

      final result = component.component('NONEXISTENT');
      expect(result, isNull);
    });

    test('toString returns component name', () {
      const component = CalendarDocumentComponent(name: 'VEVENT');
      expect(component.toString(), 'VEVENT');
    });
  });

  group('CalendarProperty data model', () {
    test('Can be created with name and value', () {
      const property = CalendarProperty(name: 'SUMMARY', value: 'Test Event');

      expect(property.name, 'SUMMARY');
      expect(property.value, 'Test Event');
      expect(property.parameters, isEmpty);
      expect(property.lineNumber, 0);
    });

    test('Can be created with parameters', () {
      final property = CalendarProperty(
        name: 'DTSTART',
        value: '20250101T100000',
        parameters: {
          'TZID': ['America/New_York'],
          'VALUE': ['DATE-TIME'],
        },
      );

      expect(property.name, 'DTSTART');
      expect(property.value, '20250101T100000');
      expect(property.parameters.length, 2);
      expect(property.parameters['TZID'], ['America/New_York']);
      expect(property.parameters['VALUE'], ['DATE-TIME']);
    });

    test('Can be created with line number', () {
      const property = CalendarProperty(
        name: 'SUMMARY',
        value: 'Test',
        lineNumber: 5,
      );

      expect(property.lineNumber, 5);
    });

    test('toString formats property without parameters', () {
      const property = CalendarProperty(name: 'SUMMARY', value: 'Test Event');

      expect(property.toString(), 'SUMMARY:Test Event');
    });

    test('toString formats property with single parameter', () {
      final property = CalendarProperty(
        name: 'DTSTART',
        value: '20250101T100000',
        parameters: {
          'TZID': ['America/New_York'],
        },
      );

      expect(
        property.toString(),
        'DTSTART;TZID=America/New_York:20250101T100000',
      );
    });

    test('toString formats property with multiple parameters', () {
      final property = CalendarProperty(
        name: 'DTSTART',
        value: '20250101T100000',
        parameters: {
          'TZID': ['America/New_York'],
          'VALUE': ['DATE-TIME'],
        },
      );

      final str = property.toString();
      expect(
        str,
        'DTSTART;TZID=America/New_York;VALUE=DATE-TIME:20250101T100000',
      );
    });

    test('toString formats parameter with multiple values', () {
      final property = CalendarProperty(
        name: 'CATEGORIES',
        value: 'WORK',
        parameters: {
          'LANGUAGE': ['en', 'fr'],
        },
      );

      expect(property.toString(), 'CATEGORIES;LANGUAGE=en,fr:WORK');
    });
  });
}
