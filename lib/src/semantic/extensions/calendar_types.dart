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
