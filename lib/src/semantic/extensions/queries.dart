import '../semantic.dart';

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

      for (final occurrence in iterator.occurrencesInRange(
        start,
        end,
        duration: event.effectiveDuration,
      )) {
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

      for (final occurrence in iterator.occurrencesInRange(
        start,
        end,
        duration: todo.effectiveDuration,
      )) {
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
