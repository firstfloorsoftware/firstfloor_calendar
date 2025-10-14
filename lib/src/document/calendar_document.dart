import 'package:collection/collection.dart';

/// Represents the raw structural representation of an iCalendar document
/// without any type interpretation of property values.
class CalendarDocument extends CalendarDocumentComponent {
  /// Creates a new calendar document with the given properties and components.
  const CalendarDocument({
    super.properties = const [],
    super.components = const [],
    super.lineNumber = 0,
  }) : super(name: 'VCALENDAR');
}

/// Represents a component in the calendar document structure.
class CalendarDocumentComponent {
  /// The name of the calendar component.
  final String name;

  /// The list of properties associated with this component.
  final List<CalendarProperty> properties;

  /// The list of sub-components within this component.
  final List<CalendarDocumentComponent> components;

  /// The line number where this component is defined.
  final int lineNumber;

  /// Creates a new  component with the given name, properties, and components.
  const CalendarDocumentComponent({
    required this.name,
    this.properties = const [],
    this.components = const [],
    this.lineNumber = 0,
  });

  /// Returns the properties with the given name.
  Iterable<CalendarProperty> propertiesNamed(String name) {
    return properties.where((p) => p.name == name);
  }

  /// Returns the values for the properties with the given name.
  Iterable<String> values(String name) {
    return properties.where((p) => p.name == name).map((p) => p.value);
  }

  // Return the first value for the given property name, or null if not found.
  String? value(String name) {
    return properties.firstWhereOrNull((p) => p.name == name)?.value;
  }

  /// Returns the components with the given name.
  Iterable<CalendarDocumentComponent> componentsNamed(String name) {
    return components.where((c) => c.name == name);
  }

  /// Returns the first component with the given name, or null if not found.
  CalendarDocumentComponent? component(String name) {
    return components.firstWhereOrNull((c) => c.name == name);
  }

  @override
  String toString() {
    return name;
  }
}

/// Represents a raw property in the document structure
class CalendarProperty {
  /// The name of the property.
  final String name;

  /// The parameters associated with the property, if any.
  final Map<String, List<String>> parameters;

  /// The raw value of the property.
  final String value;

  /// The line number where this property is defined.
  final int lineNumber;

  /// Creates a new calendar property with the given name, parameters, and value.
  const CalendarProperty({
    required this.name,
    this.parameters = const {},
    required this.value,
    this.lineNumber = 0,
  });

  @override
  String toString() {
    final params = parameters.entries
        .map((e) => '${e.key}=${e.value.join(',')}')
        .join(';');
    return '$name${params.isNotEmpty ? ';$params' : ''}:$value';
  }
}
