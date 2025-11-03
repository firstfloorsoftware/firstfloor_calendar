import '../document/document.dart';
import 'semantic.dart';

/// Semantic parser for converting a structured calendar document or component into a Calendar model.
class CalendarParser {
  /// Built-in rules for parsing timezone properties.
  /// These rules are used for both STANDARD and DAYLIGHT components.
  static const Map<String, PropertyRule> timezonePropertyRules = {
    'DTSTART': PropertyRule(minOccurs: 1, parser: parseCalDateTimeLocal),
    'TZOFFSETFROM': PropertyRule(minOccurs: 1, parser: parseUtcOffset),
    'TZOFFSETTO': PropertyRule(minOccurs: 1, parser: parseUtcOffset),
    'RRULE': PropertyRule(parser: parseRecurrenceRule),
    'COMMENT': PropertyRule(maxOccurs: -1, parser: parseString),
    'RDATE': PropertyRule(maxOccurs: -1, parser: parseRecurrenceDateTime),
    'TZNAME': PropertyRule(maxOccurs: -1, parser: parseString),
  };

  /// Built-in rules for parsing common calendar properties.
  static const Map<String, Map<String, PropertyRule>> builtinPropertyRules = {
    'VCALENDAR': {
      'VERSION': PropertyRule(minOccurs: 1, parser: parseString),
      'PRODID': PropertyRule(minOccurs: 1, parser: parseString),
      'CALSCALE': PropertyRule(parser: parseString),
      'METHOD': PropertyRule(parser: parseString),
    },
    'VEVENT': {
    'DTSTAMP': PropertyRule(minOccurs: 1, parser: parseCalDateTimeUtc),
      'UID': PropertyRule(minOccurs: 1, parser: parseString),
      'DTSTART': PropertyRule(minOccurs: 1, parser: parseCalDateOrDateTime),
      'CLASS': PropertyRule(parser: parseString),
      'CREATED': PropertyRule(parser: parseCalDateTimeUtc),
      'DESCRIPTION': PropertyRule(parser: parseString),
      'GEO': PropertyRule(parser: parseGeoCoordinate),
      'LAST-MODIFIED': PropertyRule(parser: parseCalDateTimeUtc),
      'LOCATION': PropertyRule(parser: parseString),
      'ORGANIZER': PropertyRule(parser: parseCalAddress),
      'PRIORITY': PropertyRule(parser: parseInteger),
      'SEQUENCE': PropertyRule(parser: parseInteger),
      'STATUS': PropertyRule(parser: parseString),
      'SUMMARY': PropertyRule(parser: parseString),
      'TRANSP': PropertyRule(parser: parseString),
      'URL': PropertyRule(parser: parseUri),
      'RECURRENCE-ID': PropertyRule(parser: parseString),
      'RRULE': PropertyRule(parser: parseRecurrenceRule),
      'DTEND': PropertyRule(parser: parseCalDateOrDateTime),
      'DURATION': PropertyRule(parser: parseCalDuration),
      'ATTACH': PropertyRule(maxOccurs: -1, parser: parseAttachment),
      'ATTENDEE': PropertyRule(maxOccurs: -1, parser: parseCalAddress),
      'CATEGORIES': PropertyRule(maxOccurs: -1, parser: parseStringList),
      'COMMENT': PropertyRule(maxOccurs: -1, parser: parseString),
      'CONTACT': PropertyRule(maxOccurs: -1, parser: parseCalAddress),
      'EXDATE': PropertyRule(maxOccurs: -1, parser: parseCalDateOrDateTimeList),
      'RELATED-TO': PropertyRule(maxOccurs: -1, parser: parseString),
      'REQUEST-STATUS': PropertyRule(maxOccurs: -1, parser: parseString),
      'RESOURCE': PropertyRule(maxOccurs: -1, parser: parseCalAddress),
      'RDATE': PropertyRule(maxOccurs: -1, parser: parseRecurrenceDateTime),
    },
    'VTODO': {
      'DTSTAMP': PropertyRule(minOccurs: 1, parser: parseCalDateTimeUtc),
      'UID': PropertyRule(minOccurs: 1, parser: parseString),
      'CLASS': PropertyRule(parser: parseString),
      'COMPLETED': PropertyRule(parser: parseCalDateTimeUtc),
      'CREATED': PropertyRule(parser: parseCalDateTimeUtc),
      'DESCRIPTION': PropertyRule(parser: parseString),
      'DTSTART': PropertyRule(parser: parseCalDateOrDateTime),
      'GEO': PropertyRule(parser: parseGeoCoordinate),
      'LAST-MODIFIED': PropertyRule(parser: parseCalDateTimeUtc),
      'LOCATION': PropertyRule(parser: parseString),
      'ORGANIZER': PropertyRule(parser: parseCalAddress),
      'PERCENT-COMPLETE': PropertyRule(parser: parseInteger),
      'PRIORITY': PropertyRule(parser: parseInteger),
      'RECURRENCE-ID': PropertyRule(parser: parseString),
      'SEQUENCE': PropertyRule(parser: parseInteger),
      'STATUS': PropertyRule(parser: parseString),
      'SUMMARY': PropertyRule(parser: parseString),
      'URL': PropertyRule(parser: parseUri),
      'RRULE': PropertyRule(parser: parseRecurrenceRule),
      'DUE': PropertyRule(parser: parseCalDateOrDateTime),
      'DURATION': PropertyRule(parser: parseCalDuration),
      'ATTACH': PropertyRule(maxOccurs: -1, parser: parseAttachment),
      'ATTENDEE': PropertyRule(maxOccurs: -1, parser: parseCalAddress),
      'CATEGORIES': PropertyRule(maxOccurs: -1, parser: parseStringList),
      'COMMENT': PropertyRule(maxOccurs: -1, parser: parseString),
      'CONTACT': PropertyRule(maxOccurs: -1, parser: parseCalAddress),
      'EXDATE': PropertyRule(maxOccurs: -1, parser: parseCalDateOrDateTimeList),
      'RELATED-TO': PropertyRule(maxOccurs: -1, parser: parseString),
      'REQUEST-STATUS': PropertyRule(maxOccurs: -1, parser: parseString),
      'RESOURCE': PropertyRule(maxOccurs: -1, parser: parseCalAddress),
      'RDATE': PropertyRule(maxOccurs: -1, parser: parseRecurrenceDateTime),
    },
    'VJOURNAL': {
      'DTSTAMP': PropertyRule(minOccurs: 1, parser: parseCalDateTimeUtc),
      'UID': PropertyRule(minOccurs: 1, parser: parseString),
      'CLASS': PropertyRule(parser: parseString),
      'CREATED': PropertyRule(parser: parseCalDateTimeUtc),
      'DTSTART': PropertyRule(parser: parseCalDateOrDateTime),
      'LAST-MODIFIED': PropertyRule(parser: parseCalDateTimeUtc),
      'ORGANIZER': PropertyRule(parser: parseCalAddress),
      'PRIORITY': PropertyRule(parser: parseInteger),
      'RECURRENCE-ID': PropertyRule(parser: parseString),
      'SEQUENCE': PropertyRule(parser: parseInteger),
      'STATUS': PropertyRule(parser: parseString),
      'SUMMARY': PropertyRule(parser: parseString),
      'URL': PropertyRule(parser: parseUri),
      'RRULE': PropertyRule(parser: parseRecurrenceRule),
      'ATTACH': PropertyRule(maxOccurs: -1, parser: parseAttachment),
      'ATTENDEE': PropertyRule(maxOccurs: -1, parser: parseCalAddress),
      'CATEGORIES': PropertyRule(maxOccurs: -1, parser: parseStringList),
      'COMMENT': PropertyRule(maxOccurs: -1, parser: parseString),
      'CONTACT': PropertyRule(maxOccurs: -1, parser: parseCalAddress),
      'DESCRIPTION': PropertyRule(maxOccurs: -1, parser: parseString),
      'EXDATE': PropertyRule(maxOccurs: -1, parser: parseCalDateOrDateTimeList),
      'RELATED-TO': PropertyRule(maxOccurs: -1, parser: parseString),
      'RDATE': PropertyRule(maxOccurs: -1, parser: parseRecurrenceDateTime),
      'REQUEST-STATUS': PropertyRule(maxOccurs: -1, parser: parseString),
    },
    'VFREEBUSY': {
      'DTSTAMP': PropertyRule(minOccurs: 1, parser: parseCalDateTimeUtc),
      'UID': PropertyRule(minOccurs: 1, parser: parseString),
      'CONTACT': PropertyRule(parser: parseCalAddress),
      'DTSTART': PropertyRule(parser: parseCalDateTimeUtc),
      'DTEND': PropertyRule(parser: parseCalDateOrDateTime),
      'ORGANIZER': PropertyRule(parser: parseCalAddress),
      'URL': PropertyRule(parser: parseUri),
      'ATTENDEE': PropertyRule(maxOccurs: -1, parser: parseCalAddress),
      'COMMENT': PropertyRule(maxOccurs: -1, parser: parseString),
      'FREEBUSY': PropertyRule(maxOccurs: -1, parser: parsePeriodList),
      'REQUEST-STATUS': PropertyRule(maxOccurs: -1, parser: parseString),
    },
    'VTIMEZONE': {
      'TZID': PropertyRule(minOccurs: 1, parser: parseString),
      'LAST-MODIFIED': PropertyRule(parser: parseCalDateTimeUtc),
      'TZURL': PropertyRule(parser: parseUri),
    },
    'STANDARD': timezonePropertyRules,
    'DAYLIGHT': timezonePropertyRules,
    'VALARM': {
      'ACTION': PropertyRule(minOccurs: 1, parser: parseString),
      'TRIGGER': PropertyRule(minOccurs: 1, parser: parseTrigger),
      'DESCRIPTION': PropertyRule(parser: parseString),
      'SUMMARY': PropertyRule(parser: parseString),
      'ATTENDEE': PropertyRule(maxOccurs: -1, parser: parseCalAddress),
      'DURATION': PropertyRule(parser: parseCalDuration),
      'REPEAT': PropertyRule(parser: parseInteger),
      'ATTACH': PropertyRule(parser: parseAttachment),
    },
  };

  final Map<String, Map<String, PropertyRule>> _customPropertyRules = {};

  /// Registers a custom property rule.
  /// When componentName is null, the rule will be applied to all components.
  /// Component name null has lower priority than specific component rules.
  void registerPropertyRule({
    String? componentName,
    required String propertyName,
    required PropertyRule rule,
  }) {
    // Use '*' for global rules
    final key = componentName ?? '*';
    _customPropertyRules.putIfAbsent(key, () => {})[propertyName] = rule;
  }

  /// Parses a [CalendarDocument] into a [Calendar] model.
  Calendar parse(CalendarDocument document) {
    return _ComponentParser(
          component: document,
          customPropertyRules: _customPropertyRules,
        ).parse()
        as Calendar;
  }

  /// Parses a single component.
  /// This is useful for parsing components like VEVENT, VTODO, etc.
  T parseComponent<T extends CalendarComponent>(
    CalendarDocumentComponent component,
  ) {
    return _ComponentParser(
          component: component,
          customPropertyRules: _customPropertyRules,
        ).parse()
        as T;
  }

  /// Parses a calendar from a string source.
  Calendar parseFromString(String source) {
    final parser = DocumentParser();
    final document = parser.parse(source);
    return parse(document);
  }

  /// Parses a single component from a string source.
  T parseComponentFromString<T extends CalendarComponent>(String source) {
    final parser = DocumentParser();
    final component = parser.parseComponent(source);
    return parseComponent<T>(component);
  }
}

class _ComponentParser {
  final CalendarDocumentComponent component;
  final Map<String, Map<String, PropertyRule>> customPropertyRules;
  final Map<String, List<PropertyValue>> properties = {};
  final List<CalendarComponent> components = [];

  _ComponentParser({
    required this.component,
    required this.customPropertyRules,
  });

  CalendarComponent parse() {
    // Get property rules for this component
    final builtinRules =
        CalendarParser.builtinPropertyRules[component.name] ?? {};
    final globalRules = customPropertyRules['*'] ?? {};
    final customRules = customPropertyRules[component.name] ?? {};
    // combine all rules, order is important
    final rules = {...builtinRules, ...globalRules, ...customRules};

    // parse  properties
    for (final property in component.properties) {
      // check if the property has a rule
      final rule = rules[property.name];
      // if no rule is found, unlimited occurrences are allowed
      final maxOccurs = rule?.maxOccurs ?? -1;

      // validate maxOccurs early
      if (maxOccurs >= 0 &&
          (properties[property.name]?.length ?? 0) >= maxOccurs) {
        throw ParseException(
          maxOccurs == 1
              ? 'Property "${property.name}" may not occur more than once'
              : 'Property "${property.name}" may not occur more than $maxOccurs times ',
          lineNumber: property.lineNumber,
        );
      }

      // parse value using the rule, or fall back to raw parser
      final parser = rule?.parser ?? parseRaw;

      properties
          .putIfAbsent(property.name, () => [])
          .add(PropertyValue(property: property, value: parser(property)));
    }

    // make sure minOccurs is satisfied
    for (final entry in rules.entries) {
      final name = entry.key;
      final rule = entry.value;

      if (rule.minOccurs > 0 &&
          (properties[name]?.length ?? 0) < rule.minOccurs) {
        throw ParseException(
          rule.minOccurs == 1
              ? 'Property "$name" must occur at least once'
              : 'Property "$name" must occur at least ${rule.minOccurs} times',
          lineNumber: component.lineNumber,
        );
      }
    }

    // parse sub-components
    for (final c in component.components) {
      final parser = _ComponentParser(
        component: c,
        customPropertyRules: customPropertyRules,
      );
      final result = parser.parse();
      components.add(result);
    }

    final result = CalendarComponent.typed(
      componentName: component.name,
      properties: properties,
      components: components,
    );

    return result;
  }
}

/// Defines a function type for parsing calendar properties.
typedef PropertyParser = dynamic Function(CalendarProperty property);

/// Represents a rule for parsing a specific calendar property.
/// This includes validation for occurrences and a parser function.
class PropertyRule {
  /// Minimum number of occurrences (0 or more).
  final int minOccurs;

  /// Maximum number of occurrences (-1 for unlimited).
  final int maxOccurs;

  /// The function that will parse the property value.
  final PropertyParser parser;

  /// Creates a new PropertyRule with the specified parameters.
  /// - [minOccurs] is the minimum number of occurrences (default is 0).
  /// - [maxOccurs] is the maximum number of occurrences (default is 1, -1 for unlimited).
  /// - [parser] is the function that will parse the property value.
  /// Throws an [AssertionError] if the parameters are invalid.
  const PropertyRule({
    this.minOccurs = 0,
    this.maxOccurs = 1,
    required this.parser,
  }) : assert(minOccurs >= 0, 'minOccurs must be >= 0'),
       assert(
         maxOccurs == -1 || maxOccurs >= minOccurs,
         'maxOccurs must be -1 or >= minOccurs',
       );
}
