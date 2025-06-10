import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../constants/app_theme.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback? onLongPress;
  final VoidCallback? onDeleted;

  const TaskItem({
    super.key,
    required this.task,
    this.onLongPress,
    this.onDeleted,
  });

  void _showUndoSnackBar(BuildContext context, TaskProvider taskProvider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task "${task.title}" deleted'),
        backgroundColor: const Color(0xFF374151),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: const Color(0xFF007AFF),
          onPressed: () {
            taskProvider.restoreTask(task);
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return Dismissible(
          key: Key('task_${task.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFFF3B30),
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
            ),
            child: const Icon(
              Icons.delete_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
          onDismissed: (direction) {
            // Store the task for potential undo
            taskProvider.deleteTask(task.id);
            onDeleted?.call();
            _showUndoSnackBar(context, taskProvider);
          },
          child: InkWell(
            onTap: () => taskProvider.toggleTaskCompletion(task.id),
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(AppTheme.radiusS),
          child: Container(
            height: AppTheme.taskItemHeight, // 44px touch-friendly from PRD
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingS, // 8px horizontal padding
              vertical: 10, // Center content vertically
            ),
            child: Row(
              children: [
                // Checkbox (20px with 2px border from PRD specs)
                GestureDetector(
                  onTap: () => taskProvider.toggleTaskCompletion(task.id),
                  child: Container(
                    width: AppTheme.checkboxSize, // 20px
                    height: AppTheme.checkboxSize, // 20px
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: task.isCompleted
                          ? Theme.of(context).colorScheme.secondary // Green
                          : Theme.of(context).colorScheme.outline, // Subtle border
                        width: 2, // 2px border from PRD
                      ),
                      color: task.isCompleted
                        ? Theme.of(context).colorScheme.secondary // Green fill
                        : Colors.transparent,
                    ),
                    child: task.isCompleted
                      ? Icon(
                          Icons.check,
                          size: 12, // Smaller check for 20px container
                          color: Theme.of(context).colorScheme.onSecondary, // Black on green
                        )
                      : null,
                  ),
                ),
                const SizedBox(width: 12), // Spacing between checkbox and text
                
                // Task title (16px regular from PRD)
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      decoration: task.isCompleted 
                        ? TextDecoration.lineThrough 
                        : null,
                      color: task.isCompleted
                        ? Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6) // Dimmed
                        : Theme.of(context).colorScheme.onSurface, // Pure white
                      decorationColor: Theme.of(context).colorScheme.onSurfaceVariant, // Cool grey strikethrough
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          ),
        );
      },
    );
  }
} 