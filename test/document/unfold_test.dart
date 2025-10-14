import 'dart:convert';

import 'package:firstfloor_calendar/firstfloor_calendar.dart';
import 'package:test/test.dart';

void main() {
  group('Line unfolding', () {
    group('Basic unfolding', () {
      test('Should unfold lines when content spans multiple lines', () {
        final lines = DocumentParser.unfold(
          'This is a lo\r\n'
          ' ng description\r\n'
          '  that exists on a long line.',
        );

        expect(lines, [
          ('This is a long description that exists on a long line.', 1),
        ]);
      });

      test('Should handle multiple properties when unfolding complex content', () {
        final lines = DocumentParser.unfold(
          'DESCRIPTION:Lorem ipsum dolor sit amet, consectetur adipiscing elit.\r\n'
          '  Sed suscipit malesuada sodales. Ut\r\n'
          '  viverra metus neque, ut ullamcorper felis fermentum vel. \r\n'
          ' Sed sodales mauris nec.\r\n'
          'A:B',
        );

        expect(lines, [
          (
            'DESCRIPTION:Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed suscipit malesuada sodales. Ut viverra metus neque, ut ullamcorper felis fermentum vel. Sed sodales mauris nec.',
            1,
          ),
          ('A:B', 5),
        ]);
      });

      test('Should unfold single line when no folding exists', () {
        final lines = DocumentParser.unfold('SUMMARY:Simple event title');

        expect(lines, [('SUMMARY:Simple event title', 1)]);
      });

      test('Should unfold property when continuation uses single space', () {
        final lines = DocumentParser.unfold(
          'LOCATION:Conference Room A,\r\n'
          ' Building B, Floor 3',
        );

        expect(lines, [('LOCATION:Conference Room A,Building B, Floor 3', 1)]);
      });
    });

    group('Edge cases', () {
      test(
        'Should preserve line numbers when unfolding content with empty lines',
        () {
          final lines = DocumentParser.unfold(
            'A\r\n'
            '\r\n'
            'B\r\n'
            ' 1\r\n'
            ' 2\r\n'
            '\r\n'
            'C\r\n',
          );

          expect(lines, [('A', 1), ('B12', 3), ('C', 7)]);
        },
      );

      test('Should handle empty input when no content provided', () {
        final lines = DocumentParser.unfold('');

        expect(lines, []);
      });

      test(
        'Should unfold property when multiple tabs are used for continuation',
        () {
          final lines = DocumentParser.unfold(
            'ATTENDEE:mailto:john@example.com\r\n'
            '\t\tCN=John Doe',
          );

          expect(lines, [('ATTENDEE:mailto:john@example.com\tCN=John Doe', 1)]);
        },
      );
    });
  });

  group('Line stream unfolding', () {
    test('Should unfold lines from a byte stream', () async {
      final bytes = Stream.fromIterable([
        utf8.encode('This is a lo\r\n'),
        utf8.encode(' ng description\r\n'),
        utf8.encode('  that exists on a long line.'),
      ]);

      final lines = DocumentStreamParser.unfoldStream(bytes);

      await expectLater(
        lines,
        emitsInOrder([
          ('This is a long description that exists on a long line.', 1),
        ]),
      );
    });
  });
}
