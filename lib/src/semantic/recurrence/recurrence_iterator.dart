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

  /// Generates all date time occurrences, applying exclusions and ensuring no duplicates.
  ///
  /// This method applies EXDATE exclusions and deduplicates occurrences
  /// from the merged RRULE and RDATE stream.
  Iterable<CalDateTime> occurrences() sync* {
    // Only store EXDATEs (finite set) for exclusion checking
    final exdateSet = <CalDateTime>{};
    exdateSet.addAll(exdates ?? []);

    // Track last yielded occurrence for duplicate detection (O(1) memory).
    // This sliding window approach works because:
    // 1. The merged stream from _occurrences() is sorted chronologically
    // 2. Duplicates can only occur consecutively (same timestamp from both sources)
    // 3. We only need to compare with the immediately previous occurrence
    // This prevents memory leaks from storing all occurrences for infinite RRULEs.
    CalDateTime? lastYielded;

    for (var o in _occurrences()) {
      // Skip if excluded (EXDATE) or duplicate (same as last yielded)
      if (exdateSet.contains(o)) continue;
      if (lastYielded == o) continue;

      lastYielded = o;
      yield o;
    }
  }

  /// Generates occurrences by merging RRULE-based occurrences with RDATEs
  /// in chronological order.
  ///
  /// This maintains lazy evaluation for potentially infinite recurrence rules
  /// while ensuring proper ordering.
  Iterable<CalDateTime> _occurrences() sync* {
    // Pre-sort RDATEs (finite list) for chronological merging
    final sortedRDates = <CalDateTime>[];
    if (rdates != null) {
      for (final rdate in rdates!) {
        if (rdate.isPeriod) {
          throw UnsupportedError(
            'RDATE with PERIOD values is not yet supported. '
            'Only RDATE with DATE-TIME values are currently supported.',
          );
        }
        sortedRDates.add(rdate.dateTime!);
      }
      sortedRDates.sort();
    }

    var rdateIndex = 0;

    // Merge RRULE occurrences and RDATEs in chronological order
    for (var o in _generate()) {
      // Yield all RDATEs that come before this RRULE occurrence
      while (rdateIndex < sortedRDates.length &&
          sortedRDates[rdateIndex].isBefore(o)) {
        yield sortedRDates[rdateIndex++];
      }

      // Now yield the RRULE occurrence
      yield o;
    }

    // Yield any remaining RDATEs after all RRULE occurrences
    while (rdateIndex < sortedRDates.length) {
      yield sortedRDates[rdateIndex++];
    }
  }

  /// Generates RRULE-based occurrences or DTSTART if no RRULE.
  Iterable<CalDateTime> _generate() sync* {
    // Generate RRULE-based occurrences
    if (rrule != null) {
      yield* _generateFromRule(rrule!);
    } else {
      // if no RRULE, just yield DTSTART once
      yield dtstart;
    }
  }

  Iterable<CalDateTime> _generateFromRule(RecurrenceRule rrule) sync* {
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
