import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/weekday.dart';
import '../services/task_service.dart';


class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  Weekday _selectedWeekday = Weekday.today;
  bool _isLoading = false;
  final List<Task> _deletedTasks = []; // Store recently deleted tasks for undo

  List<Task> get tasks => _tasks.where((task) => _isTaskForSelectedWeekday(task)).toList();
  List<Task> get allTasks => _tasks;
  Weekday get selectedWeekday => _selectedWeekday;
  bool get isLoading => _isLoading;

  List<Task> get completedTasks => tasks.where((task) => task.isCompleted).toList();
  List<Task> get incompleteTasks => tasks.where((task) => !task.isCompleted).toList();
  
  int get completedCount => completedTasks.length;
  int get totalCount => tasks.length;
  double get completionPercentage => totalCount > 0 ? completedCount / totalCount : 0.0;

  TaskProvider() {
    _loadTasks();
  }

  bool _isTaskForSelectedWeekday(Task task) {
    final taskWeekday = Weekday.fromDateTime(task.date);
    return taskWeekday == _selectedWeekday;
  }

  Future<void> _loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = TaskService.getAllTasks();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(String title) async {
    if (title.trim().isEmpty) return;

    try {
      final taskDate = _selectedWeekday.toDateTime();
      final savedTask = await TaskService.createTask(
        title: title.trim(),
        date: taskDate,
      );
      _tasks.add(savedTask);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding task: $e');
    }
  }

  Future<void> addTaskForWeekday(String title, Weekday weekday) async {
    if (title.trim().isEmpty) return;

    try {
      final taskDate = weekday.toDateTime();
      final savedTask = await TaskService.createTask(
        title: title.trim(),
        date: taskDate,
      );
      _tasks.add(savedTask);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding task: $e');
    }
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    try {
      final updatedTask = await TaskService.toggleTaskCompletion(taskId);
      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        _tasks[taskIndex] = updatedTask;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating task: $e');
    }
  }

  Future<void> updateTask(Task updatedTask) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (taskIndex == -1) return;

    try {
      await TaskService.updateTask(updatedTask);
      _tasks[taskIndex] = updatedTask;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating task: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    // Find and store the task before deleting for potential undo
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex == -1) return;
    
    final taskToDelete = _tasks[taskIndex];
    
    try {
      await TaskService.deleteTask(taskId);
      _tasks.removeAt(taskIndex);
      
      // Store for potential undo (keep only last 5 for memory efficiency)
      _deletedTasks.add(taskToDelete);
      if (_deletedTasks.length > 5) {
        _deletedTasks.removeAt(0);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting task: $e');
    }
  }

  Future<void> restoreTask(Task task) async {
    try {
      // Re-add the task to the service
      final restoredTask = await TaskService.createTask(
        title: task.title,
        date: task.date,
      );
      
      // If the original task was completed, toggle the restored task to completed
      if (task.isCompleted) {
        final completedTask = await TaskService.toggleTaskCompletion(restoredTask.id);
        _tasks.add(completedTask);
      } else {
        _tasks.add(restoredTask);
      }
      
      _deletedTasks.removeWhere((deletedTask) => deletedTask.id == task.id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error restoring task: $e');
    }
  }

  void setSelectedWeekday(Weekday weekday) {
    _selectedWeekday = weekday;
    notifyListeners();
  }

  Future<void> refreshTasks() async {
    await _loadTasks();
  }

  // Get tasks for a specific weekday
  List<Task> getTasksForWeekday(Weekday weekday) {
    return _tasks.where((task) => Weekday.fromDateTime(task.date) == weekday).toList();
  }

  // Clear completed tasks for current weekday
  Future<void> clearCompletedTasks() async {
    final completedTaskIds = completedTasks.map((task) => task.id).toList();
    
    for (final taskId in completedTaskIds) {
      await deleteTask(taskId);
    }
  }
} 