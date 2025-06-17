import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../constants/app_theme.dart';

class TaskInput extends StatefulWidget {
  final String placeholder;
  final Function(String)? onTaskAdded;

  const TaskInput({
    super.key,
    this.placeholder = 'Add a new task...',
    this.onTaskAdded,
  });

  @override
  State<TaskInput> createState() => _TaskInputState();
}

class _TaskInputState extends State<TaskInput>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  late AnimationController _expansionController;
  late AnimationController _shakeController;
  late AnimationController _successController;
  
  late Animation<double> _expansionAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _successAnimation;
  late Animation<Color?> _borderColorAnimation;
  
  bool _isExpanded = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _expansionController = AnimationController(
      duration: AppTheme.animationNormal,
      vsync: this,
    );
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _successController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Initialize animations
    _expansionAnimation = Tween<double>(
      begin: 56.0,
      end: 80.0,
    ).animate(CurvedAnimation(
      parent: _expansionController,
      curve: Curves.easeOutCubic,
    ));
    
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticOut,
    ));
    
    _successAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    ));
    
    _borderColorAnimation = ColorTween(
      begin: const Color(0xFFE5E7EB),
      end: const Color(0xFF1A1A1A),
    ).animate(CurvedAnimation(
      parent: _expansionController,
      curve: Curves.easeOutCubic,
    ));
    
    // Listen to focus changes
    _focusNode.addListener(_handleFocusChange);
    
    // Listen to text changes for validation
    _controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    _expansionController.dispose();
    _shakeController.dispose();
    _successController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isExpanded = _focusNode.hasFocus || _controller.text.isNotEmpty;
    });
    
    if (_isExpanded) {
      _expansionController.forward();
    } else {
      _expansionController.reverse();
    }
  }

  void _handleTextChange() {
    // Add subtle feedback for typing
    if (_controller.text.length == 1) {
      // First character typed - gentle scale effect
      _successController.forward().then((_) {
        _successController.reverse();
      });
    }
  }

  void _handleSubmit() async {
    final text = _controller.text.trim();
    
    // Enhanced validation for edge cases
    if (text.isEmpty) {
      // Shake animation for empty submission
      _shakeController.forward().then((_) {
        _shakeController.reverse();
      });
      return;
    }
    
    // Check for very long titles
    if (text.length > 200) {
      // Show error for overly long titles
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task title is too long. Please keep it under 200 characters.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    
    // Check for titles that are just whitespace or special characters
    if (text.replaceAll(RegExp(r'[^\w\s]'), '').trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a valid task title.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      await taskProvider.addTask(text);
      
      // Success animation
      await _successController.forward();
      await _successController.reverse();
      
      // Clear and unfocus
      _controller.clear();
      _focusNode.unfocus();
      
      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task added successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      widget.onTaskAdded?.call(text);
    } catch (e) {
      // Error shake animation
      _shakeController.forward().then((_) {
        _shakeController.reverse();
      });
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add task. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_expansionAnimation, _shakeAnimation, _successAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: Transform.scale(
            scale: 1.0 + (_successAnimation.value * 0.02),
            child: AnimatedContainer(
              duration: AppTheme.animationNormal,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: _isExpanded ? 16 : 12,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(
                  _isExpanded ? AppTheme.radiusL : AppTheme.radiusM,
                ),
                border: Border.all(
                  color: _borderColorAnimation.value ?? Theme.of(context).colorScheme.outline,
                  width: _isExpanded ? 2 : 1,
                ),
                boxShadow: _isExpanded ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ] : null,
              ),
              child: Row(
                children: [
                  if (_isExpanded) ...[
                    Icon(
                      Icons.add_circle_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Semantics(
                      label: 'Task input field',
                      hint: 'Enter a new task title and press done to add it',
                      textField: true,
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        enabled: !_isSubmitting,
                        onChanged: (_) => _handleTextChange(),
                        onSubmitted: (_) => _handleSubmit(),
                        decoration: InputDecoration(
                          hintText: widget.placeholder,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLength: 200, // Add character limit for long titles
                        maxLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ),
                  if (_isExpanded) ...[
                    const SizedBox(width: 12),
                    Semantics(
                      label: 'Add task',
                      hint: 'Tap to add the task',
                      button: true,
                      child: GestureDetector(
                        onTap: _isSubmitting ? null : _handleSubmit,
                        child: AnimatedContainer(
                          duration: AppTheme.animationFast,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _isSubmitting 
                                ? Theme.of(context).colorScheme.outline
                                : Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _isSubmitting
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Theme.of(context).colorScheme.onPrimary,
                                  ),
                                )
                              : Icon(
                                  Icons.arrow_forward,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  size: 16,
                                ),
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
    );
  }
} 