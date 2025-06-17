import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/weekday.dart';
import '../providers/task_provider.dart';
import '../widgets/task_item.dart';
import '../widgets/error_handler.dart';
import '../constants/app_theme.dart';
import 'package:intl/intl.dart';
import 'settings_screen.dart';
import 'whats_new_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _scrollController;
  int _currentDayIndex = 0;
  late DateTime _currentTime;
  Timer? _timeUpdateTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _currentTime = DateTime.now();
    
    // Set initial day to today
    _currentDayIndex = Weekday.all.indexOf(Weekday.today);
    
    // Start timer to update time every minute
    _startTimeUpdateTimer();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSelectedDay();
    });
  }

  void _startTimeUpdateTimer() {
    // Calculate seconds until next minute to sync with clock
    final now = DateTime.now();
    final secondsUntilNextMinute = 60 - now.second;
    
    // Start with a delay to sync to the next minute
    Timer(Duration(seconds: secondsUntilNextMinute), () {
      // Update time immediately
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
      
      // Then start periodic timer for every minute
      _timeUpdateTimer = Timer.periodic(const Duration(minutes: 1), (_) {
        if (mounted) {
          setState(() {
            _currentTime = DateTime.now();
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _timeUpdateTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    // Disable automatic scroll-based day switching to fix the Monday issue
    // Days will only change when tapped directly
  }

  void _updateSelectedDay() {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.setSelectedWeekday(Weekday.all[_currentDayIndex]);
  }

  void _scrollToDay(int dayIndex) {
    if (!_scrollController.hasClients) return;
    
    final collapsedHeight = 80.0;
    
    // Calculate the scroll position for the selected day
    double targetOffset = 0;
    for (int i = 0; i < dayIndex; i++) {
      targetOffset += collapsedHeight; // All previous days are collapsed
    }
    
    // Animate to the target position
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Modern light background
      body: ErrorHandler(
        showRetryButton: true,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF9FAFB), // Light top
                Color(0xFFF3F4F6), // Slightly darker bottom
              ],
            ),
          ),
          child: SafeArea(
            child: Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                // Show error state if there's a loading error
                if (taskProvider.hasError && taskProvider.lastError?.type == ErrorType.loading) {
                  return ErrorStateWidget(
                    errorMessage: taskProvider.errorMessage,
                    onRetry: () => taskProvider.refreshTasks(),
                  );
                }

                return LoadingOverlay(
                  isLoading: taskProvider.isLoading,
                  loadingText: 'Loading tasks...',
                  child: GestureDetector(
                    // Add horizontal swipe gestures for week navigation
                    onHorizontalDragEnd: (details) {
                      // Detect swipe direction based on velocity
                      if (details.primaryVelocity != null) {
                        if (details.primaryVelocity! > 500) {
                          // Swipe right - go to previous week
                          taskProvider.goToPreviousWeek();
                        } else if (details.primaryVelocity! < -500) {
                          // Swipe left - go to next week
                          taskProvider.goToNextWeek();
                        }
                      }
                    },
                    child: _buildScrollableDayList(context, taskProvider),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableDayList(BuildContext context, TaskProvider taskProvider) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      itemCount: Weekday.all.length,
      itemBuilder: (context, index) {
        final weekday = Weekday.all[index];
        final isActive = index == _currentDayIndex;
        return _buildDaySection(context, weekday, taskProvider, isActive, index);
      },
    );
  }

  Widget _buildDaySection(BuildContext context, Weekday weekday, TaskProvider taskProvider, bool isActive, int index) {
    final tasks = taskProvider.getTasksForWeekday(weekday);
    // Check if this weekday in the current week context is today
    final weekdayDate = taskProvider.currentWeekStart.add(Duration(days: weekday.dayNumber - 1));
    final today = DateTime.now();
    final isToday = taskProvider.isCurrentWeek && 
        weekdayDate.year == today.year && 
        weekdayDate.month == today.month && 
        weekdayDate.day == today.day;
    
    return GestureDetector(
      onTap: () {
        // Allow tapping any day to expand it
        if (!isActive) {
          setState(() {
            _currentDayIndex = index;
          });
          _updateSelectedDay();
          
          // Optionally scroll to the selected day for better UX
          _scrollToDay(index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: isActive ? null : 96,
        // Remove all height constraints - let content size naturally
        decoration: BoxDecoration(
          gradient: isActive 
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFAFBFC),
                  Color(0xFFF8F9FA),
                ],
              )
            : null,
          color: isActive ? null : Colors.transparent,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: isActive ? 20 : 0, // More breathing room
        ),
        child: isActive ? _buildExpandedDayContent(context, weekday, isToday, tasks, taskProvider, isActive) 
                       : _buildCollapsedDayContent(context, weekday),
      ),
    );
  }

  Widget _buildExpandedDayContent(BuildContext context, Weekday weekday, bool isToday, List<dynamic> tasks, TaskProvider taskProvider, bool isActive) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFBFCFD), // Ultra subtle gradient top
            Color(0xFFF8F9FA), // Seamless bottom
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      child: ClipRect(
                  child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12), // Better padding
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Week navigation header with modern glass styling
              Container(
                decoration: AppTheme.glassDecoration(
                  backgroundColor: const Color(0x08000000),
                  borderColor: const Color(0x12000000),
                  borderRadius: AppTheme.radiusM,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: _buildWeekNavigationHeader(context, taskProvider),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Time and date section with enhanced spacing
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time display with subtle background
                    Semantics(
                      label: 'Current time',
                      readOnly: true,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0x03000000),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0x05000000),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          DateFormat('HH:mm').format(_currentTime),
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A1A),
                            letterSpacing: -1.5,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Enhanced date display with better visual hierarchy
                    Semantics(
                      label: 'Current date: ${_formatDateForAccessibility(weekday, taskProvider.selectedDate)}',
                      readOnly: true,
                      child: Row(
                        children: [
                          Container(
                            width: 3,
                            height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 4), // Align with baseline
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0x06000000),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0x08000000),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _formatDateLong(weekday, taskProvider.selectedDate),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Modern tasks section with better proportions
              Flexible(
                flex: 1,
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: 200,
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                decoration: AppTheme.modernCardDecoration(
                  backgroundColor: const Color(0xFFFDFDFD),
                  borderColor: const Color(0xFFE8E9EA),
                  borderRadius: AppTheme.radiusL,
                  elevated: true,
                ),
                                  child: Padding(
                    padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Modern header design with better weekday indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          border: Border(
                            bottom: BorderSide(
                              color: const Color(0xFFE5E7EA),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Semantics(
                          label: 'Day ${weekday.fullName}${isToday ? ', today' : ''}. ${tasks.length} tasks. ${isActive ? 'Currently selected' : 'Tap to select'}',
                          hint: isActive ? 'Swipe left or right to navigate between weeks' : 'Tap to view tasks for this day',
                          button: !isActive,
                          selected: isActive,
                          child: Row(
                            children: [
                              // Day indicator with modern styling
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isToday 
                                      ? const Color(0xFF1A1A1A)
                                      : isActive 
                                        ? const Color(0xFF1A1A1A).withValues(alpha: 0.1)
                                        : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isToday || isActive 
                                        ? const Color(0xFF1A1A1A)
                                        : const Color(0xFFE5E7EA),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    weekday.shortName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isToday 
                                          ? const Color(0xFFFFFFFF)
                                          : const Color(0xFF1A1A1A),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 16),
                              
                              // Day name and task count
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          weekday.fullName,
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF1A1A1A),
                                          ),
                                        ),
                                        if (isToday) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF10B981),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              'TODAY',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFFFFFFFF),
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Semantics(
                                      label: '${tasks.length} ${tasks.length == 1 ? 'task' : 'tasks'}${tasks.isNotEmpty ? '. ${tasks.where((t) => t.isCompleted).length} completed' : ''}',
                                      child: Text(
                                        tasks.isEmpty 
                                            ? 'No tasks planned'
                                            : '${tasks.length} ${tasks.length == 1 ? 'task' : 'tasks'} • ${tasks.where((t) => t.isCompleted).length} completed',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: const Color(0xFF6B7280),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Three-dot menu for all days
                              if (isActive) ...[
                                const SizedBox(width: 8),
                                Semantics(
                                  label: 'More options',
                                  hint: 'Opens menu with additional options',
                                  button: true,
                                  child: PopupMenuButton<String>(
                                    icon: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8F9FA),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFFE5E7EA),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.more_vert,
                                        size: 18,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                    elevation: 8,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    color: const Color(0xFFFFFFFF),
                                    surfaceTintColor: Colors.transparent,
                                    onSelected: (value) => _handleMenuAction(value, context, taskProvider),
                                    itemBuilder: (context) => [
                                      // Clear completed tasks (only show if there are completed tasks)
                                      if (tasks.any((task) => task.isCompleted)) ...[
                                        PopupMenuItem<String>(
                                          value: 'clear_completed',
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFF3B30).withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: const Icon(
                                                  Icons.clear_all,
                                                  size: 14,
                                                  color: Color(0xFFFF3B30),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              const Text(
                                                'Clear completed tasks',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF1A1A1A),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuDivider(),
                                      ],
                                      
                                      // Settings
                                      PopupMenuItem<String>(
                                        value: 'settings',
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF6B7280).withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Icon(
                                                Icons.settings,
                                                size: 14,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Text(
                                              'Settings',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF1A1A1A),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // What's New (placeholder for now)
                                      PopupMenuItem<String>(
                                        value: 'whats_new',
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Icon(
                                                Icons.new_releases,
                                                size: 14,
                                                color: Color(0xFF007AFF),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Text(
                                              'What\'s New',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF1A1A1A),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              
                              // Visual indicator for active/today
                              if (isActive || isToday) ...[
                                const SizedBox(width: 8),
                                Container(
                                  width: 4,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isToday 
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF1A1A1A),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Tasks list with prominent scrollbar  
                      Expanded(
                        child: tasks.isNotEmpty 
                          ? _ScrollableTaskList(
                              tasks: tasks,
                              taskProvider: taskProvider,
                              showTaskOptions: _showTaskOptions,
                            )
                          : Semantics(
                              label: 'No tasks for ${weekday.fullName}',
                              hint: 'Tap the add button below to create your first task',
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: const Color(0x08000000),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Icon(
                                        Icons.check_circle_outline,
                                        size: 32,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No tasks planned',
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: const Color(0xFF9CA3AF),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Add a task to get started',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: const Color(0xFFD1D5DB),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Modern add task button
                      Semantics(
                        label: 'Add new task for ${weekday.fullName}',
                        hint: 'Opens dialog to create a new task',
                        button: true,
                        child: GestureDetector(
                          onTap: () => _showAddTaskDialog(context, taskProvider, weekday),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: AppTheme.modernCardDecoration(
                              backgroundColor: const Color(0xFF1A1A1A),
                              borderColor: const Color(0xFF1A1A1A),
                              borderRadius: AppTheme.radiusM,
                              elevated: true,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: const Color(0x20FFFFFF),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    size: 16,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Add a new task...',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: const Color(0xFFFFFFFF),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: Color(0x60FFFFFF),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekNavigationHeader(BuildContext context, TaskProvider taskProvider) {
    return Row(
      children: [
        // Previous week button with modern styling
        GestureDetector(
          onTap: () => taskProvider.goToPreviousWeek(),
          child: Container(
            width: 40,
            height: 40,
            decoration: AppTheme.modernCardDecoration(
              backgroundColor: const Color(0xFFFFFFFF),
              borderColor: const Color(0xFFE5E7EA),
              borderRadius: 12,
              elevated: false,
            ),
            child: const Icon(
              Icons.chevron_left,
              size: 20,
              color: Color(0xFF374151),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Modern week indicator
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: () => taskProvider.goToCurrentWeek(),
              child: AnimatedContainer(
                duration: AppTheme.animationNormal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: AppTheme.modernCardDecoration(
                  backgroundColor: taskProvider.isCurrentWeek 
                    ? const Color(0xFF1A1A1A)
                    : const Color(0xFFFFFFFF),
                  borderColor: taskProvider.isCurrentWeek
                    ? const Color(0xFF1A1A1A)
                    : const Color(0xFFE5E7EA),
                  borderRadius: 16,
                  elevated: taskProvider.isCurrentWeek,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (taskProvider.isCurrentWeek) ...[
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      taskProvider.weekDisplayText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: taskProvider.isCurrentWeek 
                          ? const Color(0xFFFFFFFF)
                          : const Color(0xFF6B7280),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Next week button with modern styling
        GestureDetector(
          onTap: () => taskProvider.goToNextWeek(),
          child: Container(
            width: 40,
            height: 40,
            decoration: AppTheme.modernCardDecoration(
              backgroundColor: const Color(0xFFFFFFFF),
              borderColor: const Color(0xFFE5E7EA),
              borderRadius: 12,
              elevated: false,
            ),
            child: const Icon(
              Icons.chevron_right,
              size: 20,
              color: Color(0xFF374151),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsedDayContent(BuildContext context, Weekday weekday) {
    return Container(
      height: 88,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: AppTheme.modernCardDecoration(
        backgroundColor: const Color(0xFFFDFDFD),
        borderColor: const Color(0xFFE8E9EA),
        borderRadius: AppTheme.radiusM,
        elevated: false,
      ),
      child: Row(
        children: [
          // Day indicator dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          
          // Day name with modern typography
          Expanded(
            child: Text(
              weekday.fullName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A1A).withValues(alpha: 0.6),
                letterSpacing: 0.2,
              ),
            ),
          ),
          
          // Chevron indicator
          Icon(
            Icons.keyboard_arrow_down,
            size: 20,
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  String _formatDateLong(Weekday weekday, DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${weekday.fullName}, ${date.day} ${months[date.month - 1]}';
  }

  String _formatDateForAccessibility(Weekday weekday, DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${weekday.fullName}, ${date.day} ${months[date.month - 1]}';
  }

  void _showAddTaskDialog(BuildContext context, TaskProvider taskProvider, Weekday weekday) {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF), // White background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        title: Text(
          'Add Task for ${weekday.fullName}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A), // Dark text for readability
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter task title...',
            hintStyle: const TextStyle(
              color: Color(0xFF8E8E93), // Light grey hint text
              fontSize: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
              borderSide: const BorderSide(
                color: Color(0xFFE5E5EA), // Light grey border
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
              borderSide: const BorderSide(
                color: Color(0xFF1A1A1A), // Dark border when focused
                width: 2,
              ),
            ),
            filled: true,
            fillColor: const Color(0xFFF8F9FA), // Very light background
          ),
          style: const TextStyle(
            color: Color(0xFF1A1A1A), // Dark text for input
            fontSize: 16,
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              taskProvider.addTaskForWeekday(value.trim(), weekday);
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF8E8E93), // Light grey for cancel
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                taskProvider.addTaskForWeekday(controller.text.trim(), weekday);
                Navigator.of(context).pop();
              }
            },
            child: const Text(
              'Add',
              style: TextStyle(
                color: Color(0xFF1A1A1A), // Dark text for primary action
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTaskOptions(BuildContext context, dynamic task, TaskProvider taskProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFFFFF), // White background
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusL)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppTheme.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A), // Dark text for readability
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.paddingL),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: Color(0xFFFF3B30), // Red color for delete
              ),
              title: const Text(
                'Delete Task',
                style: TextStyle(
                  color: Color(0xFFFF3B30), // Red color for delete
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                taskProvider.deleteTask(task.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String value, BuildContext context, TaskProvider taskProvider) async {
    switch (value) {
      case 'clear_completed':
        await _showClearCompletedConfirmation(context, taskProvider);
        break;
      case 'settings':
        if (mounted) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const SettingsScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOutCubic;

                var tween = Tween(begin: begin, end: end).chain(
                  CurveTween(curve: curve),
                );

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        }
        break;
      case 'whats_new':
        if (mounted) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const WhatsNewScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOutCubic;

                var tween = Tween(begin: begin, end: end).chain(
                  CurveTween(curve: curve),
                );

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        }
        break;
    }
  }

  Future<void> _showClearCompletedConfirmation(BuildContext context, TaskProvider taskProvider) async {
    final completedCount = taskProvider.tasks.where((task) => 
      task.isCompleted && _isSameDay(task.date, taskProvider.selectedDate)
    ).length;

    if (completedCount == 0) return;

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          title: const Text(
            'Clear Completed Tasks',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          content: Text(
            'Are you sure you want to remove $completedCount completed ${completedCount == 1 ? 'task' : 'tasks'} from today? This action cannot be undone.',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6B7280),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                taskProvider.clearCompletedTasks();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3B30),
                foregroundColor: const Color(0xFFFFFFFF),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Clear Tasks',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}

class _ScrollableTaskList extends StatefulWidget {
  final List<dynamic> tasks;
  final TaskProvider taskProvider;
  final Function(BuildContext, dynamic, TaskProvider) showTaskOptions;

  const _ScrollableTaskList({
    required this.tasks,
    required this.taskProvider,
    required this.showTaskOptions,
  });

  @override
  State<_ScrollableTaskList> createState() => _ScrollableTaskListState();
}

class _ScrollableTaskListState extends State<_ScrollableTaskList> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrollingActive = false;
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _scrollTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    // Show scrollbar when scrolling is active
    if (!_isScrollingActive) {
      setState(() {
        _isScrollingActive = true;
      });
    }
    
    // Hide scrollbar after scrolling stops
    _scrollTimer?.cancel();
    _scrollTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isScrollingActive = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true, // Always show the scrollbar thumb
      trackVisibility: true, // Always show the scrollbar track
      thickness: 6.0, // Make it prominent
      radius: const Radius.circular(3),
      scrollbarOrientation: ScrollbarOrientation.right,
      child: ListView.separated(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(
          top: 12,
          bottom: 12,
          right: 16, // Add padding for scrollbar
        ),
        itemCount: widget.tasks.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final task = widget.tasks[index];
          return Container(
            decoration: AppTheme.modernCardDecoration(
              backgroundColor: const Color(0xFFFAFBFC),
              borderColor: const Color(0xFFE5E7EA),
              borderRadius: AppTheme.radiusM,
              elevated: false,
            ),
            child: TaskItem(
              task: task,
              onLongPress: () => widget.showTaskOptions(context, task, widget.taskProvider),
              onDeleted: () {
                // Force rebuild to remove the dismissed task from the list
                setState(() {});
              },
            ),
          );
        },
      ),
    );
  }
} 