import 'package:firstfloor_calendar/firstfloor_calendar.dart';
import 'package:test/test.dart';

void main() {
  group('AlarmAction', () {
    test('toName returns correct string', () {
      expect(AlarmAction.audio.toName(), 'AUDIO');
      expect(AlarmAction.display.toName(), 'DISPLAY');
      expect(AlarmAction.email.toName(), 'EMAIL');
      expect(AlarmAction.procedure.toName(), 'PROCEDURE');
    });

    test('tryParse returns correct enum value', () {
      expect(AlarmActionNames.tryParse('AUDIO'), AlarmAction.audio);
      expect(AlarmActionNames.tryParse('DISPLAY'), AlarmAction.display);
      expect(AlarmActionNames.tryParse('EMAIL'), AlarmAction.email);
      expect(AlarmActionNames.tryParse('PROCEDURE'), AlarmAction.procedure);
      expect(AlarmActionNames.tryParse('audio'), AlarmAction.audio);
      expect(AlarmActionNames.tryParse('INVALID'), isNull);
    });
  });

  group('CalendarUserType', () {
    test('toName returns correct string', () {
      expect(CalendarUserType.individual.toName(), 'INDIVIDUAL');
      expect(CalendarUserType.group.toName(), 'GROUP');
      expect(CalendarUserType.resource.toName(), 'RESOURCE');
      expect(CalendarUserType.room.toName(), 'ROOM');
      expect(CalendarUserType.unknown.toName(), 'UNKNOWN');
    });

    test('tryParse returns correct enum value', () {
      expect(
        CalendarUserTypeNames.tryParse('INDIVIDUAL'),
        CalendarUserType.individual,
      );
      expect(CalendarUserTypeNames.tryParse('GROUP'), CalendarUserType.group);
      expect(
        CalendarUserTypeNames.tryParse('RESOURCE'),
        CalendarUserType.resource,
      );
      expect(CalendarUserTypeNames.tryParse('ROOM'), CalendarUserType.room);
      expect(
        CalendarUserTypeNames.tryParse('UNKNOWN'),
        CalendarUserType.unknown,
      );
      expect(
        CalendarUserTypeNames.tryParse('individual'),
        CalendarUserType.individual,
      );
      expect(CalendarUserTypeNames.tryParse('INVALID'), isNull);
    });
  });

  group('Classification', () {
    test('toName returns correct string', () {
      expect(Classification.public.toName(), 'PUBLIC');
      expect(Classification.private.toName(), 'PRIVATE');
      expect(Classification.confidential.toName(), 'CONFIDENTIAL');
    });

    test('tryParse returns correct enum value', () {
      expect(ClassificationNames.tryParse('PUBLIC'), Classification.public);
      expect(ClassificationNames.tryParse('PRIVATE'), Classification.private);
      expect(
        ClassificationNames.tryParse('CONFIDENTIAL'),
        Classification.confidential,
      );
      expect(ClassificationNames.tryParse('public'), Classification.public);
      expect(ClassificationNames.tryParse('INVALID'), isNull);
    });
  });

  group('EventStatus', () {
    test('toName returns correct string', () {
      expect(EventStatus.tentative.toName(), 'TENTATIVE');
      expect(EventStatus.confirmed.toName(), 'CONFIRMED');
      expect(EventStatus.cancelled.toName(), 'CANCELLED');
    });

    test('tryParse returns correct enum value', () {
      expect(EventStatusNames.tryParse('TENTATIVE'), EventStatus.tentative);
      expect(EventStatusNames.tryParse('CONFIRMED'), EventStatus.confirmed);
      expect(EventStatusNames.tryParse('CANCELLED'), EventStatus.cancelled);
      expect(EventStatusNames.tryParse('tentative'), EventStatus.tentative);
      expect(EventStatusNames.tryParse('INVALID'), isNull);
    });
  });

  group('FreeBusyType', () {
    test('toName returns correct string', () {
      expect(FreeBusyType.free.toName(), 'FREE');
      expect(FreeBusyType.busy.toName(), 'BUSY');
      expect(FreeBusyType.busyUnavailable.toName(), 'BUSY-UNAVAILABLE');
      expect(FreeBusyType.busyTentative.toName(), 'BUSY-TENTATIVE');
    });

    test('tryParse returns correct enum value', () {
      expect(FreeBusyTypeNames.tryParse('FREE'), FreeBusyType.free);
      expect(FreeBusyTypeNames.tryParse('BUSY'), FreeBusyType.busy);
      expect(
        FreeBusyTypeNames.tryParse('BUSY-UNAVAILABLE'),
        FreeBusyType.busyUnavailable,
      );
      expect(
        FreeBusyTypeNames.tryParse('BUSY-TENTATIVE'),
        FreeBusyType.busyTentative,
      );
      expect(FreeBusyTypeNames.tryParse('free'), FreeBusyType.free);
      expect(FreeBusyTypeNames.tryParse('INVALID'), isNull);
    });
  });

  group('JournalStatus', () {
    test('toName returns correct string', () {
      expect(JournalStatus.draft.toName(), 'DRAFT');
      expect(JournalStatus.final_.toName(), 'FINAL');
      expect(JournalStatus.amended.toName(), 'AMENDED');
    });

    test('tryParse returns correct enum value', () {
      expect(JournalStatusNames.tryParse('DRAFT'), JournalStatus.draft);
      expect(JournalStatusNames.tryParse('FINAL'), JournalStatus.final_);
      expect(JournalStatusNames.tryParse('AMENDED'), JournalStatus.amended);
      expect(JournalStatusNames.tryParse('draft'), JournalStatus.draft);
      expect(JournalStatusNames.tryParse('INVALID'), isNull);
    });
  });

  group('ParticipationStatus', () {
    test('toName returns correct string', () {
      expect(ParticipationStatus.needsAction.toName(), 'NEEDS-ACTION');
      expect(ParticipationStatus.accepted.toName(), 'ACCEPTED');
      expect(ParticipationStatus.declined.toName(), 'DECLINED');
      expect(ParticipationStatus.tentative.toName(), 'TENTATIVE');
      expect(ParticipationStatus.delegated.toName(), 'DELEGATED');
      expect(ParticipationStatus.completed.toName(), 'COMPLETED');
      expect(ParticipationStatus.inProcess.toName(), 'IN-PROCESS');
    });

    test('tryParse returns correct enum value', () {
      expect(
        ParticipationStatusNames.tryParse('NEEDS-ACTION'),
        ParticipationStatus.needsAction,
      );
      expect(
        ParticipationStatusNames.tryParse('ACCEPTED'),
        ParticipationStatus.accepted,
      );
      expect(
        ParticipationStatusNames.tryParse('DECLINED'),
        ParticipationStatus.declined,
      );
      expect(
        ParticipationStatusNames.tryParse('TENTATIVE'),
        ParticipationStatus.tentative,
      );
      expect(
        ParticipationStatusNames.tryParse('DELEGATED'),
        ParticipationStatus.delegated,
      );
      expect(
        ParticipationStatusNames.tryParse('COMPLETED'),
        ParticipationStatus.completed,
      );
      expect(
        ParticipationStatusNames.tryParse('IN-PROCESS'),
        ParticipationStatus.inProcess,
      );
      expect(
        ParticipationStatusNames.tryParse('needs-action'),
        ParticipationStatus.needsAction,
      );
      expect(ParticipationStatusNames.tryParse('INVALID'), isNull);
    });
  });

  group('ParticipationRole', () {
    test('toName returns correct string', () {
      expect(ParticipationRole.chair.toName(), 'CHAIR');
      expect(ParticipationRole.reqParticipant.toName(), 'REQ-PARTICIPANT');
      expect(ParticipationRole.optParticipant.toName(), 'OPT-PARTICIPANT');
      expect(ParticipationRole.nonParticipant.toName(), 'NON-PARTICIPANT');
    });

    test('tryParse returns correct enum value', () {
      expect(ParticipationRoleNames.tryParse('CHAIR'), ParticipationRole.chair);
      expect(
        ParticipationRoleNames.tryParse('REQ-PARTICIPANT'),
        ParticipationRole.reqParticipant,
      );
      expect(
        ParticipationRoleNames.tryParse('OPT-PARTICIPANT'),
        ParticipationRole.optParticipant,
      );
      expect(
        ParticipationRoleNames.tryParse('NON-PARTICIPANT'),
        ParticipationRole.nonParticipant,
      );
      expect(ParticipationRoleNames.tryParse('chair'), ParticipationRole.chair);
      expect(ParticipationRoleNames.tryParse('INVALID'), isNull);
    });
  });

  group('RecurrenceFrequency', () {
    test('toName returns correct string', () {
      expect(RecurrenceFrequency.secondly.toName(), 'SECONDLY');
      expect(RecurrenceFrequency.minutely.toName(), 'MINUTELY');
      expect(RecurrenceFrequency.hourly.toName(), 'HOURLY');
      expect(RecurrenceFrequency.daily.toName(), 'DAILY');
      expect(RecurrenceFrequency.weekly.toName(), 'WEEKLY');
      expect(RecurrenceFrequency.monthly.toName(), 'MONTHLY');
      expect(RecurrenceFrequency.yearly.toName(), 'YEARLY');
    });

    test('tryParse returns correct enum value', () {
      expect(
        RecurrenceFrequencyNames.tryParse('SECONDLY'),
        RecurrenceFrequency.secondly,
      );
      expect(
        RecurrenceFrequencyNames.tryParse('MINUTELY'),
        RecurrenceFrequency.minutely,
      );
      expect(
        RecurrenceFrequencyNames.tryParse('HOURLY'),
        RecurrenceFrequency.hourly,
      );
      expect(
        RecurrenceFrequencyNames.tryParse('DAILY'),
        RecurrenceFrequency.daily,
      );
      expect(
        RecurrenceFrequencyNames.tryParse('WEEKLY'),
        RecurrenceFrequency.weekly,
      );
      expect(
        RecurrenceFrequencyNames.tryParse('MONTHLY'),
        RecurrenceFrequency.monthly,
      );
      expect(
        RecurrenceFrequencyNames.tryParse('YEARLY'),
        RecurrenceFrequency.yearly,
      );
      expect(
        RecurrenceFrequencyNames.tryParse('daily'),
        RecurrenceFrequency.daily,
      );
      expect(RecurrenceFrequencyNames.tryParse('INVALID'), isNull);
    });
  });

  group('RelationshipType', () {
    test('toName returns correct string', () {
      expect(RelationshipType.child.toName(), 'CHILD');
      expect(RelationshipType.parent.toName(), 'PARENT');
      expect(RelationshipType.sibling.toName(), 'SIBLING');
    });

    test('tryParse returns correct enum value', () {
      expect(RelationshipTypeNames.tryParse('CHILD'), RelationshipType.child);
      expect(RelationshipTypeNames.tryParse('PARENT'), RelationshipType.parent);
      expect(
        RelationshipTypeNames.tryParse('SIBLING'),
        RelationshipType.sibling,
      );
      expect(RelationshipTypeNames.tryParse('child'), RelationshipType.child);
      expect(RelationshipTypeNames.tryParse('INVALID'), isNull);
    });
  });

  group('TimeTransparency', () {
    test('toName returns correct string', () {
      expect(TimeTransparency.opaque.toName(), 'OPAQUE');
      expect(TimeTransparency.transparent.toName(), 'TRANSPARENT');
    });

    test('tryParse returns correct enum value', () {
      expect(TimeTransparencyNames.tryParse('OPAQUE'), TimeTransparency.opaque);
      expect(
        TimeTransparencyNames.tryParse('TRANSPARENT'),
        TimeTransparency.transparent,
      );
      expect(TimeTransparencyNames.tryParse('opaque'), TimeTransparency.opaque);
      expect(TimeTransparencyNames.tryParse('INVALID'), isNull);
    });
  });

  group('TodoStatus', () {
    test('toName returns correct string', () {
      expect(TodoStatus.needsAction.toName(), 'NEEDS-ACTION');
      expect(TodoStatus.completed.toName(), 'COMPLETED');
      expect(TodoStatus.inProcess.toName(), 'IN-PROCESS');
      expect(TodoStatus.cancelled.toName(), 'CANCELLED');
    });

    test('tryParse returns correct enum value', () {
      expect(TodoStatusNames.tryParse('NEEDS-ACTION'), TodoStatus.needsAction);
      expect(TodoStatusNames.tryParse('COMPLETED'), TodoStatus.completed);
      expect(TodoStatusNames.tryParse('IN-PROCESS'), TodoStatus.inProcess);
      expect(TodoStatusNames.tryParse('CANCELLED'), TodoStatus.cancelled);
      expect(TodoStatusNames.tryParse('needs-action'), TodoStatus.needsAction);
      expect(TodoStatusNames.tryParse('INVALID'), isNull);
    });
  });

  group('ValueType', () {
    test('toName returns correct string', () {
      expect(ValueType.binary.toName(), 'BINARY');
      expect(ValueType.boolean.toName(), 'BOOLEAN');
      expect(ValueType.calAddress.toName(), 'CAL-ADDRESS');
      expect(ValueType.date.toName(), 'DATE');
      expect(ValueType.dateTime.toName(), 'DATE-TIME');
      expect(ValueType.duration.toName(), 'DURATION');
      expect(ValueType.float.toName(), 'FLOAT');
      expect(ValueType.integer.toName(), 'INTEGER');
      expect(ValueType.period.toName(), 'PERIOD');
      expect(ValueType.recur.toName(), 'RECUR');
      expect(ValueType.text.toName(), 'TEXT');
      expect(ValueType.time.toName(), 'TIME');
      expect(ValueType.uri.toName(), 'URI');
      expect(ValueType.utcOffset.toName(), 'UTC-OFFSET');
    });

    test('tryParse returns correct enum value', () {
      expect(ValueTypeNames.tryParse('BINARY'), ValueType.binary);
      expect(ValueTypeNames.tryParse('BOOLEAN'), ValueType.boolean);
      expect(ValueTypeNames.tryParse('CAL-ADDRESS'), ValueType.calAddress);
      expect(ValueTypeNames.tryParse('DATE'), ValueType.date);
      expect(ValueTypeNames.tryParse('DATE-TIME'), ValueType.dateTime);
      expect(ValueTypeNames.tryParse('DURATION'), ValueType.duration);
      expect(ValueTypeNames.tryParse('FLOAT'), ValueType.float);
      expect(ValueTypeNames.tryParse('INTEGER'), ValueType.integer);
      expect(ValueTypeNames.tryParse('PERIOD'), ValueType.period);
      expect(ValueTypeNames.tryParse('RECUR'), ValueType.recur);
      expect(ValueTypeNames.tryParse('TEXT'), ValueType.text);
      expect(ValueTypeNames.tryParse('TIME'), ValueType.time);
      expect(ValueTypeNames.tryParse('URI'), ValueType.uri);
      expect(ValueTypeNames.tryParse('UTC-OFFSET'), ValueType.utcOffset);
      expect(ValueTypeNames.tryParse('binary'), ValueType.binary);
      expect(ValueTypeNames.tryParse('INVALID'), isNull);
    });
  });

  group('Weekday', () {
    test('toName returns correct string', () {
      expect(Weekday.su.toName(), 'SU');
      expect(Weekday.mo.toName(), 'MO');
      expect(Weekday.tu.toName(), 'TU');
      expect(Weekday.we.toName(), 'WE');
      expect(Weekday.th.toName(), 'TH');
      expect(Weekday.fr.toName(), 'FR');
      expect(Weekday.sa.toName(), 'SA');
    });

    test('tryParse returns correct enum value', () {
      expect(WeekdayNames.tryParse('SU'), Weekday.su);
      expect(WeekdayNames.tryParse('MO'), Weekday.mo);
      expect(WeekdayNames.tryParse('TU'), Weekday.tu);
      expect(WeekdayNames.tryParse('WE'), Weekday.we);
      expect(WeekdayNames.tryParse('TH'), Weekday.th);
      expect(WeekdayNames.tryParse('FR'), Weekday.fr);
      expect(WeekdayNames.tryParse('SA'), Weekday.sa);
      expect(WeekdayNames.tryParse('su'), Weekday.su);
      expect(WeekdayNames.tryParse('INVALID'), isNull);
    });
  });
}
