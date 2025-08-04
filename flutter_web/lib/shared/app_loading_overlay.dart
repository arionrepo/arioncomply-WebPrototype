// FILE PATH: lib/shared/widgets/app_loading_overlay.dart
// App Loading Overlay - Global loading indicator
// Referenced in main.dart for app-wide loading states

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Global loading overlay that can be shown over any screen
class AppLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final String? message;
  final Widget child;
  final Color? backgroundColor;

  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        message!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
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

// FILE PATH: lib/shared/widgets/app_error_boundary.dart
// App Error Boundary - Global error handling widget
// Referenced in main.dart for app-wide error catching

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../core/theme/app_colors.dart';

/// Error boundary widget that catches and displays errors gracefully
class AppErrorBoundary extends StatefulWidget {
  final Widget child;
  final void Function(FlutterErrorDetails)? onError;

  const AppErrorBoundary({
    super.key,
    required this.child,
    this.onError,
  });

  @override
  State<AppErrorBoundary> createState() => _AppErrorBoundaryState();
}

class _AppErrorBoundaryState extends State<AppErrorBoundary> {
  FlutterErrorDetails? _errorDetails;

  @override
  void initState() {
    super.initState();
    
    // Capture errors in this widget tree
    FlutterError.onError = (FlutterErrorDetails details) {
      if (mounted) {
        setState(() {
          _errorDetails = details;
        });
      }
      
      // Call custom error handler if provided
      widget.onError?.call(details);
      
      // Log error in debug mode
      if (kDebugMode) {
        FlutterError.presentError(details);
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_errorDetails != null) {
      return _buildErrorWidget();
    }
    
    return widget.child;
  }

  Widget _buildErrorWidget() {
    return Material(
      child: Container(
        color: AppColors.background,
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'We encountered an unexpected error. Please restart the app or contact support if the problem persists.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _resetError,
                    child: const Text('Try Again'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: _showErrorDetails,
                    child: const Text('Details'),
                  ),
                ],
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Debug Information:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorDetails?.exception.toString() ?? 'Unknown error',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _resetError() {
    setState(() {
      _errorDetails = null;
    });
  }

  void _showErrorDetails() {
    if (_errorDetails == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Exception:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorDetails!.exception.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Stack Trace:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorDetails!.stack.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Simple error widget for specific components
class SimpleErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;

  const SimpleErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.error_outline,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}