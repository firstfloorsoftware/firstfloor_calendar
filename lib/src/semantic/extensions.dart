import '../document/document.dart';
import 'semantic.dart';

extension CalDateTimeExtensions on CalDateTime {
  /// Determines if this date is after the [other] date.
  bool isAfter(CalDateTime other) {
    return native.isAfter(other.native);
  }

  /// Determines if this date is before the [other] date.
  bool isBefore(CalDateTime other) {
    return native.isBefore(other.native);
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

extension EventComponentExtensions on EventComponent {
  /// Determines if the event is recurring based on the presence of
  /// a recurrence rule (RRULE) or recurrence dates (RDATE).
  bool get isRecurring => rrule != null || rdates.isNotEmpty;

  /// Generates all occurrences of the event based on its recurrence
  /// rules, exclusions (EXDATE), and additional dates (RDATE).
  Iterable<CalDateTime> occurrences() {
    if (dtstart == null) {
      throw StateError('No DTSTART provided for recurrence generation');
    }

    final iterator = RecurrenceIterator(
      dtstart: dtstart!,
      rrule: rrule,
      exdates: exdates,
      rdates: rdates,
    );
    return iterator.occurrences();
  }
}

extension TodoComponentExtensions on TodoComponent {
  /// Determines if the todo is recurring based on the presence of
  /// a recurrence rule (RRULE) or recurrence dates (RDATE).
  bool get isRecurring => rrule != null || rdates.isNotEmpty;

  /// Generates all occurrences of the todo based on its recurrence
  /// rules, exclusions (EXDATE), and additional dates (RDATE).
  Iterable<CalDateTime> occurrences() {
    final iterator = RecurrenceIterator(
      dtstart: dtstart,
      rrule: rrule,
      exdates: exdates,
      rdates: rdates,
    );
    return iterator.occurrences();
  }
}

extension JournalComponentExtensions on JournalComponent {
  /// Determines if the journal is recurring based on the presence of
  /// a recurrence rule (RRULE) or recurrence dates (RDATE).
  bool get isRecurring => rrule != null || rdates.isNotEmpty;

  /// Generates all occurrences of the journal based on its recurrence
  /// rules, exclusions (EXDATE), and additional dates (RDATE).
  Iterable<CalDateTime> occurrences() {
    final iterator = RecurrenceIterator(
      dtstart: dtstart,
      rrule: rrule,
      exdates: exdates,
      rdates: rdates,
    );
    return iterator.occurrences();
  }
}

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
