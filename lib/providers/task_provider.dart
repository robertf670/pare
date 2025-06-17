import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/weekday.dart';
import '../services/task_service.dart';
import '../utils/date_utils.dart';

// Add error state management
enum ErrorType {
  loading,
  adding,
  updating,
  deleting,
  general,
}

class AppError {
  final String message;
  final ErrorType type;
  final DateTime timestamp;
  final Object? originalError;

  AppError({
    required this.message,
    required this.type,
    DateTime? timestamp,
    this.originalError,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() => 'AppError: $message (${type.name})';
}

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  Weekday _selectedWeekday = Weekday.today;
  int _weekOffset = 0; // 0 = current week, -1 = previous week, +1 = next week
  bool _isLoading = false;
  final List<Task> _deletedTasks = []; // Store recently deleted tasks for undo
  
  // Add error handling state
  AppError? _lastError;
  final Map<String, bool> _operationStates = {}; // Track individual operation states

  // Add error getters
  AppError? get lastError => _lastError;
  bool get hasError => _lastError != null;
  String get errorMessage => _lastError?.message ?? '';
  
  // Check if specific operations are in progress
  bool isOperationInProgress(String operation) => _operationStates[operation] ?? false;
  bool get isAddingTask => isOperationInProgress('adding');
  bool get isDeletingTask => isOperationInProgress('deleting');
  bool get isUpdatingTask => isOperationInProgress('updating');

  // Clear error state
  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  // Set error state
  void _setError(String message, ErrorType type, [Object? originalError]) {
    _lastError = AppError(
      message: message,
      type: type,
      originalError: originalError,
    );
    notifyListeners();
  }

  // Set operation state
  void _setOperationState(String operation, bool inProgress) {
    _operationStates[operation] = inProgress;
    notifyListeners();
  }

  List<Task> get tasks {
    final filteredTasks = _tasks.where((task) => _isTaskForSelectedWeekday(task)).toList();
    
    // Sort tasks: incomplete tasks first, then completed tasks
    filteredTasks.sort((a, b) {
      // First sort by completion status (incomplete first)
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      // Then sort by creation time (newest first within same completion status)
      return b.createdAt.compareTo(a.createdAt);
    });
    
    return filteredTasks;
  }
  List<Task> get allTasks => _tasks;
  List<Task> get deletedTasks => _deletedTasks;
  Weekday get selectedWeekday => _selectedWeekday;
  int get weekOffset => _weekOffset;
  bool get isLoading => _isLoading;

  // Week navigation getters
  bool get isCurrentWeek => _weekOffset == 0;
  bool get isPreviousWeek => _weekOffset < 0;
  bool get isNextWeek => _weekOffset > 0;
  
  // Get the actual date for the selected weekday in the current week context
  DateTime get currentWeekStart => DateUtils.getCurrentMonday().add(Duration(days: _weekOffset * 7));
  DateTime get selectedDate => currentWeekStart.add(Duration(days: _selectedWeekday.dayNumber - 1));
  
  // Week display helper
  String get weekDisplayText {
    if (_weekOffset == 0) {
      return 'This Week';
    } else if (_weekOffset == -1) {
      return 'Last Week';
    } else if (_weekOffset == 1) {
      return 'Next Week';
    } else if (_weekOffset < 0) {
      return '${_weekOffset.abs()} weeks ago';
    } else {
      return 'In $_weekOffset weeks';
    }
  }

  List<Task> get completedTasks => tasks.where((task) => task.isCompleted).toList();
  List<Task> get incompleteTasks => tasks.where((task) => !task.isCompleted).toList();
  
  int get completedCount => completedTasks.length;
  int get totalCount => tasks.length;
  double get completionPercentage => totalCount > 0 ? completedCount / totalCount : 0.0;

  TaskProvider() {
    _loadTasks();
  }

  bool _isTaskForSelectedWeekday(Task task) {
    final taskDate = DateUtils.startOfDay(task.date);
    final expectedDate = DateUtils.startOfDay(selectedDate);
    return taskDate.isAtSameMomentAs(expectedDate);
  }

  // Week navigation methods
  void goToPreviousWeek() {
    _weekOffset--;
    notifyListeners();
  }

  void goToNextWeek() {
    _weekOffset++;
    notifyListeners();
  }

  void goToCurrentWeek() {
    _weekOffset = 0;
    // Also set the selected weekday to today if going to current week
    _selectedWeekday = Weekday.today;
    notifyListeners();
  }

  Future<void> _loadTasks() async {
    _isLoading = true;
    clearError(); // Clear any previous errors
    notifyListeners();

    try {
      _tasks = TaskService.getAllTasks();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      _setError('Failed to load tasks. Please try again.', ErrorType.loading, e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(String title) async {
    if (title.trim().isEmpty) {
      _setError('Task title cannot be empty', ErrorType.adding);
      return;
    }

    _setOperationState('adding', true);
    clearError();

    try {
      final taskDate = selectedDate;
      final savedTask = await TaskService.createTask(
        title: title.trim(),
        date: taskDate,
      );
      _tasks.add(savedTask);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding task: $e');
      _setError('Failed to add task. Please try again.', ErrorType.adding, e);
    } finally {
      _setOperationState('adding', false);
    }
  }

  Future<void> addTaskForWeekday(String title, Weekday weekday) async {
    if (title.trim().isEmpty) return;

    try {
      final taskDate = currentWeekStart.add(Duration(days: weekday.dayNumber - 1));
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
    _setOperationState('updating', true);
    clearError();
    
    try {
      final updatedTask = await TaskService.toggleTaskCompletion(taskId);
      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        _tasks[taskIndex] = updatedTask;
        notifyListeners();
      } else {
        _setError('Task not found', ErrorType.updating);
      }
    } catch (e) {
      debugPrint('Error updating task: $e');
      _setError('Failed to update task. Please try again.', ErrorType.updating, e);
    } finally {
      _setOperationState('updating', false);
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
    if (taskIndex == -1) {
      _setError('Task not found', ErrorType.deleting);
      return;
    }
    
    final taskToDelete = _tasks[taskIndex];
    _setOperationState('deleting', true);
    clearError();
    
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
      _setError('Failed to delete task. Please try again.', ErrorType.deleting, e);
    } finally {
      _setOperationState('deleting', false);
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

  // Get tasks for a specific weekday in the current week context
  List<Task> getTasksForWeekday(Weekday weekday) {
    final weekdayDate = currentWeekStart.add(Duration(days: weekday.dayNumber - 1));
    final filteredTasks = _tasks.where((task) {
      final taskDate = DateUtils.startOfDay(task.date);
      final expectedDate = DateUtils.startOfDay(weekdayDate);
      return taskDate.isAtSameMomentAs(expectedDate);
    }).toList();
    
    // Sort tasks: incomplete tasks first, then completed tasks
    filteredTasks.sort((a, b) {
      // First sort by completion status (incomplete first)
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      // Then sort by creation time (newest first within same completion status)
      return b.createdAt.compareTo(a.createdAt);
    });
    
    return filteredTasks;
  }

  // Clear completed tasks for current weekday
  Future<void> clearCompletedTasks() async {
    final completedTaskIds = completedTasks.map((task) => task.id).toList();
    
    for (final taskId in completedTaskIds) {
      await deleteTask(taskId);
    }
  }
} 