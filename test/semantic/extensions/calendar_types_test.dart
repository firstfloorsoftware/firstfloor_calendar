import 'package:firstfloor_calendar/firstfloor_calendar.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });

  group('CalDateTimeExtensions', () {
    test('isAfter returns true when date is after other', () {
      final date1 = CalDateTime.local(2025, 1, 1, 10, 0, 0);
      final date2 = CalDateTime.local(2025, 1, 2, 10, 0, 0);

      expect(date2.isAfter(date1), isTrue);
      expect(date1.isAfter(date2), isFalse);
      expect(date1.isAfter(date1), isFalse);
    });

    test('isBefore returns true when date is before other', () {
      final date1 = CalDateTime.local(2025, 1, 1, 10, 0, 0);
      final date2 = CalDateTime.local(2025, 1, 2, 10, 0, 0);

      expect(date1.isBefore(date2), isTrue);
      expect(date2.isBefore(date1), isFalse);
      expect(date1.isBefore(date1), isFalse);
    });

    test('dayOfYear returns correct day number in regular year', () {
      expect(CalDateTime.date(2025, 1, 1).dayOfYear, 1);
      expect(CalDateTime.local(2025, 1, 31).dayOfYear, 31);
      expect(CalDateTime.local(2025, 2, 1).dayOfYear, 32);
      expect(CalDateTime.local(2025, 3, 1).dayOfYear, 60);
      expect(CalDateTime.local(2025, 12, 31).dayOfYear, 365);
    });

    test('dayOfYear returns correct day number in leap year', () {
      expect(CalDateTime.local(2024, 1, 1).dayOfYear, 1);
      expect(CalDateTime.local(2024, 2, 29).dayOfYear, 60);
      expect(CalDateTime.local(2024, 3, 1).dayOfYear, 61);
      expect(CalDateTime.local(2024, 12, 31).dayOfYear, 366);
    });

    test('weekday returns correct weekday', () {
      expect(CalDateTime.date(2025, 1, 1).weekday, Weekday.we);
      expect(CalDateTime.local(2025, 1, 6).weekday, Weekday.mo);
      expect(CalDateTime.local(2025, 1, 5).weekday, Weekday.su);
    });

    group('addDuration', () {
      test('Adds positive duration with days', () {
        final date = CalDateTime.local(2025, 1, 1, 10, 0, 0);
        final duration = CalDuration(days: 5);
        final result = date.addDuration(duration);

        expect(result, CalDateTime.local(2025, 1, 6, 10, 0, 0));
      });

      test('adds positive duration with weeks', () {
        final date = CalDateTime.local(2025, 1, 1, 10, 0, 0);
        final duration = CalDuration(weeks: 2);
        final result = date.addDuration(duration);

        expect(result, CalDateTime.local(2025, 1, 15, 10, 0, 0));
      });

      test('adds positive duration with hours', () {
        final date = CalDateTime.local(2025, 1, 1, 10, 0, 0);
        final duration = CalDuration(hours: 5);
        final result = date.addDuration(duration);

        expect(result, CalDateTime.local(2025, 1, 1, 15, 0, 0));
      });

      test('adds positive duration with minutes', () {
        final date = CalDateTime.local(2025, 1, 1, 10, 0, 0);
        final duration = CalDuration(minutes: 90);
        final result = date.addDuration(duration);

        expect(result, CalDateTime.local(2025, 1, 1, 11, 30, 0));
      });

      test('adds positive duration with seconds', () {
        final date = CalDateTime.local(2025, 1, 1, 10, 0, 0);
        final duration = CalDuration(seconds: 3665);
        final result = date.addDuration(duration);

        expect(result, CalDateTime.local(2025, 1, 1, 11, 1, 5));
      });

      test('adds negative duration with days', () {
        final date = CalDateTime.local(2025, 1, 10, 10, 0, 0);
        final duration = CalDuration(sign: Sign.negative, days: 5);
        final result = date.addDuration(duration);

        expect(result, CalDateTime.local(2025, 1, 5, 10, 0, 0));
      });

      test('adds negative duration with weeks', () {
        final date = CalDateTime.local(2025, 1, 20, 10, 0, 0);
        final duration = CalDuration(sign: Sign.negative, weeks: 2);
        final result = date.addDuration(duration);

        expect(result, CalDateTime.local(2025, 1, 6, 10, 0, 0));
      });

      test('adds negative duration with hours', () {
        final date = CalDateTime.local(2025, 1, 1, 15, 0, 0);
        final duration = CalDuration(sign: Sign.negative, hours: 5);
        final result = date.addDuration(duration);

        expect(result, CalDateTime.local(2025, 1, 1, 10, 0, 0));
      });

      test('adds complex positive duration with multiple components', () {
        final date = CalDateTime.local(2025, 1, 1, 10, 0, 0);
        final duration = CalDuration(
          weeks: 1,
          days: 2,
          hours: 3,
          minutes: 30,
          seconds: 45,
        );
        final result = date.addDuration(duration);

        // 1 week (7 days) + 2 days + 3 hours + 30 minutes + 45 seconds
        expect(result, CalDateTime.local(2025, 1, 10, 13, 30, 45));
      });

      test('adds complex negative duration with multiple components', () {
        final date = CalDateTime.local(2025, 1, 20, 15, 30, 45);
        final duration = CalDuration(
          sign: Sign.negative,
          weeks: 1,
          days: 2,
          hours: 3,
          minutes: 30,
          seconds: 45,
        );
        final result = date.addDuration(duration);

        // -1 week (7 days) - 2 days - 3 hours - 30 minutes - 45 seconds
        expect(result, CalDateTime.local(2025, 1, 11, 12, 0, 0));
      });

      test('adds duration crossing month boundary', () {
        final date = CalDateTime.local(2025, 1, 28, 10, 0, 0);
        final duration = CalDuration(days: 5);
        final result = date.addDuration(duration);

        expect(result, CalDateTime.local(2025, 2, 2, 10, 0, 0));
      });

      test('adds duration crossing year boundary', () {
        final date = CalDateTime.local(2024, 12, 30, 10, 0, 0);
        final duration = CalDuration(days: 5);
        final result = date.addDuration(duration);

        expect(result, CalDateTime.local(2025, 1, 4, 10, 0, 0));
      });

      test('adds duration with overflow (hours to days)', () {
        final date = CalDateTime.local(2025, 1, 1, 22, 0, 0);
        final duration = CalDuration(hours: 5);
        final result = date.addDuration(duration);

        expect(result, CalDateTime.local(2025, 1, 2, 3, 0, 0));
      });

      test('adds duration with overflow (minutes to hours)', () {
        final date = CalDateTime.local(2025, 1, 1, 10, 50, 0);
        final duration = CalDuration(minutes: 30);
        final result = date.addDuration(duration);

        expect(result, CalDateTime.local(2025, 1, 1, 11, 20, 0));
      });

      test('adds duration with overflow (seconds to minutes)', () {
        final date = CalDateTime.local(2025, 1, 1, 10, 0, 50);
        final duration = CalDuration(seconds: 30);
        final result = date.addDuration(duration);

        expect(result, CalDateTime.local(2025, 1, 1, 10, 1, 20));
      });

      test('adds zero duration returns same date', () {
        final date = CalDateTime.local(2025, 1, 1, 10, 0, 0);
        final duration = CalDuration();
        final result = date.addDuration(duration);

        expect(result, date);
      });

      test('works with date-only CalDateTime', () {
        final date = CalDateTime.date(2025, 1, 1);
        final duration = CalDuration(days: 10);
        final result = date.addDuration(duration);

        expect(result, CalDateTime.date(2025, 1, 11));
      });

      test('preserves timezone information', () {
        final date = CalDateTime.local(
          2025,
          1,
          1,
          10,
          0,
          0,
          'America/New_York',
        );
        final duration = CalDuration(days: 1, hours: 2);
        final result = date.addDuration(duration);

        expect(result.time?.tzid, 'America/New_York');
        expect(
          result,
          CalDateTime.local(2025, 1, 2, 12, 0, 0, 'America/New_York'),
        );
      });

      test('handles leap year February correctly', () {
        final date = CalDateTime.local(2024, 2, 28, 10, 0, 0);
        final duration = CalDuration(days: 2);
        final result = date.addDuration(duration);

        // 2024 is a leap year, so Feb 29 exists
        expect(result, CalDateTime.local(2024, 3, 1, 10, 0, 0));
      });

      test('handles non-leap year February correctly', () {
        final date = CalDateTime.local(2025, 2, 28, 10, 0, 0);
        final duration = CalDuration(days: 2);
        final result = date.addDuration(duration);

        // 2025 is not a leap year
        expect(result, CalDateTime.local(2025, 3, 2, 10, 0, 0));
      });
    });
  });

  group('RecurrenceRuleExtensions', () {
    test('isInfinite returns true when no count or until', () {
      final rrule = RecurrenceRule(freq: RecurrenceFrequency.daily);
      expect(rrule.isInfinite, isTrue);
      expect(rrule.isFinite, isFalse);
    });

    test('isFinite returns true when count is set', () {
      final rrule = RecurrenceRule(freq: RecurrenceFrequency.daily, count: 10);
      expect(rrule.isFinite, isTrue);
      expect(rrule.isInfinite, isFalse);
      expect(rrule.hasCount, isTrue);
      expect(rrule.hasUntil, isFalse);
    });

    test('isFinite returns true when until is set', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.daily,
        until: CalDateTime.local(2025, 12, 31),
      );
      expect(rrule.isFinite, isTrue);
      expect(rrule.isInfinite, isFalse);
      expect(rrule.hasUntil, isTrue);
      expect(rrule.hasCount, isFalse);
    });
  });
}
