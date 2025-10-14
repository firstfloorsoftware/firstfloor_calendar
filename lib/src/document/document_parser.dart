import 'dart:async';
import 'dart:convert';

import 'calendar_document.dart';
import 'parser.dart';

/// Parses iCalendar data from a string source.
/// This class works with in-memory strings. Use [DocumentStreamParser] for streaming large files and avoiding memory issues.
class DocumentParser {
  /// Maximum depth for nested components to prevent stack overflow.
  /// This is a safeguard against malformed iCalendar files that could lead to infinite recursion.
  final int maxDepth;

  /// Creates a new [DocumentParser] with the specified [maxDepth].
  /// The [maxDepth] must be greater than 0. The default is 50
  const DocumentParser({this.maxDepth = 50})
    : assert(maxDepth > 0, 'maxDepth must be greater than 0');

  /// Parses a complete iCalendar document from the source string.
  /// Returns a [CalendarDocument] containing the parsed properties and components.
  /// Expects the input string to be well-formed according to the iCalendar specification.
  /// No semantic validation is performed on the property values.
  CalendarDocument parse(String source) {
    final builder = _parseComponent(source, componentName: 'VCALENDAR');
    return builder.buildDocument();
  }

  /// Parses a single component from the source string.
  /// Returns a [CalendarDocumentComponent] containing the parsed properties and nested components.
  /// Expects the input string to be well-formed according to the iCalendar specification.
  /// No semantic validation is performed on the property values.
  CalendarDocumentComponent parseComponent(String source) {
    final builder = _parseComponent(source);
    return builder.build();
  }

  /// Parses a flat collection of properties from a string without parsing structure.
  /// Component properties are not nested and are returned as a simple list, including BEGIN and END properties.
  Iterable<CalendarProperty> parseProperties(String source) sync* {
    for (final (line, lineNumber) in unfold(source)) {
      final parser = _PropertyParser(line, lineNumber: lineNumber);
      yield parser.parse();
    }
  }

  _ComponentBuilder _parseComponent(String source, {String? componentName}) {
    final properties = parseProperties(source);
    final stack = _ComponentStack(
      componentName: componentName,
      maxDepth: maxDepth,
    );
    _ComponentBuilder? builder;
    for (final property in properties) {
      builder = stack.push(property);
    }
    stack.finalize();
    return builder!;
  }

  /// Parses a single property line and returns a [CalendarProperty].
  static CalendarProperty parseProperty(String line) {
    final parser = _PropertyParser(line, lineNumber: 0);
    return parser.parse();
  }

  /// Unfolds a multi-line string into individual lines, handling folded lines.
  /// Yields each line along with its original line number. Empty lines are not emitted.
  static Iterable<Line> unfold(String data) sync* {
    final buffer = StringBuffer();
    var lineNumber = 0;
    var lineStart = 1;

    for (final line in LineSplitter.split(data)) {
      lineNumber++;

      if (line.isEmpty) continue;

      final firstChar = line.codeUnitAt(0);
      if (firstChar == $space || firstChar == $htab) {
        buffer.write(line.substring(1));
      } else {
        if (buffer.isNotEmpty) {
          yield (buffer.toString(), lineStart);
          buffer.clear();
          lineStart = lineNumber;
        }
        buffer.write(line);
      }
    }

    if (buffer.isNotEmpty) {
      yield (buffer.toString(), lineStart);
    }
  }
}

/// Parses iCalendar data from a stream of bytes.
/// The streaming API allows for parsing large iCalendar files without loading the entire file into memory.
class DocumentStreamParser {
  /// Maximum depth for nested components to prevent stack overflow.
  /// This is a safeguard against malformed iCalendar files that could lead to infinite recursion.
  final int maxDepth;

  /// Creates a new [DocumentStreamParser] with the specified [maxDepth].
  /// The [maxDepth] must be greater than 0. The default is 50
  const DocumentStreamParser({this.maxDepth = 50})
    : assert(maxDepth > 0, 'maxDepth must be greater than 0');

  /// Parses a flat stream of calendar properties from a stream of bytes without parsing structure.
  Stream<CalendarProperty> parseProperties(Stream<List<int>> stream) {
    final controller = StreamController<CalendarProperty>();

    final sub = unfoldStream(stream).listen(
      (lineInfo) {
        final (line, lineNumber) = lineInfo;
        final parser = _PropertyParser(line, lineNumber: lineNumber);
        controller.add(parser.parse());
      },
      onError: controller.addError,
      onDone: () => controller.close(),
      cancelOnError: false,
    );

    controller.onPause = () => sub.pause();
    controller.onResume = () => sub.resume();
    controller.onCancel = () => sub.cancel();

    return controller.stream;
  }

  /// Parses top-level calendar components from a stream of bytes.
  /// The root VCALENDAR component is emitted before any nested components, and only contains top-level properties.
  Stream<CalendarDocumentComponent> parseComponents(Stream<List<int>> stream) {
    final controller = StreamController<CalendarDocumentComponent>();
    final stack = _ComponentStack(
      maxDepth: maxDepth,
      emitTopLevelComponents: true,
    );

    final sub = unfoldStream(stream).listen(
      (lineInfo) {
        final (line, lineNumber) = lineInfo;
        final parser = _PropertyParser(line, lineNumber: lineNumber);
        final property = parser.parse();
        final builder = stack.push(property);
        if (builder != null) {
          controller.add(builder.build());
        }
      },
      onError: controller.addError,
      onDone: () {
        try {
          stack.finalize();
          controller.close();
        } catch (e, st) {
          controller.addError(e, st);
          controller.close();
        }
      },
      cancelOnError: false,
    );

    controller.onPause = () => sub.pause();
    controller.onResume = () => sub.resume();
    controller.onCancel = () => sub.cancel();

    return controller.stream;
  }

  /// Unfolds a byte stream into individual lines, handling folded lines.
  /// Yields each line along with its original line number. Empty lines are not emitted.
  static Stream<Line> unfoldStream(
    Stream<List<int>> stream, {
    Encoding encoding = utf8,
  }) {
    final controller = StreamController<Line>();

    final buffer = StringBuffer();
    var lineNumber = 0;
    var lineStart = 1;

    void emitCurrent() {
      if (buffer.isNotEmpty) {
        controller.add((buffer.toString(), lineStart));
        buffer.clear();
      }
    }

    final sub = encoding.decoder
        .bind(stream)
        .transform(const LineSplitter())
        .listen(
          (line) {
            lineNumber++;
            if (line.isEmpty) return;

            final firstChar = line.codeUnitAt(0);
            if (firstChar == $space || firstChar == $htab) {
              // Continuation (folded) line: append (drop first char)
              buffer.write(line.substring(1));
            } else {
              // New logical line: flush previous
              emitCurrent();
              lineStart = lineNumber;
              buffer.write(line);
            }
          },
          onError: controller.addError,
          onDone: () {
            emitCurrent();
            controller.close();
          },
          cancelOnError: false,
        );

    controller.onPause = () => sub.pause();
    controller.onResume = () => sub.resume();
    controller.onCancel = () => sub.cancel();

    return controller.stream;
  }
}

class _ComponentStack {
  final String? componentName;
  final int maxDepth;
  final bool emitTopLevelComponents;
  final List<_ComponentBuilder> _builders = [];
  CalendarProperty? _lastProperty;

  _ComponentStack({
    this.componentName,
    this.maxDepth = 50,
    this.emitTopLevelComponents = false,
  }) : assert(maxDepth > 0, 'maxDepth must be greater than 0');

  /// Process a calendar property and manage the component stack.
  /// Returns the builder for a completed component.
  _ComponentBuilder? push(CalendarProperty property) {
    _lastProperty = property;

    if (_builders.isEmpty) {
      // drop END:CALENDAR if emitTopLevelComponents
      if (emitTopLevelComponents &&
          property.name == 'END' &&
          property.value == 'VCALENDAR') {
        return null;
      }

      // require BEGIN
      if (property.name != 'BEGIN' || property.parameters.isNotEmpty) {
        final name = componentName ?? '[NAME]';
        throw ParseException(
          'Expected "BEGIN:$name", found "$property"',
          lineNumber: property.lineNumber,
        );
      }

      // if component name specified, it must match
      if (componentName != null && property.value != componentName) {
        throw ParseException(
          'Expected "BEGIN:$componentName", found "$property"',
          lineNumber: property.lineNumber,
        );
      }
    }
    if (property.name == 'BEGIN') {
      // protect against excessive nesting
      if (_builders.length >= maxDepth) {
        throw ParseException(
          'Maximum component depth of $maxDepth exceeded',
          lineNumber: property.lineNumber,
        );
      }

      _ComponentBuilder? root;
      if (emitTopLevelComponents &&
          _builders.length == 1 &&
          _builders.first.name == 'VCALENDAR') {
        // remove root vcalendar
        root = _builders.removeLast();
      }

      if (_builders.isEmpty) {
        // start new component
        final builder = _ComponentBuilder(
          name: property.value,
          lineNumber: property.lineNumber,
        );
        _builders.add(builder);
      } else {
        // add nested component
        final builder = _builders.last.addComponent(
          name: property.value,
          lineNumber: property.lineNumber,
        );
        _builders.add(builder);
      }
      // emit root component
      if (root != null) {
        return root;
      }
    } else if (property.name == 'END') {
      // end current component
      if (property.value != _builders.last.name) {
        throw ParseException(
          'Expected "END:${_builders.last.name}", found "$property"',
          lineNumber: property.lineNumber,
        );
      }
      // remove builder
      final last = _builders.removeLast();

      // return root and/or top-level components
      if (_builders.isEmpty) {
        return last;
      }
    } else {
      // regular property
      _builders.last.addProperty(property);
    }

    return null;
  }

  /// Finalize the parsing process and ensure all components are complete.
  void finalize() {
    if (_lastProperty == null) {
      throw ParseException(
        'No properties found in the source string',
        lineNumber: 1,
      );
    }
    if (_builders.isNotEmpty) {
      throw ParseException(
        'Unexpected end of input while parsing component "${_builders.last.name}"',
        lineNumber: _lastProperty!.lineNumber + 1,
      );
    }
  }
}

class _ComponentBuilder {
  final String name;
  final List<CalendarProperty> properties = [];
  final List<_ComponentBuilder> components = [];
  final int lineNumber;

  _ComponentBuilder({required this.name, required this.lineNumber});

  void addProperty(CalendarProperty property) {
    properties.add(property);
  }

  _ComponentBuilder addComponent({
    required String name,
    required int lineNumber,
  }) {
    final builder = _ComponentBuilder(name: name, lineNumber: lineNumber);
    components.add(builder);
    return builder;
  }

  CalendarDocumentComponent build() {
    return CalendarDocumentComponent(
      name: name,
      properties: List.unmodifiable(properties),
      components: List.unmodifiable(components.map((c) => c.build())),
      lineNumber: lineNumber,
    );
  }

  CalendarDocument buildDocument() {
    return CalendarDocument(
      properties: List.unmodifiable(properties),
      components: List.unmodifiable(components.map((c) => c.build())),
      lineNumber: lineNumber,
    );
  }
}

class _PropertyParser extends Parser {
  _PropertyParser(super.value, {required super.lineNumber});

  CalendarProperty parse() {
    reset();

    final name = matchName();
    final next = matchOneOf([$colon, $semicolon]);
    if (next == $colon) {
      // parse value
      final value = match(isValueChar);
      matchOne(Parser.endOfLine);
      return CalendarProperty(name: name, value: value, lineNumber: lineNumber);
    } else {
      final parameters = <String, List<String>>{};
      // parse parameters
      while (column < super.source.length) {
        final paramName = matchName();

        if (parameters.containsKey(paramName)) {
          // rewind column for error message
          final c = column - paramName.length;
          throw ParseException(
            'Duplicate parameter name "$paramName" found',
            lineNumber: lineNumber,
            column: c,
          );
        }

        matchOne($equals);

        final paramValues = <String>[];

        // parse multiple parameter values
        while (true) {
          if (lookahead() == $dquote) {
            // quoted parameter value
            matchOne($dquote);
            paramValues.add(match(isQsafeChar));
            matchOne($dquote);
          } else {
            // unquoted parameter value
            paramValues.add(match(isSafeChar));
          }

          if (lookahead() == $comma) {
            // continue with next parameter value
            matchOne($comma);
          } else {
            // no more parameter values
            break;
          }
        }
        parameters[paramName] = paramValues;

        if (lookahead() == $semicolon) {
          matchOne($semicolon);
        } else {
          break; // no more parameters
        }
      }
      matchOne($colon);
      final value = match(isValueChar);
      matchOne(Parser.endOfLine);

      return CalendarProperty(
        name: name,
        parameters: Map.unmodifiable(parameters),
        value: value,
        lineNumber: lineNumber,
      );
    }
  }

  String matchName() {
    // Names are case-insensitive, and stored in uppercase
    final name = match(isNameChar).toUpperCase();

    return name.isNotEmpty
        ? name
        : throw ParseException(
            'Empty name found',
            lineNumber: lineNumber,
            column: column,
          );
  }
}
