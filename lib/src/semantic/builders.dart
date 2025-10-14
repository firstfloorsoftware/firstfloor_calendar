import 'semantic.dart';

/// A builder class for constructing [RecurrenceRule] instances.
class RecurrenceRuleBuilder {
  RecurrenceFrequency? _freq;
  CalDateTime? _until;
  int? _count;
  int _interval = 1;
  Set<int>? _bySecond;
  Set<int>? _byMinute;
  Set<int>? _byHour;
  Set<ByDay>? _byDay;
  Set<int>? _byMonthDay;
  Set<int>? _byYearDay;
  Set<int>? _byWeekNo;
  Set<int>? _byMonth;
  Set<int>? _bySetPos;
  Weekday? _wkst;

  /// Resets the builder to its initial state.
  void clear() {
    _freq = null;
    _until = null;
    _count = null;
    _interval = 1;
    _bySecond = null;
    _byMinute = null;
    _byHour = null;
    _byDay = null;
    _byMonthDay = null;
    _byYearDay = null;
    _byWeekNo = null;
    _byMonth = null;
    _bySetPos = null;
    _wkst = null;
  }

  /// Sets the frequency of the recurrence rule.
  void setFreq(RecurrenceFrequency freq) {
    _freq = freq;
  }

  /// Sets the UNTIL date of the recurrence rule.
  void setUntil(CalDateTime until) {
    _until = until;
  }

  /// Sets the COUNT of occurrences for the recurrence rule.
  void setCount(int count) {
    if (count <= 0) {
      throw ArgumentError('Count must be a positive integer, got: $count');
    }
    _count = count;
  }

  /// Sets the INTERVAL of the recurrence rule.
  void setInterval(int interval) {
    if (interval <= 0) {
      throw ArgumentError(
        'Interval must be a positive integer, got: $interval',
      );
    }
    _interval = interval;
  }

  /// Sets the BYSECOND values of the recurrence rule.
  void setBySecond(Set<int>? bySecond) {
    if (bySecond != null) {
      for (final second in bySecond) {
        if (second < 0 || second > 60) {
          throw ArgumentError(
            'BySecond values must be between 0 and 60, got: $second',
          );
        }
      }
    }
    _bySecond = bySecond;
  }

  /// Sets the BYMINUTE values of the recurrence rule.
  void setByMinute(Set<int>? byMinute) {
    if (byMinute != null) {
      for (final minute in byMinute) {
        if (minute < 0 || minute > 59) {
          throw ArgumentError(
            'ByMinute values must be between 0 and 59, got: $minute',
          );
        }
      }
    }
    _byMinute = byMinute;
  }

  /// Sets the BYHOUR values of the recurrence rule.
  void setByHour(Set<int>? byHour) {
    if (byHour != null) {
      for (final hour in byHour) {
        if (hour < 0 || hour > 23) {
          throw ArgumentError(
            'ByHour values must be between 0 and 23, got: $hour',
          );
        }
      }
    }
    _byHour = byHour;
  }

  /// Sets the BYDAY values of the recurrence rule.
  void setByDay(Set<ByDay>? byDay) {
    _byDay = byDay;
  }

  /// Sets the BYMONTHDAY values of the recurrence rule.
  void setByMonthDay(Set<int>? byMonthDay) {
    if (byMonthDay != null) {
      for (final day in byMonthDay) {
        if (day == 0 || day < -31 || day > 31) {
          throw ArgumentError(
            'ByMonthDay values must be between -31 and 31 (excluding 0), got: $day',
          );
        }
      }
    }
    _byMonthDay = byMonthDay;
  }

  /// Sets the BYYEARDAY values of the recurrence rule.
  void setByYearDay(Set<int>? byYearDay) {
    if (byYearDay != null) {
      for (final day in byYearDay) {
        if (day == 0 || day < -366 || day > 366) {
          throw ArgumentError(
            'ByYearDay values must be between -366 and 366 (excluding 0), got: $day',
          );
        }
      }
    }
    _byYearDay = byYearDay;
  }

  /// Sets the BYWEEKNO values of the recurrence rule.
  void setByWeekNo(Set<int>? byWeekNo) {
    if (byWeekNo != null) {
      for (final week in byWeekNo) {
        if (week == 0 || week < -53 || week > 53) {
          throw ArgumentError(
            'ByWeekNo values must be between -53 and 53 (excluding 0), got: $week',
          );
        }
      }
    }
    _byWeekNo = byWeekNo;
  }

  /// Sets the BYMONTH values of the recurrence rule.
  void setByMonth(Set<int>? byMonth) {
    if (byMonth != null) {
      for (final month in byMonth) {
        if (month < 1 || month > 12) {
          throw ArgumentError(
            'ByMonth values must be between 1 and 12, got: $month',
          );
        }
      }
    }
    _byMonth = byMonth;
  }

  /// Sets the BYSETPOS values of the recurrence rule.
  void setBySetPos(Set<int>? bySetPos) {
    if (bySetPos != null) {
      for (final pos in bySetPos) {
        if (pos == 0 || pos < -366 || pos > 366) {
          throw ArgumentError(
            'BySetPos values must be between -366 and 366 (excluding 0), got: $pos',
          );
        }
      }
    }
    _bySetPos = bySetPos;
  }

  /// Sets the WKST (week start) day of the recurrence rule.
  void setWkst(Weekday wkst) {
    _wkst = wkst;
  }

  /// Builds and returns the [RecurrenceRule] instance.
  RecurrenceRule build() {
    if (_freq == null) {
      throw StateError(
        'Required frequency must be set before building RecurrenceRule.',
      );
    }

    return RecurrenceRule(
      freq: _freq!,
      until: _until,
      count: _count,
      interval: _interval,
      bySecond: _bySecond,
      byMinute: _byMinute,
      byHour: _byHour,
      byDay: _byDay,
      byMonthDay: _byMonthDay,
      byYearDay: _byYearDay,
      byWeekNo: _byWeekNo,
      byMonth: _byMonth,
      bySetPos: _bySetPos,
      wkst: _wkst,
    );
  }
}
