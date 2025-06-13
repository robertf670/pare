import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/weekday.dart';
import '../providers/task_provider.dart';
import '../widgets/task_item.dart';
import '../utils/date_utils.dart' as AppDateUtils;

import '../constants/app_theme.dart';

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
      body: Container(
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
              return GestureDetector(
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
              );
            },
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
    final screenHeight = MediaQuery.of(context).size.height;
    
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
        // Modern responsive sizing
        height: isActive ? screenHeight * 0.65 : 96, // 65% for expanded, 96px for collapsed
        decoration: BoxDecoration(
          // Seamless gradient design
          gradient: isActive 
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFAFBFC), // Very subtle top
                  Color(0xFFF8F9FA), // Seamless bottom
                ],
              )
            : null,
          color: isActive ? null : Colors.transparent, // No background for collapsed
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 24, // Consistent padding
          vertical: isActive ? 24 : 0, // Only padding for expanded
        ),
        child: isActive ? _buildExpandedDayContent(context, weekday, isToday, tasks, taskProvider) 
                       : _buildCollapsedDayContent(context, weekday),
      ),
    );
  }

  Widget _buildExpandedDayContent(BuildContext context, Weekday weekday, bool isToday, List<dynamic> tasks, TaskProvider taskProvider) {
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
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
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
              
              const SizedBox(height: 32),
              
              // Time and date display side by side
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Time display
                    Text(
                      '${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 56,
                        fontWeight: FontWeight.w100,
                        color: const Color(0xFF1A1A1A),
                        letterSpacing: -3.0,
                        height: 0.85,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Enhanced date display
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
              
              const SizedBox(height: 20),
              
              // Modern tasks section
              Expanded(
                child: Container(
                  decoration: AppTheme.modernCardDecoration(
                    backgroundColor: const Color(0xFFFDFDFD),
                    borderColor: const Color(0xFFE8E9EA),
                    borderRadius: AppTheme.radiusL,
                    elevated: true,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tasks header with scroll hint
                        if (tasks.isNotEmpty) ...[
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Today\'s Tasks',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1A1A1A),
                                ),
                              ),
                              // Scroll hint for many tasks
                              if (tasks.length > 3) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6B7280).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.keyboard_arrow_up,
                                        size: 12,
                                        color: const Color(0xFF6B7280),
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 12,
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${tasks.length}',
                                  style: const TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                        
                        // Tasks list with prominent scrollbar
                        Expanded(
                          child: tasks.isNotEmpty 
                            ? _ScrollableTaskList(
                                tasks: tasks,
                                taskProvider: taskProvider,
                                showTaskOptions: _showTaskOptions,
                              )
                            : Center(
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
                        
                        const SizedBox(height: 16),
                        
                        // Modern add task button
                        GestureDetector(
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

  String _formatDateSimple(DateTime date) {
    final months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    
    return '${months[date.month - 1]} ${date.day}';
  }

  String _formatDateLong(Weekday weekday, DateTime date) {
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
          top: 8,
          bottom: 8,
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
              onDeleted: () {},
            ),
          );
        },
      ),
    );
  }
} 