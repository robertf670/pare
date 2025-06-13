import 'package:intl/intl.dart';
import '../models/weekday.dart';

/// Utility functions for date handling in the task management app
class DateUtils {
  // Private constructor to prevent instantiation
  DateUtils._();

  /// Format a DateTime to display time (e.g., "9:41")
  static String formatTime(DateTime dateTime) {
    return DateFormat('H:mm').format(dateTime);
  }

  /// Format a DateTime to display day and date (e.g., "MONDAY, October 06 2025")
  static String formatDayDate(DateTime dateTime) {
    return DateFormat('EEEE, MMMM dd yyyy').format(dateTime).toUpperCase();
  }

  /// Format a DateTime to display just the date (e.g., "Oct 06")
  static String formatShortDate(DateTime dateTime) {
    return DateFormat('MMM dd').format(dateTime);
  }

  /// Format a DateTime to display relative date (e.g., "Today", "Yesterday", "Oct 06")
  static String formatRelativeDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    final difference = targetDate.difference(today).inDays;
    
    switch (difference) {
      case 0:
        return 'Today';
      case 1:
        return 'Tomorrow';
      case -1:
        return 'Yesterday';
      default:
        return formatShortDate(dateTime);
    }
  }

  /// Get the start of the day (00:00:00) for a given DateTime
  static DateTime startOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Get the end of the day (23:59:59.999) for a given DateTime
  static DateTime endOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59, 999);
  }

  /// Check if two DateTime objects are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return startOfDay(date1).isAtSameMomentAs(startOfDay(date2));
  }

  /// Check if a DateTime is today
  static bool isToday(DateTime dateTime) {
    return isSameDay(dateTime, DateTime.now());
  }

  /// Check if a DateTime is yesterday
  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(dateTime, yesterday);
  }

  /// Check if a DateTime is tomorrow
  static bool isTomorrow(DateTime dateTime) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(dateTime, tomorrow);
  }

  /// Get the current week's Monday
  static DateTime getCurrentMonday() {
    final now = DateTime.now();
    final daysFromMonday = now.weekday - 1;
    return startOfDay(now.subtract(Duration(days: daysFromMonday)));
  }

  /// Get the current week's Friday
  static DateTime getCurrentFriday() {
    final monday = getCurrentMonday();
    return monday.add(const Duration(days: 4));
  }

  /// Get all weekdays for the current week
  static List<DateTime> getCurrentWeekDays() {
    final monday = getCurrentMonday();
    return List.generate(5, (index) => monday.add(Duration(days: index)));
  }

  /// Convert a Weekday enum to DateTime for the current week
  static DateTime weekdayToDateTime(Weekday weekday) {
    final monday = getCurrentMonday();
    return monday.add(Duration(days: weekday.dayNumber - 1));
  }

  /// Convert a DateTime to Weekday enum (returns Monday for weekends)
  static Weekday dateTimeToWeekday(DateTime dateTime) {
    return Weekday.fromDateTime(dateTime);
  }

  /// Check if a DateTime is a weekday (Monday-Friday)
  static bool isWeekday(DateTime dateTime) {
    final weekday = dateTime.weekday;
    return weekday >= 1 && weekday <= 5; // Monday = 1, Friday = 5
  }

  /// Check if a DateTime is a weekend (Saturday-Sunday)
  static bool isWeekend(DateTime dateTime) {
    return !isWeekday(dateTime);
  }

  /// Get the next weekday (skips weekends)
  static DateTime getNextWeekday(DateTime dateTime) {
    DateTime nextDay = dateTime.add(const Duration(days: 1));
    while (isWeekend(nextDay)) {
      nextDay = nextDay.add(const Duration(days: 1));
    }
    return startOfDay(nextDay);
  }

  /// Get the previous weekday (skips weekends)
  static DateTime getPreviousWeekday(DateTime dateTime) {
    DateTime previousDay = dateTime.subtract(const Duration(days: 1));
    while (isWeekend(previousDay)) {
      previousDay = previousDay.subtract(const Duration(days: 1));
    }
    return startOfDay(previousDay);
  }

  /// Get a human-readable time since/until description
  static String getTimeDescription(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.isNegative) {
      // Past
      final duration = difference.abs();
      if (duration.inDays > 0) {
        return '${duration.inDays} day${duration.inDays == 1 ? '' : 's'} ago';
      } else if (duration.inHours > 0) {
        return '${duration.inHours} hour${duration.inHours == 1 ? '' : 's'} ago';
      } else if (duration.inMinutes > 0) {
        return '${duration.inMinutes} minute${duration.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'Just now';
      }
    } else {
      // Future
      if (difference.inDays > 0) {
        return 'In ${difference.inDays} day${difference.inDays == 1 ? '' : 's'}';
      } else if (difference.inHours > 0) {
        return 'In ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}';
      } else if (difference.inMinutes > 0) {
        return 'In ${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'}';
      } else {
        return 'Now';
      }
    }
  }

  /// Get Monday for any given week offset (0 = current week, -1 = last week, +1 = next week)
  static DateTime getMondayForWeekOffset(int weekOffset) {
    final currentMonday = getCurrentMonday();
    return currentMonday.add(Duration(days: weekOffset * 7));
  }

  /// Get Friday for any given week offset
  static DateTime getFridayForWeekOffset(int weekOffset) {
    final monday = getMondayForWeekOffset(weekOffset);
    return monday.add(const Duration(days: 4));
  }

  /// Get all weekdays for a specific week offset
  static List<DateTime> getWeekDaysForOffset(int weekOffset) {
    final monday = getMondayForWeekOffset(weekOffset);
    return List.generate(5, (index) => monday.add(Duration(days: index)));
  }

  /// Calculate week offset between two dates
  static int getWeekOffset(DateTime fromDate, DateTime toDate) {
    final fromMonday = getMondayForDate(fromDate);
    final toMonday = getMondayForDate(toDate);
    final difference = toMonday.difference(fromMonday);
    return (difference.inDays / 7).round();
  }

  /// Get Monday for any specific date
  static DateTime getMondayForDate(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return startOfDay(date.subtract(Duration(days: daysFromMonday)));
  }

  /// Check if a date is in the current week
  static bool isInCurrentWeek(DateTime date) {
    final currentMonday = getCurrentMonday();
    final currentFriday = getCurrentFriday();
    final checkDate = startOfDay(date);
    
    return !checkDate.isBefore(currentMonday) && !checkDate.isAfter(currentFriday);
  }

  /// Get week number within the year (ISO 8601)
  static int getWeekNumber(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final firstMondayOffset = (startOfYear.weekday - 1) % 7;
    final firstMonday = startOfYear.subtract(Duration(days: firstMondayOffset));
    
    final difference = date.difference(firstMonday);
    return (difference.inDays / 7).floor() + 1;
  }

  /// Format week range display (e.g., "Dec 23 - Dec 29")
  static String formatWeekRange(DateTime mondayDate) {
    final friday = mondayDate.add(const Duration(days: 4));
    
    if (mondayDate.month == friday.month) {
      // Same month: "Dec 23 - 29"
      return '${formatShortDate(mondayDate)} - ${friday.day}';
    } else {
      // Different months: "Dec 30 - Jan 3"
      return '${formatShortDate(mondayDate)} - ${formatShortDate(friday)}';
    }
  }
} 