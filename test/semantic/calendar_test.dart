import 'package:firstfloor_calendar/firstfloor_calendar.dart';
import 'package:test/test.dart';

void main() {
  late CalendarParser parser;

  setUp(() {
    parser = CalendarParser();
  });

  group('Calendar', () {
    test('accesses basic calendar properties', () {
      final cal = parser.parseFromString('''
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//My Company//My Product//EN
CALSCALE:GREGORIAN
METHOD:PUBLISH
BEGIN:VEVENT
UID:event1
DTSTAMP:20250101T120000Z
DTSTART:20250101T120000Z
END:VEVENT
END:VCALENDAR
''');

      expect(cal.version, '2.0');
      expect(cal.prodid, '-//My Company//My Product//EN');
      expect(cal.calscale, 'GREGORIAN');
      expect(cal.method, 'PUBLISH');
      expect(cal.events.length, 1);
    });

    test('calscale defaults to GREGORIAN when not specified', () {
      final cal = parser.parseFromString('''
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Test//Test//EN
BEGIN:VEVENT
UID:event1
DTSTAMP:20250101T120000Z
DTSTART:20250101T120000Z
END:VEVENT
END:VCALENDAR
''');

      expect(cal.calscale, 'GREGORIAN');
    });

    test('method is null when not specified', () {
      final cal = parser.parseFromString('''
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Test//Test//EN
END:VCALENDAR
''');

      expect(cal.method, isNull);
    });

    test('accesses component collections', () {
      final cal = parser.parseFromString('''
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Test//Test//EN
BEGIN:VEVENT
UID:event1
DTSTAMP:20250101T120000Z
DTSTART:20250101T120000Z
END:VEVENT
BEGIN:VTODO
UID:todo1
DTSTAMP:20250101T120000Z
DTSTART:20250101T120000Z
END:VTODO
BEGIN:VJOURNAL
UID:journal1
DTSTAMP:20250101T120000Z
DTSTART:20250101T120000Z
END:VJOURNAL
BEGIN:VFREEBUSY
UID:fb1
DTSTAMP:20250101T120000Z
CONTACT:mailto:contact@example.com
END:VFREEBUSY
BEGIN:VTIMEZONE
TZID:America/New_York
BEGIN:STANDARD
DTSTART:19701101T020000
TZOFFSETFROM:-0400
TZOFFSETTO:-0500
END:STANDARD
END:VTIMEZONE
END:VCALENDAR
''');

      expect(cal.events.length, 1);
      expect(cal.todos.length, 1);
      expect(cal.journals.length, 1);
      expect(cal.freeBusy.length, 1);
      expect(cal.timezones.length, 1);
    });
  });

  group('EventComponent', () {
    test('accesses optional event properties', () {
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:event1
DTSTAMP:20250101T120000Z
DTSTART:20250115T100000Z
CLASS:CONFIDENTIAL
CREATED:20250101T080000Z
DESCRIPTION:Team meeting
GEO:37.386013;-122.082932
LAST-MODIFIED:20250102T090000Z
LOCATION:Conference Room A
ORGANIZER:mailto:organizer@example.com
PRIORITY:5
SEQUENCE:2
STATUS:CONFIRMED
SUMMARY:Weekly Team Meeting
TRANSP:OPAQUE
URL:https://example.com/events/1
RECURRENCE-ID:20250115T100000Z
RRULE:FREQ=WEEKLY;COUNT=10
DTEND:20250115T110000Z
DURATION:PT1H
ATTACH:https://example.com/file.pdf
ATTENDEE:mailto:attendee@example.com
CATEGORIES:Work,Important
COMMENT:First comment
CONTACT:mailto:contact@example.com
EXDATE:20250122T100000Z
RELATED-TO:event2
REQUEST-STATUS:2.0;Success
RESOURCES:Projector,Laptop
RDATE:20250129T100000Z
END:VEVENT
''');

      expect(event.uid, 'event1');
      expect(event.dtstamp, CalDateTime.utc(2025, 1, 1, 12, 0, 0));
      expect(event.dtstart, CalDateTime.utc(2025, 1, 15, 10, 0, 0));
      expect(event.classification, Classification.confidential);
      expect(event.classificationName, 'CONFIDENTIAL');
      expect(event.created, CalDateTime.utc(2025, 1, 1, 8, 0, 0));
      expect(event.description, 'Team meeting');
      expect(
        event.geo,
        GeoCoordinate(latitude: 37.386013, longitude: -122.082932),
      );
      expect(event.lastModified, CalDateTime.utc(2025, 1, 2, 9, 0, 0));
      expect(event.location, 'Conference Room A');
      expect(
        event.organizer,
        CalendarUserAddress(address: 'mailto:organizer@example.com'),
      );
      expect(event.priority, 5);
      expect(event.sequence, 2);
      expect(event.status, EventStatus.confirmed);
      expect(event.statusName, 'CONFIRMED');
      expect(event.summary, 'Weekly Team Meeting');
      expect(event.transp, TimeTransparency.opaque);
      expect(event.transpName, 'OPAQUE');
      expect(event.url, Uri.parse('https://example.com/events/1'));
      expect(event.recurrenceId, '20250115T100000Z');
      expect(
        event.rrule,
        RecurrenceRule(freq: RecurrenceFrequency.weekly, count: 10),
      );
      expect(event.dtend, CalDateTime.utc(2025, 1, 15, 11, 0, 0));
      expect(event.duration, CalDuration(hours: 1));
      expect(event.attachments, [
        AttachmentUri(uri: Uri.parse('https://example.com/file.pdf')),
      ]);
      expect(event.attendees, [
        CalendarUserAddress(address: 'mailto:attendee@example.com'),
      ]);
      expect(event.categories, ['Work', 'Important']);
      expect(event.comments, ['First comment']);
      expect(event.contacts, [
        CalendarUserAddress(address: 'mailto:contact@example.com'),
      ]);
      expect(event.exdates, [CalDateTime.utc(2025, 1, 22, 10, 0, 0)]);
      expect(event.relatedTo, ['event2']);
      expect(event.requestStatus, ['2.0;Success']);
      expect(event.resources, ['Projector', 'Laptop']);
      expect(event.rdates, [
        RecurrenceDateTime.dateTime(CalDateTime.utc(2025, 1, 29, 10, 0, 0)),
      ]);
    });

    test('handles null optional properties', () {
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:event1
DTSTAMP:20250101T120000Z
DTSTART:20250101T120000Z
END:VEVENT
''');

      expect(event.dtstart, isNotNull);
      expect(event.classification, isNull);
      expect(event.classificationName, isNull);
      expect(event.created, isNull);
      expect(event.description, isNull);
      expect(event.geo, isNull);
      expect(event.lastModified, isNull);
      expect(event.location, isNull);
      expect(event.organizer, isNull);
      expect(event.priority, isNull);
      expect(event.sequence, isNull);
      expect(event.status, isNull);
      expect(event.statusName, isNull);
      expect(event.summary, isNull);
      expect(event.transp, isNull);
      expect(event.transpName, isNull);
      expect(event.url, isNull);
      expect(event.recurrenceId, isNull);
      expect(event.rrule, isNull);
      expect(event.dtend, isNull);
      expect(event.duration, isNull);
    });

    test('accesses alarms', () {
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:event1
DTSTAMP:20250101T120000Z
DTSTART:20250101T120000Z
BEGIN:VALARM
ACTION:DISPLAY
TRIGGER:-PT15M
DESCRIPTION:Reminder
END:VALARM
BEGIN:VALARM
ACTION:AUDIO
TRIGGER:-PT5M
END:VALARM
END:VEVENT
''');

      expect(event.alarms.length, 2);
    });

    test('handles multiple RESOURCES properties', () {
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:event1
DTSTAMP:20250101T120000Z
DTSTART:20250101T120000Z
RESOURCES:Projector,Screen
RESOURCES:Laptop,Whiteboard
RESOURCES:Conference Phone
END:VEVENT
''');

      expect(event.resources, [
        'Projector',
        'Screen',
        'Laptop',
        'Whiteboard',
        'Conference Phone',
      ]);
    });
  });

  group('TodoComponent', () {
    test('accesses required todo properties', () {
      final todo = parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:todo1
DTSTAMP:20250101T120000Z
DTSTART:20250115T090000Z
END:VTODO
''');

      expect(todo.uid, 'todo1');
      expect(todo.dtstamp, isNotNull);
      expect(todo.dtstart, isNotNull);
    });

    test('accesses optional todo properties', () {
      final todo = parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:todo1
DTSTAMP:20250101T120000Z
DTSTART:20250115T090000Z
CLASS:PUBLIC
COMPLETED:20250116T100000Z
CREATED:20250101T080000Z
DESCRIPTION:Complete project
GEO:37.386013;-122.082932
LAST-MODIFIED:20250102T090000Z
LOCATION:Office
ORGANIZER:mailto:organizer@example.com
PERCENT-COMPLETE:75
PRIORITY:3
RECURRENCE-ID:20250115T090000Z
SEQUENCE:1
STATUS:IN-PROCESS
SUMMARY:Important Task
URL:https://example.com/tasks/1
RRULE:FREQ=DAILY;COUNT=5
DUE:20250120T170000Z
DURATION:PT8H
ATTACH:https://example.com/file.pdf
ATTENDEE:mailto:attendee@example.com
CATEGORIES:Work,Urgent
COMMENT:Task comment
CONTACT:mailto:contact@example.com
EXDATE:20250117T090000Z
RELATED-TO:todo2
REQUEST-STATUS:2.0;Success
RESOURCES:Laptop,Monitor
RDATE:20250118T090000Z
END:VTODO
''');

      expect(todo.classification, Classification.public);
      expect(todo.classificationName, 'PUBLIC');
      expect(todo.completed, CalDateTime.utc(2025, 1, 16, 10, 0, 0));
      expect(todo.created, CalDateTime.utc(2025, 1, 1, 8, 0, 0));
      expect(todo.description, 'Complete project');
      expect(
        todo.geo,
        GeoCoordinate(latitude: 37.386013, longitude: -122.082932),
      );
      expect(todo.lastModified, CalDateTime.utc(2025, 1, 2, 9, 0, 0));
      expect(todo.location, 'Office');
      expect(
        todo.organizer,
        CalendarUserAddress(address: 'mailto:organizer@example.com'),
      );
      expect(todo.percentComplete, 75);
      expect(todo.priority, 3);
      expect(todo.recurrenceId, '20250115T090000Z');
      expect(todo.sequence, 1);
      expect(todo.status, TodoStatus.inProcess);
      expect(todo.statusName, 'IN-PROCESS');
      expect(todo.summary, 'Important Task');
      expect(todo.url, Uri.parse('https://example.com/tasks/1'));
      expect(
        todo.rrule,
        RecurrenceRule(freq: RecurrenceFrequency.daily, count: 5),
      );
      expect(todo.due, CalDateTime.utc(2025, 1, 20, 17, 0, 0));
      expect(todo.duration, CalDuration(hours: 8));
      expect(todo.attachments, [
        AttachmentUri(uri: Uri.parse('https://example.com/file.pdf')),
      ]);
      expect(todo.attendees, [
        CalendarUserAddress(address: 'mailto:attendee@example.com'),
      ]);
      expect(todo.categories, ['Work', 'Urgent']);
      expect(todo.comments, ['Task comment']);
      expect(todo.contacts, [
        CalendarUserAddress(address: 'mailto:contact@example.com'),
      ]);
      expect(todo.exdates, [CalDateTime.utc(2025, 1, 17, 9, 0, 0)]);
      expect(todo.relatedTo, ['todo2']);
      expect(todo.requestStatus, ['2.0;Success']);
      expect(todo.resources, ['Laptop', 'Monitor']);
      expect(todo.rdates, [
        RecurrenceDateTime.dateTime(CalDateTime.utc(2025, 1, 18, 9, 0, 0)),
      ]);
    });

    test('handles null optional todo properties', () {
      final todo = parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:todo1
DTSTAMP:20250101T120000Z
DTSTART:20250115T090000Z
END:VTODO
''');

      expect(todo.classification, isNull);
      expect(todo.classificationName, isNull);
      expect(todo.completed, isNull);
      expect(todo.created, isNull);
      expect(todo.description, isNull);
      expect(todo.geo, isNull);
      expect(todo.lastModified, isNull);
      expect(todo.location, isNull);
      expect(todo.organizer, isNull);
      expect(todo.percentComplete, isNull);
      expect(todo.priority, isNull);
      expect(todo.recurrenceId, isNull);
      expect(todo.sequence, isNull);
      expect(todo.status, isNull);
      expect(todo.statusName, isNull);
      expect(todo.summary, isNull);
      expect(todo.url, isNull);
      expect(todo.rrule, isNull);
      expect(todo.due, isNull);
      expect(todo.duration, isNull);
    });

    test('accesses alarms', () {
      final todo = parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:todo1
DTSTAMP:20250101T120000Z
DTSTART:20250115T090000Z
BEGIN:VALARM
ACTION:DISPLAY
TRIGGER:-PT30M
DESCRIPTION:Deadline approaching
END:VALARM
END:VTODO
''');

      expect(todo.alarms.length, 1);
    });
  });

  group('JournalComponent', () {
    test('accesses required journal properties', () {
      final journal = parser.parseComponentFromString<JournalComponent>('''
BEGIN:VJOURNAL
UID:journal1
DTSTAMP:20250101T120000Z
DTSTART:20250115T090000Z
END:VJOURNAL
''');

      expect(journal.uid, 'journal1');
      expect(journal.dtstamp, CalDateTime.utc(2025, 1, 1, 12, 0, 0));
      expect(journal.dtstart, CalDateTime.utc(2025, 1, 15, 9, 0, 0));
    });

    test('accesses optional journal properties', () {
      final journal = parser.parseComponentFromString<JournalComponent>('''
BEGIN:VJOURNAL
UID:journal1
DTSTAMP:20250101T120000Z
DTSTART:20250115T090000Z
CLASS:PRIVATE
CREATED:20250101T080000Z
LAST-MODIFIED:20250102T090000Z
ORGANIZER:mailto:organizer@example.com
RECURRENCE-ID:20250115T090000Z
SEQUENCE:1
STATUS:DRAFT
SUMMARY:My Journal Entry
URL:https://example.com/journal/1
RRULE:FREQ=DAILY;COUNT=7
ATTACH:https://example.com/photo.jpg
ATTENDEE:mailto:attendee@example.com
CATEGORIES:Personal,Ideas
COMMENT:Journal comment
CONTACT:mailto:contact@example.com
DESCRIPTION:Today's thoughts
EXDATE:20250116T090000Z
RELATED-TO:journal2
RDATE:20250117T090000Z
REQUEST-STATUS:2.0;Success
END:VJOURNAL
''');

      expect(journal.classification, Classification.private);
      expect(journal.classificationName, 'PRIVATE');
      expect(journal.created, CalDateTime.utc(2025, 1, 1, 8, 0, 0));
      expect(journal.lastModified, CalDateTime.utc(2025, 1, 2, 9, 0, 0));
      expect(
        journal.organizer,
        CalendarUserAddress(address: 'mailto:organizer@example.com'),
      );
      expect(journal.recurrenceId, '20250115T090000Z');
      expect(journal.sequence, 1);
      expect(journal.status, JournalStatus.draft);
      expect(journal.statusName, 'DRAFT');
      expect(journal.summary, 'My Journal Entry');
      expect(journal.url, Uri.parse('https://example.com/journal/1'));
      expect(
        journal.rrule,
        RecurrenceRule(freq: RecurrenceFrequency.daily, count: 7),
      );
      expect(journal.attachments, [
        AttachmentUri(uri: Uri.parse('https://example.com/photo.jpg')),
      ]);
      expect(journal.attendees, [
        CalendarUserAddress(address: 'mailto:attendee@example.com'),
      ]);
      expect(journal.categories, ['Personal', 'Ideas']);
      expect(journal.comments, ['Journal comment']);
      expect(journal.contacts, [
        CalendarUserAddress(address: 'mailto:contact@example.com'),
      ]);
      expect(journal.descriptions, ['Today\'s thoughts']);
      expect(journal.exdates, [CalDateTime.utc(2025, 1, 16, 9, 0, 0)]);
      expect(journal.relatedTo, ['journal2']);
      expect(journal.rdates, [
        RecurrenceDateTime.dateTime(CalDateTime.utc(2025, 1, 17, 9, 0, 0)),
      ]);
      expect(journal.requestStatus, ['2.0;Success']);
    });

    test('handles null optional journal properties', () {
      final journal = parser.parseComponentFromString<JournalComponent>('''
BEGIN:VJOURNAL
UID:journal1
DTSTAMP:20250101T120000Z
DTSTART:20250115T090000Z
END:VJOURNAL
''');

      expect(journal.classification, isNull);
      expect(journal.classificationName, isNull);
      expect(journal.created, isNull);
      expect(journal.lastModified, isNull);
      expect(journal.organizer, isNull);
      expect(journal.recurrenceId, isNull);
      expect(journal.sequence, isNull);
      expect(journal.status, isNull);
      expect(journal.statusName, isNull);
      expect(journal.summary, isNull);
      expect(journal.url, isNull);
      expect(journal.rrule, isNull);
    });
  });

  group('FreeBusyComponent', () {
    test('accesses required freebusy properties', () {
      final fb = parser.parseComponentFromString<FreeBusyComponent>('''
BEGIN:VFREEBUSY
UID:fb1
DTSTAMP:20250101T120000Z
CONTACT:mailto:contact@example.com
END:VFREEBUSY
''');

      expect(fb.uid, 'fb1');
      expect(fb.dtstamp, CalDateTime.utc(2025, 1, 1, 12, 0, 0));
      expect(
        fb.contact,
        CalendarUserAddress(address: 'mailto:contact@example.com'),
      );
    });

    test('accesses optional freebusy properties', () {
      final fb = parser.parseComponentFromString<FreeBusyComponent>('''
BEGIN:VFREEBUSY
UID:fb1
DTSTAMP:20250101T120000Z
CONTACT:mailto:contact@example.com
DTSTART:20250115T090000Z
DTEND:20250115T170000Z
ORGANIZER:mailto:organizer@example.com
URL:https://example.com/freebusy/1
ATTENDEE:mailto:attendee@example.com
COMMENT:Freebusy comment
FREEBUSY:20250115T100000Z/20250115T110000Z
REQUEST-STATUS:2.0;Success
END:VFREEBUSY
''');

      expect(fb.dtstart, CalDateTime.utc(2025, 1, 15, 9, 0, 0));
      expect(fb.dtend, CalDateTime.utc(2025, 1, 15, 17, 0, 0));
      expect(
        fb.organizer,
        CalendarUserAddress(address: 'mailto:organizer@example.com'),
      );
      expect(fb.url, Uri.parse('https://example.com/freebusy/1'));
      expect(fb.attendees, [
        CalendarUserAddress(address: 'mailto:attendee@example.com'),
      ]);
      expect(fb.comments, ['Freebusy comment']);
      expect(fb.freebusy, [
        Period.explicit(
          start: CalDateTime.utc(2025, 1, 15, 10, 0, 0),
          end: CalDateTime.utc(2025, 1, 15, 11, 0, 0),
        ),
      ]);
      expect(fb.requestStatus, ['2.0;Success']);
    });

    test('handles null optional freebusy properties', () {
      final fb = parser.parseComponentFromString<FreeBusyComponent>('''
BEGIN:VFREEBUSY
UID:fb1
DTSTAMP:20250101T120000Z
CONTACT:mailto:contact@example.com
END:VFREEBUSY
''');

      expect(fb.dtstart, isNull);
      expect(fb.dtend, isNull);
      expect(fb.organizer, isNull);
      expect(fb.url, isNull);
    });
  });

  group('TimeZoneComponent', () {
    test('accesses timezone properties', () {
      final tz = parser.parseComponentFromString<TimeZoneComponent>('''
BEGIN:VTIMEZONE
TZID:America/New_York
LAST-MODIFIED:20250101T000000Z
TZURL:https://example.com/tz/newyork
BEGIN:STANDARD
DTSTART:19701101T020000
TZOFFSETFROM:-0400
TZOFFSETTO:-0500
RRULE:FREQ=YEARLY;BYMONTH=11;BYDAY=1SU
COMMENT:Standard time
RDATE:20251101T020000
TZNAME:EST
END:STANDARD
BEGIN:DAYLIGHT
DTSTART:19700308T020000
TZOFFSETFROM:-0500
TZOFFSETTO:-0400
RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=2SU
COMMENT:Daylight saving time
RDATE:20250309T020000
TZNAME:EDT
END:DAYLIGHT
END:VTIMEZONE
''');

      expect(tz.tzid, 'America/New_York');
      expect(tz.lastModified, CalDateTime.utc(2025, 1, 1, 0, 0, 0));
      expect(tz.tzurl, Uri.parse('https://example.com/tz/newyork'));
      expect(tz.standard.length, 1);
      expect(tz.daylight.length, 1);

      final std = tz.standard.first;
      expect(std.dtstart, CalDateTime.local(1970, 11, 1, 2, 0, 0));
      expect(
        std.tzoffsetFrom,
        UtcOffset(sign: Sign.negative, hours: 4, minutes: 0),
      );
      expect(
        std.tzoffsetTo,
        UtcOffset(sign: Sign.negative, hours: 5, minutes: 0),
      );
      expect(
        std.rrule,
        RecurrenceRule(
          freq: RecurrenceFrequency.yearly,
          byMonth: {11},
          byDay: {ByDay(Weekday.su, ordinal: 1)},
        ),
      );
      expect(std.comments, ['Standard time']);
      expect(std.rdates, [
        RecurrenceDateTime.dateTime(CalDateTime.local(2025, 11, 1, 2, 0, 0)),
      ]);
      expect(std.tznames, ['EST']);

      final dst = tz.daylight.first;
      expect(dst.dtstart, CalDateTime.local(1970, 3, 8, 2, 0, 0));
      expect(
        dst.tzoffsetFrom,
        UtcOffset(sign: Sign.negative, hours: 5, minutes: 0),
      );
      expect(
        dst.tzoffsetTo,
        UtcOffset(sign: Sign.negative, hours: 4, minutes: 0),
      );
      expect(
        dst.rrule,
        RecurrenceRule(
          freq: RecurrenceFrequency.yearly,
          byMonth: {3},
          byDay: {ByDay(Weekday.su, ordinal: 2)},
        ),
      );
      expect(dst.comments, ['Daylight saving time']);
      expect(dst.rdates, [
        RecurrenceDateTime.dateTime(CalDateTime.local(2025, 3, 9, 2, 0, 0)),
      ]);
      expect(dst.tznames, ['EDT']);
    });

    test('handles null optional timezone properties', () {
      final tz = parser.parseComponentFromString<TimeZoneComponent>('''
BEGIN:VTIMEZONE
TZID:Custom/Zone
BEGIN:STANDARD
DTSTART:19701101T020000
TZOFFSETFROM:-0400
TZOFFSETTO:-0500
END:STANDARD
END:VTIMEZONE
''');

      expect(tz.lastModified, isNull);
      expect(tz.tzurl, isNull);
    });
  });

  group('AlarmComponent', () {
    test('accesses alarm properties', () {
      final alarm = parser.parseComponentFromString<AlarmComponent>('''
BEGIN:VALARM
ACTION:EMAIL
TRIGGER:-PT30M
DESCRIPTION:Reminder
SUMMARY:Meeting in 30 minutes
ATTENDEE:mailto:attendee@example.com
DURATION:PT15M
REPEAT:3
ATTACH:https://example.com/reminder.mp3
END:VALARM
''');

      expect(alarm.action, AlarmAction.email);
      expect(alarm.actionName, 'EMAIL');
      expect(
        alarm.trigger,
        Trigger.duration(CalDuration(sign: Sign.negative, minutes: 30)),
      );
      expect(alarm.description, 'Reminder');
      expect(alarm.summary, 'Meeting in 30 minutes');
      expect(alarm.attendees, [
        CalendarUserAddress(address: 'mailto:attendee@example.com'),
      ]);
      expect(alarm.duration, CalDuration(minutes: 15));
      expect(alarm.repeat, 3);
      expect(alarm.attachments, [
        AttachmentUri(uri: Uri.parse('https://example.com/reminder.mp3')),
      ]);
    });

    test('handles null optional alarm properties', () {
      final alarm = parser.parseComponentFromString<AlarmComponent>('''
BEGIN:VALARM
ACTION:DISPLAY
TRIGGER:-PT15M
END:VALARM
''');

      expect(alarm.description, isNull);
      expect(alarm.summary, isNull);
      expect(alarm.duration, isNull);
      expect(alarm.repeat, isNull);
    });
  });

  group('CalendarComponent.typed factory', () {
    test('creates Calendar from VCALENDAR', () {
      final component = CalendarComponent.typed(
        componentName: 'VCALENDAR',
        properties: {
          'VERSION': [
            PropertyValue(
              property: CalendarProperty(
                name: 'VERSION',
                value: '2.0',
                parameters: {},
                lineNumber: 0,
              ),
              value: '2.0',
            ),
          ],
          'PRODID': [
            PropertyValue(
              property: CalendarProperty(
                name: 'PRODID',
                value: '-//Test//Test//EN',
                parameters: {},
                lineNumber: 0,
              ),
              value: '-//Test//Test//EN',
            ),
          ],
        },
        components: [],
      );

      expect(component, isA<Calendar>());
    });

    test('creates generic component for unknown type', () {
      final component = CalendarComponent.typed(
        componentName: 'VUNKNOWN',
        properties: {},
        components: [],
      );

      expect(component, isA<CalendarComponent>());
      expect(component.name, 'VUNKNOWN');
      expect(component, isNot(isA<Calendar>()));
    });

    test('values throws StateError when types do not match', () {
      final component = CalendarComponent(
        name: 'TEST',
        properties: {
          'MIXED': [
            PropertyValue(
              property: CalendarProperty(
                name: 'MIXED',
                value: 'string',
                parameters: {},
                lineNumber: 0,
              ),
              value: 'string',
            ),
            PropertyValue(
              property: CalendarProperty(
                name: 'MIXED',
                value: '123',
                parameters: {},
                lineNumber: 0,
              ),
              value: 123,
            ),
          ],
        },
        components: [],
      );

      expect(() => component.values<String>('MIXED'), throwsStateError);
    });
  });
}
