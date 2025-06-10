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

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => taskProvider.setSelectedWeekday(weekday),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : isToday
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                                             border: Border.all(
                         color: isToday
                           ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                           : Colors.transparent,
                         width: 1,
                       ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Day abbreviation
                        Text(
                          weekday.shortName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : isToday
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: isSelected || isToday 
                              ? FontWeight.w600 
                              : FontWeight.w400,
                          ),
                        ),
                        
                        // Task indicator
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
                        ] else if (isToday || isSelected) ...[
                          const SizedBox(height: 4),
                          Container(
                            width: 6,
                            height: 6,
                                                         decoration: BoxDecoration(
                               color: isSelected
                                 ? Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.6)
                                 : Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                               shape: BoxShape.circle,
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