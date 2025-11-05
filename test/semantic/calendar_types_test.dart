import 'dart:typed_data';
import 'package:firstfloor_calendar/firstfloor_calendar.dart';
import 'package:test/test.dart';

void main() {
  group('AttachmentBinary', () {
    test('equality works correctly', () {
      final att1 = AttachmentBinary(
        fmtType: 'image/png',
        encoding: 'BASE64',
        value: 'aGVsbG8=',
      );
      final att2 = AttachmentBinary(
        fmtType: 'image/png',
        encoding: 'BASE64',
        value: 'aGVsbG8=',
      );
      final att3 = AttachmentBinary(
        fmtType: 'image/jpeg',
        encoding: 'BASE64',
        value: 'aGVsbG8=',
      );

      expect(att1, equals(att2));
      expect(att1, isNot(equals(att3)));
      expect(att1.hashCode, equals(att2.hashCode));
    });

    test('bytes decodes BASE64 correctly', () {
      final att = AttachmentBinary(
        encoding: 'BASE64',
        value: 'aGVsbG8=', // "hello" in base64
      );

      final bytes = att.bytes;
      expect(bytes, isA<Uint8List>());
      expect(String.fromCharCodes(bytes), 'hello');
    });

    test('bytes caches decoded value', () {
      final att = AttachmentBinary(encoding: 'BASE64', value: 'aGVsbG8=');

      final bytes1 = att.bytes;
      final bytes2 = att.bytes;
      expect(identical(bytes1, bytes2), isTrue);
    });

    test('bytes throws for unsupported encoding', () {
      final att = AttachmentBinary(encoding: 'UNKNOWN', value: 'data');

      expect(() => att.bytes, throwsUnsupportedError);
    });
  });

  group('AttachmentUri', () {
    test('equality works correctly', () {
      final att1 = AttachmentUri(
        fmtType: 'image/png',
        uri: Uri.parse('https://example.com/image.png'),
      );
      final att2 = AttachmentUri(
        fmtType: 'image/png',
        uri: Uri.parse('https://example.com/image.png'),
      );
      final att3 = AttachmentUri(
        fmtType: 'image/png',
        uri: Uri.parse('https://example.com/other.png'),
      );

      expect(att1, equals(att2));
      expect(att1, isNot(equals(att3)));
      expect(att1.hashCode, equals(att2.hashCode));
    });

    test('toString returns URI string', () {
      final att = AttachmentUri(uri: Uri.parse('https://example.com/file.pdf'));

      expect(att.toString(), 'https://example.com/file.pdf');
    });
  });

  group('ByDay', () {
    test('equality works correctly', () {
      final bd1 = ByDay(Weekday.mo, ordinal: 1);
      final bd2 = ByDay(Weekday.mo, ordinal: 1);
      final bd3 = ByDay(Weekday.mo, ordinal: 2);
      final bd4 = ByDay(Weekday.mo);

      expect(bd1, equals(bd2));
      expect(bd1, isNot(equals(bd3)));
      expect(bd1, isNot(equals(bd4)));
      expect(bd1.hashCode, equals(bd2.hashCode));
    });

    test('toString with ordinal', () {
      final bd = ByDay(Weekday.su, ordinal: -1);
      expect(bd.toString(), '-1SU');
    });

    test('toString without ordinal', () {
      final bd = ByDay(Weekday.fr);
      expect(bd.toString(), 'FR');
    });
  });

  group('CalDuration', () {
    test('equality works correctly', () {
      final dur1 = CalDuration(days: 1, hours: 2, minutes: 30);
      final dur2 = CalDuration(days: 1, hours: 2, minutes: 30);
      final dur3 = CalDuration(days: 1, hours: 3, minutes: 30);

      expect(dur1, equals(dur2));
      expect(dur1, isNot(equals(dur3)));
      expect(dur1.hashCode, equals(dur2.hashCode));
    });

    test('toString formats duration correctly', () {
      final dur1 = CalDuration(days: 1, hours: 2, minutes: 30, seconds: 45);
      expect(dur1.toString(), contains('P'));
      expect(dur1.toString(), contains('1D'));
      expect(dur1.toString(), contains('T'));
      expect(dur1.toString(), contains('2H'));
      expect(dur1.toString(), contains('30M'));
      expect(dur1.toString(), contains('45S'));
    });

    test('toString with weeks only', () {
      final dur = CalDuration(weeks: 2);
      expect(dur.toString(), 'P2W');
    });
  });

  group('CalTime', () {
    test('equality works correctly', () {
      final t1 = CalTime.local(10, 30, 45);
      final t2 = CalTime.local(10, 30, 45);
      final t3 = CalTime.local(10, 30, 0);

      expect(t1, equals(t2));
      expect(t1, isNot(equals(t3)));
      expect(t1.hashCode, equals(t2.hashCode));
    });

    test('toString formats time correctly', () {
      final t = CalTime.local(9, 5, 3);
      expect(t.toString(), '090503');
    });

    test('toString with UTC', () {
      final t = CalTime.utc(14, 30, 0);
      expect(t.toString(), '143000Z');
    });
  });

  group('CalendarUserAddress', () {
    test('equality works correctly', () {
      final addr1 = CalendarUserAddress(
        address: 'mailto:user@example.com',
        cn: 'John Doe',
      );
      final addr2 = CalendarUserAddress(
        address: 'mailto:user@example.com',
        cn: 'John Doe',
      );
      final addr3 = CalendarUserAddress(
        address: 'mailto:other@example.com',
        cn: 'John Doe',
      );

      expect(addr1, equals(addr2));
      expect(addr1, isNot(equals(addr3)));
      expect(addr1.hashCode, equals(addr2.hashCode));
    });
  });

  group('GeoCoordinate', () {
    test('equality works correctly', () {
      final geo1 = GeoCoordinate(latitude: 51.5074, longitude: -0.1278);
      final geo2 = GeoCoordinate(latitude: 51.5074, longitude: -0.1278);
      final geo3 = GeoCoordinate(latitude: 40.7128, longitude: -74.0060);

      expect(geo1, equals(geo2));
      expect(geo1, isNot(equals(geo3)));
      expect(geo1.hashCode, equals(geo2.hashCode));
    });

    test('toString formats coordinates', () {
      final geo = GeoCoordinate(latitude: 51.5074, longitude: -0.1278);
      expect(geo.toString(), contains('51.5074'));
      expect(geo.toString(), contains('-0.1278'));
    });
  });

  group('Period', () {
    test('equality works correctly', () {
      final start = CalDateTime.local(2025, 1, 1, 10, 0, 0);
      final end = CalDateTime.local(2025, 1, 1, 11, 0, 0);
      final duration = CalDuration(hours: 1);

      final p1 = Period.explicit(start: start, end: end);
      final p2 = Period.explicit(start: start, end: end);
      final p3 = Period.start(start: start, duration: duration);

      expect(p1, equals(p2));
      expect(p1, isNot(equals(p3)));
      expect(p1.hashCode, equals(p2.hashCode));
    });

    test('toString with end time', () {
      final start = CalDateTime.local(2025, 1, 1, 10, 0, 0);
      final end = CalDateTime.local(2025, 1, 1, 11, 0, 0);
      final period = Period.explicit(start: start, end: end);

      final str = period.toString();
      expect(str, contains('20250101T100000'));
      expect(str, contains('/'));
      expect(str, contains('20250101T110000'));
    });

    test('toString with duration', () {
      final start = CalDateTime.local(2025, 1, 1, 10, 0, 0);
      final duration = CalDuration(hours: 2);
      final period = Period.start(start: start, duration: duration);

      final str = period.toString();
      expect(str, contains('20250101T100000'));
      expect(str, contains('/'));
      expect(str, contains('PT2H'));
    });
  });

  group('RecurrenceDateTime', () {
    test('equality works correctly', () {
      final dt1 = CalDateTime.local(2025, 1, 1, 10, 0, 0);
      final dt2 = CalDateTime.local(2025, 1, 2, 10, 0, 0);

      final rd1 = RecurrenceDateTime.dateTime(dt1);
      final rd2 = RecurrenceDateTime.dateTime(dt1);
      final rd3 = RecurrenceDateTime.dateTime(dt2);

      expect(rd1, equals(rd2));
      expect(rd1, isNot(equals(rd3)));
      expect(rd1.hashCode, equals(rd2.hashCode));
    });

    test('toString returns datetime string', () {
      final dt = CalDateTime.local(2025, 1, 15, 14, 30, 0);
      final rd = RecurrenceDateTime.dateTime(dt);

      expect(rd.toString(), contains('20250115T143000'));
    });
  });

  group('Trigger', () {
    test('toString with duration', () {
      final dur = CalDuration(hours: 1, minutes: 30);
      final trigger = Trigger.duration(dur);

      expect(trigger.toString(), contains('PT1H30M'));
    });

    test('toString with UTC dateTime', () {
      final dt = CalDateTime.utc(2025, 1, 1, 10, 0, 0);
      final trigger = Trigger.dateTime(dt);

      expect(trigger.toString(), contains('20250101T100000Z'));
    });
  });

  group('UtcOffset', () {
    test('equality works correctly', () {
      final off1 = UtcOffset(sign: Sign.positive, hours: 5, minutes: 30);
      final off2 = UtcOffset(sign: Sign.positive, hours: 5, minutes: 30);
      final off3 = UtcOffset(sign: Sign.negative, hours: 8, minutes: 0);

      expect(off1, equals(off2));
      expect(off1, isNot(equals(off3)));
      expect(off1.hashCode, equals(off2.hashCode));
    });

    test('toString formats positive offset', () {
      final off = UtcOffset(sign: Sign.positive, hours: 5, minutes: 30);
      expect(off.toString(), '+0530');
    });

    test('toString formats negative offset', () {
      final off = UtcOffset(sign: Sign.negative, hours: 8, minutes: 0);
      expect(off.toString(), '-0800');
    });

    test('toString with seconds', () {
      final off = UtcOffset(
        sign: Sign.positive,
        hours: 1,
        minutes: 0,
        seconds: 30,
      );
      expect(off.toString(), '+010030');
    });
  });
}
