# Changelog

All notable changes to this project will be documented in this file.

## [1.0.2] - 2025-11-05

### Fixed
- Fixed `resources` property type from `List<CalendarUserAddress>` to `List<String>` and use `valuesUnion()` for RFC 5545 compliance

### Improved
- Significantly increased test coverage

## [1.0.1] - 2025-10-26

### Fixed
- Updated README examples to use correct API methods (`parseComponents` instead of deprecated `streamComponents`)
- Added missing required `DTSTAMP` properties in README examples for RFC 5545 compliance

### Improved
- Enhanced documentation comments across public APIs for better clarity and consistency

## [1.0.0] - 2025-10-15

### Added
- RFC 5545 compliant iCalendar parser
- Support for VEVENT, VTODO, VJOURNAL, VTIMEZONE components
- Full RRULE recurrence expansion
- Streaming parser for large files
- Custom property parser registration
- Timezone-aware date/time handling
- Two-layer architecture (document + semantic)

[1.0.2]: https://github.com/firstfloorsoftware/firstfloor_calendar/releases/tag/v1.0.2
[1.0.1]: https://github.com/firstfloorsoftware/firstfloor_calendar/releases/tag/v1.0.1
[1.0.0]: https://github.com/firstfloorsoftware/firstfloor_calendar/releases/tag/v1.0.0