import 'package:collection/collection.dart';

import '../semantic.dart';

/// Represents a single event occurrence.
typedef EventOccurrence = ({CalDateTime occurrence, EventComponent event});

/// Query extensions for [Iterable]<[EventComponent]> to enhance functionality.
extension EventIterableQuery on Iterable<EventComponent> {
  /// Finds all event occurrences within the specified date range.
  ///
  /// Returns occurrences in chronological order across all events.
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
  Iterable<EventOccurrence> inRange(CalDateTime start, CalDateTime end) {
    return _OccurrenceIterator.inRange<EventComponent>(
      components: this,
      ignore: (event) => event.dtstart == null,
      occurrences: (event) => RecurrenceIterator(
        dtstart: event.dtstart!,
        rrule: event.rrule,
        exdates: event.exdates,
        rdates: event.rdates,
      ).occurrencesInRange(start, end, duration: event.effectiveDuration),
    ).map((e) => (occurrence: e.occurrence, event: e.component));
  }
}

/// Helper class to track a generic occurrence iterator.
class _OccurrenceIterator<T> implements Comparable<_OccurrenceIterator<T>> {
  final T component;
  final Iterator<CalDateTime> iterator;
  final int sequence;

  _OccurrenceIterator(this.component, this.iterator, this.sequence);

  @override
  int compareTo(_OccurrenceIterator<T> other) {
    final timeCompare = iterator.current.compareTo(other.iterator.current);
    if (timeCompare != 0) return timeCompare;
    // If same time, preserve insertion order (stable sort)
    return sequence.compareTo(other.sequence);
  }

  /// Returns occurrences in chronological order across all components.
  static Iterable<({CalDateTime occurrence, T component})> inRange<T>({
    required Iterable<T> components,
    required bool Function(T component) ignore,
    required Iterable<CalDateTime> Function(T component) occurrences,
  }) sync* {
    // Use a priority queue to efficiently get the earliest occurrence.
    // Use sequence number for stable sorting when occurrences are at the same time.
    var sequence = 0;
    final queue = PriorityQueue<_OccurrenceIterator<T>>();

    // setup iterators for each component and add to queue
    for (final component in components) {
      // skip ignored components
      if (ignore(component)) continue;

      final entry = _OccurrenceIterator<T>(
        component,
        occurrences(component).iterator,
        sequence++,
      );

      // add to queue if it has at least one occurrence
      if (entry.iterator.moveNext()) {
        queue.add(entry);
      }
    }

    // Process occurrences in chronological order using the queue
    while (queue.isNotEmpty) {
      final entry = queue.removeFirst();
      yield (occurrence: entry.iterator.current, component: entry.component);

      if (entry.iterator.moveNext()) {
        queue.add(entry); // Re-insert if it has more occurrences
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
  /// Returns occurrences in chronological order across all todos.
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
  Iterable<TodoOccurrence> inRange(CalDateTime start, CalDateTime end) {
    return _OccurrenceIterator.inRange<TodoComponent>(
      components: this,
      ignore: (todo) => todo.dtstart == null,
      occurrences: (todo) => RecurrenceIterator(
        dtstart: todo.dtstart!,
        rrule: todo.rrule,
        exdates: todo.exdates,
        rdates: todo.rdates,
      ).occurrencesInRange(start, end, duration: todo.effectiveDuration),
    ).map((e) => (occurrence: e.occurrence, todo: e.component));
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
  /// Returns occurrences in chronological order across all journals.
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
  Iterable<JournalOccurrence> inRange(CalDateTime start, CalDateTime end) {
    return _OccurrenceIterator.inRange<JournalComponent>(
      components: this,
      ignore: (journal) => journal.dtstart == null,
      occurrences: (journal) => RecurrenceIterator(
        dtstart: journal.dtstart!,
        rrule: journal.rrule,
        exdates: journal.exdates,
        rdates: journal.rdates,
      ).occurrencesInRange(start, end),
    ).map((e) => (occurrence: e.occurrence, journal: e.component));
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
  /// Returns occurrences in chronological order across all timezones.
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
  Iterable<TimeZoneOccurrence> inRange(CalDateTime start, CalDateTime end) {
    return _OccurrenceIterator.inRange<TimeZoneSubComponent>(
      components: this,
      ignore: (timezone) => false, // No timezones to ignore
      occurrences: (timezone) => RecurrenceIterator(
        dtstart: timezone.dtstart,
        rrule: timezone.rrule,
        rdates: timezone.rdates,
      ).occurrencesInRange(start, end),
    ).map((e) => (occurrence: e.occurrence, timezone: e.component));
  }
}

/// Extension providing query operations on [RecurrenceIterator].
extension RecurrenceIteratorQuery on RecurrenceIterator {
  /// Generates occurrences within the specified date range.
  ///
  /// Returns occurrences in chronological order.
  ///
  /// [start] and [end] define the inclusive date range.
  ///
  /// When [duration] is provided, the method checks for overlap:
  /// an occurrence is included if it starts at or before [end] AND
  /// ends (occurrence + duration) at or after [start]. This correctly
  /// handles multi-day events that may start before the range but
  /// extend into it.
  ///
  /// When [duration] is null, only the occurrence start time is checked.
  ///
  /// Example without duration:
  /// ```dart
  /// final iterator = RecurrenceIterator(
  ///   dtstart: CalDateTime(2025, 1, 1, 10, 0, 0),
  ///   rrule: RecurrenceRule(freq: Frequency.daily),
  /// );
  ///
  /// final start = CalDateTime(2025, 1, 10, 0, 0, 0);
  /// final end = CalDateTime(2025, 1, 20, 23, 59, 59);
  ///
  /// for (final occurrence in iterator.occurrencesInRange(start, end)) {
  ///   print(occurrence); // Only occurrences from Jan 10-20
  /// }
  /// ```
  ///
  /// Example with duration (multi-day event):
  /// ```dart
  /// final iterator = RecurrenceIterator(
  ///   dtstart: CalDateTime(2025, 1, 1, 10, 0, 0),
  ///   rrule: RecurrenceRule(freq: Frequency.weekly),
  /// );
  ///
  /// final duration = CalDuration(days: 3); // 3-day event
  /// final start = CalDateTime(2025, 1, 10, 0, 0, 0);
  /// final end = CalDateTime(2025, 1, 20, 23, 59, 59);
  ///
  /// for (final occurrence in iterator.occurrencesInRange(start, end, duration: duration)) {
  ///   print(occurrence); // Includes events that overlap the range
  /// }
  /// ```
  Iterable<CalDateTime> occurrencesInRange(
    CalDateTime start,
    CalDateTime end, {
    CalDuration? duration,
  }) sync* {
    if (start.isAfter(end)) {
      throw ArgumentError('start must be before or equal to end');
    }

    // If end is a date-only value, treat it as end of that day.
    // DATE values are timezone-agnostic, so we create a local date-time
    // without timezone to represent 23:59:59 on that date.
    final effectiveEnd = end.isDate
        ? CalDateTime.local(end.year, end.month, end.day, 23, 59, 59)
        : end;

    for (final o in occurrences()) {
      if (duration != null) {
        // With duration: check for overlap
        // Skip if occurrence ends before range starts
        final occurrenceEnd = o.addDuration(duration);
        if (occurrenceEnd.isBefore(start)) continue;

        // Stop when occurrence starts after range ends (crucial for infinite recurrences)
        if (o.isAfter(effectiveEnd)) break;

        yield o;
      } else {
        // Single-point occurrence logic
        // Skip occurrences before the range
        if (o.isBefore(start)) continue;

        // Stop when past the range (crucial for infinite recurrences)
        if (o.isAfter(effectiveEnd)) break;

        yield o;
      }
    }
  }
}
