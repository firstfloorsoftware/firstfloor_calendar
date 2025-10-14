import 'package:firstfloor_calendar/firstfloor_calendar.dart';
import 'package:test/test.dart';

void main() {
  group('Parse properties', () {
    test('Parse document properties', () {
      final parser = DocumentParser();
      final properties = parser
          .parseProperties(
            'BEGIN:VCALENDAR\r\n'
            'VERSION:2.0\r\n'
            'PRODID:-//hacksw/handcal//NONSGML v1.0//EN\r\n'
            'END:VCALENDAR',
          )
          .toList();

      expect(properties.length, 4);
      expect(properties[0].name, 'BEGIN');
      expect(properties[0].value, 'VCALENDAR');
      expect(properties[1].name, 'VERSION');
      expect(properties[1].value, '2.0');
      expect(properties[2].name, 'PRODID');
      expect(properties[2].value, '-//hacksw/handcal//NONSGML v1.0//EN');
      expect(properties[3].name, 'END');
      expect(properties[3].value, 'VCALENDAR');
    });

    test('Parse properties with lowercase names', () {
      final parser = DocumentParser();
      final properties = parser
          .parseProperties(
            'begin:VCALENDAR\r\n'
            'version:2.0\r\n'
            'prodid:-//hacksw/handcal//NONSGML v1.0//EN\r\n'
            'end:VCALENDAR',
          )
          .toList();

      expect(properties.length, 4);
      expect(properties[0].name, 'BEGIN');
      expect(properties[0].value, 'VCALENDAR');
      expect(properties[1].name, 'VERSION');
      expect(properties[1].value, '2.0');
      expect(properties[2].name, 'PRODID');
      expect(properties[2].value, '-//hacksw/handcal//NONSGML v1.0//EN');
      expect(properties[3].name, 'END');
      expect(properties[3].value, 'VCALENDAR');
    });
  });
}
