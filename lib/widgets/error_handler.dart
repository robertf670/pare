import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

/// Widget that handles error display and user feedback
class ErrorHandler extends StatelessWidget {
  final Widget child;
  final bool showSnackBar;
  final bool showRetryButton;

  const ErrorHandler({
    super.key,
    required this.child,
    this.showSnackBar = true,
    this.showRetryButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        // Show snackbar for errors if enabled
        if (showSnackBar && taskProvider.hasError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showErrorSnackBar(context, taskProvider);
          });
        }

        return child;
      },
    );
  }

  void _showErrorSnackBar(BuildContext context, TaskProvider taskProvider) {
    if (taskProvider.lastError == null) return;

    final error = taskProvider.lastError!;
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getErrorIcon(error.type),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: _getErrorColor(error.type),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        action: showRetryButton
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () => _handleRetry(context, taskProvider, error.type),
              )
            : SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white70,
                onPressed: () {
                  taskProvider.clearError();
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
      ),
    );
  }

  IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.loading:
        return Icons.refresh_outlined;
      case ErrorType.adding:
        return Icons.add_circle_outline;
      case ErrorType.updating:
        return Icons.edit_outlined;
      case ErrorType.deleting:
        return Icons.delete_outline;
      case ErrorType.general:
        return Icons.error_outline;
    }
  }

  Color _getErrorColor(ErrorType type) {
    switch (type) {
      case ErrorType.loading:
        return const Color(0xFFFF9F0A); // Orange for loading issues
      case ErrorType.adding:
        return const Color(0xFF007AFF); // Blue for add issues
      case ErrorType.updating:
        return const Color(0xFF34C759); // Green for update issues
      case ErrorType.deleting:
        return const Color(0xFFFF3B30); // Red for delete issues
      case ErrorType.general:
        return const Color(0xFF8E8E93); // Grey for general issues
    }
  }

  void _handleRetry(BuildContext context, TaskProvider taskProvider, ErrorType errorType) {
    taskProvider.clearError();
    
    switch (errorType) {
      case ErrorType.loading:
        taskProvider.refreshTasks();
        break;
      case ErrorType.adding:
      case ErrorType.updating:
      case ErrorType.deleting:
      case ErrorType.general:
        // For these, we can't automatically retry without more context
        // Just clear the error and let user try again
        break;
    }
  }
}

/// Error state widget for displaying loading/error states
class ErrorStateWidget extends StatelessWidget {
  final String? errorMessage;
  final bool isLoading;
  final VoidCallback? onRetry;
  final Widget? child;

  const ErrorStateWidget({
    super.key,
    this.errorMessage,
    this.isLoading = false,
    this.onRetry,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF1A1A1A),
            ),
            SizedBox(height: 16),
            Text(
              'Loading tasks...',
              style: TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Color(0xFF8E8E93),
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8E8E93),
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Try Again'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return child ?? const SizedBox.shrink();
  }
}

/// Loading overlay widget
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingText;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF1A1A1A),
                    ),
                    if (loadingText != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        loadingText!,
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
} 