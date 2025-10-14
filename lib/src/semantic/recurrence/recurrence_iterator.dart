import '../semantic.dart';
import 'filters.dart';

/// An iterator that generates occurrences based on the provided
/// recurrence rule, start date, exclusions, and additional dates.
class RecurrenceIterator {
  static const int defaultMaxIterations = 10000;
  static const int absoluteMaxIterations = 100000; // hard ceiling

  /// The start date of the recurrence.
  final CalDateTime dtstart;

  /// The recurrence rule defining the pattern of recurrence.
  final RecurrenceRule? rrule;

  /// Dates to be excluded from the recurrence.
  final List<CalDateTime>? exdates;

  /// Additional dates to be included in the recurrence.
  final List<RecurrenceDateTime>? rdates;

  /// Maximum number of iterations to prevent infinite loops.
  final int maxIterations;

  /// Creates a [RecurrenceIterator] with the given parameters.
  RecurrenceIterator({
    required this.dtstart,
    this.rrule,
    this.exdates,
    this.rdates,
    int? maxIterations,
  }) : maxIterations = (maxIterations ?? defaultMaxIterations).clamp(
         1,
         absoluteMaxIterations,
       );

  /// Generates all occurrences of the event, applying exclusions and
  /// ensuring no duplicates.
  Iterable<CalDateTime> occurrences() sync* {
    final exclude = <CalDateTime>{};
    exclude.addAll(exdates ?? []);

    for (var o in _occurrences()) {
      // apply exclusions
      if (exclude.contains(o)) continue;

      // ensure we don't yield duplicates
      exclude.add(o);

      yield o;
    }
  }

  Iterable<CalDateTime> _occurrences() sync* {
    // include RRULE
    if (rrule != null) {
      yield* _generate(rrule!);
    } else {
      // if no RRULE, just yield DTSTART once
      yield dtstart;
    }

    // include RDATEs
    if (rdates != null) {
      for (final rdate in rdates!) {
        if (rdate.isPeriod) {
          // TODO: support RDATE periods
          throw UnsupportedError('RDATE periods are not supported yet');
        } else {
          yield rdate.dateTime!;
        }
      }
    }
  }

  Iterable<CalDateTime> _generate(RecurrenceRule rrule) sync* {
    final count = rrule.count ?? -1;
    final until = rrule.until != null ? _normalizeUntil(rrule.until!) : null;
    final filters = _getFilters(dtstart, rrule);

    // return early if any filter produces no occurrences
    if (filters.any((f) => f.hasNoOccurrences())) return;

    var current = dtstart;
    var done = false;
    var i = 0;
    var iterations = 0;

    while (!done) {
      if (++iterations > maxIterations) {
        throw StateError(
          'Recurrence generation exceeded safety limit of $maxIterations iterations.',
        );
      }

      // apply BYxxx rules
      // each filter will either expand (e.g. BYMONTH in YEARLY) or limit (e.g. BYMONTH in MONTHLY)
      Iterable<CalDateTime> result = [current];
      for (final filter in filters) {
        result = filter.transform(result);
      }

      for (final dt in result) {
        // skip occurrences before DTSTART
        if (dt.isBefore(dtstart)) {
          continue;
        }

        // limit by COUNT
        if (count != -1 && i >= count) {
          done = true;
          break;
        }

        // limit by UNTIL (except for DTSTART itself)
        if (until != null && dt != dtstart && dt.isAfter(until)) {
          done = true;
          break;
        }

        yield dt;
        i++;
      }

      // compute next occurrence based on frequency and interval
      current = _next(current, rrule);
    }
  }

  CalDateTime? _normalizeUntil(CalDateTime until) {
    // The value of the UNTIL rule part MUST have the same
    // value type as the "DTSTART" property.
    if (until.isDate != dtstart.isDate) {
      throw StateError('UNTIL and DTSTART must have the same value type');
    }

    // Furthermore, if the
    // "DTSTART" property is specified as a date with local time, then
    // the UNTIL rule part MUST also be specified as a date with local
    // time.  If the "DTSTART" property is specified as a date with UTC
    // time or a date with local time and time zone reference, then the
    // UNTIL rule part MUST be specified as a date with UTC time.
    if (dtstart.isDate) return until;
    final dtstartTime = dtstart.time!;

    // make sure UNTIL is in the same timezone as DTSTART
    // RFC5545 states UNTIL MUST be in same timezone, but reality is different
    return until.copyWith(isUtc: dtstartTime.isUtc, tzid: dtstartTime.tzid);
  }

  CalDateTime _next(CalDateTime current, RecurrenceRule rrule) {
    switch (rrule.freq) {
      case RecurrenceFrequency.secondly:
        return current.add(seconds: rrule.interval);
      case RecurrenceFrequency.minutely:
        return current.add(minutes: rrule.interval);
      case RecurrenceFrequency.hourly:
        return current.add(hours: rrule.interval);
      case RecurrenceFrequency.daily:
        return current.add(days: rrule.interval);
      case RecurrenceFrequency.weekly:
        return current.add(weeks: rrule.interval);
      case RecurrenceFrequency.monthly:
        // if there are no BYMONTHDAY or BYDAY rules, we can just add the interval
        // otherwise we need to go to the first of the month and let the filters handle it
        // This is because adding months can lead to skipping months if the current day
        // does not exist in the target month (e.g., Jan 31 + 1 month -> Feb 31 (invalid) -> Mar 3)
        if (rrule.byMonthDay != null || rrule.byDay != null) {
          return current.copyWith(day: 1).add(months: rrule.interval);
        }

        // add interval, and skip months that don't have the same day
        var next = current.add(months: rrule.interval);
        var index = 1;
        while (next.day != current.day) {
          next = current.add(months: rrule.interval * ++index);
        }
        return next;

      case RecurrenceFrequency.yearly:
        // add interval, and skip years that don't have the same day (feb 29)
        var next = current.add(years: rrule.interval);
        var index = 1;
        while (next.day != current.day && next.year <= 9999) {
          next = current.add(years: rrule.interval * ++index);
        }
        return next;
    }
  }

  List<ByRuleFilter> _getFilters(CalDateTime dtstart, RecurrenceRule rrule) {
    // RFC 5545 evaluation order:
    // BYMONTH, BYWEEKNO, BYYEARDAY, BYMONTHDAY, BYDAY, BYHOUR, BYMINUTE, BYSECOND
    return [
      if (rrule.byMonth != null) ByMonthFilter(rrule),
      if (rrule.byWeekNo != null) ByWeekNoFilter(rrule),
      if (rrule.byYearDay != null) ByYearDayFilter(rrule),
      if (rrule.byMonthDay != null) ByMonthDayFilter(rrule),
      if (rrule.byDay != null) ByDayFilter(rrule),

      // BYHOUR, BYMINUTE, BYSECOND only apply to date-time (not date) values
      if (dtstart.isDateTime && rrule.byHour != null) ByHourFilter(rrule),
      if (dtstart.isDateTime && rrule.byMinute != null) ByMinuteFilter(rrule),
      if (dtstart.isDateTime && rrule.bySecond != null) BySecondFilter(rrule),

      if (rrule.bySetPos != null) BySetPosFilter(rrule),
    ];
  }
}
