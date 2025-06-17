import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

/// Service class for managing tasks
/// Handles all task-related operations including storage, retrieval, and manipulation
class TaskService {
  static const String _tasksBoxName = 'tasks';
  static Box<Task>? _tasksBox;

  /// Initialize Hive and open the tasks box
  static Future<void> initialize() async {
    try {
      await Hive.initFlutter();
      
      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(TaskAdapter());
      }
      
      // Open the tasks box
      _tasksBox = await Hive.openBox<Task>(_tasksBoxName);
    } catch (e) {
      throw Exception('Failed to initialize storage: ${e.toString()}');
    }
  }

  /// Get the tasks box (ensure it's initialized)
  static Box<Task> get _box {
    if (_tasksBox == null || !_tasksBox!.isOpen) {
      throw Exception('TaskService not initialized. Call TaskService.initialize() first.');
    }
    return _tasksBox!;
  }

  /// Create a new task
  static Future<Task> createTask({
    required String title,
    required DateTime date,
  }) async {
    try {
      if (title.trim().isEmpty) {
        throw ArgumentError('Task title cannot be empty');
      }

      final task = Task(
        id: _generateId(),
        title: title.trim(),
        date: date,
        createdAt: DateTime.now(),
      );
      
      await _box.put(task.id, task);
      return task;
    } catch (e) {
      throw Exception('Failed to create task: ${e.toString()}');
    }
  }

  /// Get all tasks
  static List<Task> getAllTasks() {
    return _box.values.toList();
  }

  /// Get tasks for a specific date
  static List<Task> getTasksForDate(DateTime date) {
    return _box.values
        .where((task) => task.isForDate(date))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Get tasks for today
  static List<Task> getTodaysTasks() {
    return getTasksForDate(DateTime.now());
  }

  /// Update a task
  static Future<void> updateTask(Task updatedTask) async {
    await _box.put(updatedTask.id, updatedTask);
  }

  /// Toggle task completion
  static Future<Task> toggleTaskCompletion(String taskId) async {
    final task = _box.get(taskId);
    if (task == null) {
      throw Exception('Task not found: $taskId');
    }
    
    final updatedTask = task.toggleCompletion();
    await updateTask(updatedTask);
    return updatedTask;
  }

  /// Delete a task
  static Future<void> deleteTask(String taskId) async {
    await _box.delete(taskId);
  }

  /// Delete all tasks (useful for testing/debugging)
  static Future<void> deleteAllTasks() async {
    await _box.clear();
  }

  /// Get completed tasks for a specific date
  static List<Task> getCompletedTasksForDate(DateTime date) {
    return getTasksForDate(date)
        .where((task) => task.isCompleted)
        .toList();
  }

  /// Get pending tasks for a specific date
  static List<Task> getPendingTasksForDate(DateTime date) {
    return getTasksForDate(date)
        .where((task) => !task.isCompleted)
        .toList();
  }

  /// Get task completion stats for a date
  static TaskStats getStatsForDate(DateTime date) {
    final tasks = getTasksForDate(date);
    final completed = tasks.where((task) => task.isCompleted).length;
    final total = tasks.length;
    
    return TaskStats(
      total: total,
      completed: completed,
      pending: total - completed,
      completionRate: total > 0 ? completed / total : 0.0,
    );
  }

  /// Search tasks by title
  static List<Task> searchTasks(String query) {
    if (query.trim().isEmpty) return [];
    
    final lowercaseQuery = query.toLowerCase().trim();
    return _box.values
        .where((task) => task.title.toLowerCase().contains(lowercaseQuery))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get tasks for the current week (Monday to Friday)
  static Map<DateTime, List<Task>> getThisWeeksTasks() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekTasks = <DateTime, List<Task>>{};
    
    for (int i = 0; i < 5; i++) { // Monday to Friday
      final date = monday.add(Duration(days: i));
      final normalizedDate = DateTime(date.year, date.month, date.day);
      weekTasks[normalizedDate] = getTasksForDate(normalizedDate);
    }
    
    return weekTasks;
  }

  /// Listen to task changes
  static Stream<BoxEvent> get taskStream => _box.watch();

  /// Generate a unique ID for tasks
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Close the service (cleanup)
  static Future<void> close() async {
    await _tasksBox?.close();
  }
}

/// Task statistics for a specific date
class TaskStats {
  final int total;
  final int completed;
  final int pending;
  final double completionRate;

  TaskStats({
    required this.total,
    required this.completed,
    required this.pending,
    required this.completionRate,
  });

  @override
  String toString() {
    return 'TaskStats(total: $total, completed: $completed, pending: $pending, rate: ${(completionRate * 100).toStringAsFixed(1)}%)';
  }
} 