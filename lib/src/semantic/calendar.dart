import '../document/document.dart';
import 'semantic.dart';

/// Represents a calendar with typed access to its components and properties.
class Calendar extends CalendarComponent {
  late final List<EventComponent> _cachedEvents = List.unmodifiable(
    components.whereType<EventComponent>(),
  );
  late final List<TodoComponent> _cachedTodos = List.unmodifiable(
    components.whereType<TodoComponent>(),
  );
  late final List<JournalComponent> _cachedJournals = List.unmodifiable(
    components.whereType<JournalComponent>(),
  );
  late final List<FreeBusyComponent> _cachedFreeBusy = List.unmodifiable(
    components.whereType<FreeBusyComponent>(),
  );
  late final List<TimeZoneComponent> _cachedTimeZones = List.unmodifiable(
    components.whereType<TimeZoneComponent>(),
  );

  /// Creates a new calendar with the given properties.
  /// Properties are expected to be immutable and contain required values.
  Calendar({required super.properties, required super.components})
    : super(name: 'VCALENDAR');

  /// The version of the iCalendar specification used.
  String get version => value('VERSION');

  /// The product identifier for the calendar.
  String get prodid => value('PRODID');

  /// The calendar scale, defaults to 'GREGORIAN' if not specified.
  String get calscale => valueOrNull('CALSCALE') ?? 'GREGORIAN';

  /// The method associated with the calendar, if any.
  String? get method => valueOrNull('METHOD');

  /// The list of event components in the calendar.
  List<EventComponent> get events => _cachedEvents;

  /// The list of todo components in the calendar.
  List<TodoComponent> get todos => _cachedTodos;

  /// The list of journal components in the calendar.
  List<JournalComponent> get journals => _cachedJournals;

  /// The list of free/busy components in the calendar.
  List<FreeBusyComponent> get freeBusy => _cachedFreeBusy;

  /// The list of timezone components in the calendar.
  List<TimeZoneComponent> get timezones => _cachedTimeZones;
}

/// Represents an event in the calendar.
class EventComponent extends CalendarComponent {
  late final List<AlarmComponent> _cachedAlarms = List.unmodifiable(
    components.whereType<AlarmComponent>(),
  );

  late final Classification? _classification = classificationName != null
      ? ClassificationNames.tryParse(classificationName!)
      : null;

  late final EventStatus? _status = statusName != null
      ? EventStatusNames.tryParse(statusName!)
      : null;

  late final TimeTransparency? _transp = transpName != null
      ? TimeTransparencyNames.tryParse(transpName!)
      : null;

  /// Creates a new event with the given properties.
  /// Properties are expected to be immutable and contain required values.
  EventComponent({required super.properties, required super.components})
    : super(name: 'VEVENT');

  /// The list of alarm components associated with the event.
  List<AlarmComponent> get alarms => _cachedAlarms;

  /// The timestamp of when the event was created.
  CalDateTime get dtstamp => value('DTSTAMP');

  /// The unique identifier for the event.
  String get uid => value('UID');

  /// The start date and time of the event.
  CalDateTime? get dtstart => valueOrNull('DTSTART');

  /// The classification of the event, if any.
  Classification? get classification => _classification;

  /// The classification name as a string, if any.
  String? get classificationName => valueOrNull('CLASS');

  /// The creation date and time of the event, if any.
  CalDateTime? get created => valueOrNull('CREATED');

  /// The description of the event, if any.
  String? get description => valueOrNull('DESCRIPTION');

  /// The geographical location of the event, if any.
  GeoCoordinate? get geo => valueOrNull('GEO');

  /// The last modified date and time of the event, if any.
  CalDateTime? get lastModified => valueOrNull('LAST-MODIFIED');

  /// The location of the event, if any.
  String? get location => valueOrNull('LOCATION');

  /// The organizer of the event, if any.
  CalendarUserAddress? get organizer => valueOrNull('ORGANIZER');

  /// The percentage of completion of the event, if any.
  int? get priority => valueOrNull('PRIORITY');

  /// The sequence number of the event, if any.
  int? get sequence => valueOrNull('SEQUENCE');

  /// The status of the event, if any.
  EventStatus? get status => _status;

  /// The status name as a string, if any.
  String? get statusName => valueOrNull('STATUS');

  /// The summary or title of the event, if any.
  String? get summary => valueOrNull('SUMMARY');

  /// The transparency of the event, if any.
  TimeTransparency? get transp => _transp;

  /// The transparency name as a string, if any.
  String? get transpName => valueOrNull('TRANSP');

  /// The URL associated with the event, if any.
  Uri? get url => valueOrNull('URL');

  /// The recurrence identifier of the event, if any.
  String? get recurrenceId => valueOrNull('RECURRENCE-ID');

  /// The recurrence rule of the event, if any.
  RecurrenceRule? get rrule => valueOrNull('RRULE');

  /// The end date and time of the event, if any.
  CalDateTime? get dtend => valueOrNull('DTEND');

  /// The duration of the event, if any.
  CalDuration? get duration => valueOrNull('DURATION');

  /// The list of attachments associated with the event.
  List<Attachment> get attachments => values('ATTACH');

  /// The list of attendees associated with the event.
  List<CalendarUserAddress> get attendees => values('ATTENDEE');

  /// The list of categories associated with the event.
  List<String> get categories => valuesUnion('CATEGORIES');

  /// The list of comments associated with the event.
  List<String> get comments => values('COMMENT');

  /// The list of contacts associated with the event.
  List<CalendarUserAddress> get contacts => values('CONTACT');

  /// The list of exclusion dates associated with the event.
  List<CalDateTime> get exdates => valuesUnion('EXDATE');

  /// The list of related-to identifiers associated with the event.
  List<String> get relatedTo => values('RELATED-TO');

  /// The list of request statuses associated with the event.
  List<String> get requestStatus => values('REQUEST-STATUS');

  /// The list of resources associated with the event.
  List<CalendarUserAddress> get resources => values('RESOURCES');

  /// The list of recurrence dates associated with the event.
  List<RecurrenceDateTime> get rdates => values('RDATE');
}

/// Represents a todo item in the calendar.
class TodoComponent extends CalendarComponent {
  late final List<AlarmComponent> _cachedAlarms = List.unmodifiable(
    components.whereType<AlarmComponent>(),
  );

  late final Classification? _classification = classificationName != null
      ? ClassificationNames.tryParse(classificationName!)
      : null;

  late final TodoStatus? _status = statusName != null
      ? TodoStatusNames.tryParse(statusName!)
      : null;

  /// Creates a new todo with the given properties.
  /// Properties are expected to be immutable and contain required values.
  TodoComponent({required super.properties, required super.components})
    : super(name: 'VTODO');

  /// The list of alarm components associated with the todo.
  List<AlarmComponent> get alarms => _cachedAlarms;

  /// The timestamp of when the todo was created.
  CalDateTime get dtstamp => value('DTSTAMP');

  /// The unique identifier for the todo.
  String get uid => value('UID');

  /// The classification of the todo, if any.
  Classification? get classification => _classification;

  /// The classification name as a string, if any.
  String? get classificationName => valueOrNull('CLASS');

  /// The completion date and time of the todo, if any.
  CalDateTime? get completed => valueOrNull('COMPLETED');

  /// The creation date and time of the todo, if any.
  CalDateTime? get created => valueOrNull('CREATED');

  /// The description of the todo, if any.
  String? get description => valueOrNull('DESCRIPTION');

  /// The start date and time of the todo, if any.
  CalDateTime get dtstart => value('DTSTART');

  /// The geographical location of the todo, if any.
  GeoCoordinate? get geo => valueOrNull('GEO');

  /// The last modified date and time of the todo, if any.
  CalDateTime? get lastModified => valueOrNull('LAST-MODIFIED');

  /// The location of the todo, if any.
  String? get location => valueOrNull('LOCATION');

  /// The organizer of the todo, if any.
  CalendarUserAddress? get organizer => valueOrNull('ORGANIZER');

  /// The percentage of completion of the todo, if any.
  int? get percentComplete => valueOrNull('PERCENT-COMPLETE');

  /// The priority of the todo, if any.
  int? get priority => valueOrNull('PRIORITY');

  /// The recurrence identifier of the todo, if any.
  String? get recurrenceId => valueOrNull('RECURRENCE-ID');

  /// The sequence number of the todo, if any.
  int? get sequence => valueOrNull('SEQUENCE');

  /// The status of the todo, if any.
  TodoStatus? get status => _status;

  /// The status name as a string, if any.
  String? get statusName => valueOrNull('STATUS');

  /// The summary or title of the todo, if any.
  String? get summary => valueOrNull('SUMMARY');

  /// The URL associated with the todo, if any.
  Uri? get url => valueOrNull('URL');

  /// The recurrence rule of the todo, if any.
  RecurrenceRule? get rrule => valueOrNull('RRULE');

  /// The due date and time of the todo, if any.
  CalDateTime? get due => valueOrNull('DUE');

  /// The duration of the todo, if any.
  CalDuration? get duration => valueOrNull('DURATION');

  /// The list of attachments associated with the todo.
  List<Attachment> get attachments => values('ATTACH');

  /// The list of attendees associated with the todo.
  List<CalendarUserAddress> get attendees => values('ATTENDEE');

  /// The list of categories associated with the todo.
  List<String> get categories => valuesUnion('CATEGORIES');

  /// The list of comments associated with the todo.
  List<String> get comments => values('COMMENT');

  /// The list of contacts associated with the todo.
  List<CalendarUserAddress> get contacts => values('CONTACT');

  /// The list of exclusion dates associated with the todo.
  List<CalDateTime> get exdates => valuesUnion('EXDATE');

  /// The list of related-to identifiers associated with the todo.
  List<String> get relatedTo => values('RELATED-TO');

  /// The list of request statuses associated with the todo.
  List<String> get requestStatus => values('REQUEST-STATUS');

  /// The list of resources associated with the todo.
  List<CalendarUserAddress> get resources => values('RESOURCES');

  /// The list of recurrence dates associated with the todo.
  List<RecurrenceDateTime> get rdates => values('RDATE');
}

/// Represents a journal entry in the calendar.
class JournalComponent extends CalendarComponent {
  late final Classification? _classification = classificationName != null
      ? ClassificationNames.tryParse(classificationName!)
      : null;

  late final JournalStatus? _status = statusName != null
      ? JournalStatusNames.tryParse(statusName!)
      : null;

  /// Creates a new journal with the given properties.
  /// Properties are expected to be immutable and contain required values.
  JournalComponent({required super.properties, required super.components})
    : super(name: 'VJOURNAL');

  /// The timestamp of when the journal was created.
  CalDateTime get dtstamp => value('DTSTAMP');

  /// The unique identifier for the journal.
  String get uid => value('UID');

  /// The classification of the journal, if any.
  Classification? get classification => _classification;

  /// The classification name as a string, if any.
  String? get classificationName => valueOrNull('CLASS');

  /// The creation date and time of the journal, if any.
  CalDateTime? get created => valueOrNull('CREATED');

  /// The description of the journal, if any.
  CalDateTime get dtstart => value('DTSTART');

  /// The geographical location of the journal, if any.
  CalDateTime? get lastModified => valueOrNull('LAST-MODIFIED');

  /// The location of the journal, if any.
  CalendarUserAddress? get organizer => valueOrNull('ORGANIZER');

  /// The priority of the journal, if any.
  String? get recurrenceId => valueOrNull('RECURRENCE-ID');

  /// The sequence number of the journal, if any.
  int? get sequence => valueOrNull('SEQUENCE');

  /// The status of the journal, if any.
  JournalStatus? get status => _status;

  /// The status name as a string, if any.
  String? get statusName => valueOrNull('STATUS');

  /// The summary or title of the journal, if any.
  String? get summary => valueOrNull('SUMMARY');

  /// The URL associated with the journal, if any.
  Uri? get url => valueOrNull('URL');

  /// The recurrence rule of the journal, if any.
  RecurrenceRule? get rrule => valueOrNull('RRULE');

  /// The list of attachments associated with the journal.
  List<Attachment> get attachments => values('ATTACH');

  /// The list of attendees associated with the journal.
  List<CalendarUserAddress> get attendees => values('ATTENDEE');

  /// The list of categories associated with the journal.
  List<String> get categories => valuesUnion('CATEGORIES');

  /// The list of comments associated with the journal.
  List<String> get comments => values('COMMENT');

  /// The list of contacts associated with the journal.
  List<CalendarUserAddress> get contacts => values('CONTACT');

  /// The list of descriptions associated with the journal.
  List<String> get descriptions => values('DESCRIPTION');

  /// The list of exclusion dates associated with the journal.
  List<CalDateTime> get exdates => valuesUnion('EXDATE');

  /// The list of related-to identifiers associated with the journal.
  List<String> get relatedTo => values('RELATED-TO');

  /// The list of recurrence dates associated with the journal.
  List<RecurrenceDateTime> get rdates => values('RDATE');

  /// The list of request statuses associated with the journal.
  List<String> get requestStatus => values('REQUEST-STATUS');
}

/// Represents a free/busy time component in the calendar.
class FreeBusyComponent extends CalendarComponent {
  /// Creates a new free/busy time component with the given properties.
  /// Properties are expected to be immutable and contain required values.
  const FreeBusyComponent({
    required super.properties,
    required super.components,
  }) : super(name: 'VFREEBUSY');

  /// The timestamp of when the free/busy component was created.
  CalDateTime get dtstamp => value('DTSTAMP');

  /// The unique identifier for the free/busy component.
  String get uid => value('UID');

  /// The contact associated with the free/busy component, if any.
  CalendarUserAddress? get contact => value('CONTACT');

  /// The start date and time of the free/busy component, if any.
  CalDateTime? get dtstart => valueOrNull('DTSTART');

  /// The end date and time of the free/busy component, if any.
  CalDateTime? get dtend => valueOrNull('DTEND');

  /// The organizer of the free/busy component, if any.
  CalendarUserAddress? get organizer => valueOrNull('ORGANIZER');

  /// The URL associated with the free/busy component, if any.
  Uri? get url => valueOrNull('URL');

  /// The list of attendees associated with the free/busy component.
  List<CalendarUserAddress> get attendees => values('ATTENDEE');

  /// The list of comments associated with the free/busy component.
  List<String> get comments => values('COMMENT');

  /// The list of free/busy periods associated with the free/busy component.
  List<Period> get freebusy => valuesUnion('FREEBUSY');

  /// The list of request statuses associated with the free/busy component.
  List<String> get requestStatus => values('REQUEST-STATUS');
}

/// Represents a timezone in the calendar.
class TimeZoneComponent extends CalendarComponent {
  late final List<TimeZoneSubComponent> _cachedStandard = List.unmodifiable(
    components.whereType<TimeZoneSubComponent>().where(
      (c) => c.name == 'STANDARD',
    ),
  );
  late final List<TimeZoneSubComponent> _cachedDaylight = List.unmodifiable(
    components.whereType<TimeZoneSubComponent>().where(
      (c) => c.name == 'DAYLIGHT',
    ),
  );

  /// Creates a new timezone with the given properties.
  /// Properties are expected to be immutable and contain required values.
  TimeZoneComponent({required super.properties, required super.components})
    : super(name: 'VTIMEZONE');

  /// The list of standard time subcomponents in the timezone.
  List<TimeZoneSubComponent> get standard => _cachedStandard;

  /// The list of daylight time subcomponents in the timezone.
  List<TimeZoneSubComponent> get daylight => _cachedDaylight;

  /// The unique identifier for the timezone.
  String get tzid => value('TZID');

  /// The last modified date and time of the timezone, if any.
  CalDateTime? get lastModified => valueOrNull('LAST-MODIFIED');

  /// The URL associated with the timezone, if any.
  Uri? get tzurl => valueOrNull('TZURL');
}

/// Represents a subcomponent of a timezone, such as a specific time zone rule.
class TimeZoneSubComponent extends CalendarComponent {
  const TimeZoneSubComponent({
    required super.name,
    required super.properties,
    required super.components,
  });

  /// The date and time when the time zone rule starts.
  CalDateTime get dtstart => value('DTSTART');

  /// The time zone offset from which the rule applies.
  UtcOffset get tzoffsetFrom => value('TZOFFSETFROM');

  /// The time zone offset to which the rule applies.
  UtcOffset get tzoffsetTo => value('TZOFFSETTO');

  /// The recurrence rule for the time zone rule, if any.
  RecurrenceRule? get rrule => valueOrNull('RRULE');

  /// The comment associated with the time zone rule, if any.
  List<String> get comments => values('COMMENT');

  /// The list of recurrence dates associated with the time zone rule.
  List<RecurrenceDateTime> get rdates => values('RDATE');

  /// The list of time zone names associated with the time zone rule.
  List<String> get tznames => values('TZNAME');
}

/// Represents an alarm in the calendar.
class AlarmComponent extends CalendarComponent {
  late final AlarmAction? _action = actionName != null
      ? AlarmActionNames.tryParse(actionName!)
      : null;

  /// Creates a new alarm with the given properties.
  /// Properties are expected to be immutable and contain required values.
  AlarmComponent({required super.properties, required super.components})
    : super(name: 'VALARM');

  /// The action to be taken when the alarm triggers, if any.
  AlarmAction? get action => _action;

  /// The action name as a string, if any.
  String? get actionName => value('ACTION');

  /// The trigger for the alarm.
  Trigger get trigger => value('TRIGGER');

  /// The description of the alarm, if any.
  String? get description => valueOrNull('DESCRIPTION');

  /// The summary of the alarm, if any.
  String? get summary => valueOrNull('SUMMARY');

  /// The list of attendees associated with the alarm.
  List<CalendarUserAddress> get attendees => values('ATTENDEE');

  /// The duration of the alarm, if any.
  CalDuration? get duration => valueOrNull('DURATION');

  /// The number of times the alarm repeats, if any.
  int? get repeat => valueOrNull('REPEAT');

  /// The list of attachments associated with the alarm.
  List<Attachment> get attachments => values('ATTACH');
}

/// Represents the base implementation for calendar components.
class CalendarComponent {
  /// The name of the component, e.g., VCALENDAR, VEVENT, VTODO, etc.
  final String name;

  /// The properties of the component, mapped by property name to a list of values.
  final Map<String, List<PropertyValue>> properties;

  /// The nested components within this component.
  final List<CalendarComponent> components;

  /// Creates a new calendar component with the given name, properties, and components.
  /// Properties and components are expected to be immutable and contain required values.
  const CalendarComponent({
    required this.name,
    required this.properties,
    required this.components,
  });

  /// Factory constructor that creates a specific typed calendar component
  /// based on the provided component name.
  factory CalendarComponent.typed({
    required String componentName,
    required Map<String, List<PropertyValue>> properties,
    required List<CalendarComponent> components,
  }) {
    // create immutable collections
    properties = Map.unmodifiable(
      properties.map(
        (k, v) => MapEntry(k, List<PropertyValue>.unmodifiable(v)),
      ),
    );
    components = List.unmodifiable(components);

    switch (componentName) {
      case 'VCALENDAR':
        return Calendar(properties: properties, components: components);
      case 'VEVENT':
        return EventComponent(properties: properties, components: components);
      case 'VTODO':
        return TodoComponent(properties: properties, components: components);
      case 'VJOURNAL':
        return JournalComponent(properties: properties, components: components);
      case 'VFREEBUSY':
        return FreeBusyComponent(
          properties: properties,
          components: components,
        );
      case 'VTIMEZONE':
        return TimeZoneComponent(
          properties: properties,
          components: components,
        );
      case 'VALARM':
        return AlarmComponent(properties: properties, components: components);
      case 'STANDARD':
        return TimeZoneSubComponent(
          name: componentName,
          properties: properties,
          components: components,
        );
      case 'DAYLIGHT':
        return TimeZoneSubComponent(
          name: componentName,
          properties: properties,
          components: components,
        );
      default:
        // Fallback to generic component if no specific type matches
        return CalendarComponent(
          name: componentName,
          properties: properties,
          components: components,
        );
    }
  }

  /// Returns the first value for the given property name, or throws if not found.
  T value<T>(String name) =>
      valueOrNull<T>(name) ?? (throw StateError('No value for "$name"'));

  /// Returns the first value for the given property name, or null if not found.
  T? valueOrNull<T>(String name) {
    final values = properties[name];
    if (values == null || values.isEmpty) {
      return null;
    }
    final first = values.first;
    if (first.value is! T) {
      throw StateError(
        'Property "$name" has type ${first.value.runtimeType}, expected $T',
      );
    }
    return first.value as T;
  }

  /// Returns all values for the given property name, or an empty list if not found.
  List<T> values<T>(String name) {
    final values = properties[name];
    if (values == null) return [];
    // Find mismatched types for better error messages
    final mismatched = values.where((v) => v.value is! T).toList();
    if (mismatched.isNotEmpty) {
      final types = mismatched.map((v) => v.value.runtimeType).toSet();
      throw StateError(
        'Property "$name" contains values of types $types, expected all $T',
      );
    }
    return List.unmodifiable(values.map((v) => v.value as T));
  }

  /// Returns all values for the given property name, or an empty list if not found.
  /// This flattens all values into a single list, useful for properties that can have
  /// multiple values.
  /// For example, CATEGORIES can have multiple values separated by commas.
  List<T> valuesUnion<T>(String name) {
    final values = properties[name];
    if (values == null) return [];

    return List.unmodifiable(values.expand((v) => v.value as List<T>));
  }
}

/// Wrapper containing both the parsed value and source property
class PropertyValue<T> {
  /// The original calendar property from the source
  final CalendarProperty property;

  /// The parsed, typed value
  final T value;

  /// Creates a new property value with the given property and value.
  const PropertyValue({required this.property, required this.value});
}
