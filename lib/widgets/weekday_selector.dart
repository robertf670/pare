import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weekday.dart';
import '../providers/task_provider.dart';

class WeekdaySelector extends StatelessWidget {
  const WeekdaySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return Container(
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: Weekday.all.length,
            itemBuilder: (context, index) {
              final weekday = Weekday.all[index];
              final isSelected = weekday == taskProvider.selectedWeekday;
              final isToday = weekday.isToday;
              final taskCount = taskProvider.getTasksForWeekday(weekday).length;
              final completedCount = taskProvider.getTasksForWeekday(weekday)
                  .where((task) => task.isCompleted).length;

              return GestureDetector(
                onTap: () => taskProvider.setSelectedWeekday(weekday),
                child: Semantics(
                  label: '${weekday.fullName}${isToday ? ', today' : ''}. $taskCount ${taskCount == 1 ? 'task' : 'tasks'}${taskCount > 0 ? ', $completedCount completed' : ''}',
                  hint: isSelected ? 'Currently selected day' : 'Tap to select this day',
                  button: true,
                  selected: isSelected,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : isToday
                            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected || isToday
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          weekday.shortName,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : isToday
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface,
                            fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        if (taskCount > 0) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: completedCount == taskCount
                                 ? Theme.of(context).colorScheme.secondary
                                 : isSelected
                                   ? Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8)
                                   : Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$completedCount/$taskCount',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: completedCount == taskCount
                                  ? Theme.of(context).colorScheme.onSecondary
                                  : isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
} 