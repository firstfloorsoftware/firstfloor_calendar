import 'package:collection/collection.dart';
import 'package:firstfloor_calendar/firstfloor_calendar.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });

  List<CalDateTime> getOccurrences(List<String> lines, {int take = -1}) {
    final properties = lines.map((line) => DocumentParser.parseProperty(line));

    final dtstart = parseCalDateTime(
      properties.firstWhere((p) => p.name == 'DTSTART'),
    );
    final rrule = parseRecurrenceRule(
      properties.firstWhere((p) => p.name == 'RRULE'),
    );
    final exdatesProperty = properties.firstWhereOrNull(
      (p) => p.name == 'EXDATE',
    );
    final exdates = exdatesProperty != null
        ? parseCalDateOrDateTimeList(exdatesProperty)
        : null;

    final iterator = RecurrenceIterator(
      dtstart: dtstart,
      rrule: rrule,
      exdates: exdates,
    );

    final result = iterator.occurrences();
    return take > 0 ? result.take(take).toList() : result.toList();
  }

  void expectOccurrences(List<CalDateTime> actual, List<String> expected) {
    expect(actual.length, expected.length);
    for (var i = 0; i < expected.length; i++) {
      expect(actual[i].toString(), expected[i]);
    }
  }

  group('RFC5545 RRULE Examples', () {
    test('Daily for 10 occurrences', () {
      final actual = getOccurrences([
        'DTSTART;TZID=America/New_York:19970902T090000',
        'RRULE:FREQ=DAILY;COUNT=10',
      ]);

      expectOccurrences(actual, [
        '19970902T090000 [America/New_York]',
        '19970903T090000 [America/New_York]',
        '19970904T090000 [America/New_York]',
        '19970905T090000 [America/New_York]',
        '19970906T090000 [America/New_York]',
        '19970907T090000 [America/New_York]',
        '19970908T090000 [America/New_York]',
        '19970909T090000 [America/New_York]',
        '19970910T090000 [America/New_York]',
        '19970911T090000 [America/New_York]',
      ]);
    });

    test('Daily until December 24, 1997', () {
      final actual = getOccurrences([
        'DTSTART;TZID=America/New_York:19970920T090000',
        'RRULE:FREQ=DAILY;UNTIL=19971224T000000Z',
      ]);

      expect(actual.length, 95);
      expect(actual[0].toString(), '19970920T090000 [America/New_York]');
      expect(actual[1].toString(), '19970921T090000 [America/New_York]');
      expect(actual[94].toString(), '19971223T090000 [America/New_York]');
    });

    test('Every other day - forever', () {
      // take 10 occurrences
      final actual = getOccurrences([
        'DTSTART;TZID=America/New_York:19970902T090000',
        'RRULE:FREQ=DAILY;INTERVAL=2',
      ], take: 10);

      expectOccurrences(actual, [
        '19970902T090000 [America/New_York]',
        '19970904T090000 [America/New_York]',
        '19970906T090000 [America/New_York]',
        '19970908T090000 [America/New_York]',
        '19970910T090000 [America/New_York]',
        '19970912T090000 [America/New_York]',
        '19970914T090000 [America/New_York]',
        '19970916T090000 [America/New_York]',
        '19970918T090000 [America/New_York]',
        '19970920T090000 [America/New_York]',
      ]);
    });

    test('Every 10 days, 5 occurrences', () {
      final actual = getOccurrences([
        'DTSTART;TZID=America/New_York:19970902T090000',
        'RRULE:FREQ=DAILY;INTERVAL=10;COUNT=5',
      ]);

      expectOccurrences(actual, [
        '19970902T090000 [America/New_York]',
        '19970912T090000 [America/New_York]',
        '19970922T090000 [America/New_York]',
        '19971002T090000 [America/New_York]',
        '19971012T090000 [America/New_York]',
      ]);
    });

    test('Every day in January, for 3 years', () {
      final actual = getOccurrences([
        'DTSTART;TZID=America/New_York:19980101T090000',
        'RRULE:FREQ=YEARLY;UNTIL=20000131T140000Z;BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA',
      ]);
      final actual2 = getOccurrences([
        'DTSTART;TZID=America/New_York:19980101T090000',
        'RRULE:FREQ=DAILY;UNTIL=20000131T140000Z;BYMONTH=1',
      ]);

      final expected = [
        for (var day = 1; day <= 31; day++)
          '199801${day.toString().padLeft(2, '0')}T090000 [America/New_York]',
        for (var day = 1; day <= 31; day++)
          '199901${day.toString().padLeft(2, '0')}T090000 [America/New_York]',
        for (var day = 1; day <= 31; day++)
          '200001${day.toString().padLeft(2, '0')}T090000 [America/New_York]',
      ];

      expectOccurrences(actual, expected);
      expectOccurrences(actual2, expected);
    });

    test('Weekly for 10 occurrences', () {
      final actual = getOccurrences([
        'DTSTART;TZID=America/New_York:19970902T090000',
        'RRULE:FREQ=WEEKLY;COUNT=10',
      ]);

      expectOccurrences(actual, [
        '19970902T090000 [America/New_York]',
        '19970909T090000 [America/New_York]',
        '19970916T090000 [America/New_York]',
        '19970923T090000 [America/New_York]',
        '19970930T090000 [America/New_York]',
        '19971007T090000 [America/New_York]',
        '19971014T090000 [America/New_York]',
        '19971021T090000 [America/New_York]',
        '19971028T090000 [America/New_York]',
        '19971104T090000 [America/New_York]',
      ]);
    });

    test('Weekly until December 24, 1997', () {
      final actual = getOccurrences([
        'DTSTART;TZID=America/New_York:19970902T090000',
        'RRULE:FREQ=WEEKLY;UNTIL=19971224T000000Z',
      ]);

      expectOccurrences(actual, [
        '19970902T090000 [America/New_York]',
        '19970909T090000 [America/New_York]',
        '19970916T090000 [America/New_York]',
        '19970923T090000 [America/New_York]',
        '19970930T090000 [America/New_York]',
        '19971007T090000 [America/New_York]',
        '19971014T090000 [America/New_York]',
        '19971021T090000 [America/New_York]',
        '19971028T090000 [America/New_York]',
        '19971104T090000 [America/New_York]',
        '19971111T090000 [America/New_York]',
        '19971118T090000 [America/New_York]',
        '19971125T090000 [America/New_York]',
        '19971202T090000 [America/New_York]',
        '19971209T090000 [America/New_York]',
        '19971216T090000 [America/New_York]',
        '19971223T090000 [America/New_York]',
      ]);
    });

    test('Every other week - forever', () {
      // take 10 occurrences
      final actual = getOccurrences([
        'DTSTART;TZID=America/New_York:19970902T090000',
        'RRULE:FREQ=WEEKLY;INTERVAL=2;WKST=SU',
      ], take: 10);

      expectOccurrences(actual, [
        '19970902T090000 [America/New_York]',
        '19970916T090000 [America/New_York]',
        '19970930T090000 [America/New_York]',
        '19971014T090000 [America/New_York]',
        '19971028T090000 [America/New_York]',
        '19971111T090000 [America/New_York]',
        '19971125T090000 [America/New_York]',
        '19971209T090000 [America/New_York]',
        '19971223T090000 [America/New_York]',
        '19980106T090000 [America/New_York]',
      ]);
    });

    test('Weekly on Tuesday and Thursday for five weeks', () {
      final actual = getOccurrences([
        'DTSTART;TZID=America/New_York:19970902T090000',
        'RRULE:FREQ=WEEKLY;UNTIL=19971007T000000Z;WKST=SU;BYDAY=TU,TH',
      ]);

      final actual2 = getOccurrences([
        'DTSTART;TZID=America/New_York:19970902T090000',
        'RRULE:FREQ=WEEKLY;COUNT=10;WKST=SU;BYDAY=TU,TH',
      ]);

      final expected = [
        '19970902T090000 [America/New_York]',
        '19970904T090000 [America/New_York]',
        '19970909T090000 [America/New_York]',
        '19970911T090000 [America/New_York]',
        '19970916T090000 [America/New_York]',
        '19970918T090000 [America/New_York]',
        '19970923T090000 [America/New_York]',
        '19970925T090000 [America/New_York]',
        '19970930T090000 [America/New_York]',
        '19971002T090000 [America/New_York]',
      ];

      expectOccurrences(actual, expected);
      expectOccurrences(actual2, expected);
    });

    test(
      'Every other week on Monday, Wednesday, and Friday until December 24, 1997, starting on Monday, September 1, 1997',
      () {
        final actual = getOccurrences([
          'DTSTART;TZID=America/New_York:19970901T090000',
          'RRULE:FREQ=WEEKLY;INTERVAL=2;UNTIL=19971224T000000Z;WKST=SU;BYDAY=MO,WE,FR',
        ]);

        expectOccurrences(actual, [
          '19970901T090000 [America/New_York]',
          '19970903T090000 [America/New_York]',
          '19970905T090000 [America/New_York]',
          '19970915T090000 [America/New_York]',
          '19970917T090000 [America/New_York]',
          '19970919T090000 [America/New_York]',
          '19970929T090000 [America/New_York]',
          '19971001T090000 [America/New_York]',
          '19971003T090000 [America/New_York]',
          '19971013T090000 [America/New_York]',
          '19971015T090000 [America/New_York]',
          '19971017T090000 [America/New_York]',
          '19971027T090000 [America/New_York]',
          '19971029T090000 [America/New_York]',
          '19971031T090000 [America/New_York]',
          '19971110T090000 [America/New_York]',
          '19971112T090000 [America/New_York]',
          '19971114T090000 [America/New_York]',
          '19971124T090000 [America/New_York]',
          '19971126T090000 [America/New_York]',
          '19971128T090000 [America/New_York]',
          '19971208T090000 [America/New_York]',
          '19971210T090000 [America/New_York]',
          '19971212T090000 [America/New_York]',
          '19971222T090000 [America/New_York]',
        ]);
      },
    );

    test('Every other week on Tuesday and Thursday, for 8 occurrences', () {
      final actual = getOccurrences([
        'DTSTART;TZID=America/New_York:19970902T090000',
        'RRULE:FREQ=WEEKLY;INTERVAL=2;COUNT=8;WKST=SU;BYDAY=TU,TH',
      ]);

      expectOccurrences(actual, [
        '19970902T090000 [America/New_York]',
        '19970904T090000 [America/New_York]',
        '19970916T090000 [America/New_York]',
        '19970918T090000 [America/New_York]',
        '19970930T090000 [America/New_York]',
        '19971002T090000 [America/New_York]',
        '19971014T090000 [America/New_York]',
        '19971016T090000 [America/New_York]',
      ]);
    });

    test('Monthly on the first Friday for 10 occurrences', () {
      final actual = getOccurrences([
        'DTSTART;TZID=America/New_York:19970905T090000',
        'RRULE:FREQ=MONTHLY;COUNT=10;BYDAY=1FR',
      ]);

      expectOccurrences(actual, [
        '19970905T090000 [America/New_York]',
        '19971003T090000 [America/New_York]',
        '19971107T090000 [America/New_York]',
        '19971205T090000 [America/New_York]',
        '19980102T090000 [America/New_York]',
        '19980206T090000 [America/New_York]',
        '19980306T090000 [America/New_York]',
        '19980403T090000 [America/New_York]',
        '19980501T090000 [America/New_York]',
        '19980605T090000 [America/New_York]',
      ]);
    });

    test('Monthly on the first Friday until December 24, 1997', () {
      final actual = getOccurrences([
        'DTSTART;TZID=America/New_York:19970905T090000',
        'RRULE:FREQ=MONTHLY;UNTIL=19971224T000000Z;BYDAY=1FR',
      ]);

      expectOccurrences(actual, [
        '19970905T090000 [America/New_York]',
        '19971003T090000 [America/New_York]',
        '19971107T090000 [America/New_York]',
        '19971205T090000 [America/New_York]',
      ]);
    });

    test(
      'Every other month on the first and last Sunday of the month for 10 occurrences',
      () {
        final actual = getOccurrences([
          'DTSTART;TZID=America/New_York:19970907T090000',
          'RRULE:FREQ=MONTHLY;INTERVAL=2;COUNT=10;BYDAY=1SU,-1SU',
        ]);

        expectOccurrences(actual, [
          '19970907T090000 [America/New_York]',
          '19970928T090000 [America/New_York]',
          '19971102T090000 [America/New_York]',
          '19971130T090000 [America/New_York]',
          '19980104T090000 [America/New_York]',
          '19980125T090000 [America/New_York]',
          '19980301T090000 [America/New_York]',
          '19980329T090000 [America/New_York]',
          '19980503T090000 [America/New_York]',
          '19980531T090000 [America/New_York]',
        ]);
      },
    );

    test('Monthly on the second-to-last Monday of the month for 6 months', () {
      final actual = getOccurrences([
        'DTSTART;TZID=America/New_York:19970922T090000',
        'RRULE:FREQ=MONTHLY;COUNT=6;BYDAY=-2MO',
      ]);

      expectOccurrences(actual, [
        '19970922T090000 [America/New_York]',
        '19971020T090000 [America/New_York]',
        '19971117T090000 [America/New_York]',
        '19971222T090000 [America/New_York]',
        '19980119T090000 [America/New_York]',
        '19980216T090000 [America/New_York]',
      ]);
    });

    test('Monthly on the third-to-the-last day of the month, forever', () {
      final actual = getOccurrences([
        'DTSTART;TZID=America/New_York:19970928T090000',
        'RRULE:FREQ=MONTHLY;BYMONTHDAY=-3',
      ], take: 6);

      expectOccurrences(actual, [
        '19970928T090000 [America/New_York]',
        '19971029T090000 [America/New_York]',
        '19971128T090000 [America/New_York]',
        '19971229T090000 [America/New_York]',
        '19980129T090000 [America/New_York]',
        '19980226T090000 [America/New_York]',
      ]);
    });

    test('Monthly on the 2nd and 15th of the month for 10 occurrences', () {
      final actual = getOccurrences([
        'DTSTART;TZID=America/New_York:19970902T090000',
        'RRULE:FREQ=MONTHLY;COUNT=10;BYMONTHDAY=2,15',
      ]);

      expectOccurrences(actual, [
        '19970902T090000 [America/New_York]',
        '19970915T090000 [America/New_York]',
        '19971002T090000 [America/New_York]',
        '19971015T090000 [America/New_York]',
        '19971102T090000 [America/New_York]',
        '19971115T090000 [America/New_York]',
        '19971202T090000 [America/New_York]',
        '19971215T090000 [America/New_York]',
        '19980102T090000 [America/New_York]',
        '19980115T090000 [America/New_York]',
      ]);
    });

    test(
      'Monthly on the first and last day of the month for 10 occurrences',
      () {
        final actual = getOccurrences([
          'DTSTART;TZID=America/New_York:19970930T090000',
          'RRULE:FREQ=MONTHLY;COUNT=10;BYMONTHDAY=1,-1',
        ]);

        expectOccurrences(actual, [
          '19970930T090000 [America/New_York]',
          '19971001T090000 [America/New_York]',
          '19971031T090000 [America/New_York]',
          '19971101T090000 [America/New_York]',
          '19971130T090000 [America/New_York]',
          '19971201T090000 [America/New_York]',
          '19971231T090000 [America/New_York]',
          '19980101T090000 [America/New_York]',
          '19980131T090000 [America/New_York]',
          '19980201T090000 [America/New_York]',
        ]);
      },
    );

    test(
      'Every 18 months on the 10th thru 15th of the month for 10 occurrences',
      () {
        final actual = getOccurrences([
          'DTSTART;TZID=America/New_York:19970910T090000',
          'RRULE:FREQ=MONTHLY;INTERVAL=18;COUNT=10;BYMONTHDAY=10,11,12,13,14,15',
        ]);

        expectOccurrences(actual, [
          '19970910T090000 [America/New_York]',
          '19970911T090000 [America/New_York]',
          '19970912T090000 [America/New_York]',
          '19970913T090000 [America/New_York]',
          '19970914T090000 [America/New_York]',
          '19970915T090000 [America/New_York]',
          '19990310T090000 [America/New_York]',
          '19990311T090000 [America/New_York]',
          '19990312T090000 [America/New_York]',
          '19990313T090000 [America/New_York]',
        ]);
      },
    );

    test('Every Tuesday, every other month', () {
      final actual = getOccurrences([
        'DTSTART;TZID=America/New_York:19970902T090000',
        'RRULE:FREQ=MONTHLY;INTERVAL=2;BYDAY=TU',
      ], take: 14);

      expectOccurrences(actual, [
        '19970902T090000 [America/New_York]',
        '19970909T090000 [America/New_York]',
        '19970916T090000 [America/New_York]',
        '19970923T090000 [America/New_York]',
        '19970930T090000 [America/New_York]',
        '19971104T090000 [America/New_York]',
        '19971111T090000 [America/New_York]',
        '19971118T090000 [America/New_York]',
        '19971125T090000 [America/New_York]',
        '19980106T090000 [America/New_York]',
        '19980113T090000 [America/New_York]',
        '19980120T090000 [America/New_York]',
        '19980127T090000 [America/New_York]',
        '19980303T090000 [America/New_York]',
      ]);
    });

    test('Yearly in June and July for 10 occurrences', () {
      final actual = getOccurrences([
        'DTSTART;TZID=America/New_York:19970610T090000',
        'RRULE:FREQ=YEARLY;COUNT=10;BYMONTH=6,7',
      ]);

      expectOccurrences(actual, [
        '19970610T090000 [America/New_York]',
        '19970710T090000 [America/New_York]',
        '19980610T090000 [America/New_York]',
        '19980710T090000 [America/New_York]',
        '19990610T090000 [America/New_York]',
        '19990710T090000 [America/New_York]',
        '20000610T090000 [America/New_York]',
        '20000710T090000 [America/New_York]',
        '20010610T090000 [America/New_York]',
        '20010710T090000 [America/New_York]',
      ]);
    });

    test(
      'Every other year on January, February, and March for 10 occurrences',
      () {
        final actual = getOccurrences([
          'DTSTART;TZID=America/New_York:19970310T090000',
          'RRULE:FREQ=YEARLY;INTERVAL=2;COUNT=10;BYMONTH=1,2,3',
        ]);

        expectOccurrences(actual, [
          '19970310T090000 [America/New_York]',
          '19990110T090000 [America/New_York]',
          '19990210T090000 [America/New_York]',
          '19990310T090000 [America/New_York]',
          '20010110T090000 [America/New_York]',
          '20010210T090000 [America/New_York]',
          '20010310T090000 [America/New_York]',
          '20030110T090000 [America/New_York]',
          '20030210T090000 [America/New_York]',
          '20030310T090000 [America/New_York]',
        ]);
      },
    );

    test(
      'Every third year on the 1st, 100th, and 200th day for 10 occurrences',
      () {
        final actual = getOccurrences([
          'DTSTART;TZID=America/New_York:19970101T090000',
          'RRULE:FREQ=YEARLY;INTERVAL=3;COUNT=10;BYYEARDAY=1,100,200',
        ]);

        expectOccurrences(actual, [
          '19970101T090000 [America/New_York]',
          '19970410T090000 [America/New_York]',
          '19970719T090000 [America/New_York]',
          '20000101T090000 [America/New_York]',
          '20000409T090000 [America/New_York]',
          '20000718T090000 [America/New_York]',
          '20030101T090000 [America/New_York]',
          '20030410T090000 [America/New_York]',
          '20030719T090000 [America/New_York]',
          '20060101T090000 [America/New_York]',
        ]);
      },
    );

    test('Every 20th Monday of the year, forever', () {
      final actual = getOccurrences([
        'DTSTART;TZID=America/New_York:19970519T090000',
        'RRULE:FREQ=YEARLY;BYDAY=20MO',
      ], take: 3);

      expectOccurrences(actual, [
        '19970519T090000 [America/New_York]',
        '19980518T090000 [America/New_York]',
        '19990517T090000 [America/New_York]',
      ]);
    });

    test(
      'Monday of week number 20 (where the default start of the week is Monday), forever',
      () {
        final actual = getOccurrences([
          'DTSTART;TZID=America/New_York:19970512T090000',
          'RRULE:FREQ=YEARLY;BYWEEKNO=20;BYDAY=MO',
        ], take: 3);

        expectOccurrences(actual, [
          '19970512T090000 [America/New_York]',
          '19980511T090000 [America/New_York]',
          '19990517T090000 [America/New_York]',
        ]);
      },
    );

    test('Every Thursday in March, forever', () {
      final actual = getOccurrences([
        'DTSTART;TZID=America/New_York:19970313T090000',
        'RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=TH',
      ], take: 11);

      expectOccurrences(actual, [
        '19970313T090000 [America/New_York]',
        '19970320T090000 [America/New_York]',
        '19970327T090000 [America/New_York]',
        '19980305T090000 [America/New_York]',
        '19980312T090000 [America/New_York]',
        '19980319T090000 [America/New_York]',
        '19980326T090000 [America/New_York]',
        '19990304T090000 [America/New_York]',
        '19990311T090000 [America/New_York]',
        '19990318T090000 [America/New_York]',
        '19990325T090000 [America/New_York]',
      ]);
    });

    test('Every Thursday, but only during June, July, and August, forever', () {
      final actual = getOccurrences([
        'DTSTART;TZID=America/New_York:19970605T090000',
        'RRULE:FREQ=YEARLY;BYDAY=TH;BYMONTH=6,7,8',
      ], take: 26);

      expectOccurrences(actual, [
        '19970605T090000 [America/New_York]',
        '19970612T090000 [America/New_York]',
        '19970619T090000 [America/New_York]',
        '19970626T090000 [America/New_York]',
        '19970703T090000 [America/New_York]',
        '19970710T090000 [America/New_York]',
        '19970717T090000 [America/New_York]',
        '19970724T090000 [America/New_York]',
        '19970731T090000 [America/New_York]',
        '19970807T090000 [America/New_York]',
        '19970814T090000 [America/New_York]',
        '19970821T090000 [America/New_York]',
        '19970828T090000 [America/New_York]',
        '19980604T090000 [America/New_York]',
        '19980611T090000 [America/New_York]',
        '19980618T090000 [America/New_York]',
        '19980625T090000 [America/New_York]',
        '19980702T090000 [America/New_York]',
        '19980709T090000 [America/New_York]',
        '19980716T090000 [America/New_York]',
        '19980723T090000 [America/New_York]',
        '19980730T090000 [America/New_York]',
        '19980806T090000 [America/New_York]',
        '19980813T090000 [America/New_York]',
        '19980820T090000 [America/New_York]',
        '19980827T090000 [America/New_York]',
      ]);
    });

    test('Every Friday the 13th, forever', () {
      final actual = getOccurrences([
        'DTSTART;TZID=America/New_York:19970902T090000',
        'EXDATE;TZID=America/New_York:19970902T090000',
        'RRULE:FREQ=MONTHLY;BYDAY=FR;BYMONTHDAY=13',
      ], take: 5);

      expectOccurrences(actual, [
        '19980213T090000 [America/New_York]',
        '19980313T090000 [America/New_York]',
        '19981113T090000 [America/New_York]',
        '19990813T090000 [America/New_York]',
        '20001013T090000 [America/New_York]',
      ]);
    });

    test(
      'The first Saturday that follows the first Sunday of the month, forever',
      () {
        final actual = getOccurrences([
          'DTSTART;TZID=America/New_York:19970913T090000',
          'RRULE:FREQ=MONTHLY;BYDAY=SA;BYMONTHDAY=7,8,9,10,11,12,13',
        ], take: 10);

        expectOccurrences(actual, [
          '19970913T090000 [America/New_York]',
          '19971011T090000 [America/New_York]',
          '19971108T090000 [America/New_York]',
          '19971213T090000 [America/New_York]',
          '19980110T090000 [America/New_York]',
          '19980207T090000 [America/New_York]',
          '19980307T090000 [America/New_York]',
          '19980411T090000 [America/New_York]',
          '19980509T090000 [America/New_York]',
          '19980613T090000 [America/New_York]',
        ]);
      },
    );

    test(
      'Every 4 years, the first Tuesday after a Monday in November, forever (U.S. Presidential Election day)',
      () {
        final actual = getOccurrences([
          'DTSTART;TZID=America/New_York:19961105T090000',
          'RRULE:FREQ=YEARLY;INTERVAL=4;BYMONTH=11;BYDAY=TU;BYMONTHDAY=2,3,4,5,6,7,8',
        ], take: 3);

        expectOccurrences(actual, [
          '19961105T090000 [America/New_York]',
          '20001107T090000 [America/New_York]',
          '20041102T090000 [America/New_York]',
        ]);
      },
    );

    test(
      'The third instance into the month of one of Tuesday, Wednesday, or Thursday, for the next 3 months',
      () {
        final actual = getOccurrences([
          'DTSTART;TZID=America/New_York:19970904T090000',
          'RRULE:FREQ=MONTHLY;COUNT=3;BYDAY=TU,WE,TH;BYSETPOS=3',
        ]);

        expectOccurrences(actual, [
          '19970904T090000 [America/New_York]',
          '19971007T090000 [America/New_York]',
          '19971106T090000 [America/New_York]',
        ]);
      },
    );

    test('The second-to-last weekday of the month', () {
      final actual = getOccurrences([
        'DTSTART;TZID=America/New_York:19970929T090000',
        'RRULE:FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-2',
      ], take: 7);

      expectOccurrences(actual, [
        '19970929T090000 [America/New_York]',
        '19971030T090000 [America/New_York]',
        '19971127T090000 [America/New_York]',
        '19971230T090000 [America/New_York]',
        '19980129T090000 [America/New_York]',
        '19980226T090000 [America/New_York]',
        '19980330T090000 [America/New_York]',
      ]);
    });

    test('Every 3 hours from 9:00 AM to 5:00 PM on a specific day', () {
      final actual = getOccurrences([
        'DTSTART;TZID=America/New_York:19970902T090000',
        'RRULE:FREQ=HOURLY;INTERVAL=3;UNTIL=19970902T170000Z',
      ]);

      expectOccurrences(actual, [
        '19970902T090000 [America/New_York]',
        '19970902T120000 [America/New_York]',
        '19970902T150000 [America/New_York]',
      ]);
    });

    test('Every 15 minutes for 6 occurrences', () {
      final actual = getOccurrences([
        'DTSTART;TZID=America/New_York:19970902T090000',
        'RRULE:FREQ=MINUTELY;INTERVAL=15;COUNT=6',
      ]);

      expectOccurrences(actual, [
        '19970902T090000 [America/New_York]',
        '19970902T091500 [America/New_York]',
        '19970902T093000 [America/New_York]',
        '19970902T094500 [America/New_York]',
        '19970902T100000 [America/New_York]',
        '19970902T101500 [America/New_York]',
      ]);
    });

    test('Every hour and a half for 4 occurrences', () {
      final actual = getOccurrences([
        'DTSTART;TZID=America/New_York:19970902T090000',
        'RRULE:FREQ=MINUTELY;INTERVAL=90;COUNT=4',
      ]);

      expectOccurrences(actual, [
        '19970902T090000 [America/New_York]',
        '19970902T103000 [America/New_York]',
        '19970902T120000 [America/New_York]',
        '19970902T133000 [America/New_York]',
      ]);
    });

    test('Every 20 minutes from 9:00 AM to 4:40 PM every day', () {
      final actual = getOccurrences([
        'DTSTART;TZID=America/New_York:19970902T090000',
        'RRULE:FREQ=DAILY;BYHOUR=9,10,11,12,13,14,15,16;BYMINUTE=0,20,40',
      ], take: 25);

      final actual2 = getOccurrences([
        'DTSTART;TZID=America/New_York:19970902T090000',
        'RRULE:FREQ=MINUTELY;INTERVAL=20;BYHOUR=9,10,11,12,13,14,15,16',
      ], take: 25);

      final expected = [
        '19970902T090000 [America/New_York]',
        '19970902T092000 [America/New_York]',
        '19970902T094000 [America/New_York]',
        '19970902T100000 [America/New_York]',
        '19970902T102000 [America/New_York]',
        '19970902T104000 [America/New_York]',
        '19970902T110000 [America/New_York]',
        '19970902T112000 [America/New_York]',
        '19970902T114000 [America/New_York]',
        '19970902T120000 [America/New_York]',
        '19970902T122000 [America/New_York]',
        '19970902T124000 [America/New_York]',
        '19970902T130000 [America/New_York]',
        '19970902T132000 [America/New_York]',
        '19970902T134000 [America/New_York]',
        '19970902T140000 [America/New_York]',
        '19970902T142000 [America/New_York]',
        '19970902T144000 [America/New_York]',
        '19970902T150000 [America/New_York]',
        '19970902T152000 [America/New_York]',
        '19970902T154000 [America/New_York]',
        '19970902T160000 [America/New_York]',
        '19970902T162000 [America/New_York]',
        '19970902T164000 [America/New_York]',
        '19970903T090000 [America/New_York]',
      ];

      expectOccurrences(actual, expected);
      expectOccurrences(actual2, expected);
    });

    test('Days generated makes a difference because of WKST=MO', () {
      final actual = getOccurrences([
        'DTSTART;TZID=America/New_York:19970805T090000',
        'RRULE:FREQ=WEEKLY;INTERVAL=2;COUNT=4;BYDAY=TU,SU;WKST=MO',
      ]);

      expectOccurrences(actual, [
        '19970805T090000 [America/New_York]',
        '19970810T090000 [America/New_York]',
        '19970819T090000 [America/New_York]',
        '19970824T090000 [America/New_York]',
      ]);
    });

    test('Days generated makes a difference because of WKST=SU', () {
      final actual = getOccurrences([
        'DTSTART;TZID=America/New_York:19970805T090000',
        'RRULE:FREQ=WEEKLY;INTERVAL=2;COUNT=4;BYDAY=TU,SU;WKST=SU',
      ]);

      expectOccurrences(actual, [
        '19970805T090000 [America/New_York]',
        '19970817T090000 [America/New_York]',
        '19970819T090000 [America/New_York]',
        '19970831T090000 [America/New_York]',
      ]);
    });

    test('Ignore invalid date (i.e., February 30)', () {
      final actual = getOccurrences([
        'DTSTART;TZID=America/New_York:20070115T090000',
        'RRULE:FREQ=MONTHLY;BYMONTHDAY=15,30;COUNT=5',
      ]);

      expectOccurrences(actual, [
        '20070115T090000 [America/New_York]',
        '20070130T090000 [America/New_York]',
        '20070215T090000 [America/New_York]',
        '20070315T090000 [America/New_York]',
        '20070330T090000 [America/New_York]',
      ]);
    });
  });
}
