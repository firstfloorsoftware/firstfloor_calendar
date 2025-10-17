# firstfloor_calendar

[![Pub Package](https://img.shields.io/pub/v/firstfloor_calendar.svg)](https://pub.dev/packages/firstfloor_calendar)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Dart library for parsing iCalendar (.ics) files with RFC 5545 support.

## Features

- Parse iCalendar files into strongly typed models
- Support for events, todos, journals, and timezones
- Full RRULE recurrence expansion
- Stream large files without loading into memory
- Extensible with custom property parsers

## Installation

```yaml
dependencies:
  firstfloor_calendar: ^1.0.0
```

## Usage

### Basic Parsing

Parse iCalendar text into a strongly typed `Calendar` object. The parser handles all RFC 5545 components including events, todos, journals, and timezones.

```dart
import 'package:firstfloor_calendar/firstfloor_calendar.dart';

final icsContent = '''
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Example//EN
BEGIN:VEVENT
UID:event-123@example.com
DTSTAMP:20240315T090000Z
DTSTART:20240315T100000Z
DTEND:20240315T110000Z
SUMMARY:Team Meeting
END:VEVENT
END:VCALENDAR''';

final parser = CalendarParser();
final calendar = parser.parseFromString(icsContent);

for (final event in calendar.events) {
  print('${event.summary}: ${event.dtstart}');
}
```

### Working with Events

Access event properties with full type safety. Required properties like `uid` and `dtstart` are non-nullable, while optional properties return nullable values.

```dart
final event = calendar.events.first;

// Required properties
print('UID: ${event.uid}');
print('Start: ${event.dtstart}');

// Optional properties
print('Summary: ${event.summary ?? "Untitled"}');
print('Location: ${event.location ?? "No location"}');
print('Description: ${event.description ?? ""}');

// Attendees
for (final attendee in event.attendees) {
  print('Attendee: ${attendee.address}');
}
```

### Recurring Events

Generate occurrences from recurrence rules (RRULE). The `occurrences()` method returns a lazy stream that handles both recurring and non-recurring events gracefully.

```dart
final event = calendar.events.first;

// Get first 10 occurrences
for (final occurrence in event.occurrences().take(10)) {
  print('Occurrence: $occurrence');
}
```

### Streaming Large Files

Parse large iCalendar files efficiently using the streaming parser. Components are processed one at a time without loading the entire file into memory.

```dart
import 'dart:io';

final file = File('large-calendar.ics');
final streamParser = DocumentStreamParser();

await for (final component in streamParser.parseComponents(file.openRead())) {
  if (component.name == 'VEVENT') {
    final summary = component.properties
        .where((p) => p.name == 'SUMMARY')
        .firstOrNull
        ?.value;
    print('Event: ${summary ?? "Untitled"}');
  }
}
```

### Custom Property Parsers

Extend the parser with custom property handlers for vendor-specific or experimental properties. Register custom parsers before parsing your calendar data.

```dart
final parser = CalendarParser();

parser.registerPropertyRule(
  componentName: 'VEVENT',
  propertyName: 'X-CUSTOM-PRIORITY',
  rule: PropertyRule(
    parser: (property) {
      final value = int.tryParse(property.value);
      if (value == null || value < 1 || value > 10) {
        throw ParseException(
          'X-CUSTOM-PRIORITY must be between 1-10',
          lineNumber: property.lineNumber,
        );
      }
      return value;
    },
  ),
);

final calendar = parser.parseFromString(icsContent);
final priority = calendar.events.first.value<int>('X-CUSTOM-PRIORITY');
```

## Architecture

The library uses a two-layer architecture:

- **Document Layer** (`DocumentParser`): Parses raw .ics text into an untyped tree structure
- **Semantic Layer** (`CalendarParser`): Converts the document tree into strongly typed models with validation

Use `DocumentParser` for low-level access, and `CalendarParser` for most applications.

## License

MIT License - see [LICENSE](LICENSE) file for details.
