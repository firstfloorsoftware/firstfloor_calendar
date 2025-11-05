import 'package:firstfloor_calendar/firstfloor_calendar.dart';
import 'package:firstfloor_calendar/src/semantic/builders.dart';
import 'package:test/test.dart';

void main() {
  group('RecurrenceRuleBuilder', () {
    group('Basic building', () {
      test('builds with only required frequency', () {
        final builder = RecurrenceRuleBuilder();
        builder.setFreq(RecurrenceFrequency.daily);
        final rule = builder.build();

        expect(rule.freq, RecurrenceFrequency.daily);
        expect(rule.interval, 1); // default value
        expect(rule.until, isNull);
        expect(rule.count, isNull);
      });

      test('throws StateError when building without frequency', () {
        final builder = RecurrenceRuleBuilder();
        expect(() => builder.build(), throwsStateError);
      });

      test('clears all values', () {
        final builder = RecurrenceRuleBuilder();
        builder.setFreq(RecurrenceFrequency.weekly);
        builder.setCount(10);
        builder.setInterval(2);
        builder.setWkst(Weekday.mo);

        builder.clear();

        expect(() => builder.build(), throwsStateError);
      });

      test('builds with all basic properties', () {
        final builder = RecurrenceRuleBuilder();
        builder.setFreq(RecurrenceFrequency.monthly);
        builder.setInterval(2);
        builder.setCount(5);
        builder.setWkst(Weekday.su);

        final rule = builder.build();

        expect(rule.freq, RecurrenceFrequency.monthly);
        expect(rule.interval, 2);
        expect(rule.count, 5);
        expect(rule.wkst, Weekday.su);
      });

      test('builds with until date', () {
        final builder = RecurrenceRuleBuilder();
        final until = CalDateTime.date(2025, 12, 31);
        builder.setFreq(RecurrenceFrequency.yearly);
        builder.setUntil(until);

        final rule = builder.build();

        expect(rule.until, until);
      });
    });

    group('setCount validation', () {
      test('accepts positive count', () {
        final builder = RecurrenceRuleBuilder();
        builder.setCount(10);
        builder.setFreq(RecurrenceFrequency.daily);
        final rule = builder.build();

        expect(rule.count, 10);
      });

      test('throws ArgumentError for zero count', () {
        final builder = RecurrenceRuleBuilder();
        expect(() => builder.setCount(0), throwsArgumentError);
      });

      test('throws ArgumentError for negative count', () {
        final builder = RecurrenceRuleBuilder();
        expect(() => builder.setCount(-1), throwsArgumentError);
      });
    });

    group('setInterval validation', () {
      test('accepts positive interval', () {
        final builder = RecurrenceRuleBuilder();
        builder.setInterval(5);
        builder.setFreq(RecurrenceFrequency.daily);
        final rule = builder.build();

        expect(rule.interval, 5);
      });

      test('throws ArgumentError for zero interval', () {
        final builder = RecurrenceRuleBuilder();
        expect(() => builder.setInterval(0), throwsArgumentError);
      });

      test('throws ArgumentError for negative interval', () {
        final builder = RecurrenceRuleBuilder();
        expect(() => builder.setInterval(-2), throwsArgumentError);
      });
    });

    group('setBySecond validation', () {
      test('accepts valid bySecond values', () {
        final builder = RecurrenceRuleBuilder();
        builder.setBySecond({0, 15, 30, 45, 60});
        builder.setFreq(RecurrenceFrequency.minutely);
        final rule = builder.build();

        expect(rule.bySecond, {0, 15, 30, 45, 60});
      });

      test('accepts null bySecond', () {
        final builder = RecurrenceRuleBuilder();
        builder.setBySecond(null);
        builder.setFreq(RecurrenceFrequency.daily);
        final rule = builder.build();

        expect(rule.bySecond, isNull);
      });

      test('throws ArgumentError for bySecond below 0', () {
        final builder = RecurrenceRuleBuilder();
        expect(() => builder.setBySecond({-1, 30}), throwsArgumentError);
      });

      test('throws ArgumentError for bySecond above 60', () {
        final builder = RecurrenceRuleBuilder();
        expect(() => builder.setBySecond({30, 61}), throwsArgumentError);
      });
    });

    group('setByMinute validation', () {
      test('accepts valid byMinute values', () {
        final builder = RecurrenceRuleBuilder();
        builder.setByMinute({0, 15, 30, 45});
        builder.setFreq(RecurrenceFrequency.hourly);
        final rule = builder.build();

        expect(rule.byMinute, {0, 15, 30, 45});
      });

      test('accepts null byMinute', () {
        final builder = RecurrenceRuleBuilder();
        builder.setByMinute(null);
        builder.setFreq(RecurrenceFrequency.daily);
        final rule = builder.build();

        expect(rule.byMinute, isNull);
      });

      test('throws ArgumentError for byMinute below 0', () {
        final builder = RecurrenceRuleBuilder();
        expect(() => builder.setByMinute({-1, 30}), throwsArgumentError);
      });

      test('throws ArgumentError for byMinute above 59', () {
        final builder = RecurrenceRuleBuilder();
        expect(() => builder.setByMinute({30, 60}), throwsArgumentError);
      });
    });

    group('setByHour validation', () {
      test('accepts valid byHour values', () {
        final builder = RecurrenceRuleBuilder();
        builder.setByHour({0, 6, 12, 18, 23});
        builder.setFreq(RecurrenceFrequency.daily);
        final rule = builder.build();

        expect(rule.byHour, {0, 6, 12, 18, 23});
      });

      test('accepts null byHour', () {
        final builder = RecurrenceRuleBuilder();
        builder.setByHour(null);
        builder.setFreq(RecurrenceFrequency.daily);
        final rule = builder.build();

        expect(rule.byHour, isNull);
      });

      test('throws ArgumentError for byHour below 0', () {
        final builder = RecurrenceRuleBuilder();
        expect(() => builder.setByHour({-1, 12}), throwsArgumentError);
      });

      test('throws ArgumentError for byHour above 23', () {
        final builder = RecurrenceRuleBuilder();
        expect(() => builder.setByHour({12, 24}), throwsArgumentError);
      });
    });

    group('setByDay', () {
      test('accepts valid byDay values', () {
        final builder = RecurrenceRuleBuilder();
        final byDay = {
          ByDay(Weekday.mo),
          ByDay(Weekday.we, ordinal: 1),
          ByDay(Weekday.fr, ordinal: -1),
        };

        builder.setByDay(byDay);
        builder.setFreq(RecurrenceFrequency.weekly);
        final rule = builder.build();

        expect(rule.byDay, byDay);
      });

      test('accepts null byDay', () {
        final builder = RecurrenceRuleBuilder();
        builder.setByDay(null);
        builder.setFreq(RecurrenceFrequency.daily);
        final rule = builder.build();

        expect(rule.byDay, isNull);
      });
    });

    group('setByMonthDay validation', () {
      test('accepts valid positive byMonthDay values', () {
        final builder = RecurrenceRuleBuilder();
        builder.setByMonthDay({1, 15, 31});
        builder.setFreq(RecurrenceFrequency.monthly);
        final rule = builder.build();

        expect(rule.byMonthDay, {1, 15, 31});
      });

      test('accepts valid negative byMonthDay values', () {
        final builder = RecurrenceRuleBuilder();
        builder.setByMonthDay({-1, -15, -31});
        builder.setFreq(RecurrenceFrequency.monthly);
        final rule = builder.build();

        expect(rule.byMonthDay, {-1, -15, -31});
      });

      test('accepts null byMonthDay', () {
        final builder = RecurrenceRuleBuilder();
        builder.setByMonthDay(null);
        builder.setFreq(RecurrenceFrequency.daily);
        final rule = builder.build();

        expect(rule.byMonthDay, isNull);
      });

      test('throws ArgumentError for byMonthDay of 0', () {
        final builder = RecurrenceRuleBuilder();
        expect(() => builder.setByMonthDay({0, 15}), throwsArgumentError);
      });

      test('throws ArgumentError for byMonthDay below -31', () {
        final builder = RecurrenceRuleBuilder();
        expect(() => builder.setByMonthDay({-32, -1}), throwsArgumentError);
      });

      test('throws ArgumentError for byMonthDay above 31', () {
        final builder = RecurrenceRuleBuilder();
        expect(() => builder.setByMonthDay({15, 32}), throwsArgumentError);
      });
    });

    group('setByYearDay validation', () {
      test('accepts valid positive byYearDay values', () {
        final builder = RecurrenceRuleBuilder();
        builder.setByYearDay({1, 100, 366});
        builder.setFreq(RecurrenceFrequency.yearly);
        final rule = builder.build();

        expect(rule.byYearDay, {1, 100, 366});
      });

      test('accepts valid negative byYearDay values', () {
        final builder = RecurrenceRuleBuilder();
        builder.setByYearDay({-1, -100, -366});
        builder.setFreq(RecurrenceFrequency.yearly);
        final rule = builder.build();

        expect(rule.byYearDay, {-1, -100, -366});
      });

      test('accepts null byYearDay', () {
        final builder = RecurrenceRuleBuilder();
        builder.setByYearDay(null);
        builder.setFreq(RecurrenceFrequency.daily);
        final rule = builder.build();

        expect(rule.byYearDay, isNull);
      });

      test('throws ArgumentError for byYearDay of 0', () {
        final builder = RecurrenceRuleBuilder();
        expect(() => builder.setByYearDay({0, 100}), throwsArgumentError);
      });

      test('throws ArgumentError for byYearDay below -366', () {
        final builder = RecurrenceRuleBuilder();
        expect(() => builder.setByYearDay({-367, -1}), throwsArgumentError);
      });

      test('throws ArgumentError for byYearDay above 366', () {
        final builder = RecurrenceRuleBuilder();
        expect(() => builder.setByYearDay({100, 367}), throwsArgumentError);
      });
    });

    group('setByWeekNo validation', () {
      test('accepts valid positive byWeekNo values', () {
        final builder = RecurrenceRuleBuilder();
        builder.setByWeekNo({1, 26, 53});
        builder.setFreq(RecurrenceFrequency.yearly);
        final rule = builder.build();

        expect(rule.byWeekNo, {1, 26, 53});
      });

      test('accepts valid negative byWeekNo values', () {
        final builder = RecurrenceRuleBuilder();
        builder.setByWeekNo({-1, -26, -53});
        builder.setFreq(RecurrenceFrequency.yearly);
        final rule = builder.build();

        expect(rule.byWeekNo, {-1, -26, -53});
      });

      test('accepts null byWeekNo', () {
        final builder = RecurrenceRuleBuilder();
        builder.setByWeekNo(null);
        builder.setFreq(RecurrenceFrequency.daily);
        final rule = builder.build();

        expect(rule.byWeekNo, isNull);
      });

      test('throws ArgumentError for byWeekNo of 0', () {
        final builder = RecurrenceRuleBuilder();
        expect(() => builder.setByWeekNo({0, 26}), throwsArgumentError);
      });

      test('throws ArgumentError for byWeekNo below -53', () {
        final builder = RecurrenceRuleBuilder();
        expect(() => builder.setByWeekNo({-54, -1}), throwsArgumentError);
      });

      test('throws ArgumentError for byWeekNo above 53', () {
        final builder = RecurrenceRuleBuilder();
        expect(() => builder.setByWeekNo({26, 54}), throwsArgumentError);
      });
    });

    group('setByMonth validation', () {
      test('accepts valid byMonth values', () {
        final builder = RecurrenceRuleBuilder();
        builder.setByMonth({1, 6, 12});
        builder.setFreq(RecurrenceFrequency.yearly);
        final rule = builder.build();

        expect(rule.byMonth, {1, 6, 12});
      });

      test('accepts null byMonth', () {
        final builder = RecurrenceRuleBuilder();
        builder.setByMonth(null);
        builder.setFreq(RecurrenceFrequency.daily);
        final rule = builder.build();

        expect(rule.byMonth, isNull);
      });

      test('throws ArgumentError for byMonth below 1', () {
        final builder = RecurrenceRuleBuilder();
        expect(() => builder.setByMonth({0, 6}), throwsArgumentError);
      });

      test('throws ArgumentError for byMonth above 12', () {
        final builder = RecurrenceRuleBuilder();
        expect(() => builder.setByMonth({6, 13}), throwsArgumentError);
      });
    });

    group('setBySetPos validation', () {
      test('accepts valid positive bySetPos values', () {
        final builder = RecurrenceRuleBuilder();
        builder.setBySetPos({1, 100, 366});
        builder.setFreq(RecurrenceFrequency.yearly);
        final rule = builder.build();

        expect(rule.bySetPos, {1, 100, 366});
      });

      test('accepts valid negative bySetPos values', () {
        final builder = RecurrenceRuleBuilder();
        builder.setBySetPos({-1, -100, -366});
        builder.setFreq(RecurrenceFrequency.yearly);
        final rule = builder.build();

        expect(rule.bySetPos, {-1, -100, -366});
      });

      test('accepts null bySetPos', () {
        final builder = RecurrenceRuleBuilder();
        builder.setBySetPos(null);
        builder.setFreq(RecurrenceFrequency.daily);
        final rule = builder.build();

        expect(rule.bySetPos, isNull);
      });

      test('throws ArgumentError for bySetPos of 0', () {
        final builder = RecurrenceRuleBuilder();
        expect(() => builder.setBySetPos({0, 100}), throwsArgumentError);
      });

      test('throws ArgumentError for bySetPos below -366', () {
        final builder = RecurrenceRuleBuilder();
        expect(() => builder.setBySetPos({-367, -1}), throwsArgumentError);
      });

      test('throws ArgumentError for bySetPos above 366', () {
        final builder = RecurrenceRuleBuilder();
        expect(() => builder.setBySetPos({100, 367}), throwsArgumentError);
      });
    });

    group('Complex scenarios', () {
      test('builds complete recurrence rule with all properties', () {
        final builder = RecurrenceRuleBuilder();
        final until = CalDateTime.utc(2025, 12, 31, 23, 59, 59);

        builder.setFreq(RecurrenceFrequency.monthly);
        builder.setUntil(until);
        builder.setInterval(3);
        builder.setByMonth({1, 4, 7, 10});
        builder.setByMonthDay({1, 15});
        builder.setByDay({ByDay(Weekday.mo), ByDay(Weekday.fr)});
        builder.setByHour({9, 17});
        builder.setByMinute({0, 30});
        builder.setBySecond({0});
        builder.setWkst(Weekday.mo);

        final rule = builder.build();

        expect(rule.freq, RecurrenceFrequency.monthly);
        expect(rule.until, until);
        expect(rule.interval, 3);
        expect(rule.byMonth, {1, 4, 7, 10});
        expect(rule.byMonthDay, {1, 15});
        expect(rule.byDay?.length, 2);
        expect(rule.byHour, {9, 17});
        expect(rule.byMinute, {0, 30});
        expect(rule.bySecond, {0});
        expect(rule.wkst, Weekday.mo);
      });

      test('reuses builder after clear', () {
        final builder = RecurrenceRuleBuilder();
        builder.setFreq(RecurrenceFrequency.daily);
        builder.setCount(10);
        builder.build();

        builder.clear();

        builder.setFreq(RecurrenceFrequency.weekly);
        builder.setInterval(2);
        final rule = builder.build();

        expect(rule.freq, RecurrenceFrequency.weekly);
        expect(rule.interval, 2);
        expect(rule.count, isNull);
      });
    });
  });
}
