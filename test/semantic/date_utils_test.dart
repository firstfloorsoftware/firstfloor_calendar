import 'package:firstfloor_calendar/firstfloor_calendar.dart';
import 'package:test/test.dart';

void main() {
  group('DateUtils - isLeapYear', () {
    test('Common leap years divisible by 4', () {
      expect(DateUtils.isLeapYear(2024), true);
      expect(DateUtils.isLeapYear(2020), true);
      expect(DateUtils.isLeapYear(2016), true);
      expect(DateUtils.isLeapYear(2012), true);
      expect(DateUtils.isLeapYear(2008), true);
      expect(DateUtils.isLeapYear(2004), true);
      expect(DateUtils.isLeapYear(2000), true);
    });

    test('Common non-leap years not divisible by 4', () {
      expect(DateUtils.isLeapYear(2023), false);
      expect(DateUtils.isLeapYear(2022), false);
      expect(DateUtils.isLeapYear(2021), false);
      expect(DateUtils.isLeapYear(2019), false);
      expect(DateUtils.isLeapYear(2018), false);
      expect(DateUtils.isLeapYear(2017), false);
      expect(DateUtils.isLeapYear(2015), false);
    });

    test('Century years not divisible by 400 are not leap years', () {
      expect(DateUtils.isLeapYear(1900), false);
      expect(DateUtils.isLeapYear(1800), false);
      expect(DateUtils.isLeapYear(1700), false);
      expect(DateUtils.isLeapYear(2100), false);
      expect(DateUtils.isLeapYear(2200), false);
      expect(DateUtils.isLeapYear(2300), false);
    });

    test('Century years divisible by 400 are leap years', () {
      expect(DateUtils.isLeapYear(2000), true);
      expect(DateUtils.isLeapYear(1600), true);
      expect(DateUtils.isLeapYear(2400), true);
    });

    test('Edge case years', () {
      expect(DateUtils.isLeapYear(1), false);
      expect(DateUtils.isLeapYear(4), true);
      expect(DateUtils.isLeapYear(100), false);
      expect(DateUtils.isLeapYear(400), true);
    });
  });

  group('DateUtils - totalDaysInYear', () {
    test('Leap years have 366 days', () {
      expect(DateUtils.totalDaysInYear(2024), 366);
      expect(DateUtils.totalDaysInYear(2020), 366);
      expect(DateUtils.totalDaysInYear(2000), 366);
      expect(DateUtils.totalDaysInYear(1600), 366);
    });

    test('Non-leap years have 365 days', () {
      expect(DateUtils.totalDaysInYear(2023), 365);
      expect(DateUtils.totalDaysInYear(2022), 365);
      expect(DateUtils.totalDaysInYear(2021), 365);
      expect(DateUtils.totalDaysInYear(1900), 365);
      expect(DateUtils.totalDaysInYear(2100), 365);
    });
  });

  group('DateUtils - totalDaysInMonth', () {
    test('January has 31 days', () {
      expect(DateUtils.totalDaysInMonth(2024, 1), 31);
      expect(DateUtils.totalDaysInMonth(2023, 1), 31);
    });

    test('February has 28 days in non-leap years', () {
      expect(DateUtils.totalDaysInMonth(2023, 2), 28);
      expect(DateUtils.totalDaysInMonth(2022, 2), 28);
      expect(DateUtils.totalDaysInMonth(2021, 2), 28);
      expect(DateUtils.totalDaysInMonth(1900, 2), 28);
      expect(DateUtils.totalDaysInMonth(2100, 2), 28);
    });

    test('February has 29 days in leap years', () {
      expect(DateUtils.totalDaysInMonth(2024, 2), 29);
      expect(DateUtils.totalDaysInMonth(2020, 2), 29);
      expect(DateUtils.totalDaysInMonth(2000, 2), 29);
      expect(DateUtils.totalDaysInMonth(1600, 2), 29);
    });

    test('March has 31 days', () {
      expect(DateUtils.totalDaysInMonth(2024, 3), 31);
      expect(DateUtils.totalDaysInMonth(2023, 3), 31);
    });

    test('April has 30 days', () {
      expect(DateUtils.totalDaysInMonth(2024, 4), 30);
      expect(DateUtils.totalDaysInMonth(2023, 4), 30);
    });

    test('May has 31 days', () {
      expect(DateUtils.totalDaysInMonth(2024, 5), 31);
      expect(DateUtils.totalDaysInMonth(2023, 5), 31);
    });

    test('June has 30 days', () {
      expect(DateUtils.totalDaysInMonth(2024, 6), 30);
      expect(DateUtils.totalDaysInMonth(2023, 6), 30);
    });

    test('July has 31 days', () {
      expect(DateUtils.totalDaysInMonth(2024, 7), 31);
      expect(DateUtils.totalDaysInMonth(2023, 7), 31);
    });

    test('August has 31 days', () {
      expect(DateUtils.totalDaysInMonth(2024, 8), 31);
      expect(DateUtils.totalDaysInMonth(2023, 8), 31);
    });

    test('September has 30 days', () {
      expect(DateUtils.totalDaysInMonth(2024, 9), 30);
      expect(DateUtils.totalDaysInMonth(2023, 9), 30);
    });

    test('October has 31 days', () {
      expect(DateUtils.totalDaysInMonth(2024, 10), 31);
      expect(DateUtils.totalDaysInMonth(2023, 10), 31);
    });

    test('November has 30 days', () {
      expect(DateUtils.totalDaysInMonth(2024, 11), 30);
      expect(DateUtils.totalDaysInMonth(2023, 11), 30);
    });

    test('December has 31 days', () {
      expect(DateUtils.totalDaysInMonth(2024, 12), 31);
      expect(DateUtils.totalDaysInMonth(2023, 12), 31);
    });
  });

  group('DateUtils - startOfWeek', () {
    test('Date already on week start returns same date', () {
      // Jan 6, 2025 is a Monday
      final monday = CalDateTime.date(2025, 1, 6);
      final result = DateUtils.startOfWeek(monday, Weekday.mo);
      expect(result.toString(), '20250106');
    });

    test('Start of week with Monday as week start', () {
      // Jan 8, 2025 is a Wednesday
      final wednesday = CalDateTime.date(2025, 1, 8);
      final result = DateUtils.startOfWeek(wednesday, Weekday.mo);
      // Should return Monday, Jan 6, 2025
      expect(result.toString(), '20250106');
    });

    test('Start of week with Sunday as week start', () {
      // Jan 8, 2025 is a Wednesday
      final wednesday = CalDateTime.date(2025, 1, 8);
      final result = DateUtils.startOfWeek(wednesday, Weekday.su);
      // Should return Sunday, Jan 5, 2025
      expect(result.toString(), '20250105');
    });

    test('Start of week with Tuesday as week start', () {
      // Jan 10, 2025 is a Friday
      final friday = CalDateTime.date(2025, 1, 10);
      final result = DateUtils.startOfWeek(friday, Weekday.tu);
      // Should return Tuesday, Jan 7, 2025
      expect(result.toString(), '20250107');
    });

    test('Start of week crosses month boundary', () {
      // Feb 2, 2025 is a Sunday (index 0)
      final sunday = CalDateTime.date(2025, 2, 2);
      final result = DateUtils.startOfWeek(sunday, Weekday.mo);
      // Should return Monday, Jan 27, 2025 (previous week)
      expect(result.toString(), '20250127');
    });

    test('Start of week crosses year boundary', () {
      // Jan 2, 2025 is a Thursday
      final thursday = CalDateTime.date(2025, 1, 2);
      final result = DateUtils.startOfWeek(thursday, Weekday.mo);
      // Should return Monday, Dec 30, 2024
      expect(result.toString(), '20241230');
    });

    test('All weekdays as week start', () {
      // Jan 10, 2025 is a Friday (index 5)
      final friday = CalDateTime.date(2025, 1, 10);

      // Should always go backward (or stay) to find start of current week
      expect(
        DateUtils.startOfWeek(friday, Weekday.su).toString(),
        '20250105',
      ); // back 5 days
      expect(
        DateUtils.startOfWeek(friday, Weekday.mo).toString(),
        '20250106',
      ); // back 4 days
      expect(
        DateUtils.startOfWeek(friday, Weekday.tu).toString(),
        '20250107',
      ); // back 3 days
      expect(
        DateUtils.startOfWeek(friday, Weekday.we).toString(),
        '20250108',
      ); // back 2 days
      expect(
        DateUtils.startOfWeek(friday, Weekday.th).toString(),
        '20250109',
      ); // back 1 day
      expect(
        DateUtils.startOfWeek(friday, Weekday.fr).toString(),
        '20250110',
      ); // same day
      expect(
        DateUtils.startOfWeek(friday, Weekday.sa).toString(),
        '20250104',
      ); // back 6 days
    });
  });

  group('DateUtils - numberOfWeekdaysInMonth', () {
    test('January 2025 weekday counts', () {
      // Jan 2025 starts on Wednesday, has 31 days
      expect(DateUtils.numberOfWeekdaysInMonth(2025, 1, Weekday.su), 4);
      expect(DateUtils.numberOfWeekdaysInMonth(2025, 1, Weekday.mo), 4);
      expect(DateUtils.numberOfWeekdaysInMonth(2025, 1, Weekday.tu), 4);
      expect(DateUtils.numberOfWeekdaysInMonth(2025, 1, Weekday.we), 5);
      expect(DateUtils.numberOfWeekdaysInMonth(2025, 1, Weekday.th), 5);
      expect(DateUtils.numberOfWeekdaysInMonth(2025, 1, Weekday.fr), 5);
      expect(DateUtils.numberOfWeekdaysInMonth(2025, 1, Weekday.sa), 4);
    });

    test('February 2025 weekday counts (non-leap year)', () {
      // Feb 2025 starts on Saturday, has 28 days
      expect(DateUtils.numberOfWeekdaysInMonth(2025, 2, Weekday.su), 4);
      expect(DateUtils.numberOfWeekdaysInMonth(2025, 2, Weekday.mo), 4);
      expect(DateUtils.numberOfWeekdaysInMonth(2025, 2, Weekday.tu), 4);
      expect(DateUtils.numberOfWeekdaysInMonth(2025, 2, Weekday.we), 4);
      expect(DateUtils.numberOfWeekdaysInMonth(2025, 2, Weekday.th), 4);
      expect(DateUtils.numberOfWeekdaysInMonth(2025, 2, Weekday.fr), 4);
      expect(DateUtils.numberOfWeekdaysInMonth(2025, 2, Weekday.sa), 4);
    });

    test('February 2024 weekday counts (leap year)', () {
      // Feb 2024 starts on Thursday, has 29 days
      expect(DateUtils.numberOfWeekdaysInMonth(2024, 2, Weekday.su), 4);
      expect(DateUtils.numberOfWeekdaysInMonth(2024, 2, Weekday.mo), 4);
      expect(DateUtils.numberOfWeekdaysInMonth(2024, 2, Weekday.tu), 4);
      expect(DateUtils.numberOfWeekdaysInMonth(2024, 2, Weekday.we), 4);
      expect(DateUtils.numberOfWeekdaysInMonth(2024, 2, Weekday.th), 5);
      expect(DateUtils.numberOfWeekdaysInMonth(2024, 2, Weekday.fr), 4);
      expect(DateUtils.numberOfWeekdaysInMonth(2024, 2, Weekday.sa), 4);
    });

    test('April 2025 weekday counts (30-day month)', () {
      // April 2025 starts on Tuesday, has 30 days
      expect(DateUtils.numberOfWeekdaysInMonth(2025, 4, Weekday.su), 4);
      expect(DateUtils.numberOfWeekdaysInMonth(2025, 4, Weekday.mo), 4);
      expect(DateUtils.numberOfWeekdaysInMonth(2025, 4, Weekday.tu), 5);
      expect(DateUtils.numberOfWeekdaysInMonth(2025, 4, Weekday.we), 5);
      expect(DateUtils.numberOfWeekdaysInMonth(2025, 4, Weekday.th), 4);
      expect(DateUtils.numberOfWeekdaysInMonth(2025, 4, Weekday.fr), 4);
      expect(DateUtils.numberOfWeekdaysInMonth(2025, 4, Weekday.sa), 4);
    });

    test('December 2025 weekday counts (31-day month)', () {
      // December 2025 starts on Monday, has 31 days
      expect(DateUtils.numberOfWeekdaysInMonth(2025, 12, Weekday.su), 4);
      expect(DateUtils.numberOfWeekdaysInMonth(2025, 12, Weekday.mo), 5);
      expect(DateUtils.numberOfWeekdaysInMonth(2025, 12, Weekday.tu), 5);
      expect(DateUtils.numberOfWeekdaysInMonth(2025, 12, Weekday.we), 5);
      expect(DateUtils.numberOfWeekdaysInMonth(2025, 12, Weekday.th), 4);
      expect(DateUtils.numberOfWeekdaysInMonth(2025, 12, Weekday.fr), 4);
      expect(DateUtils.numberOfWeekdaysInMonth(2025, 12, Weekday.sa), 4);
    });

    test('Month starting on Sunday has 5 Sundays', () {
      // June 2025 starts on Sunday, has 30 days
      expect(DateUtils.numberOfWeekdaysInMonth(2025, 6, Weekday.su), 5);
    });

    test('Month starting on Monday has 5 Mondays', () {
      // September 2025 starts on Monday, has 30 days
      expect(DateUtils.numberOfWeekdaysInMonth(2025, 9, Weekday.mo), 5);
    });
  });

  group('DateUtils - numberOfWeekdaysInYear', () {
    test('2024 weekday counts (leap year starting on Monday)', () {
      // 2024 is a leap year (366 days), starts on Monday
      // 366 days = 52 weeks + 2 days, so Monday and Tuesday appear 53 times
      expect(DateUtils.numberOfWeekdaysInYear(2024, Weekday.su), 52);
      expect(DateUtils.numberOfWeekdaysInYear(2024, Weekday.mo), 53);
      expect(DateUtils.numberOfWeekdaysInYear(2024, Weekday.tu), 53);
      expect(DateUtils.numberOfWeekdaysInYear(2024, Weekday.we), 52);
      expect(DateUtils.numberOfWeekdaysInYear(2024, Weekday.th), 52);
      expect(DateUtils.numberOfWeekdaysInYear(2024, Weekday.fr), 52);
      expect(DateUtils.numberOfWeekdaysInYear(2024, Weekday.sa), 52);
    });

    test('2025 weekday counts (non-leap year starting on Wednesday)', () {
      // 2025 is not a leap year (365 days), starts on Wednesday
      expect(DateUtils.numberOfWeekdaysInYear(2025, Weekday.su), 52);
      expect(DateUtils.numberOfWeekdaysInYear(2025, Weekday.mo), 52);
      expect(DateUtils.numberOfWeekdaysInYear(2025, Weekday.tu), 52);
      expect(DateUtils.numberOfWeekdaysInYear(2025, Weekday.we), 53);
      expect(DateUtils.numberOfWeekdaysInYear(2025, Weekday.th), 52);
      expect(DateUtils.numberOfWeekdaysInYear(2025, Weekday.fr), 52);
      expect(DateUtils.numberOfWeekdaysInYear(2025, Weekday.sa), 52);
    });

    test('2020 weekday counts (leap year starting on Wednesday)', () {
      // 2020 is a leap year (366 days), starts on Wednesday
      expect(DateUtils.numberOfWeekdaysInYear(2020, Weekday.su), 52);
      expect(DateUtils.numberOfWeekdaysInYear(2020, Weekday.mo), 52);
      expect(DateUtils.numberOfWeekdaysInYear(2020, Weekday.tu), 52);
      expect(DateUtils.numberOfWeekdaysInYear(2020, Weekday.we), 53);
      expect(DateUtils.numberOfWeekdaysInYear(2020, Weekday.th), 53);
      expect(DateUtils.numberOfWeekdaysInYear(2020, Weekday.fr), 52);
      expect(DateUtils.numberOfWeekdaysInYear(2020, Weekday.sa), 52);
    });

    test('2023 weekday counts (non-leap year starting on Sunday)', () {
      // 2023 is not a leap year (365 days), starts on Sunday
      expect(DateUtils.numberOfWeekdaysInYear(2023, Weekday.su), 53);
      expect(DateUtils.numberOfWeekdaysInYear(2023, Weekday.mo), 52);
      expect(DateUtils.numberOfWeekdaysInYear(2023, Weekday.tu), 52);
      expect(DateUtils.numberOfWeekdaysInYear(2023, Weekday.we), 52);
      expect(DateUtils.numberOfWeekdaysInYear(2023, Weekday.th), 52);
      expect(DateUtils.numberOfWeekdaysInYear(2023, Weekday.fr), 52);
      expect(DateUtils.numberOfWeekdaysInYear(2023, Weekday.sa), 52);
    });

    test('Non-leap year has exactly 365 days worth of weekdays', () {
      final year = 2025;
      final total = Weekday.values
          .map((wd) => DateUtils.numberOfWeekdaysInYear(year, wd))
          .reduce((a, b) => a + b);
      expect(total, 365);
    });

    test('Leap year has exactly 366 days worth of weekdays', () {
      final year = 2024;
      final total = Weekday.values
          .map((wd) => DateUtils.numberOfWeekdaysInYear(year, wd))
          .reduce((a, b) => a + b);
      expect(total, 366);
    });

    test('Century non-leap year (1900)', () {
      // 1900 is not a leap year (365 days), starts on Monday
      expect(DateUtils.numberOfWeekdaysInYear(1900, Weekday.su), 52);
      expect(DateUtils.numberOfWeekdaysInYear(1900, Weekday.mo), 53);
      expect(DateUtils.numberOfWeekdaysInYear(1900, Weekday.tu), 52);
      expect(DateUtils.numberOfWeekdaysInYear(1900, Weekday.we), 52);
      expect(DateUtils.numberOfWeekdaysInYear(1900, Weekday.th), 52);
      expect(DateUtils.numberOfWeekdaysInYear(1900, Weekday.fr), 52);
      expect(DateUtils.numberOfWeekdaysInYear(1900, Weekday.sa), 52);
    });

    test('Century leap year (2000)', () {
      // 2000 is a leap year (366 days), starts on Saturday
      expect(DateUtils.numberOfWeekdaysInYear(2000, Weekday.su), 53);
      expect(DateUtils.numberOfWeekdaysInYear(2000, Weekday.mo), 52);
      expect(DateUtils.numberOfWeekdaysInYear(2000, Weekday.tu), 52);
      expect(DateUtils.numberOfWeekdaysInYear(2000, Weekday.we), 52);
      expect(DateUtils.numberOfWeekdaysInYear(2000, Weekday.th), 52);
      expect(DateUtils.numberOfWeekdaysInYear(2000, Weekday.fr), 52);
      expect(DateUtils.numberOfWeekdaysInYear(2000, Weekday.sa), 53);
    });
  });

  group('CalDateTime - isInRange', () {
    group('Point-in-time (no duration)', () {
      test('Date within range', () {
        final date = CalDateTime.local(2025, 1, 15, 10, 0, 0);
        final start = CalDateTime.local(2025, 1, 1, 0, 0, 0);
        final end = CalDateTime.local(2025, 1, 31, 23, 59, 59);

        expect(date.isInRange(start, end), isTrue);
      });

      test('Date at range start', () {
        final date = CalDateTime.local(2025, 1, 1, 0, 0, 0);
        final start = CalDateTime.local(2025, 1, 1, 0, 0, 0);
        final end = CalDateTime.local(2025, 1, 31, 23, 59, 59);

        expect(date.isInRange(start, end), isTrue);
      });

      test('Date at range end', () {
        final date = CalDateTime.local(2025, 1, 31, 23, 59, 59);
        final start = CalDateTime.local(2025, 1, 1, 0, 0, 0);
        final end = CalDateTime.local(2025, 1, 31, 23, 59, 59);

        expect(date.isInRange(start, end), isTrue);
      });

      test('Date before range', () {
        final date = CalDateTime.local(2024, 12, 31, 23, 59, 59);
        final start = CalDateTime.local(2025, 1, 1, 0, 0, 0);
        final end = CalDateTime.local(2025, 1, 31, 23, 59, 59);

        expect(date.isInRange(start, end), isFalse);
      });

      test('Date after range', () {
        final date = CalDateTime.local(2025, 2, 1, 0, 0, 0);
        final start = CalDateTime.local(2025, 1, 1, 0, 0, 0);
        final end = CalDateTime.local(2025, 1, 31, 23, 59, 59);

        expect(date.isInRange(start, end), isFalse);
      });

      test('Single-day range', () {
        final date = CalDateTime.local(2025, 1, 15, 12, 0, 0);
        final start = CalDateTime.local(2025, 1, 15, 0, 0, 0);
        final end = CalDateTime.local(2025, 1, 15, 23, 59, 59);

        expect(date.isInRange(start, end), isTrue);
      });
    });

    group('With duration (overlap check)', () {
      test('Date with duration fully within range', () {
        final date = CalDateTime.local(2025, 1, 15, 10, 0, 0);
        final start = CalDateTime.local(2025, 1, 1, 0, 0, 0);
        final end = CalDateTime.local(2025, 1, 31, 23, 59, 59);
        final duration = CalDuration(hours: 2);

        expect(date.isInRange(start, end, duration: duration), isTrue);
      });

      test('Date starts before range but ends during range (overlap)', () {
        final date = CalDateTime.local(2025, 1, 30, 10, 0, 0);
        final start = CalDateTime.local(2025, 2, 1, 0, 0, 0);
        final end = CalDateTime.local(2025, 2, 28, 23, 59, 59);
        final duration = CalDuration(days: 3); // Ends Feb 2

        expect(date.isInRange(start, end, duration: duration), isTrue);
      });

      test('Date starts during range but ends after range (overlap)', () {
        final date = CalDateTime.local(2025, 1, 29, 10, 0, 0);
        final start = CalDateTime.local(2025, 1, 1, 0, 0, 0);
        final end = CalDateTime.local(2025, 1, 30, 23, 59, 59);
        final duration = CalDuration(days: 5); // Ends Feb 3

        expect(date.isInRange(start, end, duration: duration), isTrue);
      });

      test('Date with duration fully contains range', () {
        final date = CalDateTime.local(2024, 12, 28, 10, 0, 0);
        final start = CalDateTime.local(2025, 1, 1, 0, 0, 0);
        final end = CalDateTime.local(2025, 1, 5, 23, 59, 59);
        final duration = CalDuration(days: 10); // Ends Jan 7

        expect(date.isInRange(start, end, duration: duration), isTrue);
      });

      test('Date with duration ends before range starts (no overlap)', () {
        final date = CalDateTime.local(2025, 1, 10, 10, 0, 0);
        final start = CalDateTime.local(2025, 1, 20, 0, 0, 0);
        final end = CalDateTime.local(2025, 1, 31, 23, 59, 59);
        final duration = CalDuration(days: 5); // Ends Jan 15

        expect(date.isInRange(start, end, duration: duration), isFalse);
      });

      test('Date starts after range ends (no overlap)', () {
        final date = CalDateTime.local(2025, 2, 1, 10, 0, 0);
        final start = CalDateTime.local(2025, 1, 1, 0, 0, 0);
        final end = CalDateTime.local(2025, 1, 31, 23, 59, 59);
        final duration = CalDuration(days: 5);

        expect(date.isInRange(start, end, duration: duration), isFalse);
      });

      test('Date with duration exactly touches range start', () {
        final date = CalDateTime.local(2025, 1, 28, 10, 0, 0);
        final start = CalDateTime.local(2025, 2, 1, 0, 0, 0);
        final end = CalDateTime.local(2025, 2, 28, 23, 59, 59);
        final duration = CalDuration(days: 3, hours: 14); // Ends Feb 1 00:00

        expect(date.isInRange(start, end, duration: duration), isTrue);
      });

      test('Date starts exactly at range end', () {
        final date = CalDateTime.local(2025, 1, 31, 23, 59, 59);
        final start = CalDateTime.local(2025, 1, 1, 0, 0, 0);
        final end = CalDateTime.local(2025, 1, 31, 23, 59, 59);
        final duration = CalDuration(hours: 1);

        expect(date.isInRange(start, end, duration: duration), isTrue);
      });

      test('Multi-day duration spanning month boundary', () {
        final date = CalDateTime.local(2025, 1, 28, 20, 0, 0);
        final start = CalDateTime.local(2025, 1, 15, 0, 0, 0);
        final end = CalDateTime.local(2025, 2, 15, 23, 59, 59);
        final duration = CalDuration(days: 3); // Ends Jan 31

        expect(date.isInRange(start, end, duration: duration), isTrue);
      });

      test('Hour-based duration overlap', () {
        final date = CalDateTime.local(2025, 1, 15, 22, 0, 0);
        final start = CalDateTime.local(2025, 1, 16, 0, 0, 0);
        final end = CalDateTime.local(2025, 1, 16, 23, 59, 59);
        final duration = CalDuration(hours: 3); // Ends Jan 16 01:00

        expect(date.isInRange(start, end, duration: duration), isTrue);
      });
    });
  });
}
