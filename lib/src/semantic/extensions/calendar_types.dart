import '../semantic.dart';

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

  /// Checks if this date (with optional duration) falls within or overlaps a date range.
  ///
  /// When [duration] is null, checks if this date is between [start] and [end] (inclusive).
  ///
  /// When [duration] is provided, checks for overlap: the date range defined by
  /// this date to this date + [duration] overlaps with the range [start] to [end].
  /// This means the date is included if:
  /// - The date starts at or before [end], AND
  /// - The date + duration ends at or after [start]
  ///
  /// Examples:
  /// ```dart
  /// // Point-in-time check
  /// final date = CalDateTime.local(2025, 1, 15, 10, 0, 0);
  /// date.isInRange(
  ///   CalDateTime.local(2025, 1, 1, 0, 0, 0),
  ///   CalDateTime.local(2025, 1, 31, 23, 59, 59),
  /// ); // true
  ///
  /// // Multi-day event overlap check
  /// final eventStart = CalDateTime.local(2025, 1, 30, 10, 0, 0);
  /// eventStart.isInRange(
  ///   CalDateTime.local(2025, 2, 1, 0, 0, 0),   // Range starts Feb 1
  ///   CalDateTime.local(2025, 2, 28, 23, 59, 59),
  ///   duration: CalDuration(days: 3),  // Event ends Feb 2
  /// ); // true - event overlaps range
  /// ```
  bool isInRange(CalDateTime start, CalDateTime end, {CalDuration? duration}) {
    if (duration != null) {
      // Overlap logic: check if date range overlaps with query range
      final dateEnd = addDuration(duration);
      // Include if date ends at or after range start AND date starts at or before range end
      return !dateEnd.isBefore(start) && !isAfter(end);
    } else {
      // Point-in-time logic: check if date is within range
      return !isBefore(start) && !isAfter(end);
    }
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
