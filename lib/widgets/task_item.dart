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
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0x00FF3B30), Color(0xFFFF3B30)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Color(0xFFFF3B30),
                size: 20,
              ),
            ),
          ),
          onDismissed: (direction) {
            taskProvider.deleteTask(task.id);
            onDeleted?.call();
            _showUndoSnackBar(context, taskProvider);
          },
          child: InkWell(
            onTap: () => taskProvider.toggleTaskCompletion(task.id),
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // Modern checkbox with sophisticated animation
                  GestureDetector(
                    onTap: () => taskProvider.toggleTaskCompletion(task.id),
                    child: AnimatedContainer(
                      duration: AppTheme.animationFast,
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: task.isCompleted
                          ? const Color(0xFF10B981)
                          : Colors.transparent,
                        border: Border.all(
                          color: task.isCompleted
                            ? const Color(0xFF10B981)
                            : const Color(0xFFD1D5DB),
                          width: 2,
                        ),
                        boxShadow: task.isCompleted ? [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: task.isCompleted
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Color(0xFFFFFFFF),
                          )
                        : null,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Enhanced task content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Task title with modern typography
                        AnimatedDefaultTextStyle(
                          duration: AppTheme.animationFast,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: task.isCompleted
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF1F2937),
                            decoration: task.isCompleted 
                              ? TextDecoration.lineThrough 
                              : null,
                            decorationColor: const Color(0xFF9CA3AF),
                            height: 1.3,
                            letterSpacing: 0.1,
                          ),
                          child: Text(
                            task.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        // Subtle completion indicator
                        if (task.isCompleted) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Completed',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF10B981),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Modern status indicator
                  if (!task.isCompleted) ...[
                    const SizedBox(width: 12),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B7280),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} 