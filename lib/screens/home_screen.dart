import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weekday.dart';
import '../providers/task_provider.dart';
import '../widgets/task_item.dart';

import '../constants/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _scrollController;
  int _currentDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    // Set initial day to today
    _currentDayIndex = Weekday.all.indexOf(Weekday.today);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSelectedDay();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
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
      backgroundColor: const Color(0xFFFFFFFF), // Pure white background
      body: SafeArea(
        child: Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            return _buildScrollableDayList(context, taskProvider);
          },
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
    final isToday = weekday.isToday;
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
        // Proper sizing like mockup
                height: isActive ? screenHeight * 0.5 : 80, // 50% for expanded, 80px for collapsed
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
    final now = DateTime.now();
    
    return Container(
      clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(),
        child: ClipRect(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                        // Time header with seamless design
            Text(
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w300,
                color: Color(0xFF1A1A1A), // Clean dark text
                height: 0.9,
                letterSpacing: -1.2,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Date and day info with better typography
            Text(
              '${weekday.fullName}, ${_formatDateSimple(weekday.toDateTime())}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF8E8E93), // Subtle gray
                height: 1.2,
                letterSpacing: 0.2,
              ),
            ),
              
              const SizedBox(height: 24),
              
              // Tasks content (with overflow protection)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tasks list (takes available space)
                      Expanded(
                        child: tasks.isNotEmpty 
                          ? ListView.separated(
                              itemCount: tasks.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 4),
                              itemBuilder: (context, index) {
                                final task = tasks[index];
                                return Container(
                                  height: 48,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: TaskItem(
                                    task: task,
                                    onLongPress: () => _showTaskOptions(context, task, taskProvider),
                                    onDeleted: () {
                                      // Optional: Add any additional cleanup or animations here
                                    },
                                  ),
                                );
                              },
                            )
                          : const Center(
                              child: Text(
                                'No tasks planned',
                                style: TextStyle(
                                  color: Color(0xFF8E8E93),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Add task input with seamless design
                      Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE5E5EA),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.add,
                              size: 20,
                              color: Color(0xFF8E8E93),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _showAddTaskDialog(context, taskProvider, weekday),
                                child: const Text(
                                  'Add a new task...',
                                  style: TextStyle(
                                    color: Color(0xFF8E8E93),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildCollapsedDayContent(BuildContext context, Weekday weekday) {
    return Container(
      height: 80,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 24),
      decoration: const BoxDecoration(
        color: Colors.transparent, // Completely seamless
      ),
      child: Text(
        weekday.fullName,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: Color(0xFF1A1A1A).withValues(alpha: 0.4), // Very subtle text
          height: 1.0,
          letterSpacing: 0.5,
        ),
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

  void _showAddTaskDialog(BuildContext context, TaskProvider taskProvider, Weekday weekday) {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        title: Text(
          'Add Task for ${weekday.fullName}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter task title...',
            hintStyle: Theme.of(context).textTheme.bodySmall,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          style: Theme.of(context).textTheme.bodyLarge,
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
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                taskProvider.addTaskForWeekday(controller.text.trim(), weekday);
                Navigator.of(context).pop();
              }
            },
            child: Text(
              'Add',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showTaskOptions(BuildContext context, dynamic task, TaskProvider taskProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
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
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.paddingL),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Delete Task',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
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