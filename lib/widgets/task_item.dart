import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../constants/app_theme.dart';

class TaskItem extends StatefulWidget {
  final Task task;
  final VoidCallback? onDeleted;
  final VoidCallback? onLongPress;
  final bool showAnimation;

  const TaskItem({
    super.key,
    required this.task,
    this.onDeleted,
    this.onLongPress,
    this.showAnimation = true,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late AnimationController _pulseController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _isPressed = false;
  bool _isDismissed = false; // Track dismissal state

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _slideController = AnimationController(
      duration: AppTheme.animationNormal,
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: AppTheme.animationFast,
      vsync: this,
    );
    
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 300), // Simplified duration
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 400), // Reduced duration
      vsync: this,
    );
    
    // Initialize animations
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic, // Simplified curve
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1, // Reduced scale
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Start entrance animation if enabled
    if (widget.showAnimation) {
      _slideController.forward();
      _scaleController.forward();
    } else {
      _slideController.value = 1.0;
      _scaleController.value = 1.0;
    }
    
    // Set initial checkbox state based on task completion
    if (widget.task.isCompleted) {
      _checkController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(TaskItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update checkbox animation when task completion changes
    if (widget.task.isCompleted != oldWidget.task.isCompleted) {
      if (widget.task.isCompleted) {
        _checkController.forward();
        // Add small celebration pulse
        _pulseController.forward().then((_) {
          if (mounted) {
            _pulseController.reverse();
          }
        });
      } else {
        _checkController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _checkController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTaskToggle() async {
    if (_isDismissed) return; // Prevent interaction if dismissed
    
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    
    // Simple toggle without complex animation coordination
    await taskProvider.toggleTaskCompletion(widget.task.id);
  }

  void _handlePress(bool isPressed) {
    if (_isDismissed) return;
    
    setState(() {
      _isPressed = isPressed;
    });
    
    if (isPressed) {
      _scaleController.animateTo(0.98);
    } else {
      _scaleController.forward();
    }
  }

  void _handleDismiss() {
    setState(() {
      _isDismissed = true;
    });
    
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.deleteTask(widget.task.id);
    
    // Immediately call onDeleted to remove from parent list
    widget.onDeleted?.call();
    
    _showUndoSnackBar(context, taskProvider);
  }

  @override
  Widget build(BuildContext context) {
    // Don't render if dismissed
    if (_isDismissed) {
      return const SizedBox.shrink();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: AppTheme.animationFast,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isPressed ? 0.1 : 0.05),
                blurRadius: _isPressed ? 8 : 4,
                offset: Offset(0, _isPressed ? 4 : 2),
              ),
            ],
          ),
          child: Dismissible(
            key: Key('task_${widget.task.id}'),
            direction: DismissDirection.endToStart,
            background: _buildDismissBackground(),
            onDismissed: (direction) => _handleDismiss(),
            child: Semantics(
              label: '${widget.task.title}. ${widget.task.isCompleted ? 'Completed task' : 'Incomplete task'}',
              hint: widget.task.isCompleted 
                  ? 'Double tap to mark as incomplete. Swipe left to delete.' 
                  : 'Double tap to mark as complete. Swipe left to delete.',
              button: true,
              enabled: true,
              focusable: true,
              child: GestureDetector(
                onTapDown: (_) => _handlePress(true),
                onTapUp: (_) => _handlePress(false),
                onTapCancel: () => _handlePress(false),
                onTap: _handleTaskToggle,
                onLongPress: widget.onLongPress,
                child: AnimatedContainer(
                  duration: AppTheme.animationFast,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: AppTheme.modernCardDecoration(
                    backgroundColor: widget.task.isCompleted
                        ? const Color(0xFFF8F9FA)
                        : const Color(0xFFFFFFFF),
                    borderColor: widget.task.isCompleted
                        ? const Color(0xFFE5E7EA)
                        : const Color(0xFFF0F1F2),
                    elevated: !widget.task.isCompleted,
                  ),
                  child: Row(
                    children: [
                      _buildCheckbox(),
                      const SizedBox(width: 16),
                      _buildTaskContent(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Semantics(
        label: widget.task.isCompleted ? 'Completed' : 'Not completed',
        hint: 'Tap to ${widget.task.isCompleted ? 'mark as incomplete' : 'mark as complete'}',
        button: true,
        checked: widget.task.isCompleted,
        child: GestureDetector(
          onTap: _handleTaskToggle,
          child: AnimatedContainer(
            duration: AppTheme.animationNormal,
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: widget.task.isCompleted
                  ? const Color(0xFF10B981)
                  : Colors.transparent,
              border: Border.all(
                color: widget.task.isCompleted
                    ? const Color(0xFF10B981)
                    : const Color(0xFFD1D5DB),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: widget.task.isCompleted
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskContent() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedDefaultTextStyle(
            duration: AppTheme.animationNormal,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: widget.task.isCompleted
                  ? const Color(0xFF9CA3AF)
                  : const Color(0xFF1F2937),
              decoration: widget.task.isCompleted 
                  ? TextDecoration.lineThrough 
                  : null,
              decorationColor: const Color(0xFF9CA3AF),
              height: 1.3,
              letterSpacing: 0.1,
            ),
            child: Text(
              widget.task.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.task.isCompleted) ...[
            const SizedBox(height: 4),
            AnimatedOpacity(
              duration: AppTheme.animationNormal,
              opacity: widget.task.isCompleted ? 1.0 : 0.0,
              child: Row(
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
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0x00FF3B30), Color(0xFFFF3B30)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: AnimatedContainer(
        duration: AppTheme.animationFast,
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
    );
  }

  void _showUndoSnackBar(BuildContext context, TaskProvider taskProvider) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.delete_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Task deleted',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF374151),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Undo',
          textColor: const Color(0xFF60A5FA),
          onPressed: () {
            if (taskProvider.deletedTasks.contains(widget.task)) {
              taskProvider.restoreTask(widget.task);
            }
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
} 