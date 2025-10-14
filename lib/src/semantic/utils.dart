import 'semantic.dart';

/// Utility class for date-related calculations.
class DateUtils {
  /// Number of days in each month for a non-leap year.
  static const daysInMonths = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

  /// Determines if the given year is a leap year.
  static bool isLeapYear(int year) {
    if (year % 4 != 0) return false;
    if (year % 100 != 0) return true;
    if (year % 400 != 0) return false;
    return true;
  }

  /// Returns the total number of days in the given year.
  static int totalDaysInYear(int year) {
    return isLeapYear(year) ? 366 : 365;
  }

  /// Returns the total number of days in the given month of the specified year.
  static int totalDaysInMonth(int year, int month) {
    if (month == 2 && isLeapYear(year)) {
      return 29;
    }

    return daysInMonths[month - 1];
  }

  /// Returns the start of the week for the given [date] based on the specified
  /// [weekStart] day.
  static CalDateTime startOfWeek(CalDateTime date, Weekday weekStart) {
    if (date.weekday == weekStart) {
      return date;
    }
    // Calculate days to go back: always go backward to find week start
    final daysBack = (date.weekday.index - weekStart.index + 7) % 7;
    return date.add(days: -daysBack);
  }

  /// Computes how many occurrences of the specified [weekday] are in the given
  /// [month] of the specified [year].
  static int numberOfWeekdaysInMonth(int year, int month, Weekday weekday) {
    final firstOfMonth = CalDateTime.date(year, month, 1);
    final daysInMonth = totalDaysInMonth(year, month);

    // Calculate days from first of month to first occurrence of target weekday
    final toFirst = (weekday.index - firstOfMonth.weekday.index + 7) % 7;

    // Calculate remaining days after first occurrence
    final remaining = daysInMonth - toFirst - 1;

    // Number of occurrences = 1 (first) + number of complete weeks remaining
    return 1 + (remaining / 7).floor();
  }

  /// Computes how many occurrences of the specified [weekday] are in the given
  /// [year].
  static int numberOfWeekdaysInYear(int year, Weekday weekday) {
    final firstOfYear = CalDateTime.date(year, 1, 1);
    final daysInYear = totalDaysInYear(year);

    // Calculate days from first of year to first occurrence of target weekday
    final toFirst = (weekday.index - firstOfYear.weekday.index + 7) % 7;

    // Calculate remaining days after first occurrence
    final remaining = daysInYear - toFirst - 1;

    // Number of occurrences = 1 (first) + number of complete weeks remaining
    return 1 + (remaining / 7).floor();
  }
}
