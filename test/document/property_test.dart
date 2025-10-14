import 'package:firstfloor_calendar/firstfloor_calendar.dart';
import 'package:test/test.dart';

void main() {
  group('Basic property parsing', () {
    test('Valid BEGIN', () {
      final property = DocumentParser.parseProperty('BEGIN:VCALENDAR');
      expect(property.name, 'BEGIN');
      expect(property.parameters, isEmpty);
      expect(property.value, 'VCALENDAR');
    });
    test('Valid VERSION', () {
      final property = DocumentParser.parseProperty('VERSION:2.0');
      expect(property.name, 'VERSION');
      expect(property.parameters, isEmpty);
      expect(property.value, '2.0');
    });
    test('Valid PRODID', () {
      final property = DocumentParser.parseProperty(
        'PRODID:RacingNews365 2025',
      );
      expect(property.name, 'PRODID');
      expect(property.parameters, isEmpty);
      expect(property.value, 'RacingNews365 2025');
    });
    test('Valid X-APPLE-CALENDAR-COLOR', () {
      final property = DocumentParser.parseProperty(
        'X-APPLE-CALENDAR-COLOR:#DC0E0E',
      );
      expect(property.name, 'X-APPLE-CALENDAR-COLOR');
      expect(property.parameters, isEmpty);
      expect(property.value, '#DC0E0E');
    });
    test('Valid RRULE', () {
      final property = DocumentParser.parseProperty(
        'RRULE:FREQ=YEARLY;INTERVAL=1;BYMONTH=3;BYDAY=-1SU',
      );
      expect(property.name, 'RRULE');
      expect(property.parameters, isEmpty);
      expect(property.value, 'FREQ=YEARLY;INTERVAL=1;BYMONTH=3;BYDAY=-1SU');
    });

    test('Valid LOCATION', () {
      final property = DocumentParser.parseProperty(
        'LOCATION:Shanghai International Circuit\\, shanghai',
      );
      expect(property.name, 'LOCATION');
      expect(property.parameters, isEmpty);
      expect(property.value, 'Shanghai International Circuit\\, shanghai');
    });

    test('Valid DTSTART with TZID param', () {
      final property = DocumentParser.parseProperty(
        'DTSTART;TZID=Europe/Amsterdam:20250314T023000',
      );
      expect(property.name, 'DTSTART');
      expect(property.parameters, {
        'TZID': ['Europe/Amsterdam'],
      });
      expect(property.value, '20250314T023000');
    });

    test('Valid ORGANIZER with quoted param', () {
      final property = DocumentParser.parseProperty(
        'ORGANIZER;CN="John Doe,Eng":mailto:jd@some.com',
      );
      expect(property.name, 'ORGANIZER');
      expect(property.parameters, {
        'CN': ['John Doe,Eng'],
      });
      expect(property.value, 'mailto:jd@some.com');
    });

    test('Valid ATTENDEE with multiple params', () {
      final property = DocumentParser.parseProperty(
        'ATTENDEE;RSVP=TRUE;ROLE=REQ-PARTICIPANT:mailto:jsmith@example.com',
      );
      expect(property.name, 'ATTENDEE');
      expect(property.parameters, {
        'RSVP': ['TRUE'],
        'ROLE': ['REQ-PARTICIPANT'],
      });
      expect(property.value, 'mailto:jsmith@example.com');
    });

    test('Valid RDATE with comma separated value', () {
      final property = DocumentParser.parseProperty(
        'RDATE;VALUE=DATE:19970304,19970504,19970704,19970904',
      );
      expect(property.name, 'RDATE');
      expect(property.parameters, {
        'VALUE': ['DATE'],
      });
      expect(property.value, '19970304,19970504,19970704,19970904');
    });

    test('Valid DESCRIPTION with quoted param and comma separated value', () {
      final property = DocumentParser.parseProperty(
        'DESCRIPTION;ALTREP="cid:part1.0001@example.org":The Fall\'98 Wild Wizards Conference - - Las Vegas\\, NV\\, USA',
      );
      expect(property.name, 'DESCRIPTION');
      expect(property.parameters, {
        'ALTREP': ['cid:part1.0001@example.org'],
      });
      expect(
        property.value,
        'The Fall\'98 Wild Wizards Conference - - Las Vegas\\, NV\\, USA',
      );
    });

    test('Valid ALTREP parameter in DESCRIPTION', () {
      final property = DocumentParser.parseProperty(
        'DESCRIPTION;ALTREP="CID:part3.msg.970415T083000@example.com":'
        'Project XYZ Review Meeting will include the following agenda'
        ' items: (a) Market Overview\\, (b) Finances\\, (c) Project Man'
        'agement',
      );
      expect(property.name, 'DESCRIPTION');
      expect(property.parameters, {
        'ALTREP': ['CID:part3.msg.970415T083000@example.com'],
      });
      expect(
        property.value,
        'Project XYZ Review Meeting will include the following agenda items: (a) Market Overview\\, (b) Finances\\, (c) Project Management',
      );
    });

    test('Valid CN parameter in ORGANIZER', () {
      final property = DocumentParser.parseProperty(
        'ORGANIZER;CN="John Smith":mailto:jsmith@example.com',
      );
      expect(property.name, 'ORGANIZER');
      expect(property.parameters, {
        'CN': ['John Smith'],
      });
      expect(property.value, 'mailto:jsmith@example.com');
    });

    test('Valid CUTYPE parameter in ATTENDEE', () {
      final property = DocumentParser.parseProperty(
        'ATTENDEE;CUTYPE=GROUP:mailto:ietf-calsch@example.org',
      );
      expect(property.name, 'ATTENDEE');
      expect(property.parameters, {
        'CUTYPE': ['GROUP'],
      });
      expect(property.value, 'mailto:ietf-calsch@example.org');
    });

    test('Valid DELEGATED-FROM parameter in ATTENDEE', () {
      final property = DocumentParser.parseProperty(
        'ATTENDEE;DELEGATED-FROM="mailto:jsmith@example.com":mailto:jdoe@example.com',
      );
      expect(property.name, 'ATTENDEE');
      expect(property.parameters, {
        'DELEGATED-FROM': ['mailto:jsmith@example.com'],
      });
      expect(property.value, 'mailto:jdoe@example.com');
    });

    test('Valid DELEGATED-TO parameter in ATTENDEE', () {
      final property = DocumentParser.parseProperty(
        'ATTENDEE;DELEGATED-TO="mailto:jdoe@example.com","mailto:jqpublic@example.com":mailto:jsmith@example.com',
      );
      expect(property.name, 'ATTENDEE');
      expect(property.parameters, {
        'DELEGATED-TO': [
          'mailto:jdoe@example.com',
          'mailto:jqpublic@example.com',
        ],
      });
      expect(property.value, 'mailto:jsmith@example.com');
    });

    test('Valid DIR parameter in ORGANIZER', () {
      final property = DocumentParser.parseProperty(
        'ORGANIZER;DIR="ldap://example.com:6666/o=ABC%20Industries,'
        ' c=US???(cn=Jim%20Dolittle)":mailto:jimdo@example.com',
      );
      expect(property.name, 'ORGANIZER');
      expect(property.parameters, {
        'DIR': [
          'ldap://example.com:6666/o=ABC%20Industries, c=US???(cn=Jim%20Dolittle)',
        ],
      });
      expect(property.value, 'mailto:jimdo@example.com');
    });

    test('Valid ENCODING parameter in ATTACH', () {
      final property = DocumentParser.parseProperty(
        'ATTACH;FMTTYPE=text/plain;ENCODING=BASE64;VALUE=BINARY:TG9yZW'
        '0gaXBzdW0gZG9sb3Igc2l0IGFtZXQsIGNvbnNlY3RldHVyIGFkaXBpc2ljaW'
        '5nIGVsaXQsIHNlZCBkbyBlaXVzbW9kIHRlbXBvciBpbmNpZGlkdW50IHV0IG'
        'xhYm9yZSBldCBkb2xvcmUgbWFnbmEgYWxpcXVhLiBVdCBlbmltIGFkIG1pbm'
        'ltIHZlbmlhbSwgcXVpcyBub3N0cnVkIGV4ZXJjaXRhdGlvbiB1bGxhbWNvIG'
        'xhYm9yaXMgbmlzaSB1dCBhbGlxdWlwIGV4IGVhIGNvbW1vZG8gY29uc2VxdW'
        'F0LiBEdWlzIGF1dGUgaXJ1cmUgZG9sb3IgaW4gcmVwcmVoZW5kZXJpdCBpbi'
        'B2b2x1cHRhdGUgdmVsaXQgZXNzZSBjaWxsdW0gZG9sb3JlIGV1IGZ1Z2lhdC'
        'BudWxsYSBwYXJpYXR1ci4gRXhjZXB0ZXVyIHNpbnQgb2NjYWVjYXQgY3VwaW'
        'RhdGF0IG5vbiBwcm9pZGVudCwgc3VudCBpbiBjdWxwYSBxdWkgb2ZmaWNpYS'
        'BkZXNlcnVudCBtb2xsaXQgYW5pbSBpZCBlc3QgbGFib3J1bS4=',
      );
      expect(property.name, 'ATTACH');
      expect(property.parameters, {
        'FMTTYPE': ['text/plain'],
        'ENCODING': ['BASE64'],
        'VALUE': ['BINARY'],
      });
      expect(
        property.value,
        'TG9yZW'
        '0gaXBzdW0gZG9sb3Igc2l0IGFtZXQsIGNvbnNlY3RldHVyIGFkaXBpc2ljaW'
        '5nIGVsaXQsIHNlZCBkbyBlaXVzbW9kIHRlbXBvciBpbmNpZGlkdW50IHV0IG'
        'xhYm9yZSBldCBkb2xvcmUgbWFnbmEgYWxpcXVhLiBVdCBlbmltIGFkIG1pbm'
        'ltIHZlbmlhbSwgcXVpcyBub3N0cnVkIGV4ZXJjaXRhdGlvbiB1bGxhbWNvIG'
        'xhYm9yaXMgbmlzaSB1dCBhbGlxdWlwIGV4IGVhIGNvbW1vZG8gY29uc2VxdW'
        'F0LiBEdWlzIGF1dGUgaXJ1cmUgZG9sb3IgaW4gcmVwcmVoZW5kZXJpdCBpbi'
        'B2b2x1cHRhdGUgdmVsaXQgZXNzZSBjaWxsdW0gZG9sb3JlIGV1IGZ1Z2lhdC'
        'BudWxsYSBwYXJpYXR1ci4gRXhjZXB0ZXVyIHNpbnQgb2NjYWVjYXQgY3VwaW'
        'RhdGF0IG5vbiBwcm9pZGVudCwgc3VudCBpbiBjdWxwYSBxdWkgb2ZmaWNpYS'
        'BkZXNlcnVudCBtb2xsaXQgYW5pbSBpZCBlc3QgbGFib3J1bS4=',
      );
    });

    test('Valid FMTTYPE parameter in ATTACH', () {
      final property = DocumentParser.parseProperty(
        'ATTACH;FMTTYPE=application/msword:ftp://example.com/pub/docs/agenda.doc',
      );
      expect(property.name, 'ATTACH');
      expect(property.parameters, {
        'FMTTYPE': ['application/msword'],
      });
      expect(property.value, 'ftp://example.com/pub/docs/agenda.doc');
    });

    test('Valid FBTYPE parameter in FREEBUSY', () {
      final property = DocumentParser.parseProperty(
        'FREEBUSY;FBTYPE=BUSY:19980415T133000Z/19980415T170000Z',
      );
      expect(property.name, 'FREEBUSY');
      expect(property.parameters, {
        'FBTYPE': ['BUSY'],
      });
      expect(property.value, '19980415T133000Z/19980415T170000Z');
    });

    test('Valid LANGUAGE parameter in SUMMARY', () {
      final property = DocumentParser.parseProperty(
        'SUMMARY;LANGUAGE=en-US:Company Holiday Party',
      );
      expect(property.name, 'SUMMARY');
      expect(property.parameters, {
        'LANGUAGE': ['en-US'],
      });
      expect(property.value, 'Company Holiday Party');
    });

    test('Valid LANGUAGE parameter in LOCATION', () {
      final property = DocumentParser.parseProperty(
        'LOCATION;LANGUAGE=en:Germany',
      );
      expect(property.name, 'LOCATION');
      expect(property.parameters, {
        'LANGUAGE': ['en'],
      });
      expect(property.value, 'Germany');
    });

    test('Valid LANGUAGE parameter in LOCATION (2)', () {
      final property = DocumentParser.parseProperty(
        'LOCATION;LANGUAGE=no:Tyskland',
      );
      expect(property.name, 'LOCATION');
      expect(property.parameters, {
        'LANGUAGE': ['no'],
      });
      expect(property.value, 'Tyskland');
    });

    test('Valid MEMBER parameter in ATTENDEE', () {
      final property = DocumentParser.parseProperty(
        'ATTENDEE;MEMBER="mailto:ietf-calsch@example.org":mailto:jsmith@example.com',
      );
      expect(property.name, 'ATTENDEE');
      expect(property.parameters, {
        'MEMBER': ['mailto:ietf-calsch@example.org'],
      });
      expect(property.value, 'mailto:jsmith@example.com');
    });

    test('Valid MEMBER parameter with multiple values in ATTENDEE', () {
      final property = DocumentParser.parseProperty(
        'ATTENDEE;MEMBER="mailto:projectA@example.com","mailto:pr'
        'ojectB@example.com":mailto:janedoe@example.com',
      );
      expect(property.name, 'ATTENDEE');
      expect(property.parameters, {
        'MEMBER': [
          'mailto:projectA@example.com',
          'mailto:projectB@example.com',
        ],
      });
      expect(property.value, 'mailto:janedoe@example.com');
    });

    test('Valid PARTSTAT parameter in ATTENDEE', () {
      final property = DocumentParser.parseProperty(
        'ATTENDEE;PARTSTAT=DECLINED:mailto:jsmith@example.com',
      );
      expect(property.name, 'ATTENDEE');
      expect(property.parameters, {
        'PARTSTAT': ['DECLINED'],
      });
      expect(property.value, 'mailto:jsmith@example.com');
    });

    test('Valid RANGE parameter in RECURRENCE-ID', () {
      final property = DocumentParser.parseProperty(
        'RECURRENCE-ID;RANGE=THISANDFUTURE:19980401T133000Z',
      );
      expect(property.name, 'RECURRENCE-ID');
      expect(property.parameters, {
        'RANGE': ['THISANDFUTURE'],
      });
      expect(property.value, '19980401T133000Z');
    });

    test('Valid RELATED parameter in TRIGGER', () {
      final property = DocumentParser.parseProperty('TRIGGER;RELATED=END:PT5M');
      expect(property.name, 'TRIGGER');
      expect(property.parameters, {
        'RELATED': ['END'],
      });
      expect(property.value, 'PT5M');
    });

    test('Valid RELTYPE parameter in RELATED-TO', () {
      final property = DocumentParser.parseProperty(
        'RELATED-TO;RELTYPE=SIBLING:19960401-080045-4000F192713@example.com',
      );
      expect(property.name, 'RELATED-TO');
      expect(property.parameters, {
        'RELTYPE': ['SIBLING'],
      });
      expect(property.value, '19960401-080045-4000F192713@example.com');
    });

    test('Valid ROLE parameter in ATTENDEE', () {
      final property = DocumentParser.parseProperty(
        'ATTENDEE;ROLE=CHAIR:mailto:mrbig@example.com',
      );
      expect(property.name, 'ATTENDEE');
      expect(property.parameters, {
        'ROLE': ['CHAIR'],
      });
      expect(property.value, 'mailto:mrbig@example.com');
    });

    test('Valid RSVP parameter in ATTENDEE', () {
      final property = DocumentParser.parseProperty(
        'ATTENDEE;RSVP=TRUE:mailto:jsmith@example.com',
      );
      expect(property.name, 'ATTENDEE');
      expect(property.parameters, {
        'RSVP': ['TRUE'],
      });
      expect(property.value, 'mailto:jsmith@example.com');
    });

    test('Valid SENT-BY parameter in ORGANIZER', () {
      final property = DocumentParser.parseProperty(
        'ORGANIZER;SENT-BY="mailto:sray@example.com":mailto:jsmith@example.com',
      );
      expect(property.name, 'ORGANIZER');
      expect(property.parameters, {
        'SENT-BY': ['mailto:sray@example.com'],
      });
      expect(property.value, 'mailto:jsmith@example.com');
    });

    test('Valid TZID parameter in DTSTART', () {
      final property = DocumentParser.parseProperty(
        'DTSTART;TZID=America/New_York:19980119T020000',
      );
      expect(property.name, 'DTSTART');
      expect(property.parameters, {
        'TZID': ['America/New_York'],
      });
      expect(property.value, '19980119T020000');
    });

    test('Valid TZID parameter in DTEND', () {
      final property = DocumentParser.parseProperty(
        'DTEND;TZID=America/New_York:19980119T030000',
      );
      expect(property.name, 'DTEND');
      expect(property.parameters, {
        'TZID': ['America/New_York'],
      });
      expect(property.value, '19980119T030000');
    });

    test('Valid BINARY datatype', () {
      final property = DocumentParser.parseProperty(
        'ATTACH;FMTTYPE=image/vnd.microsoft.icon;ENCODING=BASE64;VALUE'
        '=BINARY:AAABAAEAEBAQAAEABAAoAQAAFgAAACgAAAAQAAAAIAAAAAEABAAA'
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAAAAgIAAAICAgADAwMAA////AAAA'
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
        'AAAAAAAAAAAAAAAAAAAAAAMwAAAAAAABNEMQAAAAAAAkQgAAAAAAJEREQgAA'
        'ACECQ0QgEgAAQxQzM0E0AABERCRCREQAADRDJEJEQwAAAhA0QwEQAAAAAERE'
        'AAAAAAAAREQAAAAAAAAkQgAAAAAAAAMgAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
        'AAAAAAAAAAAA',
      );
      expect(property.name, 'ATTACH');
      expect(property.parameters, {
        'FMTTYPE': ['image/vnd.microsoft.icon'],
        'ENCODING': ['BASE64'],
        'VALUE': ['BINARY'],
      });
      expect(
        property.value,
        'AAABAAEAEBAQAAEABAAoAQAAFgAAACgAAAAQAAAAIAAAAAEABAAA'
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAAAAgIAAAICAgADAwMAA////AAAA'
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
        'AAAAAAAAAAAAAAAAAAAAAAMwAAAAAAABNEMQAAAAAAAkQgAAAAAAJEREQgAA'
        'ACECQ0QgEgAAQxQzM0E0AABERCRCREQAADRDJEJEQwAAAhA0QwEQAAAAAERE'
        'AAAAAAAAREQAAAAAAAAkQgAAAAAAAAMgAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
        'AAAAAAAAAAAA',
      );
    });

    test('Valid IANA property', () {
      final property = DocumentParser.parseProperty(
        'NON-SMOKING;VALUE=BOOLEAN:TRUE',
      );
      expect(property.name, 'NON-SMOKING');
      expect(property.parameters, {
        'VALUE': ['BOOLEAN'],
      });
      expect(property.value, 'TRUE');
    });

    test('Valid non-standard property', () {
      final property = DocumentParser.parseProperty(
        'X-ABC-MMSUBJ;VALUE=URI;FMTTYPE=audio/basic:http://www.example.org/mysubj.au',
      );
      expect(property.name, 'X-ABC-MMSUBJ');
      expect(property.parameters, {
        'VALUE': ['URI'],
        'FMTTYPE': ['audio/basic'],
      });
      expect(property.value, 'http://www.example.org/mysubj.au');
    });

    test('Valid lowercase name', () {
      final property = DocumentParser.parseProperty('abc:');
      expect(property.name, 'ABC');
      expect(property.parameters, isEmpty);
      expect(property.value, isEmpty);
    });

    test('Valid uppercase name', () {
      final property = DocumentParser.parseProperty('ABC:');
      expect(property.name, 'ABC');
      expect(property.parameters, isEmpty);
      expect(property.value, isEmpty);
    });

    test('Valid lower and uppercase name', () {
      final property = DocumentParser.parseProperty('aB:');
      expect(property.name, 'AB');
      expect(property.parameters, isEmpty);
      expect(property.value, isEmpty);
    });

    test('Valid digit name', () {
      final property = DocumentParser.parseProperty('123:');
      expect(property.name, '123');
      expect(property.parameters, isEmpty);
      expect(property.value, isEmpty);
    });

    test('Valid alphanumeric followed by digit name', () {
      final property = DocumentParser.parseProperty('A1:');
      expect(property.name, 'A1');
      expect(property.parameters, isEmpty);
      expect(property.value, isEmpty);
    });

    test('Valid digit followed by alphanumeric name', () {
      final property = DocumentParser.parseProperty('1A:');
      expect(property.name, '1A');
      expect(property.parameters, isEmpty);
      expect(property.value, isEmpty);
    });

    test('Valid hyphen name', () {
      final property = DocumentParser.parseProperty('-:');
      expect(property.name, '-');
      expect(property.parameters, isEmpty);
      expect(property.value, isEmpty);
    });

    test('Valid alphanumeric, hyphen and digit name', () {
      final property = DocumentParser.parseProperty('a-1:');
      expect(property.name, 'A-1');
      expect(property.parameters, isEmpty);
      expect(property.value, isEmpty);
    });

    test('Valid empty value', () {
      final property = DocumentParser.parseProperty('ABC:');
      expect(property.name, 'ABC');
      expect(property.parameters, isEmpty);
      expect(property.value, isEmpty);
    });

    test('Valid colon value', () {
      final property = DocumentParser.parseProperty('ABC::');
      expect(property.name, 'ABC');
      expect(property.parameters, isEmpty);
      expect(property.value, ':');
    });

    test('Valid value with ",=: characters', () {
      final property = DocumentParser.parseProperty('A::"B",=1');
      expect(property.name, 'A');
      expect(property.parameters, isEmpty);
      expect(property.value, ':"B",=1');
    });

    test('Valid single dquote value', () {
      final property = DocumentParser.parseProperty('A:"');
      expect(property.name, 'A');
      expect(property.parameters, isEmpty);
      expect(property.value, '"');
    });
    test('Valid double dquote value', () {
      final property = DocumentParser.parseProperty('A:""');
      expect(property.name, 'A');
      expect(property.parameters, isEmpty);
      expect(property.value, '""');
    });

    test('Valid empty param value', () {
      final property = DocumentParser.parseProperty('A;B=:C');
      expect(property.name, 'A');
      expect(property.parameters, {
        'B': [''],
      });
      expect(property.value, 'C');
    });

    test('Valid empty quoted param value', () {
      final property = DocumentParser.parseProperty('A;B="":C');
      expect(property.name, 'A');
      expect(property.parameters, {
        'B': [''],
      });
      expect(property.value, 'C');
    });

    test('Valid whitespace param value', () {
      final property = DocumentParser.parseProperty('A;B= :C');
      expect(property.name, 'A');
      expect(property.parameters, {
        'B': [' '],
      });
      expect(property.value, 'C');
    });

    test('Valid whitespace quoted param value', () {
      final property = DocumentParser.parseProperty('A;B=" ":C');
      expect(property.name, 'A');
      expect(property.parameters, {
        'B': [' '],
      });
      expect(property.value, 'C');
    });

    test('Valid whitespace before param value', () {
      final property = DocumentParser.parseProperty('A;B= 1:C');
      expect(property.name, 'A');
      expect(property.parameters, {
        'B': [' 1'],
      });
      expect(property.value, 'C');
    });

    test('Valid whitespace after param value ', () {
      final property = DocumentParser.parseProperty('A;B=1 :C');
      expect(property.name, 'A');
      expect(property.parameters, {
        'B': ['1 '],
      });
      expect(property.value, 'C');
    });

    test('Valid whitespace with multiple param values', () {
      final property = DocumentParser.parseProperty('A;B=1,2, 3,4 ,:C');
      expect(property.name, 'A');
      expect(property.parameters, {
        'B': ['1', '2', ' 3', '4 ', ''],
      });
      expect(property.value, 'C');
    });

    test('Valid multiple params', () {
      final property = DocumentParser.parseProperty('A;B="";C=;D="1";E="1":F');
      expect(property.name, 'A');
      expect(property.parameters, {
        'B': [''],
        'C': [''],
        'D': ['1'],
        'E': ['1'],
      });
      expect(property.value, 'F');
    });

    test('Valid multiple empty param values', () {
      final property = DocumentParser.parseProperty('A;B=,:C');
      expect(property.name, 'A');
      expect(property.parameters, {
        'B': ['', ''],
      });
      expect(property.value, 'C');
    });

    test('Valid multiple empty and non-empty param values', () {
      final property = DocumentParser.parseProperty('A;B=1,:C');
      expect(property.name, 'A');
      expect(property.parameters, {
        'B': ['1', ''],
      });
      expect(property.value, 'C');
    });

    test('Valid multiple empty quoted param values', () {
      final property = DocumentParser.parseProperty('A;B="","":C');
      expect(property.name, 'A');
      expect(property.parameters, {
        'B': ['', ''],
      });
      expect(property.value, 'C');
    });

    test('Valid multiple empty unquoted and quoted param values', () {
      final property = DocumentParser.parseProperty('A;B=,"":C');
      expect(property.name, 'A');
      expect(property.parameters, {
        'B': ['', ''],
      });
      expect(property.value, 'C');
    });

    test('Valid multiple whitespace unquoted and quoted param values', () {
      final property = DocumentParser.parseProperty('A;B= ," ",\t,"\t":C');
      expect(property.name, 'A');
      expect(property.parameters, {
        'B': [' ', ' ', '\t', '\t'],
      });
      expect(property.value, 'C');
    });

    test('Valid multiple unquoted param values', () {
      final property = DocumentParser.parseProperty('A;B=1,2:C');
      expect(property.name, 'A');
      expect(property.parameters, {
        'B': ['1', '2'],
      });
      expect(property.value, 'C');
    });

    test('Valid multiple quoted param values', () {
      final property = DocumentParser.parseProperty('A;B="1","2":C');
      expect(property.name, 'A');
      expect(property.parameters, {
        'B': ['1', '2'],
      });
      expect(property.value, 'C');
    });

    test('Valid multiple empty and non-empty quoted param values', () {
      final property = DocumentParser.parseProperty('A;B="1","":C');
      expect(property.name, 'A');
      expect(property.parameters, {
        'B': ['1', ''],
      });
      expect(property.value, 'C');
    });

    test('Valid multiple param values', () {
      final property = DocumentParser.parseProperty('A;B=,1,"","1":C');
      expect(property.name, 'A');
      expect(property.parameters, {
        'B': ['', '1', '', '1'],
      });
      expect(property.value, 'C');
    });

    test('Valid multiple params and multiple param values', () {
      final property = DocumentParser.parseProperty(
        'A;B=;C=1;D="";E="1";F=,1,"","1":G',
      );
      expect(property.name, 'A');
      expect(property.parameters, {
        'B': [''],
        'C': ['1'],
        'D': [''],
        'E': ['1'],
        'F': ['', '1', '', '1'],
      });
      expect(property.value, 'G');
    });
  });

  group('Basic property parsing errors', () {
    test('Empty string should throw', () {
      expect(
        () => DocumentParser.parseProperty(''),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Empty name found [Ln 0, Col 0]',
          ),
        ),
      );
    });

    test('White space should throw', () {
      expect(
        () => DocumentParser.parseProperty(' '),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Empty name found [Ln 0, Col 0]',
          ),
        ),
      );
    });

    test('LF should throw', () {
      expect(
        () => DocumentParser.parseProperty('\n'),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Empty name found [Ln 0, Col 0]',
          ),
        ),
      );
    });

    test('CRLF should throw', () {
      expect(
        () => DocumentParser.parseProperty('\r\n'),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Empty name found [Ln 0, Col 0]',
          ),
        ),
      );
    });

    test('Missing value should throw', () {
      expect(
        () => DocumentParser.parseProperty('abc'),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Expected one of [":", ";"], found "<endOfLine>" [Ln 0, Col 3]',
          ),
        ),
      );
    });

    test('Empty name without value should throw', () {
      expect(
        () => DocumentParser.parseProperty(':abc'),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Empty name found [Ln 0, Col 0]',
          ),
        ),
      );
    });

    test('Empty name should throw', () {
      expect(
        () => DocumentParser.parseProperty(':abc:'),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Empty name found [Ln 0, Col 0]',
          ),
        ),
      );
    });

    test('Empty parameter and missing value should throw', () {
      expect(
        () => DocumentParser.parseProperty('abc;'),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Expected ":", found "<endOfLine>" [Ln 0, Col 4]',
          ),
        ),
      );
    });

    test('CR in content line should throw', () {
      expect(
        () => DocumentParser.parseProperty('A:B\n'),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Expected "<endOfLine>", found "\n" [Ln 0, Col 3]',
          ),
        ),
      );
    });

    test('Param without equals and param value should throw', () {
      expect(
        () => DocumentParser.parseProperty('A;B:C'),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Expected "=", found ":" [Ln 0, Col 3]',
          ),
        ),
      );
    });

    test('Empty param should throw', () {
      expect(
        () => DocumentParser.parseProperty('A;:'),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Empty name found [Ln 0, Col 2]',
          ),
        ),
      );
    });
    test('Property with params without value should throw"', () {
      expect(
        () => DocumentParser.parseProperty('A;B=1;C=2;'),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Expected ":", found "<endOfLine>" [Ln 0, Col 10]',
          ),
        ),
      );
    });

    test('Missing param value end quote should throw', () {
      expect(
        () => DocumentParser.parseProperty('A;B="1:'),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Expected """, found "<endOfLine>" [Ln 0, Col 7]',
          ),
        ),
      );
    });

    test('Quoted param name should throw', () {
      expect(
        () => DocumentParser.parseProperty('A;"B"=1:'),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Empty name found [Ln 0, Col 2]',
          ),
        ),
      );
    });

    test('Duplicate param name should throw', () {
      expect(
        () => DocumentParser.parseProperty('A;B=1;B=2:C'),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Duplicate parameter name "B" found [Ln 0, Col 6]',
          ),
        ),
      );
    });

    test('Duplicate param name in different case should throw', () {
      expect(
        () => DocumentParser.parseProperty('A;B=1;b=2:C'),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Duplicate parameter name "B" found [Ln 0, Col 6]',
          ),
        ),
      );
    });

    test('Invalid name character should throw', () {
      expect(
        () => DocumentParser.parseProperty('A@B:C'),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Expected one of [":", ";"], found "@" [Ln 0, Col 1]',
          ),
        ),
      );
    });

    test('Invalid underscore character in name should throw', () {
      expect(
        () => DocumentParser.parseProperty('A_B:C'),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Expected one of [":", ";"], found "_" [Ln 0, Col 1]',
          ),
        ),
      );
    });

    test('Invalid param name character should throw', () {
      expect(
        () => DocumentParser.parseProperty('A;B@=1:C'),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Expected "=", found "@" [Ln 0, Col 3]',
          ),
        ),
      );
    });

    test('Invalid param value character should throw', () {
      expect(
        () => DocumentParser.parseProperty('A;B=1@C'),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Expected ":", found "<endOfLine>" [Ln 0, Col 7]',
          ),
        ),
      );
    });

    test('Invalid whitespace before name should throw', () {
      expect(
        () => DocumentParser.parseProperty(' A:B'),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Empty name found [Ln 0, Col 0]',
          ),
        ),
      );
    });

    test('Invalid whitespace after name should throw', () {
      expect(
        () => DocumentParser.parseProperty('A :B'),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Expected one of [":", ";"], found " " [Ln 0, Col 1]',
          ),
        ),
      );
    });

    test('Invalid whitespace before param name should throw', () {
      expect(
        () => DocumentParser.parseProperty('A; B=1:C'),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Empty name found [Ln 0, Col 2]',
          ),
        ),
      );
    });

    test('Invalid whitespace after param name should throw', () {
      expect(
        () => DocumentParser.parseProperty('A;B =1:C'),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Expected "=", found " " [Ln 0, Col 3]',
          ),
        ),
      );
    });

    test('Invalid whitespace before quoted param value should throw', () {
      expect(
        () => DocumentParser.parseProperty('A;B= "1":C'),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Expected ":", found """ [Ln 0, Col 5]',
          ),
        ),
      );
    });

    test('Invalid whitespace after quoted param value should throw', () {
      expect(
        () => DocumentParser.parseProperty('A;B="1" :C'),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Expected ":", found " " [Ln 0, Col 7]',
          ),
        ),
      );
    });

    test('Updating property parameters should throw', () {
      final property = DocumentParser.parseProperty('A:B');

      expect(
        () => property.parameters.clear(),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'Unsupported operation: Cannot modify unmodifiable map',
          ),
        ),
      );
    });
  });
}
