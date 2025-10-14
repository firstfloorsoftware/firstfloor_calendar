const $htab = 0x09;
const $lf = 0x0a;
const $cr = 0x0d;
const $space = 0x20;
const $dquote = 0x22;
const $plus = 0x2b;
const $comma = 0x2c;
// both minus and hyphen are the same character
const $minus = 0x2d;
const $hyphen = 0x2d;
const $0 = 0x30;
const $9 = 0x39;
const $colon = 0x3a;
const $semicolon = 0x3b;
const $equals = 0x3d;
const $a = 0x61;
const $b = 0x62;
const $c = 0x63;
const $d = 0x64;
const $e = 0x65;
const $f = 0x66;
const $g = 0x67;
const $h = 0x68;
const $i = 0x69;
const $j = 0x6a;
const $k = 0x6b;
const $l = 0x6c;
const $m = 0x6d;
const $n = 0x6e;
const $o = 0x6f;
const $p = 0x70;
const $q = 0x71;
const $r = 0x72;
const $s = 0x73;
const $t = 0x74;
const $u = 0x75;
const $v = 0x76;
const $w = 0x77;
const $x = 0x78;
const $y = 0x79;
const $z = 0x7a;
const $A = 0x41;
const $B = 0x42;
const $C = 0x43;
const $D = 0x44;
const $E = 0x45;
const $F = 0x46;
const $G = 0x47;
const $H = 0x48;
const $I = 0x49;
const $J = 0x4a;
const $K = 0x4b;
const $L = 0x4c;
const $M = 0x4d;
const $N = 0x4e;
const $O = 0x4f;
const $P = 0x50;
const $Q = 0x51;
const $R = 0x52;
const $S = 0x53;
const $T = 0x54;
const $U = 0x55;
const $V = 0x56;
const $W = 0x57;
const $X = 0x58;
const $Y = 0x59;
const $Z = 0x5a;

/// Checks if the code unit is a whitespace character (HTAB or SPACE).
bool isWhitespace(int codeUnit) {
  return codeUnit == $htab || codeUnit == $space;
}

/// Printable ASCII characters range from 0x21 to 0x7e
bool isPrintableAscii(int codeUnit) {
  return codeUnit >= 0x21 && codeUnit <= 0x7e;
}

/// All the controls except HTAB
bool isControl(int codeUnit) {
  return (codeUnit >= 0x00 && codeUnit <= 0x08) ||
      (codeUnit >= 0x0a && codeUnit <= 0x1f) ||
      codeUnit == 0x7f;
}

/// Checks if the code unit is a digit (0-9).
bool isDigit(int codeUnit) {
  return codeUnit >= $0 && codeUnit <= $9;
}

// A-Z, a-z, digits and hyphen (-)
bool isNameChar(int codeUnit) {
  return (codeUnit >= $a && codeUnit <= $z) ||
      (codeUnit >= $A && codeUnit <= $Z) ||
      (codeUnit >= $0 && codeUnit <= $9) ||
      codeUnit == $hyphen;
}

/// Any character except CONTROL, DQUOTE, ";", ":", ","
bool isSafeChar(int codeUnit) {
  return !isControl(codeUnit) &&
      codeUnit != $dquote &&
      codeUnit != $semicolon &&
      codeUnit != $colon &&
      codeUnit != $comma;
}

/// Any character except CONTROL and DQUOTE
bool isQsafeChar(int codeUnit) {
  return !isControl(codeUnit) && codeUnit != $dquote;
}

/// Any textual character
bool isValueChar(int codeUnit) {
  return codeUnit == $space ||
      codeUnit == $htab ||
      isPrintableAscii(codeUnit) ||
      isNonUsAscii(codeUnit);
}

/// Returns true for any code unit outside the US-ASCII range (0x00–0x7F)
bool isNonUsAscii(int codeUnit) {
  return codeUnit > 0x7F;
}

/// A base class for parsing strings in a structured way.
abstract class Parser {
  /// A constant representing the end of a line.
  static const endOfLine = -1;

  /// The source string to be parsed.
  final String source;

  /// The current line number in the source string.
  final int lineNumber;
  int _column = 0;

  /// Creates a new [Parser] with the given [source] string and optional [lineNumber].
  Parser(this.source, {this.lineNumber = 0});

  /// Gets the current column position.
  int get column => _column;

  /// Resets the parser's column position to the start.
  void reset() {
    _column = 0;
  }

  /// Matches a sequence of characters that satisfy the given predicate, and advances the column position.
  /// If [minOccurs] is provided, it enforces a minimum number of characters to match.
  /// If [maxOccurs] is provided, it limits the maximum number of characters to match.
  String match(
    bool Function(int) predicate, {
    int minOccurs = 0,
    int maxOccurs = -1,
  }) {
    assert(minOccurs >= 0, 'minOccurs must be >= 0');
    assert(
      maxOccurs == -1 || maxOccurs >= minOccurs,
      'maxOccurs must be -1 or >= minOccurs',
    );
    int i;
    for (
      i = _column;
      i < source.length &&
          (maxOccurs == -1 || i - _column < maxOccurs) &&
          predicate(source.codeUnitAt(i));
      i++
    ) {}

    if (i - _column < minOccurs) {
      final expectedCount = minOccurs == 1
          ? 'a character'
          : '$minOccurs characters';
      final actualCount = i - _column;
      throw ParseException(
        'Expected $expectedCount, found $actualCount',
        lineNumber: lineNumber,
        column: _column,
      );
    }

    final result = source.substring(_column, i);
    _column = i;
    return result;
  }

  /// Matches a specific character and advances the column position.
  int matchOne(int expected) {
    final actual = lookahead();

    if (actual != expected) {
      throw ParseException(
        'Expected "${fromCodeUnit(expected)}", found "${fromCodeUnit(actual)}"',
        lineNumber: lineNumber,
        column: _column,
      );
    }
    _column++;

    return actual;
  }

  /// Matches one of the expected characters and advances the column position.
  int matchOneOf(List<int> expected) {
    final actual = lookahead();

    if (!expected.contains(actual)) {
      final expectedChars = expected
          .map((e) => '"${fromCodeUnit(e)}"')
          .join(', ');
      throw ParseException(
        'Expected one of [$expectedChars], found "${fromCodeUnit(actual)}"',
        lineNumber: lineNumber,
        column: _column,
      );
    }
    _column++;

    return actual;
  }

  /// Determines if the current position is at the end of the string.
  bool isEndOfLine() => _column >= source.length;

  /// Looks ahead to the next character without consuming it.
  /// If the end of the string is reached, it returns [endOfLine].
  int lookahead() => isEndOfLine() ? endOfLine : source.codeUnitAt(_column);

  /// Consumes the next character and returns it.
  /// This method also advances the column position if the character is not an end-of-line character.
  /// If the end of the string is reached, it returns [endOfLine].
  int consume() {
    // do not advance column if we are at the end of the line
    if (isEndOfLine()) return endOfLine;

    final char = lookahead();

    _column++;

    return char;
  }

  /// Converts a code unit to its string representation.
  /// If the code unit is [endOfLine], it returns the string '&lt;endOfLine&gt;'.
  static String fromCodeUnit(int codeUnit) {
    if (codeUnit == endOfLine) {
      return '<endOfLine>';
    }
    return String.fromCharCode(codeUnit);
  }
}

/// Exception thrown when parsing fails.
class ParseException implements Exception {
  /// The error message describing the parse failure.
  final String message;

  /// The line number where the error occurred.
  final int lineNumber;

  /// The column number where the error occurred, if available.
  final int? column;

  /// Creates a new [ParseException] with the given [message], [lineNumber], and optional [column].
  ParseException(this.message, {required this.lineNumber, this.column});

  @override
  String toString() {
    final location = column != null ? ', Col $column' : '';
    return 'ParseException: $message [Ln $lineNumber$location]';
  }
}

/// A tuple representing a line of text along with its line number.
typedef Line = (String line, int lineNumber);

extension ParserExtensions on Parser {
  /// Matches a sequence of digits and returns it as an integer.
  /// If [minOccurs] is provided, it enforces a minimum number of digits to match.
  /// If [maxOccurs] is provided, it limits the maximum number of digits to match.
  /// -1 for maxOccurs means no limit.
  /// If [minValue] is provided, it enforces a minimum value for the parsed integer.
  /// If [maxValue] is provided, it enforces a maximum value for the parsed integer.
  /// -1 for maxValue means no limit.
  int matchInteger({
    int minOccurs = 1,
    int maxOccurs = -1,
    int minValue = 0,
    int maxValue = -1,
  }) {
    // match optional sign
    int sign = $plus;
    if (lookahead() == $plus || lookahead() == $minus) {
      sign = consume();
    }

    final value = match(isDigit, minOccurs: minOccurs, maxOccurs: maxOccurs);
    final intValue = (sign == $minus ? -1 : 1) * int.parse(value);
    if (intValue < minValue || (maxValue != -1 && intValue > maxValue)) {
      throw ParseException(
        'Integer value $intValue is out of bounds [$minValue, $maxValue]',
        lineNumber: lineNumber,
        column: _column,
      );
    }
    return intValue;
  }
}
