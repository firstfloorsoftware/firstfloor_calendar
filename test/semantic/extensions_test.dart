import 'package:firstfloor_calendar/firstfloor_calendar.dart';
import 'package:test/test.dart';

void main() {
  group('CalDateTimeExtensions', () {
    test('isAfter returns true when date is after other', () {
      final date1 = CalDateTime.local(2025, 1, 1, 10, 0, 0);
      final date2 = CalDateTime.local(2025, 1, 2, 10, 0, 0);

      expect(date2.isAfter(date1), isTrue);
      expect(date1.isAfter(date2), isFalse);
      expect(date1.isAfter(date1), isFalse);
    });

    test('isBefore returns true when date is before other', () {
      final date1 = CalDateTime.local(2025, 1, 1, 10, 0, 0);
      final date2 = CalDateTime.local(2025, 1, 2, 10, 0, 0);

      expect(date1.isBefore(date2), isTrue);
      expect(date2.isBefore(date1), isFalse);
      expect(date1.isBefore(date1), isFalse);
    });

    test('dayOfYear returns correct day number in regular year', () {
      expect(CalDateTime.local(2025, 1, 1, 0, 0, 0).dayOfYear, 1);
      expect(CalDateTime.local(2025, 1, 31, 0, 0, 0).dayOfYear, 31);
      expect(CalDateTime.local(2025, 2, 1, 0, 0, 0).dayOfYear, 32);
      expect(CalDateTime.local(2025, 3, 1, 0, 0, 0).dayOfYear, 60);
      expect(CalDateTime.local(2025, 12, 31, 0, 0, 0).dayOfYear, 365);
    });

    test('dayOfYear returns correct day number in leap year', () {
      expect(CalDateTime.local(2024, 1, 1, 0, 0, 0).dayOfYear, 1);
      expect(CalDateTime.local(2024, 2, 29, 0, 0, 0).dayOfYear, 60);
      expect(CalDateTime.local(2024, 3, 1, 0, 0, 0).dayOfYear, 61);
      expect(CalDateTime.local(2024, 12, 31, 0, 0, 0).dayOfYear, 366);
    });

    test('weekday returns correct weekday', () {
      expect(CalDateTime.local(2025, 1, 1, 0, 0, 0).weekday, Weekday.we);
      expect(CalDateTime.local(2025, 1, 6, 0, 0, 0).weekday, Weekday.mo);
      expect(CalDateTime.local(2025, 1, 5, 0, 0, 0).weekday, Weekday.su);
    });
  });

  group('RecurrenceRuleExtensions', () {
    test('isInfinite returns true when no count or until', () {
      final rrule = RecurrenceRule(freq: RecurrenceFrequency.daily);
      expect(rrule.isInfinite, isTrue);
      expect(rrule.isFinite, isFalse);
    });

    test('isFinite returns true when count is set', () {
      final rrule = RecurrenceRule(freq: RecurrenceFrequency.daily, count: 10);
      expect(rrule.isFinite, isTrue);
      expect(rrule.isInfinite, isFalse);
      expect(rrule.hasCount, isTrue);
      expect(rrule.hasUntil, isFalse);
    });

    test('isFinite returns true when until is set', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.daily,
        until: CalDateTime.local(2025, 12, 31, 0, 0, 0),
      );
      expect(rrule.isFinite, isTrue);
      expect(rrule.isInfinite, isFalse);
      expect(rrule.hasUntil, isTrue);
      expect(rrule.hasCount, isFalse);
    });
  });

  group('EventComponentExtensions', () {
    test('isRecurring returns true when rrule is present', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:test-1\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250101T100000\r\n'
        'RRULE:FREQ=DAILY;COUNT=5\r\n'
        'END:VEVENT',
      );

      expect(event.isRecurring, isTrue);
    });

    test('isRecurring returns false when no recurrence', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:test-2\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250101T100000\r\n'
        'END:VEVENT',
      );

      expect(event.isRecurring, isFalse);
    });

    test('occurrences generates correct occurrences', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:test-3\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250101T100000\r\n'
        'RRULE:FREQ=DAILY;COUNT=3\r\n'
        'END:VEVENT',
      );

      final occurrences = event.occurrences().toList();
      expect(occurrences.length, 3);
      expect(occurrences[0], CalDateTime.local(2025, 1, 1, 10, 0, 0));
      expect(occurrences[1], CalDateTime.local(2025, 1, 2, 10, 0, 0));
      expect(occurrences[2], CalDateTime.local(2025, 1, 3, 10, 0, 0));
    });

    test('occurrences throws StateError when DTSTART is null', () {
      // Create an event without DTSTART property
      final event = EventComponent(
        properties: {
          'UID': [
            PropertyValue(
              property: CalendarProperty(name: 'UID', value: 'test-4', lineNumber: 1),
              value: 'test-4',
            ),
          ],
          'DTSTAMP': [
            PropertyValue(
              property: CalendarProperty(
                name: 'DTSTAMP',
                value: '20250101T000000Z',
                lineNumber: 2,
              ),
              value: CalDateTime.utc(2025, 1, 1, 0, 0, 0),
            ),
          ],
          'RRULE': [
            PropertyValue(
              property: CalendarProperty(
                name: 'RRULE',
                value: 'FREQ=DAILY;COUNT=3',
                lineNumber: 3,
              ),
              value: RecurrenceRule(freq: RecurrenceFrequency.daily, count: 3),
            ),
          ],
        },
        components: [],
      );

      expect(
        () => event.occurrences(),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'No DTSTART provided for recurrence generation',
          ),
        ),
      );
    });
  });

  group('TodoComponentExtensions', () {
    test('isRecurring returns true when rrule is present', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>(
        'BEGIN:VTODO\r\n'
        'UID:test-todo-1\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250101T100000\r\n'
        'RRULE:FREQ=WEEKLY;COUNT=4\r\n'
        'END:VTODO',
      );

      expect(todo.isRecurring, isTrue);
    });

    test('isRecurring returns false when no recurrence', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>(
        'BEGIN:VTODO\r\n'
        'UID:test-todo-2\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250101T100000\r\n'
        'END:VTODO',
      );

      expect(todo.isRecurring, isFalse);
    });

    test('occurrences generates correct occurrences', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>(
        'BEGIN:VTODO\r\n'
        'UID:test-todo-3\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250101T100000\r\n'
        'RRULE:FREQ=DAILY;COUNT=2\r\n'
        'END:VTODO',
      );

      final occurrences = todo.occurrences().toList();
      expect(occurrences.length, 2);
      expect(occurrences[0], CalDateTime.local(2025, 1, 1, 10, 0, 0));
      expect(occurrences[1], CalDateTime.local(2025, 1, 2, 10, 0, 0));
    });
  });

  group('JournalComponentExtensions', () {
    test('isRecurring returns true when rrule is present', () {
      final parser = CalendarParser();
      final journal = parser.parseComponentFromString<JournalComponent>(
        'BEGIN:VJOURNAL\r\n'
        'UID:test-journal-1\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250101T100000\r\n'
        'RRULE:FREQ=DAILY;COUNT=2\r\n'
        'END:VJOURNAL',
      );

      expect(journal.isRecurring, isTrue);
    });

    test('isRecurring returns false when no recurrence', () {
      final parser = CalendarParser();
      final journal = parser.parseComponentFromString<JournalComponent>(
        'BEGIN:VJOURNAL\r\n'
        'UID:test-journal-2\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250101T100000\r\n'
        'END:VJOURNAL',
      );

      expect(journal.isRecurring, isFalse);
    });

    test('occurrences generates correct occurrences', () {
      final parser = CalendarParser();
      final journal = parser.parseComponentFromString<JournalComponent>(
        'BEGIN:VJOURNAL\r\n'
        'UID:test-journal-3\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250101T100000\r\n'
        'RRULE:FREQ=DAILY;COUNT=2\r\n'
        'END:VJOURNAL',
      );

      final occurrences = journal.occurrences().toList();
      expect(occurrences.length, 2);
      expect(occurrences[0], CalDateTime.local(2025, 1, 1, 10, 0, 0));
      expect(occurrences[1], CalDateTime.local(2025, 1, 2, 10, 0, 0));
    });
  });

  group('CalendarDocumentComponentExtensions', () {
    test('isEvent returns true for VEVENT', () {
      final component = CalendarDocumentComponent(
        name: 'VEVENT',
        properties: [],
        components: [],
      );

      expect(component.isEvent, isTrue);
      expect(component.isTodo, isFalse);
      expect(component.isJournal, isFalse);
      expect(component.isFreeBusy, isFalse);
      expect(component.isTimezone, isFalse);
      expect(component.isAlarm, isFalse);
    });

    test('isTodo returns true for VTODO', () {
      final component = CalendarDocumentComponent(
        name: 'VTODO',
        properties: [],
        components: [],
      );

      expect(component.isTodo, isTrue);
      expect(component.isEvent, isFalse);
    });

    test('isJournal returns true for VJOURNAL', () {
      final component = CalendarDocumentComponent(
        name: 'VJOURNAL',
        properties: [],
        components: [],
      );

      expect(component.isJournal, isTrue);
      expect(component.isEvent, isFalse);
    });

    test('isFreeBusy returns true for VFREEBUSY', () {
      final component = CalendarDocumentComponent(
        name: 'VFREEBUSY',
        properties: [],
        components: [],
      );

      expect(component.isFreeBusy, isTrue);
      expect(component.isEvent, isFalse);
    });

    test('isTimezone returns true for VTIMEZONE', () {
      final component = CalendarDocumentComponent(
        name: 'VTIMEZONE',
        properties: [],
        components: [],
      );

      expect(component.isTimezone, isTrue);
      expect(component.isEvent, isFalse);
    });

    test('isAlarm returns true for VALARM', () {
      final component = CalendarDocumentComponent(
        name: 'VALARM',
        properties: [],
        components: [],
      );

      expect(component.isAlarm, isTrue);
      expect(component.isEvent, isFalse);
    });

    test('toEvent converts VEVENT to EventComponent', () {
      final component = CalendarDocumentComponent(
        name: 'VEVENT',
        properties: [
          CalendarProperty(name: 'UID', value: 'test-5', lineNumber: 1),
          CalendarProperty(
            name: 'DTSTAMP',
            value: '20250101T000000Z',
            lineNumber: 2,
          ),
          CalendarProperty(
            name: 'DTSTART',
            value: '20250101T100000',
            lineNumber: 3,
          ),
          CalendarProperty(name: 'SUMMARY', value: 'Test Event', lineNumber: 4),
        ],
        components: [],
      );

      final event = component.toEvent();
      expect(event, isA<EventComponent>());
      expect(event.summary, 'Test Event');
    });

    test('toEvent throws exception for non-event component', () {
      final component = CalendarDocumentComponent(
        name: 'VTODO',
        properties: [],
        components: [],
      );

      expect(() => component.toEvent(), throwsException);
    });

    test('toTodo converts VTODO to TodoComponent', () {
      final component = CalendarDocumentComponent(
        name: 'VTODO',
        properties: [
          CalendarProperty(name: 'UID', value: 'test-todo', lineNumber: 1),
          CalendarProperty(
            name: 'DTSTAMP',
            value: '20250101T000000Z',
            lineNumber: 2,
          ),
          CalendarProperty(name: 'SUMMARY', value: 'Test Todo', lineNumber: 3),
        ],
        components: [],
      );

      final todo = component.toTodo();
      expect(todo, isA<TodoComponent>());
      expect(todo.summary, 'Test Todo');
    });

    test('toTodo throws exception for non-todo component', () {
      final component = CalendarDocumentComponent(
        name: 'VEVENT',
        properties: [],
        components: [],
      );

      expect(() => component.toTodo(), throwsException);
    });

    test('toJournal converts VJOURNAL to JournalComponent', () {
      final component = CalendarDocumentComponent(
        name: 'VJOURNAL',
        properties: [
          CalendarProperty(name: 'UID', value: 'test-journal', lineNumber: 1),
          CalendarProperty(
            name: 'DTSTAMP',
            value: '20250101T000000Z',
            lineNumber: 2,
          ),
          CalendarProperty(
            name: 'SUMMARY',
            value: 'Test Journal',
            lineNumber: 3,
          ),
        ],
        components: [],
      );

      final journal = component.toJournal();
      expect(journal, isA<JournalComponent>());
      expect(journal.summary, 'Test Journal');
    });

    test('toJournal throws exception for non-journal component', () {
      final component = CalendarDocumentComponent(
        name: 'VEVENT',
        properties: [],
        components: [],
      );

      expect(() => component.toJournal(), throwsException);
    });

    test('toFreeBusy converts VFREEBUSY to FreeBusyComponent', () {
      final component = CalendarDocumentComponent(
        name: 'VFREEBUSY',
        properties: [
          CalendarProperty(name: 'UID', value: 'test-freebusy', lineNumber: 1),
          CalendarProperty(
            name: 'DTSTAMP',
            value: '20250101T000000Z',
            lineNumber: 2,
          ),
          CalendarProperty(
            name: 'DTSTART',
            value: '20250101T080000Z',
            lineNumber: 3,
          ),
          CalendarProperty(
            name: 'DTEND',
            value: '20250101T180000Z',
            lineNumber: 4,
          ),
        ],
        components: [],
      );

      final freebusy = component.toFreeBusy();
      expect(freebusy, isA<FreeBusyComponent>());
      expect(freebusy.uid, 'test-freebusy');
    });

    test('toFreeBusy throws exception for non-freebusy component', () {
      final component = CalendarDocumentComponent(
        name: 'VEVENT',
        properties: [],
        components: [],
      );

      expect(() => component.toFreeBusy(), throwsException);
    });

    test('toTimeZone converts VTIMEZONE to TimeZoneComponent', () {
      final component = CalendarDocumentComponent(
        name: 'VTIMEZONE',
        properties: [
          CalendarProperty(name: 'TZID', value: 'America/New_York', lineNumber: 1),
        ],
        components: [],
      );

      final timezone = component.toTimeZone();
      expect(timezone, isA<TimeZoneComponent>());
      expect(timezone.tzid, 'America/New_York');
    });

    test('toTimeZone throws exception for non-timezone component', () {
      final component = CalendarDocumentComponent(
        name: 'VEVENT',
        properties: [],
        components: [],
      );

      expect(() => component.toTimeZone(), throwsException);
    });

    test('toAlarm converts VALARM to AlarmComponent', () {
      final component = CalendarDocumentComponent(
        name: 'VALARM',
        properties: [
          CalendarProperty(name: 'ACTION', value: 'DISPLAY', lineNumber: 1),
          CalendarProperty(name: 'TRIGGER', value: '-PT15M', lineNumber: 2),
        ],
        components: [],
      );

      final alarm = component.toAlarm();
      expect(alarm, isA<AlarmComponent>());
      expect(alarm.actionName, 'DISPLAY');
    });

    test('toAlarm throws exception for non-alarm component', () {
      final component = CalendarDocumentComponent(
        name: 'VEVENT',
        properties: [],
        components: [],
      );

      expect(() => component.toAlarm(), throwsException);
    });
  });
}
