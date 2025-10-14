import 'package:firstfloor_calendar/firstfloor_calendar.dart';

void main() {
  // Sample iCalendar content
  final icsContent = '''
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Example//EN
BEGIN:VEVENT
UID:daily-standup@example.com
DTSTAMP:20240315T080000Z
DTSTART:20240315T090000Z
DTEND:20240315T091500Z
SUMMARY:Daily Standup
LOCATION:Conference Room A
RRULE:FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR;COUNT=10
END:VEVENT
BEGIN:VEVENT
UID:team-lunch@example.com
DTSTAMP:20240320T100000Z
DTSTART:20240320T120000Z
DTEND:20240320T130000Z
SUMMARY:Team Lunch
LOCATION:Downtown Bistro
DESCRIPTION:Monthly team lunch to celebrate achievements
END:VEVENT
END:VCALENDAR''';

  // Parse the calendar
  final parser = CalendarParser();
  final calendar = parser.parseFromString(icsContent);

  print('Calendar: ${calendar.prodid}');
  print('Events: ${calendar.events.length}\n');

  // List all events
  for (final event in calendar.events) {
    print('📅 ${event.summary}');
    print('   Start: ${event.dtstart}');
    if (event.location != null) {
      print('   Location: ${event.location}');
    }
    if (event.description != null) {
      print('   Description: ${event.description}');
    }

    // Show recurring event occurrences
    if (event.rrule != null) {
      print('   Recurring: ${event.rrule!.freq}');
      print('   First 5 occurrences:');
      for (final occurrence in event.occurrences().take(5)) {
        print('     • $occurrence');
      }
    }
    print('');
  }
}
