import '../../document/document.dart';
import '../semantic.dart';

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

  /// Returns the effective duration of the event.
  ///
  /// If [duration] is specified, returns it directly.
  /// Otherwise, calculates duration from [effectiveEnd] - [dtstart].
  /// Returns null if the event has no duration or end time.
  CalDuration? get effectiveDuration {
    if (duration != null) return duration;

    final end = effectiveEnd;
    if (end != null && dtstart != null && end != dtstart) {
      final diff = end.native.difference(dtstart!.native);
      final isNegative = diff.isNegative;
      final absDiff = diff.abs();

      return CalDuration(
        sign: isNegative ? Sign.negative : Sign.positive,
        days: absDiff.inDays,
        hours: absDiff.inHours % 24,
        minutes: absDiff.inMinutes % 60,
        seconds: absDiff.inSeconds % 60,
      );
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

  /// Returns the effective duration of the todo.
  ///
  /// If [duration] is specified, returns it directly.
  /// Otherwise, calculates duration from [due] - [dtstart].
  /// Returns null if the todo has no duration or due date.
  CalDuration? get effectiveDuration {
    if (duration != null) return duration;

    if (due != null && dtstart != null && due != dtstart) {
      final diff = due!.native.difference(dtstart!.native);
      final isNegative = diff.isNegative;
      final absDiff = diff.abs();

      return CalDuration(
        sign: isNegative ? Sign.negative : Sign.positive,
        days: absDiff.inDays,
        hours: absDiff.inHours % 24,
        minutes: absDiff.inMinutes % 60,
        seconds: absDiff.inSeconds % 60,
      );
    }

    return null;
  }

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
