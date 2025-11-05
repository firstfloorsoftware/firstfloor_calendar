import 'package:collection/collection.dart';

import '../document/document.dart';
import 'semantic.dart';

/// Extensions for [CalDateTime] to enhance functionality.
extension CalDateTimeExtensions on CalDateTime {
  /// Determines if this date is after the [other] date.
  bool isAfter(CalDateTime other) {
    return native.isAfter(other.native);
  }

  /// Determines if this date is before the [other] date.
  bool isBefore(CalDateTime other) {
    return native.isBefore(other.native);
  }

  /// Adds a [CalDuration] to this date and returns the resulting date.
  CalDateTime addDuration(CalDuration duration) {
    final sign = duration.sign == Sign.negative ? -1 : 1;
    return add(
      weeks: duration.weeks * sign,
      days: duration.days * sign,
      hours: duration.hours * sign,
      minutes: duration.minutes * sign,
      seconds: duration.seconds * sign,
    );
  }

  /// The day of the year (1-365 or 1-366 in leap years).
  int get dayOfYear {
    final startOfYear = copyWith(
      month: 1,
      day: 1,
      hour: 0,
      minute: 0,
      second: 0,
    );
    return native.difference(startOfYear.native).inDays + 1;
  }

  /// The weekday of this date.
  Weekday get weekday {
    return Weekday.values[native.weekday % 7];
  }
}

/// Extensions for [RecurrenceRule] to enhance functionality.
extension RecurrenceRuleExtensions on RecurrenceRule {
  /// Determines if the recurrence rule is infinite (no end).
  bool get isInfinite => count == null && until == null;

  /// Determines if the recurrence rule is finite (has an end).
  bool get isFinite => !isInfinite;

  /// Determines if the recurrence rule has a COUNT limit.
  bool get hasCount => count != null;

  /// Determines if the recurrence rule has an UNTIL limit.
  bool get hasUntil => until != null;
}

/// Extensions for [EventComponent] to enhance functionality.
extension EventComponentExtensions on EventComponent {
  /// Determines if the event is recurring based on the presence of
  /// a recurrence rule (RRULE) or recurrence dates (RDATE).
  bool get isRecurring => rrule != null || rdates.isNotEmpty;

  /// Returns true if this event is an all-day event
  bool get isAllDay => dtstart?.isDate ?? false;

  /// Returns the effective end time (dtend or dtstart + duration)
  CalDateTime? get effectiveEnd {
    if (dtend != null) return dtend;
    if (duration != null && dtstart != null) {
      return dtstart!.addDuration(duration!);
    }
    return null;
  }

  /// Generates all occurrences of the event based on its recurrence
  /// rules, exclusions (EXDATE), and additional dates (RDATE).
  ///
  /// Returns an empty iterable if the event has no start date.
  Iterable<CalDateTime> occurrences() {
    if (dtstart == null) return const Iterable<CalDateTime>.empty();

    final iterator = RecurrenceIterator(
      dtstart: dtstart!,
      rrule: rrule,
      exdates: exdates,
      rdates: rdates,
    );
    return iterator.occurrences();
  }
}

/// Extensions for [TodoComponent] to enhance functionality.
extension TodoComponentExtensions on TodoComponent {
  /// Determines if the todo is recurring based on the presence of
  /// a recurrence rule (RRULE) or recurrence dates (RDATE).
  bool get isRecurring => rrule != null || rdates.isNotEmpty;

  /// Generates all occurrences of the todo based on its recurrence
  /// rules, exclusions (EXDATE), and additional dates (RDATE).
  ///
  /// Returns an empty iterable if the todo has no start date.
  Iterable<CalDateTime> occurrences() {
    if (dtstart == null) return const Iterable<CalDateTime>.empty();

    final iterator = RecurrenceIterator(
      dtstart: dtstart!,
      rrule: rrule,
      exdates: exdates,
      rdates: rdates,
    );
    return iterator.occurrences();
  }
}

/// Extensions for [JournalComponent] to enhance functionality.
extension JournalComponentExtensions on JournalComponent {
  /// Determines if the journal is recurring based on the presence of
  /// a recurrence rule (RRULE) or recurrence dates (RDATE).
  bool get isRecurring => rrule != null || rdates.isNotEmpty;

  /// Generates all occurrences of the journal based on its recurrence
  /// rules, exclusions (EXDATE), and additional dates (RDATE).
  ///
  /// Returns an empty iterable if the journal has no start date.
  Iterable<CalDateTime> occurrences() {
    if (dtstart == null) return const Iterable<CalDateTime>.empty();

    final iterator = RecurrenceIterator(
      dtstart: dtstart!,
      rrule: rrule,
      exdates: exdates,
      rdates: rdates,
    );
    return iterator.occurrences();
  }
}

/// Extensions for [TimeZoneSubComponent] to enhance functionality.
extension TimeZoneSubComponentExtensions on TimeZoneSubComponent {
  /// Determines if the timezone component is recurring based on the presence of
  /// a recurrence rule (RRULE) or recurrence dates (RDATE).
  bool get isRecurring => rrule != null || rdates.isNotEmpty;

  /// Generates all occurrences of the timezone component based on its recurrence
  /// rules, exclusions (EXDATE), and additional dates (RDATE).
  Iterable<CalDateTime> occurrences() {
    final iterator = RecurrenceIterator(
      dtstart: dtstart,
      rrule: rrule,
      rdates: rdates,
    );
    return iterator.occurrences();
  }
}

/// Extensions for [CalendarDocumentComponent] to enhance functionality.
extension CalendarDocumentComponentExtensions on CalendarDocumentComponent {
  /// Determines if this component is an event (VEVENT).
  bool get isEvent => name == 'VEVENT';

  /// Determines if this component is a todo (VTODO).
  bool get isTodo => name == 'VTODO';

  /// Determines if this component is a journal (VJOURNAL).
  bool get isJournal => name == 'VJOURNAL';

  /// Determines if this component is a free/busy (VFREEBUSY).
  bool get isFreeBusy => name == 'VFREEBUSY';

  /// Determines if this component is a timezone (VTIMEZONE).
  bool get isTimezone => name == 'VTIMEZONE';

  /// Determines if this component is an alarm (VALARM).
  bool get isAlarm => name == 'VALARM';

  /// Converts this raw component into a typed component using the given parser.
  EventComponent toEvent({CalendarParser? parser}) {
    if (!isEvent) throw Exception('Not an event component');
    parser ??= CalendarParser();
    return parser.parseComponent(this);
  }

  /// Converts this raw component into a typed todo component using the given parser.
  TodoComponent toTodo({CalendarParser? parser}) {
    if (!isTodo) throw Exception('Not a todo component');
    parser ??= CalendarParser();
    return parser.parseComponent(this);
  }

  /// Converts this raw component into a typed journal component using the given parser.
  JournalComponent toJournal({CalendarParser? parser}) {
    if (!isJournal) throw Exception('Not a journal component');
    parser ??= CalendarParser();
    return parser.parseComponent(this);
  }

  /// Converts this raw component into a typed free/busy component using the given parser.
  FreeBusyComponent toFreeBusy({CalendarParser? parser}) {
    if (!isFreeBusy) throw Exception('Not a free/busy component');
    parser ??= CalendarParser();
    return parser.parseComponent(this);
  }

  /// Converts this raw component into a typed timezone component using the given parser.
  TimeZoneComponent toTimeZone({CalendarParser? parser}) {
    if (!isTimezone) throw Exception('Not a timezone component');
    parser ??= CalendarParser();
    return parser.parseComponent(this);
  }

  /// Converts this raw component into a typed alarm component using the given parser.
  AlarmComponent toAlarm({CalendarParser? parser}) {
    if (!isAlarm) throw Exception('Not an alarm component');
    parser ??= CalendarParser();
    return parser.parseComponent(this);
  }
}

/// Represents a single event occurrence.
typedef EventOccurrence = ({CalDateTime occurrence, EventComponent event});

/// Query extensions for [Iterable]<[EventComponent]> to enhance functionality.
extension EventIterableQuery on Iterable<EventComponent> {
  /// Finds all event occurrences within the specified date range.
  ///
  /// [start] and [end] should be [CalDateTime] values that define the
  /// inclusive date range. Use [CalDateTime.date] for all-day boundaries
  /// or [CalDateTime] with time components for precise time ranges.
  ///
  /// For recurring events without an end date, occurrences are generated
  /// up to [end] only.
  ///
  /// Example with date-only boundaries:
  /// ```dart
  /// final start = CalDateTime.date(2025, 1, 1);
  /// final end = CalDateTime.date(2025, 1, 31);
  ///
  /// for (final result in calendar.events.inRange(start, end)) {
  ///   print('${result.event.summary}: ${result.occurrence}');
  /// }
  /// ```
  ///
  /// Example with date-time boundaries:
  /// ```dart
  /// final start = CalDateTime(2025, 1, 1, 9, 0, 0);
  /// final end = CalDateTime(2025, 1, 31, 17, 0, 0);
  ///
  /// for (final result in calendar.events.inRange(start, end)) {
  ///   print('${result.event.summary}: ${result.occurrence}');
  /// }
  /// ```
  Iterable<EventOccurrence> inRange(CalDateTime start, CalDateTime end) sync* {
    for (final event in this) {
      if (event.dtstart == null) continue;

      final iterator = RecurrenceIterator(
        dtstart: event.dtstart!,
        rrule: event.rrule,
        exdates: event.exdates,
        rdates: event.rdates,
      );

      for (final occurrence in iterator.occurrencesInRange(start, end)) {
        yield (occurrence: occurrence, event: event);
      }
    }
  }
}

/// Represents a single todo occurrence.
typedef TodoOccurrence = ({CalDateTime occurrence, TodoComponent todo});

/// Query extensions for [Iterable]<[TodoComponent]> to enhance functionality.
extension TodoIterableQuery on Iterable<TodoComponent> {
  /// Finds all todo occurrences within the specified date range.
  ///
  /// [start] and [end] should be [CalDateTime] values that define the
  /// inclusive date range. Use [CalDateTime.date] for all-day boundaries
  /// or [CalDateTime] with time components for precise time ranges.
  ///
  /// For recurring todos without an end date, occurrences are generated
  /// up to [end] only.
  ///
  /// Example with date-only boundaries:
  /// ```dart
  /// final start = CalDateTime.date(2025, 1, 1);
  /// final end = CalDateTime.date(2025, 1, 31);
  ///
  /// for (final result in calendar.todos.inRange(start, end)) {
  ///   print('${result.todo.summary}: ${result.occurrence}');
  /// }
  /// ```
  ///
  /// Example with date-time boundaries:
  /// ```dart
  /// final start = CalDateTime(2025, 1, 1, 9, 0, 0);
  /// final end = CalDateTime(2025, 1, 31, 17, 0, 0);
  ///
  /// for (final result in calendar.todos.inRange(start, end)) {
  ///   print('${result.todo.summary}: ${result.occurrence}');
  /// }
  /// ```
  Iterable<TodoOccurrence> inRange(CalDateTime start, CalDateTime end) sync* {
    for (final todo in this) {
      if (todo.dtstart == null) continue;

      final iterator = RecurrenceIterator(
        dtstart: todo.dtstart!,
        rrule: todo.rrule,
        exdates: todo.exdates,
        rdates: todo.rdates,
      );

      for (final occurrence in iterator.occurrencesInRange(start, end)) {
        yield (occurrence: occurrence, todo: todo);
      }
    }
  }
}

/// Represents a single journal occurrence.
typedef JournalOccurrence = ({
  CalDateTime occurrence,
  JournalComponent journal,
});

/// Query extensions for [Iterable]<[JournalComponent]> to enhance functionality.
extension JournalIterableQuery on Iterable<JournalComponent> {
  /// Finds all journal occurrences within the specified date range.
  ///
  /// [start] and [end] should be [CalDateTime] values that define the
  /// inclusive date range. Use [CalDateTime.date] for all-day boundaries
  /// or [CalDateTime] with time components for precise time ranges.
  ///
  /// For recurring journals without an end date, occurrences are generated
  /// up to [end] only.
  ///
  /// Example with date-only boundaries:
  /// ```dart
  /// final start = CalDateTime.date(2025, 1, 1);
  /// final end = CalDateTime.date(2025, 1, 31);
  ///
  /// for (final result in calendar.journals.inRange(start, end)) {
  ///   print('${result.journal.summary}: ${result.occurrence}');
  /// }
  /// ```
  ///
  /// Example with date-time boundaries:
  /// ```dart
  /// final start = CalDateTime(2025, 1, 1, 9, 0, 0);
  /// final end = CalDateTime(2025, 1, 31, 17, 0, 0);
  ///
  /// for (final result in calendar.journals.inRange(start, end)) {
  ///   print('${result.journal.summary}: ${result.occurrence}');
  /// }
  /// ```
  Iterable<JournalOccurrence> inRange(
    CalDateTime start,
    CalDateTime end,
  ) sync* {
    for (final journal in this) {
      if (journal.dtstart == null) continue;

      final iterator = RecurrenceIterator(
        dtstart: journal.dtstart!,
        rrule: journal.rrule,
        exdates: journal.exdates,
        rdates: journal.rdates,
      );

      for (final occurrence in iterator.occurrencesInRange(start, end)) {
        yield (occurrence: occurrence, journal: journal);
      }
    }
  }
}

/// Represents a single timezone occurrence.
typedef TimeZoneOccurrence = ({
  CalDateTime occurrence,
  TimeZoneSubComponent timezone,
});

/// Query extensions for [Iterable]<[TimeZoneSubComponent]> to enhance functionality.
extension TimeZoneIterableQuery on Iterable<TimeZoneSubComponent> {
  /// Finds all timezone occurrences within the specified date range.
  ///
  /// [start] and [end] should be [CalDateTime] values that define the
  /// inclusive date range. Use [CalDateTime.date] for all-day boundaries
  /// or [CalDateTime] with time components for precise time ranges.
  ///
  /// For recurring timezone rules without an end date, occurrences are generated
  /// up to [end] only.
  ///
  /// Example with date-only boundaries:
  /// ```dart
  /// final start = CalDateTime.date(2025, 1, 1);
  /// final end = CalDateTime.date(2025, 1, 31);
  ///
  /// for (final result in timezoneComponents.inRange(start, end)) {
  ///   print('${result.timezone.tzoffsetTo}: ${result.occurrence}');
  /// }
  /// ```
  ///
  /// Example with date-time boundaries:
  /// ```dart
  /// final start = CalDateTime(2025, 1, 1, 9, 0, 0);
  /// final end = CalDateTime(2025, 1, 31, 17, 0, 0);
  ///
  /// for (final result in timezoneComponents.inRange(start, end)) {
  ///   print('${result.timezone.tzoffsetTo}: ${result.occurrence}');
  /// }
  /// ```
  Iterable<TimeZoneOccurrence> inRange(
    CalDateTime start,
    CalDateTime end,
  ) sync* {
    for (final timezone in this) {
      final iterator = RecurrenceIterator(
        dtstart: timezone.dtstart,
        rrule: timezone.rrule,
        rdates: timezone.rdates,
      );

      for (final occurrence in iterator.occurrencesInRange(start, end)) {
        yield (occurrence: occurrence, timezone: timezone);
      }
    }
  }
}
