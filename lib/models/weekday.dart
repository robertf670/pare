/// Enum representing all days of the week for task management
/// Includes all seven days to support comprehensive scheduling
enum Weekday {
  monday(1, 'Monday', 'MON'),
  tuesday(2, 'Tuesday', 'TUE'),
  wednesday(3, 'Wednesday', 'WED'),
  thursday(4, 'Thursday', 'THU'),
  friday(5, 'Friday', 'FRI'),
  saturday(6, 'Saturday', 'SAT'),
  sunday(7, 'Sunday', 'SUN');

  const Weekday(this.dayNumber, this.fullName, this.shortName);

  /// The day number (1-7, where 1 is Monday)
  final int dayNumber;
  
  /// Full day name (e.g., "Monday")
  final String fullName;
  
  /// Short day name (e.g., "MON")
  final String shortName;

  /// Check if this is a weekend day
  bool get isWeekend => this == saturday || this == sunday;

  /// Check if this is a weekday (Monday-Friday)
  bool get isWeekday => !isWeekend;

  /// Get the current weekday from DateTime
  static Weekday fromDateTime(DateTime date) {
    switch (date.weekday) {
      case 1:
        return Weekday.monday;
      case 2:
        return Weekday.tuesday;
      case 3:
        return Weekday.wednesday;
      case 4:
        return Weekday.thursday;
      case 5:
        return Weekday.friday;
      case 6:
        return Weekday.saturday;
      case 7:
        return Weekday.sunday;
      default:
        // This should never happen, but default to Monday
        return Weekday.monday;
    }
  }

  /// Get today's weekday
  static Weekday get today => fromDateTime(DateTime.now());

  /// Check if this weekday is today
  bool get isToday => this == today;

  /// Get the next weekday (wraps from Sunday to Monday)
  Weekday get next {
    switch (this) {
      case Weekday.monday:
        return Weekday.tuesday;
      case Weekday.tuesday:
        return Weekday.wednesday;
      case Weekday.wednesday:
        return Weekday.thursday;
      case Weekday.thursday:
        return Weekday.friday;
      case Weekday.friday:
        return Weekday.saturday;
      case Weekday.saturday:
        return Weekday.sunday;
      case Weekday.sunday:
        return Weekday.monday;
    }
  }

  /// Get the previous weekday (wraps from Monday to Sunday)
  Weekday get previous {
    switch (this) {
      case Weekday.monday:
        return Weekday.sunday;
      case Weekday.tuesday:
        return Weekday.monday;
      case Weekday.wednesday:
        return Weekday.tuesday;
      case Weekday.thursday:
        return Weekday.wednesday;
      case Weekday.friday:
        return Weekday.thursday;
      case Weekday.saturday:
        return Weekday.friday;
      case Weekday.sunday:
        return Weekday.saturday;
    }
  }

  /// Convert this weekday to a DateTime for the current week
  DateTime toDateTime() {
    final now = DateTime.now();
    final currentWeekday = now.weekday;
    final daysToAdd = dayNumber - currentWeekday;
    return DateTime(now.year, now.month, now.day).add(Duration(days: daysToAdd));
  }

  /// Get all weekdays as a list
  static List<Weekday> get all => [monday, tuesday, wednesday, thursday, friday, saturday, sunday];

  /// Get only work weekdays (Monday-Friday)
  static List<Weekday> get workDays => [monday, tuesday, wednesday, thursday, friday];

  /// Get only weekend days (Saturday-Sunday)
  static List<Weekday> get weekendDays => [saturday, sunday];
} 