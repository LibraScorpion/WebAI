import 'package:flutter/material.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final String? details;
  final VoidCallback? onRetry;
  final IconData icon;

  const CustomErrorWidget({
    Key? key,
    required this.message,
    this.details,
    this.onRetry,
    this.icon = Icons.error_outline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (details != null) ...[
              const SizedBox(height: 8),
              Text(
                details!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NoDataWidget extends CustomErrorWidget {
  const NoDataWidget({
    Key? key,
    String message = 'No Data Available',
    String? details,
    VoidCallback? onRetry,
  }) : super(
          key: key,
          message: message,
          details: details,
          onRetry: onRetry,
          icon: Icons.inbox,
        );
}

class NoConnectionWidget extends CustomErrorWidget {
  const NoConnectionWidget({
    Key? key,
    String message = 'No Internet Connection',
    String? details,
    VoidCallback? onRetry,
  }) : super(
          key: key,
          message: message,
          details: details,
          onRetry: onRetry,
          icon: Icons.wifi_off,
        );
}

class ErrorHandler extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback? onRetry;

  const ErrorHandler({
    Key? key,
    required this.error,
    this.stackTrace,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String message;
    String? details;
    IconData icon;

    if (error is Exception) {
      message = 'An error occurred';
      details = error.toString();
      icon = Icons.error_outline;
    } else {
      message = 'Something went wrong';
      details = stackTrace?.toString();
      icon = Icons.warning;
    }

    return CustomErrorWidget(
      message: message,
      details: details,
      onRetry: onRetry,
      icon: icon,
    );
  }
}

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;

  const ErrorBoundary({
    Key? key,
    required this.child,
    this.errorBuilder,
  }) : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!, _stackTrace);
      }
      return ErrorHandler(
        error: _error!,
        stackTrace: _stackTrace,
        onRetry: () {
          setState(() {
            _error = null;
            _stackTrace = null;
          });
        },
      );
    }

    return widget.child;
  }

  static void reportError(Object error, StackTrace stackTrace) {
    // Implement error reporting logic here
    print('Error: $error');
    print('StackTrace: $stackTrace');
  }
}
