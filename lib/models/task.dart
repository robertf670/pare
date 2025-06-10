import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.date,
    required this.createdAt,
    this.completedAt,
  });

  /// Create a copy of this task with some fields updated
  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? date,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Toggle the completion status of this task
  Task toggleCompletion() {
    return copyWith(
      isCompleted: !isCompleted,
      completedAt: !isCompleted ? DateTime.now() : null,
    );
  }

  /// Check if this task is for today
  bool get isForToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);
    return taskDate.isAtSameMomentAs(today);
  }

  /// Check if this task is for a specific date
  bool isForDate(DateTime targetDate) {
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final taskDate = DateTime(date.year, date.month, date.day);
    return taskDate.isAtSameMomentAs(target);
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, isCompleted: $isCompleted, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 